import 'package:flutter/material.dart';
import '../design/design_system.dart';

class AnimatedWaveBackground extends StatefulWidget {
  final double height;
  const AnimatedWaveBackground({Key? key, this.height = 300}) : super(key: key);

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: widget.height,
          child: Stack(
            children: [
              // Light gradient background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF8F9FA), // very light gray
                      Color(0xFFE3F6F5), // very light green/blue
                    ],
                  ),
                ),
              ),
              // Waves
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, widget.height),
                painter: _WavePainter(_controller.value),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  _WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFFB2DFDB).withOpacity(0.30) // light teal
      ..style = PaintingStyle.fill;
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.60)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    final waveHeight = 24.0 + 12.0 * animationValue;
    path1.moveTo(0, size.height * 0.8);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.7 - waveHeight,
      size.width * 0.5,
      size.height * 0.8 + waveHeight,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.9 - waveHeight,
      size.width,
      size.height * 0.8,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    final path2 = Path();
    final offset = 32.0 * animationValue;
    path2.moveTo(0, size.height * 0.9);
    path2.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.8 + offset,
      size.width * 0.5,
      size.height * 0.9 - offset,
    );
    path2.quadraticBezierTo(
      size.width * 0.75,
      size.height + offset,
      size.width,
      size.height * 0.9,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => oldDelegate.animationValue != animationValue;
} 