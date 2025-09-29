import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../../domain/user_statistics.dart';

class DifficultyStatsWidget extends StatelessWidget {
  final Map<WordDifficulty, DifficultyProgress> difficultyStats;
  final bool isDarkMode;

  const DifficultyStatsWidget({
    super.key,
    required this.difficultyStats,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(MnemonicsSpacing.m),
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : MnemonicsColors.background,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complexity Breakdown',
            style: MnemonicsTypography.headingMedium.copyWith(
              color: isDarkMode ? Colors.white : MnemonicsColors.textPrimary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Text(
            'Track your progress across different complexity levels',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          ...WordDifficulty.values.map((difficulty) {
            final stats = difficultyStats[difficulty];
            if (stats == null) return const SizedBox.shrink();
            
            return _buildDifficultyCard(difficulty, stats);
          }),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(WordDifficulty difficulty, DifficultyProgress stats) {
    final progressPercentage = stats.totalWords > 0 
        ? (stats.wordsLearned / stats.totalWords) 
        : 0.0;
    
    Color difficultyColor;
    Color progressColor;
    
    switch (difficulty) {
      case WordDifficulty.basic:
        difficultyColor = Colors.green;
        progressColor = Colors.green.shade300;
        break;
      case WordDifficulty.intermediate:
        difficultyColor = Colors.orange;
        progressColor = Colors.orange.shade300;
        break;
      case WordDifficulty.advanced:
        difficultyColor = Colors.red;
        progressColor = Colors.red.shade300;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        border: Border.all(
          color: difficultyColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MnemonicsSpacing.s,
                  vertical: MnemonicsSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      difficulty.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: MnemonicsSpacing.xs),
                    Text(
                      difficulty.displayName,
                      style: MnemonicsTypography.bodyLarge.copyWith(
                        color: difficultyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${stats.wordsLearned}/${stats.totalWords}',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: isDarkMode ? Colors.white : MnemonicsColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: isDarkMode 
                  ? Colors.grey.shade700 
                  : Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          
          // Statistics Row
          Row(
            children: [
              _buildStatItem(
                'Learned',
                stats.wordsLearned.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              _buildStatItem(
                'Learning',
                stats.wordsInProgress.toString(),
                Icons.school_outlined,
                Colors.blue,
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              _buildStatItem(
                'Accuracy',
                '${(stats.averageAccuracy * 100).round()}%',
                Icons.my_location,
                difficultyColor,
              ),
            ],
          ),
          
          if (stats.totalReviews > 0) ...[
            const SizedBox(height: MnemonicsSpacing.s),
            Row(
              children: [
                _buildStatItem(
                  'Reviews',
                  stats.totalReviews.toString(),
                  Icons.refresh,
                  Colors.purple,
                ),
                if (stats.lastReviewedAt != null) ...[
                  const SizedBox(width: MnemonicsSpacing.m),
                  _buildStatItem(
                    'Last Review',
                    _formatLastReview(stats.lastReviewedAt!),
                    Icons.schedule,
                    Colors.grey,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: MnemonicsSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    color: isDarkMode ? Colors.white : MnemonicsColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    fontSize: 12,
                    color: isDarkMode 
                        ? MnemonicsColors.darkTextSecondary 
                        : MnemonicsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastReview(DateTime lastReview) {
    final now = DateTime.now();
    final difference = now.difference(lastReview);
    
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
}