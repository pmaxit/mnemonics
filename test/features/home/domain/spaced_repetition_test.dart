import 'package:flutter_test/flutter_test.dart';
import 'package:mnemonics/features/home/domain/spaced_repetition.dart';

void main() {
  group('SpacedRepetitionManager', () {
    final now = DateTime(2025, 1, 1, 12, 0, 0);

    test('First review with EASY rating should jump to 6 day interval', () {
      final result = SpacedRepetitionManager.calculateNextReview(
        now,
        ReviewRating.easy,
        0, // current interval
        0, // repetitions
        2.5, // ease factor
      );

      expect(result.interval, 1);
      expect(result.repetitions, 1);
      // Quality 5 -> nextEaseFactor = 2.5 + (0.1 - (5-5)*(...)) = 2.6
      expect(result.easeFactor, 2.6);
      expect(result.nextReview, now.add(const Duration(days: 1)));
    });

    test('Second review with EASY rating should use 6 day interval', () {
      final result = SpacedRepetitionManager.calculateNextReview(
        now,
        ReviewRating.easy,
        1, // current interval
        1, // repetitions
        2.6, // ease factor
      );

      expect(result.interval, 6);
      expect(result.repetitions, 2);
      expect(result.easeFactor, 2.7);
      expect(result.nextReview, now.add(const Duration(days: 6)));
    });

    test('Subsequent reviews multiply by ease factor', () {
      final result = SpacedRepetitionManager.calculateNextReview(
        now,
        ReviewRating.easy,
        6, // current interval
        2, // repetitions
        2.7, // ease factor
      );

      expect(result.interval, (6 * 2.7).round());
      expect(result.repetitions, 3);
      expect(result.easeFactor, closeTo(2.8, 0.001));
    });

    test('MEDIUM rating should keep ease factor same', () {
      final result = SpacedRepetitionManager.calculateNextReview(
        now,
        ReviewRating.medium, // Maps to Quality 3
        6,
        2,
        2.5,
      );

      expect(result.interval, (6 * 2.5).round());
      expect(result.repetitions, 3);
      // Quality 3 -> nextEaseFactor = 2.5 + (0.1 - (5-3)*(0.08 + (5-3)*0.02))
      // = 2.5 + (0.1 - 2*(0.08 + 0.04)) = 2.5 + (0.1 - 2*(0.12)) = 2.5 - 0.14 = 2.36
      expect(result.easeFactor, closeTo(2.36, 0.001));
    });

    test('HARD rating should reset repetitions and drop ease factor', () {
      final result = SpacedRepetitionManager.calculateNextReview(
        now,
        ReviewRating.hard, // Maps to Quality 1
        10,
        3,
        2.5,
      );

      expect(result.interval, 1);
      expect(result.repetitions, 0);
      // Quality 1 -> nextEaseFactor = 2.5 + (0.1 - 4*(0.08 + 4*0.02))
      // = 2.5 + (0.1 - 4*(0.16)) = 2.5 - 0.54 = 1.96
      expect(result.easeFactor, closeTo(1.96, 0.001));
    });

    test('Ease factor should not drop below 1.3', () {
      final result = SpacedRepetitionManager.calculateNextReview(
        now,
        ReviewRating.hard,
        1,
        0,
        1.3,
      );

      expect(result.easeFactor, 1.3);
    });
  });
}
