import '../../profile/domain/user_statistics.dart';
import 'vocabulary_word.dart';

/// Maps a numeric vocabulary level (1 = beginner, 2 = intermediate,
/// 3+ = advanced) to the word difficulty it should practice.
WordDifficulty difficultyForLevel(int level) {
  if (level <= 1) return WordDifficulty.basic;
  if (level == 2) return WordDifficulty.intermediate;
  return WordDifficulty.advanced;
}

/// Rank used to measure distance between difficulties (for fallback fill).
int _difficultyRank(WordDifficulty d) {
  switch (d) {
    case WordDifficulty.basic:
      return 1;
    case WordDifficulty.intermediate:
      return 2;
    case WordDifficulty.advanced:
      return 3;
  }
}

/// Level-aware word recommendation.
///
/// Picks words the user has NOT learned yet, matching the difficulty of the
/// user's selected vocabulary levels. When the exact difficulty band is
/// exhausted it fills up from the nearest difficulties so the practice list
/// never runs empty, while keeping the difficulty as close to the user's
/// level as possible.
class WordRecommendation {
  /// Maximum number of words surfaced in the "My Words" practice list.
  static const int defaultLimit = 20;

  /// Returns up to [limit] recommended words from [available].
  ///
  /// - [learnedWords]: words the user already knows (excluded).
  /// - [levels]: the user's active vocabulary levels (e.g. [1, 2]).
  /// - [enabledCategories]: if non-empty, only words in these categories are
  ///   considered (the user's goal / enabled word sets).
  static List<VocabularyWord> recommend({
    required List<VocabularyWord> available,
    required Set<String> learnedWords,
    required List<int> levels,
    Set<String> enabledCategories = const {},
    int limit = defaultLimit,
  }) {
    if (available.isEmpty || levels.isEmpty || limit <= 0) return [];

    final targetDifficulties =
        levels.map(difficultyForLevel).toSet();
    final targetRanks = targetDifficulties.map(_difficultyRank).toSet();

    // Pool: unlearned words, optionally restricted to enabled categories.
    final pool = available.where((w) {
      if (learnedWords.contains(w.word)) return false;
      if (enabledCategories.isEmpty) return true;
      return enabledCategories.contains(w.category);
    }).toList();

    if (pool.isEmpty) return [];

    // Strict band: words whose difficulty matches one of the user's levels.
    final strict =
        pool.where((w) => targetDifficulties.contains(w.difficulty)).toList();
    _sortByDifficultyThenWord(strict);
    if (strict.length >= limit) return strict.sublist(0, limit);

    // Fill from nearest difficulties (distance 1, then 2…) so the list is
    // never empty while staying as accurate to the user's level as possible.
    final result = List<VocabularyWord>.from(strict);
    final used = strict.map((w) => w.word).toSet();
    for (var distance = 1; distance <= 2 && result.length < limit; distance++) {
      final ring = pool
          .where((w) =>
              !used.contains(w.word) &&
              targetRanks
                  .any((r) => (_difficultyRank(w.difficulty) - r).abs() == distance))
          .toList();
      _sortByDifficultyThenWord(ring);
      for (final w in ring) {
        if (result.length >= limit) break;
        result.add(w);
        used.add(w.word);
      }
    }

    // Last resort: any remaining word (alphabetical) — keeps My Words alive
    // even on sparse datasets.
    if (result.length < limit) {
      final rest = pool.where((w) => !used.contains(w.word)).toList()
        ..sort((a, b) => a.word.compareTo(b.word));
      for (final w in rest) {
        if (result.length >= limit) break;
        result.add(w);
      }
    }

    return result;
  }

  static void _sortByDifficultyThenWord(List<VocabularyWord> words) {
    words.sort((a, b) {
      final byDifficulty =
          _difficultyRank(a.difficulty).compareTo(_difficultyRank(b.difficulty));
      if (byDifficulty != 0) return byDifficulty;
      return a.word.compareTo(b.word);
    });
  }

  /// Parses a comma-separated level string (e.g. "1,2") into sorted levels.
  /// Falls back to [1] when nothing parses.
  static List<int> parseLevels(String? raw) {
    final levels = (raw ?? '')
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .where((l) => l > 0)
        .toSet()
        .toList()
      ..sort();
    return levels.isEmpty ? [1] : levels;
  }
}
