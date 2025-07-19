import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../../domain/profile_statistics.dart';

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
                  'Words Learned',
                  profileStats.wordsLearnedThisWeek.toString(),
                  Icons.add_circle_outline,
                  MnemonicsColors.primaryGreen,
                  textColor,
                  secondaryTextColor,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Study Sessions',
                  profileStats.studySessionsThisWeek.toString(),
                  Icons.play_circle_outline,
                  MnemonicsColors.secondaryOrange,
                  textColor,
                  secondaryTextColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: MnemonicsSpacing.m),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Learning Pace',
                  '${profileStats.learningVelocity.toStringAsFixed(1)} words/week',
                  Icons.trending_up,
                  _getTrendColor(profileStats.learningVelocity),
                  textColor,
                  secondaryTextColor,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  'Longest Streak',
                  '${profileStats.longestStreak} days',
                  Icons.emoji_events,
                  Colors.amber,
                  textColor,
                  secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.s),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
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
              Text(
                label,
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
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
    );
  }

  Color _getTrendColor(double velocity) {
    if (velocity >= 10) return Colors.green;
    if (velocity >= 5) return MnemonicsColors.primaryGreen;
    if (velocity >= 2) return MnemonicsColors.secondaryOrange;
    return Colors.red;
  }
}