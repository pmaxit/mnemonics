import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers.dart';
import '../../home/domain/user_word_data.dart';
import '../../home/domain/vocabulary_word.dart';
import '../../home/domain/review_activity.dart';
import '../domain/profile_statistics.dart';
import '../domain/user_info.dart';
import 'user_info_provider.dart';

final profileStatisticsProvider = FutureProvider<ProfileStatistics>((ref) async {
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

  return _calculateProfileStatistics(vocab, userData, reviewActivities, userInfo);
});

ProfileStatistics _calculateProfileStatistics(
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
    d.firstLearnedAt != null && 
    _isSameDay(d.firstLearnedAt!, today)
  ).length;
  
  // Calculate current streak
  final currentStreak = _calculateCurrentStreak(userData, reviewActivities);
  
  // Calculate total study time from review activities
  // Since ReviewActivity doesn't have duration, we'll estimate based on number of activities
  // Each review activity is estimated to take 1 minute
  final totalStudyTimeMinutes = reviewActivities.length;
  
  // Calculate average accuracy
  final totalAnswers = userData.fold<int>(0, (sum, d) => sum + d.totalAnswers);
  final correctAnswers = userData.fold<int>(0, (sum, d) => sum + d.correctAnswers);
  final averageAccuracy = totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;
  
  // Weekly statistics
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));
  
  final wordsThisWeek = userData.where((d) => 
    d.firstLearnedAt != null && 
    d.firstLearnedAt!.isAfter(weekStart) && 
    d.firstLearnedAt!.isBefore(weekEnd.add(const Duration(days: 1)))
  ).length;
  
  final studySessionsThisWeek = reviewActivities.where((a) => 
    a.reviewedAt.isAfter(weekStart) && 
    a.reviewedAt.isBefore(weekEnd.add(const Duration(days: 1)))
  ).length;
  
  // Calculate learning velocity (words per week over last 4 weeks)
  final fourWeeksAgo = today.subtract(const Duration(days: 28));
  final recentWords = userData.where((d) => 
    d.firstLearnedAt != null && 
    d.firstLearnedAt!.isAfter(fourWeeksAgo)
  ).length;
  final learningVelocity = recentWords / 4.0; // words per week
  
  // Category breakdown
  final categoryStats = <String, CategoryStats>{};
  for (final userWord in userData.where((d) => d.isLearned)) {
    final vocabWord = vocab.firstWhere(
      (v) => v.word == userWord.word,
      orElse: () => VocabularyWord(
        word: userWord.word,
        meaning: '',
        mnemonic: '',
        example: '',
        synonyms: [],
        antonyms: [],
        difficulty: 'medium',
        category: 'general',
      ),
    );
    
    final category = vocabWord.category;
    if (!categoryStats.containsKey(category)) {
      categoryStats[category] = CategoryStats(
        categoryName: category,
        wordsLearned: 0,
        totalWords: vocab.where((v) => v.category == category).length,
        averageAccuracy: 0.0,
      );
    }
    
    categoryStats[category] = categoryStats[category]!.copyWith(
      wordsLearned: categoryStats[category]!.wordsLearned + 1,
    );
  }
  
  // Update category accuracy
  for (final category in categoryStats.keys) {
    final categoryUserData = userData.where((d) {
      final vocabWord = vocab.firstWhere(
        (v) => v.word == d.word,
        orElse: () => VocabularyWord(
          word: d.word,
          meaning: '',
          mnemonic: '',
          example: '',
          synonyms: [],
          antonyms: [],
          difficulty: 'medium',
          category: 'general',
        ),
      );
      return vocabWord.category == category && d.totalAnswers > 0;
    });
    
    if (categoryUserData.isNotEmpty) {
      final categoryTotalAnswers = categoryUserData.fold<int>(0, (sum, d) => sum + d.totalAnswers);
      final categoryCorrectAnswers = categoryUserData.fold<int>(0, (sum, d) => sum + d.correctAnswers);
      final categoryAccuracy = categoryTotalAnswers > 0 ? categoryCorrectAnswers / categoryTotalAnswers : 0.0;
      
      categoryStats[category] = categoryStats[category]!.copyWith(
        averageAccuracy: categoryAccuracy,
      );
    }
  }
  
  // Difficulty breakdown
  final difficultyStats = <String, DifficultyStats>{};
  for (final difficulty in ['easy', 'medium', 'hard']) {
    final difficultyWords = userData.where((d) {
      final vocabWord = vocab.firstWhere(
        (v) => v.word == d.word,
        orElse: () => VocabularyWord(
          word: d.word,
          meaning: '',
          mnemonic: '',
          example: '',
          synonyms: [],
          antonyms: [],
          difficulty: 'medium',
          category: 'general',
        ),
      );
      return vocabWord.difficulty == difficulty && d.isLearned;
    });
    
    final difficultyUserData = userData.where((d) {
      final vocabWord = vocab.firstWhere(
        (v) => v.word == d.word,
        orElse: () => VocabularyWord(
          word: d.word,
          meaning: '',
          mnemonic: '',
          example: '',
          synonyms: [],
          antonyms: [],
          difficulty: 'medium',
          category: 'general',
        ),
      );
      return vocabWord.difficulty == difficulty && d.totalAnswers > 0;
    });
    
    final difficultyTotalAnswers = difficultyUserData.fold<int>(0, (sum, d) => sum + d.totalAnswers);
    final difficultyCorrectAnswers = difficultyUserData.fold<int>(0, (sum, d) => sum + d.correctAnswers);
    final difficultyAccuracy = difficultyTotalAnswers > 0 ? difficultyCorrectAnswers / difficultyTotalAnswers : 0.0;
    
    difficultyStats[difficulty] = DifficultyStats(
      difficulty: difficulty,
      wordsLearned: difficultyWords.length,
      totalWords: vocab.where((v) => v.difficulty == difficulty).length,
      averageAccuracy: difficultyAccuracy,
    );
  }
  
  // Calculate milestones
  final milestones = _calculateMilestones(totalWordsLearned, currentStreak, totalStudyTimeMinutes);
  
  return ProfileStatistics(
    totalWordsLearned: totalWordsLearned,
    wordsLearnedToday: wordsLearnedToday,
    wordsLearnedThisWeek: wordsThisWeek,
    currentStreak: currentStreak,
    longestStreak: _calculateLongestStreak(userData, reviewActivities),
    totalStudyTimeMinutes: totalStudyTimeMinutes,
    averageAccuracy: averageAccuracy,
    studySessionsThisWeek: studySessionsThisWeek,
    learningVelocity: learningVelocity,
    categoryStats: categoryStats.values.toList(),
    difficultyStats: difficultyStats.values.toList(),
    milestones: milestones,
    joinDate: userInfo?.joinedDate ?? _calculateJoinDate(userData),
  );
}

