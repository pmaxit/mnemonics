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

class BreakdownDetailScreen extends ConsumerStatefulWidget {
  final String breakdownType; // 'category' or 'difficulty'
  final String? filterValue; // specific category or difficulty to filter by
  
  const BreakdownDetailScreen({
    super.key,
    required this.breakdownType,
    this.filterValue,
  });

  @override
  ConsumerState<BreakdownDetailScreen> createState() => _BreakdownDetailScreenState();
}

class _BreakdownDetailScreenState extends ConsumerState<BreakdownDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  String _searchQuery = '';
  String _sortBy = 'Frequency'; // Frequency, Alphabetical, Count

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

  String get _screenTitle {
    if (widget.filterValue != null) {
      return '${widget.filterValue![0].toUpperCase()}${widget.filterValue!.substring(1)} Words';
    }
    return widget.breakdownType == 'category' 
        ? '📚 Categories Overview'
        : '⚡ Difficulty Levels';
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
        title: Text(_screenTitle),
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
              const PopupMenuItem(value: 'Frequency', child: Text('By Frequency')),
              const PopupMenuItem(value: 'Alphabetical', child: Text('Alphabetical')),
              const PopupMenuItem(value: 'Count', child: Text('By Word Count')),
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
                  final breakdownData = _calculateBreakdownData(allWords, userWordDataList);
                  
                  return AnimatedBuilder(
                    animation: _pageAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pageAnimation.value,
                        child: widget.filterValue != null
                            ? _buildFilteredView(breakdownData, isDarkMode)
                            : _buildOverviewScreen(breakdownData, isDarkMode),
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

  BreakdownData _calculateBreakdownData(
    List<VocabularyWord> allWords,
    List<UserWordData> userWordDataList,
  ) {
    final learnedWords = <({VocabularyWord word, UserWordData userData})>[];
    
    // Get all learned words
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
    
    // Calculate breakdown statistics
    final breakdown = <String, BreakdownCategory>{};
    
    for (final item in learnedWords) {
      final key = widget.breakdownType == 'category' 
          ? item.word.category
          : item.word.difficulty;
      
      if (!breakdown.containsKey(key)) {
        breakdown[key] = BreakdownCategory(
          name: key,
          words: [],
          totalCount: 0,
          averageAccuracy: 0.0,
          masteredCount: 0,
          learningCount: 0,
          newCount: 0,
        );
      }
      
      breakdown[key]!.words.add(item);
      breakdown[key]!.totalCount++;
      
      switch (item.userData.learningStage) {
        case 'mastered':
          breakdown[key]!.masteredCount++;
          break;
        case 'learning':
          breakdown[key]!.learningCount++;
          break;
        case 'new':
          breakdown[key]!.newCount++;
          break;
      }
    }
    
    // Calculate average accuracies
    for (final category in breakdown.values) {
      if (category.words.isNotEmpty) {
        category.averageAccuracy = category.words
            .map((item) => item.userData.accuracyRate)
            .reduce((a, b) => a + b) / category.words.length;
      }
    }
    
    return BreakdownData(categories: breakdown);
  }

  Widget _buildOverviewScreen(BreakdownData data, bool isDarkMode) {
    final sortedCategories = _sortCategories(data.categories.values.toList());
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary header
          AnimatedProgressUtils.buildStaggeredAnimation(
            animation: _pageAnimation,
            index: 0,
            child: _buildSummaryHeader(sortedCategories, isDarkMode),
          ),
          const SizedBox(height: MnemonicsSpacing.xl),
          
          // Search bar
          AnimatedProgressUtils.buildStaggeredAnimation(
            animation: _pageAnimation,
            index: 1,
            child: _buildSearchBar(isDarkMode),
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          
          // Categories list
          AnimatedProgressUtils.buildStaggeredAnimation(
            animation: _pageAnimation,
            index: 2,
            child: _buildCategoriesList(sortedCategories, isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredView(BreakdownData data, bool isDarkMode) {
    final category = data.categories[widget.filterValue];
    if (category == null) {
      return const Center(child: Text('No data found for this category'));
    }
    
    final filteredWords = category.words.where((item) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return item.word.word.toLowerCase().contains(query) ||
            item.word.meaning.toLowerCase().contains(query) ||
            item.word.mnemonic.toLowerCase().contains(query);
      }
      return true;
    }).toList();
    
    return Column(
      children: [
        // Category summary
        AnimatedProgressUtils.buildStaggeredAnimation(
          animation: _pageAnimation,
          index: 0,
          child: _buildCategorySummary(category, isDarkMode),
        ),
        
        // Search bar
        AnimatedProgressUtils.buildStaggeredAnimation(
          animation: _pageAnimation,
          index: 1,
          child: Container(
            margin: const EdgeInsets.all(MnemonicsSpacing.l),
            child: _buildSearchBar(isDarkMode),
          ),
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
    );
  }

  Widget _buildSummaryHeader(List<BreakdownCategory> categories, bool isDarkMode) {
    final totalWords = categories.fold(0, (sum, cat) => sum + cat.totalCount);
    final averageAccuracy = categories.isEmpty ? 0.0 :
        categories.map((cat) => cat.averageAccuracy).reduce((a, b) => a + b) / categories.length;
    
    return Container(
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
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total ${widget.breakdownType == 'category' ? 'Categories' : 'Levels'}',
                  categories.length.toString(),
                  widget.breakdownType == 'category' ? Icons.category : Icons.speed,
                  MnemonicsColors.primaryGreen,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: _buildSummaryCard(
                  'Total Words',
                  totalWords.toString(),
                  Icons.school,
                  MnemonicsColors.secondaryOrange,
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
                  'Most Popular',
                  _getMostPopular(categories),
                  Icons.trending_up,
                  Colors.purple,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMostPopular(List<BreakdownCategory> categories) {
    if (categories.isEmpty) return 'None';
    final mostPopular = categories.reduce((a, b) => a.totalCount > b.totalCount ? a : b);
    return '${mostPopular.name[0].toUpperCase()}${mostPopular.name.substring(1)}';
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

  Widget _buildSearchBar(bool isDarkMode) {
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
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: widget.filterValue != null 
              ? 'Search words in this ${widget.breakdownType}...'
              : 'Search ${widget.breakdownType}s...',
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
    );
  }

  Widget _buildCategoriesList(List<BreakdownCategory> categories, bool isDarkMode) {
    final filteredCategories = categories.where((category) {
      if (_searchQuery.isNotEmpty) {
        return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
    
    if (filteredCategories.isEmpty) {
      return Center(
        child: Text(
          'No ${widget.breakdownType}s found',
          style: MnemonicsTypography.bodyLarge.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
          ),
        ),
      );
    }
    
    return Column(
      children: filteredCategories.map((category) {
        return Container(
          margin: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
          child: _buildCategoryCard(category, isDarkMode),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(BreakdownCategory category, bool isDarkMode) {
    final categoryColor = _getCategoryColor(category.name);
    
    return Container(
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
            // Navigate to filtered view
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BreakdownDetailScreen(
                  breakdownType: widget.breakdownType,
                  filterValue: category.name,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(MnemonicsSpacing.s),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                      ),
                      child: Icon(
                        _getCategoryIcon(category.name),
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: MnemonicsSpacing.m),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${category.name[0].toUpperCase()}${category.name.substring(1)}',
                            style: MnemonicsTypography.headingMedium.copyWith(
                              color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${category.totalCount} words • ${(category.averageAccuracy * 100).round()}% accuracy',
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: MnemonicsSpacing.m),
                
                // Progress breakdown
                Row(
                  children: [
                    _buildProgressChip('Mastered', category.masteredCount, Colors.amber, isDarkMode),
                    const SizedBox(width: MnemonicsSpacing.s),
                    _buildProgressChip('Learning', category.learningCount, Colors.orange, isDarkMode),
                    const SizedBox(width: MnemonicsSpacing.s),
                    _buildProgressChip('New', category.newCount, Colors.blue, isDarkMode),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressChip(String label, int count, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MnemonicsSpacing.s,
        vertical: MnemonicsSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
      ),
      child: Text(
        '$count $label',
        style: MnemonicsTypography.bodyRegular.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCategorySummary(BreakdownCategory category, bool isDarkMode) {
    final categoryColor = _getCategoryColor(category.name);
    
    return Container(
      margin: const EdgeInsets.all(MnemonicsSpacing.l),
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withOpacity(0.1),
            categoryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(category.name),
              size: 32,
              color: categoryColor,
            ),
          ),
          const SizedBox(width: MnemonicsSpacing.l),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${category.name[0].toUpperCase()}${category.name.substring(1)}',
                  style: MnemonicsTypography.headingLarge.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${category.totalCount} words • ${(category.averageAccuracy * 100).round()}% accuracy',
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                  ),
                ),
              ],
            ),
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
      return const Center(child: Text('No words found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final item = words[index];
        return Container(
          margin: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
          padding: const EdgeInsets.all(MnemonicsSpacing.l),
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.word.word,
                style: MnemonicsTypography.headingMedium.copyWith(
                  color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.xs),
              Text(
                item.word.meaning,
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.s),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MnemonicsSpacing.s,
                      vertical: MnemonicsSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getStageColor(item.userData.learningStage).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
                    ),
                    child: Text(
                      item.userData.learningStage.toUpperCase(),
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: _getStageColor(item.userData.learningStage),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(item.userData.accuracyRate * 100).round()}% accuracy',
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<BreakdownCategory> _sortCategories(List<BreakdownCategory> categories) {
    switch (_sortBy) {
      case 'Alphabetical':
        categories.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Count':
        categories.sort((a, b) => b.totalCount.compareTo(a.totalCount));
        break;
      case 'Frequency':
      default:
        categories.sort((a, b) => b.totalCount.compareTo(a.totalCount));
        break;
    }
    return categories;
  }

  Color _getCategoryColor(String category) {
    final colors = [
      MnemonicsColors.primaryGreen,
      MnemonicsColors.secondaryOrange,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.amber,
      Colors.cyan,
      Colors.pink,
    ];
    return colors[category.hashCode % colors.length];
  }

  IconData _getCategoryIcon(String category) {
    if (widget.breakdownType == 'difficulty') {
      switch (category.toLowerCase()) {
        case 'easy':
          return Icons.sentiment_very_satisfied;
        case 'medium':
          return Icons.sentiment_neutral;
        case 'hard':
          return Icons.sentiment_very_dissatisfied;
        default:
          return Icons.speed;
      }
    } else {
      // Category icons
      switch (category.toLowerCase()) {
        case 'academic':
          return Icons.school;
        case 'common':
          return Icons.public;
        case 'business':
          return Icons.business;
        case 'science':
          return Icons.science;
        case 'arts':
          return Icons.palette;
        default:
          return Icons.category;
      }
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

class BreakdownData {
  final Map<String, BreakdownCategory> categories;

  BreakdownData({required this.categories});
}

class BreakdownCategory {
  final String name;
  final List<({VocabularyWord word, UserWordData userData})> words;
  int totalCount;
  double averageAccuracy;
  int masteredCount;
  int learningCount;
  int newCount;

  BreakdownCategory({
    required this.name,
    required this.words,
    required this.totalCount,
    required this.averageAccuracy,
    required this.masteredCount,
    required this.learningCount,
    required this.newCount,
  });
}