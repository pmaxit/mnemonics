// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileStatisticsImpl _$$ProfileStatisticsImplFromJson(
        Map<String, dynamic> json) =>
    _$ProfileStatisticsImpl(
      totalWordsLearned: (json['totalWordsLearned'] as num).toInt(),
      wordsLearnedToday: (json['wordsLearnedToday'] as num).toInt(),
      wordsLearnedThisWeek: (json['wordsLearnedThisWeek'] as num).toInt(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      totalStudyTimeMinutes: (json['totalStudyTimeMinutes'] as num).toInt(),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      studySessionsThisWeek: (json['studySessionsThisWeek'] as num).toInt(),
      learningVelocity: (json['learningVelocity'] as num).toDouble(),
      categoryStats: (json['categoryStats'] as List<dynamic>)
          .map((e) => CategoryStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      difficultyStats: (json['difficultyStats'] as List<dynamic>)
          .map((e) => DifficultyStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      joinDate: json['joinDate'] == null
          ? null
          : DateTime.parse(json['joinDate'] as String),
      lastStudyDate: json['lastStudyDate'] == null
          ? null
          : DateTime.parse(json['lastStudyDate'] as String),
      masteredCategories: (json['masteredCategories'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ProfileStatisticsImplToJson(
        _$ProfileStatisticsImpl instance) =>
    <String, dynamic>{
      'totalWordsLearned': instance.totalWordsLearned,
      'wordsLearnedToday': instance.wordsLearnedToday,
      'wordsLearnedThisWeek': instance.wordsLearnedThisWeek,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'totalStudyTimeMinutes': instance.totalStudyTimeMinutes,
      'averageAccuracy': instance.averageAccuracy,
      'studySessionsThisWeek': instance.studySessionsThisWeek,
      'learningVelocity': instance.learningVelocity,
      'categoryStats': instance.categoryStats,
      'difficultyStats': instance.difficultyStats,
      'milestones': instance.milestones,
      'joinDate': instance.joinDate?.toIso8601String(),
      'lastStudyDate': instance.lastStudyDate?.toIso8601String(),
      'masteredCategories': instance.masteredCategories,
    };

_$CategoryStatsImpl _$$CategoryStatsImplFromJson(Map<String, dynamic> json) =>
    _$CategoryStatsImpl(
      categoryName: json['categoryName'] as String,
      wordsLearned: (json['wordsLearned'] as num).toInt(),
      totalWords: (json['totalWords'] as num).toInt(),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
    );

Map<String, dynamic> _$$CategoryStatsImplToJson(_$CategoryStatsImpl instance) =>
    <String, dynamic>{
      'categoryName': instance.categoryName,
      'wordsLearned': instance.wordsLearned,
      'totalWords': instance.totalWords,
      'averageAccuracy': instance.averageAccuracy,
    };

_$DifficultyStatsImpl _$$DifficultyStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$DifficultyStatsImpl(
      difficulty: json['difficulty'] as String,
      wordsLearned: (json['wordsLearned'] as num).toInt(),
      totalWords: (json['totalWords'] as num).toInt(),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
    );

Map<String, dynamic> _$$DifficultyStatsImplToJson(
        _$DifficultyStatsImpl instance) =>
    <String, dynamic>{
      'difficulty': instance.difficulty,
      'wordsLearned': instance.wordsLearned,
      'totalWords': instance.totalWords,
      'averageAccuracy': instance.averageAccuracy,
    };

_$MilestoneImpl _$$MilestoneImplFromJson(Map<String, dynamic> json) =>
    _$MilestoneImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$MilestoneTypeEnumMap, json['type']),
      targetValue: (json['targetValue'] as num).toInt(),
      currentValue: (json['currentValue'] as num).toInt(),
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
    );

Map<String, dynamic> _$$MilestoneImplToJson(_$MilestoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$MilestoneTypeEnumMap[instance.type]!,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      'isUnlocked': instance.isUnlocked,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
    };

const _$MilestoneTypeEnumMap = {
  MilestoneType.vocabulary: 'vocabulary',
  MilestoneType.consistency: 'consistency',
  MilestoneType.dedication: 'dedication',
  MilestoneType.accuracy: 'accuracy',
  MilestoneType.category: 'category',
};