int _calculateCurrentStreak(List<UserWordData> userData, List<ReviewActivity> reviewActivities) {
  if (userData.isEmpty && reviewActivities.isEmpty) return 0;
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Get all unique days with learning activity
  final activeDays = <DateTime>{};
  
  // Add days from user word data
  for (final data in userData) {
    if (data.firstLearnedAt != null) {
      final day = DateTime(
        data.firstLearnedAt!.year,
        data.firstLearnedAt!.month,
        data.firstLearnedAt!.day,
      );
      activeDays.add(day);
    }
    if (data.lastReviewedAt != null) {
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
  
  final sortedDays = activeDays.toList()..sort((a, b) => b.compareTo(a));
  
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

int _calculateLongestStreak(List<UserWordData> userData, List<ReviewActivity> reviewActivities) {
  if (userData.isEmpty && reviewActivities.isEmpty) return 0;
  
  // Get all unique days with learning activity
  final activeDays = <DateTime>{};
  
  for (final data in userData) {
    if (data.firstLearnedAt != null) {
      final day = DateTime(
        data.firstLearnedAt!.year,
        data.firstLearnedAt!.month,
        data.firstLearnedAt!.day,
      );
      activeDays.add(day);
    }
    if (data.lastReviewedAt != null) {
      final day = DateTime(
        data.lastReviewedAt!.year,
        data.lastReviewedAt!.month,
        data.lastReviewedAt!.day,
      );
      activeDays.add(day);
    }
  }
  
  for (final activity in reviewActivities) {
    final day = DateTime(
      activity.reviewedAt.year,
      activity.reviewedAt.month,
      activity.reviewedAt.day,
    );
    activeDays.add(day);
  }
  
  if (activeDays.isEmpty) return 0;
  
  final sortedDays = activeDays.toList()..sort();
  
  int longestStreak = 1;
  int currentStreak = 1;
  
  for (int i = 1; i < sortedDays.length; i++) {
    final difference = sortedDays[i].difference(sortedDays[i - 1]).inDays;
    if (difference == 1) {
      currentStreak++;
      longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
    } else {
      currentStreak = 1;
    }
  }
  
  return longestStreak;
}

DateTime? _calculateJoinDate(List<UserWordData> userData) {
  if (userData.isEmpty) return null;
  
  final firstLearned = userData
      .where((d) => d.firstLearnedAt != null)
      .map((d) => d.firstLearnedAt!)
      .fold<DateTime?>(null, (earliest, date) {
    if (earliest == null || date.isBefore(earliest)) {
      return date;
    }
    return earliest;
  });
  
  return firstLearned;
}

List<Milestone> _calculateMilestones(int totalWords, int currentStreak, int totalStudyMinutes) {
  final milestones = <Milestone>[];
  
  // Word milestones
  final wordMilestones = [10, 25, 50, 100, 250, 500, 1000];
  for (final milestone in wordMilestones) {
    milestones.add(Milestone(
      id: 'words_$milestone',
      title: '$milestone Words Learned',
      description: 'Learn $milestone vocabulary words',
      type: MilestoneType.vocabulary,
      targetValue: milestone,
      currentValue: totalWords,
      isUnlocked: totalWords >= milestone,
      unlockedAt: totalWords >= milestone ? DateTime.now() : null,
    ));
  }
  
  // Streak milestones
  final streakMilestones = [3, 7, 14, 30, 60, 100, 365];
  for (final milestone in streakMilestones) {
    milestones.add(Milestone(
      id: 'streak_$milestone',
      title: '$milestone Day Streak',
      description: 'Study for $milestone consecutive days',
      type: MilestoneType.consistency,
      targetValue: milestone,
      currentValue: currentStreak,
      isUnlocked: currentStreak >= milestone,
      unlockedAt: currentStreak >= milestone ? DateTime.now() : null,
    ));
  }
  
  // Study time milestones (in hours)
  final studyHours = (totalStudyMinutes / 60).floor();
  final timeMilestones = [1, 5, 10, 25, 50, 100];
  for (final milestone in timeMilestones) {
    milestones.add(Milestone(
      id: 'time_$milestone',
      title: '$milestone Hours Studied',
      description: 'Spend $milestone hours learning vocabulary',
      type: MilestoneType.dedication,
      targetValue: milestone,
      currentValue: studyHours,
      isUnlocked: studyHours >= milestone,
      unlockedAt: studyHours >= milestone ? DateTime.now() : null,
    ));
  }
  
  return milestones;
}

bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
         date1.month == date2.month &&
         date1.day == date2.day;
}