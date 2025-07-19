import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/design/design_system.dart';
import '../../../../../common/design/theme_provider.dart';
import '../../../providers/statistics_provider.dart';
import '../../../../home/providers.dart';
import '../../../../home/domain/vocabulary_word.dart';
import '../../../../home/domain/user_word_data.dart';
import '../../widgets/animated_progress_utils.dart';

class TotalWordsDetailScreen extends ConsumerStatefulWidget {
  const TotalWordsDetailScreen({super.key});

  @override
  ConsumerState<TotalWordsDetailScreen> createState() => _TotalWordsDetailScreenState();
}

class _TotalWordsDetailScreenState extends ConsumerState<TotalWordsDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  String _selectedStage = 'All';
  String _sortBy = 'Recent'; // Recent, Alphabetical, Difficulty, Accuracy

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: AnimatedProgressUtils.pageTransition,
      vsync: this,
    );
    
    _pageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: AnimatedProgressUtils.entryEasing,
    ));
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _pageController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statisticsAsync = ref.watch(statisticsProvider);
    final allWordsAsync = ref.watch(vocabularyListProvider);
    final userWordDataAsync = ref.watch(allUserWordDataProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.background,
      appBar: AppBar(
        title: const Text('🎓 All Learned Words'),
        backgroundColor: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        foregroundColor: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Recent', child: Text('Recently Learned')),
              const PopupMenuItem(value: 'Alphabetical', child: Text('Alphabetical')),
              const PopupMenuItem(value: 'Difficulty', child: Text('By Difficulty')),
              const PopupMenuItem(value: 'Accuracy', child: Text('By Accuracy')),
            ],
          ),
        ],
      ),
      body: statisticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (statistics) {
          return allWordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error loading words: $error')),
            data: (allWords) {
              return userWordDataAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error loading user data: $error')),
                data: (userWordDataList) {
                  final learnedWords = _getLearnedWords(allWords, userWordDataList);
                  final filteredWords = _filterAndSortWords(learnedWords);
                  
                  return AnimatedBuilder(
                    animation: _pageAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pageAnimation.value,
                        child: Column(
                          children: [
                            // Summary header
                            AnimatedProgressUtils.buildStaggeredAnimation(
                              animation: _pageAnimation,
                              index: 0,
                              child: _buildSummaryHeader(learnedWords, statistics, isDarkMode),
                            ),
                            
                            // Search and filters
                            AnimatedProgressUtils.buildStaggeredAnimation(
                              animation: _pageAnimation,
                              index: 1,
                              child: _buildSearchAndFilters(learnedWords, isDarkMode),
                            ),
                            
                            // Results count
                            AnimatedProgressUtils.buildStaggeredAnimation(
                              animation: _pageAnimation,
                              index: 2,
                              child: _buildResultsHeader(filteredWords.length, isDarkMode),
                            ),
                            
                            // Words list
                            Expanded(
                              child: AnimatedProgressUtils.buildStaggeredAnimation(
                                animation: _pageAnimation,
                                index: 3,
                                child: _buildWordsList(filteredWords, isDarkMode),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  List<({VocabularyWord word, UserWordData userData})> _getLearnedWords(
    List<VocabularyWord> allWords,
    List<UserWordData> userWordDataList,
  ) {
    final learnedWords = <({VocabularyWord word, UserWordData userData})>[];
    
    for (final userData in userWordDataList) {
      if (userData.isLearned || userData.learningStage != 'new') {
        final word = allWords.firstWhere(
          (w) => w.word == userData.word,
          orElse: () => const VocabularyWord(
            word: 'Unknown',
            meaning: 'Word not found',
            mnemonic: '',
            example: '',
            synonyms: [],
            antonyms: [],
            difficulty: 'medium',
            category: 'unknown',
          ),
        );
        
        if (word.word != 'Unknown') {
          learnedWords.add((word: word, userData: userData));
        }
      }
    }
    
    return learnedWords;
  }

  List<({VocabularyWord word, UserWordData userData})> _filterAndSortWords(
    List<({VocabularyWord word, UserWordData userData})> words,
  ) {
    var filtered = words.where((item) {
      final word = item.word;
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!word.word.toLowerCase().contains(query) &&
            !word.meaning.toLowerCase().contains(query) &&
            !word.mnemonic.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Category filter
      if (_selectedCategory != 'All' && word.category != _selectedCategory.toLowerCase()) {
        return false;
      }
      
      // Difficulty filter
      if (_selectedDifficulty != 'All' && word.difficulty != _selectedDifficulty.toLowerCase()) {
        return false;
      }
      
      // Learning stage filter
      if (_selectedStage != 'All' && item.userData.learningStage != _selectedStage.toLowerCase()) {
        return false;
      }
      
      return true;
    }).toList();

    // Sort the filtered words
    switch (_sortBy) {
      case 'Recent':
        filtered.sort((a, b) {
          final aTime = a.userData.firstLearnedAt ?? DateTime(1970);
          final bTime = b.userData.firstLearnedAt ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
        break;
      case 'Alphabetical':
        filtered.sort((a, b) => a.word.word.compareTo(b.word.word));
        break;
      case 'Difficulty':
        final difficultyOrder = ['easy', 'medium', 'hard'];
        filtered.sort((a, b) {
          final aIndex = difficultyOrder.indexOf(a.word.difficulty);
          final bIndex = difficultyOrder.indexOf(b.word.difficulty);
          return aIndex.compareTo(bIndex);
        });
        break;
      case 'Accuracy':
        filtered.sort((a, b) => b.userData.accuracyRate.compareTo(a.userData.accuracyRate));
        break;
    }
    
    return filtered;
  }

  Widget _buildSummaryHeader(
    List<({VocabularyWord word, UserWordData userData})> learnedWords,
    dynamic statistics,
    bool isDarkMode,
  ) {
    final averageAccuracy = learnedWords.isEmpty ? 0.0 : 
        learnedWords.map((item) => item.userData.accuracyRate).reduce((a, b) => a + b) / learnedWords.length;
    
    final categoryBreakdown = <String, int>{};
    final difficultyBreakdown = <String, int>{};
    final stageBreakdown = <String, int>{};
    
    for (final item in learnedWords) {
      categoryBreakdown[item.word.category] = (categoryBreakdown[item.word.category] ?? 0) + 1;
      difficultyBreakdown[item.word.difficulty] = (difficultyBreakdown[item.word.difficulty] ?? 0) + 1;
      stageBreakdown[item.userData.learningStage] = (stageBreakdown[item.userData.learningStage] ?? 0) + 1;
    }
    
    return Container(
      margin: const EdgeInsets.all(MnemonicsSpacing.l),
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MnemonicsColors.primaryGreen.withOpacity(0.1),
            MnemonicsColors.primaryGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        border: Border.all(
          color: MnemonicsColors.primaryGreen.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Words',
                  learnedWords.length.toString(),
                  Icons.school,
                  MnemonicsColors.primaryGreen,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: _buildSummaryCard(
                  'Avg Accuracy',
                  '${(averageAccuracy * 100).round()}%',
                  Icons.psychology,
                  Colors.blue,
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          
          // Middle row
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Mastered',
                  stageBreakdown['mastered']?.toString() ?? '0',
                  Icons.star,
                  Colors.amber,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: _buildSummaryCard(
                  'Learning',
                  stageBreakdown['learning']?.toString() ?? '0',
                  Icons.psychology,
                  Colors.orange,
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          
          // Bottom row
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Most Common',
                  _getMostCommon(categoryBreakdown),
                  Icons.category,
                  Colors.purple,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: _buildSummaryCard(
                  'Hardest Level',
                  difficultyBreakdown['hard']?.toString() ?? '0',
                  Icons.sentiment_very_dissatisfied,
                  Colors.red,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMostCommon(Map<String, int> breakdown) {
    if (breakdown.isEmpty) return 'None';
    var maxEntry = breakdown.entries.first;
    for (final entry in breakdown.entries) {
      if (entry.value > maxEntry.value) {
        maxEntry = entry;
      }
    }
    return '${maxEntry.key[0].toUpperCase()}${maxEntry.key.substring(1)}';
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        border: isDarkMode
            ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3))
            : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: MnemonicsSpacing.xs),
          Text(
            value,
            style: MnemonicsTypography.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(
    List<({VocabularyWord word, UserWordData userData})> learnedWords,
    bool isDarkMode,
  ) {
    final categories = ['All'] + learnedWords.map((item) => item.word.category).toSet().map((c) => 
        c[0].toUpperCase() + c.substring(1)).toList();
    final difficulties = ['All', 'Easy', 'Medium', 'Hard'];
    final stages = ['All', 'Learning', 'Mastered'];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.l),
      child: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.m),
            decoration: BoxDecoration(
              color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              border: isDarkMode
                  ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3))
                  : null,
              boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search words, meanings, or mnemonics...',
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                ),
                hintStyle: TextStyle(
                  color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          
          // Filters row 1
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Category',
                  _selectedCategory,
                  categories,
                  (value) => setState(() => _selectedCategory = value),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: _buildFilterDropdown(
                  'Difficulty',
                  _selectedDifficulty,
                  difficulties,
                  (value) => setState(() => _selectedDifficulty = value),
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          
          // Filters row 2
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Stage',
                  _selectedStage,
                  stages,
                  (value) => setState(() => _selectedStage = value),
                  isDarkMode,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.m, vertical: MnemonicsSpacing.s),
                  decoration: BoxDecoration(
                    color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                    border: isDarkMode
                        ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3))
                        : null,
                    boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort,
                        size: 16,
                        color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                      ),
                      const SizedBox(width: MnemonicsSpacing.xs),
                      Text(
                        'Sort: $_sortBy',
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        border: isDarkMode
            ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3))
            : null,
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
          ),
          style: TextStyle(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontSize: 14,
          ),
          dropdownColor: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
          onChanged: (newValue) => onChanged(newValue!),
          items: options.map<DropdownMenuItem<String>>((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text('$label: $option'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(int count, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.l, vertical: MnemonicsSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count words found',
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'All' || 
              _selectedDifficulty != 'All' || _selectedStage != 'All')
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'All';
                  _selectedDifficulty = 'All';
                  _selectedStage = 'All';
                });
              },
              child: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildWordsList(
    List<({VocabularyWord word, UserWordData userData})> words,
    bool isDarkMode,
  ) {
    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
            const SizedBox(height: MnemonicsSpacing.l),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'All' || 
              _selectedDifficulty != 'All' || _selectedStage != 'All'
                  ? 'No words match your filters'
                  : 'No words learned yet!',
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'All' || 
              _selectedDifficulty != 'All' || _selectedStage != 'All'
                  ? 'Try adjusting your search or filters'
                  : 'Start learning to see your progress here!',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final item = words[index];
        return AnimatedProgressUtils.buildStaggeredAnimation(
          animation: _pageAnimation,
          index: index + 4,
          child: _buildWordCard(item.word, item.userData, isDarkMode, index),
        );
      },
    );
  }

  Widget _buildWordCard(VocabularyWord word, UserWordData userData, bool isDarkMode, int index) {
    final difficultyColor = _getDifficultyColor(word.difficulty);
    final stageColor = _getStageColor(userData.learningStage);
    final learnedDate = userData.firstLearnedAt?.toLocal().toString().substring(0, 10) ?? 'Unknown';
    
    return Container(
      margin: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
        border: isDarkMode
            ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          onTap: () {
            _showWordDetail(word, userData, isDarkMode);
          },
          child: Padding(
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.word,
                        style: MnemonicsTypography.headingMedium.copyWith(
                          color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MnemonicsSpacing.s,
                        vertical: MnemonicsSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
                      ),
                      child: Text(
                        word.difficulty.toUpperCase(),
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: difficultyColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: MnemonicsSpacing.s),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MnemonicsSpacing.s,
                        vertical: MnemonicsSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: stageColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
                      ),
                      child: Text(
                        userData.learningStage.toUpperCase(),
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: stageColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MnemonicsSpacing.s),
                
                // Meaning
                Text(
                  word.meaning,
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: MnemonicsSpacing.s),
                
                // Mnemonic (truncated)
                if (word.mnemonic.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(MnemonicsSpacing.s),
                    decoration: BoxDecoration(
                      color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
                    ),
                    child: Text(
                      word.mnemonic.length > 100 
                          ? '${word.mnemonic.substring(0, 100)}...'
                          : word.mnemonic,
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: MnemonicsColors.primaryGreen,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: MnemonicsSpacing.s),
                ],
                
                // Stats row
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                    ),
                    const SizedBox(width: MnemonicsSpacing.xs),
                    Text(
                      learnedDate,
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    
                    Icon(
                      Icons.repeat,
                      size: 14,
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                    ),
                    const SizedBox(width: MnemonicsSpacing.xs),
                    Text(
                      '${userData.reviewCount} reviews',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: MnemonicsSpacing.m),
                    
                    Icon(
                      Icons.psychology,
                      size: 14,
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                    ),
                    const SizedBox(width: MnemonicsSpacing.xs),
                    Text(
                      '${(userData.accuracyRate * 100).round()}%',
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
      ),
    );
  }

  void _showWordDetail(VocabularyWord word, UserWordData userData, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        ),
        title: Text(
          word.word,
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Meaning:',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(word.meaning),
              const SizedBox(height: MnemonicsSpacing.m),
              
              if (word.example.isNotEmpty) ...[
                Text(
                  'Example:',
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(word.example, style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: MnemonicsSpacing.m),
              ],
              
              if (word.mnemonic.isNotEmpty) ...[
                Text(
                  'Mnemonic:',
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(word.mnemonic, style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: MnemonicsSpacing.m),
              ],
              
              Text(
                'Learning Progress:',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text('Stage: ${userData.learningStage}'),
              Text('Reviews: ${userData.reviewCount}'),
              Text('Accuracy: ${(userData.accuracyRate * 100).round()}%'),
              if (userData.firstLearnedAt != null)
                Text('First learned: ${userData.firstLearnedAt!.toLocal().toString().substring(0, 10)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'learning':
        return Colors.orange;
      case 'mastered':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}