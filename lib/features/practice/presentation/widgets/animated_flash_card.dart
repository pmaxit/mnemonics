import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../widgets/animated_progress_utils.dart';
import '../../domain/timer_models.dart';
import '../../../home/domain/vocabulary_word.dart';
import '../../../home/domain/user_word_data.dart';
import '../../../profile/domain/user_statistics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ai_mnemonic_provider.dart';

import 'dart:math' as math;

class AnimatedFlashCard extends ConsumerStatefulWidget {
  final VocabularyWord word;
  final UserWordData? userWordData;
  final bool isRevealed;
  final VoidCallback onTap;
  final Function(ReviewDifficulty) onRate;
  final VoidCallback? onSkip;
  final int animationDelay;

  const AnimatedFlashCard({
    super.key,
    required this.word,
    this.userWordData,
    required this.isRevealed,
    required this.onTap,
    required this.onRate,
    this.onSkip,
    this.animationDelay = 0,
  });

  @override
  ConsumerState<AnimatedFlashCard> createState() => _AnimatedFlashCardState();
}

class _AnimatedFlashCardState extends ConsumerState<AnimatedFlashCard>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _flipController;
  late AnimationController _ratingController;

  late Animation<double> _entryAnimation;
  late Animation<double> _flipAnimation;
  late Animation<double> _ratingAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: AnimatedProgressUtils.dataAnimation,
      vsync: this,
    );

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _ratingController = AnimationController(
      duration: AnimatedProgressUtils.dataAnimation,
      vsync: this,
    );

    _entryAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: AnimatedProgressUtils.entryEasing,
    ));

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    _ratingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ratingController,
      curve: AnimatedProgressUtils.entryEasing,
    ));

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _entryController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedFlashCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRevealed && !oldWidget.isRevealed) {
      _flipCard();
    } else if (!widget.isRevealed && oldWidget.isRevealed) {
      _resetCard();
    }
  }

  void _flipCard() {
    _flipController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _ratingController.forward();
      }
    });
  }

  void _resetCard() {
    _flipController.reset();
    _ratingController.reset();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _flipController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  String _sanitizeString(String input) {
    if (input.isEmpty) return input;

    // Remove any invalid UTF-16 characters
    return input.replaceAll(RegExp(r'[\uD800-\uDFFF]'), '');
  }

  @override
  Widget build(BuildContext context) {
    final aiMnemonicState = ref.watch(aiMnemonicProvider(widget.word.word));

    return AnimatedBuilder(
      animation: _entryAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _entryAnimation.value)),
          child: Opacity(
            opacity: _entryAnimation.value,
            child: Column(
              children: [
                // Main card
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: _buildCard(aiMnemonicState),
                  ),
                ),

                // Rating buttons
                if (widget.isRevealed)
                  AnimatedBuilder(
                    animation: _ratingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - _ratingAnimation.value)),
                        child: Opacity(
                          opacity: _ratingAnimation.value,
                          child: _buildRatingButtons(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(AsyncValue<String?> aiMnemonicState) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final isShowingFront = _flipAnimation.value < 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_flipAnimation.value * math.pi),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(MnemonicsSpacing.m),
            padding: const EdgeInsets.all(MnemonicsSpacing.l),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: MnemonicsColors.primaryGreen.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: isShowingFront
                ? _buildFrontContent()
                : _buildBackContent(aiMnemonicState),
          ),
        );
      },
    );
  }

  Widget _buildFrontContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Word display
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, animation, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * animation),
              child: Text(
                _sanitizeString(widget.word.word.toUpperCase()),
                style: MnemonicsTypography.headingLarge.copyWith(
                  color: MnemonicsColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),

        const SizedBox(height: MnemonicsSpacing.xl),

        // Category and difficulty
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInfoChip(
              'Category',
              widget.word.category,
              MnemonicsColors.primaryGreen,
            ),
            const SizedBox(width: MnemonicsSpacing.s),
            _buildInfoChip(
              'Difficulty',
              widget.word.difficulty.name,
              _getDifficultyColor(widget.word.difficulty),
            ),
          ],
        ),

        const SizedBox(height: MnemonicsSpacing.l),

        // Statistics if available
        if (widget.userWordData != null) _buildStatistics(),

        const Spacer(),

        // Tap instruction
        Container(
          padding: const EdgeInsets.all(MnemonicsSpacing.m),
          decoration: BoxDecoration(
            color: MnemonicsColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.touch_app,
                color: MnemonicsColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Text(
                'Tap to reveal meaning',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: MnemonicsColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackContent(AsyncValue<String?> aiMnemonicState) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word header with category/difficulty
            Row(
              children: [
                Expanded(
                  child: Text(
                    _sanitizeString(widget.word.word.toUpperCase()),
                    style: MnemonicsTypography.headingMedium.copyWith(
                      color: MnemonicsColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildInfoChip(
                  'Category',
                  widget.word.category,
                  MnemonicsColors.primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: MnemonicsSpacing.m),

            // Meaning - prominent position
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MnemonicsSpacing.m),
              decoration: BoxDecoration(
                color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                border: Border.all(
                  color: MnemonicsColors.primaryGreen.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: MnemonicsColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: MnemonicsSpacing.s),
                      Text(
                        'Meaning:',
                        style: MnemonicsTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: MnemonicsColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MnemonicsSpacing.s),
                  Text(
                    _sanitizeString(widget.word.meaning),
                    style: MnemonicsTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: MnemonicsSpacing.m),

            // Example
            Text(
              'Example:',
              style: MnemonicsTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.xs),
            Container(
              padding: const EdgeInsets.all(MnemonicsSpacing.m),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              ),
              child: Text(
                _sanitizeString(widget.word.example),
                style: MnemonicsTypography.bodyRegular.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: MnemonicsSpacing.m),

            // Mnemonic - special attention with prominent styling
            // Mnemonic - special attention with prominent styling
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MnemonicsSpacing.m),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MnemonicsColors.secondaryOrange.withOpacity(0.15),
                    MnemonicsColors.secondaryOrange.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
                border: Border.all(
                  color: MnemonicsColors.secondaryOrange.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.psychology,
                        color: MnemonicsColors.secondaryOrange,
                        size: 22,
                      ),
                      const SizedBox(width: MnemonicsSpacing.s),
                      Expanded(
                        child: Text(
                          'Memory Aid:',
                          style: MnemonicsTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: MnemonicsColors.secondaryOrange,
                          ),
                        ),
                      ),
                      if (widget.word.aiMnemonic == null &&
                          aiMnemonicState.valueOrNull == null &&
                          !aiMnemonicState.isLoading)
                        IconButton(
                          icon: const Icon(Icons.auto_awesome,
                              color: MnemonicsColors.secondaryOrange),
                          onPressed: () {
                            ref
                                .read(aiMnemonicProvider(widget.word.word)
                                    .notifier)
                                .generateMnemonic(meaning: widget.word.meaning);
                          },
                          tooltip: 'Generate Magic Mnemonic',
                        ),
                    ],
                  ),
                  const SizedBox(height: MnemonicsSpacing.s),
                  if (aiMnemonicState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(MnemonicsSpacing.s),
                        child: CircularProgressIndicator(
                            color: MnemonicsColors.secondaryOrange),
                      ),
                    )
                  else if (aiMnemonicState.hasError)
                    Text(
                      'Oops! Magic spell failed. Try again.',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else if (widget.word.aiMnemonic != null ||
                      aiMnemonicState.valueOrNull != null ||
                      widget.word.mnemonic.isNotEmpty)
                    Text(
                      _sanitizeString(widget.word.aiMnemonic ??
                          aiMnemonicState.valueOrNull ??
                          widget.word.mnemonic),
                      style: MnemonicsTypography.bodyLarge.copyWith(
                        color: MnemonicsColors.secondaryOrange,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    )
                  else
                    Text(
                      'No memory aid yet. Tap the magic wand above to generate a fun AI-powered mnemonic!',
                      style: MnemonicsTypography.bodyRegular.copyWith(
                        color: MnemonicsColors.secondaryOrange.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: MnemonicsSpacing.s),

            // Synonyms and Antonyms in a row if both exist
            if (widget.word.synonyms.isNotEmpty ||
                widget.word.antonyms.isNotEmpty) ...[
              Row(
                children: [
                  if (widget.word.synonyms.isNotEmpty) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Synonyms:',
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: MnemonicsSpacing.xs),
                          Wrap(
                            spacing: MnemonicsSpacing.xs,
                            runSpacing: MnemonicsSpacing.xs,
                            children: widget.word.synonyms
                                .take(3)
                                .map(
                                  (synonym) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: MnemonicsSpacing.s,
                                      vertical: MnemonicsSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                          MnemonicsSpacing.radiusS),
                                      border: Border.all(
                                          color: Colors.blue.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      _sanitizeString(synonym),
                                      style: MnemonicsTypography.bodyRegular
                                          .copyWith(
                                        fontSize: 10,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    if (widget.word.antonyms.isNotEmpty)
                      const SizedBox(width: MnemonicsSpacing.s),
                  ],
                  if (widget.word.antonyms.isNotEmpty) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Antonyms:',
                            style: MnemonicsTypography.bodyRegular.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: MnemonicsSpacing.xs),
                          Wrap(
                            spacing: MnemonicsSpacing.xs,
                            runSpacing: MnemonicsSpacing.xs,
                            children: widget.word.antonyms
                                .take(3)
                                .map(
                                  (antonym) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: MnemonicsSpacing.s,
                                      vertical: MnemonicsSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                          MnemonicsSpacing.radiusS),
                                      border: Border.all(
                                          color: Colors.red.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      _sanitizeString(antonym),
                                      style: MnemonicsTypography.bodyRegular
                                          .copyWith(
                                        fontSize: 10,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: MnemonicsSpacing.s),
            ],

            const SizedBox(height: MnemonicsSpacing.m),

            // Rate instruction
            Container(
              padding: const EdgeInsets.all(MnemonicsSpacing.m),
              decoration: BoxDecoration(
                color: MnemonicsColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.rate_review,
                    color: MnemonicsColors.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: MnemonicsSpacing.s),
                  Text(
                    'How difficult was this word?',
                    style: MnemonicsTypography.bodyRegular.copyWith(
                      color: MnemonicsColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom padding for better scrolling
            const SizedBox(height: MnemonicsSpacing.m),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MnemonicsSpacing.s,
        vertical: MnemonicsSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '${_sanitizeString(label)}: ${_sanitizeString(value)}',
        style: MnemonicsTypography.bodyRegular.copyWith(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final userWordData = widget.userWordData!;

    return Container(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: MnemonicsTypography.bodyRegular.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: MnemonicsSpacing.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Reviews', userWordData.reviewCount.toString()),
              _buildStatItem('Accuracy',
                  '${(userWordData.accuracyRate * 100).toStringAsFixed(0)}%'),
              _buildStatItem('Learned', userWordData.isLearned ? 'Yes' : 'No'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: MnemonicsTypography.bodyRegular.copyWith(
            fontWeight: FontWeight.bold,
            color: MnemonicsColors.primaryGreen,
          ),
        ),
        Text(
          label,
          style: MnemonicsTypography.bodyRegular.copyWith(
            fontSize: 10,
            color: MnemonicsColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingButtons() {
    return Padding(
      padding: const EdgeInsets.all(MnemonicsSpacing.m),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildRatingButton(
                  ReviewDifficulty.hard,
                  Colors.red,
                  Icons.sentiment_very_dissatisfied,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: _buildRatingButton(
                  ReviewDifficulty.medium,
                  Colors.orange,
                  Icons.sentiment_neutral,
                ),
              ),
              const SizedBox(width: MnemonicsSpacing.s),
              Expanded(
                child: _buildRatingButton(
                  ReviewDifficulty.easy,
                  Colors.green,
                  Icons.sentiment_very_satisfied,
                ),
              ),
            ],
          ),
          if (widget.onSkip != null) ...[
            const SizedBox(height: MnemonicsSpacing.s),
            TextButton(
              onPressed: widget.onSkip,
              child: Text(
                'Skip this word',
                style: MnemonicsTypography.bodyRegular.copyWith(
                  color: MnemonicsColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingButton(
      ReviewDifficulty difficulty, Color color, IconData icon) {
    return TweenAnimationBuilder<double>(
      duration: AnimatedProgressUtils.microInteraction,
      tween: Tween<double>(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: ElevatedButton(
            onPressed: () => _handleRating(difficulty),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: MnemonicsSpacing.m),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
              ),
              elevation: 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24),
                const SizedBox(height: MnemonicsSpacing.xs),
                Text(
                  difficulty.displayName,
                  style: MnemonicsTypography.bodyRegular.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleRating(ReviewDifficulty difficulty) {
    // Add button press animation
    final controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    controller.forward().then((_) {
      controller.reverse().then((_) {
        controller.dispose();
        widget.onRate(difficulty);
      });
    });
  }

  Color _getDifficultyColor(WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.basic:
        return Colors.green;
      case WordDifficulty.intermediate:
        return Colors.orange;
      case WordDifficulty.advanced:
        return Colors.red;
    }
  }
}
