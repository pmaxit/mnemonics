enum ReviewRating { hard, medium, easy }

class SpacedRepetitionResult {
  final DateTime nextReview;
  final int interval;
  final int repetitions;
  final double easeFactor;

  SpacedRepetitionResult({
    required this.nextReview,
    required this.interval,
    required this.repetitions,
    required this.easeFactor,
  });
}

class SpacedRepetitionManager {
  /// Calculates the next review time and SM-2 parameters based on the user's rating.
  /// Standard SM-2 Algorithm mapping:
  /// easy (Quality 5) -> correct response, perfect hesitation
  /// medium (Quality 3.5ish) -> correct response remembered with serious difficulty
  /// hard (Quality 1ish) -> incorrect response
  static SpacedRepetitionResult calculateNextReview(
    DateTime now,
    ReviewRating rating,
    int currentInterval,
    int repetitions,
    double easeFactor,
  ) {
    int nextInterval;
    int nextRepetitions = repetitions;
    double nextEaseFactor = easeFactor;

    int quality;
    switch (rating) {
      case ReviewRating.easy:
        quality = 5;
        break;
      case ReviewRating.medium:
        quality = 3;
        break;
      case ReviewRating.hard:
        quality = 1;
        break;
    }

    if (quality >= 3) {
      if (repetitions == 0) {
        nextInterval = 1;
      } else if (repetitions == 1) {
        nextInterval = 6;
      } else {
        nextInterval = (currentInterval * easeFactor).round();
      }
      nextRepetitions++;
    } else {
      nextRepetitions = 0;
      nextInterval = 1;
    }

    nextEaseFactor =
        easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (nextEaseFactor < 1.3) {
      nextEaseFactor = 1.3;
    }

    return SpacedRepetitionResult(
      nextReview: now.add(Duration(days: nextInterval)),
      interval: nextInterval,
      repetitions: nextRepetitions,
      easeFactor: nextEaseFactor,
    );
  }
}
