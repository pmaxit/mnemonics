import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/widgets/buttons.dart';

final dailyGoalProvider = StateProvider<int>((ref) => 60); // Default 60 minutes

class DailyGoalScreen extends ConsumerWidget {
  const DailyGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMinutes = ref.watch(dailyGoalProvider);

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
          'Daily Goal',
          style: MnemonicsTypography.headingMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(MnemonicsSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How much time would you like to spend learning each day?',
              style: MnemonicsTypography.bodyLarge,
            ),
            const SizedBox(height: MnemonicsSpacing.xl),
            _buildTimeSelector(ref, selectedMinutes),
            const SizedBox(height: MnemonicsSpacing.xl),
            _buildMotivationalMessage(selectedMinutes),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: MnemonicsButton(
                text: 'Save Goal',
                onPressed: () {
                  // TODO: Save goal to storage
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(WidgetRef ref, int selectedMinutes) {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedMinutes.toString(),
                style: MnemonicsTypography.headingLarge.copyWith(
                  color: MnemonicsColors.primaryGreen,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              const Text(
                'minutes',
                style: MnemonicsTypography.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: MnemonicsSpacing.m),
          Slider(
            value: selectedMinutes.toDouble(),
            min: 15,
            max: 120,
            divisions: 7,
            activeColor: MnemonicsColors.primaryGreen,
            inactiveColor: MnemonicsColors.surface,
            onChanged: (value) {
              ref.read(dailyGoalProvider.notifier).state = value.round();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '15 min',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: MnemonicsColors.textSecondary,
                ),
              ),
              Text(
                '120 min',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: MnemonicsColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalMessage(int minutes) {
    String message;
    if (minutes <= 30) {
      message = 'A great start! Even short practice sessions can make a difference.';
    } else if (minutes <= 60) {
      message = 'Perfect balance! This goal will help you make steady progress.';
    } else {
      message = 'Ambitious goal! Your dedication will lead to faster progress.';
    }

    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: MnemonicsColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: MnemonicsColors.primaryGreen,
          ),
          const SizedBox(width: MnemonicsSpacing.m),
          Expanded(
            child: Text(
              message,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: MnemonicsColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 