// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudyPlanImpl _$$StudyPlanImplFromJson(Map<String, dynamic> json) =>
    _$StudyPlanImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      totalWords: (json['total_words'] as num).toInt(),
      numDays: (json['num_days'] as num).toInt(),
      wordsPerDay: (json['words_per_day'] as num).toInt(),
      startDate: json['start_date'] as String,
      status: json['status'] as String? ?? 'active',
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => StudyPlanDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <StudyPlanDay>[],
    );

Map<String, dynamic> _$$StudyPlanImplToJson(_$StudyPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'total_words': instance.totalWords,
      'num_days': instance.numDays,
      'words_per_day': instance.wordsPerDay,
      'start_date': instance.startDate,
      'status': instance.status,
      'days': instance.days,
    };
