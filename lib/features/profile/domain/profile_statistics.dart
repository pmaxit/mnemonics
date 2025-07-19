import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_statistics.freezed.dart';
part 'profile_statistics.g.dart';

@freezed
class ProfileStatistics with _$ProfileStatistics {
  const factory ProfileStatistics({
    required int totalWordsLearned,
    required int wordsLearnedToday,
    required int wordsLearnedThisWeek,
    required int currentStreak,
    required int longestStreak,
    required int totalStudyTimeMinutes,
    required double averageAccuracy,
    required int studySessionsThisWeek,
    required double learningVelocity,
    required List<CategoryStats> categoryStats,
    required List<DifficultyStats> difficultyStats,
    required List<Milestone> milestones,
    DateTime? joinDate,
  }) = _ProfileStatistics;

  factory ProfileStatistics.fromJson(Map<String, dynamic> json) => _$ProfileStatisticsFromJson(json);
}

@freezed
class CategoryStats with _$CategoryStats {
  const factory CategoryStats({
    required String categoryName,
    required int wordsLearned,
    required int totalWords,
    required double averageAccuracy,
  }) = _CategoryStats;

  factory CategoryStats.fromJson(Map<String, dynamic> json) => _$CategoryStatsFromJson(json);
}

@freezed
class DifficultyStats with _$DifficultyStats {
  const factory DifficultyStats({
    required String difficulty,
    required int wordsLearned,
    required int totalWords,
    required double averageAccuracy,
  }) = _DifficultyStats;

  factory DifficultyStats.fromJson(Map<String, dynamic> json) => _$DifficultyStatsFromJson(json);
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

enum MilestoneType {
  vocabulary,
  consistency,
  dedication,
  accuracy,
  category,
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