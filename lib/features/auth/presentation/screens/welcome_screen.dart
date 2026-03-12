import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/widgets/animated_wave_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedWaveBackground(height: double.infinity),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(MnemonicsSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(MnemonicsSpacing.radiusXL),
                        boxShadow: MnemonicsColors.cardShadow,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Let's Break",
                        style: MnemonicsTypography.headingLarge,
                      ),
                      Text(
                        "THE BARRIERS OF LANGUAGE",
                        style: MnemonicsTypography.headingLarge.copyWith(
                          color: MnemonicsColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MnemonicsSpacing.xl),
                  Text(
                    "Join our community and master vocabulary with ease.",
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      color: MnemonicsColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.push('/signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MnemonicsColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor:
                            MnemonicsColors.primaryGreen.withOpacity(0.5),
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: MnemonicsSpacing.m),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => context.push('/login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MnemonicsColors.primaryGreen,
                        side: BorderSide(
                          color: MnemonicsColors.primaryGreen.withOpacity(0.5),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.9),
                      ),
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: MnemonicsSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
