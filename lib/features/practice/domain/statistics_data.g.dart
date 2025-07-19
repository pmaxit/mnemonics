// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StatisticsDataImpl _$$StatisticsDataImplFromJson(Map<String, dynamic> json) =>
    _$StatisticsDataImpl(
      totalLearned: (json['totalLearned'] as num).toInt(),
      learnedToday: (json['learnedToday'] as num).toInt(),
      newCount: (json['newCount'] as num).toInt(),
      inProgressCount: (json['inProgressCount'] as num).toInt(),
      masteredCount: (json['masteredCount'] as num).toInt(),
      categoryBreakdown:
          Map<String, int>.from(json['categoryBreakdown'] as Map),
      difficultyBreakdown:
          Map<String, int>.from(json['difficultyBreakdown'] as Map),
      weeklyProgress: (json['weeklyProgress'] as List<dynamic>)
          .map((e) => DailyProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      streak: (json['streak'] as num).toInt(),
    );

Map<String, dynamic> _$$StatisticsDataImplToJson(
        _$StatisticsDataImpl instance) =>
    <String, dynamic>{
      'totalLearned': instance.totalLearned,
      'learnedToday': instance.learnedToday,
      'newCount': instance.newCount,
      'inProgressCount': instance.inProgressCount,
      'masteredCount': instance.masteredCount,
      'categoryBreakdown': instance.categoryBreakdown,
      'difficultyBreakdown': instance.difficultyBreakdown,
      'weeklyProgress': instance.weeklyProgress,
      'averageAccuracy': instance.averageAccuracy,
      'totalReviews': instance.totalReviews,
      'streak': instance.streak,
    };

_$DailyProgressImpl _$$DailyProgressImplFromJson(Map<String, dynamic> json) =>
    _$DailyProgressImpl(
      date: DateTime.parse(json['date'] as String),
      wordsLearned: (json['wordsLearned'] as num).toInt(),
      reviewsCompleted: (json['reviewsCompleted'] as num).toInt(),
    );

Map<String, dynamic> _$$DailyProgressImplToJson(_$DailyProgressImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'wordsLearned': instance.wordsLearned,
      'reviewsCompleted': instance.reviewsCompleted,
    };
