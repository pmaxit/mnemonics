import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../../domain/profile_statistics.dart';
import '../screens/detailed_word_statistics_screen.dart';

class StatisticsOverviewWidget extends StatelessWidget {
  final ProfileStatistics profileStats;
  final bool isDarkMode;

  const StatisticsOverviewWidget({
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
            'This Week',
            style: MnemonicsTypography.headingMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  context,
                  'Words Learned',
                  profileStats.wordsLearnedThisWeek.toString(),
                  Icons.add_circle_outline,
                  MnemonicsColors.primaryGreen,
                  textColor,
                  secondaryTextColor,
                  () => _navigateToWordsLearned(context),
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  context,
                  'Study Sessions',
                  profileStats.studySessionsThisWeek.toString(),
                  Icons.play_circle_outline,
                  MnemonicsColors.secondaryOrange,
                  textColor,
                  secondaryTextColor,
                  () => _navigateToStudySessions(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: MnemonicsSpacing.m),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  context,
                  'Learning Pace',
                  '${profileStats.learningVelocity.toStringAsFixed(1)} words/week',
                  Icons.trending_up,
                  _getTrendColor(profileStats.learningVelocity),
                  textColor,
                  secondaryTextColor,
                  () => _navigateToLearningPace(context),
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  context,
                  'Longest Streak',
                  '${profileStats.longestStreak} days',
                  Icons.emoji_events,
                  Colors.amber,
                  textColor,
                  secondaryTextColor,
                  () => _navigateToStreakHistory(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textColor,
    Color secondaryTextColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      child: Container(
        padding: const EdgeInsets.all(MnemonicsSpacing.s),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          border: Border.all(
            color: iconColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(width: MnemonicsSpacing.xs),
                Expanded(
                  child: Text(
                    label,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: iconColor.withOpacity(0.5),
                  size: 12,
                ),
              ],
            ),
            const SizedBox(height: MnemonicsSpacing.xs),
            Text(
              value,
              style: MnemonicsTypography.headingMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor(double velocity) {
    if (velocity >= 10) return Colors.green;
    if (velocity >= 5) return MnemonicsColors.primaryGreen;
    if (velocity >= 2) return MnemonicsColors.secondaryOrange;
    return Colors.red;
  }

  void _navigateToWordsLearned(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DetailedWordStatisticsScreen(
          statType: WordStatType.learned,
        ),
      ),
    );
  }

  void _navigateToStudySessions(BuildContext context) {
    // Show a dialog with study session details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Study Sessions This Week'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total sessions: ${profileStats.studySessionsThisWeek}'),
            const SizedBox(height: MnemonicsSpacing.s),
            Text('Total study time: ${(profileStats.totalStudyTimeMinutes / 60).toStringAsFixed(1)} hours'),
            const SizedBox(height: MnemonicsSpacing.s),
            const Text('Session history and detailed analytics coming soon!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToLearningPace(BuildContext context) {
    // Show learning pace analytics
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Learning Pace Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current pace: ${profileStats.learningVelocity.toStringAsFixed(1)} words/week'),
            const SizedBox(height: MnemonicsSpacing.s),
            Text('Words learned today: ${profileStats.wordsLearnedToday}'),
            const SizedBox(height: MnemonicsSpacing.s),
            Text('Words learned this week: ${profileStats.wordsLearnedThisWeek}'),
            const SizedBox(height: MnemonicsSpacing.s),
            const Text('Detailed trend analysis coming soon!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToStreakHistory(BuildContext context) {
    // Show streak analytics
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Streak History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current streak: ${profileStats.currentStreak} days'),
            const SizedBox(height: MnemonicsSpacing.s),
            Text('Longest streak: ${profileStats.longestStreak} days'),
            const SizedBox(height: MnemonicsSpacing.s),
            const Text('Detailed streak calendar coming soon!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}