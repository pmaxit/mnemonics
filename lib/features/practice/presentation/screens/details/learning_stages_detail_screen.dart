import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/design/design_system.dart';
import '../../../../../common/design/theme_provider.dart';
import '../../../providers/statistics_provider.dart';
import '../../../../home/providers.dart';
import '../../../../home/domain/vocabulary_word.dart';
import '../../../../home/domain/user_word_data.dart';
import '../../../../profile/domain/user_statistics.dart';
import '../../widgets/animated_progress_utils.dart';

class LearningStagesDetailScreen extends ConsumerStatefulWidget {
  final String stage;
  
  const LearningStagesDetailScreen({
    super.key,
    required this.stage,
  });

  @override
  ConsumerState<LearningStagesDetailScreen> createState() => _LearningStagesDetailScreenState();
}

class _LearningStagesDetailScreenState extends ConsumerState<LearningStagesDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
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

  String get _stageTitle {
    switch (widget.stage.toLowerCase()) {
      case 'new':
        return '🆕 New Words';
      case 'learning':
        return '🧠 Learning Words';
      case 'mastered':
        return '⭐ Mastered Words';
      default:
        return '📚 Words';
    }
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
        title: Text(_stageTitle),
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
              const PopupMenuItem(value: 'Recent', child: Text('Recently Updated')),
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
                  final stageWords = _getStageWords(allWords, userWordDataList, widget.stage);
                  final filteredWords = _filterAndSortWords(stageWords);
                  
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
                              child: _buildSummaryHeader(stageWords, widget.stage, isDarkMode),
                            ),
                            
                            // Search and filters
                            AnimatedProgressUtils.buildStaggeredAnimation(
                              animation: _pageAnimation,
                              index: 1,
                              child: _buildSearchAndFilters(stageWords, isDarkMode),
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

  List<({VocabularyWord word, UserWordData userData})> _getStageWords(
    List<VocabularyWord> allWords,
    List<UserWordData> userWordDataList,
    String stage,
  ) {
    final stageWords = <({VocabularyWord word, UserWordData userData})>[];
    
    for (final userData in userWordDataList) {
      if (userData.learningStage.name.toLowerCase() == stage.toLowerCase()) {
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
          stageWords.add((word: word, userData: userData));
        }
      }
    }
    
    return stageWords;
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
      
      return true;
    }).toList();

    // Sort the filtered words
    switch (_sortBy) {
      case 'Recent':
        filtered.sort((a, b) {
          final aTime = a.userData.lastReviewedAt ?? a.userData.firstLearnedAt ?? DateTime(1970);
          final bTime = b.userData.lastReviewedAt ?? b.userData.firstLearnedAt ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
        break;
      case 'Alphabetical':
        filtered.sort((a, b) => a.word.word.compareTo(b.word.word));
        break;
      case 'Difficulty':
        final difficultyOrder = [WordDifficulty.basic, WordDifficulty.intermediate, WordDifficulty.advanced];
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
    List<({VocabularyWord word, UserWordData userData})> stageWords,
    String stage,
    bool isDarkMode,
  ) {
    final stageColor = _getStageColor(stage);
    final averageAccuracy = stageWords.isEmpty ? 0.0 : 
        stageWords.map((item) => item.userData.accuracyRate).reduce((a, b) => a + b) / stageWords.length;
    
    final difficultyBreakdown = <String, int>{};
    final categoryBreakdown = <String, int>{};
    
    for (final item in stageWords) {
      difficultyBreakdown[item.word.difficulty.name] = (difficultyBreakdown[item.word.difficulty.name] ?? 0) + 1;
      categoryBreakdown[item.word.category] = (categoryBreakdown[item.word.category] ?? 0) + 1;
    }
    
    return Container(
      margin: const EdgeInsets.all(MnemonicsSpacing.l),
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stageColor.withOpacity(0.1),
            stageColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        border: Border.all(
          color: stageColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: Column(
        children: [
          // Stage icon and count
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(MnemonicsSpacing.l),
                decoration: BoxDecoration(
                  color: stageColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStageIcon(stage),
                  size: 32,
                  color: stageColor,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedProgressUtils.buildCountUpAnimation(
                      animation: _pageAnimation,
                      targetValue: stageWords.length,
                      suffix: stageWords.length == 1 ? ' Word' : ' Words',
                      style: MnemonicsTypography.headingLarge.copyWith(
                        color: stageColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStageDescription(stage),
                      style: MnemonicsTypography.bodyLarge.copyWith(
                        color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          
          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Avg Accuracy',
                  '${(averageAccuracy * 100).round()}%',
                  Icons.psychology,
                  Colors.blue,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: _buildSummaryCard(
                  'Most Common',
                  _getMostCommon(difficultyBreakdown),
                  Icons.trending_up,
                  Colors.green,
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
    List<({VocabularyWord word, UserWordData userData})> stageWords,
    bool isDarkMode,
  ) {
    final categories = ['All'] + stageWords.map((item) => item.word.category).toSet().map((c) => 
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
          if (_searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedDifficulty != 'All')
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'All';
                  _selectedDifficulty = 'All';
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
              _getStageIcon(widget.stage),
              size: 64,
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
            const SizedBox(height: MnemonicsSpacing.l),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedDifficulty != 'All'
                  ? 'No words match your filters'
                  : 'No ${widget.stage.toLowerCase()} words yet!',
              style: MnemonicsTypography.bodyLarge.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedDifficulty != 'All'
                  ? 'Try adjusting your search or filters'
                  : _getEmptyStateMessage(widget.stage),
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
    final stageColor = _getStageColor(widget.stage);
    final lastActivity = userData.lastReviewedAt ?? userData.firstLearnedAt;
    
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
                        word.difficulty.name.toUpperCase(),
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
                
                // Progress bar for learning stage
                if (widget.stage.toLowerCase() == 'learning') ...[
                  LinearProgressIndicator(
                    value: userData.accuracyRate,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(stageColor),
                  ),
                  const SizedBox(height: MnemonicsSpacing.s),
                ],
                
                // Stats row
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                    ),
                    const SizedBox(width: MnemonicsSpacing.xs),
                    Text(
                      lastActivity != null 
                          ? 'Updated ${_formatDate(lastActivity)}'
                          : 'No activity',
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
              if (userData.nextReview != null)
                Text('Next review: ${_formatDate(userData.nextReview!)}'),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
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

  IconData _getStageIcon(String stage) {
    switch (stage.toLowerCase()) {
      case 'new':
        return Icons.fiber_new;
      case 'learning':
        return Icons.psychology;
      case 'mastered':
        return Icons.star;
      default:
        return Icons.school;
    }
  }

  String _getStageDescription(String stage) {
    switch (stage.toLowerCase()) {
      case 'new':
        return 'Words you haven\'t started learning yet';
      case 'learning':
        return 'Words you\'re currently practicing';
      case 'mastered':
        return 'Words you\'ve successfully learned';
      default:
        return 'Your vocabulary words';
    }
  }

  String _getEmptyStateMessage(String stage) {
    switch (stage.toLowerCase()) {
      case 'new':
        return 'All words have been started! Great progress!';
      case 'learning':
        return 'No words in progress. Start learning some new words!';
      case 'mastered':
        return 'Keep practicing to master more words!';
      default:
        return 'Start learning to see words here!';
    }
  }
}