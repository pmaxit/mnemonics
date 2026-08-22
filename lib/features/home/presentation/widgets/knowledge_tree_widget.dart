import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/design/design_system.dart';
import '../../providers.dart';

/// One branch of the knowledge tree — a group of learned words that share a
/// common meaning (vocabulary category). The branch grows with the number of
/// words the user has learned in that category.
class TreeBranchSpec {
  final String category;
  final int wordCount;
  final Color color;

  const TreeBranchSpec({
    required this.category,
    required this.wordCount,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      other is TreeBranchSpec &&
      other.category == category &&
      other.wordCount == wordCount;

  @override
  int get hashCode => Object.hash(category, wordCount);
}

/// Stable colours per meaning category (mirrors the home set accents), with a
/// hashed fallback palette for unknown categories.
const Map<String, Color> _categoryColors = {
  'character': Color(0xFF26A69A),
  'speech': Color(0xFF5C6BC0),
  'intellect': Color(0xFF7E57C2),
  'conflict': Color(0xFFEF5350),
  'morality': Color(0xFF66BB6A),
  'change': Color(0xFF26C6DA),
  'academic': Color(0xFF4CAF50),
  'common': Color(0xFFFFA726),
};

const List<Color> _fallbackPalette = [
  Color(0xFF4CAF50),
  Color(0xFFE91E63),
  Color(0xFFFF7043),
  Color(0xFF42A5F5),
  Color(0xFFAB47BC),
  Color(0xFF26C6DA),
];

Color colorForCategory(String category) {
  final hit = _categoryColors[category.toLowerCase()];
  if (hit != null) return hit;
  final hash = category.codeUnits.fold<int>(0, (a, b) => a + b);
  return _fallbackPalette[hash % _fallbackPalette.length];
}

/// Groups the user's learned words by their common meaning (vocabulary
/// category) and returns one branch spec per meaning group, biggest first.
List<TreeBranchSpec> buildTreeBranches({
  required List<String> learnedWords,
  required Map<String, String> wordToCategory,
}) {
  final counts = <String, int>{};
  for (final word in learnedWords) {
    final category = wordToCategory[word] ?? 'General';
    counts[category] = (counts[category] ?? 0) + 1;
  }
  final branches = counts.entries
      .map((e) => TreeBranchSpec(
            category: e.key,
            wordCount: e.value,
            color: colorForCategory(e.key),
          ))
      .toList()
    ..sort((a, b) {
      final byCount = b.wordCount.compareTo(a.wordCount);
      if (byCount != 0) return byCount;
      return a.category.compareTo(b.category);
    });
  return branches;
}

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
    return 7; // Ancient oak
  }

