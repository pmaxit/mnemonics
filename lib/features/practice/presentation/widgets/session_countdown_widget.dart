import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';

class SessionCountdownWidget extends StatelessWidget {
  final int countdownSeconds;

  const SessionCountdownWidget({
    super.key,
    required this.countdownSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main countdown circle
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Transform.scale(
                scale: 0.5 + (0.5 * animation),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MnemonicsColors.primaryGreen,
                        MnemonicsColors.primaryGreen.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MnemonicsColors.primaryGreen.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      countdownSeconds.toString(),
                      style: MnemonicsTypography.headingLarge.copyWith(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: MnemonicsSpacing.xl),

          // Get ready message
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Opacity(
                opacity: animation,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - animation)),
                  child: Column(
                    children: [
                      Text(
                        'Get Ready!',
                        style: MnemonicsTypography.headingMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MnemonicsColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: MnemonicsSpacing.s),
                      Text(
                        'Your learning session is about to begin',
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: MnemonicsColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: MnemonicsSpacing.xl),

          // Animated progress indicator
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: MnemonicsColors.textSecondary.withOpacity(0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animation,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(
                        colors: [
                          MnemonicsColors.primaryGreen,
                          MnemonicsColors.secondaryOrange,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
