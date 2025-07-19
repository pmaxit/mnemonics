import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../home/domain/vocabulary_word.dart';
import '../../../home/domain/user_word_data.dart';
import '../../../home/providers.dart';
import '../../providers/detailed_statistics_provider.dart';
import '../../../../common/widgets/animated_wave_background.dart';
import 'package:go_router/go_router.dart';

enum WordStatType {
  learned('Learned Words', 'Words you have mastered'),
  struggling('Struggling Words', 'Words that need more practice'),
  newWords('New Words', 'Words not yet started'),
  easy('Easy Words', 'Words rated as easy'),
  medium('Medium Words', 'Words rated as medium'),
  hard('Hard Words', 'Words rated as hard'),
  category('Category Words', 'Words from specific category'),
  allWords('All Words', 'Complete vocabulary list');

  const WordStatType(this.title, this.description);
  final String title;
  final String description;
}

class DetailedWordStatisticsScreen extends ConsumerStatefulWidget {
  final WordStatType statType;
  final String? categoryFilter;
  final String? searchQuery;

  const DetailedWordStatisticsScreen({
    super.key,
    required this.statType,
    this.categoryFilter,
    this.searchQuery,
  });

  @override
  ConsumerState<DetailedWordStatisticsScreen> createState() => _DetailedWordStatisticsScreenState();
}

