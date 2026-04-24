import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../providers/unified_statistics_provider.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/statistics_overview_widget.dart';
import '../widgets/difficulty_stats_widget.dart';

class EnhancedProfileScreen extends ConsumerStatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  ConsumerState<EnhancedProfileScreen> createState() =>
      _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends ConsumerState<EnhancedProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
    final profileStatsAsync = ref.watch(unifiedStatisticsProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
          bottom: 120,
        ),
        child: profileStatsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading stats: $error'),
          ),
          data: (profileStats) => FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Profile Header
                SliverToBoxAdapter(
                  child: ProfileHeaderWidget(
                    profileStats: profileStats,
                    isDarkMode: isDarkMode,
                  ),
                ),

                // Stats Overview
                SliverToBoxAdapter(
                  child: StatisticsOverviewWidget(
                    profileStats: profileStats,
                    isDarkMode: isDarkMode,
                  ),
                ),

                // Difficulty Stats
                SliverToBoxAdapter(
                  child: DifficultyStatsWidget(
                    difficultyStats: profileStats.difficultyStats,
                    isDarkMode: isDarkMode,
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: MnemonicsSpacing.xxl),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
