import 'package:flutter_test/flutter_test.dart';
import 'package:mnemonics/features/home/domain/user_word_data.dart';
import 'package:mnemonics/features/home/domain/vocabulary_word.dart';
import 'package:mnemonics/features/home/domain/review_activity.dart';
import 'package:mnemonics/features/profile/providers/profile_statistics_provider.dart';
import 'package:mnemonics/features/profile/domain/user_statistics.dart';

void main() {
  group('calculateProfileStatistics', () {
    test('accurately calculates total words and streaks', () {
      final now = DateTime.now();

      final vocab = [
        const VocabularyWord(
            word: 'dog',
            meaning: '',
            mnemonic: '',
            example: '',
            synonyms: [],
            antonyms: [],
            difficulty: WordDifficulty.basic,
            category: 'animals'),
        const VocabularyWord(
            word: 'cat',
            meaning: '',
            mnemonic: '',
            example: '',
            synonyms: [],
            antonyms: [],
            difficulty: WordDifficulty.basic,
            category: 'animals'),
      ];

      final userData = [
        UserWordData(
            word: 'dog',
            isLearned: true,
            firstLearnedAt: now,
            lastReviewedAt: now,
            totalAnswers: 10,
            correctAnswers: 8),
        UserWordData(
            word: 'cat',
            isLearned: true,
            firstLearnedAt: now.subtract(const Duration(days: 1)),
            lastReviewedAt: now,
            totalAnswers: 5,
            correctAnswers: 5),
      ];

      final reviewActivities = [
        ReviewActivity(
            word: 'dog', reviewedAt: now, rating: ReviewDifficultyRating.easy),
        ReviewActivity(
            word: 'cat',
            reviewedAt: now.subtract(const Duration(days: 1)),
            rating: ReviewDifficultyRating.easy),
      ];

      final stats =
          calculateProfileStatistics(vocab, userData, reviewActivities, null);

      expect(stats.totalWordsLearned, 2);
      expect(stats.wordsLearnedToday, 1); // 'dog' learned today
      expect(stats.currentStreak, 2); // Today and yesterday
      expect(stats.longestStreak, 2);
      expect(stats.totalStudyTimeMinutes, 2); // 2 review activities
      expect(stats.averageAccuracy, (8 + 5) / (10 + 5)); // 13 / 15
    });

    test('accuracy handles zero reviews gracefully', () {
      final stats = calculateProfileStatistics([], [], [], null);
      expect(stats.totalWordsLearned, 0);
      expect(stats.averageAccuracy, 0.0);
      expect(stats.currentStreak, 0);
    });
  });
}
