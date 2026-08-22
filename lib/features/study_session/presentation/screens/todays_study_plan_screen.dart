import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../home/domain/vocabulary_word.dart';
import '../../../home/providers.dart';
import '../../domain/daily_study_plan.dart';
import '../../providers/study_session_providers.dart';
import '../widgets/todays_study_plan_card.dart';

class TodaysStudyPlanScreen extends ConsumerWidget {
  const TodaysStudyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final planAsync = ref.watch(todaysStudyPlanProvider);
    final vocabAsync = ref.watch(vocabularyListProvider);
    final status = ref.watch(dayStatusNotifierProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.surface,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? MnemonicsColors.darkBackground : Colors.white,
        elevation: 0,
        title: const Text("Today's study plan"),
      ),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(todaysStudyPlanProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (plan) {
          final vocab = vocabAsync.asData?.value ?? [];
          return ListView(
            padding: const EdgeInsets.all(MnemonicsSpacing.m),
            children: [
              _header(plan, isDarkMode),
              const SizedBox(height: MnemonicsSpacing.m),
              _incentive(plan.incentive, isDarkMode),
              const SizedBox(height: MnemonicsSpacing.m),
              _strategy(plan.strategy, isDarkMode),
              const SizedBox(height: MnemonicsSpacing.l),
              ...plan.tracks.map(
                (track) => _track(context, plan, track, vocab, isDarkMode),
              ),
              const SizedBox(height: 96),
            ],
          );
        },
      ),
      bottomNavigationBar: planAsync.maybeWhen(
        data: (plan) => plan.completed
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final vocab = vocabAsync.asData?.value ?? [];
                            final words = wordsForPlan(plan, vocab);
                            if (words.isEmpty) return;
                            context.push('/flashcards', extra: {
                              'words': words,
                              'initialIndex': 0,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MnemonicsColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Start this mix'),
                        ),
                      ),
                      TextButton(
                        onPressed: status.isLoading
                            ? null
                            : () => ref
                                .read(dayStatusNotifierProvider.notifier)
                                .completeToday(plan),
                        child: const Text('Mark today complete'),
                      ),
                    ],
                  ),
                ),
              ),
        orElse: () => null,
      ),
    );
  }

  Widget _header(DailyStudyPlan plan, bool isDarkMode) {
    final snap = plan.profileSnapshot;
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: _box(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.strategy.headline,
            style: MnemonicsTypography.bodyLarge
                .copyWith(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '${plan.estimatedMinutes} min  ·  ${plan.incentive.dailyGoalWords} words  ·  '
            '${snap.dueCount} due  ·  ${((snap.accuracy) * 100).round()}% accuracy',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextSecondary
                  : MnemonicsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _incentive(StudyIncentive incentive, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: _box(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why finish today',
            style: MnemonicsTypography.bodyLarge
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(incentive.copy, style: MnemonicsTypography.bodyRegular),
          const SizedBox(height: 8),
          Text(
            '${incentive.streakDays}-day streak · ${incentive.pointsIfCompleted} pts · '
            '${incentive.pointsNote}',
            style: MnemonicsTypography.bodyRegular.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _strategy(StudyStrategy strategy, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: _box(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to study',
            style: MnemonicsTypography.bodyLarge
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(strategy.howToStudy, style: MnemonicsTypography.bodyRegular),
          const SizedBox(height: 12),
          ...strategy.tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(tip, style: MnemonicsTypography.bodyRegular)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _track(
    BuildContext context,
    DailyStudyPlan plan,
    StudyPlanTrack track,
    List<VocabularyWord> vocab,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
      child: Container(
        padding: const EdgeInsets.all(MnemonicsSpacing.l),
        decoration: _box(isDarkMode),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.title,
              style: MnemonicsTypography.bodyLarge
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              track.why,
              style: MnemonicsTypography.bodyRegular.copyWith(
                fontSize: 13,
                color: isDarkMode
                    ? MnemonicsColors.darkTextSecondary
                    : MnemonicsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ...track.items.asMap().entries.map((entry) {
              final item = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(item.word,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${item.reasonLabel}'
                  '${item.category.isNotEmpty ? ' · ${item.category}' : ''}'
                  '${item.mnemonicHint ? ' · mnemonic ready' : ''}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  final all = wordsForPlan(plan, vocab);
                  final index =
                      all.indexWhere((w) => w.word == item.word);
                  if (all.isEmpty) return;
                  context.push('/flashcards', extra: {
                    'words': all,
                    'initialIndex': index < 0 ? 0 : index,
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  BoxDecoration _box(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
      boxShadow:
          isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
    );
  }
}
