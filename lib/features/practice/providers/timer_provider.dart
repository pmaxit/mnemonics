import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';
import '../domain/timer_models.dart';
import '../../home/domain/vocabulary_word.dart';
import '../../home/domain/user_word_data.dart';
import '../../home/providers.dart';
import '../domain/user_progress_service.dart';

final timerSessionProvider = StateNotifierProvider<TimerSessionNotifier, TimerSessionState>((ref) {
  return TimerSessionNotifier(
    vocabularyProvider: ref.watch(vocabularyListProvider),
    userWordDataProvider: ref.watch(allUserWordDataProvider),
    progressService: ref.watch(userProgressServiceProvider),
  );
});

final sessionTimeProvider = StateProvider<Duration>((ref) => Duration.zero);

final wordUserDataProvider = FutureProvider.family<UserWordData?, String>((ref, word) async {
  final userDataList = await ref.watch(allUserWordDataProvider.future);
  try {
    return userDataList.firstWhere((data) => data.word == word);
  } catch (e) {
    return null; // Return null if no data found for this word
  }
});

class TimerSessionNotifier extends StateNotifier<TimerSessionState> {
  final AsyncValue<List<VocabularyWord>> vocabularyProvider;
  final AsyncValue<List<UserWordData>> userWordDataProvider;
  final UserProgressService progressService;
  
  Timer? _sessionTimer;
  Timer? _wordTimer;
  DateTime? _currentWordStartTime;

  TimerSessionNotifier({
    required this.vocabularyProvider,
    required this.userWordDataProvider,
    required this.progressService,
  }) : super(const TimerSessionState());

  void updateSelectedMinutes(int minutes) {
    state = state.copyWith(selectedMinutes: minutes);
  }

  void updateStudyMode(TimerMode mode) {
    state = state.copyWith(studyMode: mode);
  }

  void updateSelectedCategories(List<String> categories) {
    state = state.copyWith(selectedCategories: categories);
  }

  Future<void> startSession() async {
    await _prepareSessionWords();
    
    if (state.sessionWords.isEmpty) {
      return; // No words to study
    }

    state = state.copyWith(
      currentPhase: SessionPhase.countdown,
      sessionStartTime: DateTime.now(),
      currentWordIndex: 0,
      completedReviews: [],
      isCardRevealed: false,
    );

    // Start countdown, then begin session
    await Future.delayed(const Duration(seconds: 3));
    
    state = state.copyWith(
      currentPhase: SessionPhase.active,
      isSessionActive: true,
    );

    _startSessionTimer();
    _startWordTimer();
  }

