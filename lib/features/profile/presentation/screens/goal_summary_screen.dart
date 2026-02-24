import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../domain/user_statistics.dart';
import '../../providers/unified_statistics_provider.dart';

class GoalSummaryScreen extends ConsumerWidget {
  final Milestone milestone;

  const GoalSummaryScreen({
    super.key,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final statsAsync = ref.watch(unifiedStatisticsProvider);

    final backgroundColor =
        isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.background;
    final surfaceColor =
        isDarkMode ? MnemonicsColors.darkSurface : Colors.white;
    final textColor = isDarkMode
        ? MnemonicsColors.darkTextPrimary
        : MnemonicsColors.textPrimary;
    final secondaryTextColor = isDarkMode
        ? MnemonicsColors.darkTextSecondary
        : MnemonicsColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          milestone.title,
          style: MnemonicsTypography.headingMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Unable to load stats',
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: secondaryTextColor,
            ),
          ),
        ),
        data: (stats) {
          final progress = milestone.targetValue > 0
              ? (milestone.currentValue / milestone.targetValue).clamp(0.0, 1.0)
              : 0.0;
          final progressColor = milestone.type == MilestoneType.consistency
              ? Colors.orange
              : MnemonicsColors.primaryGreen;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(MnemonicsSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGoalCard(
                  milestone: milestone,
                  progress: progress,
                  progressColor: progressColor,
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
                const SizedBox(height: MnemonicsSpacing.l),
                _buildTypeSpecificContent(
                  context: context,
                  milestone: milestone,
                  stats: stats,
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalCard({
    required Milestone milestone,
    required double progress,
    required Color progressColor,
    required bool isDarkMode,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final surfaceColor =
        isDarkMode ? MnemonicsColors.darkSurface : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: surfaceColor,
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
          Row(
            children: [
              Text(
                milestone.type.icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: MnemonicsTypography.headingMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: MnemonicsSpacing.xs),
                    Text(
                      milestone.description,
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${milestone.currentValue} / ${milestone.targetValue}',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (milestone.isUnlocked)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: MnemonicsColors.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: MnemonicsSpacing.xs),
                    Text(
                      'Completed',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: MnemonicsColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificContent({
    required BuildContext context,
    required Milestone milestone,
    required UserStatistics stats,
    required bool isDarkMode,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    switch (milestone.type) {
      case MilestoneType.vocabulary:
        return _buildVocabularyContent(
          context: context,
          milestone: milestone,
          stats: stats,
          isDarkMode: isDarkMode,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        );
      case MilestoneType.consistency:
        return _buildConsistencyContent(
          context: context,
          milestone: milestone,
          stats: stats,
          isDarkMode: isDarkMode,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        );
      case MilestoneType.accuracy:
        return _buildAccuracyContent(
          context: context,
          milestone: milestone,
          stats: stats,
          isDarkMode: isDarkMode,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        );
      default:
        return _buildGenericContent(
          isDarkMode: isDarkMode,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        );
    }
  }

  Widget _buildVocabularyContent({
    required BuildContext context,
    required Milestone milestone,
    required UserStatistics stats,
    required bool isDarkMode,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final surfaceColor =
        isDarkMode ? MnemonicsColors.darkSurface : Colors.white;
    final stageBreakdown = stats.stageBreakdown;
    final newCount = stageBreakdown[LearningStage.newWord] ?? 0;
    final learningCount = stageBreakdown[LearningStage.learning] ?? 0;
    final masteredCount = stageBreakdown[LearningStage.mastered] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          decoration: BoxDecoration(
            color: surfaceColor,
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
                'What counts as learned?',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.s),
              Text(
                'Words move through stages: New → Learning → Mastered. '
                'Only words you\'ve mastered count toward this goal.',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.l),
              Text(
                'Your progress by stage',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.s),
              _buildStageRow(
                LearningStage.newWord,
                newCount,
                textColor,
                secondaryTextColor,
              ),
              const SizedBox(height: MnemonicsSpacing.xs),
              _buildStageRow(
                LearningStage.learning,
                learningCount,
                textColor,
                secondaryTextColor,
              ),
              const SizedBox(height: MnemonicsSpacing.xs),
              _buildStageRow(
                LearningStage.mastered,
                masteredCount,
                textColor,
                secondaryTextColor,
              ),
              const SizedBox(height: MnemonicsSpacing.l),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/main/timer'),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Start learning'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MnemonicsColors.primaryGreen,
                    side: const BorderSide(color: MnemonicsColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(
                      vertical: MnemonicsSpacing.s,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStageRow(
    LearningStage stage,
    int count,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Row(
      children: [
        Text(
          stage.emoji,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: MnemonicsSpacing.s),
        Text(
          stage.displayName,
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: secondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConsistencyContent({
    required BuildContext context,
    required Milestone milestone,
    required UserStatistics stats,
    required bool isDarkMode,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final surfaceColor =
        isDarkMode ? MnemonicsColors.darkSurface : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          decoration: BoxDecoration(
            color: surfaceColor,
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
                'Streak goal',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.s),
              Text(
                'Study at least once every day to build your streak. '
                'Your current streak is ${stats.currentStreak} day${stats.currentStreak == 1 ? '' : 's'}.',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.l),
              Container(
                padding: const EdgeInsets.all(MnemonicsSpacing.m),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(MnemonicsSpacing.radiusL),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: MnemonicsSpacing.s),
                    Expanded(
                      child: Text(
                        stats.currentStreak > 0
                            ? 'Study today to extend your streak!'
                            : 'Start studying today to begin your streak.',
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.m),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/practice/streak'),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('View streak details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(
                      vertical: MnemonicsSpacing.s,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccuracyContent({
    required BuildContext context,
    required Milestone milestone,
    required UserStatistics stats,
    required bool isDarkMode,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final surfaceColor =
        isDarkMode ? MnemonicsColors.darkSurface : Colors.white;
    final currentPercent = (stats.averageAccuracy * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          decoration: BoxDecoration(
            color: surfaceColor,
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
                'Accuracy goal',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.s),
              Text(
                'Your overall review accuracy is based on correct answers when '
                'reviewing words. You\'re at $currentPercent% toward the ${milestone.targetValue}% goal.',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.l),
              Container(
                padding: const EdgeInsets.all(MnemonicsSpacing.m),
                decoration: BoxDecoration(
                  color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(MnemonicsSpacing.radiusL),
                ),
                child: Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: MnemonicsSpacing.s),
                    Expanded(
                      child: Text(
                        'Review difficult words more often to improve your accuracy.',
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.m),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/practice/accuracy'),
                  icon: const Icon(Icons.trending_up, size: 18),
                  label: const Text('View accuracy details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MnemonicsColors.primaryGreen,
                    side: const BorderSide(color: MnemonicsColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(
                      vertical: MnemonicsSpacing.s,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenericContent({
    required bool isDarkMode,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final surfaceColor =
        isDarkMode ? MnemonicsColors.darkSurface : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: surfaceColor,
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
      child: Text(
        'Keep going! Track your progress from the Profile and Practice tabs.',
        style: MnemonicsTypography.bodyRegular.copyWith(
          color: secondaryTextColor,
          fontSize: 14,
        ),
      ),
    );
  }
}
