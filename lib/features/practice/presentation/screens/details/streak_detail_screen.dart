import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/design/design_system.dart';
import '../../../../../common/design/theme_provider.dart';
import '../../../providers/statistics_provider.dart';
import '../../widgets/animated_progress_utils.dart';

class StreakDetailScreen extends ConsumerStatefulWidget {
  const StreakDetailScreen({super.key});

  @override
  ConsumerState<StreakDetailScreen> createState() => _StreakDetailScreenState();
}

class _StreakDetailScreenState extends ConsumerState<StreakDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;

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
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _pageController.forward();
      }
    });
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

    return Scaffold(
      backgroundColor: isDarkMode ? MnemonicsColors.darkBackground : MnemonicsColors.background,
      appBar: AppBar(
        title: const Text('🔥 Streak Details'),
        backgroundColor: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        foregroundColor: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: statisticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (statistics) => AnimatedBuilder(
          animation: _pageAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _pageAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(MnemonicsSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current streak hero card
                    AnimatedProgressUtils.buildStaggeredAnimation(
                      animation: _pageAnimation,
                      index: 0,
                      child: _buildStreakHeroCard(statistics.streak, isDarkMode),
                    ),
                    const SizedBox(height: MnemonicsSpacing.xl),
                    
                    // Streak insights
                    AnimatedProgressUtils.buildStaggeredAnimation(
                      animation: _pageAnimation,
                      index: 1,
                      child: _buildStreakInsights(statistics.streak, isDarkMode),
                    ),
                    const SizedBox(height: MnemonicsSpacing.xl),
                    
                    // Weekly streak calendar
                    AnimatedProgressUtils.buildStaggeredAnimation(
                      animation: _pageAnimation,
                      index: 2,
                      child: _buildWeeklyCalendar(statistics.weeklyProgress, isDarkMode),
                    ),
                    const SizedBox(height: MnemonicsSpacing.xl),
                    
                    // Streak milestones
                    AnimatedProgressUtils.buildStaggeredAnimation(
                      animation: _pageAnimation,
                      index: 3,
                      child: _buildStreakMilestones(statistics.streak, isDarkMode),
                    ),
                    const SizedBox(height: MnemonicsSpacing.xl),
                    
                    // Motivational tips
                    AnimatedProgressUtils.buildStaggeredAnimation(
                      animation: _pageAnimation,
                      index: 4,
                      child: _buildMotivationalTips(isDarkMode),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStreakHeroCard(int streak, bool isDarkMode) {
    final streakColor = streak > 0 ? Colors.orange : Colors.grey;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            streakColor.withOpacity(0.1),
            streakColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        border: Border.all(
          color: streakColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
      ),
      child: Column(
        children: [
          // Fire icon with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 2000),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Transform.scale(
                scale: 0.8 + (0.4 * animation),
                child: Container(
                  padding: const EdgeInsets.all(MnemonicsSpacing.l),
                  decoration: BoxDecoration(
                    color: streakColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    streak > 0 ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                    size: 48,
                    color: streakColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: MnemonicsSpacing.l),
          
          // Streak count
          AnimatedProgressUtils.buildCountUpAnimation(
            animation: _pageAnimation,
            targetValue: streak,
            suffix: streak == 1 ? ' Day' : ' Days',
            style: MnemonicsTypography.headingLarge.copyWith(
              color: streakColor,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          
          Text(
            streak > 0 ? 'Keep the fire burning!' : 'Start your streak today!',
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakInsights(int streak, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Streak Insights',
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        Row(
          children: [
            Expanded(child: _buildInsightCard('Personal Best', '${streak > 7 ? streak : 7}', Icons.emoji_events, Colors.amber, isDarkMode)),
            const SizedBox(width: MnemonicsSpacing.m),
            Expanded(child: _buildInsightCard('This Week', '${(streak < 7 ? streak : 7)}', Icons.date_range, Colors.blue, isDarkMode)),
          ],
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        Row(
          children: [
            Expanded(child: _buildInsightCard('Next Goal', '${_getNextGoal(streak)}', Icons.flag, Colors.green, isDarkMode)),
            const SizedBox(width: MnemonicsSpacing.m),
            Expanded(child: _buildInsightCard('Progress', '${(streak / _getNextGoal(streak) * 100).round()}%', Icons.trending_up, Colors.purple, isDarkMode)),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(String label, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      decoration: BoxDecoration(
        color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
        border: isDarkMode
            ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3))
            : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: MnemonicsSpacing.s),
          Text(
            value,
            style: MnemonicsTypography.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.xs),
          Text(
            label,
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar(List<dynamic> weeklyProgress, bool isDarkMode) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.l),
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              
              // Calculate the date for this day of the week
              final dayOfWeek = now.weekday - 1; // Monday = 0
              final dayOffset = index - dayOfWeek;
              final dayDate = now.add(Duration(days: dayOffset));
              
              // Check if there's activity for this day (simplified logic)
              final hasActivity = index <= dayOfWeek; // Show activity for past/current days
              
              return Column(
                children: [
                  Text(
                    day,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: MnemonicsSpacing.s),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: hasActivity ? Colors.orange : Colors.grey.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: hasActivity
                        ? const Icon(Icons.local_fire_department, color: Colors.white, size: 16)
                        : null,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakMilestones(int streak, bool isDarkMode) {
    final milestones = [
      {'days': 3, 'title': 'Getting Started', 'icon': Icons.play_arrow},
      {'days': 7, 'title': 'One Week Wonder', 'icon': Icons.date_range},
      {'days': 30, 'title': 'Monthly Master', 'icon': Icons.calendar_month},
      {'days': 100, 'title': 'Century Club', 'icon': Icons.star},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        ...milestones.map((milestone) {
          final days = milestone['days'] as int;
          final isAchieved = streak >= days;
          final progress = streak / days;
          
          return Container(
            margin: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            decoration: BoxDecoration(
              color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
              border: isAchieved
                  ? Border.all(color: Colors.amber.withOpacity(0.5), width: 2)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(MnemonicsSpacing.s),
                  decoration: BoxDecoration(
                    color: isAchieved ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
                  ),
                  child: Icon(
                    milestone['icon'] as IconData,
                    color: isAchieved ? Colors.amber : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: MnemonicsSpacing.m),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone['title'] as String,
                        style: MnemonicsTypography.bodyLarge.copyWith(
                          color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$days days',
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: MnemonicsSpacing.xs),
                      
                      // Progress bar
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: isAchieved ? Colors.amber : Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (isAchieved)
                  const Icon(Icons.check_circle, color: Colors.amber, size: 20),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMotivationalTips(bool isDarkMode) {
    final tips = [
      'Set a specific time each day for learning',
      'Start with just 5-10 minutes daily',
      'Use notifications to remind yourself',
      'Celebrate small wins along the way',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips for Building Streaks',
          style: MnemonicsTypography.headingMedium.copyWith(
            color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.l),
          decoration: BoxDecoration(
            color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            boxShadow: isDarkMode ? MnemonicsColors.darkCardShadow : MnemonicsColors.cardShadow,
          ),
          child: Column(
            children: tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: MnemonicsSpacing.m),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: MnemonicsColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: MnemonicsSpacing.s),
                  Expanded(
                    child: Text(
                      tip,
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: isDarkMode ? MnemonicsColors.darkTextPrimary : MnemonicsColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  int _getNextGoal(int streak) {
    if (streak < 3) return 3;
    if (streak < 7) return 7;
    if (streak < 30) return 30;
    if (streak < 100) return 100;
    return ((streak ~/ 100) + 1) * 100;
  }
}