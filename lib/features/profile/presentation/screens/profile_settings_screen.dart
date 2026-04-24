import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../../common/design/design_system.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../home/providers.dart';
import '../../../home/infrastructure/user_word_data_repository.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/infrastructure/auth_repository.dart';
import '../../../auth/domain/user_profile.dart';
import '../../providers/unified_statistics_provider.dart';
import '../widgets/profile_settings_widget.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSettings = ref.watch(userSettingsProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Add spacing for the blurred AppBar
          SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
          
          if (userSettings != null)
            ProfileSettingsWidget(
              userSettings: userSettings,
              // If profile is loading or has error, we still show settings but without the profile-dependent parts
              userProfile: userProfileAsync.maybeWhen(
                data: (profile) => profile,
                orElse: () => null,
              ),
              themeMode: themeMode,
              isDarkMode: isDarkMode,
              onSettingChanged: (key, value) =>
                  _handleSettingChange(context, ref, key, value),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(MnemonicsSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            ),

          // If there was an error loading the profile (e.g. 404), show a small hint instead of blocking the whole screen
          if (userProfileAsync is AsyncError)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.m),
              child: Text(
                'Note: Some cloud settings are unavailable (new account or network issue).',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MnemonicsSpacing.m, vertical: MnemonicsSpacing.s),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? MnemonicsColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                border: isDarkMode ? Border.all(color: MnemonicsColors.darkBorder.withOpacity(0.3)) : null,
              ),
              child: TextButton.icon(
                onPressed: () => _handleLogout(context, ref),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: MnemonicsSpacing.l),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  void _handleSettingChange(
    BuildContext context,
    WidgetRef ref,
    String key,
    dynamic value,
  ) {
    switch (key) {
      case 'dailyGoal':
        final settings = ref.read(userSettingsProvider);
        if (settings != null) {
          settings.dailyGoal = value as int;
          ref.read(userSettingsProvider.notifier).saveSettings(settings);
        }
        break;
      case 'reviewFrequency':
        final settings = ref.read(userSettingsProvider);
        if (settings != null) {
          settings.reviewFrequency = value as int;
          ref.read(userSettingsProvider.notifier).saveSettings(settings);
        }
        break;
      case 'theme':
        ref.read(themeNotifierProvider.notifier).setThemeMode(value as ThemeMode);
        break;
      case 'resetProgress':
        _handleProgressReset(context, ref);
        break;
      case 'toggleWordSet':
        if (value is String) {
          _handleWordSetToggle(ref, value);
        }
        break;
      case 'toggleLevel':
        if (value is int) {
          _handleLevelToggle(ref, value);
        }
        break;
      case 'restartOnboarding':
        context.push('/onboarding');
        break;
    }
  }

  Future<void> _handleLevelToggle(WidgetRef ref, int level) async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) return;

    final currentLevels = profile.vocabularyLevel.split(',')
        .map((s) => int.tryParse(s.trim()))
        .where((l) => l != null)
        .cast<int>()
        .toSet();

    if (currentLevels.contains(level)) {
      if (currentLevels.length > 1) {
        currentLevels.remove(level);
      }
    } else {
      currentLevels.add(level);
    }

    final sortedLevels = currentLevels.toList()..sort();
    final updatedProfile = profile.copyWith(vocabularyLevel: sortedLevels.join(','));
    await ref.read(userProfileProvider.notifier).updateProfile(updatedProfile);
    ref.invalidate(vocabularyListProvider);
    ref.invalidate(settingsSummaryProvider);
  }

  Future<void> _handleWordSetToggle(WidgetRef ref, String setId) async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) return;

    final currentSets =
        profile.enabledWordSets.split(',').where((s) => s.isNotEmpty).toSet();
    if (currentSets.contains(setId)) {
      currentSets.remove(setId);
    } else {
      currentSets.add(setId);
    }

    final updatedProfile =
        profile.copyWith(enabledWordSets: currentSets.join(','));
    await ref.read(userProfileProvider.notifier).updateProfile(updatedProfile);
    ref.invalidate(vocabularyListProvider);
    ref.invalidate(settingsSummaryProvider);
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) {
        context.go('/welcome');
      }
    }
  }

  Future<void> _handleProgressReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
            'This will clear all your learned words and statistics. This action cannot be undone.'),
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
        final userId = ref.read(authRepositoryProvider).currentUser?.uid ?? 'default';
        await http.delete(Uri.parse('https://mnemonics-api-1078980357394.us-central1.run.app/reset/$userId'));
        
        await ref.read(userWordDataRepositoryProvider).clearAllData();
        await ref.read(reviewActivityRepositoryProvider).clearAllData();
        
        await Hive.deleteBoxFromDisk('user_word_data');
        await Hive.deleteBoxFromDisk('user_settings');
        await Hive.deleteBoxFromDisk('review_activity');
        await Hive.deleteBoxFromDisk('user_statistics');

        ref.invalidate(unifiedStatisticsProvider);
        ref.invalidate(vocabularyListProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Progress reset successful'),
              backgroundColor: MnemonicsColors.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reset failed: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
