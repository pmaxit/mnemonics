import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'user_statistics.freezed.dart';
part 'user_statistics.g.dart';

@freezed
class UserStatistics with _$UserStatistics {
  const factory UserStatistics({
    // Overall progress tracking
    required int totalWordsLearned,
    required int wordsLearnedToday,
    required int wordsLearnedThisWeek,
    required int currentStreak,
    required int longestStreak,
    required double averageAccuracy,
    required int totalStudyTimeMinutes,
    
    // Difficulty-based breakdown 
    required Map<WordDifficulty, DifficultyProgress> difficultyStats,
    
    // Category-based breakdown
    required Map<String, CategoryProgress> categoryStats,
    
    // Learning stage progression
    required Map<LearningStage, int> stageBreakdown,
    
    // Review action tracking
    required List<UserReviewAction> recentActions,
    
    // Time-based analytics
    required List<DailyProgress> weeklyProgress,
    required double learningVelocity,
    
    // Milestones and achievements
    required List<Milestone> milestones,
    
    // User profile info
    DateTime? joinDate,
  }) = _UserStatistics;

  factory UserStatistics.fromJson(Map<String, dynamic> json) => _$UserStatisticsFromJson(json);
}

@freezed
class DifficultyProgress with _$DifficultyProgress {
  const factory DifficultyProgress({
    required WordDifficulty difficulty,
    required int totalWords,
    required int wordsLearned,
    required int wordsInProgress,
    required double averageAccuracy,
    required int totalReviews,
    required DateTime? lastReviewedAt,
  }) = _DifficultyProgress;

  factory DifficultyProgress.fromJson(Map<String, dynamic> json) => _$DifficultyProgressFromJson(json);
}

@freezed
class CategoryProgress with _$CategoryProgress {
  const factory CategoryProgress({
    required String categoryName,
    required int totalWords,
    required int wordsLearned,
    required int wordsInProgress,
    required double averageAccuracy,
    required Map<WordDifficulty, int> difficultyBreakdown,
    required DateTime? lastReviewedAt,
  }) = _CategoryProgress;

  factory CategoryProgress.fromJson(Map<String, dynamic> json) => _$CategoryProgressFromJson(json);
}

@freezed
class UserReviewAction with _$UserReviewAction {
  const factory UserReviewAction({
    required String word,
    required String category,
    required WordDifficulty wordDifficulty,
    required ReviewActionType actionType,
    required ReviewDifficultyRating userRating,
    required DateTime timestamp,
    required Duration timeSpent,
    required bool wasCorrect,
    required LearningStage previousStage,
    required LearningStage newStage,
    String? notes,
  }) = _UserReviewAction;

  factory UserReviewAction.fromJson(Map<String, dynamic> json) => _$UserReviewActionFromJson(json);
}

@freezed
class DailyProgress with _$DailyProgress {
  const factory DailyProgress({
    required DateTime date,
    required int wordsLearned,
    required int reviewsCompleted,
    required int studyTimeMinutes,
    required Map<WordDifficulty, int> difficultyBreakdown,
    required double accuracyRate,
  }) = _DailyProgress;

  factory DailyProgress.fromJson(Map<String, dynamic> json) => _$DailyProgressFromJson(json);
}

@freezed
class Milestone with _$Milestone {
  const factory Milestone({
    required String id,
    required String title,
    required String description,
    required MilestoneType type,
    required int targetValue,
    required int currentValue,
    required bool isUnlocked,
    DateTime? unlockedAt,
  }) = _Milestone;

  factory Milestone.fromJson(Map<String, dynamic> json) => _$MilestoneFromJson(json);
}

// Enums for consistent data types
enum WordDifficulty {
  basic,
  intermediate,
  advanced,
}

enum LearningStage {
  newWord,
  learning,
  mastered,
}

enum ReviewActionType {
  review,
  markAsLearned,
  rateWord,
  skip,
}

@HiveType(typeId: 4)
enum ReviewDifficultyRating {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard,
}

enum MilestoneType {
  vocabulary,
  consistency,
  dedication,
  accuracy,
  category,
}

// Extensions for display purposes
extension WordDifficultyExtension on WordDifficulty {
  String get displayName {
    switch (this) {
      case WordDifficulty.basic:
        return 'Basic';
      case WordDifficulty.intermediate:
        return 'Intermediate';
      case WordDifficulty.advanced:
        return 'Advanced';
    }
  }

  String get emoji {
    switch (this) {
      case WordDifficulty.basic:
        return '⭐';
      case WordDifficulty.intermediate:
        return '⭐⭐';
      case WordDifficulty.advanced:
        return '⭐⭐⭐';
    }
  }

  int get numericValue {
    switch (this) {
      case WordDifficulty.basic:
        return 1;
      case WordDifficulty.intermediate:
        return 2;
      case WordDifficulty.advanced:
        return 3;
    }
  }
}

extension LearningStageExtension on LearningStage {
  String get displayName {
    switch (this) {
      case LearningStage.newWord:
        return 'New';
      case LearningStage.learning:
        return 'Learning';
      case LearningStage.mastered:
        return 'Mastered';
    }
  }

  String get emoji {
    switch (this) {
      case LearningStage.newWord:
        return '🆕';
      case LearningStage.learning:
        return '📚';
      case LearningStage.mastered:
        return '🏆';
    }
  }
}

extension ReviewActionTypeExtension on ReviewActionType {
  String get displayName {
    switch (this) {
      case ReviewActionType.review:
        return 'Reviewed';
      case ReviewActionType.markAsLearned:
        return 'Marked as Learned';
      case ReviewActionType.rateWord:
        return 'Rated Word';
      case ReviewActionType.skip:
        return 'Skipped';
    }
  }
}

extension MilestoneTypeExtension on MilestoneType {
  String get displayName {
    switch (this) {
      case MilestoneType.vocabulary:
        return 'Vocabulary';
      case MilestoneType.consistency:
        return 'Consistency';
      case MilestoneType.dedication:
        return 'Dedication';
      case MilestoneType.accuracy:
        return 'Accuracy';
      case MilestoneType.category:
        return 'Category Mastery';
    }
  }

  String get icon {
    switch (this) {
      case MilestoneType.vocabulary:
        return '📚';
      case MilestoneType.consistency:
        return '🔥';
      case MilestoneType.dedication:
        return '⏰';
      case MilestoneType.accuracy:
        return '🎯';
      case MilestoneType.category:
        return '🏆';
    }
  }
}