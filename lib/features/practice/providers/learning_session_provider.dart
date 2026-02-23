import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/learning_session_models.dart';
import '../../home/domain/vocabulary_word.dart';
import '../../home/domain/user_word_data.dart';
import '../../home/infrastructure/user_word_data_repository.dart';
import '../../home/infrastructure/vocabulary_repository.dart';
import '../../home/domain/spaced_repetition.dart';
import '../../home/providers.dart';
import '../../profile/domain/user_statistics.dart';
import '../../home/domain/review_activity.dart';

part 'learning_session_provider.g.dart';

@riverpod
class LearningSession extends _$LearningSession {
  Timer? _sessionTimer;
  Timer? _countdownTimer;
  DateTime? _sessionStartTime;

  @override
  LearningSessionState build() {
    ref.onDispose(() {
      _sessionTimer?.cancel();
      _countdownTimer?.cancel();
    });

    return const LearningSessionState();
  }

  void updateDuration(SessionDuration duration) {
    state = state.copyWith(duration: duration);
  }

  void updateMode(SessionMode mode) {
    state = state.copyWith(mode: mode);
  }

  Future<void> startSession() async {
    try {
      // Load words based on selected mode
      final words = await _loadWordsForSession(state.mode);

      if (words.isEmpty) {
        state = state.copyWith(phase: LearningSessionPhase.completed);
        throw StateError(
            'No words available for the selected mode. Try practicing other words first!');
      }

      // Shuffle words for variety
      words.shuffle();

      state = state.copyWith(
        sessionWords: words,
        currentWordIndex: 0,
        currentSide: FlashcardSide.front,
        completedReviews: [],
        phase: LearningSessionPhase.countdown,
        countdownSeconds: 3,
        sessionStartTime: DateTime.now(),
      );

      // Start countdown
      _startCountdown();
    } catch (e) {
      if (e is StateError) rethrow;
      rethrow;
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownSeconds > 1) {
        state = state.copyWith(countdownSeconds: state.countdownSeconds - 1);
      } else {
        timer.cancel();
        _startActiveSession();
      }
    });
  }

  void _startActiveSession() {
    _sessionStartTime = DateTime.now();
    state = state.copyWith(
      phase: LearningSessionPhase.active,
      sessionStartTime: _sessionStartTime,
    );

    // Start session timer
    _sessionTimer = Timer(state.sessionDuration, () {
      _completeSession();
    });
  }

  void pauseSession() {
    if (state.phase == LearningSessionPhase.active) {
      _sessionTimer?.cancel();
      state = state.copyWith(
        phase: LearningSessionPhase.paused,
        isPaused: true,
      );
    }
  }

  void resumeSession() {
    if (state.phase == LearningSessionPhase.paused) {
      // Calculate remaining time
      final elapsed =
          DateTime.now().difference(_sessionStartTime ?? DateTime.now());
      final remaining = state.sessionDuration - elapsed;

      if (remaining.isNegative) {
        _completeSession();
        return;
      }

      state = state.copyWith(
        phase: LearningSessionPhase.active,
        isPaused: false,
      );

      // Restart timer with remaining time
      _sessionTimer = Timer(remaining, () {
        _completeSession();
      });
    }
  }

  void flipCard() {
    if (state.currentSide == FlashcardSide.front) {
      state = state.copyWith(currentSide: FlashcardSide.back);
    }
  }

  Future<void> rateCurrentWord(String difficulty) async {
    final currentWord = state.currentWord;
    if (currentWord == null) return;

    final reviewStartTime = _sessionStartTime ?? DateTime.now();
    final timeSpent = DateTime.now().difference(reviewStartTime);

    // Create review record
    final difficultyEnum = ReviewDifficultyRating.values.firstWhere(
      (d) => d.name == difficulty.toLowerCase(),
      orElse: () => ReviewDifficultyRating.medium,
    );
    final review = SessionWordReview(
      word: currentWord.word,
      difficulty: difficultyEnum,
      reviewedAt: DateTime.now(),
      timeSpent: timeSpent,
    );

    // Update user word data and spaced repetition
    await _updateUserWordData(currentWord, difficulty);

    // Add to completed reviews
    final updatedReviews = [...state.completedReviews, review];

    state = state.copyWith(completedReviews: updatedReviews);

    // Move to next word
    _moveToNextWord();
  }

  Future<void> skipCurrentWord() async {
    final currentWord = state.currentWord;
    if (currentWord == null) return;

    final reviewStartTime = _sessionStartTime ?? DateTime.now();
    final timeSpent = DateTime.now().difference(reviewStartTime);

    // Create skip record
    final review = SessionWordReview(
      word: currentWord.word,
      difficulty:
          ReviewDifficultyRating.hard, // Skipped words are considered hard
      reviewedAt: DateTime.now(),
      timeSpent: timeSpent,
      wasSkipped: true,
    );

    final updatedReviews = [...state.completedReviews, review];
    state = state.copyWith(completedReviews: updatedReviews);

    // Move to next word
    _moveToNextWord();
  }

  void _moveToNextWord() {
    if (state.hasMoreWords) {
      state = state.copyWith(
        currentWordIndex: state.currentWordIndex + 1,
        currentSide: FlashcardSide.front,
      );
    } else {
      // If no more words, restart with the same set
      state = state.copyWith(
        currentWordIndex: 0,
        currentSide: FlashcardSide.front,
      );
    }
  }

  void _completeSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(
      phase: LearningSessionPhase.completed,
      sessionEndTime: DateTime.now(),
    );
  }

  void resetSession() {
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    state = const LearningSessionState();
  }

  Future<List<VocabularyWord>> _loadWordsForSession(SessionMode mode) async {
    final vocabularyRepo = ref.read(vocabularyRepositoryProvider);
    final userWordRepo = ref.read(userWordDataRepositoryProvider);

    final allWords = await vocabularyRepo.loadVocabulary();
    final userWordDataList = await userWordRepo.getAllUserWordData();

    final userWordMap = {for (final data in userWordDataList) data.word: data};

    switch (mode) {
      case SessionMode.allWords:
        return allWords;

      case SessionMode.dueForReview:
        final now = DateTime.now();
        return allWords.where((word) {
          final userData = userWordMap[word.word];
          if (userData == null) return true; // New words are due for review
          return userData.nextReview?.isBefore(now) ?? true;
        }).toList();

      case SessionMode.strugglingWords:
        return allWords.where((word) {
          final userData = userWordMap[word.word];
          if (userData == null) return false;
          return userData.accuracyRate < 0.6; // Less than 60% accuracy
        }).toList();

      case SessionMode.newWords:
        return allWords.where((word) {
          final userData = userWordMap[word.word];
          return userData == null || userData.learningStage == 'new';
        }).toList();
    }
  }

  Future<void> _updateUserWordData(
      VocabularyWord word, String difficulty) async {
    final userWordRepo = ref.read(userWordDataRepositoryProvider);
    final reviewRepo = ref.read(reviewActivityRepositoryProvider);

    // Get or create user word data
    UserWordData? userData = await userWordRepo.getUserWordData(word.word);

    final now = DateTime.now();
    final isCorrect = difficulty != ReviewDifficultyRating.hard.name;

    if (userData == null) {
      userData = UserWordData(
        word: word.word,
      );

      userData.notes = '';
      userData.isLearned = false;
      userData.reviewCount = 1;
      userData.lastReviewedAt = now;
      userData.firstLearnedAt = now;
      userData.correctAnswers = isCorrect ? 1 : 0;
      userData.totalAnswers = 1;
      userData.learningStage = LearningStage.learning;
      userData.hasBeenTested = true;
    } else {
      userData.reviewCount += 1;
      userData.lastReviewedAt = now;
      userData.totalAnswers += 1;
      userData.hasBeenTested = true;

      if (isCorrect) {
        userData.correctAnswers += 1;
      }

      // Update learning stage based on accuracy
      final accuracyRate = userData.accuracyRate;
      if (accuracyRate >= 0.8 && userData.reviewCount >= 3) {
        userData.learningStage = LearningStage.mastered;
        userData.isLearned = true;
      } else if (userData.reviewCount > 0) {
        userData.learningStage = LearningStage.learning;
      }
    }

    // Update next review date using spaced repetition
    final rating = switch (difficulty) {
      'easy' => ReviewRating.easy,
      'medium' => ReviewRating.medium,
      _ => ReviewRating.hard,
    };

    final result = SpacedRepetitionManager.calculateNextReview(
      now,
      rating,
      userData.interval,
      userData.repetitions,
      userData.easeFactor,
    );

    userData.nextReview = result.nextReview;
    userData.interval = result.interval;
    userData.repetitions = result.repetitions;
    userData.easeFactor = result.easeFactor;

    // Save user word data
    await userWordRepo.saveUserWordData(userData);

    // Save review activity
    final ratingEnum = ReviewDifficultyRating.values.firstWhere(
      (r) => r.name == difficulty.toLowerCase(),
      orElse: () => ReviewDifficultyRating.medium,
    );
    final reviewActivity = ReviewActivity(
      word: word.word,
      reviewedAt: now,
      rating: ratingEnum,
    );

    await reviewRepo.saveActivity(reviewActivity);

    // Invalidate providers for real-time updates across the app (like ProfileScreen)
    ref.invalidate(allUserWordDataProvider);
    ref.invalidate(reviewActivityListProvider);
  }

  LearningSessionSummary getSessionSummary() {
    final sessionDuration =
        state.sessionEndTime != null && state.sessionStartTime != null
            ? state.sessionEndTime!.difference(state.sessionStartTime!)
            : Duration.zero;

    final strugglingWords = <String>[];
    final masteredWords = <String>[];

    for (final review in state.completedReviews) {
      if (review.difficulty == ReviewDifficultyRating.hard ||
          review.wasSkipped) {
        strugglingWords.add(review.word);
      } else if (review.difficulty == ReviewDifficultyRating.easy) {
        masteredWords.add(review.word);
      }
    }

    final totalTimeSpent = state.completedReviews.fold<Duration>(
      Duration.zero,
      (sum, review) => sum + review.timeSpent,
    );

    final averageTimePerWord = state.wordsReviewed > 0
        ? totalTimeSpent.inSeconds / state.wordsReviewed.toDouble()
        : 0.0;

    final skippedWords =
        state.completedReviews.where((r) => r.wasSkipped).length;

    return LearningSessionSummary(
      sessionDuration: sessionDuration,
      wordsReviewed: state.wordsReviewed,
      uniqueWordsReviewed: state.uniqueWordsReviewed,
      difficultyBreakdown: state.difficultyBreakdown,
      averageTimePerWord: averageTimePerWord,
      skippedWords: skippedWords,
      strugglingWords: strugglingWords.toSet().toList(),
      masteredWords: masteredWords.toSet().toList(),
    );
  }
}

// Provider for remaining time in current session
@riverpod
Stream<Duration> sessionRemainingTime(SessionRemainingTimeRef ref) {
  final sessionState = ref.watch(learningSessionProvider);

  if (sessionState.phase != LearningSessionPhase.active ||
      sessionState.sessionStartTime == null) {
    return Stream.value(Duration.zero);
  }

  return Stream.periodic(const Duration(seconds: 1), (_) {
    final elapsed = DateTime.now().difference(sessionState.sessionStartTime!);
    final remaining = sessionState.sessionDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  });
}
