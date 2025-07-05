import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/widgets/buttons.dart';
import '../../../../common/design/theme_provider.dart';
import '../../../home/providers.dart';
import '../screens/daily_goal_screen.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../home/domain/user_word_data.dart';
import '../../../home/infrastructure/user_word_data_repository.dart';
import '../../../home/domain/user_settings.dart';
import 'language_preferences_screen.dart';
import 'activity_log_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final userSettings = ref.watch(userSettingsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoSection(),
          const SizedBox(height: MnemonicsSpacing.xl),
          if (userSettings != null)
            _buildSettingsList(context, ref, themeMode, userSettings)
          else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: MnemonicsColors.cardShadow,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: MnemonicsColors.primaryGreen.withOpacity(0.1),
            child: const Icon(
              Icons.person_outline,
              size: 48,
              color: MnemonicsColors.primaryGreen,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          const Text(
            'John Doe',
            style: MnemonicsTypography.headingMedium,
          ),
          const SizedBox(height: MnemonicsSpacing.xs),
          Text(
            'Learning since March 2024',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: MnemonicsColors.textSecondary,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Words Learned', '120'),
        _buildDivider(),
        _buildStatItem('Daily Streak', '7'),
        _buildDivider(),
        _buildStatItem('Languages', '3'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: MnemonicsTypography.headingMedium.copyWith(
            color: MnemonicsColors.primaryGreen,
          ),
        ),
        Text(
          label,
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: MnemonicsColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: MnemonicsColors.surface,
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref, ThemeMode themeMode, UserSettings userSettings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: MnemonicsTypography.headingMedium,
        ),
        const SizedBox(height: MnemonicsSpacing.m),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
            boxShadow: MnemonicsColors.cardShadow,
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: Icons.timer,
                title: 'Daily Goal',
                subtitle: '${userSettings.dailyGoal} minutes',
                onTap: () async {
                  final newGoal = await _showEditGoalDialog(context, userSettings.dailyGoal);
                  if (newGoal != null) {
                    await ref.read(userSettingsProvider.notifier).updateDailyGoal(newGoal);
                  }
                },
              ),
              _buildSettingsDivider(),
              _buildSettingsItem(
                icon: Icons.repeat,
                title: 'Review Frequency',
                subtitle: '${userSettings.reviewFrequency} minutes/day',
                onTap: () async {
                  final newFreq = await _showEditGoalDialog(context, userSettings.reviewFrequency, label: 'Review frequency (minutes per day)');
                  if (newFreq != null) {
                    await ref.read(userSettingsProvider.notifier).updateReviewFrequency(newFreq);
                  }
                },
              ),
              _buildSettingsItem(
                icon: Icons.brightness_6,
                title: 'Theme Mode',
                subtitle: themeMode == ThemeMode.dark ? 'Dark' : 'Light',
                onTap: () {
                  ref.read(themeNotifierProvider.notifier).toggleTheme();
                },
              ),
              _buildSettingsDivider(),
              _buildSettingsItem(
                icon: Icons.file_download,
                title: 'Export Data',
                subtitle: 'Download your learning history',
                onTap: () async {
                  final repo = ref.read(userWordDataRepositoryProvider);
                  final allData = await repo.getAllUserWordData();
                  final jsonList = allData.map((e) => e.toJson()).toList();
                  final jsonString = jsonEncode(jsonList);
                  final dir = await getApplicationDocumentsDirectory();
                  final file = File('${dir.path}/mnemonics_export.json');
                  await file.writeAsString(jsonString);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to ${file.path}')),
                  );
                },
              ),
              _buildSettingsDivider(),
              _buildSettingsItem(
                icon: Icons.file_upload,
                title: 'Import Data',
                subtitle: 'Restore your learning history',
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
                  if (result != null && result.files.single.path != null) {
                    final file = File(result.files.single.path!);
                    final jsonString = await file.readAsString();
                    final List<dynamic> jsonList = jsonDecode(jsonString);
                    final repo = ref.read(userWordDataRepositoryProvider);
                    for (final item in jsonList) {
                      final data = UserWordData.fromJson(item);
                      await repo.saveOrUpdateUserWordData(data);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import successful')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import cancelled')),
                    );
                  }
                },
              ),
              _buildSettingsDivider(),
              _buildSettingsItem(
                icon: Icons.restore,
                title: 'Reset Progress',
                subtitle: 'Clear all learning data',
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Progress'),
                      content: const Text('Are you sure you want to clear all your learning data? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    final repo = ref.read(userWordDataRepositoryProvider);
                    final box = await Hive.openBox<UserWordData>(UserWordDataRepository.boxName);
                    await box.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Progress reset')),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                icon: Icons.language,
                title: 'Language Preferences',
                subtitle: userSettings.languageCodes.map((c) => c.toUpperCase()).join(', '),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LanguagePreferencesScreen()),
                  );
                },
              ),
              _buildSettingsItem(
                icon: Icons.history,
                title: 'Activity Log',
                subtitle: 'View your review history',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActivityLogScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(MnemonicsSpacing.m),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(MnemonicsSpacing.s),
              decoration: BoxDecoration(
                color: MnemonicsColors.surface,
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              ),
              child: Icon(
                icon,
                color: MnemonicsColors.primaryGreen,
              ),
            ),
            const SizedBox(width: MnemonicsSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MnemonicsTypography.bodyLarge,
                  ),
                  Text(
                    subtitle,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: MnemonicsColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: MnemonicsColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: MnemonicsColors.surface,
    );
  }

  Future<int?> _showEditGoalDialog(BuildContext context, int currentValue, {String label = 'Minutes per day'}) async {
    final controller = TextEditingController(text: currentValue.toString());
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 