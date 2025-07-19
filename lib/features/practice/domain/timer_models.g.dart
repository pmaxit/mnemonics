// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimerSessionStateImpl _$$TimerSessionStateImplFromJson(
        Map<String, dynamic> json) =>
    _$TimerSessionStateImpl(
      selectedMinutes: (json['selectedMinutes'] as num?)?.toInt() ?? 10,
      studyMode: $enumDecodeNullable(_$TimerModeEnumMap, json['studyMode']) ??
          TimerMode.allWords,
      selectedCategories: (json['selectedCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sessionWords: (json['sessionWords'] as List<dynamic>?)
              ?.map((e) => VocabularyWord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentWordIndex: (json['currentWordIndex'] as num?)?.toInt() ?? 0,
      sessionStartTime: json['sessionStartTime'] == null
          ? null
          : DateTime.parse(json['sessionStartTime'] as String),
      completedReviews: (json['completedReviews'] as List<dynamic>?)
              ?.map((e) => WordReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isSessionActive: json['isSessionActive'] as bool? ?? false,
      isCardRevealed: json['isCardRevealed'] as bool? ?? false,
      isPaused: json['isPaused'] as bool? ?? false,
      currentPhase:
          $enumDecodeNullable(_$SessionPhaseEnumMap, json['currentPhase']) ??
              SessionPhase.setup,
    );

Map<String, dynamic> _$$TimerSessionStateImplToJson(
        _$TimerSessionStateImpl instance) =>
    <String, dynamic>{
      'selectedMinutes': instance.selectedMinutes,
      'studyMode': _$TimerModeEnumMap[instance.studyMode]!,
      'selectedCategories': instance.selectedCategories,
      'sessionWords': instance.sessionWords,
      'currentWordIndex': instance.currentWordIndex,
      'sessionStartTime': instance.sessionStartTime?.toIso8601String(),
      'completedReviews': instance.completedReviews,
      'isSessionActive': instance.isSessionActive,
      'isCardRevealed': instance.isCardRevealed,
      'isPaused': instance.isPaused,
      'currentPhase': _$SessionPhaseEnumMap[instance.currentPhase]!,
    };

const _$TimerModeEnumMap = {
  TimerMode.allWords: 'allWords',
  TimerMode.difficultOnly: 'difficultOnly',
  TimerMode.newWords: 'newWords',
  TimerMode.category: 'category',
};

const _$SessionPhaseEnumMap = {
  SessionPhase.setup: 'setup',
  SessionPhase.countdown: 'countdown',
  SessionPhase.active: 'active',
  SessionPhase.paused: 'paused',
  SessionPhase.completed: 'completed',
};

_$WordReviewImpl _$$WordReviewImplFromJson(Map<String, dynamic> json) =>
    _$WordReviewImpl(
      word: json['word'] as String,
      reviewedAt: DateTime.parse(json['reviewedAt'] as String),
      difficulty: $enumDecode(_$ReviewDifficultyEnumMap, json['difficulty']),
      timeSpent: Duration(microseconds: (json['timeSpent'] as num).toInt()),
      wasSkipped: json['wasSkipped'] as bool? ?? false,
    );

Map<String, dynamic> _$$WordReviewImplToJson(_$WordReviewImpl instance) =>
    <String, dynamic>{
      'word': instance.word,
      'reviewedAt': instance.reviewedAt.toIso8601String(),
      'difficulty': _$ReviewDifficultyEnumMap[instance.difficulty]!,
      'timeSpent': instance.timeSpent.inMicroseconds,
      'wasSkipped': instance.wasSkipped,
    };

const _$ReviewDifficultyEnumMap = {
  ReviewDifficulty.easy: 'easy',
  ReviewDifficulty.medium: 'medium',
  ReviewDifficulty.hard: 'hard',
};

_$SessionSummaryImpl _$$SessionSummaryImplFromJson(Map<String, dynamic> json) =>
    _$SessionSummaryImpl(
      wordsReviewed: (json['wordsReviewed'] as num).toInt(),
      totalTime: Duration(microseconds: (json['totalTime'] as num).toInt()),
      timeUsed: Duration(microseconds: (json['timeUsed'] as num).toInt()),
      difficultyBreakdown:
          (json['difficultyBreakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$ReviewDifficultyEnumMap, k), (e as num).toInt()),
      ),
      wordsPerMinute: (json['wordsPerMinute'] as num).toDouble(),
      streakCount: (json['streakCount'] as num).toInt(),
      strugglingWords: (json['strugglingWords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      masteredWords: (json['masteredWords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$SessionSummaryImplToJson(
        _$SessionSummaryImpl instance) =>
    <String, dynamic>{
      'wordsReviewed': instance.wordsReviewed,
      'totalTime': instance.totalTime.inMicroseconds,
      'timeUsed': instance.timeUsed.inMicroseconds,
      'difficultyBreakdown': instance.difficultyBreakdown
          .map((k, e) => MapEntry(_$ReviewDifficultyEnumMap[k]!, e)),
      'wordsPerMinute': instance.wordsPerMinute,
      'streakCount': instance.streakCount,
      'strugglingWords': instance.strugglingWords,
      'masteredWords': instance.masteredWords,
    };
