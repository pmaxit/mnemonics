// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudyPlanImpl _$$StudyPlanImplFromJson(Map<String, dynamic> json) =>
    _$StudyPlanImpl(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] as String? ?? 'default',
      totalWords: (json['total_words'] as num).toInt(),
      wordsPerDay: (json['words_per_day'] as num).toInt(),
      totalDays: (json['total_days'] as num).toInt(),
      startDate: json['start_date'] as String,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] as String?,
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => StudyPlanDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$StudyPlanImplToJson(_$StudyPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'total_words': instance.totalWords,
      'words_per_day': instance.wordsPerDay,
      'total_days': instance.totalDays,
      'start_date': instance.startDate,
      'status': instance.status,
      'created_at': instance.createdAt,
      'days': instance.days,
    };

_$StudyPlanDayImpl _$$StudyPlanDayImplFromJson(Map<String, dynamic> json) =>
    _$StudyPlanDayImpl(
      id: (json['id'] as num).toInt(),
      dayNumber: (json['day_number'] as num).toInt(),
      scheduledDate: json['scheduled_date'] as String,
      status: json['status'] as String? ?? 'not_started',
      theme: json['theme'] as String?,
      totalWords: (json['total_words'] as num?)?.toInt() ?? 0,
      completedWords: (json['completed_words'] as num?)?.toInt() ?? 0,
      inProgressWords: (json['in_progress_words'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$StudyPlanDayImplToJson(_$StudyPlanDayImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day_number': instance.dayNumber,
      'scheduled_date': instance.scheduledDate,
      'status': instance.status,
      'theme': instance.theme,
      'total_words': instance.totalWords,
      'completed_words': instance.completedWords,
      'in_progress_words': instance.inProgressWords,
    };

_$StudyPlanDayDetailImpl _$$StudyPlanDayDetailImplFromJson(
        Map<String, dynamic> json) =>
    _$StudyPlanDayDetailImpl(
      id: (json['id'] as num).toInt(),
      dayNumber: (json['day_number'] as num).toInt(),
      scheduledDate: json['scheduled_date'] as String,
      status: json['status'] as String? ?? 'not_started',
      theme: json['theme'] as String?,
      words: (json['words'] as List<dynamic>?)
              ?.map((e) => StudyPlanWord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$StudyPlanDayDetailImplToJson(
        _$StudyPlanDayDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day_number': instance.dayNumber,
      'scheduled_date': instance.scheduledDate,
      'status': instance.status,
      'theme': instance.theme,
      'words': instance.words,
    };

_$StudyPlanWordImpl _$$StudyPlanWordImplFromJson(Map<String, dynamic> json) =>
    _$StudyPlanWordImpl(
      word: json['word'] as String,
      status: json['status'] as String? ?? 'not_started',
      completedAt: json['completed_at'] as String?,
      meaning: json['meaning'] as String?,
      mnemonic: json['mnemonic'] as String?,
      category: json['category'] as String?,
      difficulty: json['difficulty'] as String?,
    );

Map<String, dynamic> _$$StudyPlanWordImplToJson(_$StudyPlanWordImpl instance) =>
    <String, dynamic>{
      'word': instance.word,
      'status': instance.status,
      'completed_at': instance.completedAt,
      'meaning': instance.meaning,
      'mnemonic': instance.mnemonic,
      'category': instance.category,
      'difficulty': instance.difficulty,
    };
