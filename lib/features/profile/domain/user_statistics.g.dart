// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_statistics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReviewDifficultyRatingAdapter
    extends TypeAdapter<ReviewDifficultyRating> {
  @override
  final int typeId = 4;

  @override
  ReviewDifficultyRating read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReviewDifficultyRating.easy;
      case 1:
        return ReviewDifficultyRating.medium;
      case 2:
        return ReviewDifficultyRating.hard;
      default:
        return ReviewDifficultyRating.easy;
    }
  }

  @override
  void write(BinaryWriter writer, ReviewDifficultyRating obj) {
    switch (obj) {
      case ReviewDifficultyRating.easy:
        writer.writeByte(0);
        break;
      case ReviewDifficultyRating.medium:
        writer.writeByte(1);
        break;
      case ReviewDifficultyRating.hard:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewDifficultyRatingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserStatisticsImpl _$$UserStatisticsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatisticsImpl(
      totalWordsLearned: (json['totalWordsLearned'] as num).toInt(),
      wordsLearnedToday: (json['wordsLearnedToday'] as num).toInt(),
      wordsLearnedThisWeek: (json['wordsLearnedThisWeek'] as num).toInt(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      totalStudyTimeMinutes: (json['totalStudyTimeMinutes'] as num).toInt(),
      difficultyStats: (json['difficultyStats'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$WordDifficultyEnumMap, k),
            DifficultyProgress.fromJson(e as Map<String, dynamic>)),
      ),
      categoryStats: (json['categoryStats'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, CategoryProgress.fromJson(e as Map<String, dynamic>)),
      ),
      stageBreakdown: (json['stageBreakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$LearningStageEnumMap, k), (e as num).toInt()),
      ),
      recentActions: (json['recentActions'] as List<dynamic>)
          .map((e) => UserReviewAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      weeklyProgress: (json['weeklyProgress'] as List<dynamic>)
          .map((e) => DailyProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      learningVelocity: (json['learningVelocity'] as num).toDouble(),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      joinDate: json['joinDate'] == null
          ? null
          : DateTime.parse(json['joinDate'] as String),
    );

Map<String, dynamic> _$$UserStatisticsImplToJson(
        _$UserStatisticsImpl instance) =>
    <String, dynamic>{
      'totalWordsLearned': instance.totalWordsLearned,
      'wordsLearnedToday': instance.wordsLearnedToday,
      'wordsLearnedThisWeek': instance.wordsLearnedThisWeek,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'averageAccuracy': instance.averageAccuracy,
      'totalStudyTimeMinutes': instance.totalStudyTimeMinutes,
      'difficultyStats': instance.difficultyStats
          .map((k, e) => MapEntry(_$WordDifficultyEnumMap[k]!, e)),
      'categoryStats': instance.categoryStats,
      'stageBreakdown': instance.stageBreakdown
          .map((k, e) => MapEntry(_$LearningStageEnumMap[k]!, e)),
      'recentActions': instance.recentActions,
      'weeklyProgress': instance.weeklyProgress,
      'learningVelocity': instance.learningVelocity,
      'milestones': instance.milestones,
      'joinDate': instance.joinDate?.toIso8601String(),
    };

const _$WordDifficultyEnumMap = {
  WordDifficulty.basic: 'basic',
  WordDifficulty.intermediate: 'intermediate',
  WordDifficulty.advanced: 'advanced',
};

const _$LearningStageEnumMap = {
  LearningStage.newWord: 'newWord',
  LearningStage.learning: 'learning',
  LearningStage.mastered: 'mastered',
};

_$DifficultyProgressImpl _$$DifficultyProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$DifficultyProgressImpl(
      difficulty: $enumDecode(_$WordDifficultyEnumMap, json['difficulty']),
      totalWords: (json['totalWords'] as num).toInt(),
      wordsLearned: (json['wordsLearned'] as num).toInt(),
      wordsInProgress: (json['wordsInProgress'] as num).toInt(),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      lastReviewedAt: json['lastReviewedAt'] == null
          ? null
          : DateTime.parse(json['lastReviewedAt'] as String),
    );

Map<String, dynamic> _$$DifficultyProgressImplToJson(
        _$DifficultyProgressImpl instance) =>
    <String, dynamic>{
      'difficulty': _$WordDifficultyEnumMap[instance.difficulty]!,
      'totalWords': instance.totalWords,
      'wordsLearned': instance.wordsLearned,
      'wordsInProgress': instance.wordsInProgress,
      'averageAccuracy': instance.averageAccuracy,
      'totalReviews': instance.totalReviews,
      'lastReviewedAt': instance.lastReviewedAt?.toIso8601String(),
    };

_$CategoryProgressImpl _$$CategoryProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$CategoryProgressImpl(
      categoryName: json['categoryName'] as String,
      totalWords: (json['totalWords'] as num).toInt(),
      wordsLearned: (json['wordsLearned'] as num).toInt(),
      wordsInProgress: (json['wordsInProgress'] as num).toInt(),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      difficultyBreakdown:
          (json['difficultyBreakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$WordDifficultyEnumMap, k), (e as num).toInt()),
      ),
      lastReviewedAt: json['lastReviewedAt'] == null
          ? null
          : DateTime.parse(json['lastReviewedAt'] as String),
    );

Map<String, dynamic> _$$CategoryProgressImplToJson(
        _$CategoryProgressImpl instance) =>
    <String, dynamic>{
      'categoryName': instance.categoryName,
      'totalWords': instance.totalWords,
      'wordsLearned': instance.wordsLearned,
      'wordsInProgress': instance.wordsInProgress,
      'averageAccuracy': instance.averageAccuracy,
      'difficultyBreakdown': instance.difficultyBreakdown
          .map((k, e) => MapEntry(_$WordDifficultyEnumMap[k]!, e)),
      'lastReviewedAt': instance.lastReviewedAt?.toIso8601String(),
    };

_$UserReviewActionImpl _$$UserReviewActionImplFromJson(
        Map<String, dynamic> json) =>
    _$UserReviewActionImpl(
      word: json['word'] as String,
      category: json['category'] as String,
      wordDifficulty:
          $enumDecode(_$WordDifficultyEnumMap, json['wordDifficulty']),
      actionType: $enumDecode(_$ReviewActionTypeEnumMap, json['actionType']),
      userRating:
          $enumDecode(_$ReviewDifficultyRatingEnumMap, json['userRating']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      timeSpent: Duration(microseconds: (json['timeSpent'] as num).toInt()),
      wasCorrect: json['wasCorrect'] as bool,
      previousStage: $enumDecode(_$LearningStageEnumMap, json['previousStage']),
      newStage: $enumDecode(_$LearningStageEnumMap, json['newStage']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$UserReviewActionImplToJson(
        _$UserReviewActionImpl instance) =>
    <String, dynamic>{
      'word': instance.word,
      'category': instance.category,
      'wordDifficulty': _$WordDifficultyEnumMap[instance.wordDifficulty]!,
      'actionType': _$ReviewActionTypeEnumMap[instance.actionType]!,
      'userRating': _$ReviewDifficultyRatingEnumMap[instance.userRating]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'timeSpent': instance.timeSpent.inMicroseconds,
      'wasCorrect': instance.wasCorrect,
      'previousStage': _$LearningStageEnumMap[instance.previousStage]!,
      'newStage': _$LearningStageEnumMap[instance.newStage]!,
      'notes': instance.notes,
    };

const _$ReviewActionTypeEnumMap = {
  ReviewActionType.review: 'review',
  ReviewActionType.markAsLearned: 'markAsLearned',
  ReviewActionType.rateWord: 'rateWord',
  ReviewActionType.skip: 'skip',
};

const _$ReviewDifficultyRatingEnumMap = {
  ReviewDifficultyRating.easy: 'easy',
  ReviewDifficultyRating.medium: 'medium',
  ReviewDifficultyRating.hard: 'hard',
};

_$DailyProgressImpl _$$DailyProgressImplFromJson(Map<String, dynamic> json) =>
    _$DailyProgressImpl(
      date: DateTime.parse(json['date'] as String),
      wordsLearned: (json['wordsLearned'] as num).toInt(),
      reviewsCompleted: (json['reviewsCompleted'] as num).toInt(),
      studyTimeMinutes: (json['studyTimeMinutes'] as num).toInt(),
      difficultyBreakdown:
          (json['difficultyBreakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$WordDifficultyEnumMap, k), (e as num).toInt()),
      ),
      accuracyRate: (json['accuracyRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$DailyProgressImplToJson(_$DailyProgressImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'wordsLearned': instance.wordsLearned,
      'reviewsCompleted': instance.reviewsCompleted,
      'studyTimeMinutes': instance.studyTimeMinutes,
      'difficultyBreakdown': instance.difficultyBreakdown
          .map((k, e) => MapEntry(_$WordDifficultyEnumMap[k]!, e)),
      'accuracyRate': instance.accuracyRate,
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
