import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../home/domain/vocabulary_word.dart';
import '../../domain/daily_study_plan.dart';
import '../../providers/study_session_providers.dart';

class TodaysStudyPlanCard extends ConsumerWidget {
  final bool isDarkMode;

  const TodaysStudyPlanCard({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(todaysStudyPlanProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's plan",
          style: MnemonicsTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        planAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _errorCard(ref),
          data: (plan) => _planCard(context, ref, plan),
        ),
      ],
    );
  }

  Widget _errorCard(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(
            "Couldn't load today's mix",
            style: MnemonicsTypography.bodyLarge
                .copyWith(fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: () => ref.invalidate(todaysStudyPlanProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _planCard(BuildContext context, WidgetRef ref, DailyStudyPlan plan) {
    final incentive = plan.incentive;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: MnemonicsColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.completed ? 'Finished for today' : 'Personalized mix',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: MnemonicsColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '~${plan.estimatedMinutes} min',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? MnemonicsColors.darkTextSecondary
                      : MnemonicsColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Text(
            plan.strategy.headline,
            style: MnemonicsTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.xs),
          Text(
            plan.strategy.nextAction,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextSecondary
                  : MnemonicsColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Wrap(
            spacing: MnemonicsSpacing.s,
            runSpacing: MnemonicsSpacing.s,
            children: [
              if (plan.split.review > 0)
                _chip('${plan.split.review} due', MnemonicsColors.primaryGreen),
              if (plan.split.weak > 0)
                _chip('${plan.split.weak} weak', MnemonicsColors.secondaryOrange),
              if (plan.split.newWords > 0)
                _chip('${plan.split.newWords} new', Colors.blue),
              if (plan.split.bonus > 0)
                _chip('${plan.split.bonus} bonus', Colors.purple),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MnemonicsSpacing.m),
            decoration: BoxDecoration(
              color: MnemonicsColors.secondaryOrange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${incentive.streakDays}-day streak  ·  ${incentive.pointsIfCompleted} pts if you finish',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  incentive.copy,
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    fontSize: 12,
                    height: 1.4,
                    color: isDarkMode
                        ? MnemonicsColors.darkTextSecondary
                        : MnemonicsColors.textSecondary,
                  ),
                ),
                if (incentive.nextMilestone != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Next: ${incentive.nextMilestone!.label} (${incentive.nextMilestone!.remaining} to go)',
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MnemonicsColors.primaryGreen,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Row(
            children: [
              Expanded(
                child: _primaryButton(
                  label: plan.completed ? 'Review again' : 'Start next words',
                  onTap: () => context.push('/study-plan/today'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: MnemonicsColors.primaryGreen,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
      ),
      child: Text(
        label,
        style: MnemonicsTypography.bodyRegular.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
      boxShadow:
          isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      border: isDarkMode
          ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3))
          : null,
    );
  }
}

/// Shared helper: map plan word strings onto local vocabulary for flashcards.
List<VocabularyWord> wordsForPlan(DailyStudyPlan plan, List<VocabularyWord> all) {
  final byWord = {for (final w in all) w.word: w};
  return plan.items
      .map((item) => byWord[item.word])
      .whereType<VocabularyWord>()
      .toList();
}
