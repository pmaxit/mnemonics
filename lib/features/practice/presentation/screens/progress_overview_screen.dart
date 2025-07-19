import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../domain/statistics_data.dart';
import '../widgets/animated_progress_chart.dart';
import '../widgets/animated_stat_card.dart';
import '../widgets/animated_progress_utils.dart';
import '../../../profile/providers/user_info_provider.dart';
import '../../../profile/domain/user_info.dart';

class ProgressOverviewScreen extends ConsumerStatefulWidget {
  const ProgressOverviewScreen({super.key});

  @override
  ConsumerState<ProgressOverviewScreen> createState() => _ProgressOverviewScreenState();
}

class _ProgressOverviewScreenState extends ConsumerState<ProgressOverviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: AnimatedProgressUtils.pageTransition,
      vsync: this,
    );
    
    _pageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: AnimatedProgressUtils.entryEasing,
    ));
    
    // Start page animation only once
    if (!_hasAnimated) {
      _hasAnimated = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _pageController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statisticsAsync = ref.watch(statisticsProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    if (statisticsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (statisticsAsync.hasError) {
      return Center(child: Text('Error loading statistics: ${statisticsAsync.error}'));
    }
    
    final statistics = statisticsAsync.asData?.value;
    if (statistics == null) {
      return const Center(child: Text('No statistics data available.'));
    }

    return SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: MnemonicsSpacing.l,
              right: MnemonicsSpacing.l,
              bottom: MnemonicsSpacing.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated header matching Profile style
                _buildAnimatedHeader(isDarkMode),
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
                            onTap: () => context.push('/practice/learning-stages/new'),
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
                            onTap: () => context.push('/practice/learning-stages/learning'),
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
                            onTap: () => context.push('/practice/learning-stages/mastered'),
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
                  onCategoryTap: (category) => context.push('/practice/breakdown/category/$category'),
                ),
                const SizedBox(height: MnemonicsSpacing.xl),
                
                // Difficulty breakdown
                AnimatedBreakdownSection(
                  key: const ValueKey('difficulty_breakdown'),
                  title: 'Progress by Difficulty',
                  data: statistics.difficultyBreakdown,
                  animationDelay: 0,
                  onCategoryTap: (difficulty) => context.push('/practice/breakdown/difficulty/$difficulty'),
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
                      stops: [0.0, _getMotivationProgress(statistics).clamp(0.0, 1.0)],
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
    // Psychology-driven motivational messages based on progress
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
    // Calculate progress towards next milestone
    if (statistics.totalLearned < 10) {
      return statistics.totalLearned / 10;
    } else if (statistics.totalLearned < 50) {
      return (statistics.totalLearned - 10) / 40;
    } else if (statistics.totalLearned < 100) {
      return (statistics.totalLearned - 50) / 50;
    } else if (statistics.totalLearned < 250) {
      return (statistics.totalLearned - 100) / 150;
    } else {
      return 1.0; // Max achievement
    }
  }

  Widget _buildAnimatedHeader(bool isDarkMode) {
    final userInfoAsync = ref.watch(currentUserProvider);
    
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
        border: isDarkMode
            ? Border.all(
                color: MnemonicsColors.darkBorder.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          // Avatar section
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
          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userInfoAsync.when(
                  data: (userInfo) => Text(
                    'Your Progress',
                    style: MnemonicsTypography.headingMedium.copyWith(
                      color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => Text(
                    'Your Progress',
                    style: MnemonicsTypography.headingMedium.copyWith(
                      color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  error: (error, stack) => Text(
                    'Your Progress',
                    style: MnemonicsTypography.headingMedium.copyWith(
                      color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: MnemonicsSpacing.xs),
                Text(
                  'Track your learning journey',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Statistics indicator
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