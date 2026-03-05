import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/design/design_system.dart';
import '../../../../core/services/ai_service.dart';
import '../../../profile/providers/profile_statistics_provider.dart';
import '../../../home/providers.dart';
import '../../../home/domain/vocabulary_word.dart';
import '../../../profile/domain/user_statistics.dart' as stats;

class KnowledgeTreeDetailScreen extends ConsumerStatefulWidget {
  const KnowledgeTreeDetailScreen({super.key});

  @override
  ConsumerState<KnowledgeTreeDetailScreen> createState() =>
      _KnowledgeTreeDetailScreenState();
}

class _KnowledgeTreeDetailScreenState
    extends ConsumerState<KnowledgeTreeDetailScreen> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    // Center the tree trunk near bottom of initial viewport
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      // The canvas is 4000x4000. Root is at (2000, 3600).
      // Let's translate so root is at bottom center.
      final dx = -(2000 - size.width / 2);
      final dy = -(3600 - size.height + 100);
      _transformationController.value = Matrix4.identity()
        ..translate(dx, dy)
        ..scale(1.0);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _triggerTreeWhisperer(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: MnemonicsColors.primaryGreen),
              SizedBox(height: MnemonicsSpacing.m),
              Text(
                'Listening to the Tree Spirit...',
                style:
                    TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final profStats = await ref.read(profileStatisticsProvider.future);
      final aiService = ref.read(aiServiceProvider);

      final wisdom = await aiService.generateTreeWisdom(
        totalLearned: profStats.totalWordsLearned,
        accuracy: profStats.averageAccuracy,
        streak: profStats.currentStreak,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
      }

      if (mounted) {
        _showWisdomModal(context, wisdom);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
      }
    }
  }

  void _showWisdomModal(BuildContext context, String wisdom) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL)),
        child: Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.xl),
          decoration: BoxDecoration(
            color: MnemonicsColors.surface,
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
            border: Border.all(
                color: MnemonicsColors.primaryGreen.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: MnemonicsColors.primaryGreen.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome,
                  color: MnemonicsColors.primaryGreen, size: 48),
              const SizedBox(height: MnemonicsSpacing.m),
              Text(
                'Tree of Knowledge Says:',
                style: MnemonicsTypography.bodyLarge.copyWith(
                    color: MnemonicsColors.primaryGreen,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: MnemonicsSpacing.l),
              Text(
                '"$wisdom"',
                style: MnemonicsTypography.bodyLarge.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MnemonicsSpacing.xl),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MnemonicsColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MnemonicsSpacing.radiusL)),
                ),
                child: const Text('Continue Growing',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(vocabularyListProvider);
    final userDataAsync = ref.watch(allUserWordDataProvider);
    final statsAsync = ref.watch(profileStatisticsProvider);

    if (vocabAsync.isLoading ||
        userDataAsync.isLoading ||
        statsAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final vocab = vocabAsync.value ?? [];
    final userData = userDataAsync.value ?? [];
    final profStats = statsAsync.value;

    final health =
        profStats != null ? _calculateHealth(profStats.lastStudyDate) : 1.0;

    // Group learned words by category
    final learnedWordsData = userData
        .where((d) => d.hasBeenTested || d.isLearned || d.reviewCount > 0)
        .toList();
    final Map<String, List<String>> categoryToWords = {};

    for (var uwd in learnedWordsData) {
      final vWord = vocab.firstWhere(
        (v) => v.word == uwd.word,
        orElse: () => VocabularyWord(
          word: uwd.word,
          meaning: '',
          mnemonic: '',
          example: '',
          synonyms: [],
          antonyms: [],
          category: 'General',
          difficulty: stats.WordDifficulty.intermediate,
        ),
      );

      final cat = vWord.category;
      if (!categoryToWords.containsKey(cat)) {
        categoryToWords[cat] = [];
      }
      categoryToWords[cat]!.add(vWord.word);
    }

    return Scaffold(
      backgroundColor: MnemonicsColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: MnemonicsColors.background.withOpacity(0.8),
        elevation: 0,
        title:
            Text('Your Word Canopy', style: MnemonicsTypography.headingMedium),
        centerTitle: true,
        iconTheme: const IconThemeData(color: MnemonicsColors.textPrimary),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _triggerTreeWhisperer(context),
        backgroundColor: MnemonicsColors.primaryGreen,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text('Tree Spirit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(2000),
        minScale: 0.1,
        maxScale: 3.0,
        constrained: false, // Allow unbounded canvas
        child: Container(
          width: 4000,
          height: 4000,
          color: MnemonicsColors.background, // Canvas background
          child: CustomPaint(
            painter: SemanticTreePainter(
              categoryToWords: categoryToWords,
              health: health,
              seed: 42,
            ),
          ),
        ),
      ),
    );
  }

  double _calculateHealth(DateTime? lastStudyDate) {
    if (lastStudyDate == null) return 1.0;
    final days = DateTime.now().difference(lastStudyDate).inDays;
    if (days <= 1) return 1.0;
    if (days >= 7) return 0.2;
    return 1.0 - ((days - 1) * 0.13);
  }
}

