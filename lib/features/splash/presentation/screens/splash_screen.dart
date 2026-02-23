import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/widgets/animated_wave_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _flyInController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeInAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<Offset> _buttonSlideAnimation;
  late final Animation<double> _buttonPulseAnimation;

  @override
  void initState() {
    super.initState();
    _flyInController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _flyInController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _flyInController,
      curve: Curves.easeOutCubic,
    ));

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _flyInController,
      curve: Curves.easeOutBack,
    ));

    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _flyInController.forward().then((_) {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _flyInController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    _pulseController.stop();
    _flyInController.reverse().then((_) {
      context.go('/main/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Use the animated background for consistency
          const Positioned.fill(
            child: AnimatedWaveBackground(height: double.infinity),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(MnemonicsSpacing.xl),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      Center(child: _buildLogo()),
                      const Spacer(),
                      // Text fly-in
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
                      const Spacer(),
                      // Button fly-in and pulse
                      Center(
                        child: SlideTransition(
                          position: _buttonSlideAnimation,
                          child: ScaleTransition(
                            scale: _buttonPulseAnimation,
                            child: _Animated3DCTAButton(
                              onPressed: _navigateToHome,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: MnemonicsSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: MnemonicsColors.cardShadow,
        image: const DecorationImage(
          image: AssetImage('assets/images/logo.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Replace _buildCTAButton with the new animated 3D button widget
}

class _Animated3DCTAButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _Animated3DCTAButton({required this.onPressed});

  @override
  State<_Animated3DCTAButton> createState() => _Animated3DCTAButtonState();
}

class _Animated3DCTAButtonState extends State<_Animated3DCTAButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.92;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFB75E), // light orange
                Color(0xFFF57C00), // deeper orange
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                blurRadius: 8,
                offset: const Offset(-2, -2),
                spreadRadius: -4,
              ),
            ],
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gloss highlight
              Positioned(
                top: 12,
                left: 18,
                right: 18,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.55),
                        Colors.white.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 36,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