  @override
  Widget build(BuildContext context) {
    // Build semantic branches from what the user actually learned.
    final vocabAsync = ref.watch(vocabularyListProvider);
    final userDataAsync = ref.watch(allUserWordDataProvider);

    List<TreeBranchSpec> branches = const [];
    final vocab = vocabAsync.asData?.value;
    final userData = userDataAsync.asData?.value;
    if (vocab != null && userData != null) {
      final wordToCategory = {for (final w in vocab) w.word: w.category};
      final learned = userData
          .where((d) => d.isLearned || d.hasBeenTested || d.reviewCount > 0)
          .map((d) => d.word)
          .toList();
      branches = buildTreeBranches(
        learnedWords: learned,
        wordToCategory: wordToCategory,
      );
    }

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
                        _getTreeStatusMessage(branches),
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

            // Canvas Drawing — branches grow per learned-word meaning group
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
                      branches: branches,
                      seed: 42, // Consistent shape
                    ),
                  );
                },
              ),
            ),

            // Branch legend — one chip per meaning group
            if (branches.isNotEmpty) ...[
              const SizedBox(height: MnemonicsSpacing.m),
              Wrap(
                spacing: MnemonicsSpacing.s,
                runSpacing: MnemonicsSpacing.xs,
                alignment: WrapAlignment.center,
                children: branches
                    .map((b) => _branchChip(b))
                    .toList(),
              ),
            ],

            const SizedBox(height: MnemonicsSpacing.m),
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

  Widget _branchChip(TreeBranchSpec branch) {
    final label = branch.category.length > 12
        ? '${branch.category.substring(0, 12)}…'
        : branch.category;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: branch.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
        border: Border.all(color: branch.color.withOpacity(0.35)),
      ),
      child: Text(
        '$label • ${branch.wordCount}',
        style: MnemonicsTypography.bodyRegular.copyWith(
          color: branch.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getTreeStatusMessage(List<TreeBranchSpec> branches) {
    if (widget.totalLearned == 0) return 'Plant a seed by learning words!';
    if (branches.isNotEmpty) {
      final biggest = branches.first;
      final cap = biggest.category[0].toUpperCase() +
          biggest.category.substring(1).toLowerCase();
      return 'Growing strong on "$cap" words.';
    }
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

/// Paints the tree: a trunk whose height reflects total words learned, and one
/// branch per meaning group (vocabulary category). A branch grows longer,
/// thicker and bushier the more words the user has learned with that common
/// meaning.
class TreePainter extends CustomPainter {
  final int depth;
  final double health; // 0.0 (dead/brown) to 1.0 (vibrant green)
  final double growthAnimation; // 0.0 to 1.0
  final List<TreeBranchSpec> branches;
  final int seed;

  TreePainter({
    required this.depth,
    required this.health,
    required this.growthAnimation,
    required this.branches,
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

    // Start drawing from bottom center
    final startX = size.width / 2;
    final startY = size.height;

    if (growthAnimation <= 0.01) return;

    // ── Seed / sprout stage: no branches yet, just the trunk growing ──────
    if (branches.isEmpty) {
      final heightScale = 0.5 + (depth / 7.0) * 0.5;
      final trunkLength = (size.height / 4.5) * growthAnimation * heightScale;
      trunkPaint.strokeWidth = (4 + depth).toDouble();
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX, startY - trunkLength),
        trunkPaint,
      );
      // A tiny leaf cluster at the tip so the sprout reads as alive.
      if (health > 0.1) {
        final tipPaint = Paint()
          ..color = leafColor.withAlpha(200)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
            Offset(startX, startY - trunkLength), (8 + depth).toDouble(), tipPaint);
      }
      return;
    }

    // ── Trunk: taller & thicker as more meaning groups take root ──────────
    final maxWords =
        branches.map((b) => b.wordCount).fold<int>(1, (a, b) => max<int>(a, b));
    final trunkLength = size.height * (0.30 + min(branches.length, 4) * 0.04);
    final trunkEnd = Offset(startX, startY - trunkLength * growthAnimation);
    trunkPaint.strokeWidth = 8.0 + min(branches.length * 1.5, 8.0);
    canvas.drawLine(Offset(startX, startY), trunkEnd, trunkPaint);

    // ── One branch per meaning group, spread across the canopy ────────────
    final n = branches.length;
    final spread = n == 1 ? 0.0 : pi * 0.75;
    final startAngle = -spread / 2;

    for (var i = 0; i < n; i++) {
      final branch = branches[i];

      final angle = n == 1 ? 0.0 : startAngle + i * (spread / (n - 1));
      // Growth factor: how big THIS meaning group is relative to the biggest
      // (min 0.45 so even a single-word branch is visible).
      final growth = 0.45 + 0.55 * (branch.wordCount / maxWords);
      // Extra sub-twigs as the meaning group deepens (1..3).
      final twigs = 1 + min((branch.wordCount / 3).floor(), 2);

      final branchLength =
          (size.height * 0.34) * growth * growthAnimation;
      final jitter = random.nextDouble() * 0.1 - 0.05;
      final a = angle + jitter;

      final branchEnd = Offset(
        trunkEnd.dx + branchLength * sin(a),
        trunkEnd.dy - branchLength * cos(a),
      );

      trunkPaint.strokeWidth = 3.0 + branch.wordCount * 0.8;
      canvas.drawLine(trunkEnd, branchEnd, trunkPaint);

      // Sub-twigs fan out from the branch tip.
      final twigSpread = pi * 0.5;
      for (var t = 0; t < twigs; t++) {
        final twigAngle = twigs == 1
            ? a
            : (a - twigSpread / 2) + t * (twigSpread / (twigs - 1));
        final twigLength = branchLength * (0.45 + random.nextDouble() * 0.2);
        final twigEnd = Offset(
          branchEnd.dx + twigLength * sin(twigAngle),
          branchEnd.dy - twigLength * cos(twigAngle),
        );
        trunkPaint.strokeWidth = 2.0;
        canvas.drawLine(branchEnd, twigEnd, trunkPaint);

        // Leaf cluster at the twig tip, tinted by the meaning group.
        if (health > 0.1) {
          final clusterColor = Color.lerp(branch.color, leafColor, 0.35)!;
          final clusterPaint = Paint()
            ..color = clusterColor
                .withAlpha((200 * health).clamp(120, 255).toInt())
            ..style = PaintingStyle.fill;
          final radius = 7.0 + min(branch.wordCount, 8) * 1.1;
          canvas.drawCircle(twigEnd, radius, clusterPaint);
          // Scatter leaf for organic feel
          canvas.drawCircle(
            Offset(twigEnd.dx + random.nextDouble() * 8 - 4,
                twigEnd.dy + random.nextDouble() * 8 - 4),
            radius * 0.6,
            clusterPaint,
          );
        }
      }

      // Fruit (amber) once a meaning group is deep enough (5+ words).
      if (branch.wordCount >= 5 && health > 0.15) {
        final fruitPaint = Paint()
          ..color = Colors.amberAccent
          ..style = PaintingStyle.fill;
        canvas.drawCircle(branchEnd, 4.5, fruitPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.depth != depth ||
        oldDelegate.health != health ||
        oldDelegate.growthAnimation != growthAnimation ||
        !_branchListEquals(oldDelegate.branches, branches);
  }

  static bool _branchListEquals(
      List<TreeBranchSpec> a, List<TreeBranchSpec> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
