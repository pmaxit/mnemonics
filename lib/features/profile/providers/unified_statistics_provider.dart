import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers.dart';
import '../../home/domain/user_word_data.dart';
import '../../home/domain/vocabulary_word.dart';
import '../../home/domain/review_activity.dart';
import '../domain/user_statistics.dart';
import '../domain/user_info.dart';
import 'user_info_provider.dart';

final unifiedStatisticsProvider = FutureProvider<UserStatistics>((ref) async {
  final vocabAsync = ref.watch(vocabularyListProvider);
  final userDataAsync = ref.watch(allUserWordDataProvider);
  final reviewActivitiesAsync = ref.watch(reviewActivityListProvider);
  final userInfoAsync = ref.watch(currentUserProvider);

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

  final userInfo = userInfoAsync.when(
    data: (data) => data,
    loading: () => null,
    error: (error, stack) => null,
  );

  return _calculateUnifiedStatistics(vocab, userData, reviewActivities, userInfo);
});

UserStatistics _calculateUnifiedStatistics(
  List<VocabularyWord> vocab,
  List<UserWordData> userData,
  List<ReviewActivity> reviewActivities,
  UserInfo? userInfo,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Basic Statistics
  final totalWordsLearned = userData.where((d) => d.isLearned).length;
  final wordsLearnedToday = userData.where((d) => 
    d.isLearned &&
    d.firstLearnedAt != null && 
    _isSameDay(d.firstLearnedAt!, today)
  ).length;
  
  // Weekly statistics
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));
  
  final wordsThisWeek = userData.where((d) => 
    d.isLearned &&
    d.firstLearnedAt != null && 
    d.firstLearnedAt!.isAfter(weekStart) && 
    d.firstLearnedAt!.isBefore(weekEnd.add(const Duration(days: 1)))
  ).length;
  
  // Calculate current streak
  final currentStreak = _calculateCurrentStreak(userData, reviewActivities);
  final longestStreak = _calculateLongestStreak(userData, reviewActivities);
  
  // Calculate average accuracy
  final totalAnswers = userData.fold<int>(0, (sum, d) => sum + d.totalAnswers);
  final correctAnswers = userData.fold<int>(0, (sum, d) => sum + d.correctAnswers);
  final averageAccuracy = totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;
  
  // Calculate study time (estimated 1 minute per review activity)
  final totalStudyTimeMinutes = reviewActivities.length;
  
  // Calculate learning velocity (words per week over last 4 weeks)
  final fourWeeksAgo = today.subtract(const Duration(days: 28));
  final recentWords = userData.where((d) => 
    d.firstLearnedAt != null && 
    d.firstLearnedAt!.isAfter(fourWeeksAgo)
  ).length;
  final learningVelocity = recentWords / 4.0;
  
  // Difficulty breakdown
  final difficultyStats = <WordDifficulty, DifficultyProgress>{};
  for (final difficulty in WordDifficulty.values) {
    final wordsInDifficulty = vocab.where((v) => v.difficulty == difficulty);
    final learnedWordsInDifficulty = userData.where((u) => 
      u.isLearned && 
      wordsInDifficulty.any((v) => v.word == u.word)
    );
    final inProgressWordsInDifficulty = userData.where((u) => 
      u.isInProgress && 
      wordsInDifficulty.any((v) => v.word == u.word)
    );
    
    final totalReviews = userData.where((u) => 
      wordsInDifficulty.any((v) => v.word == u.word)
    ).fold<int>(0, (sum, u) => sum + u.reviewCount);
    
    final accuracyInDifficulty = _calculateAccuracyForWords(
      userData.where((u) => wordsInDifficulty.any((v) => v.word == u.word)).toList()
    );
    
    final lastReviewedAt = userData
        .where((u) => wordsInDifficulty.any((v) => v.word == u.word) && u.lastReviewedAt != null)
        .map((u) => u.lastReviewedAt!)
        .fold<DateTime?>(null, (latest, date) => 
          latest == null || date.isAfter(latest) ? date : latest);
    
    difficultyStats[difficulty] = DifficultyProgress(
      difficulty: difficulty,
      totalWords: wordsInDifficulty.length,
      wordsLearned: learnedWordsInDifficulty.length,
      wordsInProgress: inProgressWordsInDifficulty.length,
      averageAccuracy: accuracyInDifficulty,
      totalReviews: totalReviews,
      lastReviewedAt: lastReviewedAt,
    );
  }
  
  // Category breakdown
  final categoryStats = <String, CategoryProgress>{};
  final categories = vocab.map((v) => v.category).toSet();
  
  for (final category in categories) {
    final wordsInCategory = vocab.where((v) => v.category == category);
    final learnedWordsInCategory = userData.where((u) => 
      u.isLearned && 
      wordsInCategory.any((v) => v.word == u.word)
    );
    final inProgressWordsInCategory = userData.where((u) => 
      u.isInProgress && 
      wordsInCategory.any((v) => v.word == u.word)
    );
    
    final accuracyInCategory = _calculateAccuracyForWords(
      userData.where((u) => wordsInCategory.any((v) => v.word == u.word)).toList()
    );
    
    final difficultyBreakdown = <WordDifficulty, int>{};
    for (final difficulty in WordDifficulty.values) {
      difficultyBreakdown[difficulty] = wordsInCategory
          .where((v) => v.difficulty == difficulty)
          .length;
    }
    
    final lastReviewedAt = userData
        .where((u) => wordsInCategory.any((v) => v.word == u.word) && u.lastReviewedAt != null)
        .map((u) => u.lastReviewedAt!)
        .fold<DateTime?>(null, (latest, date) => 
          latest == null || date.isAfter(latest) ? date : latest);
    
    categoryStats[category] = CategoryProgress(
      categoryName: category,
      totalWords: wordsInCategory.length,
      wordsLearned: learnedWordsInCategory.length,
      wordsInProgress: inProgressWordsInCategory.length,
      averageAccuracy: accuracyInCategory,
      difficultyBreakdown: difficultyBreakdown,
      lastReviewedAt: lastReviewedAt,
    );
  }
  
  // Learning stage breakdown
  final stageBreakdown = <LearningStage, int>{};
  for (final stage in LearningStage.values) {
    stageBreakdown[stage] = userData.where((u) => u.learningStage == stage).length;
  }
  
  // Recent actions (convert from review activities)
  final recentActions = reviewActivities
      .take(50) // Last 50 activities
      .map((activity) {
        final vocabWord = vocab.firstWhere(
          (v) => v.word == activity.word,
          orElse: () => VocabularyWord(
            word: activity.word,
            meaning: '',
            mnemonic: '',
            example: '',
            synonyms: [],
            antonyms: [],
            difficulty: WordDifficulty.intermediate,
            category: 'Unknown',
          ),
        );
        
        final userWord = userData.firstWhere(
          (u) => u.word == activity.word,
          orElse: () => UserWordData(word: activity.word),
        );
        
        return UserReviewAction(
          word: activity.word,
          category: vocabWord.category,
          wordDifficulty: vocabWord.difficulty,
          actionType: ReviewActionType.review,
          userRating: activity.rating,
          timestamp: activity.reviewedAt,
          timeSpent: const Duration(minutes: 1), // Estimated
          wasCorrect: activity.rating == ReviewDifficultyRating.easy,
          previousStage: userWord.learningStage,
          newStage: userWord.learningStage,
        );
      })
      .toList()
      .reversed
      .toList();
  
  // Weekly progress
  final weeklyProgress = _calculateWeeklyProgress(userData, reviewActivities, vocab);
  
  // Generate milestones
  final milestones = _generateMilestones(
    totalWordsLearned, 
    currentStreak, 
    averageAccuracy, 
    categoryStats
  );
  
  return UserStatistics(
    totalWordsLearned: totalWordsLearned,
    wordsLearnedToday: wordsLearnedToday,
    wordsLearnedThisWeek: wordsThisWeek,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    averageAccuracy: averageAccuracy,
    totalStudyTimeMinutes: totalStudyTimeMinutes,
    difficultyStats: difficultyStats,
    categoryStats: categoryStats,
    stageBreakdown: stageBreakdown,
    recentActions: recentActions,
    weeklyProgress: weeklyProgress,
    learningVelocity: learningVelocity,
    milestones: milestones,
    joinDate: userInfo?.joinedDate,
  );
}

