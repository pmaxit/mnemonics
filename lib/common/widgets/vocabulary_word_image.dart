import 'package:flutter/material.dart';

import '../../features/home/domain/vocabulary_word.dart';
import '../design/design_system.dart';
import '../../core/utils/vocabulary_image_url.dart';

/// Shows a vocabulary image from the API URL (Railway-hosted comics).
class VocabularyWordImage extends StatelessWidget {
  final VocabularyWord word;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const VocabularyWordImage({
    super.key,
    required this.word,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  Widget _placeholder() {
    return Container(
      width: width,
      height: height ?? 160,
      color: MnemonicsColors.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image,
        size: 40,
        color: MnemonicsColors.textSecondary,
      ),
    );
  }

  Widget _broken() {
    return Container(
      width: width,
      height: height ?? 160,
      color: MnemonicsColors.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image,
        size: 40,
        color: MnemonicsColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final networkUrl = resolveVocabularyWordImage(word);

    Widget image;
    if (networkUrl != null && networkUrl.isNotEmpty) {
      image = Image.network(
        networkUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _broken(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height ?? 160,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    } else {
      image = _placeholder();
    }

    final radius = borderRadius;
    if (radius != null) {
      return ClipRRect(borderRadius: radius, child: image);
    }
    return image;
  }
}
