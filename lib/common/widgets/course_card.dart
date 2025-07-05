import 'package:flutter/material.dart';
import '../design/design_system.dart';

class CourseCard extends StatelessWidget {
  final String languageName;
  final double progressPercentage;
  final Color progressColor;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.languageName,
    required this.progressPercentage,
    required this.progressColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          boxShadow: MnemonicsColors.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: MnemonicsSpacing.m),
              Text(
                languageName,
                style: MnemonicsTypography.bodyLarge.copyWith(
                  height: 1.2, // Reduce line height
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: MnemonicsSpacing.xs),
              Text(
                '${(100 - progressPercentage).toInt()}% remaining',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: MnemonicsColors.textSecondary,
                  height: 1.2, // Reduce line height
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      height: 48,
      width: 48,
      child: CustomPaint(
        painter: CircularProgressPainter(
          backgroundColor: MnemonicsColors.surface,
          progressColor: progressColor,
          progress: progressPercentage / 100,
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final Color backgroundColor;
  final Color progressColor;
  final double progress;
  final double strokeWidth;

  CircularProgressPainter({
    required this.backgroundColor,
    required this.progressColor,
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start from top (-90 degrees)
      progress * 2 * 3.14159, // Convert progress to radians
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
} 