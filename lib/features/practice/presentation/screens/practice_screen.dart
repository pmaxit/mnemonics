import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import 'progress_overview_screen.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ProgressOverviewScreen();
  }





  Widget _buildLanguageButton(String language, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MnemonicsSpacing.m,
        vertical: MnemonicsSpacing.s,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? MnemonicsColors.primaryGreen
            : MnemonicsColors.surface,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      ),
      child: Text(
        language,
        style: MnemonicsTypography.bodyRegular.copyWith(
          color: isActive ? Colors.white : MnemonicsColors.textSecondary,
        ),
      ),
    );
  }

} 