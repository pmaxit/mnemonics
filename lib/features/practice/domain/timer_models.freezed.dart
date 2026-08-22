// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimerSessionState _$TimerSessionStateFromJson(Map<String, dynamic> json) {
  return _TimerSessionState.fromJson(json);
}

/// @nodoc
mixin _$TimerSessionState {
  int get selectedMinutes => throw _privateConstructorUsedError;
  TimerMode get studyMode => throw _privateConstructorUsedError;
  List<String> get selectedCategories => throw _privateConstructorUsedError;
  List<VocabularyWord> get sessionWords => throw _privateConstructorUsedError;
  int get currentWordIndex => throw _privateConstructorUsedError;
  DateTime? get sessionStartTime => throw _privateConstructorUsedError;
  List<WordReview> get completedReviews => throw _privateConstructorUsedError;
  bool get isSessionActive => throw _privateConstructorUsedError;
  bool get isCardRevealed => throw _privateConstructorUsedError;
  bool get isPaused => throw _privateConstructorUsedError;
  SessionPhase get currentPhase => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimerSessionStateCopyWith<TimerSessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionStateCopyWith<$Res> {
  factory $TimerSessionStateCopyWith(
          TimerSessionState value, $Res Function(TimerSessionState) then) =
      _$TimerSessionStateCopyWithImpl<$Res, TimerSessionState>;
  @useResult
  $Res call(
      {int selectedMinutes,
      TimerMode studyMode,
      List<String> selectedCategories,
      List<VocabularyWord> sessionWords,
      int currentWordIndex,
      DateTime? sessionStartTime,
      List<WordReview> completedReviews,
      bool isSessionActive,
      bool isCardRevealed,
      bool isPaused,
      SessionPhase currentPhase});
}

/// @nodoc
class _$TimerSessionStateCopyWithImpl<$Res, $Val extends TimerSessionState>
    implements $TimerSessionStateCopyWith<$Res> {
  _$TimerSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedMinutes = null,
    Object? studyMode = null,
    Object? selectedCategories = null,
    Object? sessionWords = null,
    Object? currentWordIndex = null,
    Object? sessionStartTime = freezed,
    Object? completedReviews = null,
    Object? isSessionActive = null,
    Object? isCardRevealed = null,
    Object? isPaused = null,
    Object? currentPhase = null,
  }) {
    return _then(_value.copyWith(
      selectedMinutes: null == selectedMinutes
          ? _value.selectedMinutes
          : selectedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      studyMode: null == studyMode
          ? _value.studyMode
          : studyMode // ignore: cast_nullable_to_non_nullable
              as TimerMode,
      selectedCategories: null == selectedCategories
          ? _value.selectedCategories
          : selectedCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sessionWords: null == sessionWords
          ? _value.sessionWords
          : sessionWords // ignore: cast_nullable_to_non_nullable
              as List<VocabularyWord>,
      currentWordIndex: null == currentWordIndex
          ? _value.currentWordIndex
          : currentWordIndex // ignore: cast_nullable_to_non_nullable
              as int,
      sessionStartTime: freezed == sessionStartTime
          ? _value.sessionStartTime
          : sessionStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedReviews: null == completedReviews
          ? _value.completedReviews
          : completedReviews // ignore: cast_nullable_to_non_nullable
              as List<WordReview>,
      isSessionActive: null == isSessionActive
          ? _value.isSessionActive
          : isSessionActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isCardRevealed: null == isCardRevealed
          ? _value.isCardRevealed
          : isCardRevealed // ignore: cast_nullable_to_non_nullable
              as bool,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPhase: null == currentPhase
          ? _value.currentPhase
          : currentPhase // ignore: cast_nullable_to_non_nullable
              as SessionPhase,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimerSessionStateImplCopyWith<$Res>
    implements $TimerSessionStateCopyWith<$Res> {
  factory _$$TimerSessionStateImplCopyWith(_$TimerSessionStateImpl value,
          $Res Function(_$TimerSessionStateImpl) then) =
      __$$TimerSessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int selectedMinutes,
      TimerMode studyMode,
      List<String> selectedCategories,
      List<VocabularyWord> sessionWords,
      int currentWordIndex,
      DateTime? sessionStartTime,
      List<WordReview> completedReviews,
      bool isSessionActive,
      bool isCardRevealed,
      bool isPaused,
      SessionPhase currentPhase});
}

/// @nodoc
class __$$TimerSessionStateImplCopyWithImpl<$Res>
    extends _$TimerSessionStateCopyWithImpl<$Res, _$TimerSessionStateImpl>
    implements _$$TimerSessionStateImplCopyWith<$Res> {
  __$$TimerSessionStateImplCopyWithImpl(_$TimerSessionStateImpl _value,
      $Res Function(_$TimerSessionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedMinutes = null,
    Object? studyMode = null,
    Object? selectedCategories = null,
    Object? sessionWords = null,
    Object? currentWordIndex = null,
    Object? sessionStartTime = freezed,
    Object? completedReviews = null,
    Object? isSessionActive = null,
    Object? isCardRevealed = null,
    Object? isPaused = null,
    Object? currentPhase = null,
  }) {
    return _then(_$TimerSessionStateImpl(
      selectedMinutes: null == selectedMinutes
          ? _value.selectedMinutes
          : selectedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      studyMode: null == studyMode
          ? _value.studyMode
          : studyMode // ignore: cast_nullable_to_non_nullable
              as TimerMode,
      selectedCategories: null == selectedCategories
          ? _value._selectedCategories
          : selectedCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sessionWords: null == sessionWords
          ? _value._sessionWords
          : sessionWords // ignore: cast_nullable_to_non_nullable
              as List<VocabularyWord>,
      currentWordIndex: null == currentWordIndex
          ? _value.currentWordIndex
          : currentWordIndex // ignore: cast_nullable_to_non_nullable
              as int,
      sessionStartTime: freezed == sessionStartTime
          ? _value.sessionStartTime
          : sessionStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedReviews: null == completedReviews
          ? _value._completedReviews
          : completedReviews // ignore: cast_nullable_to_non_nullable
              as List<WordReview>,
      isSessionActive: null == isSessionActive
          ? _value.isSessionActive
          : isSessionActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isCardRevealed: null == isCardRevealed
          ? _value.isCardRevealed
          : isCardRevealed // ignore: cast_nullable_to_non_nullable
              as bool,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPhase: null == currentPhase
          ? _value.currentPhase
          : currentPhase // ignore: cast_nullable_to_non_nullable
              as SessionPhase,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimerSessionStateImpl implements _TimerSessionState {
  const _$TimerSessionStateImpl(
      {this.selectedMinutes = 10,
      this.studyMode = TimerMode.allWords,
      final List<String> selectedCategories = const [],
      final List<VocabularyWord> sessionWords = const [],
      this.currentWordIndex = 0,
      this.sessionStartTime,
      final List<WordReview> completedReviews = const [],
      this.isSessionActive = false,
      this.isCardRevealed = false,
      this.isPaused = false,
      this.currentPhase = SessionPhase.setup})
      : _selectedCategories = selectedCategories,
        _sessionWords = sessionWords,
        _completedReviews = completedReviews;

  factory _$TimerSessionStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimerSessionStateImplFromJson(json);

  @override
  @JsonKey()
  final int selectedMinutes;
  @override
  @JsonKey()
  final TimerMode studyMode;
  final List<String> _selectedCategories;
  @override
  @JsonKey()
  List<String> get selectedCategories {
    if (_selectedCategories is EqualUnmodifiableListView)
      return _selectedCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedCategories);
  }

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
  final DateTime? sessionStartTime;
  final List<WordReview> _completedReviews;
  @override
  @JsonKey()
  List<WordReview> get completedReviews {
    if (_completedReviews is EqualUnmodifiableListView)
      return _completedReviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedReviews);
  }

  @override
  @JsonKey()
  final bool isSessionActive;
  @override
  @JsonKey()
  final bool isCardRevealed;
  @override
  @JsonKey()
  final bool isPaused;
  @override
  @JsonKey()
  final SessionPhase currentPhase;

  @override
  String toString() {
    return 'TimerSessionState(selectedMinutes: $selectedMinutes, studyMode: $studyMode, selectedCategories: $selectedCategories, sessionWords: $sessionWords, currentWordIndex: $currentWordIndex, sessionStartTime: $sessionStartTime, completedReviews: $completedReviews, isSessionActive: $isSessionActive, isCardRevealed: $isCardRevealed, isPaused: $isPaused, currentPhase: $currentPhase)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionStateImpl &&
            (identical(other.selectedMinutes, selectedMinutes) ||
                other.selectedMinutes == selectedMinutes) &&
            (identical(other.studyMode, studyMode) ||
                other.studyMode == studyMode) &&
            const DeepCollectionEquality()
                .equals(other._selectedCategories, _selectedCategories) &&
            const DeepCollectionEquality()
                .equals(other._sessionWords, _sessionWords) &&
            (identical(other.currentWordIndex, currentWordIndex) ||
                other.currentWordIndex == currentWordIndex) &&
            (identical(other.sessionStartTime, sessionStartTime) ||
                other.sessionStartTime == sessionStartTime) &&
            const DeepCollectionEquality()
                .equals(other._completedReviews, _completedReviews) &&
            (identical(other.isSessionActive, isSessionActive) ||
                other.isSessionActive == isSessionActive) &&
            (identical(other.isCardRevealed, isCardRevealed) ||
                other.isCardRevealed == isCardRevealed) &&
            (identical(other.isPaused, isPaused) ||
                other.isPaused == isPaused) &&
            (identical(other.currentPhase, currentPhase) ||
                other.currentPhase == currentPhase));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedMinutes,
      studyMode,
      const DeepCollectionEquality().hash(_selectedCategories),
      const DeepCollectionEquality().hash(_sessionWords),
      currentWordIndex,
      sessionStartTime,
      const DeepCollectionEquality().hash(_completedReviews),
      isSessionActive,
      isCardRevealed,
      isPaused,
      currentPhase);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionStateImplCopyWith<_$TimerSessionStateImpl> get copyWith =>
      __$$TimerSessionStateImplCopyWithImpl<_$TimerSessionStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimerSessionStateImplToJson(
      this,
    );
  }
}

abstract class _TimerSessionState implements TimerSessionState {
  const factory _TimerSessionState(
      {final int selectedMinutes,
      final TimerMode studyMode,
      final List<String> selectedCategories,
      final List<VocabularyWord> sessionWords,
      final int currentWordIndex,
      final DateTime? sessionStartTime,
      final List<WordReview> completedReviews,
      final bool isSessionActive,
      final bool isCardRevealed,
      final bool isPaused,
      final SessionPhase currentPhase}) = _$TimerSessionStateImpl;

  factory _TimerSessionState.fromJson(Map<String, dynamic> json) =
      _$TimerSessionStateImpl.fromJson;

  @override
  int get selectedMinutes;
  @override
  TimerMode get studyMode;
  @override
  List<String> get selectedCategories;
  @override
  List<VocabularyWord> get sessionWords;
  @override
  int get currentWordIndex;
  @override
  DateTime? get sessionStartTime;
  @override
  List<WordReview> get completedReviews;
  @override
  bool get isSessionActive;
  @override
  bool get isCardRevealed;
  @override
  bool get isPaused;
  @override
  SessionPhase get currentPhase;
  @override
  @JsonKey(ignore: true)
  _$$TimerSessionStateImplCopyWith<_$TimerSessionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WordReview _$WordReviewFromJson(Map<String, dynamic> json) {
  return _WordReview.fromJson(json);
}

/// @nodoc
mixin _$WordReview {
  String get word => throw _privateConstructorUsedError;
  DateTime get reviewedAt => throw _privateConstructorUsedError;
  ReviewDifficulty get difficulty => throw _privateConstructorUsedError;
  Duration get timeSpent => throw _privateConstructorUsedError;
  bool get wasSkipped => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WordReviewCopyWith<WordReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordReviewCopyWith<$Res> {
  factory $WordReviewCopyWith(
          WordReview value, $Res Function(WordReview) then) =
      _$WordReviewCopyWithImpl<$Res, WordReview>;
  @useResult
  $Res call(
      {String word,
      DateTime reviewedAt,
      ReviewDifficulty difficulty,
      Duration timeSpent,
      bool wasSkipped});
}

/// @nodoc
class _$WordReviewCopyWithImpl<$Res, $Val extends WordReview>
    implements $WordReviewCopyWith<$Res> {
  _$WordReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? reviewedAt = null,
    Object? difficulty = null,
    Object? timeSpent = null,
    Object? wasSkipped = null,
  }) {
    return _then(_value.copyWith(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      reviewedAt: null == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as ReviewDifficulty,
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
abstract class _$$WordReviewImplCopyWith<$Res>
    implements $WordReviewCopyWith<$Res> {
  factory _$$WordReviewImplCopyWith(
          _$WordReviewImpl value, $Res Function(_$WordReviewImpl) then) =
      __$$WordReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String word,
      DateTime reviewedAt,
      ReviewDifficulty difficulty,
      Duration timeSpent,
      bool wasSkipped});
}

/// @nodoc
class __$$WordReviewImplCopyWithImpl<$Res>
    extends _$WordReviewCopyWithImpl<$Res, _$WordReviewImpl>
    implements _$$WordReviewImplCopyWith<$Res> {
  __$$WordReviewImplCopyWithImpl(
      _$WordReviewImpl _value, $Res Function(_$WordReviewImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? reviewedAt = null,
    Object? difficulty = null,
    Object? timeSpent = null,
    Object? wasSkipped = null,
  }) {
    return _then(_$WordReviewImpl(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      reviewedAt: null == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as ReviewDifficulty,
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
@JsonSerializable()
class _$WordReviewImpl implements _WordReview {
  const _$WordReviewImpl(
      {required this.word,
      required this.reviewedAt,
      required this.difficulty,
      required this.timeSpent,
      this.wasSkipped = false});

  factory _$WordReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordReviewImplFromJson(json);

  @override
  final String word;
  @override
  final DateTime reviewedAt;
  @override
  final ReviewDifficulty difficulty;
  @override
  final Duration timeSpent;
  @override
  @JsonKey()
  final bool wasSkipped;

  @override
  String toString() {
    return 'WordReview(word: $word, reviewedAt: $reviewedAt, difficulty: $difficulty, timeSpent: $timeSpent, wasSkipped: $wasSkipped)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordReviewImpl &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.timeSpent, timeSpent) ||
                other.timeSpent == timeSpent) &&
            (identical(other.wasSkipped, wasSkipped) ||
                other.wasSkipped == wasSkipped));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, word, reviewedAt, difficulty, timeSpent, wasSkipped);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WordReviewImplCopyWith<_$WordReviewImpl> get copyWith =>
      __$$WordReviewImplCopyWithImpl<_$WordReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WordReviewImplToJson(
      this,
    );
  }
}

abstract class _WordReview implements WordReview {
  const factory _WordReview(
      {required final String word,
      required final DateTime reviewedAt,
      required final ReviewDifficulty difficulty,
      required final Duration timeSpent,
      final bool wasSkipped}) = _$WordReviewImpl;

  factory _WordReview.fromJson(Map<String, dynamic> json) =
      _$WordReviewImpl.fromJson;

  @override
  String get word;
  @override
  DateTime get reviewedAt;
  @override
  ReviewDifficulty get difficulty;
  @override
  Duration get timeSpent;
  @override
  bool get wasSkipped;
  @override
  @JsonKey(ignore: true)
  _$$WordReviewImplCopyWith<_$WordReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionSummary _$SessionSummaryFromJson(Map<String, dynamic> json) {
  return _SessionSummary.fromJson(json);
}

/// @nodoc
mixin _$SessionSummary {
  int get wordsReviewed => throw _privateConstructorUsedError;
  Duration get totalTime => throw _privateConstructorUsedError;
  Duration get timeUsed => throw _privateConstructorUsedError;
  Map<ReviewDifficulty, int> get difficultyBreakdown =>
      throw _privateConstructorUsedError;
  double get wordsPerMinute => throw _privateConstructorUsedError;
  int get streakCount => throw _privateConstructorUsedError;
  List<String> get strugglingWords => throw _privateConstructorUsedError;
  List<String> get masteredWords => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SessionSummaryCopyWith<SessionSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionSummaryCopyWith<$Res> {
  factory $SessionSummaryCopyWith(
          SessionSummary value, $Res Function(SessionSummary) then) =
      _$SessionSummaryCopyWithImpl<$Res, SessionSummary>;
  @useResult
  $Res call(
      {int wordsReviewed,
      Duration totalTime,
      Duration timeUsed,
      Map<ReviewDifficulty, int> difficultyBreakdown,
      double wordsPerMinute,
      int streakCount,
      List<String> strugglingWords,
      List<String> masteredWords});
}

/// @nodoc
class _$SessionSummaryCopyWithImpl<$Res, $Val extends SessionSummary>
    implements $SessionSummaryCopyWith<$Res> {
  _$SessionSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordsReviewed = null,
    Object? totalTime = null,
    Object? timeUsed = null,
    Object? difficultyBreakdown = null,
    Object? wordsPerMinute = null,
    Object? streakCount = null,
    Object? strugglingWords = null,
    Object? masteredWords = null,
  }) {
    return _then(_value.copyWith(
      wordsReviewed: null == wordsReviewed
          ? _value.wordsReviewed
          : wordsReviewed // ignore: cast_nullable_to_non_nullable
              as int,
      totalTime: null == totalTime
          ? _value.totalTime
          : totalTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      timeUsed: null == timeUsed
          ? _value.timeUsed
          : timeUsed // ignore: cast_nullable_to_non_nullable
              as Duration,
      difficultyBreakdown: null == difficultyBreakdown
          ? _value.difficultyBreakdown
          : difficultyBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<ReviewDifficulty, int>,
      wordsPerMinute: null == wordsPerMinute
          ? _value.wordsPerMinute
          : wordsPerMinute // ignore: cast_nullable_to_non_nullable
              as double,
      streakCount: null == streakCount
          ? _value.streakCount
          : streakCount // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SessionSummaryImplCopyWith<$Res>
    implements $SessionSummaryCopyWith<$Res> {
  factory _$$SessionSummaryImplCopyWith(_$SessionSummaryImpl value,
          $Res Function(_$SessionSummaryImpl) then) =
      __$$SessionSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int wordsReviewed,
      Duration totalTime,
      Duration timeUsed,
      Map<ReviewDifficulty, int> difficultyBreakdown,
      double wordsPerMinute,
      int streakCount,
      List<String> strugglingWords,
      List<String> masteredWords});
}

/// @nodoc
class __$$SessionSummaryImplCopyWithImpl<$Res>
    extends _$SessionSummaryCopyWithImpl<$Res, _$SessionSummaryImpl>
    implements _$$SessionSummaryImplCopyWith<$Res> {
  __$$SessionSummaryImplCopyWithImpl(
      _$SessionSummaryImpl _value, $Res Function(_$SessionSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordsReviewed = null,
    Object? totalTime = null,
    Object? timeUsed = null,
    Object? difficultyBreakdown = null,
    Object? wordsPerMinute = null,
    Object? streakCount = null,
    Object? strugglingWords = null,
    Object? masteredWords = null,
  }) {
    return _then(_$SessionSummaryImpl(
      wordsReviewed: null == wordsReviewed
          ? _value.wordsReviewed
          : wordsReviewed // ignore: cast_nullable_to_non_nullable
              as int,
      totalTime: null == totalTime
          ? _value.totalTime
          : totalTime // ignore: cast_nullable_to_non_nullable
              as Duration,
      timeUsed: null == timeUsed
          ? _value.timeUsed
          : timeUsed // ignore: cast_nullable_to_non_nullable
              as Duration,
      difficultyBreakdown: null == difficultyBreakdown
          ? _value._difficultyBreakdown
          : difficultyBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<ReviewDifficulty, int>,
      wordsPerMinute: null == wordsPerMinute
          ? _value.wordsPerMinute
          : wordsPerMinute // ignore: cast_nullable_to_non_nullable
              as double,
      streakCount: null == streakCount
          ? _value.streakCount
          : streakCount // ignore: cast_nullable_to_non_nullable
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
@JsonSerializable()
class _$SessionSummaryImpl implements _SessionSummary {
  const _$SessionSummaryImpl(
      {required this.wordsReviewed,
      required this.totalTime,
      required this.timeUsed,
      required final Map<ReviewDifficulty, int> difficultyBreakdown,
      required this.wordsPerMinute,
      required this.streakCount,
      required final List<String> strugglingWords,
      required final List<String> masteredWords})
      : _difficultyBreakdown = difficultyBreakdown,
        _strugglingWords = strugglingWords,
        _masteredWords = masteredWords;

  factory _$SessionSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionSummaryImplFromJson(json);

  @override
  final int wordsReviewed;
  @override
  final Duration totalTime;
  @override
  final Duration timeUsed;
  final Map<ReviewDifficulty, int> _difficultyBreakdown;
  @override
  Map<ReviewDifficulty, int> get difficultyBreakdown {
    if (_difficultyBreakdown is EqualUnmodifiableMapView)
      return _difficultyBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_difficultyBreakdown);
  }

  @override
  final double wordsPerMinute;
  @override
  final int streakCount;
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
    return 'SessionSummary(wordsReviewed: $wordsReviewed, totalTime: $totalTime, timeUsed: $timeUsed, difficultyBreakdown: $difficultyBreakdown, wordsPerMinute: $wordsPerMinute, streakCount: $streakCount, strugglingWords: $strugglingWords, masteredWords: $masteredWords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionSummaryImpl &&
            (identical(other.wordsReviewed, wordsReviewed) ||
                other.wordsReviewed == wordsReviewed) &&
            (identical(other.totalTime, totalTime) ||
                other.totalTime == totalTime) &&
            (identical(other.timeUsed, timeUsed) ||
                other.timeUsed == timeUsed) &&
            const DeepCollectionEquality()
                .equals(other._difficultyBreakdown, _difficultyBreakdown) &&
            (identical(other.wordsPerMinute, wordsPerMinute) ||
                other.wordsPerMinute == wordsPerMinute) &&
            (identical(other.streakCount, streakCount) ||
                other.streakCount == streakCount) &&
            const DeepCollectionEquality()
                .equals(other._strugglingWords, _strugglingWords) &&
            const DeepCollectionEquality()
                .equals(other._masteredWords, _masteredWords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      wordsReviewed,
      totalTime,
      timeUsed,
      const DeepCollectionEquality().hash(_difficultyBreakdown),
      wordsPerMinute,
      streakCount,
      const DeepCollectionEquality().hash(_strugglingWords),
      const DeepCollectionEquality().hash(_masteredWords));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionSummaryImplCopyWith<_$SessionSummaryImpl> get copyWith =>
      __$$SessionSummaryImplCopyWithImpl<_$SessionSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionSummaryImplToJson(
      this,
    );
  }
}

abstract class _SessionSummary implements SessionSummary {
  const factory _SessionSummary(
      {required final int wordsReviewed,
      required final Duration totalTime,
      required final Duration timeUsed,
      required final Map<ReviewDifficulty, int> difficultyBreakdown,
      required final double wordsPerMinute,
      required final int streakCount,
      required final List<String> strugglingWords,
      required final List<String> masteredWords}) = _$SessionSummaryImpl;

  factory _SessionSummary.fromJson(Map<String, dynamic> json) =
      _$SessionSummaryImpl.fromJson;

  @override
  int get wordsReviewed;
  @override
  Duration get totalTime;
  @override
  Duration get timeUsed;
  @override
  Map<ReviewDifficulty, int> get difficultyBreakdown;
  @override
  double get wordsPerMinute;
  @override
  int get streakCount;
  @override
  List<String> get strugglingWords;
  @override
  List<String> get masteredWords;
  @override
  @JsonKey(ignore: true)
  _$$SessionSummaryImplCopyWith<_$SessionSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
