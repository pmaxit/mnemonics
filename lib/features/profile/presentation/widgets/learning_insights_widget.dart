import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../../domain/profile_statistics.dart';
import '../screens/detailed_word_statistics_screen.dart';
import '../screens/category_detail_screen.dart';

class LearningInsightsWidget extends StatelessWidget {
  final ProfileStatistics profileStats;
  final bool isDarkMode;

  const LearningInsightsWidget({
    super.key,
    required this.profileStats,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode 
        ? MnemonicsColors.darkSurface 
        : Colors.white;
    final textColor = isDarkMode 
        ? MnemonicsColors.darkTextPrimary 
        : MnemonicsColors.textPrimary;
    final secondaryTextColor = isDarkMode 
        ? MnemonicsColors.darkTextSecondary 
        : MnemonicsColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: MnemonicsSpacing.m,
        vertical: MnemonicsSpacing.s,
      ),
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode 
            ? MnemonicsColors.darkCardShadow 
            : MnemonicsColors.cardShadow,
        border: isDarkMode 
            ? Border.all(
                color: MnemonicsColors.darkBorder.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Insights',
            style: MnemonicsTypography.headingMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          
          // Category Performance
          _buildCategoryInsights(context, textColor, secondaryTextColor),
          
          const SizedBox(height: MnemonicsSpacing.m),
          
          // Difficulty Analysis
          _buildDifficultyInsights(context, textColor, secondaryTextColor),
          
          const SizedBox(height: MnemonicsSpacing.m),
          
          // Recommendations
          _buildRecommendations(textColor, secondaryTextColor),
        ],
      ),
    );
  }

  Widget _buildCategoryInsights(BuildContext context, Color textColor, Color secondaryTextColor) {
    if (profileStats.categoryStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(MnemonicsSpacing.m),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        ),
        child: Center(
          child: Text(
            'Start learning to see category insights',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: secondaryTextColor,
            ),
          ),
        ),
      );
    }

    final topCategories = profileStats.categoryStats
        .where((c) => c.wordsLearned > 0)
        .toList()
      ..sort((a, b) => b.wordsLearned.compareTo(a.wordsLearned));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Progress',
          style: MnemonicsTypography.bodyLarge.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        ...topCategories.take(3).map((category) => 
          _buildCategoryProgressBar(context, category, textColor, secondaryTextColor)
        ),
      ],
    );
  }

  Widget _buildCategoryProgressBar(
    BuildContext context,
    CategoryStats category,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final progress = category.totalWords > 0 
        ? category.wordsLearned / category.totalWords 
        : 0.0;
    final progressClamped = progress.clamp(0.0, 1.0);

    return InkWell(
      onTap: () => _navigateToCategory(context, category.categoryName),
      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      child: Container(
        margin: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
        padding: const EdgeInsets.all(MnemonicsSpacing.s),
        decoration: BoxDecoration(
          color: _getCategoryColor(category.categoryName).withOpacity(0.05),
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          border: Border.all(
            color: _getCategoryColor(category.categoryName).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatCategoryName(category.categoryName),
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${category.wordsLearned}/${category.totalWords}',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: MnemonicsSpacing.s),
                Text(
                  '${(category.averageAccuracy * 100).toStringAsFixed(0)}%',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: _getAccuracyColor(category.averageAccuracy),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: MnemonicsSpacing.xs),
                Icon(
                  Icons.arrow_forward_ios,
                  color: _getCategoryColor(category.categoryName).withOpacity(0.5),
                  size: 12,
                ),
              ],
            ),
            const SizedBox(height: MnemonicsSpacing.xs),
            LinearProgressIndicator(
              value: progressClamped,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getCategoryColor(category.categoryName),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyInsights(BuildContext context, Color textColor, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty Performance',
          style: MnemonicsTypography.bodyLarge.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        Row(
          children: profileStats.difficultyStats.map((difficulty) => 
            Expanded(
              child: _buildDifficultyCard(
                context,
                difficulty,
                textColor,
                secondaryTextColor,
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context,
    DifficultyStats difficulty,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final difficultyColor = _getDifficultyColor(difficulty.difficulty);
    final progress = difficulty.totalWords > 0 
        ? difficulty.wordsLearned / difficulty.totalWords 
        : 0.0;

    return InkWell(
      onTap: () => _navigateToDifficulty(context, difficulty.difficulty),
      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      child: Container(
        margin: const EdgeInsets.only(right: MnemonicsSpacing.s),
        padding: const EdgeInsets.all(MnemonicsSpacing.s),
        decoration: BoxDecoration(
          color: difficultyColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          border: Border.all(
            color: difficultyColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDifficultyName(difficulty.difficulty),
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: difficultyColor.withOpacity(0.5),
                  size: 10,
                ),
              ],
            ),
            const SizedBox(height: MnemonicsSpacing.xs),
            Text(
              '${difficulty.wordsLearned}/${difficulty.totalWords}',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: secondaryTextColor,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.xs),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(difficultyColor),
            ),
            const SizedBox(height: MnemonicsSpacing.xs),
            Text(
              '${(difficulty.averageAccuracy * 100).toStringAsFixed(0)}%',
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: difficultyColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(Color textColor, Color secondaryTextColor) {
    final recommendations = _generateRecommendations();
    
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: MnemonicsTypography.bodyLarge.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        ...recommendations.map((rec) => 
          Container(
            margin: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
            padding: const EdgeInsets.all(MnemonicsSpacing.s),
            decoration: BoxDecoration(
              color: MnemonicsColors.secondaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            ),
            child: Row(
              children: [
                Icon(
                  rec.icon,
                  color: MnemonicsColors.secondaryOrange,
                  size: 20,
                ),
                const SizedBox(width: MnemonicsSpacing.s),
                Expanded(
                  child: Text(
                    rec.message,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Recommendation> _generateRecommendations() {
    final recommendations = <Recommendation>[];

    // Streak recommendation
    if (profileStats.currentStreak == 0) {
      recommendations.add(Recommendation(
        icon: Icons.whatshot,
        message: 'Start building your learning streak by studying today!',
      ));
    } else if (profileStats.currentStreak < 7) {
      recommendations.add(Recommendation(
        icon: Icons.whatshot,
        message: 'Keep going! You\'re ${7 - profileStats.currentStreak} days away from a week streak.',
      ));
    }

    // Accuracy recommendation
    if (profileStats.averageAccuracy < 0.8) {
      recommendations.add(Recommendation(
        icon: Icons.track_changes,
        message: 'Focus on reviewing difficult words to improve accuracy.',
      ));
    }

    // Category recommendation
    final weakestCategory = profileStats.categoryStats
        .where((c) => c.wordsLearned > 0)
        .fold<CategoryStats?>(null, (weakest, category) {
      if (weakest == null || category.averageAccuracy < weakest.averageAccuracy) {
        return category;
      }
      return weakest;
    });

    if (weakestCategory != null && weakestCategory.averageAccuracy < 0.75) {
      recommendations.add(Recommendation(
        icon: Icons.trending_up,
        message: 'Practice more ${_formatCategoryName(weakestCategory.categoryName)} words.',
      ));
    }

    return recommendations;
  }

  String _formatCategoryName(String category) {
    return category.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatDifficultyName(String difficulty) {
    return difficulty[0].toUpperCase() + difficulty.substring(1);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return Colors.blue;
      case 'technology':
        return Colors.purple;
      case 'science':
        return Colors.green;
      case 'arts':
        return Colors.pink;
      case 'general':
        return MnemonicsColors.primaryGreen;
      default:
        return MnemonicsColors.secondaryOrange;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return MnemonicsColors.secondaryOrange;
      case 'hard':
        return Colors.red;
      default:
        return MnemonicsColors.primaryGreen;
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.9) return Colors.green;
    if (accuracy >= 0.8) return MnemonicsColors.primaryGreen;
    if (accuracy >= 0.7) return MnemonicsColors.secondaryOrange;
    return Colors.red;
  }

  void _navigateToCategory(BuildContext context, String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(category: category),
      ),
    );
  }

  void _navigateToDifficulty(BuildContext context, String difficulty) {
    WordStatType statType;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        statType = WordStatType.easy;
        break;
      case 'medium':
        statType = WordStatType.medium;
        break;
      case 'hard':
        statType = WordStatType.hard;
        break;
      default:
        statType = WordStatType.allWords;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailedWordStatisticsScreen(statType: statType),
      ),
    );
  }
}

class Recommendation {
  final IconData icon;
  final String message;

  Recommendation({
    required this.icon,
    required this.message,
  });
}