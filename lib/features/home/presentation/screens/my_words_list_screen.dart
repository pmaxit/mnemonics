import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../domain/word_recommendation.dart';
import '../../providers.dart';

/// List-first entry point for practising "My Words".
///
/// Shows every recommended word as a tappable row; tapping opens the word
/// detail (flashcard) starting at that word. A primary action starts the
/// whole queue from the first unlearned word.
class MyWordsListScreen extends ConsumerWidget {
  const MyWordsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final recommendedAsync = ref.watch(recommendedWordsProvider);
    final learnedAsync = ref.watch(allUserWordDataProvider);
    final profile = ref.watch(userProfileProvider).value;

    final learnedSet = learnedAsync.asData?.value
            .where((d) => d.isLearned)
            .map((d) => d.word)
            .toSet() ??
        {};

    final scaffold = Scaffold(
      backgroundColor: isDarkMode
          ? MnemonicsColors.darkBackground
          : MnemonicsColors.surface,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? MnemonicsColors.darkBackground : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Words',
          style: MnemonicsTypography.headingMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
          ),
        ),
      ),
      body: recommendedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
              color: MnemonicsColors.primaryGreen),
        ),
        error: (e, _) => Center(
          child: Text(
            'Could not load your words: $e',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextSecondary
                  : MnemonicsColors.textSecondary,
            ),
          ),
        ),
        data: (words) {
          if (words.isEmpty) {
            return _buildEmpty(isDarkMode);
          }

          final levels = WordRecommendation.parseLevels(profile?.vocabularyLevel);
          final levelLabel = levels.length == 1
              ? (levels.first == 1
                  ? 'Beginner'
                  : levels.first == 2
                      ? 'Intermediate'
                      : 'Advanced')
              : 'Levels ${levels.join(', ')}';

          // Start the queue at the first word that is not learned yet.
          var startIndex = words.indexWhere((w) => !learnedSet.contains(w.word));
          if (startIndex < 0) startIndex = 0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    MnemonicsSpacing.l, MnemonicsSpacing.s, MnemonicsSpacing.l, 0),
                child: _buildHeaderRow(
                    context, isDarkMode, words.length, levelLabel, () {
                  HapticFeedback.lightImpact();
                  context.push('/flashcards', extra: {
                    'words': words,
                    'initialIndex': startIndex,
                  });
                }),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(MnemonicsSpacing.l,
                      MnemonicsSpacing.m, MnemonicsSpacing.l, 40),
                  physics: const BouncingScrollPhysics(),
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final word = words[index];
                    final isLearned = learnedSet.contains(word.word);
                    return _wordRow(context, isDarkMode, word, index, isLearned,
                        () {
                      HapticFeedback.lightImpact();
                      context.push('/flashcards', extra: {
                        'words': words,
                        'initialIndex': index,
                      });
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    return scaffold;
  }

  Widget _buildEmpty(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MnemonicsSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 56,
              color: MnemonicsColors.primaryGreen.withOpacity(0.6),
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            Text(
              'Nothing left to practice here',
              style: MnemonicsTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: isDarkMode
                    ? MnemonicsColors.darkTextPrimary
                    : MnemonicsColors.textPrimary,
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.s),
            Text(
              'Every recommended word at your level is learned. '
              'Pick a new level or category in Settings to grow your list.',
              textAlign: TextAlign.center,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode
                    ? MnemonicsColors.darkTextSecondary
                    : MnemonicsColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isDarkMode, int count,
      String levelLabel, VoidCallback onPracticeAll) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode
            ? MnemonicsColors.darkCardShadow
            : MnemonicsColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count words • $levelLabel',
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDarkMode
                        ? MnemonicsColors.darkTextPrimary
                        : MnemonicsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap a word to study it',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: isDarkMode
                        ? MnemonicsColors.darkTextSecondary
                        : MnemonicsColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onPracticeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: MnemonicsSpacing.m, vertical: 10),
              decoration: BoxDecoration(
                color: MnemonicsColors.primaryGreen,
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Practice all',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wordRow(BuildContext context, bool isDarkMode, dynamic word,
      int index, bool isLearned, VoidCallback onTap) {
    final accent = isLearned
        ? MnemonicsColors.primaryGreen
        : _difficultyColor(word.difficulty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
        padding: const EdgeInsets.all(MnemonicsSpacing.m),
        decoration: BoxDecoration(
          color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          boxShadow: isDarkMode
              ? MnemonicsColors.darkCardShadow
              : MnemonicsColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
              ),
              alignment: Alignment.center,
              child: isLearned
                  ? const Icon(Icons.check_circle_rounded,
                      color: MnemonicsColors.primaryGreen, size: 18)
                  : Text(
                      '${index + 1}',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: isDarkMode
                          ? MnemonicsColors.darkTextSecondary
                          : MnemonicsColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MnemonicsSpacing.s),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: (isDarkMode
                      ? MnemonicsColors.darkTextSecondary
                      : MnemonicsColors.textSecondary)
                  .withOpacity(0.6),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(dynamic difficulty) {
    switch (difficulty.name) {
      case 'basic':
        return MnemonicsColors.primaryGreen;
      case 'intermediate':
        return MnemonicsColors.secondaryOrange;
      case 'advanced':
        return Colors.redAccent;
      default:
        return MnemonicsColors.textSecondary;
    }
  }
}
