import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../home/domain/vocabulary_word.dart';
import '../../providers/detailed_statistics_provider.dart';
import '../../domain/user_statistics.dart';
import '../../../../common/widgets/animated_wave_background.dart';
import 'package:go_router/go_router.dart';

enum WordStatType {
  learned('Learned Words', 'Words you have mastered'),
  struggling('Struggling Words', 'Words that need more practice'),
  newWords('New Words', 'Words not yet started'),
  basic('Basic Words', 'Words with basic complexity'),
  intermediate('Intermediate Words', 'Words with intermediate complexity'),
  advanced('Advanced Words', 'Words with advanced complexity'),
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
  bool _isLoadingMoreReviewed = false;
  bool _isLoadingMoreRemaining = false;
  List<WordWithUserData> _allReviewedWords = [];
  List<WordWithUserData> _allRemainingWords = [];
  int _reviewedDisplayCount = 20;
  int _remainingDisplayCount = 20;
  bool _showReviewedSection = true;
  bool _showRemainingSection = true;

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
    // Load more for whichever section is currently being scrolled
    _loadMoreReviewedWords();
    _loadMoreRemainingWords();
  }

  void _loadMoreReviewedWords() {
    if (!_isLoadingMoreReviewed && _reviewedDisplayCount < _allReviewedWords.length && mounted) {
      setState(() {
        _isLoadingMoreReviewed = true;
      });
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _reviewedDisplayCount = (_reviewedDisplayCount + _pageSize).clamp(0, _allReviewedWords.length);
            _isLoadingMoreReviewed = false;
          });
        }
      });
    }
  }

  void _loadMoreRemainingWords() {
    if (!_isLoadingMoreRemaining && _remainingDisplayCount < _allRemainingWords.length && mounted) {
      setState(() {
        _isLoadingMoreRemaining = true;
      });
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _remainingDisplayCount = (_remainingDisplayCount + _pageSize).clamp(0, _allRemainingWords.length);
            _isLoadingMoreRemaining = false;
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
                  const PopupMenuItem(value: 'word', child: Text('Sort by Word')),
                  const PopupMenuItem(value: 'accuracy', child: Text('Sort by Accuracy')),
                  const PopupMenuItem(value: 'difficulty', child: Text('Sort by Difficulty')),
                  const PopupMenuItem(value: 'lastReviewed', child: Text('Sort by Last Reviewed')),
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
              
              // Word List with Two Sections
              Expanded(
                child: _buildTwoSectionWordList(wordsAsync, isDarkMode),
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
        final totalWords = _allReviewedWords.length + _allRemainingWords.length;
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
                'Reviewed',
                _allReviewedWords.length.toString(),
                Icons.check_circle_outline,
                MnemonicsColors.primaryGreen,
                isDarkMode,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Remaining',
                _allRemainingWords.length.toString(),
                Icons.pending_outlined,
                MnemonicsColors.secondaryOrange,
                isDarkMode,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Total',
                totalWords.toString(),
                Icons.library_books,
                Colors.blue,
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

  Widget _buildTwoSectionWordList(AsyncValue<List<WordWithUserData>> wordsAsync, bool isDarkMode) {
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
        
        // Separate words into reviewed and remaining
        final reviewedWords = allWords.where((wordData) {
          return wordData.userData != null && 
                 (wordData.userData!.reviewCount > 0 || wordData.userData!.totalAnswers > 0);
        }).toList();
        
        final remainingWords = allWords.where((wordData) {
          return wordData.userData == null || 
                 (wordData.userData!.reviewCount == 0 && wordData.userData!.totalAnswers == 0);
        }).toList();
        
        // Update the lists when data changes
        if (_allReviewedWords.length != reviewedWords.length || 
            _allRemainingWords.length != remainingWords.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _allReviewedWords = reviewedWords;
                _allRemainingWords = remainingWords;
                _reviewedDisplayCount = _pageSize.clamp(0, reviewedWords.length);
                _remainingDisplayCount = _pageSize.clamp(0, remainingWords.length);
              });
            }
          });
        }
        
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          child: Column(
            children: [
              // Reviewed Words Section
              if (_allReviewedWords.isNotEmpty) ...[
                _buildSectionHeader(
                  'Reviewed Words',
                  _allReviewedWords.length,
                  Icons.check_circle,
                  MnemonicsColors.primaryGreen,
                  _showReviewedSection,
                  () => setState(() => _showReviewedSection = !_showReviewedSection),
                  isDarkMode,
                ),
                if (_showReviewedSection) ...[
                  const SizedBox(height: MnemonicsSpacing.s),
                  _buildWordSection(
                    _allReviewedWords,
                    _reviewedDisplayCount,
                    _isLoadingMoreReviewed,
                    _loadMoreReviewedWords,
                    isDarkMode,
                    MnemonicsColors.primaryGreen.withOpacity(0.05),
                  ),
                ],
                const SizedBox(height: MnemonicsSpacing.l),
              ],
              
              // Remaining Words Section
              if (_allRemainingWords.isNotEmpty) ...[
                _buildSectionHeader(
                  'Remaining Words',
                  _allRemainingWords.length,
                  Icons.pending,
                  MnemonicsColors.secondaryOrange,
                  _showRemainingSection,
                  () => setState(() => _showRemainingSection = !_showRemainingSection),
                  isDarkMode,
                ),
                if (_showRemainingSection) ...[
                  const SizedBox(height: MnemonicsSpacing.s),
                  _buildWordSection(
                    _allRemainingWords,
                    _remainingDisplayCount,
                    _isLoadingMoreRemaining,
                    _loadMoreRemainingWords,
                    isDarkMode,
                    MnemonicsColors.secondaryOrange.withOpacity(0.05),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    String title,
    int count,
    IconData icon,
    Color color,
    bool isExpanded,
    VoidCallback onToggle,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(MnemonicsSpacing.s),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: Text(
                  title,
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MnemonicsSpacing.s,
                  vertical: MnemonicsSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                ),
                child: Text(
                  count.toString(),
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordSection(
    List<WordWithUserData> words,
    int displayCount,
    bool isLoadingMore,
    VoidCallback loadMore,
    bool isDarkMode,
    Color backgroundColor,
  ) {
    final displayedWords = words.take(displayCount).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      ),
      padding: const EdgeInsets.all(MnemonicsSpacing.s),
      child: Column(
        children: [
          ...displayedWords.map((wordData) => Padding(
            padding: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
            child: _buildWordCard(wordData, isDarkMode),
          )),
          
          // Load more button
          if (displayedWords.length < words.length) ...[
            const SizedBox(height: MnemonicsSpacing.s),
            if (isLoadingMore)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: loadMore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
                  foregroundColor: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                ),
                child: Text('Load More (${words.length - displayedWords.length} remaining)'),
              ),
          ],
        ],
      ),
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
                            userData.learningStage.displayName.toUpperCase(),
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
                      final difficultyLevel = word.difficulty.numericValue;
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

  Color _getStageColor(LearningStage stage) {
    switch (stage) {
      case LearningStage.mastered:
        return MnemonicsColors.primaryGreen;
      case LearningStage.learning:
        return MnemonicsColors.secondaryOrange;
      case LearningStage.newWord:
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
    return words.where((w) => w.userData?.learningStage == LearningStage.mastered).length;
  }

  void _updateSort(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _reviewedDisplayCount = _pageSize; // Reset display count when sorting changes
      _remainingDisplayCount = _pageSize;
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _sortAscending = !_sortAscending;
      _reviewedDisplayCount = _pageSize; // Reset display count when sort order changes
      _remainingDisplayCount = _pageSize;
    });
  }

  void _performSearch(String query) {
    setState(() {
      _currentSearch = query;
      _reviewedDisplayCount = _pageSize; // Reset display count when search changes
      _remainingDisplayCount = _pageSize;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentSearch = '';
      _reviewedDisplayCount = _pageSize; // Reset display count when search is cleared
      _remainingDisplayCount = _pageSize;
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