double _calculateAccuracyForWords(List<UserWordData> words) {
  final totalAnswers = words.fold<int>(0, (sum, w) => sum + w.totalAnswers);
  final correctAnswers = words.fold<int>(0, (sum, w) => sum + w.correctAnswers);
  return totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;
}

int _calculateCurrentStreak(List<UserWordData> userData, List<ReviewActivity> reviewActivities) {
  final now = DateTime.now();
  var currentDate = DateTime(now.year, now.month, now.day);
  var streak = 0;
  
  // Check if user studied today
  final studiedToday = reviewActivities.any((activity) => 
    _isSameDay(activity.reviewedAt, currentDate)
  );
  
  if (studiedToday) {
    streak = 1;
    currentDate = currentDate.subtract(const Duration(days: 1));
  } else {
    // Check if user studied yesterday
    final studiedYesterday = reviewActivities.any((activity) => 
      _isSameDay(activity.reviewedAt, currentDate.subtract(const Duration(days: 1)))
    );
    
    if (!studiedYesterday) {
      return 0; // Streak is broken
    }
    
    currentDate = currentDate.subtract(const Duration(days: 1));
  }
  
  // Count consecutive days
  while (true) {
    final studiedThisDay = reviewActivities.any((activity) => 
      _isSameDay(activity.reviewedAt, currentDate)
    );
    
    if (!studiedThisDay) {
      break;
    }
    
    streak++;
    currentDate = currentDate.subtract(const Duration(days: 1));
  }
  
  return streak;
}

