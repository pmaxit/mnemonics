import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_data.freezed.dart';
part 'statistics_data.g.dart';

@freezed
class StatisticsData with _$StatisticsData {
  const factory StatisticsData({
    required int totalLearned,
    required int learnedToday,
    required int newCount,
    required int inProgressCount,
    required int masteredCount,
    required Map<String, int> categoryBreakdown,
    required Map<String, int> difficultyBreakdown,
    required List<DailyProgress> weeklyProgress,
    required double averageAccuracy,
    required int totalReviews,
    required int streak,
  }) = _StatisticsData;

  factory StatisticsData.fromJson(Map<String, dynamic> json) => _$StatisticsDataFromJson(json);
}

@freezed
class DailyProgress with _$DailyProgress {
  const factory DailyProgress({
    required DateTime date,
    required int wordsLearned,
    required int reviewsCompleted,
  }) = _DailyProgress;

  factory DailyProgress.fromJson(Map<String, dynamic> json) => _$DailyProgressFromJson(json);
}