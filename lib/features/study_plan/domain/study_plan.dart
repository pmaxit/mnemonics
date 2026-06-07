import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_plan.freezed.dart';
part 'study_plan.g.dart';

@freezed
class StudyPlan with _$StudyPlan {
  const factory StudyPlan({
    required int id,
    @JsonKey(name: 'user_id') @Default('default') String userId,
    @JsonKey(name: 'total_words') required int totalWords,
    @JsonKey(name: 'words_per_day') required int wordsPerDay,
    @JsonKey(name: 'total_days') required int totalDays,
    @JsonKey(name: 'start_date') required String startDate,
    @Default('active') String status,
    @JsonKey(name: 'created_at') String? createdAt,
    @Default([]) List<StudyPlanDay> days,
  }) = _StudyPlan;

  factory StudyPlan.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanFromJson(json);
}

@freezed
class StudyPlanDay with _$StudyPlanDay {
  const factory StudyPlanDay({
    required int id,
    @JsonKey(name: 'day_number') required int dayNumber,
    @JsonKey(name: 'scheduled_date') required String scheduledDate,
    @Default('not_started') String status,
    String? theme,
    @JsonKey(name: 'total_words') @Default(0) int totalWords,
    @JsonKey(name: 'completed_words') @Default(0) int completedWords,
    @JsonKey(name: 'in_progress_words') @Default(0) int inProgressWords,
  }) = _StudyPlanDay;

  factory StudyPlanDay.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanDayFromJson(json);
}

@freezed
class StudyPlanDayDetail with _$StudyPlanDayDetail {
  const factory StudyPlanDayDetail({
    required int id,
    @JsonKey(name: 'day_number') required int dayNumber,
    @JsonKey(name: 'scheduled_date') required String scheduledDate,
    @Default('not_started') String status,
    String? theme,
    @Default([]) List<StudyPlanWord> words,
  }) = _StudyPlanDayDetail;

  factory StudyPlanDayDetail.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanDayDetailFromJson(json);
}

@freezed
class StudyPlanWord with _$StudyPlanWord {
  const factory StudyPlanWord({
    required String word,
    @Default('not_started') String status,
    @JsonKey(name: 'completed_at') String? completedAt,
    String? meaning,
    String? mnemonic,
    String? category,
    String? difficulty,
  }) = _StudyPlanWord;

  factory StudyPlanWord.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanWordFromJson(json);
}
