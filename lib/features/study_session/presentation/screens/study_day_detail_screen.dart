import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../profile/domain/user_statistics.dart';
import '../../domain/study_plan_day.dart';
import '../../providers/study_session_providers.dart';
import '../../../home/domain/vocabulary_word.dart';
import '../../../home/providers.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';

class StudyDayDetailScreen extends ConsumerWidget {
  final StudyPlanDay day;
  final DateTime? date;

  const StudyDayDetailScreen({super.key, required this.day, this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(vocabularyListProvider);
    final dayStatusState = ref.watch(dayStatusNotifierProvider);
    final learnedWords = ref
        .watch(allUserWordDataProvider)
        .asData
        ?.value
        .where((d) => d.isLearned)
        .map((d) => d.word)
        .toSet() ?? <String>{};
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor:
          isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.surface,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? MnemonicsColors.darkBackground : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              day.isReviewDay ? 'Review Day ${day.dayNumber}' : 'Day ${day.dayNumber}',
              style: MnemonicsTypography.headingMedium.copyWith(
                color: isDarkMode
                    ? MnemonicsColors.darkTextPrimary
                    : MnemonicsColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            if (date != null)
              Text(
                DateFormat('EEEE, MMMM d').format(date!),
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: isDarkMode
                      ? MnemonicsColors.darkTextSecondary
                      : MnemonicsColors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          // XP badge
          Container(
            margin: const EdgeInsets.only(right: MnemonicsSpacing.m),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MnemonicsColors.primaryGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded,
                    color: MnemonicsColors.primaryGreen, size: 16),
                const SizedBox(width: 4),
                Text(
                  '+${day.xpValue} XP',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: MnemonicsColors.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            margin: const EdgeInsets.only(right: MnemonicsSpacing.s),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(day.status).withOpacity(0.12),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor(day.status),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _statusLabel(day.status),
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: _statusColor(day.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: vocabAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: MnemonicsColors.primaryGreen,
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: MnemonicsColors.textSecondary,
            ),
          ),
        ),
        data: (allWords) {
          final wordSet = day.words.toSet();
          final dayWords =
              allWords.where((w) => wordSet.contains(w.word)).toList();
          final dayDone = day.status == DayStatus.done;
          final learnedCount = dayWords
              .where((w) =>
                  dayDone || learnedWords.contains(w.word))
              .length;

          return Column(
            children: [
              // Stat bar with word count, XP, and review status
              Padding(
                padding: const EdgeInsets.all(MnemonicsSpacing.m),
                child: _StatBar(
                  day: day,
                  wordCount: dayWords.length,
                  learnedCount: learnedCount,
                  isDarkMode: isDarkMode,
                ),
              ),

              // Word list
              Expanded(
                child: dayWords.isEmpty
                    ? _buildEmpty(isDarkMode)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          MnemonicsSpacing.m,
                          0,
                          MnemonicsSpacing.m,
                          120,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: dayWords.length,
                        itemBuilder: (context, index) => _WordCard(
                          word: dayWords[index],
                          index: index,
                          isDarkMode: isDarkMode,
                          isLearned: dayDone ||
                              learnedWords.contains(dayWords[index].word),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: day.status != DayStatus.done
          ? _MarkDoneBar(
              dayNumber: day.dayNumber,
              state: dayStatusState,
              isDarkMode: isDarkMode,
              wordCount: day.words.length,
              xpValue: day.xpValue,
              dayWords: day.words,
            )
          : _CompletedBar(isDarkMode: isDarkMode, xpValue: day.xpValue),
    );
  }

  Widget _buildEmpty(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: MnemonicsColors.textSecondary,
            size: 48,
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Text(
            'Words not found in vocabulary list',
            style: MnemonicsTypography.bodyRegular
                .copyWith(color: MnemonicsColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Color _statusColor(DayStatus status) {
    switch (status) {
      case DayStatus.done:
        return MnemonicsColors.primaryGreen;
      case DayStatus.inProgress:
        return MnemonicsColors.secondaryOrange;
      case DayStatus.notAttempted:
        return MnemonicsColors.textSecondary;
    }
  }

  String _statusLabel(DayStatus status) {
    switch (status) {
      case DayStatus.done:
        return 'Done';
      case DayStatus.inProgress:
        return 'In Progress';
      case DayStatus.notAttempted:
        return 'Not Started';
    }
  }
}

// ---------------------------------------------------------------------------
// Stat Bar — shows word count, XP, and review day badge
// ---------------------------------------------------------------------------
class _StatBar extends StatelessWidget {
  final StudyPlanDay day;
  final int wordCount;
  final int learnedCount;
  final bool isDarkMode;

  const _StatBar({
    required this.day,
    required this.wordCount,
    required this.learnedCount,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MnemonicsSpacing.l,
        vertical: MnemonicsSpacing.m,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode
            ? MnemonicsColors.darkCardShadow
            : MnemonicsColors.cardShadow,
        border: isDarkMode
            ? Border.all(
                color: MnemonicsColors.darkBorder.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('$learnedCount/$wordCount', 'Learned'),
          _divider(),
          _statItem('+${day.xpValue}', 'XP'),
          _divider(),
          _statItem(
            day.isReviewDay ? '🔄' : '📖',
            day.isReviewDay ? 'Review' : 'New',
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: MnemonicsTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: MnemonicsColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      color: isDarkMode
          ? MnemonicsColors.darkBorder.withOpacity(0.5)
          : MnemonicsColors.surface,
    );
  }
}

// ---------------------------------------------------------------------------
// Word Card — tappable to view flashcard detail
// ---------------------------------------------------------------------------
class _WordCard extends StatelessWidget {
  final VocabularyWord word;
  final int index;
  final bool isDarkMode;
  final bool isLearned;

  const _WordCard({
    required this.word,
    required this.index,
    required this.isDarkMode,
    this.isLearned = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isLearned ? MnemonicsColors.primaryGreen : _difficultyColor(word.difficulty);

    return GestureDetector(
      onTap: () => context.push('/flashcards', extra: {
        'words': [word],
        'initialIndex': 0,
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
        padding: const EdgeInsets.all(MnemonicsSpacing.m),
        decoration: BoxDecoration(
          color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          boxShadow: isDarkMode
              ? MnemonicsColors.darkCardShadow
              : MnemonicsColors.cardShadow,
          border: isDarkMode
              ? Border.all(
                  color: MnemonicsColors.darkBorder.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
              ),
              alignment: Alignment.center,
              child: isLearned
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: MnemonicsColors.primaryGreen,
                      size: 20,
                    )
                  : Text(
                      '${index + 1}',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
            ),
            const SizedBox(width: MnemonicsSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDarkMode
                          ? MnemonicsColors.darkTextPrimary
                          : MnemonicsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.meaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: isDarkMode
                          ? MnemonicsColors.darkTextSecondary
                          : MnemonicsColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MnemonicsSpacing.s),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
              ),
              child: Text(
                isLearned ? 'LEARNED' : word.difficulty.name.toUpperCase(),
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: MnemonicsSpacing.xs),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: MnemonicsColors.textSecondary.withOpacity(0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.basic:
        return MnemonicsColors.primaryGreen;
      case WordDifficulty.intermediate:
        return MnemonicsColors.secondaryOrange;
      case WordDifficulty.advanced:
        return Colors.redAccent;
      default:
        return MnemonicsColors.textSecondary;
    }
  }
}

// ---------------------------------------------------------------------------
// Mark Done Bar — with practice button and XP reward display
// ---------------------------------------------------------------------------
class _MarkDoneBar extends ConsumerWidget {
  final int dayNumber;
  final AsyncValue<void> state;
  final bool isDarkMode;
  final int wordCount;
  final int xpValue;
  final List<String> dayWords;

  const _MarkDoneBar({
    required this.dayNumber,
    required this.state,
    required this.isDarkMode,
    required this.wordCount,
    required this.xpValue,
    required this.dayWords,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        MnemonicsSpacing.m,
        MnemonicsSpacing.s,
        MnemonicsSpacing.m,
        MnemonicsSpacing.l,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkBackground : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? MnemonicsColors.darkBorder.withOpacity(0.3)
                : MnemonicsColors.surface,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Practice button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: MnemonicsColors.primaryGreen.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                ),
              ),
              onPressed: () {
                // Pass the day's words to the flashcards screen
                final vocabAsync = ref.read(vocabularyListProvider);
                final allWords = vocabAsync.asData?.value ?? [];
                final wordSet = dayWords.toSet();
                final matchedWords =
                    allWords.where((w) => wordSet.contains(w.word)).toList();
                if (matchedWords.isNotEmpty) {
                  context.push('/flashcards', extra: {
                    'words': matchedWords,
                    'initialIndex': 0,
                  });
                } else {
                  // Fallback to timer screen
                  context.go('/main/timer');
                }
              },
              icon: const Icon(Icons.play_arrow_rounded,
                  color: MnemonicsColors.primaryGreen),
              label: Text(
                'Practice $wordCount Words',
                style: TextStyle(
                  color: MnemonicsColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          // Mark complete button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MnemonicsColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                ),
              ),
              onPressed: state is AsyncLoading
                  ? null
                  : () async {
                      await ref
                          .read(dayStatusNotifierProvider.notifier)
                          .markDone(dayNumber);
                      if (context.mounted) {
                        // Show XP celebration
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.stars_rounded,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Day $dayNumber complete! +$xpValue XP earned! 🎉',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            backgroundColor: MnemonicsColors.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        context.pop();
                      }
                    },
              icon: state is AsyncLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(
                state is AsyncLoading
                    ? 'Saving...'
                    : 'Mark Complete (+$xpValue XP)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Completed Bar — shows celebration when day is done
// ---------------------------------------------------------------------------
class _CompletedBar extends StatelessWidget {
  final bool isDarkMode;
  final int xpValue;

  const _CompletedBar({required this.isDarkMode, required this.xpValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        MnemonicsSpacing.m,
        MnemonicsSpacing.m,
        MnemonicsSpacing.m,
        MnemonicsSpacing.l,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkBackground : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? MnemonicsColors.darkBorder.withOpacity(0.3)
                : MnemonicsColors.surface,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: MnemonicsColors.primaryGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration_rounded,
                    color: MnemonicsColors.primaryGreen, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Completed! +$xpValue XP earned 🎉',
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    color: MnemonicsColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
