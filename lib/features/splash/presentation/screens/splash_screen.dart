import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../../../common/widgets/buttons.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeInAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    _controller.reverse().then((_) {
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MnemonicsColors.background,
      body: Stack(
        children: [
          _buildWaveBackground(),
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
                      const Spacer(),
                      _buildLogo(),
                      const SizedBox(height: MnemonicsSpacing.xl),
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
                      const Spacer(),
                      Center(
                        child: _buildCTAButton(),
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
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        boxShadow: MnemonicsColors.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            bottom: 10,
            child: _buildSpeechBubble(
              "A",
              MnemonicsColors.primaryGreen,
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: _buildSpeechBubble(
              "文",
              MnemonicsColors.secondaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(String text, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      ),
      child: Center(
        child: Text(
          text,
          style: MnemonicsTypography.headingMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: MnemonicsColors.secondaryOrange,
        shape: BoxShape.circle,
      ),
      child: MnemonicsIconButton(
        icon: Icons.arrow_forward,
        color: Colors.white,
        onPressed: _navigateToHome,
      ),
    );
  }

  Widget _buildWaveBackground() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: CustomPaint(
        size: const Size(double.infinity, 300),
        painter: WavePainter(),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MnemonicsColors.primaryGreen.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..color = MnemonicsColors.primaryGreen.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.9);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.9,
    );
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height,
      size.width,
      size.height * 0.9,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 