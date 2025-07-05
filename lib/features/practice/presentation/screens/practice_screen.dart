import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/widgets/buttons.dart';
import '../../../../common/widgets/input_fields.dart';
import 'progress_overview_screen.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ProgressOverviewScreen();
  }

  Widget _buildQuestion() {
    return const Text(
      "What's the meaning of this sentence?",
      style: MnemonicsTypography.bodyLarge,
    );
  }

  Widget _buildSpanishText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: MnemonicsColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '¡Hola! ¿Cómo estás?',
                  style: MnemonicsTypography.headingMedium,
                ),
              ),
              MnemonicsIconButton(
                icon: Icons.volume_up,
                color: MnemonicsColors.primaryGreen,
                onPressed: () {
                  // TODO: Implement audio playback
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Answer',
          style: MnemonicsTypography.bodyLarge,
        ),
        const SizedBox(height: MnemonicsSpacing.s),
        MnemonicsTextField(
          hint: 'Type your translation here',
          controller: TextEditingController(text: 'Hello! How are you?'),
        ),
      ],
    );
  }

  Widget _buildKeyboardArea() {
    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: MnemonicsColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLanguageButton('English', true),
              _buildLanguageButton('Spanish', false),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          // TODO: Implement custom keyboard layout
        ],
      ),
    );
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

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: MnemonicsButton(
        text: 'Continue',
        onPressed: () {
          // TODO: Handle continue action
        },
      ),
    );
  }
} 