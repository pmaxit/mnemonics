import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedProgressUtils {
  // Animation durations based on psychology principles
  static const Duration microInteraction = Duration(milliseconds: 200);
  static const Duration pageTransition = Duration(milliseconds: 400);
  static const Duration dataAnimation = Duration(milliseconds: 800);
  static const Duration celebration = Duration(milliseconds: 1500);

  // Easing curves for different contexts
  static const Curve entryEasing = Curves.easeOutCubic;
  static const Curve exitEasing = Curves.easeInCubic;
  static const Curve interactionEasing = Curves.easeInOutCubic;
  static const Curve celebrationEasing = Curves.elasticOut;

  // Shadow configurations
  static List<BoxShadow> restingShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> hoverShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> achievementShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // Particle animation for celebrations
  static Widget buildParticleEffect({
    required Animation<double> animation,
    required Color color,
    int particleCount = 20,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            animation: animation,
            color: color,
            particleCount: particleCount,
          ),
        );
      },
    );
  }

  // Shimmer effect for loading states
  static Widget buildShimmerEffect({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                0.0,
                animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }

  // Pulsing animation for achievements
  static Widget buildPulsingWidget({
    required Widget child,
    required Animation<double> animation,
    Color? glowColor,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final scale = 1.0 + (animation.value * 0.1);
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: glowColor != null
                ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity(animation.value * 0.3),
                        blurRadius: animation.value * 20,
                        spreadRadius: animation.value * 2,
                      ),
                    ],
                  )
                : null,
            child: child,
          ),
        );
      },
    );
  }

  // Staggered animation for list items
  static Widget buildStaggeredAnimation({
    required Widget child,
    required Animation<double> animation,
    required int index,
    int totalItems = 1,
  }) {
    final itemDelay = (index / totalItems).clamp(0.0, 0.8); // Max delay of 0.8
    final itemEnd =
        (itemDelay + 0.4).clamp(0.0, 1.0); // Ensure it doesn't exceed 1.0

    final staggeredAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(
          itemDelay,
          itemEnd,
          curve: entryEasing,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: staggeredAnimation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset.zero, // Disabled slide animation
          child: Opacity(
            opacity: staggeredAnimation.value,
            child: child,
          ),
        );
      },
    );
  }

  // Count-up animation for numbers
  static Widget buildCountUpAnimation({
    required Animation<double> animation,
    required int targetValue,
    required TextStyle style,
    String? suffix,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final currentValue = (targetValue * animation.value).round();
        return Text(
          '$currentValue${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}

// Custom painter for particle effects
class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final int particleCount;

  ParticlePainter({
    required this.animation,
    required this.color,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent animation

    for (int i = 0; i < particleCount; i++) {
      final progress = animation.value;
      final particleProgress =
          (progress * 2 - i / particleCount).clamp(0.0, 1.0);

      if (particleProgress <= 0) continue;

      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;

      final endX = startX + (random.nextDouble() - 0.5) * 100;
      final endY = startY - random.nextDouble() * 150;

      final currentX = startX + (endX - startX) * particleProgress;
      final currentY = startY + (endY - startY) * particleProgress;

      final opacity = (1.0 - particleProgress).clamp(0.0, 1.0);
      final particleSize = 3.0 * (1.0 - particleProgress);

      paint.color = color.withOpacity(opacity * 0.7);
      canvas.drawCircle(
        Offset(currentX, currentY),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Achievement celebration widget
class AchievementCelebration extends StatefulWidget {
  final Widget child;
  final bool shouldCelebrate;
  final Color celebrationColor;

  const AchievementCelebration({
    super.key,
    required this.child,
    required this.shouldCelebrate,
    this.celebrationColor = Colors.amber,
  });

  @override
  State<AchievementCelebration> createState() => _AchievementCelebrationState();
}

class _AchievementCelebrationState extends State<AchievementCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimatedProgressUtils.celebration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void didUpdateWidget(AchievementCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldCelebrate && !oldWidget.shouldCelebrate) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            );
          },
        ),
        if (widget.shouldCelebrate)
          Positioned.fill(
            child: AnimatedProgressUtils.buildParticleEffect(
              animation: _particleAnimation,
              color: widget.celebrationColor,
            ),
          ),
      ],
    );
  }
}
