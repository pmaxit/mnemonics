import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../domain/statistics_data.dart';
import '../widgets/animated_progress_chart.dart';
import '../widgets/animated_stat_card.dart';
import '../../../profile/providers/user_info_provider.dart';
import '../../../profile/domain/user_info.dart';
import 'package:intl/intl.dart';
import '../../../study_session/providers/study_session_providers.dart';
import '../../../study_session/domain/study_plan.dart';
import '../../../study_session/domain/study_plan_day.dart';

class ProgressOverviewScreen extends ConsumerStatefulWidget {
  const ProgressOverviewScreen({super.key});

  @override
  ConsumerState<ProgressOverviewScreen> createState() =>
      _ProgressOverviewScreenState();
}

class _ProgressOverviewScreenState extends ConsumerState<ProgressOverviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statisticsAsync = ref.watch(statisticsProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    if (statisticsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (statisticsAsync.hasError) {
      return Center(
          child: Text('Error loading statistics: ${statisticsAsync.error}'));
    }

    final statistics = statisticsAsync.asData?.value;
    if (statistics == null) {
      return const Center(child: Text('No statistics data available.'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
        left: MnemonicsSpacing.l,
        right: MnemonicsSpacing.l,
        bottom: 120, // Space for CustomBottomNavBar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated header matching Profile style (only this slides up)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildAnimatedHeader(isDarkMode),
                ),
              );
            },
          ),
          const SizedBox(height: MnemonicsSpacing.l),

          // Motivational tagline with animation
          _buildMotivationalTagline(statistics),
          const SizedBox(height: MnemonicsSpacing.xl),

          // Main statistics grid
          Row(
            children: [
              Expanded(
                child: AnimatedStatCard(
                  key: const ValueKey('total_learned'),
                  label: 'Total Learned',
                  value: statistics.totalLearned,
                  icon: Icons.school,
                  accentColor: MnemonicsColors.primaryGreen,
                  isAchievement: true,
                  animationDelay: 0,
                  onTap: () => context.push('/practice/total-words'),
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: AnimatedStatCard(
                  key: const ValueKey('learned_today'),
                  label: 'Learned Today',
                  value: statistics.learnedToday,
                  icon: Icons.today,
                  accentColor: MnemonicsColors.secondaryOrange,
                  isAchievement: statistics.learnedToday > 0,
                  animationDelay: 0,
                  onTap: () => context.push('/practice/words-today'),
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/practice/streak'),
                  child: StreakCard(
                    key: const ValueKey('streak_card'),
                    streakCount: statistics.streak,
                    animationDelay: 0,
                  ),
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.m),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/practice/accuracy'),
                  child: ProgressPercentageCard(
                    key: const ValueKey('accuracy_card'),
                    label: 'Accuracy',
                    percentage: statistics.averageAccuracy * 100,
                    accentColor: _getAccuracyColor(statistics.averageAccuracy),
                    animationDelay: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.xl),

          // Animated progress chart
          AnimatedProgressChart(
            weeklyProgress: statistics.weeklyProgress,
            animationDelay: 0,
          ),
          const SizedBox(height: MnemonicsSpacing.xl),

          // ── Study Plan card ──────────────────────────────────────────────
          _StudyPlanSection(isDarkMode: isDarkMode),
          const SizedBox(height: MnemonicsSpacing.xl),

          // Learning stages breakdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning Stages',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: MnemonicsSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: AnimatedStatCard(
                      key: const ValueKey('new_words'),
                      label: 'New',
                      value: statistics.newCount,
                      icon: Icons.fiber_new,
                      accentColor: Colors.blue,
                      animationDelay: 0,
                      onTap: () =>
                          context.push('/practice/learning-stages/new'),
                    ),
                  ),
                  const SizedBox(width: MnemonicsSpacing.s),
                  Expanded(
                    child: AnimatedStatCard(
                      key: const ValueKey('learning_words'),
                      label: 'Learning',
                      value: statistics.inProgressCount,
                      icon: Icons.psychology,
                      accentColor: Colors.orange,
                      animationDelay: 0,
                      onTap: () =>
                          context.push('/practice/learning-stages/learning'),
                    ),
                  ),
                  const SizedBox(width: MnemonicsSpacing.s),
                  Expanded(
                    child: AnimatedStatCard(
                      key: const ValueKey('mastered_words'),
                      label: 'Mastered',
                      value: statistics.masteredCount,
                      icon: Icons.star,
                      accentColor: Colors.amber,
                      isAchievement: true,
                      animationDelay: 0,
                      onTap: () =>
                          context.push('/practice/learning-stages/mastered'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.xl),

          // Category breakdown
          AnimatedBreakdownSection(
            key: const ValueKey('category_breakdown'),
            title: 'Progress by Category',
            data: statistics.categoryBreakdown,
            animationDelay: 0,
            onCategoryTap: (category) =>
                context.push('/practice/breakdown/category/$category'),
          ),
          const SizedBox(height: MnemonicsSpacing.xl),

          // Difficulty breakdown
          AnimatedBreakdownSection(
            key: const ValueKey('difficulty_breakdown'),
            title: 'Progress by Difficulty',
            data: statistics.difficultyBreakdown,
            animationDelay: 0,
            onCategoryTap: (difficulty) =>
                context.push('/practice/breakdown/difficulty/$difficulty'),
          ),

          // Bottom spacing
          const SizedBox(height: MnemonicsSpacing.xl),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMotivationalTagline(StatisticsData statistics) {
    final tagline = _getMotivationalMessage(statistics);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTaglineColor(statistics).withOpacity(0.1),
            _getTaglineColor(statistics).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        border: Border.all(
          color: _getTaglineColor(statistics).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getTaglineColor(statistics).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.s),
            decoration: BoxDecoration(
              color: _getTaglineColor(statistics).withOpacity(0.2),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            ),
            child: Icon(
              _getTaglineIcon(statistics),
              color: _getTaglineColor(statistics),
              size: 24,
            ),
          ),
          const SizedBox(width: MnemonicsSpacing.m),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tagline,
                  style: MnemonicsTypography.bodyLarge.copyWith(
                    color: _getTaglineColor(statistics),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: MnemonicsSpacing.xs),

                // Progress indicator
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        _getTaglineColor(statistics).withOpacity(0.3),
                        _getTaglineColor(statistics),
                      ],
                      stops: [
                        0.0,
                        _getMotivationProgress(statistics).clamp(0.0, 1.0)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Achievement badge
          if (statistics.totalLearned > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MnemonicsSpacing.s,
                vertical: MnemonicsSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getTaglineColor(statistics),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
              ),
              child: Text(
                '${statistics.totalLearned}',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(StatisticsData statistics) {
    if (statistics.totalLearned == 0) {
      return "Every expert was once a beginner. Start your journey today! 🌱";
    } else if (statistics.totalLearned < 10) {
      return "Great start! You're building momentum. Keep going! 🚀";
    } else if (statistics.totalLearned < 50) {
      return "You're on fire! ${statistics.totalLearned} words mastered and counting! 🔥";
    } else if (statistics.totalLearned < 100) {
      return "Impressive progress! You're becoming a vocabulary champion! 🏆";
    } else if (statistics.totalLearned < 250) {
      return "Wow! ${statistics.totalLearned} words conquered. You're unstoppable! ⚡";
    } else {
      return "Legendary! ${statistics.totalLearned} words mastered. You're a language master! 👑";
    }
  }

  Color _getTaglineColor(StatisticsData statistics) {
    if (statistics.totalLearned == 0) {
      return MnemonicsColors.primaryGreen;
    } else if (statistics.totalLearned < 50) {
      return MnemonicsColors.secondaryOrange;
    } else if (statistics.totalLearned < 100) {
      return Colors.purple;
    } else if (statistics.totalLearned < 250) {
      return Colors.indigo;
    } else {
      return Colors.amber;
    }
  }

  IconData _getTaglineIcon(StatisticsData statistics) {
    if (statistics.totalLearned == 0) {
      return Icons.eco;
    } else if (statistics.totalLearned < 10) {
      return Icons.rocket_launch;
    } else if (statistics.totalLearned < 50) {
      return Icons.local_fire_department;
    } else if (statistics.totalLearned < 100) {
      return Icons.emoji_events;
    } else if (statistics.totalLearned < 250) {
      return Icons.bolt;
    } else {
      return Icons.workspace_premium;
    }
  }

  double _getMotivationProgress(StatisticsData statistics) {
    if (statistics.totalLearned < 10) {
      return statistics.totalLearned / 10;
    } else if (statistics.totalLearned < 50) {
      return (statistics.totalLearned - 10) / 40;
    } else if (statistics.totalLearned < 100) {
      return (statistics.totalLearned - 50) / 50;
    } else if (statistics.totalLearned < 250) {
      return (statistics.totalLearned - 100) / 150;
    } else {
      return 1.0;
    }
  }

  Widget _buildAnimatedHeader(bool isDarkMode) {
    final userInfoAsync = ref.watch(currentUserProvider);

    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MnemonicsColors.primaryGreen,
                  MnemonicsColors.primaryGreen.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: MnemonicsColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: userInfoAsync.when(
                data: (userInfo) => Text(
                  userInfo.initials,
                  style: MnemonicsTypography.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                loading: () => const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
                error: (error, stack) => const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: MnemonicsSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userInfoAsync.when(
                  data: (userInfo) => Text(
                    'Your Progress',
                    style: MnemonicsTypography.headingMedium.copyWith(
                      color: isDarkMode
                          ? MnemonicsColors.darkTextPrimary
                          : MnemonicsColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => Text(
                    'Your Progress',
                    style: MnemonicsTypography.headingMedium.copyWith(
                      color: isDarkMode
                          ? MnemonicsColors.darkTextPrimary
                          : MnemonicsColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  error: (error, stack) => Text(
                    'Your Progress',
                    style: MnemonicsTypography.headingMedium.copyWith(
                      color: isDarkMode
                          ? MnemonicsColors.darkTextPrimary
                          : MnemonicsColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: MnemonicsSpacing.xs),
                Text(
                  'Track your learning journey',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: isDarkMode
                        ? MnemonicsColors.darkTextSecondary
                        : MnemonicsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(MnemonicsSpacing.s),
            decoration: BoxDecoration(
              color: MnemonicsColors.secondaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
            ),
            child: const Icon(
              Icons.analytics,
              color: MnemonicsColors.secondaryOrange,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyPlanSection extends ConsumerWidget {
  final bool isDarkMode;
  const _StudyPlanSection({required this.isDarkMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(activePlansProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Study Plan',
              style: MnemonicsTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/study-plan/create'),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('New Plan'),
              style: TextButton.styleFrom(
                foregroundColor: MnemonicsColors.primaryGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: MnemonicsSpacing.m),

        plansAsync.when(
          loading: () => _loadingCard(),
          error: (err, __) => _errorCard(err),
          data: (plans) => plans.isEmpty
              ? _emptyCard(context)
              : Column(
                  children: plans
                      .map((plan) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: MnemonicsSpacing.m),
                            child: _activePlanCard(context, ref, plan),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _loadingCard() => const Center(child: CircularProgressIndicator());
  Widget _errorCard(dynamic err) => Center(child: Text('Error: $err'));

  Widget _emptyCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/study-plan/create'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(MnemonicsSpacing.l),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month_outlined,
                  color: MnemonicsColors.primaryGreen, size: 24),
            ),
            const SizedBox(height: MnemonicsSpacing.m),
            Text('No active study plan',
                style: MnemonicsTypography.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: MnemonicsSpacing.xs),
            Text(
              'Create an AI-powered plan to practise\nwords day by day',
              textAlign: TextAlign.center,
              style: MnemonicsTypography.bodyRegular
                  .copyWith(color: MnemonicsColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: MnemonicsSpacing.l),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: MnemonicsColors.primaryGreen,
                borderRadius:
                    BorderRadius.circular(MnemonicsSpacing.radiusL),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Generate Plan with AI',
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activePlanCard(BuildContext context, WidgetRef ref, StudyPlan plan) {
    final days = plan.days;
    final done = days.where((d) => d.status == DayStatus.done).length;
    final inProgress =
        days.where((d) => d.status == DayStatus.inProgress).length;
    final total = days.length;
    final progress = total == 0 ? 0.0 : done / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: MnemonicsColors.primaryGreen.withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(MnemonicsSpacing.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month,
                        color: MnemonicsColors.primaryGreen, size: 14),
                    const SizedBox(width: 4),
                    Text('Active Plan',
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: MnemonicsColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, 
                    color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                    size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmDelete(context, ref, plan),
                ),
              ],
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Text(
            plan.title ?? '${plan.totalWords}-Word ${plan.numDays}-Day Plan',
            style: MnemonicsTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Row(
            children: [
              _chip('$done done', MnemonicsColors.primaryGreen),
              const SizedBox(width: MnemonicsSpacing.s),
              _chip('$inProgress in progress',
                  MnemonicsColors.secondaryOrange),
              const SizedBox(width: MnemonicsSpacing.s),
              _chip('${total - done} left',
                  MnemonicsColors.textSecondary),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress',
                  style: MnemonicsTypography.bodyRegular
                      .copyWith(fontWeight: FontWeight.w500)),
              Text('${(progress * 100).round()}%',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                      color: MnemonicsColors.primaryGreen,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.s),
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
      boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      border: isDarkMode ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3)) : null,
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, StudyPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: const Text('Are you sure you want to remove this study plan? Progress on individual words will be kept, but the plan schedule will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(studyPlanRepositoryProvider).deletePlan(plan.id);
      ref.invalidate(activePlansProvider);
    }
  }
}

class StreakCard extends StatelessWidget {
  final int streakCount;
  final int animationDelay;
  const StreakCard({super.key, required this.streakCount, this.animationDelay = 0});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
          const SizedBox(height: 8),
          Text('$streakCount Days', style: MnemonicsTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          Text('Streak', style: MnemonicsTypography.bodyRegular.copyWith(color: MnemonicsColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class ProgressPercentageCard extends StatelessWidget {
  final String label;
  final double percentage;
  final Color accentColor;
  final int animationDelay;
  const ProgressPercentageCard({super.key, required this.label, required this.percentage, required this.accentColor, this.animationDelay = 0});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            backgroundColor: accentColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(accentColor),
            strokeWidth: 6,
          ),
          const SizedBox(height: 8),
          Text('${percentage.round()}%', style: MnemonicsTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: MnemonicsTypography.bodyRegular.copyWith(color: MnemonicsColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class AnimatedBreakdownSection extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  final int animationDelay;
  final Function(String) onCategoryTap;
  const AnimatedBreakdownSection({super.key, required this.title, required this.data, this.animationDelay = 0, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: MnemonicsTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        if (data.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('No data available')),
          )
        else
          ...data.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onCategoryTap(entry.key),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text('${entry.value} words', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          )),
      ],
    );
  }
}
