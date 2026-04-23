import 'package:freezed_annotation/freezed_annotation.dart';
import 'study_plan_day.dart';

part 'study_plan.freezed.dart';
part 'study_plan.g.dart';

@freezed
class StudyPlan with _$StudyPlan {
  const factory StudyPlan({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    @JsonKey(name: 'total_words') required int totalWords,
    @JsonKey(name: 'num_days') required int numDays,
    @JsonKey(name: 'words_per_day') required int wordsPerDay,
    @JsonKey(name: 'start_date') required String startDate,
    @Default('active') String status,
    @Default(<StudyPlanDay>[]) List<StudyPlanDay> days,
  }) = _StudyPlan;

  factory StudyPlan.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanFromJson(json);
}