int _calculateLongestStreak(List<UserWordData> userData, List<ReviewActivity> reviewActivities) {
  if (reviewActivities.isEmpty) return 0;
  
  final sortedActivities = reviewActivities
      .map((a) => DateTime(a.reviewedAt.year, a.reviewedAt.month, a.reviewedAt.day))
      .toSet()
      .toList()
    ..sort();
  
  var longestStreak = 1;
  var currentStreak = 1;
  
  for (int i = 1; i < sortedActivities.length; i++) {
    final daysDiff = sortedActivities[i].difference(sortedActivities[i - 1]).inDays;
    
    if (daysDiff == 1) {
      currentStreak++;
      longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
    } else {
      currentStreak = 1;
    }
  }
  
  return longestStreak;
}

List<DailyProgress> _calculateWeeklyProgress(
  List<UserWordData> userData, 
  List<ReviewActivity> reviewActivities,
  List<VocabularyWord> vocab,
) {
  final now = DateTime.now();
  final weeklyProgress = <DailyProgress>[];
  
  for (int i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    
    final wordsLearnedThatDay = userData.where((u) => 
      u.firstLearnedAt != null && _isSameDay(u.firstLearnedAt!, date)
    ).length;
    
    final reviewsCompletedThatDay = reviewActivities.where((a) => 
      _isSameDay(a.reviewedAt, date)
    ).length;
    
    final difficultyBreakdown = <WordDifficulty, int>{};
    for (final difficulty in WordDifficulty.values) {
      difficultyBreakdown[difficulty] = userData.where((u) => 
        u.firstLearnedAt != null && 
        _isSameDay(u.firstLearnedAt!, date) &&
        vocab.any((v) => v.word == u.word && v.difficulty == difficulty)
      ).length;
    }
    
    final accuracyThatDay = _calculateAccuracyForDay(userData, reviewActivities, date);
    
    weeklyProgress.add(DailyProgress(
      date: date,
      wordsLearned: wordsLearnedThatDay,
      reviewsCompleted: reviewsCompletedThatDay,
      studyTimeMinutes: reviewsCompletedThatDay, // Estimated 1 min per review
      difficultyBreakdown: difficultyBreakdown,
      accuracyRate: accuracyThatDay,
    ));
  }
  
  return weeklyProgress;
}

double _calculateAccuracyForDay(
  List<UserWordData> userData, 
  List<ReviewActivity> reviewActivities, 
  DateTime date
) {
  final activitiesOnDate = reviewActivities.where((a) => _isSameDay(a.reviewedAt, date));
  if (activitiesOnDate.isEmpty) return 0.0;
  
  final correctCount = activitiesOnDate.where((a) => 
    a.rating == ReviewDifficultyRating.easy
  ).length;
  
  return correctCount / activitiesOnDate.length;
}

List<Milestone> _generateMilestones(
  int totalWordsLearned,
  int currentStreak, 
  double averageAccuracy,
  Map<String, CategoryProgress> categoryStats,
) {
  final milestones = <Milestone>[];
  
  // Vocabulary milestones
  final vocabMilestones = [10, 25, 50, 100, 250, 500, 1000];
  for (final target in vocabMilestones) {
    milestones.add(Milestone(
      id: 'vocab_$target',
      title: 'Learn $target Words',
      description: 'Master $target vocabulary words',
      type: MilestoneType.vocabulary,
      targetValue: target,
      currentValue: totalWordsLearned,
      isUnlocked: totalWordsLearned >= target,
      unlockedAt: totalWordsLearned >= target ? DateTime.now() : null,
    ));
  }
  
  // Consistency milestones
  final streakMilestones = [3, 7, 14, 30, 60, 100];
  for (final target in streakMilestones) {
    milestones.add(Milestone(
      id: 'streak_$target',
      title: '$target Day Streak',
      description: 'Study for $target consecutive days',
      type: MilestoneType.consistency,
      targetValue: target,
      currentValue: currentStreak,
      isUnlocked: currentStreak >= target,
      unlockedAt: currentStreak >= target ? DateTime.now() : null,
    ));
  }
  
  // Accuracy milestones
  final accuracyMilestones = [0.7, 0.8, 0.9, 0.95];
  for (final target in accuracyMilestones) {
    final percentage = (target * 100).round();
    milestones.add(Milestone(
      id: 'accuracy_$percentage',
      title: '$percentage% Accuracy',
      description: 'Achieve $percentage% overall accuracy',
      type: MilestoneType.accuracy,
      targetValue: percentage,
      currentValue: (averageAccuracy * 100).round(),
      isUnlocked: averageAccuracy >= target,
      unlockedAt: averageAccuracy >= target ? DateTime.now() : null,
    ));
  }
  
  return milestones;
}

bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year && 
         date1.month == date2.month && 
         date1.day == date2.day;
}