import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../../../home/domain/user_settings.dart';

class ProfileSettingsWidget extends StatelessWidget {
  final UserSettings userSettings;
  final ThemeMode themeMode;
  final bool isDarkMode;
  final Function(String key, dynamic value) onSettingChanged;

  const ProfileSettingsWidget({
    super.key,
    required this.userSettings,
    required this.themeMode,
    required this.isDarkMode,
    required this.onSettingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode 
        ? MnemonicsColors.darkSurface 
        : Colors.white;
    final textColor = isDarkMode 
        ? MnemonicsColors.darkTextPrimary 
        : MnemonicsColors.textPrimary;
    final secondaryTextColor = isDarkMode 
        ? MnemonicsColors.darkTextSecondary 
        : MnemonicsColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: MnemonicsSpacing.m,
        vertical: MnemonicsSpacing.s,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(MnemonicsSpacing.m),
            child: Text(
              'Settings',
              style: MnemonicsTypography.headingMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Learning Preferences
          _buildSettingsSection(
            'Learning Preferences',
            [
              _buildSettingItem(
                icon: Icons.timer,
                title: 'Daily Goal',
                subtitle: '${userSettings.dailyGoal} minutes',
                onTap: () => _showDailyGoalDialog(context),
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildSettingItem(
                icon: Icons.repeat,
                title: 'Review Frequency',
                subtitle: '${userSettings.reviewFrequency} minutes/day',
                onTap: () => _showReviewFrequencyDialog(context),
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
            textColor,
          ),
          
          // Appearance
          _buildSettingsSection(
            'Appearance',
            [
              _buildSettingItem(
                icon: Icons.brightness_6,
                title: 'Theme',
                subtitle: _getThemeDisplayName(themeMode),
                onTap: () => _showThemeDialog(context),
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
            textColor,
          ),
          
          // Data Management
          _buildSettingsSection(
            'Data Management',
            [
              _buildSettingItem(
                icon: Icons.file_download,
                title: 'Export Data',
                subtitle: 'Download your learning history',
                onTap: () => onSettingChanged('exportData', null),
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildSettingItem(
                icon: Icons.file_upload,
                title: 'Import Data',
                subtitle: 'Restore your learning history',
                onTap: () => onSettingChanged('importData', null),
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
            textColor,
          ),
          
          // Advanced
          _buildSettingsSection(
            'Advanced',
            [
              _buildSettingItem(
                icon: Icons.restore,
                title: 'Reset Progress',
                subtitle: 'Clear all learning data',
                onTap: () => onSettingChanged('resetProgress', null),
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                isDestructive: true,
              ),
            ],
            textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    List<Widget> items,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MnemonicsSpacing.m,
            vertical: MnemonicsSpacing.s,
          ),
          child: Text(
            title,
            style: MnemonicsTypography.bodyLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: MnemonicsSpacing.s),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textColor,
    required Color secondaryTextColor,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(MnemonicsSpacing.m),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(MnemonicsSpacing.s),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? Colors.red.withOpacity(0.1)
                    : (isDarkMode ? MnemonicsColors.darkBorder : MnemonicsColors.surface),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              ),
              child: Icon(
                icon,
                color: isDestructive 
                    ? Colors.red 
                    : MnemonicsColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: MnemonicsSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      color: isDestructive ? Colors.red : textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: MnemonicsSpacing.xs),
                  Text(
                    subtitle,
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _GoalDialog(
        title: 'Daily Goal',
        currentValue: userSettings.dailyGoal,
        onChanged: (value) => onSettingChanged('dailyGoal', value),
      ),
    );
  }

  void _showReviewFrequencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _GoalDialog(
        title: 'Review Frequency',
        currentValue: userSettings.reviewFrequency,
        onChanged: (value) => onSettingChanged('reviewFrequency', value),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_7),
              title: const Text('Light'),
              onTap: () {
                Navigator.pop(context);
                if (themeMode != ThemeMode.light) {
                  onSettingChanged('theme', ThemeMode.light);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_4),
              title: const Text('Dark'),
              onTap: () {
                Navigator.pop(context);
                if (themeMode != ThemeMode.dark) {
                  onSettingChanged('theme', ThemeMode.dark);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System'),
              onTap: () {
                Navigator.pop(context);
                if (themeMode != ThemeMode.system) {
                  onSettingChanged('theme', ThemeMode.system);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

class _GoalDialog extends StatefulWidget {
  final String title;
  final int currentValue;
  final Function(int) onChanged;

  const _GoalDialog({
    required this.title,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Minutes',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final value = int.tryParse(_controller.text);
            if (value != null && value > 0) {
              widget.onChanged(value);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}