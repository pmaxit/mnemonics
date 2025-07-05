import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/widgets/buttons.dart';
import '../../../home/providers.dart';
import '../../../home/domain/user_settings.dart';

class Language {
  final String code;
  final String name;
  final String flag;
  bool isSelected;

  Language({
    required this.code,
    required this.name,
    required this.flag,
    this.isSelected = false,
  });
}

class LanguagePreferencesScreen extends ConsumerStatefulWidget {
  const LanguagePreferencesScreen({super.key});

  @override
  ConsumerState<LanguagePreferencesScreen> createState() => _LanguagePreferencesScreenState();
}

class _LanguagePreferencesScreenState extends ConsumerState<LanguagePreferencesScreen> {
  late List<Language> _languages;

  @override
  void initState() {
    super.initState();
    final userSettings = ref.read(userSettingsProvider);
    _languages = [
      Language(code: 'en', name: 'English', flag: '🇺🇸'),
      Language(code: 'es', name: 'Spanish', flag: '🇪🇸'),
      Language(code: 'tr', name: 'Turkish', flag: '🇹🇷'),
      Language(code: 'fr', name: 'French', flag: '🇫🇷'),
      Language(code: 'de', name: 'German', flag: '🇩🇪'),
      Language(code: 'it', name: 'Italian', flag: '🇮🇹'),
      Language(code: 'pt', name: 'Portuguese', flag: '🇵🇹'),
      Language(code: 'ru', name: 'Russian', flag: '🇷🇺'),
      Language(code: 'zh', name: 'Chinese', flag: '🇨🇳'),
      Language(code: 'ja', name: 'Japanese', flag: '🇯🇵'),
    ];
    if (userSettings != null) {
      for (final lang in _languages) {
        lang.isSelected = userSettings.languageCodes.contains(lang.code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MnemonicsColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: MnemonicsColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Language Preferences',
          style: MnemonicsTypography.headingMedium,
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(MnemonicsSpacing.m),
            child: Text(
              'Select the languages you want to learn',
              style: MnemonicsTypography.bodyLarge,
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: MnemonicsSpacing.m,
                vertical: MnemonicsSpacing.s,
              ),
              itemCount: _languages.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final List<Language> newList = List.from(_languages);
                  final item = newList.removeAt(oldIndex);
                  newList.insert(newIndex, item);
                  _languages = newList;
                });
              },
              itemBuilder: (context, index) {
                final language = _languages[index];
                return _buildLanguageItem(
                  key: ValueKey(language.code),
                  language: language,
                  onToggle: (value) {
                    setState(() {
                      _languages[index] = Language(
                        code: language.code,
                        name: language.name,
                        flag: language.flag,
                        isSelected: value,
                      );
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(MnemonicsSpacing.m),
            child: Column(
              children: [
                Text(
                  'Drag to reorder languages based on your priority',
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    color: MnemonicsColors.textSecondary,
                  ),
                ),
                const SizedBox(height: MnemonicsSpacing.m),
                SizedBox(
                  width: double.infinity,
                  child: Consumer(
                    builder: (context, ref, _) => MnemonicsButton(
                      text: 'Save Preferences',
                      onPressed: () async {
                        final selectedCodes = _languages.where((l) => l.isSelected).map((l) => l.code).toList();
                        await ref.read(userSettingsProvider.notifier).updateLanguages(selectedCodes);
                        Navigator.pop(context);
                      },
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

  Widget _buildLanguageItem({
    required Key key,
    required Language language,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: MnemonicsSpacing.s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        boxShadow: MnemonicsColors.cardShadow,
      ),
      child: ListTile(
        leading: Text(
          language.flag,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          language.name,
          style: MnemonicsTypography.bodyLarge,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: language.isSelected,
              onChanged: onToggle,
              activeColor: MnemonicsColors.primaryGreen,
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
} 