  Future<void> _prepareSessionWords() async {
    final vocabData = vocabularyProvider.asData?.value ?? [];
    final userDataList = userWordDataProvider.asData?.value ?? [];
    
    List<VocabularyWord> selectedWords = [];

    switch (state.studyMode) {
      case TimerMode.allWords:
        selectedWords = List.from(vocabData);
        break;
      case TimerMode.difficultOnly:
        selectedWords = vocabData.where((word) {
          final userData = userDataList.firstWhere(
            (data) => data.word == word.word,
            orElse: () => UserWordData(word: word.word),
          );
          return userData.accuracyRate < 0.7; // Difficult words have low accuracy
        }).toList();
        break;
      case TimerMode.newWords:
        selectedWords = vocabData.where((word) {
          final userData = userDataList.firstWhere(
            (data) => data.word == word.word,
            orElse: () => UserWordData(word: word.word),
          );
          return userData.reviewCount == 0; // New words haven't been reviewed
        }).toList();
        break;
      case TimerMode.category:
        selectedWords = vocabData.where((word) {
          return state.selectedCategories.contains(word.category);
        }).toList();
        break;
    }

    // Shuffle words and limit based on time
    selectedWords.shuffle();
    final estimatedWordsPerMinute = 2;
    final maxWords = state.selectedMinutes * estimatedWordsPerMinute;
    
    if (selectedWords.length > maxWords) {
      selectedWords = selectedWords.take(maxWords).toList();
    }

    state = state.copyWith(sessionWords: selectedWords);
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final elapsed = DateTime.now().difference(state.sessionStartTime!);
      final totalDuration = Duration(minutes: state.selectedMinutes);
      
      if (elapsed >= totalDuration) {
        _endSession();
      }
    });
  }

  void _startWordTimer() {
    _currentWordStartTime = DateTime.now();
  }

  void revealCard() {
    state = state.copyWith(isCardRevealed: true);
  }

  void rateCurrentWord(ReviewDifficulty difficulty) {
    if (state.sessionWords.isEmpty) return;

    final currentWord = state.sessionWords[state.currentWordIndex];
    final timeSpent = _currentWordStartTime != null
        ? DateTime.now().difference(_currentWordStartTime!)
        : Duration.zero;

    final review = WordReview(
      word: currentWord.word,
      reviewedAt: DateTime.now(),
      difficulty: difficulty,
      timeSpent: timeSpent,
    );

    // Update progress through service
    _recordProgress(currentWord.word, difficulty);

    final updatedReviews = [...state.completedReviews, review];
    
    // Move to next random word - don't end session until timer runs out
    final nextIndex = _getNextRandomWordIndex();
    
    state = state.copyWith(
      currentWordIndex: nextIndex,
      completedReviews: updatedReviews,
      isCardRevealed: false,
    );
    _startWordTimer();
  }

  void _recordProgress(String word, ReviewDifficulty difficulty) {
    final isCorrect = difficulty == ReviewDifficulty.easy;
    progressService.recordWordLearned(word, isCorrect: isCorrect);
    
    // Record review activity
    final ratingString = difficulty.name;
    progressService.recordReviewActivity(word, ratingString);
  }

  int _getNextRandomWordIndex() {
    // Randomly select from all available words, allowing repetition
    final random = Random();
    return random.nextInt(state.sessionWords.length);
  }

  Set<String> getUniqueWordsReviewed() {
    return state.completedReviews.map((review) => review.word).toSet();
  }

  void skipCurrentWord() {
    if (state.sessionWords.isEmpty) return;

    final currentWord = state.sessionWords[state.currentWordIndex];
    final timeSpent = _currentWordStartTime != null
        ? DateTime.now().difference(_currentWordStartTime!)
        : Duration.zero;

    final review = WordReview(
      word: currentWord.word,
      reviewedAt: DateTime.now(),
      difficulty: ReviewDifficulty.hard, // Treat skip as hard
      timeSpent: timeSpent,
      wasSkipped: true,
    );

    final updatedReviews = [...state.completedReviews, review];
    
    // Move to next random word - don't end session until timer runs out
    final nextIndex = _getNextRandomWordIndex();
    
    state = state.copyWith(
      currentWordIndex: nextIndex,
      completedReviews: updatedReviews,
      isCardRevealed: false,
    );
    _startWordTimer();
  }

  void pauseSession() {
    state = state.copyWith(isPaused: true, currentPhase: SessionPhase.paused);
    _sessionTimer?.cancel();
  }

  void resumeSession() {
    state = state.copyWith(isPaused: false, currentPhase: SessionPhase.active);
    _startSessionTimer();
  }

  void _endSession() {
    _sessionTimer?.cancel();
    _wordTimer?.cancel();
    
    state = state.copyWith(
      isSessionActive: false,
      currentPhase: SessionPhase.completed,
    );
  }

  SessionSummary getSessionSummary() {
    final totalTime = Duration(minutes: state.selectedMinutes);
    final timeUsed = state.sessionStartTime != null
        ? DateTime.now().difference(state.sessionStartTime!)
        : Duration.zero;

    final difficultyBreakdown = <ReviewDifficulty, int>{
      ReviewDifficulty.easy: 0,
      ReviewDifficulty.medium: 0,
      ReviewDifficulty.hard: 0,
    };

    for (final review in state.completedReviews) {
      difficultyBreakdown[review.difficulty] = 
          (difficultyBreakdown[review.difficulty] ?? 0) + 1;
    }

    final wordsPerMinute = timeUsed.inMinutes > 0
        ? state.completedReviews.length / timeUsed.inMinutes
        : 0.0;

    final strugglingWords = state.completedReviews
        .where((review) => review.difficulty == ReviewDifficulty.hard)
        .map((review) => review.word)
        .toList();

    final masteredWords = state.completedReviews
        .where((review) => review.difficulty == ReviewDifficulty.easy)
        .map((review) => review.word)
        .toList();

    return SessionSummary(
      wordsReviewed: state.completedReviews.length,
      totalTime: totalTime,
      timeUsed: timeUsed,
      difficultyBreakdown: difficultyBreakdown,
      wordsPerMinute: wordsPerMinute,
      streakCount: _calculateStreak(),
      strugglingWords: strugglingWords,
      masteredWords: masteredWords,
    );
  }

  int _calculateStreak() {
    int streak = 0;
    for (int i = state.completedReviews.length - 1; i >= 0; i--) {
      if (state.completedReviews[i].difficulty == ReviewDifficulty.easy) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  void resetSession() {
    _sessionTimer?.cancel();
    _wordTimer?.cancel();
    
    state = const TimerSessionState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _wordTimer?.cancel();
    super.dispose();
  }
}

// Helper provider for session time remaining
final sessionTimeRemainingProvider = StreamProvider<Duration>((ref) async* {
  final sessionState = ref.watch(timerSessionProvider);
  
  if (!sessionState.isSessionActive || sessionState.sessionStartTime == null) {
    yield Duration.zero;
    return;
  }

  yield* Stream.periodic(const Duration(seconds: 1), (count) {
    final elapsed = DateTime.now().difference(sessionState.sessionStartTime!);
    final totalDuration = Duration(minutes: sessionState.selectedMinutes);
    final remaining = totalDuration - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  });
});