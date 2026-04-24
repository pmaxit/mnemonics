// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_session_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LearningSessionState {
  LearningSessionPhase get phase => throw _privateConstructorUsedError;
  SessionDuration get duration => throw _privateConstructorUsedError;
  SessionMode get mode => throw _privateConstructorUsedError;
  List<VocabularyWord> get sessionWords => throw _privateConstructorUsedError;
  int get currentWordIndex => throw _privateConstructorUsedError;
  FlashcardSide get currentSide => throw _privateConstructorUsedError;
  List<SessionWordReview> get completedReviews =>
      throw _privateConstructorUsedError;
  bool get isPaused => throw _privateConstructorUsedError;
  DateTime? get sessionStartTime => throw _privateConstructorUsedError;
  DateTime? get sessionEndTime => throw _privateConstructorUsedError;
  int get countdownSeconds => throw _privateConstructorUsedError;

  /// Create a copy of LearningSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LearningSessionStateCopyWith<LearningSessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningSessionStateCopyWith<$Res> {
  factory $LearningSessionStateCopyWith(LearningSessionState value,
          $Res Function(LearningSessionState) then) =
      _$LearningSessionStateCopyWithImpl<$Res, LearningSessionState>;
  @useResult
  $Res call(
      {LearningSessionPhase phase,
      SessionDuration duration,
      SessionMode mode,
      List<VocabularyWord> sessionWords,
      int currentWordIndex,
      FlashcardSide currentSide,
      List<SessionWordReview> completedReviews,
      bool isPaused,
      DateTime? sessionStartTime,
      DateTime? sessionEndTime,
      int countdownSeconds});
}

