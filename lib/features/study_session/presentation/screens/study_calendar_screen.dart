import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/study_plan.dart';
import '../../domain/study_plan_day.dart';
import '../../providers/study_session_providers.dart';
import '../widgets/calendar_heatmap_widget.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../../common/layout/tab_screen_layout.dart';
import '../../../../common/widgets/animated_tab_header_card.dart';
import '../../../home/providers.dart';

class StudyCalendarScreen extends ConsumerWidget {
  const StudyCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(activePlansProvider);
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
        .toSet() ?? {};
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------
  Widget _buildEmpty(BuildContext context, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        MnemonicsSpacing.m,
        MnemonicsSpacing.m,
        MnemonicsSpacing.m,
        MnemonicsSpacing.xxl,
      ),
      child: Column(
        children: [
          AnimatedTabHeaderCard(
            isDarkMode: isDarkMode,
            leading: TabHeaderBadge(
              child: const Icon(Icons.calendar_month_rounded,
                  color: Colors.white, size: 24),
            ),
            title: 'Study Plan',
            subtitle: 'Create a personalized plan to get started',
            trailing: const TabHeaderTrailingIcon(
              icon: Icons.auto_awesome,
              color: MnemonicsColors.secondaryOrange,
            ),
          ),
          const SizedBox(height: TabScreenLayout.afterHeaderGap),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MnemonicsSpacing.xl),
            decoration: BoxDecoration(
              color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
              boxShadow: isDarkMode
                  ? MnemonicsColors.darkCardShadow
                  : MnemonicsColors.cardShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MnemonicsColors.primaryGreen,
                        MnemonicsColors.primaryGreen.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color:
                            MnemonicsColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.calendar_month_rounded,
                      size: 36, color: Colors.white),
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
                          BorderRadius.circular(MnemonicsSpacing.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: MnemonicsColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
        ],
      ),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        MnemonicsSpacing.m,
        MnemonicsSpacing.m,
        MnemonicsSpacing.m,
        MnemonicsSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card matching app style ───────────────────────────────
          AnimatedTabHeaderCard(
            isDarkMode: isDarkMode,
            leading: TabHeaderBadge(
              child: const Icon(Icons.calendar_month_rounded,
                  color: Colors.white, size: 24),
            ),
            title: plan.title,
            subtitle:
                '${plan.totalWords} words • ${plan.numDays} days • ${plan.wordsPerDay}/day',
            trailing: TabHeaderTrailingIcon(
              icon: Icons.stars_rounded,
              color: MnemonicsColors.primaryGreen,
            ),
          ),
          const SizedBox(height: TabScreenLayout.afterHeaderGap),

          // ── Status chips ─────────────────────────────────────────────────
          Row(
            children: [
              _chip('$doneDays done', MnemonicsColors.primaryGreen),
              const SizedBox(width: MnemonicsSpacing.s),
              _chip('$inProgressDays in progress',
                  MnemonicsColors.secondaryOrange),
              const SizedBox(width: MnemonicsSpacing.s),
              _chip(
                  '${plan.numDays - doneDays - inProgressDays} left',
                  MnemonicsColors.textSecondary),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.l),

          // ── XP & Streak Hero Cards ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _XpCard(
                  earnedXp: earnedXp,
                  totalXp: plan.totalXp > 0 ? plan.totalXp : 1,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: _StreakCard(streak: streak),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),

          // ── Progress ring card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? MnemonicsColors.darkSurface
                  : Colors.white,
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
                          backgroundColor: MnemonicsColors.primaryGreen
                              .withOpacity(0.12),
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

          // ── Badges section ───────────────────────────────────────────────
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
              height: 76,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    badges.map((b) => _BadgeChip(badge: b)).toList(),
              ),
            ),
          ],

          // ── Calendar heatmap ─────────────────────────────────────────────
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
          CalendarHeatmapWidget(
            plan: plan,
            onDayTap: (day) => _openDay(context, ref, day),
          ),
          const SizedBox(height: MnemonicsSpacing.xxl),
        ],
      ),
    );
  }

  void _openDay(BuildContext context, WidgetRef ref, StudyPlanDay day) {
    if (day.status == DayStatus.notAttempted) {
      ref.read(dayStatusNotifierProvider.notifier).markInProgress(day.dayNumber);
    }
    context.push('/study-plan/day/${day.dayNumber}', extra: day);
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      ),
      child: Text(
        label,
        style: MnemonicsTypography.bodyRegular.copyWith(
          color: color,
          fontSize: 12,
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
// XP Card
// ---------------------------------------------------------------------------
class _XpCard extends StatelessWidget {
  final int earnedXp;
  final int totalXp;

  const _XpCard({required this.earnedXp, required this.totalXp});

  @override
  Widget build(BuildContext context) {
    final pct =
        totalXp > 0 ? (earnedXp / totalXp).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                '$earnedXp XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'of $totalXp XP total',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Streak Card
// ---------------------------------------------------------------------------
class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final isOnFire = streak >= 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnFire
              ? [const Color(0xFFF97316), const Color(0xFFFB923C)]
              : [const Color(0xFF64748B), const Color(0xFF94A3B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: [
          BoxShadow(
            color: (isOnFire
                    ? const Color(0xFFF97316)
                    : const Color(0xFF64748B))
                .withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOnFire ? Icons.local_fire_department : Icons.whatshot,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '$streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isOnFire ? 'Day streak! 🔥' : 'Day streak',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
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
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
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

  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            badge.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
