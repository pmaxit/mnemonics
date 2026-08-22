/// Helpers for vocabulary image URLs returned by the API.
///
/// Production images are hosted on the Railway API volume at
/// `/word_images/{slug}.jpg`. This helper only normalizes empty values and
/// rewrites legacy Pollinations URLs when the API still returns them.
library;

import '../../features/home/domain/vocabulary_word.dart';

String? resolveVocabularyImageUrl({
  String? imageUrl,
  String? word,
  String? meaning,
}) {
  final raw = imageUrl?.trim();
  if (raw == null || raw.isEmpty) return null;

  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.hasScheme) {
    if (raw.startsWith('/word_images/')) {
      return 'https://mnemonics-api-production.up.railway.app$raw';
    }
    return raw;
  }

  final host = uri.host.toLowerCase();
  // Dead/unauthorized Pollinations hosts — prefer API-hosted comics instead.
  if (host == 'media.pollinations.ai' || host == 'gen.pollinations.ai') {
    final w = word?.trim() ?? '';
    if (w.isEmpty) return null;
    final slug = w
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (slug.isEmpty) return null;
    return 'https://mnemonics-api-production.up.railway.app/word_images/$slug.jpg';
  }

  return raw;
}

String? resolveVocabularyWordImage(VocabularyWord word) {
  return resolveVocabularyImageUrl(
    imageUrl: word.image,
    word: word.word,
    meaning: word.meaning,
  );
}