/// @nodoc
class _$LearningSessionStateCopyWithImpl<$Res,
        $Val extends LearningSessionState>
    implements $LearningSessionStateCopyWith<$Res> {
  _$LearningSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LearningSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? duration = null,
    Object? mode = null,
    Object? sessionWords = null,
    Object? currentWordIndex = null,
    Object? currentSide = null,
    Object? completedReviews = null,
    Object? isPaused = null,
    Object? sessionStartTime = freezed,
    Object? sessionEndTime = freezed,
    Object? countdownSeconds = null,
  }) {
    return _then(_value.copyWith(
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as LearningSessionPhase,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as SessionDuration,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as SessionMode,
      sessionWords: null == sessionWords
          ? _value.sessionWords
          : sessionWords // ignore: cast_nullable_to_non_nullable
              as List<VocabularyWord>,
      currentWordIndex: null == currentWordIndex
          ? _value.currentWordIndex
          : currentWordIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentSide: null == currentSide
          ? _value.currentSide
          : currentSide // ignore: cast_nullable_to_non_nullable
              as FlashcardSide,
      completedReviews: null == completedReviews
          ? _value.completedReviews
          : completedReviews // ignore: cast_nullable_to_non_nullable
              as List<SessionWordReview>,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionStartTime: freezed == sessionStartTime
          ? _value.sessionStartTime
          : sessionStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sessionEndTime: freezed == sessionEndTime
          ? _value.sessionEndTime
          : sessionEndTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      countdownSeconds: null == countdownSeconds
          ? _value.countdownSeconds
          : countdownSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LearningSessionStateImplCopyWith<$Res>
    implements $LearningSessionStateCopyWith<$Res> {
  factory _$$LearningSessionStateImplCopyWith(_$LearningSessionStateImpl value,
          $Res Function(_$LearningSessionStateImpl) then) =
      __$$LearningSessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LearningSessionPhase phase,
      SessionDuration duration,
      SessionMode mode,
      List<VocabularyWord> sessionWords,
      int currentWordIndex,
      FlashcardSide currentSide,
      List<SessionWordReview> completedReviews,
      bool isPaused,
      DateTime? sessionStartTime,
      DateTime? sessionEndTime,
      int countdownSeconds});
}

/// @nodoc
class __$$LearningSessionStateImplCopyWithImpl<$Res>
    extends _$LearningSessionStateCopyWithImpl<$Res, _$LearningSessionStateImpl>
    implements _$$LearningSessionStateImplCopyWith<$Res> {
  __$$LearningSessionStateImplCopyWithImpl(_$LearningSessionStateImpl _value,
      $Res Function(_$LearningSessionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LearningSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? duration = null,
    Object? mode = null,
    Object? sessionWords = null,
    Object? currentWordIndex = null,
    Object? currentSide = null,
    Object? completedReviews = null,
    Object? isPaused = null,
    Object? sessionStartTime = freezed,
    Object? sessionEndTime = freezed,
    Object? countdownSeconds = null,
  }) {
    return _then(_$LearningSessionStateImpl(
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as LearningSessionPhase,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as SessionDuration,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as SessionMode,
      sessionWords: null == sessionWords
          ? _value._sessionWords
          : sessionWords // ignore: cast_nullable_to_non_nullable
              as List<VocabularyWord>,
      currentWordIndex: null == currentWordIndex
          ? _value.currentWordIndex
          : currentWordIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentSide: null == currentSide
          ? _value.currentSide
          : currentSide // ignore: cast_nullable_to_non_nullable
              as FlashcardSide,
      completedReviews: null == completedReviews
          ? _value._completedReviews
          : completedReviews // ignore: cast_nullable_to_non_nullable
              as List<SessionWordReview>,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionStartTime: freezed == sessionStartTime
          ? _value.sessionStartTime
          : sessionStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sessionEndTime: freezed == sessionEndTime
          ? _value.sessionEndTime
          : sessionEndTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      countdownSeconds: null == countdownSeconds
          ? _value.countdownSeconds
          : countdownSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$LearningSessionStateImpl extends _LearningSessionState {
  const _$LearningSessionStateImpl(
      {this.phase = LearningSessionPhase.setup,
      this.duration = SessionDuration.tenMinutes,
      this.mode = SessionMode.dueForReview,
      final List<VocabularyWord> sessionWords = const <VocabularyWord>[],
      this.currentWordIndex = 0,
      this.currentSide = FlashcardSide.front,
      final List<SessionWordReview> completedReviews =
          const <SessionWordReview>[],
      this.isPaused = false,
      this.sessionStartTime,
      this.sessionEndTime,
      this.countdownSeconds = 3})
      : _sessionWords = sessionWords,
        _completedReviews = completedReviews,
        super._();

  @override
  @JsonKey()
  final LearningSessionPhase phase;
  @override
  @JsonKey()
  final SessionDuration duration;
  @override
  @JsonKey()
  final SessionMode mode;
  final List<VocabularyWord> _sessionWords;
  @override
  @JsonKey()
  List<VocabularyWord> get sessionWords {
    if (_sessionWords is EqualUnmodifiableListView) return _sessionWords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessionWords);
  }

  @override
  @JsonKey()
  final int currentWordIndex;
  @override
  @JsonKey()
  final FlashcardSide currentSide;
  final List<SessionWordReview> _completedReviews;
  @override
  @JsonKey()
  List<SessionWordReview> get completedReviews {
    if (_completedReviews is EqualUnmodifiableListView)
      return _completedReviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedReviews);
  }

  @override
  @JsonKey()
  final bool isPaused;
  @override
  final DateTime? sessionStartTime;
  @override
  final DateTime? sessionEndTime;
  @override
  @JsonKey()
  final int countdownSeconds;

  @override
  String toString() {
    return 'LearningSessionState(phase: $phase, duration: $duration, mode: $mode, sessionWords: $sessionWords, currentWordIndex: $currentWordIndex, currentSide: $currentSide, completedReviews: $completedReviews, isPaused: $isPaused, sessionStartTime: $sessionStartTime, sessionEndTime: $sessionEndTime, countdownSeconds: $countdownSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningSessionStateImpl &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            const DeepCollectionEquality()
                .equals(other._sessionWords, _sessionWords) &&
            (identical(other.currentWordIndex, currentWordIndex) ||
                other.currentWordIndex == currentWordIndex) &&
            (identical(other.currentSide, currentSide) ||
                other.currentSide == currentSide) &&
            const DeepCollectionEquality()
                .equals(other._completedReviews, _completedReviews) &&
            (identical(other.isPaused, isPaused) ||
                other.isPaused == isPaused) &&
            (identical(other.sessionStartTime, sessionStartTime) ||
                other.sessionStartTime == sessionStartTime) &&
            (identical(other.sessionEndTime, sessionEndTime) ||
                other.sessionEndTime == sessionEndTime) &&
            (identical(other.countdownSeconds, countdownSeconds) ||
                other.countdownSeconds == countdownSeconds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      phase,
      duration,
      mode,
      const DeepCollectionEquality().hash(_sessionWords),
      currentWordIndex,
      currentSide,
      const DeepCollectionEquality().hash(_completedReviews),
      isPaused,
      sessionStartTime,
      sessionEndTime,
      countdownSeconds);

  /// Create a copy of LearningSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningSessionStateImplCopyWith<_$LearningSessionStateImpl>
      get copyWith =>
          __$$LearningSessionStateImplCopyWithImpl<_$LearningSessionStateImpl>(
              this, _$identity);
}

abstract class _LearningSessionState extends LearningSessionState {
  const factory _LearningSessionState(
      {final LearningSessionPhase phase,
      final SessionDuration duration,
      final SessionMode mode,
      final List<VocabularyWord> sessionWords,
      final int currentWordIndex,
      final FlashcardSide currentSide,
      final List<SessionWordReview> completedReviews,
      final bool isPaused,
      final DateTime? sessionStartTime,
      final DateTime? sessionEndTime,
      final int countdownSeconds}) = _$LearningSessionStateImpl;
  const _LearningSessionState._() : super._();

  @override
  LearningSessionPhase get phase;
  @override
  SessionDuration get duration;
  @override
  SessionMode get mode;
  @override
  List<VocabularyWord> get sessionWords;
  @override
  int get currentWordIndex;
  @override
  FlashcardSide get currentSide;
  @override
  List<SessionWordReview> get completedReviews;
  @override
  bool get isPaused;
  @override
  DateTime? get sessionStartTime;
  @override
  DateTime? get sessionEndTime;
  @override
  int get countdownSeconds;

  /// Create a copy of LearningSessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LearningSessionStateImplCopyWith<_$LearningSessionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SessionWordReview {
  String get word => throw _privateConstructorUsedError;
  ReviewDifficultyRating get difficulty => throw _privateConstructorUsedError;
  DateTime get reviewedAt => throw _privateConstructorUsedError;
  Duration get timeSpent => throw _privateConstructorUsedError;
  bool get wasSkipped => throw _privateConstructorUsedError;

  /// Create a copy of SessionWordReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionWordReviewCopyWith<SessionWordReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionWordReviewCopyWith<$Res> {
  factory $SessionWordReviewCopyWith(
          SessionWordReview value, $Res Function(SessionWordReview) then) =
      _$SessionWordReviewCopyWithImpl<$Res, SessionWordReview>;
  @useResult
  $Res call(
      {String word,
      ReviewDifficultyRating difficulty,
      DateTime reviewedAt,
      Duration timeSpent,
      bool wasSkipped});
}

/// @nodoc
class _$SessionWordReviewCopyWithImpl<$Res, $Val extends SessionWordReview>
    implements $SessionWordReviewCopyWith<$Res> {
  _$SessionWordReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionWordReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? difficulty = null,
    Object? reviewedAt = null,
    Object? timeSpent = null,
    Object? wasSkipped = null,
  }) {
    return _then(_value.copyWith(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as ReviewDifficultyRating,
      reviewedAt: null == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      timeSpent: null == timeSpent
          ? _value.timeSpent
          : timeSpent // ignore: cast_nullable_to_non_nullable
              as Duration,
      wasSkipped: null == wasSkipped
          ? _value.wasSkipped
          : wasSkipped // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionWordReviewImplCopyWith<$Res>
    implements $SessionWordReviewCopyWith<$Res> {
  factory _$$SessionWordReviewImplCopyWith(_$SessionWordReviewImpl value,
          $Res Function(_$SessionWordReviewImpl) then) =
      __$$SessionWordReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String word,
      ReviewDifficultyRating difficulty,
      DateTime reviewedAt,
      Duration timeSpent,
      bool wasSkipped});
}

/// @nodoc
class __$$SessionWordReviewImplCopyWithImpl<$Res>
    extends _$SessionWordReviewCopyWithImpl<$Res, _$SessionWordReviewImpl>
    implements _$$SessionWordReviewImplCopyWith<$Res> {
  __$$SessionWordReviewImplCopyWithImpl(_$SessionWordReviewImpl _value,
      $Res Function(_$SessionWordReviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessionWordReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? difficulty = null,
    Object? reviewedAt = null,
    Object? timeSpent = null,
    Object? wasSkipped = null,
  }) {
    return _then(_$SessionWordReviewImpl(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as ReviewDifficultyRating,
      reviewedAt: null == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      timeSpent: null == timeSpent
          ? _value.timeSpent
          : timeSpent // ignore: cast_nullable_to_non_nullable
              as Duration,
      wasSkipped: null == wasSkipped
          ? _value.wasSkipped
          : wasSkipped // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SessionWordReviewImpl implements _SessionWordReview {
  const _$SessionWordReviewImpl(
      {required this.word,
      required this.difficulty,
      required this.reviewedAt,
      required this.timeSpent,
      this.wasSkipped = false});

  @override
  final String word;
  @override
  final ReviewDifficultyRating difficulty;
  @override
  final DateTime reviewedAt;
  @override
  final Duration timeSpent;
  @override
  @JsonKey()
  final bool wasSkipped;

  @override
  String toString() {
    return 'SessionWordReview(word: $word, difficulty: $difficulty, reviewedAt: $reviewedAt, timeSpent: $timeSpent, wasSkipped: $wasSkipped)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionWordReviewImpl &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.timeSpent, timeSpent) ||
                other.timeSpent == timeSpent) &&
            (identical(other.wasSkipped, wasSkipped) ||
                other.wasSkipped == wasSkipped));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, word, difficulty, reviewedAt, timeSpent, wasSkipped);

  /// Create a copy of SessionWordReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionWordReviewImplCopyWith<_$SessionWordReviewImpl> get copyWith =>
      __$$SessionWordReviewImplCopyWithImpl<_$SessionWordReviewImpl>(
          this, _$identity);
}

abstract class _SessionWordReview implements SessionWordReview {
  const factory _SessionWordReview(
      {required final String word,
      required final ReviewDifficultyRating difficulty,
      required final DateTime reviewedAt,
      required final Duration timeSpent,
      final bool wasSkipped}) = _$SessionWordReviewImpl;

  @override
  String get word;
  @override
  ReviewDifficultyRating get difficulty;
  @override
  DateTime get reviewedAt;
  @override
  Duration get timeSpent;
  @override
  bool get wasSkipped;

  /// Create a copy of SessionWordReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionWordReviewImplCopyWith<_$SessionWordReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LearningSessionSummary {
  Duration get sessionDuration => throw _privateConstructorUsedError;
  int get wordsReviewed => throw _privateConstructorUsedError;
  int get uniqueWordsReviewed => throw _privateConstructorUsedError;
  Map<String, int> get difficultyBreakdown =>
      throw _privateConstructorUsedError;
  double get averageTimePerWord => throw _privateConstructorUsedError;
  int get skippedWords => throw _privateConstructorUsedError;
  List<String> get strugglingWords => throw _privateConstructorUsedError;
  List<String> get masteredWords => throw _privateConstructorUsedError;

  /// Create a copy of LearningSessionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LearningSessionSummaryCopyWith<LearningSessionSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningSessionSummaryCopyWith<$Res> {
  factory $LearningSessionSummaryCopyWith(LearningSessionSummary value,
          $Res Function(LearningSessionSummary) then) =
      _$LearningSessionSummaryCopyWithImpl<$Res, LearningSessionSummary>;
  @useResult
  $Res call(
      {Duration sessionDuration,
      int wordsReviewed,
      int uniqueWordsReviewed,
      Map<String, int> difficultyBreakdown,
      double averageTimePerWord,
      int skippedWords,
      List<String> strugglingWords,
      List<String> masteredWords});
}

/// @nodoc
class _$LearningSessionSummaryCopyWithImpl<$Res,
        $Val extends LearningSessionSummary>
    implements $LearningSessionSummaryCopyWith<$Res> {
  _$LearningSessionSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LearningSessionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionDuration = null,
    Object? wordsReviewed = null,
    Object? uniqueWordsReviewed = null,
    Object? difficultyBreakdown = null,
    Object? averageTimePerWord = null,
    Object? skippedWords = null,
    Object? strugglingWords = null,
    Object? masteredWords = null,
  }) {
    return _then(_value.copyWith(
      sessionDuration: null == sessionDuration
          ? _value.sessionDuration
          : sessionDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      wordsReviewed: null == wordsReviewed
          ? _value.wordsReviewed
          : wordsReviewed // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueWordsReviewed: null == uniqueWordsReviewed
          ? _value.uniqueWordsReviewed
          : uniqueWordsReviewed // ignore: cast_nullable_to_non_nullable
              as int,
      difficultyBreakdown: null == difficultyBreakdown
          ? _value.difficultyBreakdown
          : difficultyBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      averageTimePerWord: null == averageTimePerWord
          ? _value.averageTimePerWord
          : averageTimePerWord // ignore: cast_nullable_to_non_nullable
              as double,
      skippedWords: null == skippedWords
          ? _value.skippedWords
          : skippedWords // ignore: cast_nullable_to_non_nullable
              as int,
      strugglingWords: null == strugglingWords
          ? _value.strugglingWords
          : strugglingWords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      masteredWords: null == masteredWords
          ? _value.masteredWords
          : masteredWords // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LearningSessionSummaryImplCopyWith<$Res>
    implements $LearningSessionSummaryCopyWith<$Res> {
  factory _$$LearningSessionSummaryImplCopyWith(
          _$LearningSessionSummaryImpl value,
          $Res Function(_$LearningSessionSummaryImpl) then) =
      __$$LearningSessionSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Duration sessionDuration,
      int wordsReviewed,
      int uniqueWordsReviewed,
      Map<String, int> difficultyBreakdown,
      double averageTimePerWord,
      int skippedWords,
      List<String> strugglingWords,
      List<String> masteredWords});
}

/// @nodoc
class __$$LearningSessionSummaryImplCopyWithImpl<$Res>
    extends _$LearningSessionSummaryCopyWithImpl<$Res,
        _$LearningSessionSummaryImpl>
    implements _$$LearningSessionSummaryImplCopyWith<$Res> {
  __$$LearningSessionSummaryImplCopyWithImpl(
      _$LearningSessionSummaryImpl _value,
      $Res Function(_$LearningSessionSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of LearningSessionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionDuration = null,
    Object? wordsReviewed = null,
    Object? uniqueWordsReviewed = null,
    Object? difficultyBreakdown = null,
    Object? averageTimePerWord = null,
    Object? skippedWords = null,
    Object? strugglingWords = null,
    Object? masteredWords = null,
  }) {
    return _then(_$LearningSessionSummaryImpl(
      sessionDuration: null == sessionDuration
          ? _value.sessionDuration
          : sessionDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      wordsReviewed: null == wordsReviewed
          ? _value.wordsReviewed
          : wordsReviewed // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueWordsReviewed: null == uniqueWordsReviewed
          ? _value.uniqueWordsReviewed
          : uniqueWordsReviewed // ignore: cast_nullable_to_non_nullable
              as int,
      difficultyBreakdown: null == difficultyBreakdown
          ? _value._difficultyBreakdown
          : difficultyBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      averageTimePerWord: null == averageTimePerWord
          ? _value.averageTimePerWord
          : averageTimePerWord // ignore: cast_nullable_to_non_nullable
              as double,
      skippedWords: null == skippedWords
          ? _value.skippedWords
          : skippedWords // ignore: cast_nullable_to_non_nullable
              as int,
      strugglingWords: null == strugglingWords
          ? _value._strugglingWords
          : strugglingWords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      masteredWords: null == masteredWords
          ? _value._masteredWords
          : masteredWords // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$LearningSessionSummaryImpl extends _LearningSessionSummary {
  const _$LearningSessionSummaryImpl(
      {required this.sessionDuration,
      required this.wordsReviewed,
      required this.uniqueWordsReviewed,
      required final Map<String, int> difficultyBreakdown,
      required this.averageTimePerWord,
      required this.skippedWords,
      required final List<String> strugglingWords,
      required final List<String> masteredWords})
      : _difficultyBreakdown = difficultyBreakdown,
        _strugglingWords = strugglingWords,
        _masteredWords = masteredWords,
        super._();

  @override
  final Duration sessionDuration;
  @override
  final int wordsReviewed;
  @override
  final int uniqueWordsReviewed;
  final Map<String, int> _difficultyBreakdown;
  @override
  Map<String, int> get difficultyBreakdown {
    if (_difficultyBreakdown is EqualUnmodifiableMapView)
      return _difficultyBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_difficultyBreakdown);
  }

  @override
  final double averageTimePerWord;
  @override
  final int skippedWords;
  final List<String> _strugglingWords;
  @override
  List<String> get strugglingWords {
    if (_strugglingWords is EqualUnmodifiableListView) return _strugglingWords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strugglingWords);
  }

  final List<String> _masteredWords;
  @override
  List<String> get masteredWords {
    if (_masteredWords is EqualUnmodifiableListView) return _masteredWords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_masteredWords);
  }

  @override
  String toString() {
    return 'LearningSessionSummary(sessionDuration: $sessionDuration, wordsReviewed: $wordsReviewed, uniqueWordsReviewed: $uniqueWordsReviewed, difficultyBreakdown: $difficultyBreakdown, averageTimePerWord: $averageTimePerWord, skippedWords: $skippedWords, strugglingWords: $strugglingWords, masteredWords: $masteredWords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningSessionSummaryImpl &&
            (identical(other.sessionDuration, sessionDuration) ||
                other.sessionDuration == sessionDuration) &&
            (identical(other.wordsReviewed, wordsReviewed) ||
                other.wordsReviewed == wordsReviewed) &&
            (identical(other.uniqueWordsReviewed, uniqueWordsReviewed) ||
                other.uniqueWordsReviewed == uniqueWordsReviewed) &&
            const DeepCollectionEquality()
                .equals(other._difficultyBreakdown, _difficultyBreakdown) &&
            (identical(other.averageTimePerWord, averageTimePerWord) ||
                other.averageTimePerWord == averageTimePerWord) &&
            (identical(other.skippedWords, skippedWords) ||
                other.skippedWords == skippedWords) &&
            const DeepCollectionEquality()
                .equals(other._strugglingWords, _strugglingWords) &&
            const DeepCollectionEquality()
                .equals(other._masteredWords, _masteredWords));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionDuration,
      wordsReviewed,
      uniqueWordsReviewed,
      const DeepCollectionEquality().hash(_difficultyBreakdown),
      averageTimePerWord,
      skippedWords,
      const DeepCollectionEquality().hash(_strugglingWords),
      const DeepCollectionEquality().hash(_masteredWords));

  /// Create a copy of LearningSessionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningSessionSummaryImplCopyWith<_$LearningSessionSummaryImpl>
      get copyWith => __$$LearningSessionSummaryImplCopyWithImpl<
          _$LearningSessionSummaryImpl>(this, _$identity);
}

abstract class _LearningSessionSummary extends LearningSessionSummary {
  const factory _LearningSessionSummary(
          {required final Duration sessionDuration,
          required final int wordsReviewed,
          required final int uniqueWordsReviewed,
          required final Map<String, int> difficultyBreakdown,
          required final double averageTimePerWord,
          required final int skippedWords,
          required final List<String> strugglingWords,
          required final List<String> masteredWords}) =
      _$LearningSessionSummaryImpl;
  const _LearningSessionSummary._() : super._();

  @override
  Duration get sessionDuration;
  @override
  int get wordsReviewed;
  @override
  int get uniqueWordsReviewed;
  @override
  Map<String, int> get difficultyBreakdown;
  @override
  double get averageTimePerWord;
  @override
  int get skippedWords;
  @override
  List<String> get strugglingWords;
  @override
  List<String> get masteredWords;

  /// Create a copy of LearningSessionSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LearningSessionSummaryImplCopyWith<_$LearningSessionSummaryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
