import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';

class KnowledgeTreeWidget extends ConsumerStatefulWidget {
  final int totalLearned;
  final int daysSinceLastPractice;
  final int masteredCategoriesCount;
  final VoidCallback onTreeTapped;

  const KnowledgeTreeWidget({
    Key? key,
    required this.totalLearned,
    required this.daysSinceLastPractice,
    required this.masteredCategoriesCount,
    required this.onTreeTapped,
  }) : super(key: key);

  @override
  ConsumerState<KnowledgeTreeWidget> createState() =>
      _KnowledgeTreeWidgetState();
}

class _KnowledgeTreeWidgetState extends ConsumerState<KnowledgeTreeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _growthController;

  @override
  void initState() {
    super.initState();
    _growthController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _growthController.forward();
  }

  @override
  void didUpdateWidget(covariant KnowledgeTreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalLearned != widget.totalLearned ||
        oldWidget.daysSinceLastPractice != widget.daysSinceLastPractice ||
        oldWidget.masteredCategoriesCount != widget.masteredCategoriesCount) {
      _growthController.reset();
      _growthController.forward();
    }
  }

  @override
  void dispose() {
    _growthController.dispose();
    super.dispose();
  }

  // Calculate tree health (0.0 to 1.0) based on days missed
  double get _healthFactor {
    if (widget.daysSinceLastPractice <= 1) return 1.0; // Perfect health
    if (widget.daysSinceLastPractice >= 7) return 0.2; // Severely wilted
    // Linear scale between 2 and 7 days
    return 1.0 - ((widget.daysSinceLastPractice - 1) * 0.13);
  }

  // Calculate complexity (depth) based on total learned
  int get _treeDepth {
    if (widget.totalLearned == 0) return 1; // Seed (Just a stem)
    if (widget.totalLearned < 5) return 2; // Sprout
    if (widget.totalLearned < 15) return 3; // Sapling
    if (widget.totalLearned < 30) return 4; // Young tree
    if (widget.totalLearned < 60) return 5; // Mature tree
    if (widget.totalLearned < 100) return 6; // Dense tree
    return 7; // Ancient oak (max rendering depth usually 7-8 for performance)
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/knowledge-tree'),
      child: Container(
        padding: const EdgeInsets.all(MnemonicsSpacing.l),
        decoration: BoxDecoration(
          color: MnemonicsColors.surface,
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
          boxShadow: [
            BoxShadow(
              color: MnemonicsColors.primaryGreen.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Tree Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Knowledge Tree',
                        style: MnemonicsTypography.headingMedium,
                      ),
                      const SizedBox(height: MnemonicsSpacing.xs),
                      Text(
                        _getTreeStatusMessage(),
                        style: MnemonicsTypography.bodyRegular.copyWith(
                          color: _getHealthThemeColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: MnemonicsSpacing.m),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildLevelBadge(),
                    const SizedBox(height: MnemonicsSpacing.xs),
                    Text(
                      '${widget.totalLearned} Words',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: MnemonicsColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: MnemonicsSpacing.xl),

            // Canvas Drawing
            SizedBox(
              height: 250,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _growthController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: TreePainter(
                      depth: _treeDepth,
                      health: _healthFactor,
                      growthAnimation: CurvedAnimation(
                        parent: _growthController,
                        curve: Curves.elasticOut,
                      ).value,
                      masteryFruits: widget.masteredCategoriesCount,
                      seed: 42, // Consistent shape
                    ),
                  );
                },
              ),
            ),

            // Ground
            Container(
              height: 4,
              width: 120,
              decoration: BoxDecoration(
                color: MnemonicsColors.primaryGreen.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTreeStatusMessage() {
    if (widget.totalLearned == 0) return 'Plant a seed by learning words!';
    if (widget.daysSinceLastPractice == 0) return 'Thriving beautifully!';
    if (widget.daysSinceLastPractice == 1) return 'Looking healthy.';
    if (widget.daysSinceLastPractice < 4)
      return 'Leaves are looking a bit dry...';
    return 'Drooping! Needs practice watering!';
  }

  Color _getHealthThemeColor() {
    if (widget.daysSinceLastPractice < 2) return MnemonicsColors.primaryGreen;
    if (widget.daysSinceLastPractice < 5) return Colors.orange;
    return Colors.brown;
  }

  Widget _buildLevelBadge() {
    String levelName = 'Seed';
    if (widget.totalLearned >= 100)
      levelName = 'Oak';
    else if (widget.totalLearned >= 60)
      levelName = 'Dense Tree';
    else if (widget.totalLearned >= 30)
      levelName = 'Mature Tree';
    else if (widget.totalLearned >= 15)
      levelName = 'Young Tree';
    else if (widget.totalLearned >= 5)
      levelName = 'Sapling';
    else if (widget.totalLearned >= 1) levelName = 'Sprout';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getHealthThemeColor().withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getHealthThemeColor().withAlpha(100)),
      ),
      child: Text(
        levelName,
        style: MnemonicsTypography.bodyRegular.copyWith(
          color: _getHealthThemeColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class TreePainter extends CustomPainter {
  final int depth;
  final double health; // 0.0 (dead/brown) to 1.0 (vibrant green)
  final double growthAnimation; // 0.0 to 1.0
  final int masteryFruits;
  final int seed;

  TreePainter({
    required this.depth,
    required this.health,
    required this.growthAnimation,
    required this.masteryFruits,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);

    // Base colors
    final trunkColor = Color.lerp(
          const Color(0xFF6D4C41), // Healthy brown
          const Color(0xFF8D6E63), // Dry/Ashy brown
          1.0 - health,
        ) ??
        const Color(0xFF6D4C41);

    final leafColor = Color.lerp(
          const Color(0xFFD84315), // Very Wilted Orange/Brown
          MnemonicsColors.primaryGreen, // Vibrant Green
          health,
        ) ??
        MnemonicsColors.primaryGreen;

    final trunkPaint = Paint()
      ..color = trunkColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = leafColor.withAlpha((255 * health).clamp(150, 255).toInt())
      ..style = PaintingStyle.fill;

    // Start drawing from bottom center
    final startX = size.width / 2;
    final startY = size.height;

    // Base trunk length scales with overall growth animation and depth
    final heightScale = 0.5 + (depth / 7.0) * 0.5;
    final trunkLength = (size.height / 4.5) * growthAnimation * heightScale;

    int fruitsDrawn = 0;

    void drawBranch(
        double x, double y, double length, double angle, int currentDepth) {
      if (currentDepth == 0) {
        // Draw leaves at the tips
        if (health > 0.1) {
          canvas.drawCircle(Offset(x, y), length * 1.5, leafPaint);

          // Add some scatter leaves
          canvas.drawCircle(
            Offset(x + random.nextDouble() * 10 - 5,
                y + random.nextDouble() * 10 - 5),
            length,
            leafPaint,
          );
        }

        // Draw fruits (Mastered categories)
        if (fruitsDrawn < masteryFruits && random.nextDouble() > 0.7) {
          final fruitPaint = Paint()
            ..color = Colors.amberAccent
            ..style = PaintingStyle.fill;

          final glowPaint = Paint()
            ..color = Colors.amber.withAlpha(100)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

          canvas.drawCircle(Offset(x, y + 2), 6, glowPaint);
          canvas.drawCircle(Offset(x, y + 2), 4, fruitPaint);
          fruitsDrawn++;
        }
        return;
      }

      final endX = x + length * sin(angle);
      final endY = y - length * cos(angle);

      // Thicker trunk at bottom, thinner at top
      trunkPaint.strokeWidth = currentDepth * 1.5;

      canvas.drawLine(Offset(x, y), Offset(endX, endY), trunkPaint);

      // Recursive branching
      final numBranches =
          currentDepth == depth ? 1 : 2 + random.nextInt(2); // 2-3 branches

      for (int i = 0; i < numBranches; i++) {
        // Natural varied angles [-pi/4, pi/4]
        final angleOffset = (random.nextDouble() * pi / 2) - (pi / 4);
        // Branches get shorter
        final nextLength = length * (0.6 + random.nextDouble() * 0.2);

        drawBranch(
            endX, endY, nextLength, angle + angleOffset, currentDepth - 1);
      }
    }

    // Initiate drawing sequence
    if (growthAnimation > 0.01) {
      drawBranch(startX, startY, trunkLength, 0.0, depth);
    }
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.depth != depth ||
        oldDelegate.health != health ||
        oldDelegate.growthAnimation != growthAnimation ||
        oldDelegate.masteryFruits != masteryFruits;
  }
}
