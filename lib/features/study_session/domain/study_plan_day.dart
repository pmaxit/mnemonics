import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_plan_day.freezed.dart';
part 'study_plan_day.g.dart';

enum DayStatus {
  @JsonValue('not_attempted')
  notAttempted,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('done')
  done,
}

@freezed
class StudyPlanDay with _$StudyPlanDay {
  const factory StudyPlanDay({
    @JsonKey(name: 'day_number') required int dayNumber,
    required List<String> words,
    @Default(DayStatus.notAttempted) DayStatus status,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'done_at') DateTime? doneAt,
  }) = _StudyPlanDay;

  factory StudyPlanDay.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanDayFromJson(json);
}
