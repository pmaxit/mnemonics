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
import '../../../../profile/domain/user_statistics.dart';

class WordsTodayDetailScreen extends ConsumerStatefulWidget {
  const WordsTodayDetailScreen({super.key});

  @override
  ConsumerState<WordsTodayDetailScreen> createState() => _WordsTodayDetailScreenState();
}

class _WordsTodayDetailScreenState extends ConsumerState<WordsTodayDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';

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
        title: const Text('📚 Words Learned Today'),
        backgroundColor: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        foregroundColor: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
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
                  final todaysWords = _getTodaysLearnedWords(allWords, userWordDataList);
                  final filteredWords = _filterWords(todaysWords);
                  
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
                              child: _buildSummaryHeader(todaysWords, statistics.learnedToday, isDarkMode),
                            ),
                            
                            // Search and filters
                            AnimatedProgressUtils.buildStaggeredAnimation(
                              animation: _pageAnimation,
                              index: 1,
                              child: _buildSearchAndFilters(todaysWords, isDarkMode),
                            ),
                            
                            // Words list
                            Expanded(
                              child: AnimatedProgressUtils.buildStaggeredAnimation(
                                animation: _pageAnimation,
                                index: 2,
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

  List<({VocabularyWord word, UserWordData userData})> _getTodaysLearnedWords(
    List<VocabularyWord> allWords,
    List<UserWordData> userWordDataList,
  ) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final todaysLearned = <({VocabularyWord word, UserWordData userData})>[];
    
    for (final userData in userWordDataList) {
      if (userData.firstLearnedAt != null &&
          userData.firstLearnedAt!.isAfter(todayStart) &&
          userData.firstLearnedAt!.isBefore(todayEnd)) {
        
        final word = allWords.firstWhere(
          (w) => w.word == userData.word,
          orElse: () => const VocabularyWord(
            word: 'Unknown',
            meaning: 'Word not found',
            mnemonic: '',
            example: '',
            synonyms: [],
            antonyms: [],
            difficulty: WordDifficulty.intermediate,
            category: 'unknown',
          ),
        );
        
        if (word.word != 'Unknown') {
          todaysLearned.add((word: word, userData: userData));
        }
      }
    }
    
    // Sort by learning time (most recent first)
    todaysLearned.sort((a, b) => b.userData.firstLearnedAt!.compareTo(a.userData.firstLearnedAt!));
    
    return todaysLearned;
  }

  List<({VocabularyWord word, UserWordData userData})> _filterWords(
    List<({VocabularyWord word, UserWordData userData})> words,
  ) {
    return words.where((item) {
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
      if (_selectedDifficulty != 'All' && word.difficulty.name != _selectedDifficulty.toLowerCase()) {
        return false;
      }
      
      return true;
    }).toList();
  }

  Widget _buildSummaryHeader(
    List<({VocabularyWord word, UserWordData userData})> todaysWords,
    int learnedToday,
    bool isDarkMode,
  ) {
    final averageAccuracy = todaysWords.isEmpty ? 0.0 : 
        todaysWords.map((item) => item.userData.accuracyRate).reduce((a, b) => a + b) / todaysWords.length;
    
    return Container(
      margin: const EdgeInsets.all(MnemonicsSpacing.l),
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MnemonicsColors.secondaryOrange.withOpacity(0.1),
            MnemonicsColors.secondaryOrange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        border: Border.all(
          color: MnemonicsColors.secondaryOrange.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Words Learned',
                  learnedToday.toString(),
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
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Easiest',
                  todaysWords.where((item) => item.word.difficulty == WordDifficulty.basic).length.toString(),
                  Icons.sentiment_very_satisfied,
                  Colors.green,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: _buildSummaryCard(
                  'Hardest',
                  todaysWords.where((item) => item.word.difficulty == WordDifficulty.advanced).length.toString(),
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
    List<({VocabularyWord word, UserWordData userData})> todaysWords,
    bool isDarkMode,
  ) {
    final categories = ['All'] + todaysWords.map((item) => item.word.category).toSet().map((c) => 
        c[0].toUpperCase() + c.substring(1)).toList();
    final difficulties = ['All', 'Easy', 'Medium', 'Hard'];
    
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
          
          // Filters
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
              const SizedBox(width: MnemonicsSpacing.m),
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
              _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedDifficulty != 'All'
                  ? 'No words match your filters'
                  : 'No words learned today yet!',
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedDifficulty != 'All'
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
          index: index + 3,
          child: _buildWordCard(item.word, item.userData, isDarkMode, index),
        );
      },
    );
  }

  Widget _buildWordCard(VocabularyWord word, UserWordData userData, bool isDarkMode, int index) {
    final difficultyColor = _getDifficultyColor(word.difficulty);
    final learningTime = userData.firstLearnedAt?.toLocal().toString().substring(11, 16) ?? 'Unknown';
    
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
            // Navigate to word detail screen or show popup
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
                        word.difficulty.displayName.toUpperCase(),
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: difficultyColor,
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
                
                // Mnemonic
                if (word.mnemonic.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(MnemonicsSpacing.s),
                    decoration: BoxDecoration(
                      color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
                    ),
                    child: Text(
                      word.mnemonic,
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
                      Icons.schedule,
                      size: 16,
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                    ),
                    const SizedBox(width: MnemonicsSpacing.xs),
                    Text(
                      'Learned at $learningTime',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    
                    Icon(
                      Icons.psychology,
                      size: 16,
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                    ),
                    const SizedBox(width: MnemonicsSpacing.xs),
                    Text(
                      '${(userData.accuracyRate * 100).round()}% accuracy',
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
              
              Text(
                'Learning Stats:',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text('Reviews: ${userData.reviewCount}'),
              Text('Accuracy: ${(userData.accuracyRate * 100).round()}%'),
              Text('Stage: ${userData.learningStage}'),
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

  Color _getDifficultyColor(WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.basic:
        return Colors.green;
      case WordDifficulty.intermediate:
        return Colors.orange;
      case WordDifficulty.advanced:
        return Colors.red;
    }
  }
}