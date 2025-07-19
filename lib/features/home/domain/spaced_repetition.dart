enum ReviewRating { hard, medium, easy }

class SpacedRepetitionManager {
  /// Returns the next review time based on the user's rating.
  static DateTime calculateNextReview(DateTime now, ReviewRating rating) {
    switch (rating) {
      case ReviewRating.hard:
        return now.add(const Duration(days: 1));
      case ReviewRating.medium:
        return now.add(const Duration(days: 3));
      case ReviewRating.easy:
        return now.add(const Duration(days: 7));
    }
  }
} 