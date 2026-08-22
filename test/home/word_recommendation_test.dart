import 'package:flutter_test/flutter_test.dart';
import 'package:mnemonics/features/home/domain/vocabulary_word.dart';
import 'package:mnemonics/features/home/domain/word_recommendation.dart';
import 'package:mnemonics/features/profile/domain/user_statistics.dart';

VocabularyWord _w(String word, WordDifficulty difficulty,
        {String category = 'common'}) =>
    VocabularyWord(
      word: word,
      meaning: 'meaning of $word',
      mnemonic: 'mnemonic',
      example: 'example',
      synonyms: [],
      antonyms: [],
      difficulty: difficulty,
      category: category,
    );

void main() {
  final allWords = [
    _w('alpha', WordDifficulty.basic, category: 'character'),
    _w('beta', WordDifficulty.basic, category: 'character'),
    _w('gamma', WordDifficulty.intermediate, category: 'speech'),
    _w('delta', WordDifficulty.intermediate, category: 'speech'),
    _w('epsilon', WordDifficulty.intermediate, category: 'intellect'),
    _w('zeta', WordDifficulty.advanced, category: 'morality'),
    _w('eta', WordDifficulty.advanced, category: 'morality'),
  ];

  group('difficultyForLevel', () {
    test('maps levels to difficulties', () {
      expect(difficultyForLevel(1), WordDifficulty.basic);
      expect(difficultyForLevel(0), WordDifficulty.basic);
      expect(difficultyForLevel(2), WordDifficulty.intermediate);
      expect(difficultyForLevel(3), WordDifficulty.advanced);
      expect(difficultyForLevel(6), WordDifficulty.advanced);
    });
  });

  group('WordRecommendation.parseLevels', () {
    test('parses comma-separated levels', () {
      expect(WordRecommendation.parseLevels('1,2'), [1, 2]);
      expect(WordRecommendation.parseLevels('3, 1'), [1, 3]);
    });

    test('falls back to level 1 on empty/invalid input', () {
      expect(WordRecommendation.parseLevels(null), [1]);
      expect(WordRecommendation.parseLevels(''), [1]);
      expect(WordRecommendation.parseLevels('abc'), [1]);
      expect(WordRecommendation.parseLevels('0,-2'), [1]);
    });
  });

  group('WordRecommendation.recommend', () {
    test('level 1 user gets only basic words', () {
      final rec = WordRecommendation.recommend(
        available: allWords,
        learnedWords: {},
        levels: [1],
        limit: 2, // exactly the size of the basic band
      );
      expect(rec.map((w) => w.word).toSet(), {'alpha', 'beta'});
      expect(rec.every((w) => w.difficulty == WordDifficulty.basic), true);
    });

    test('level 2 user gets intermediate words', () {
      final rec = WordRecommendation.recommend(
        available: allWords,
        learnedWords: {},
        levels: [2],
        limit: 3, // exactly the size of the intermediate band
      );
      expect(rec.map((w) => w.word).toSet(), {'gamma', 'delta', 'epsilon'});
    });

    test('multi-level user gets union of bands', () {
      final rec = WordRecommendation.recommend(
        available: allWords,
        learnedWords: {},
        levels: [1, 3],
        limit: 4, // exactly the union of basic + advanced bands
      );
      expect(rec.map((w) => w.word).toSet(),
          {'alpha', 'beta', 'zeta', 'eta'});
    });

    test('already-learned words are excluded', () {
      final rec = WordRecommendation.recommend(
        available: allWords,
        learnedWords: {'alpha'},
        levels: [1],
        limit: 1, // exactly the remaining basic word
      );
      expect(rec.map((w) => w.word), ['beta']);
    });

    test('enabled categories restrict the pool', () {
      final rec = WordRecommendation.recommend(
        available: allWords,
        learnedWords: {},
        levels: [2],
        enabledCategories: {'speech'},
        limit: 2,
      );
      expect(rec.map((w) => w.word).toSet(), {'gamma', 'delta'});
    });

    test('fills from nearest difficulty when band is exhausted', () {
      // Level 1 band has 2 basics; limit 4 → fills with 2 nearest
      // (intermediates, distance 1), never skipping to distance 2 first.
      final rec = WordRecommendation.recommend(
        available: allWords,
        learnedWords: {},
        levels: [1],
        limit: 4,
      );
      expect(rec.length, 4);
      expect(rec.take(2).map((w) => w.word).toSet(), {'alpha', 'beta'});
      expect(
        rec.skip(2).every((w) => w.difficulty == WordDifficulty.intermediate),
        true,
      );
    });

    test('respects limit and sorts strictly by difficulty then word', () {
      final rec = WordRecommendation.recommend(
        available: allWords,
        learnedWords: {},
        levels: [2],
        limit: 2,
      );
      expect(rec.map((w) => w.word), ['delta', 'epsilon']);
    });

    test('empty pool returns empty list', () {
      expect(
        WordRecommendation.recommend(
          available: allWords,
          learnedWords: allWords.map((w) => w.word).toSet(),
          levels: [2],
        ),
        isEmpty,
      );
      expect(
        WordRecommendation.recommend(
          available: [],
          learnedWords: {},
          levels: [1],
        ),
        isEmpty,
      );
    });

    test('results are deterministic (alphabetical tie-break)', () {
      final a = WordRecommendation.recommend(
          available: allWords, learnedWords: {}, levels: [2]);
      final b = WordRecommendation.recommend(
          available: allWords.reversed.toList(), learnedWords: {}, levels: [2]);
      expect(a.map((w) => w.word), b.map((w) => w.word));
    });
  });
}
