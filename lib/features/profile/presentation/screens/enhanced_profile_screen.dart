import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../home/providers.dart';
import '../../../home/infrastructure/user_word_data_repository.dart';
import '../../providers/unified_statistics_provider.dart';
import '../../domain/user_statistics.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/statistics_overview_widget.dart';
import '../widgets/achievements_widget.dart';
import '../widgets/learning_insights_widget.dart';
import '../widgets/profile_settings_widget.dart';
import '../widgets/difficulty_stats_widget.dart';
import 'dart:io';
import '../../../../common/widgets/animated_wave_background.dart';

class EnhancedProfileScreen extends ConsumerStatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  ConsumerState<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
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
    final userSettings = ref.watch(userSettingsProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        AnimatedWaveBackground(height: screenHeight),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: profileStatsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                  ),
                  const SizedBox(height: MnemonicsSpacing.m),
                  Text(
                    'Unable to load profile data',
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: MnemonicsSpacing.s),
                  Text(
                    error.toString(),
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: isDarkMode ? MnemonicsColors.darkTextSecondary : MnemonicsColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            data: (profileStats) => FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // Profile Header with Statistics
                  SliverToBoxAdapter(
                    child: ProfileHeaderWidget(
                      profileStats: profileStats,
                      isDarkMode: isDarkMode,
                    ),
                  ),

                  // Quick Stats Overview
                  SliverToBoxAdapter(
                    child: StatisticsOverviewWidget(
                      profileStats: profileStats,
                      isDarkMode: isDarkMode,
                    ),
                  ),

                  // Achievements Section
                  SliverToBoxAdapter(
                    child: AchievementsWidget(
                      milestones: profileStats.milestones,
                      isDarkMode: isDarkMode,
                    ),
                  ),

                  // Learning Insights
                  SliverToBoxAdapter(
                    child: LearningInsightsWidget(
                      profileStats: profileStats,
                      isDarkMode: isDarkMode,
                    ),
                  ),

                  // Difficulty Statistics
                  SliverToBoxAdapter(
                    child: DifficultyStatsWidget(
                      difficultyStats: profileStats.difficultyStats,
                      isDarkMode: isDarkMode,
                    ),
                  ),

                  // Settings Section
                  if (userSettings != null)
                    SliverToBoxAdapter(
                      child: ProfileSettingsWidget(
                        userSettings: userSettings,
                        themeMode: themeMode,
                        isDarkMode: isDarkMode,
                        onSettingChanged: (key, value) => _handleSettingChange(key, value),
                      ),
                    )
                  else
                    const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: MnemonicsSpacing.xl),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSettingChange(String key, dynamic value) {
    switch (key) {
      case 'theme':
        ref.read(themeNotifierProvider.notifier).toggleTheme();
        break;
      case 'dailyGoal':
        if (value is int) {
          ref.read(userSettingsProvider.notifier).updateDailyGoal(value);
        }
        break;
      case 'reviewFrequency':
        if (value is int) {
          ref.read(userSettingsProvider.notifier).updateReviewFrequency(value);
        }
        break;
      case 'exportData':
        _handleDataExport();
        break;
      case 'importData':
        _handleDataImport();
        break;
      case 'resetProgress':
        _handleProgressReset();
        break;
    }
  }

  Future<void> _handleDataExport() async {
    try {
      final repo = ref.read(userWordDataRepositoryProvider);
      final allData = await repo.getAllUserWordData();
      
      // Create export data with timestamp
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'userData': allData.map((e) => e.toJson()).toList(),
      };
      
      // For now, just show success message
      // In a real app, you would use file_picker or share_plus to save/share the file
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data export prepared successfully'),
            backgroundColor: MnemonicsColors.primaryGreen,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Show export data preview
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Export Data'),
                    content: Text('${allData.length} words exported'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDataImport() async {
    // For now, just show a placeholder dialog
    // In a real app, you would use file_picker to select a JSON file
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data'),
          content: const Text('Data import feature will be available soon.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleProgressReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset all your learning progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resetting progress...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Clear user word data
        final userWordRepo = ref.read(userWordDataRepositoryProvider);
        await userWordRepo.clearAllData();
        
        // Clear review activities
        final reviewRepo = ref.read(reviewActivityRepositoryProvider);
        await reviewRepo.clearAllData();
        
        // Reset user settings to defaults
        final userSettingsNotifier = ref.read(userSettingsProvider.notifier);
        await userSettingsNotifier.updateDailyGoal(10); // Default goal
        await userSettingsNotifier.updateLanguages(['en']); // Default language
        await userSettingsNotifier.updateReviewFrequency(1); // Default frequency
        
        // Invalidate all providers to refresh UI state
        ref.invalidate(allUserWordDataProvider);
        ref.invalidate(reviewActivityListProvider);
        ref.invalidate(unifiedStatisticsProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ All learning progress has been reset successfully'),
              backgroundColor: MnemonicsColors.primaryGreen,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        String errorMessage = 'Reset failed';
        if (e.toString().contains('HiveError')) {
          errorMessage = 'Database error occurred during reset';
        } else if (e.toString().contains('Permission')) {
          errorMessage = 'Permission denied - unable to clear data';
        } else {
          errorMessage = 'Reset failed: ${e.toString()}';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _handleProgressReset(),
              ),
            ),
          );
        }
      }
    }
  }
}