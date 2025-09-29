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
  
  final learned = userData.where((d) => d.isLearned).toList();
  final totalLearned = learned.length;
  
  final learnedToday = userData.where((d) => 
    d.firstLearnedAt != null && 
    _isSameDay(d.firstLearnedAt!, today)
  ).length;
  
  final newCount = userData.where((d) => d.learningStage == 'new').length;
  final inProgressCount = userData.where((d) => d.isInProgress).length;
  final masteredCount = userData.where((d) => d.isMastered).length;
  
  final categoryBreakdown = <String, int>{};
  final difficultyBreakdown = <String, int>{};
  
  for (final userWord in userData) {
    final vocabWord = vocab.firstWhere(
      (v) => v.word == userWord.word,
      orElse: () => VocabularyWord(
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
    
    if (userWord.isLearned || userWord.isInProgress) {
      categoryBreakdown[vocabWord.category] = (categoryBreakdown[vocabWord.category] ?? 0) + 1;
      difficultyBreakdown[vocabWord.difficulty.name] = (difficultyBreakdown[vocabWord.difficulty.name] ?? 0) + 1;
    }
  }
  
  final weeklyProgress = _calculateWeeklyProgress(userData, reviewActivities);
  
  final totalAnswers = userData.fold(0, (sum, d) => sum + d.totalAnswers);
  final correctAnswers = userData.fold(0, (sum, d) => sum + d.correctAnswers);
  final averageAccuracy = totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;
  
  final totalReviews = reviewActivities.length;
  final streak = _calculateStreak(userData);
  
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
        .where((d) => d.firstLearnedAt != null && _isSameDay(d.firstLearnedAt!, date))
        .length;
    
    final reviewsCompleted = reviewActivities
        .where((r) => _isSameDay(r.reviewedAt, date))
        .length;
    
    weeklyProgress.add(DailyProgress(
      date: date,
      wordsLearned: wordsLearned,
      reviewsCompleted: reviewsCompleted,
    ));
  }
  
  return weeklyProgress;
}

int _calculateStreak(List<UserWordData> userData) {
  final now = DateTime.now();
  int streak = 0;
  
  for (int i = 0; i < 365; i++) {
    final date = DateTime(now.year, now.month, now.day - i);
    final hasActivity = userData.any((d) => 
      d.firstLearnedAt != null && _isSameDay(d.firstLearnedAt!, date)
    );
    
    if (hasActivity) {
      streak++;
    } else {
      break;
    }
  }
  
  return streak;
}