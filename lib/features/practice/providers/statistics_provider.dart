import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/statistics_data.dart';
import '../../home/providers.dart';
import '../../home/domain/user_word_data.dart';
import '../../home/domain/vocabulary_word.dart';
import '../../home/domain/review_activity.dart';
import '../../profile/domain/user_statistics.dart' hide DailyProgress;

final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  final vocabAsync = ref.watch(vocabularyListProvider);
  final userDataAsync = ref.watch(allUserWordDataProvider);
  final reviewActivitiesAsync = ref.watch(reviewActivityListProvider);

  final vocab = vocabAsync.when(
    data: (data) => data,
    loading: () => <VocabularyWord>[],
    error: (error, stack) => <VocabularyWord>[],
  );
  final userData = userDataAsync.when(
    data: (data) => data,
    loading: () => <UserWordData>[],
    error: (error, stack) => <UserWordData>[],
  );
  final reviewActivities = reviewActivitiesAsync.when(
    data: (data) => data,
    loading: () => <ReviewActivity>[],
    error: (error, stack) => <ReviewActivity>[],
  );

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final learned =
      userData.where((d) => d.hasBeenTested || d.isLearned).toList();
  final totalLearned = learned.length;

  final learnedToday = userData
      .where((d) =>
          (d.hasBeenTested || d.isLearned) &&
          d.lastReviewedAt != null &&
          _isSameDay(d.lastReviewedAt!, today))
      .length;

  final newCount =
      userData.where((d) => !d.hasBeenTested && !d.isLearned).length;
  final inProgressCount = userData
      .where((d) => (d.hasBeenTested || d.isLearned) && d.isInProgress)
      .length;
  final masteredCount = userData
      .where((d) => (d.hasBeenTested || d.isLearned) && d.isMastered)
      .length;

  final categoryBreakdown = <String, int>{};
  final difficultyBreakdown = <String, int>{};

  for (final userWord in userData) {
    final vocabWord = vocab.firstWhere(
      (v) => v.word == userWord.word,
      orElse: () => const VocabularyWord(
        word: '',
        meaning: '',
        mnemonic: '',
        example: '',
        synonyms: [],
        antonyms: [],
        difficulty: WordDifficulty.intermediate,
        category: 'Unknown',
      ),
    );

    if (userWord.hasBeenTested || userWord.isLearned) {
      categoryBreakdown[vocabWord.category] =
          (categoryBreakdown[vocabWord.category] ?? 0) + 1;
      difficultyBreakdown[vocabWord.difficulty.name] =
          (difficultyBreakdown[vocabWord.difficulty.name] ?? 0) + 1;
    }
  }

  final weeklyProgress = _calculateWeeklyProgress(userData, reviewActivities);

  final testedWords =
      userData.where((d) => d.hasBeenTested || d.isLearned).toList();
  final totalAnswers = testedWords.fold(0, (sum, d) => sum + d.totalAnswers);
  final correctAnswers =
      testedWords.fold(0, (sum, d) => sum + d.correctAnswers);
  final averageAccuracy =
      totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;

  final totalReviews = reviewActivities.length;
  final streak = _calculateStreak(userData, reviewActivities);

  return StatisticsData(
    totalLearned: totalLearned,
    learnedToday: learnedToday,
    newCount: newCount,
    inProgressCount: inProgressCount,
    masteredCount: masteredCount,
    categoryBreakdown: categoryBreakdown,
    difficultyBreakdown: difficultyBreakdown,
    weeklyProgress: weeklyProgress,
    averageAccuracy: averageAccuracy,
    totalReviews: totalReviews,
    streak: streak,
  );
});

bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

List<DailyProgress> _calculateWeeklyProgress(
  List<UserWordData> userData,
  List<dynamic> reviewActivities,
) {
  final now = DateTime.now();
  final weeklyProgress = <DailyProgress>[];

  for (int i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day - i);

    final wordsLearned = userData
        .where((d) =>
            (d.hasBeenTested || d.isLearned) &&
            d.lastReviewedAt != null &&
            _isSameDay(d.lastReviewedAt!, date))
        .length;

    final reviewsCompleted =
        reviewActivities.where((r) => _isSameDay(r.reviewedAt, date)).length;

    weeklyProgress.add(DailyProgress(
      date: date,
      wordsLearned: wordsLearned,
      reviewsCompleted: reviewsCompleted,
    ));
  }

  return weeklyProgress;
}

int _calculateStreak(
    List<UserWordData> userData, List<ReviewActivity> reviewActivities) {
  if (userData.isEmpty && reviewActivities.isEmpty) return 0;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Get all unique days with learning activity
  final activeDays = <DateTime>{};

  // Add days from user word data (only for actually tested/learned words)
  for (final data in userData) {
    if ((data.hasBeenTested || data.isLearned) && data.lastReviewedAt != null) {
      final day = DateTime(
        data.lastReviewedAt!.year,
        data.lastReviewedAt!.month,
        data.lastReviewedAt!.day,
      );
      activeDays.add(day);
    }
  }

  // Add days from review activities
  for (final activity in reviewActivities) {
    final day = DateTime(
      activity.reviewedAt.year,
      activity.reviewedAt.month,
      activity.reviewedAt.day,
    );
    activeDays.add(day);
  }

  if (activeDays.isEmpty) return 0;

  // Check if there's activity today or yesterday (to allow for different timezones)
  final yesterday = today.subtract(const Duration(days: 1));
  if (!activeDays.contains(today) && !activeDays.contains(yesterday)) {
    return 0;
  }

  int streak = 0;
  DateTime currentDay = activeDays.contains(today) ? today : yesterday;

  while (activeDays.contains(currentDay)) {
    streak++;
    currentDay = currentDay.subtract(const Duration(days: 1));
  }

  return streak;
}
