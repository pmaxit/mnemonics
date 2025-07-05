import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.timer, size: 64, color: MnemonicsColors.primaryGreen),
          SizedBox(height: MnemonicsSpacing.l),
          Text('Timer coming soon', style: MnemonicsTypography.headingMedium),
        ],
      ),
    );
  }
} 