import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/study_plan.dart';
import '../../domain/study_plan_day.dart';
import '../../providers/study_session_providers.dart';
import '../widgets/calendar_heatmap_widget.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../../common/layout/detail_screen_layout.dart';
import '../../../home/providers.dart';

class StudyCalendarScreen extends ConsumerStatefulWidget {
  const StudyCalendarScreen({super.key});

  @override
  ConsumerState<StudyCalendarScreen> createState() =>
      _StudyCalendarScreenState();
}

class _StudyCalendarScreenState extends ConsumerState<StudyCalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(activePlansProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor:
          isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.surface,
      appBar: DetailScreenAppBar(
        title: 'Study Plan',
        isDarkMode: isDarkMode,
        onBack: () => context.pop(),
        actions: [
          plansAsync.maybeWhen(
            data: (plans) => plans.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: isDarkMode
                          ? MnemonicsColors.darkTextSecondary
                          : MnemonicsColors.textSecondary,
                      size: 22,
                    ),
                    onPressed: () {
                      final plan = plans.first;
                      _confirmDelete(context, ref, plan);
                    },
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: plansAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: MnemonicsColors.primaryGreen),
        ),
        error: (e, _) => _buildError(context, ref, e.toString(), isDarkMode),
        data: (plans) => plans.isEmpty
            ? _buildEmpty(context, isDarkMode)
            : _buildPlanView(context, ref, plans.first, isDarkMode),
      ),
    );
  }

  /// Set of words the user has marked as learned (from local progress data).
  Set<String> _learnedWords(WidgetRef ref) {
    return ref
        .watch(allUserWordDataProvider)
        .asData
        ?.value
        .where((d) => d.isLearned)
        .map((d) => d.word)
        .toSet() ??
        {};
  }

  Widget _buildPinnedSummary({
    required bool isDarkMode,
    required StudyPlan plan,
    required WidgetRef ref,
  }) {
    return Padding(
      padding: DetailScreenLayout.summaryCardOuterPadding,
      child: DetailSummaryCard(
        isDarkMode: isDarkMode,
        child: DetailSummaryRow(
          isDarkMode: isDarkMode,
          title: plan.title,
          subtitle:
              '${plan.totalWords} words • ${plan.numDays} days • ${plan.wordsPerDay}/day',
          actionLabel: 'Practice',
          onAction: () => _openCurrentDay(context, ref, plan),
        ),
      ),
    );
  }

  Widget _buildPlanScrollContent({
    required BuildContext context,
    required WidgetRef ref,
    required StudyPlan plan,
    required bool isDarkMode,
    required int doneDays,
    required int inProgressDays,
    required int learnedCount,
    required int totalUniqueWords,
    required double progress,
    required int earnedXp,
    required int streak,
    required List<PlanBadge> badges,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: MnemonicsSpacing.s,
          runSpacing: MnemonicsSpacing.s,
          children: [
            _chip('$doneDays done', MnemonicsColors.primaryGreen),
            _chip('$inProgressDays in progress',
                MnemonicsColors.secondaryOrange),
            _chip(
                '${plan.numDays - doneDays - inProgressDays} left',
                MnemonicsColors.textSecondary),
          ],
        ),
        const SizedBox(height: MnemonicsSpacing.l),
        Row(
          children: [
            Expanded(
              child: _XpCard(
                earnedXp: earnedXp,
                totalXp: plan.totalXp > 0
                    ? plan.totalXp
                    : plan.days.fold<int>(0, (sum, d) => sum + d.xpValue).clamp(1, 1 << 30),
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: MnemonicsSpacing.m),
            Expanded(
              child: _StreakCard(
                streak: streak,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.l),
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
            boxShadow: isDarkMode
                ? MnemonicsColors.darkCardShadow
                : MnemonicsColors.cardShadow,
            border: isDarkMode
                ? Border.all(
                    color: MnemonicsColors.darkBorder.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              _ProgressRing(progress: progress),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% Complete',
                      style: MnemonicsTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: isDarkMode
                            ? MnemonicsColors.darkTextPrimary
                            : MnemonicsColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$learnedCount of $totalUniqueWords words learned • '
                      '$doneDays of ${plan.numDays} days done',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: isDarkMode
                            ? MnemonicsColors.darkTextSecondary
                            : MnemonicsColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            MnemonicsColors.primaryGreen.withOpacity(0.12),
                        valueColor: const AlwaysStoppedAnimation(
                            MnemonicsColors.primaryGreen),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (badges.isNotEmpty) ...[
          const SizedBox(height: MnemonicsSpacing.l),
          Text(
            'Badges Earned',
            style: MnemonicsTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDarkMode
                  ? MnemonicsColors.darkTextPrimary
                  : MnemonicsColors.textPrimary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              primary: false,
              itemCount: badges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _BadgeChip(badge: badges[index], isDarkMode: isDarkMode),
            ),
          ),
        ],
        const SizedBox(height: MnemonicsSpacing.l),
        Text(
          'Daily Calendar',
          style: MnemonicsTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDarkMode
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
            boxShadow: isDarkMode
                ? MnemonicsColors.darkCardShadow
                : MnemonicsColors.cardShadow,
            border: isDarkMode
                ? Border.all(
                    color: MnemonicsColors.darkBorder.withOpacity(0.3))
                : null,
          ),
          child: CalendarHeatmapWidget(
            plan: plan,
            isDarkMode: isDarkMode,
            onDayTap: (day) => _openDay(context, ref, day),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------
  Widget _buildEmpty(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: DetailScreenLayout.summaryCardOuterPadding,
          child: DetailSummaryCard(
            isDarkMode: isDarkMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Plan',
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDarkMode
                        ? MnemonicsColors.darkTextPrimary
                        : MnemonicsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Create a personalized plan to get started',
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
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: DetailScreenLayout.scrollBodyPadding,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MnemonicsSpacing.xl),
              decoration: DetailScreenLayout.summaryCardDecoration(isDarkMode),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: MnemonicsColors.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.calendar_month_rounded,
                        size: 36,
                        color: MnemonicsColors.primaryGreen.withOpacity(0.8)),
                  ),
                  const SizedBox(height: MnemonicsSpacing.l),
                  Text(
                    'No active study plan',
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: isDarkMode
                          ? MnemonicsColors.darkTextPrimary
                          : MnemonicsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: MnemonicsSpacing.s),
                  Text(
                    'Create a plan with AI-powered difficulty\ncurves and XP rewards.',
                    textAlign: TextAlign.center,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: MnemonicsColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: MnemonicsSpacing.l),
                  GestureDetector(
                    onTap: () => context.push('/study-plan/create'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: MnemonicsColors.primaryGreen,
                        borderRadius:
                            BorderRadius.circular(MnemonicsSpacing.radiusL),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Create Study Plan',
                            style: MnemonicsTypography.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Plan view — gamified with XP, streak, badges, and heatmap
  // ---------------------------------------------------------------------------
  Widget _buildPlanView(
      BuildContext context, WidgetRef ref, StudyPlan plan, bool isDarkMode) {
    final doneDays = plan.completedDays;
    final inProgressDays = plan.inProgressDays;
    final learnedWords = _learnedWords(ref);
    final learnedCount = plan.learnedWordCount(learnedWords);
    final totalUniqueWords = plan.uniqueWords.length;
    // Word-level progress: updates as soon as the user learns words,
    // without waiting for a day to be marked complete.
    final progress = plan.wordProgress(learnedWords);
    final earnedXp = plan.earnedXp;
    final streak = plan.streak;
    final badges = plan.unlockedBadges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: isDarkMode
              ? MnemonicsColors.darkBackground
              : MnemonicsColors.surface,
          child: _buildPinnedSummary(
              isDarkMode: isDarkMode, plan: plan, ref: ref),
        ),
        Expanded(
          child: ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  key: DetailScreenLayout.nextBlockKey,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: DetailScreenLayout.scrollBodyPadding.copyWith(
                    bottom: DetailScreenLayout.scrollBodyPadding.bottom +
                        MediaQuery.paddingOf(context).bottom,
                  ),
                  child: ConstrainedBox(
                    // Always taller than the viewport so the body can scroll
                    // under the pinned summary card.
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight + 160,
                    ),
                    child: _buildPlanScrollContent(
                      context: context,
                      ref: ref,
                      plan: plan,
                      isDarkMode: isDarkMode,
                      doneDays: doneDays,
                      inProgressDays: inProgressDays,
                      learnedCount: learnedCount,
                      totalUniqueWords: totalUniqueWords,
                      progress: progress,
                      earnedXp: earnedXp,
                      streak: streak,
                      badges: badges,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _openCurrentDay(BuildContext context, WidgetRef ref, StudyPlan plan) {
    final target = plan.days.firstWhere(
      (d) => d.status == DayStatus.inProgress,
      orElse: () => plan.days.firstWhere(
        (d) => d.status == DayStatus.notAttempted,
        orElse: () => plan.days.first,
      ),
    );
    _openDay(context, ref, target);
  }

  void _openDay(BuildContext context, WidgetRef ref, StudyPlanDay day) {
    if (day.status == DayStatus.notAttempted) {
      ref.read(dayStatusNotifierProvider.notifier).markInProgress(day.dayNumber);
    }
    context.push('/study-plan/day/${day.dayNumber}', extra: day);
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

  Widget _buildError(
      BuildContext context, WidgetRef ref, String error, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: isDarkMode
                    ? MnemonicsColors.darkTextSecondary
                    : MnemonicsColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.invalidate(activePlansProvider),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: isDarkMode
                      ? MnemonicsColors.darkTextPrimary
                      : MnemonicsColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, StudyPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? MnemonicsColors.darkSurface
                : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(MnemonicsSpacing.radiusXL)),
        title: Text(
          'Delete Study Plan?',
          style: MnemonicsTypography.headingMedium.copyWith(
            fontSize: 20,
            color: Theme.of(context).brightness == Brightness.dark
                ? MnemonicsColors.darkTextPrimary
                : MnemonicsColors.textPrimary,
          ),
        ),
        content: Text(
          'This will remove "${plan.title}". This action cannot be undone.',
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? MnemonicsColors.darkTextSecondary
                : MnemonicsColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? MnemonicsColors.darkTextSecondary
                    : MnemonicsColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(dayStatusNotifierProvider.notifier).deletePlan(plan.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Study plan deleted'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }
}

// ---------------------------------------------------------------------------
// XP Card — matches My Words stat card style
// ---------------------------------------------------------------------------
class _XpCard extends StatelessWidget {
  final int earnedXp;
  final int totalXp;
  final bool isDarkMode;

  const _XpCard({
    required this.earnedXp,
    required this.totalXp,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final pct =
        totalXp > 0 ? (earnedXp / totalXp).clamp(0.0, 1.0) : 0.0;
    final textPrimary = isDarkMode
        ? MnemonicsColors.darkTextPrimary
        : MnemonicsColors.textPrimary;
    final textSecondary = isDarkMode
        ? MnemonicsColors.darkTextSecondary
        : MnemonicsColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode
            ? MnemonicsColors.darkCardShadow
            : MnemonicsColors.cardShadow,
        border: isDarkMode
            ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: MnemonicsColors.primaryGreen.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(MnemonicsSpacing.radiusM),
                ),
                child: const Icon(Icons.stars_rounded,
                    color: MnemonicsColors.primaryGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                '$earnedXp XP',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'of $totalXp XP total',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: MnemonicsColors.primaryGreen.withOpacity(0.12),
              valueColor:
                  const AlwaysStoppedAnimation(MnemonicsColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Streak Card — matches My Words stat card style
// ---------------------------------------------------------------------------
class _StreakCard extends StatelessWidget {
  final int streak;
  final bool isDarkMode;

  const _StreakCard({required this.streak, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isOnFire = streak >= 3;
    final accent = isOnFire
        ? MnemonicsColors.secondaryOrange
        : MnemonicsColors.textSecondary;
    final textPrimary = isDarkMode
        ? MnemonicsColors.darkTextPrimary
        : MnemonicsColors.textPrimary;
    final textSecondary = isDarkMode
        ? MnemonicsColors.darkTextSecondary
        : MnemonicsColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode
            ? MnemonicsColors.darkCardShadow
            : MnemonicsColors.cardShadow,
        border: isDarkMode
            ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(MnemonicsSpacing.radiusM),
                ),
                child: Icon(
                  isOnFire
                      ? Icons.local_fire_department_rounded
                      : Icons.whatshot_rounded,
                  color: accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$streak',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isOnFire ? 'Day streak' : 'Day streak',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (i < (streak % 5)) || (streak >= 5)
                        ? accent
                        : accent.withOpacity(0.2),
                  ),
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
// Progress Ring
// ---------------------------------------------------------------------------
class _ProgressRing extends StatelessWidget {
  final double progress;

  const _ProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor:
                MnemonicsColors.primaryGreen.withOpacity(0.12),
            valueColor:
                const AlwaysStoppedAnimation(MnemonicsColors.primaryGreen),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: MnemonicsColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge Chip
// ---------------------------------------------------------------------------
class _BadgeChip extends StatelessWidget {
  final PlanBadge badge;
  final bool isDarkMode;

  const _BadgeChip({required this.badge, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        border: Border.all(
          color: MnemonicsColors.primaryGreen.withOpacity(0.2),
        ),
        boxShadow: isDarkMode
            ? MnemonicsColors.darkCardShadow
            : MnemonicsColors.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(
            badge.title,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode
                  ? MnemonicsColors.darkTextPrimary
                  : MnemonicsColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