class SemanticTreePainter extends CustomPainter {
  final Map<String, List<String>> categoryToWords;
  final double health;
  final int seed;

  SemanticTreePainter({
    required this.categoryToWords,
    required this.health,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);

    final trunkColor = Color.lerp(
          const Color(0xFF6D4C41),
          const Color(0xFF8D6E63),
          1.0 - health,
        ) ??
        const Color(0xFF6D4C41);

    final leafColor = Color.lerp(
          const Color(0xFFD84315),
          MnemonicsColors.primaryGreen,
          health,
        ) ??
        MnemonicsColors.primaryGreen;

    final trunkPaint = Paint()
      ..color = trunkColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Root coordinate
    final rootX = size.width / 2;
    final rootY = size.height - 400; // Leave space at bottom

    // Draw main trunk
    final trunkLength = 300.0;
    final trunkEndX = rootX;
    final trunkEndY = rootY - trunkLength;

    trunkPaint.strokeWidth = 40.0;
    canvas.drawLine(
        Offset(rootX, rootY), Offset(trunkEndX, trunkEndY), trunkPaint);

    // If no words yet
    if (categoryToWords.isEmpty) {
      return;
    }

    final categories = categoryToWords.keys.toList();
    final int numCategories = categories.length;

    // Spread categories roughly between -pi/2 to pi/2, with root spreading upwards
    final angleSpread = pi * 0.7; // 126 degrees total spread
    final startAngle = -angleSpread / 2;

    for (int i = 0; i < numCategories; i++) {
      final category = categories[i];
      final words = categoryToWords[category]!;

      // Angle for this primary branch
      double branchAngle = 0;
      if (numCategories > 1) {
        branchAngle = startAngle + (i * (angleSpread / (numCategories - 1)));
      }

      branchAngle += (random.nextDouble() * 0.2 - 0.1);

      // Primary branch length
      // Longer if it has more words, but capped
      final branchLength =
          250.0 + min(words.length * 20.0, 300.0) + random.nextDouble() * 50;

      final branchEndX = trunkEndX + branchLength * sin(branchAngle);
      final branchEndY = trunkEndY - branchLength * cos(branchAngle);

      trunkPaint.strokeWidth = 20.0;

      // Draw primary branch
      _drawCurvedBranch(canvas, Offset(trunkEndX, trunkEndY),
          Offset(branchEndX, branchEndY), trunkPaint);

      // Draw Category Label
      _drawTextLeaf(canvas, category, branchEndX, branchEndY,
          isCategory: true, leafColor: leafColor);

      // Now draw sub-branches for words
      final numWords = words.length;
      final wordAngleSpread = pi * 0.8;
      double wordStartAngle = branchAngle - wordAngleSpread / 2;

      if (numWords == 1) wordStartAngle = branchAngle;

      for (int w = 0; w < numWords; w++) {
        final word = words[w];

        double subAngle = branchAngle;
        if (numWords > 1) {
          subAngle = wordStartAngle + (w * (wordAngleSpread / (numWords - 1)));
        }
        subAngle += (random.nextDouble() * 0.2 - 0.1); // jitter

        final subLength = 120.0 + random.nextDouble() * 100.0;

        final subEndX = branchEndX + subLength * sin(subAngle);
        final subEndY = branchEndY - subLength * cos(subAngle);

        trunkPaint.strokeWidth = 6.0;
        _drawCurvedBranch(canvas, Offset(branchEndX, branchEndY),
            Offset(subEndX, subEndY), trunkPaint);

        // Draw Word Leaf
        _drawTextLeaf(canvas, word, subEndX, subEndY,
            isCategory: false, leafColor: leafColor);
      }
    }
  }

  void _drawCurvedBranch(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Control point slightly offsets to create an organic curve
    final controlPointX =
        start.dx + (end.dx - start.dx) / 2 + 50; // arbitrary bend
    final controlPointY = start.dy + (end.dy - start.dy) / 2 - 30;

    path.quadraticBezierTo(controlPointX, controlPointY, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  void _drawTextLeaf(Canvas canvas, String text, double x, double y,
      {required bool isCategory, required Color leafColor}) {
    final textStyle = isCategory
        ? const TextStyle(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
        : const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal);

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final width = textPainter.width + 32;
    final height = textPainter.height + 16;

    final leafRect =
        Rect.fromCenter(center: Offset(x, y), width: width, height: height);
    final rrect =
        RRect.fromRectAndRadius(leafRect, Radius.circular(height / 2));

    final bgPaint = Paint()
      ..color = isCategory ? const Color(0xFF2C3E50) : leafColor
      ..style = PaintingStyle.fill;

    // Shadow
    canvas.drawRRect(
        rrect.shift(const Offset(0, 4)),
        Paint()
          ..color = Colors.black26
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawRRect(rrect, bgPaint);

    textPainter.paint(
        canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant SemanticTreePainter oldDelegate) {
    return true; // Always repaint for simplicity when stats change
  }
}
