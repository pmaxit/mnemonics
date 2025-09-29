import 'package:freezed_annotation/freezed_annotation.dart';
import '../../home/domain/vocabulary_word.dart';
import '../../home/domain/user_word_data.dart';
import '../../profile/domain/user_statistics.dart';

part 'learning_session_models.freezed.dart';

enum SessionDuration { 
  fiveMinutes(5), 
  tenMinutes(10), 
  fifteenMinutes(15), 
  thirtyMinutes(30);

  const SessionDuration(this.minutes);
  final int minutes;

  String get displayText => '${minutes} min';
  String get description {
    switch (this) {
      case SessionDuration.fiveMinutes:
        return 'Quick review';
      case SessionDuration.tenMinutes:
        return 'Short session';
      case SessionDuration.fifteenMinutes:
        return 'Standard session';
      case SessionDuration.thirtyMinutes:
        return 'Extended session';
    }
  }
}

enum LearningSessionPhase {
  setup,
  countdown,
  active,
  paused,
  completed,
}

enum SessionMode {
  allWords('All Words', 'Review all available words'),
  dueForReview('Due for Review', 'Words ready for spaced repetition'),
  strugglingWords('Struggling Words', 'Words with low accuracy'),
  newWords('New Words', 'Words not yet learned');

  const SessionMode(this.title, this.description);
  final String title;
  final String description;
}

enum FlashcardSide {
  front, // Shows word
  back,  // Shows meaning and mnemonic
}

@freezed
class LearningSessionState with _$LearningSessionState {
  const factory LearningSessionState({
    @Default(LearningSessionPhase.setup) LearningSessionPhase phase,
    @Default(SessionDuration.tenMinutes) SessionDuration duration,
    @Default(SessionMode.dueForReview) SessionMode mode,
    @Default(<VocabularyWord>[]) List<VocabularyWord> sessionWords,
    @Default(0) int currentWordIndex,
    @Default(FlashcardSide.front) FlashcardSide currentSide,
    @Default(<SessionWordReview>[]) List<SessionWordReview> completedReviews,
    @Default(false) bool isPaused,
    DateTime? sessionStartTime,
    DateTime? sessionEndTime,
    @Default(3) int countdownSeconds,
  }) = _LearningSessionState;

  const LearningSessionState._();

  VocabularyWord? get currentWord => 
      sessionWords.isNotEmpty && currentWordIndex < sessionWords.length 
          ? sessionWords[currentWordIndex] 
          : null;

  bool get hasMoreWords => currentWordIndex < sessionWords.length - 1;

  bool get isCardRevealed => currentSide == FlashcardSide.back;

  Duration get sessionDuration => Duration(minutes: duration.minutes);

  int get wordsReviewed => completedReviews.length;

  int get uniqueWordsReviewed => completedReviews.map((r) => r.word).toSet().length;

  double get progress => sessionWords.isEmpty 
      ? 0.0 
      : (currentWordIndex + 1) / sessionWords.length;

  Map<String, int> get difficultyBreakdown {
    final breakdown = <String, int>{
      'easy': 0,
      'medium': 0,
      'hard': 0,
    };
    
    for (final review in completedReviews) {
      breakdown[review.difficulty.name] = (breakdown[review.difficulty.name] ?? 0) + 1;
    }
    
    return breakdown;
  }
}

@freezed
class SessionWordReview with _$SessionWordReview {
  const factory SessionWordReview({
    required String word,
    required ReviewDifficultyRating difficulty,
    required DateTime reviewedAt,
    required Duration timeSpent,
    @Default(false) bool wasSkipped,
  }) = _SessionWordReview;
}

@freezed
class LearningSessionSummary with _$LearningSessionSummary {
  const factory LearningSessionSummary({
    required Duration sessionDuration,
    required int wordsReviewed,
    required int uniqueWordsReviewed,
    required Map<String, int> difficultyBreakdown,
    required double averageTimePerWord,
    required int skippedWords,
    required List<String> strugglingWords,
    required List<String> masteredWords,
  }) = _LearningSessionSummary;

  const LearningSessionSummary._();

  double get wordsPerMinute => sessionDuration.inMinutes > 0 
      ? wordsReviewed / sessionDuration.inMinutes.toDouble()
      : 0.0;

  double get accuracyRate {
    final total = difficultyBreakdown.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return 0.0;
    
    final easyCount = difficultyBreakdown['easy'] ?? 0;
    final mediumCount = difficultyBreakdown['medium'] ?? 0;
    
    return (easyCount + (mediumCount * 0.5)) / total;
  }
}