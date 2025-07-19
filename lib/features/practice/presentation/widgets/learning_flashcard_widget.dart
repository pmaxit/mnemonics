import 'package:flutter/material.dart';
import '../../../../common/design/design_system.dart';
import '../../domain/learning_session_models.dart';
import '../../../home/domain/vocabulary_word.dart';

class LearningFlashcardWidget extends StatefulWidget {
  final VocabularyWord word;
  final FlashcardSide currentSide;
  final VoidCallback onFlip;
  final Function(String) onRate;
  final VoidCallback onSkip;
  final bool isRevealed;

  const LearningFlashcardWidget({
    super.key,
    required this.word,
    required this.currentSide,
    required this.onFlip,
    required this.onRate,
    required this.onSkip,
    required this.isRevealed,
  });

  @override
  State<LearningFlashcardWidget> createState() => _LearningFlashcardWidgetState();
}

class _LearningFlashcardWidgetState extends State<LearningFlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(LearningFlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate flip when side changes
    if (oldWidget.currentSide != widget.currentSide) {
      if (widget.currentSide == FlashcardSide.back) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
    
    // Reset animation when word changes
    if (oldWidget.word.word != widget.word.word) {
      _flipController.reset();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: Column(
        children: [
          // Main flashcard
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: widget.isRevealed ? null : widget.onFlip,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final isShowingBack = _flipAnimation.value >= 0.5;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_flipAnimation.value * 3.14159),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: isShowingBack 
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: _buildCardBack(),
                            )
                          : _buildCardFront(),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: MnemonicsSpacing.l),
          
          // Action buttons
          if (widget.isRevealed) ...[
            _buildActionButtons(),
          ] else ...[
            _buildFlipHint(),
          ],
        ],
      ),
    );
  }

  Widget _buildCardFront() {
    return Padding(
      padding: const EdgeInsets.all(MnemonicsSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Word
          Text(
            _sanitizeText(widget.word.word),
            style: MnemonicsTypography.headingLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: MnemonicsColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: MnemonicsSpacing.l),
          
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MnemonicsSpacing.m,
              vertical: MnemonicsSpacing.s,
            ),
            decoration: BoxDecoration(
              color: MnemonicsColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
            ),
            child: Text(
              _sanitizeText(widget.word.category),
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: MnemonicsColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: MnemonicsSpacing.xl),
          
          // Difficulty indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final difficulty = widget.word.difficulty.toLowerCase();
              final filledStars = difficulty == 'easy' ? 2 : 
                                 difficulty == 'medium' ? 3 : 4;
              return Icon(
                index < filledStars ? Icons.star : Icons.star_border,
                color: MnemonicsColors.secondaryOrange,
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Padding(
      padding: const EdgeInsets.all(MnemonicsSpacing.l),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word (smaller on back)
            Center(
              child: Text(
                _sanitizeText(widget.word.word),
                style: MnemonicsTypography.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MnemonicsColors.textPrimary,
                ),
              ),
            ),
            
            const SizedBox(height: MnemonicsSpacing.l),
            
            // Meaning
            _buildSection('Meaning', _sanitizeText(widget.word.meaning)),
            
            const SizedBox(height: MnemonicsSpacing.m),
            
            // Mnemonic
            _buildSection('Mnemonic', _sanitizeText(widget.word.mnemonic)),
            
            const SizedBox(height: MnemonicsSpacing.m),
            
            // Example
            _buildSection('Example', _sanitizeText(widget.word.example)),
            
            if (widget.word.synonyms.isNotEmpty) ...[
              const SizedBox(height: MnemonicsSpacing.m),
              _buildListSection('Synonyms', widget.word.synonyms.map(_sanitizeText).toList()),
            ],
            
            if (widget.word.antonyms.isNotEmpty) ...[
              const SizedBox(height: MnemonicsSpacing.m),
              _buildListSection('Antonyms', widget.word.antonyms.map(_sanitizeText).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MnemonicsTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: MnemonicsColors.primaryGreen,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.xs),
        Text(
          content,
          style: MnemonicsTypography.bodyRegular.copyWith(
            color: MnemonicsColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MnemonicsTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: MnemonicsColors.primaryGreen,
          ),
        ),
        const SizedBox(height: MnemonicsSpacing.xs),
        Wrap(
          spacing: MnemonicsSpacing.s,
          runSpacing: MnemonicsSpacing.xs,
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MnemonicsSpacing.s,
              vertical: MnemonicsSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: MnemonicsColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusM),
            ),
            child: Text(
              item,
              style: MnemonicsTypography.bodyRegular.copyWith(
                color: MnemonicsColors.textSecondary,
                fontSize: 12,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildFlipHint() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MnemonicsSpacing.l,
        vertical: MnemonicsSpacing.m,
      ),
      decoration: BoxDecoration(
        color: MnemonicsColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        border: Border.all(
          color: MnemonicsColors.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            color: MnemonicsColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: MnemonicsSpacing.s),
          Text(
            'Tap to reveal meaning',
            style: MnemonicsTypography.bodyRegular.copyWith(
              color: MnemonicsColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Difficulty rating buttons
        Row(
          children: [
            Expanded(
              child: _buildRatingButton(
                'Hard',
                'hard',
                Icons.sentiment_very_dissatisfied,
                Colors.red,
              ),
            ),
            const SizedBox(width: MnemonicsSpacing.s),
            Expanded(
              child: _buildRatingButton(
                'Medium',
                'medium',
                Icons.sentiment_neutral,
                MnemonicsColors.secondaryOrange,
              ),
            ),
            const SizedBox(width: MnemonicsSpacing.s),
            Expanded(
              child: _buildRatingButton(
                'Easy',
                'easy',
                Icons.sentiment_very_satisfied,
                MnemonicsColors.primaryGreen,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: MnemonicsSpacing.m),
        
        // Skip button
        TextButton(
          onPressed: widget.onSkip,
          style: TextButton.styleFrom(
            foregroundColor: MnemonicsColors.textSecondary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.skip_next, size: 20),
              const SizedBox(width: MnemonicsSpacing.xs),
              Text('Skip'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingButton(String label, String difficulty, IconData icon, Color color) {
    return ElevatedButton(
      onPressed: () => widget.onRate(difficulty),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: MnemonicsSpacing.m),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusL),
        ),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: MnemonicsSpacing.xs),
          Text(
            label,
            style: MnemonicsTypography.bodyRegular.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _sanitizeText(String text) {
    if (text.isEmpty) return text;
    
    // Remove any invalid Unicode characters
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      
      // Check for valid UTF-16 code units
      if (codeUnit >= 0x20 && codeUnit <= 0xD7FF) {
        // Basic Latin, Latin-1 Supplement, and other BMP characters
        buffer.writeCharCode(codeUnit);
      } else if (codeUnit >= 0xE000 && codeUnit <= 0xFFFD) {
        // Private use area and other valid BMP characters
        buffer.writeCharCode(codeUnit);
      } else if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF && i + 1 < text.length) {
        // High surrogate - check if followed by low surrogate
        final nextCodeUnit = text.codeUnitAt(i + 1);
        if (nextCodeUnit >= 0xDC00 && nextCodeUnit <= 0xDFFF) {
          // Valid surrogate pair
          buffer.writeCharCode(codeUnit);
          buffer.writeCharCode(nextCodeUnit);
          i++; // Skip the low surrogate in next iteration
        } else {
          // Invalid surrogate pair - replace with replacement character
          buffer.write('�');
        }
      } else if (codeUnit >= 0x09 && codeUnit <= 0x0D) {
        // Tab, newline, carriage return - keep these
        buffer.writeCharCode(codeUnit);
      } else {
        // Replace invalid characters with replacement character
        buffer.write('�');
      }
    }
    
    return buffer.toString();
  }
}