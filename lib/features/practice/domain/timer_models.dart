import 'package:freezed_annotation/freezed_annotation.dart';
import '../../home/domain/vocabulary_word.dart';

part 'timer_models.freezed.dart';
part 'timer_models.g.dart';

@freezed
class TimerSessionState with _$TimerSessionState {
  const factory TimerSessionState({
    @Default(10) int selectedMinutes,
    @Default(TimerMode.allWords) TimerMode studyMode,
    @Default([]) List<String> selectedCategories,
    @Default([]) List<VocabularyWord> sessionWords,
    @Default(0) int currentWordIndex,
    DateTime? sessionStartTime,
    @Default([]) List<WordReview> completedReviews,
    @Default(false) bool isSessionActive,
    @Default(false) bool isCardRevealed,
    @Default(false) bool isPaused,
    @Default(SessionPhase.setup) SessionPhase currentPhase,
  }) = _TimerSessionState;

  factory TimerSessionState.fromJson(Map<String, dynamic> json) => _$TimerSessionStateFromJson(json);
}

@freezed
class WordReview with _$WordReview {
  const factory WordReview({
    required String word,
    required DateTime reviewedAt,
    required ReviewDifficulty difficulty,
    required Duration timeSpent,
    @Default(false) bool wasSkipped,
  }) = _WordReview;

  factory WordReview.fromJson(Map<String, dynamic> json) => _$WordReviewFromJson(json);
}

@freezed
class SessionSummary with _$SessionSummary {
  const factory SessionSummary({
    required int wordsReviewed,
    required Duration totalTime,
    required Duration timeUsed,
    required Map<ReviewDifficulty, int> difficultyBreakdown,
    required double wordsPerMinute,
    required int streakCount,
    required List<String> strugglingWords,
    required List<String> masteredWords,
  }) = _SessionSummary;

  factory SessionSummary.fromJson(Map<String, dynamic> json) => _$SessionSummaryFromJson(json);
}


enum TimerMode {
  allWords,
  difficultOnly,
  newWords,
  category,
}

enum SessionPhase {
  setup,
  countdown,
  active,
  paused,
  completed,
}

enum ReviewDifficulty {
  easy,
  medium,
  hard,
}

extension TimerModeExtension on TimerMode {
  String get displayName {
    switch (this) {
      case TimerMode.allWords:
        return 'All Words';
      case TimerMode.difficultOnly:
        return 'Difficult Only';
      case TimerMode.newWords:
        return 'New Words';
      case TimerMode.category:
        return 'By Category';
    }
  }

  String get description {
    switch (this) {
      case TimerMode.allWords:
        return 'Review all vocabulary words';
      case TimerMode.difficultOnly:
        return 'Focus on challenging words';
      case TimerMode.newWords:
        return 'Learn new vocabulary';
      case TimerMode.category:
        return 'Study specific categories';
    }
  }
}

extension ReviewDifficultyExtension on ReviewDifficulty {
  String get displayName {
    switch (this) {
      case ReviewDifficulty.easy:
        return 'Easy';
      case ReviewDifficulty.medium:
        return 'Medium';
      case ReviewDifficulty.hard:
        return 'Hard';
    }
  }

  String get emoji {
    switch (this) {
      case ReviewDifficulty.easy:
        return '😊';
      case ReviewDifficulty.medium:
        return '😐';
      case ReviewDifficulty.hard:
        return '😅';
    }
  }
}

