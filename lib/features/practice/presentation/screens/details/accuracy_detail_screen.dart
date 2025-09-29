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

class AccuracyDetailScreen extends ConsumerStatefulWidget {
  const AccuracyDetailScreen({super.key});

  @override
  ConsumerState<AccuracyDetailScreen> createState() => _AccuracyDetailScreenState();
}

class _AccuracyDetailScreenState extends ConsumerState<AccuracyDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;

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
        title: const Text('🎯 Accuracy Analytics'),
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
                  final analysisData = _calculateAccuracyAnalysis(allWords, userWordDataList);
                  
                  return AnimatedBuilder(
                    animation: _pageAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pageAnimation.value,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(MnemonicsSpacing.l),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Overall accuracy header
                              AnimatedProgressUtils.buildStaggeredAnimation(
                                animation: _pageAnimation,
                                index: 0,
                                child: _buildOverallAccuracyCard(statistics.averageAccuracy, isDarkMode),
                              ),
                              const SizedBox(height: MnemonicsSpacing.xl),
                              
                              // Accuracy breakdown by difficulty
                              AnimatedProgressUtils.buildStaggeredAnimation(
                                animation: _pageAnimation,
                                index: 1,
                                child: _buildAccuracyBreakdown('Accuracy by Difficulty', analysisData.difficultyAccuracy, isDarkMode),
                              ),
                              const SizedBox(height: MnemonicsSpacing.xl),
                              
                              // Accuracy breakdown by category
                              AnimatedProgressUtils.buildStaggeredAnimation(
                                animation: _pageAnimation,
                                index: 2,
                                child: _buildAccuracyBreakdown('Accuracy by Category', analysisData.categoryAccuracy, isDarkMode),
                              ),
                              const SizedBox(height: MnemonicsSpacing.xl),
                              
                              // Performance insights
                              AnimatedProgressUtils.buildStaggeredAnimation(
                                animation: _pageAnimation,
                                index: 3,
                                child: _buildPerformanceInsights(analysisData, isDarkMode),
                              ),
                              const SizedBox(height: MnemonicsSpacing.xl),
                              
                              // Most challenging words
                              AnimatedProgressUtils.buildStaggeredAnimation(
                                animation: _pageAnimation,
                                index: 4,
                                child: _buildChallengingWords(analysisData.challengingWords, isDarkMode),
                              ),
                              const SizedBox(height: MnemonicsSpacing.xl),
                              
                              // Best performing words
                              AnimatedProgressUtils.buildStaggeredAnimation(
                                animation: _pageAnimation,
                                index: 5,
                                child: _buildBestWords(analysisData.bestWords, isDarkMode),
                              ),
                              const SizedBox(height: MnemonicsSpacing.xl),
                              
                              // Tips for improvement
                              AnimatedProgressUtils.buildStaggeredAnimation(
                                animation: _pageAnimation,
                                index: 6,
                                child: _buildImprovementTips(analysisData, isDarkMode),
                              ),
                            ],
                          ),
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

  AccuracyAnalysisData _calculateAccuracyAnalysis(
    List<VocabularyWord> allWords,
    List<UserWordData> userWordDataList,
  ) {
    final difficultyAccuracy = <String, List<double>>{};
    final categoryAccuracy = <String, List<double>>{};
    final challengingWords = <({VocabularyWord word, UserWordData userData})>[];
    final bestWords = <({VocabularyWord word, UserWordData userData})>[];
    
    for (final userData in userWordDataList) {
      if (userData.totalAnswers > 0) {
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
          final accuracy = userData.accuracyRate;
          
          // Group by difficulty
          difficultyAccuracy.putIfAbsent(word.difficulty.name, () => []).add(accuracy);
          
          // Group by category
          categoryAccuracy.putIfAbsent(word.category, () => []).add(accuracy);
          
          // Track challenging words (accuracy < 60% and more than 3 attempts)
          if (accuracy < 0.6 && userData.totalAnswers >= 3) {
            challengingWords.add((word: word, userData: userData));
          }
          
          // Track best words (accuracy >= 90% and more than 3 attempts)
          if (accuracy >= 0.9 && userData.totalAnswers >= 3) {
            bestWords.add((word: word, userData: userData));
          }
        }
      }
    }
    
    // Calculate average accuracies
    final difficultyAverage = <String, double>{};
    for (final entry in difficultyAccuracy.entries) {
      difficultyAverage[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
    }
    
    final categoryAverage = <String, double>{};
    for (final entry in categoryAccuracy.entries) {
      categoryAverage[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
    }
    
    // Sort challenging and best words
    challengingWords.sort((a, b) => a.userData.accuracyRate.compareTo(b.userData.accuracyRate));
    bestWords.sort((a, b) => b.userData.accuracyRate.compareTo(a.userData.accuracyRate));
    
    return AccuracyAnalysisData(
      difficultyAccuracy: difficultyAverage,
      categoryAccuracy: categoryAverage,
      challengingWords: challengingWords.take(10).toList(),
      bestWords: bestWords.take(10).toList(),
    );
  }

  Widget _buildOverallAccuracyCard(double overallAccuracy, bool isDarkMode) {
    final accuracyColor = _getAccuracyColor(overallAccuracy);
    final percentage = (overallAccuracy * 100).round();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accuracyColor.withOpacity(0.1),
            accuracyColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        border: Border.all(
          color: accuracyColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: Column(
        children: [
          // Target icon
          Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            decoration: BoxDecoration(
              color: accuracyColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 48,
              color: accuracyColor,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          
          // Accuracy percentage
          AnimatedProgressUtils.buildCountUpAnimation(
            animation: _pageAnimation,
            targetValue: percentage,
            suffix: '%',
            style: MnemonicsTypography.headingLarge.copyWith(
              color: accuracyColor,
              fontWeight: FontWeight.bold,
              fontSize: 42,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          
          Text(
            'Overall Accuracy',
            style: MnemonicsTypography.headingMedium.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          
          Text(
            _getAccuracyMessage(overallAccuracy),
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyBreakdown(String title, Map<String, double> data, bool isDarkMode) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(MnemonicsSpacing.l),
        decoration: BoxDecoration(
          color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: MnemonicsTypography.headingMedium.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            Text(
              'No data available yet',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.l),
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
          ),
          child: Column(
            children: data.entries.map((entry) {
              final accuracy = entry.value;
              final percentage = (accuracy * 100).round();
              final color = _getAccuracyColor(accuracy);
              
              return Container(
                margin: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: MnemonicsSpacing.m),
                    
                    Expanded(
                      child: Text(
                        entry.key[0].toUpperCase() + entry.key.substring(1),
                        style: MnemonicsTypography.bodyLarge.copyWith(
                          color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    Text(
                      '$percentage%',
                      style: MnemonicsTypography.bodyLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: MnemonicsSpacing.m),
                    
                    // Progress bar
                    Container(
                      width: 80,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: accuracy.clamp(0.0, 1.0),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceInsights(AccuracyAnalysisData data, bool isDarkMode) {
    final strongestDifficulty = data.difficultyAccuracy.entries.isEmpty ? null :
        data.difficultyAccuracy.entries.reduce((a, b) => a.value > b.value ? a : b);
    final weakestDifficulty = data.difficultyAccuracy.entries.isEmpty ? null :
        data.difficultyAccuracy.entries.reduce((a, b) => a.value < b.value ? a : b);
    
    final strongestCategory = data.categoryAccuracy.entries.isEmpty ? null :
        data.categoryAccuracy.entries.reduce((a, b) => a.value > b.value ? a : b);
    final weakestCategory = data.categoryAccuracy.entries.isEmpty ? null :
        data.categoryAccuracy.entries.reduce((a, b) => a.value < b.value ? a : b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Insights',
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        Row(
          children: [
            if (strongestDifficulty != null)
              Expanded(
                child: _buildInsightCard(
                  'Strongest Level',
                  strongestDifficulty.key[0].toUpperCase() + strongestDifficulty.key.substring(1),
                  '${(strongestDifficulty.value * 100).round()}%',
                  Icons.sentiment_very_satisfied,
                  Colors.green,
                  isDarkMode,
                ),
              ),
            if (strongestDifficulty != null && weakestDifficulty != null)
              const SizedBox(width: MnemonicsSpacing.m),
            if (weakestDifficulty != null)
              Expanded(
                child: _buildInsightCard(
                  'Needs Practice',
                  weakestDifficulty.key[0].toUpperCase() + weakestDifficulty.key.substring(1),
                  '${(weakestDifficulty.value * 100).round()}%',
                  Icons.sentiment_dissatisfied,
                  Colors.orange,
                  isDarkMode,
                ),
              ),
          ],
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        Row(
          children: [
            if (strongestCategory != null)
              Expanded(
                child: _buildInsightCard(
                  'Best Category',
                  strongestCategory.key[0].toUpperCase() + strongestCategory.key.substring(1),
                  '${(strongestCategory.value * 100).round()}%',
                  Icons.star,
                  Colors.amber,
                  isDarkMode,
                ),
              ),
            if (strongestCategory != null && weakestCategory != null)
              const SizedBox(width: MnemonicsSpacing.m),
            if (weakestCategory != null)
              Expanded(
                child: _buildInsightCard(
                  'Focus Area',
                  weakestCategory.key[0].toUpperCase() + weakestCategory.key.substring(1),
                  '${(weakestCategory.value * 100).round()}%',
                  Icons.trending_down,
                  Colors.red,
                  isDarkMode,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(String label, String title, String subtitle, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: MnemonicsSpacing.s),
          Text(
            title,
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.xs),
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

  Widget _buildChallengingWords(List<({VocabularyWord word, UserWordData userData})> words, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Challenging Words',
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        if (words.isEmpty)
          Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            decoration: BoxDecoration(
              color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
            ),
            child: Text(
              'Great job! No challenging words found.',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
            ),
          )
        else
          ...words.take(5).map((item) => _buildWordAccuracyCard(item.word, item.userData, isDarkMode)),
      ],
    );
  }

  Widget _buildBestWords(List<({VocabularyWord word, UserWordData userData})> words, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Best Performing Words',
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        if (words.isEmpty)
          Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            decoration: BoxDecoration(
              color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
            ),
            child: Text(
              'Keep practicing to see your best words here!',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              ),
            ),
          )
        else
          ...words.take(5).map((item) => _buildWordAccuracyCard(item.word, item.userData, isDarkMode)),
      ],
    );
  }

  Widget _buildWordAccuracyCard(VocabularyWord word, UserWordData userData, bool isDarkMode) {
    final accuracy = userData.accuracyRate;
    final accuracyColor = _getAccuracyColor(accuracy);
    
    return Container(
      margin: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
        border: Border.all(
          color: accuracyColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  word.meaning,
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(accuracy * 100).round()}%',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: accuracyColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${userData.totalAnswers} attempts',
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
  }

  Widget _buildImprovementTips(AccuracyAnalysisData data, bool isDarkMode) {
    final tips = _getImprovementTips(data);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips for Improvement',
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.l),
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
          ),
          child: Column(
            children: tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: MnemonicsColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: MnemonicsSpacing.s),
                  Expanded(
                    child: Text(
                      tip,
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  List<String> _getImprovementTips(AccuracyAnalysisData data) {
    final tips = <String>[];
    
    if (data.challengingWords.isNotEmpty) {
      tips.add('Focus on reviewing challenging words more frequently');
      tips.add('Try creating personal mnemonics for difficult words');
    }
    
    if (data.difficultyAccuracy.isNotEmpty) {
      final weakestDifficulty = data.difficultyAccuracy.entries.reduce((a, b) => a.value < b.value ? a : b);
      if (weakestDifficulty.value < 0.7) {
        tips.add('Spend extra time on ${weakestDifficulty.key} difficulty words');
      }
    }
    
    tips.addAll([
      'Practice consistently for better retention',
      'Use the spaced repetition system to optimize learning',
      'Take breaks between study sessions for better performance',
      'Review incorrect answers to understand patterns',
    ]);
    
    return tips.take(5).toList();
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getAccuracyMessage(double accuracy) {
    if (accuracy >= 0.9) return 'Excellent! You\'re mastering your vocabulary!';
    if (accuracy >= 0.8) return 'Great job! Keep up the good work!';
    if (accuracy >= 0.7) return 'Good progress! Room for improvement.';
    if (accuracy >= 0.6) return 'Making progress! Focus on review.';
    return 'Keep practicing! Every attempt helps you learn.';
  }
}

class AccuracyAnalysisData {
  final Map<String, double> difficultyAccuracy;
  final Map<String, double> categoryAccuracy;
  final List<({VocabularyWord word, UserWordData userData})> challengingWords;
  final List<({VocabularyWord word, UserWordData userData})> bestWords;

  AccuracyAnalysisData({
    required this.difficultyAccuracy,
    required this.categoryAccuracy,
    required this.challengingWords,
    required this.bestWords,
  });
}