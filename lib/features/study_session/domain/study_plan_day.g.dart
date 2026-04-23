// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudyPlanDayImpl _$$StudyPlanDayImplFromJson(Map<String, dynamic> json) =>
    _$StudyPlanDayImpl(
      dayNumber: (json['day_number'] as num).toInt(),
      words: (json['words'] as List<dynamic>).map((e) => e as String).toList(),
      status: $enumDecodeNullable(_$DayStatusEnumMap, json['status']) ??
          DayStatus.notAttempted,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      doneAt: json['done_at'] == null
          ? null
          : DateTime.parse(json['done_at'] as String),
    );

Map<String, dynamic> _$$StudyPlanDayImplToJson(_$StudyPlanDayImpl instance) =>
    <String, dynamic>{
      'day_number': instance.dayNumber,
      'words': instance.words,
      'status': _$DayStatusEnumMap[instance.status]!,
      'started_at': instance.startedAt?.toIso8601String(),
      'done_at': instance.doneAt?.toIso8601String(),
    };

const _$DayStatusEnumMap = {
  DayStatus.notAttempted: 'not_attempted',
  DayStatus.inProgress: 'in_progress',
  DayStatus.done: 'done',
};