class _DetailedWordStatisticsScreenState extends ConsumerState<DetailedWordStatisticsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _sortBy = 'word'; // word, accuracy, difficulty, lastReviewed
  bool _sortAscending = true;
  String _currentSearch = '';
  
  static const int _pageSize = 20;
  bool _isLoadingMore = false;
  List<WordWithUserData> _allLoadedWords = [];
  int _displayCount = 20; // Number of items currently being displayed

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';
    _currentSearch = widget.searchQuery ?? '';
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreWords();
    }
  }

  void _loadMoreWords() {
    if (!_isLoadingMore && _displayCount < _allLoadedWords.length && mounted) {
      setState(() {
        _isLoadingMore = true;
      });
      
      // Increase display count to show more items
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _displayCount = (_displayCount + _pageSize).clamp(0, _allLoadedWords.length);
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    final wordsAsync = ref.watch(filteredWordsProvider(FilterParams(
      statType: widget.statType,
      categoryFilter: widget.categoryFilter,
      searchQuery: _currentSearch,
      sortBy: _sortBy,
      sortAscending: _sortAscending,
      page: 0, // Always get from start
      pageSize: 1000, // Load all words at once
    )));

    final screenHeight = MediaQuery.of(context).size.height;
    
    return Stack(
      children: [
        AnimatedWaveBackground(height: screenHeight),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(widget.statType.title),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) => _updateSort(value),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'word', child: Text('Sort by Word')),
                  PopupMenuItem(value: 'accuracy', child: Text('Sort by Accuracy')),
                  PopupMenuItem(value: 'difficulty', child: Text('Sort by Difficulty')),
                  PopupMenuItem(value: 'lastReviewed', child: Text('Sort by Last Reviewed')),
                ],
              ),
              IconButton(
                icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                onPressed: () => _toggleSortOrder(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search and Filter Header
              _buildSearchHeader(isDarkMode),
              
              // Statistics Summary
              _buildStatsSummary(wordsAsync, isDarkMode),
              
              // Word List
              Expanded(
                child: _buildWordList(wordsAsync, isDarkMode),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(MnemonicsSpacing.m),
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.statType.description,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search words...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _currentSearch.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDarkMode 
                  ? MnemonicsColors.darkBackground 
                  : MnemonicsColors.surface,
            ),
            onSubmitted: _performSearch,
            textInputAction: TextInputAction.search,
          ),
          
          if (widget.categoryFilter != null) ...[
            const SizedBox(height: MnemonicsSpacing.s),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MnemonicsSpacing.s,
                vertical: MnemonicsSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: MnemonicsColors.primaryGreen,
                  ),
                  const SizedBox(width: MnemonicsSpacing.xs),
                  Text(
                    'Category: ${widget.categoryFilter}',
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: MnemonicsColors.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSummary(AsyncValue<List<WordWithUserData>> wordsAsync, bool isDarkMode) {
    return wordsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (words) {
        // Use allLoadedWords if available, otherwise fall back to words from provider
        final wordsToAnalyze = _allLoadedWords.isNotEmpty ? _allLoadedWords : words;
        return Container(
        margin: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.m),
        padding: const EdgeInsets.all(MnemonicsSpacing.m),
        decoration: BoxDecoration(
          color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Total',
                wordsToAnalyze.length.toString(),
                Icons.library_books,
                MnemonicsColors.primaryGreen,
                isDarkMode,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Avg Accuracy',
                '${_calculateAverageAccuracy(wordsToAnalyze).toStringAsFixed(1)}%',
                Icons.trending_up,
                MnemonicsColors.secondaryOrange,
                isDarkMode,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Mastered',
                _countMastered(wordsToAnalyze).toString(),
                Icons.stars,
                Colors.amber,
                isDarkMode,
              ),
            ),
          ],
        ),
      );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: MnemonicsSpacing.xs),
        Text(
          value,
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWordList(AsyncValue<List<WordWithUserData>> wordsAsync, bool isDarkMode) {
    return wordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            Text(
              'Error loading words',
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
            ),
            Text(
              error.toString(),
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      data: (allWords) {
        if (allWords.isEmpty) {
          return _buildEmptyState(isDarkMode);
        }
        
        // Update loaded words when data changes
        if (_allLoadedWords.length != allWords.length || 
            (_allLoadedWords.isNotEmpty && allWords.isNotEmpty && 
             _allLoadedWords.first.word.word != allWords.first.word.word)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _allLoadedWords = allWords;
                _displayCount = _pageSize.clamp(0, allWords.length); // Reset display count
              });
            }
          });
        }
        
        final displayedWords = _allLoadedWords.take(_displayCount).toList();
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          itemCount: displayedWords.length + 
                    (displayedWords.length < _allLoadedWords.length ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= displayedWords.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(MnemonicsSpacing.m),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final wordData = displayedWords[index];
            return _buildWordCard(wordData, isDarkMode);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Text(
            'No words found',
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Text(
            'Try adjusting your search criteria',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(WordWithUserData wordData, bool isDarkMode) {
    final word = wordData.word;
    final userData = wordData.userData;
    
    return Container(
      margin: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        onTap: () => _navigateToWordDetail(word),
        child: Padding(
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sanitizeText(word.word),
                          style: MnemonicsTypography.bodyLarge.copyWith(
                            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: MnemonicsSpacing.xs),
                        Text(
                          _sanitizeText(word.meaning),
                          style: MnemonicsTypography.bodyRegular.copyWith(
                            color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress indicators
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (userData != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: MnemonicsSpacing.s,
                            vertical: MnemonicsSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _getStageColor(userData.learningStage).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                          ),
                          child: Text(
                            userData.learningStage.toUpperCase(),
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              color: _getStageColor(userData.learningStage),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: MnemonicsSpacing.xs),
                        if (userData.totalAnswers > 0)
                          Text(
                            '${(userData.accuracyRate * 100).toStringAsFixed(0)}% accuracy',
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: MnemonicsSpacing.s,
                            vertical: MnemonicsSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: MnemonicsColors.textSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                          ),
                          child: Text(
                            'NEW',
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              color: MnemonicsColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: MnemonicsSpacing.s),
              
              // Category and difficulty
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MnemonicsSpacing.s,
                      vertical: MnemonicsSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                    ),
                    child: Text(
                      _sanitizeText(word.category),
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: MnemonicsColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: MnemonicsSpacing.s),
                  Row(
                    children: List.generate(3, (index) {
                      final difficultyLevel = word.difficulty.toLowerCase() == 'easy' ? 1 :
                                            word.difficulty.toLowerCase() == 'medium' ? 2 : 3;
                      return Icon(
                        index < difficultyLevel ? Icons.star : Icons.star_border,
                        color: MnemonicsColors.secondaryOrange,
                        size: 16,
                      );
                    }),
                  ),
                  const Spacer(),
                  if (userData?.lastReviewedAt != null)
                    Text(
                      _formatLastReviewed(userData!.lastReviewedAt!),
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'mastered':
        return MnemonicsColors.primaryGreen;
      case 'learning':
        return MnemonicsColors.secondaryOrange;
      case 'new':
      default:
        return MnemonicsColors.textSecondary;
    }
  }

  String _formatLastReviewed(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Recently';
    }
  }

  double _calculateAverageAccuracy(List<WordWithUserData> words) {
    final wordsWithData = words.where((w) => w.userData != null && w.userData!.totalAnswers > 0).toList();
    if (wordsWithData.isEmpty) return 0.0;
    
    final totalAccuracy = wordsWithData.fold<double>(0.0, (sum, w) => sum + w.userData!.accuracyRate);
    return (totalAccuracy / wordsWithData.length) * 100;
  }

  int _countMastered(List<WordWithUserData> words) {
    return words.where((w) => w.userData?.learningStage == 'mastered').length;
  }

  void _updateSort(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _displayCount = _pageSize; // Reset display count when sorting changes
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _sortAscending = !_sortAscending;
      _displayCount = _pageSize; // Reset display count when sort order changes
    });
  }

  void _performSearch(String query) {
    setState(() {
      _currentSearch = query;
      _displayCount = _pageSize; // Reset display count when search changes
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentSearch = '';
      _displayCount = _pageSize; // Reset display count when search is cleared
    });
  }

  void _navigateToWordDetail(VocabularyWord word) {
    context.push('/flashcards', extra: {
      'words': [word],
      'initialIndex': 0,
    });
  }

  String _sanitizeText(String text) {
    if (text.isEmpty) return text;
    
    // Remove any invalid Unicode characters
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      
      // Check for valid UTF-16 code units
      if (codeUnit >= 0x20 && codeUnit <= 0xD7FF) {
        // Basic Latin, Latin-1 Supplement, and other BMP characters
        buffer.writeCharCode(codeUnit);
      } else if (codeUnit >= 0xE000 && codeUnit <= 0xFFFD) {
        // Private use area and other valid BMP characters
        buffer.writeCharCode(codeUnit);
      } else if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF && i + 1 < text.length) {
        // High surrogate - check if followed by low surrogate
        final nextCodeUnit = text.codeUnitAt(i + 1);
        if (nextCodeUnit >= 0xDC00 && nextCodeUnit <= 0xDFFF) {
          // Valid surrogate pair
          buffer.writeCharCode(codeUnit);
          buffer.writeCharCode(nextCodeUnit);
          i++; // Skip the low surrogate in next iteration
        } else {
          // Invalid surrogate pair - replace with replacement character
          buffer.write('�');
        }
      } else if (codeUnit >= 0x09 && codeUnit <= 0x0D) {
        // Tab, newline, carriage return - keep these
        buffer.writeCharCode(codeUnit);
      } else {
        // Replace invalid characters with replacement character
        buffer.write('�');
      }
    }
    
    return buffer.toString();
  }
}