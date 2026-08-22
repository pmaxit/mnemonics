// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_statistics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserStatistics _$UserStatisticsFromJson(Map<String, dynamic> json) {
  return _UserStatistics.fromJson(json);
}

/// @nodoc
mixin _$UserStatistics {
// Overall progress tracking
  int get totalWordsLearned => throw _privateConstructorUsedError;
  int get wordsLearnedToday => throw _privateConstructorUsedError;
  int get wordsLearnedThisWeek => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  double get averageAccuracy => throw _privateConstructorUsedError;
  int get totalStudyTimeMinutes =>
      throw _privateConstructorUsedError; // Difficulty-based breakdown
  Map<WordDifficulty, DifficultyProgress> get difficultyStats =>
      throw _privateConstructorUsedError; // Category-based breakdown
  Map<String, CategoryProgress> get categoryStats =>
      throw _privateConstructorUsedError; // Learning stage progression
  Map<LearningStage, int> get stageBreakdown =>
      throw _privateConstructorUsedError; // Review action tracking
  List<UserReviewAction> get recentActions =>
      throw _privateConstructorUsedError; // Time-based analytics
  List<DailyProgress> get weeklyProgress => throw _privateConstructorUsedError;
  double get learningVelocity =>
      throw _privateConstructorUsedError; // Milestones and achievements
  List<Milestone> get milestones =>
      throw _privateConstructorUsedError; // User profile info
  DateTime? get joinDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserStatisticsCopyWith<UserStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatisticsCopyWith<$Res> {
  factory $UserStatisticsCopyWith(
          UserStatistics value, $Res Function(UserStatistics) then) =
      _$UserStatisticsCopyWithImpl<$Res, UserStatistics>;
  @useResult
  $Res call(
      {int totalWordsLearned,
      int wordsLearnedToday,
      int wordsLearnedThisWeek,
      int currentStreak,
      int longestStreak,
      double averageAccuracy,
      int totalStudyTimeMinutes,
      Map<WordDifficulty, DifficultyProgress> difficultyStats,
      Map<String, CategoryProgress> categoryStats,
      Map<LearningStage, int> stageBreakdown,
      List<UserReviewAction> recentActions,
      List<DailyProgress> weeklyProgress,
      double learningVelocity,
      List<Milestone> milestones,
      DateTime? joinDate});
}

/// @nodoc
class _$UserStatisticsCopyWithImpl<$Res, $Val extends UserStatistics>
    implements $UserStatisticsCopyWith<$Res> {
  _$UserStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWordsLearned = null,
    Object? wordsLearnedToday = null,
    Object? wordsLearnedThisWeek = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? averageAccuracy = null,
    Object? totalStudyTimeMinutes = null,
    Object? difficultyStats = null,
    Object? categoryStats = null,
    Object? stageBreakdown = null,
    Object? recentActions = null,
    Object? weeklyProgress = null,
    Object? learningVelocity = null,
    Object? milestones = null,
    Object? joinDate = freezed,
  }) {
    return _then(_value.copyWith(
      totalWordsLearned: null == totalWordsLearned
          ? _value.totalWordsLearned
          : totalWordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      wordsLearnedToday: null == wordsLearnedToday
          ? _value.wordsLearnedToday
          : wordsLearnedToday // ignore: cast_nullable_to_non_nullable
              as int,
      wordsLearnedThisWeek: null == wordsLearnedThisWeek
          ? _value.wordsLearnedThisWeek
          : wordsLearnedThisWeek // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      totalStudyTimeMinutes: null == totalStudyTimeMinutes
          ? _value.totalStudyTimeMinutes
          : totalStudyTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      difficultyStats: null == difficultyStats
          ? _value.difficultyStats
          : difficultyStats // ignore: cast_nullable_to_non_nullable
              as Map<WordDifficulty, DifficultyProgress>,
      categoryStats: null == categoryStats
          ? _value.categoryStats
          : categoryStats // ignore: cast_nullable_to_non_nullable
              as Map<String, CategoryProgress>,
      stageBreakdown: null == stageBreakdown
          ? _value.stageBreakdown
          : stageBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<LearningStage, int>,
      recentActions: null == recentActions
          ? _value.recentActions
          : recentActions // ignore: cast_nullable_to_non_nullable
              as List<UserReviewAction>,
      weeklyProgress: null == weeklyProgress
          ? _value.weeklyProgress
          : weeklyProgress // ignore: cast_nullable_to_non_nullable
              as List<DailyProgress>,
      learningVelocity: null == learningVelocity
          ? _value.learningVelocity
          : learningVelocity // ignore: cast_nullable_to_non_nullable
              as double,
      milestones: null == milestones
          ? _value.milestones
          : milestones // ignore: cast_nullable_to_non_nullable
              as List<Milestone>,
      joinDate: freezed == joinDate
          ? _value.joinDate
          : joinDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserStatisticsImplCopyWith<$Res>
    implements $UserStatisticsCopyWith<$Res> {
  factory _$$UserStatisticsImplCopyWith(_$UserStatisticsImpl value,
          $Res Function(_$UserStatisticsImpl) then) =
      __$$UserStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalWordsLearned,
      int wordsLearnedToday,
      int wordsLearnedThisWeek,
      int currentStreak,
      int longestStreak,
      double averageAccuracy,
      int totalStudyTimeMinutes,
      Map<WordDifficulty, DifficultyProgress> difficultyStats,
      Map<String, CategoryProgress> categoryStats,
      Map<LearningStage, int> stageBreakdown,
      List<UserReviewAction> recentActions,
      List<DailyProgress> weeklyProgress,
      double learningVelocity,
      List<Milestone> milestones,
      DateTime? joinDate});
}

/// @nodoc
class __$$UserStatisticsImplCopyWithImpl<$Res>
    extends _$UserStatisticsCopyWithImpl<$Res, _$UserStatisticsImpl>
    implements _$$UserStatisticsImplCopyWith<$Res> {
  __$$UserStatisticsImplCopyWithImpl(
      _$UserStatisticsImpl _value, $Res Function(_$UserStatisticsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWordsLearned = null,
    Object? wordsLearnedToday = null,
    Object? wordsLearnedThisWeek = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? averageAccuracy = null,
    Object? totalStudyTimeMinutes = null,
    Object? difficultyStats = null,
    Object? categoryStats = null,
    Object? stageBreakdown = null,
    Object? recentActions = null,
    Object? weeklyProgress = null,
    Object? learningVelocity = null,
    Object? milestones = null,
    Object? joinDate = freezed,
  }) {
    return _then(_$UserStatisticsImpl(
      totalWordsLearned: null == totalWordsLearned
          ? _value.totalWordsLearned
          : totalWordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      wordsLearnedToday: null == wordsLearnedToday
          ? _value.wordsLearnedToday
          : wordsLearnedToday // ignore: cast_nullable_to_non_nullable
              as int,
      wordsLearnedThisWeek: null == wordsLearnedThisWeek
          ? _value.wordsLearnedThisWeek
          : wordsLearnedThisWeek // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      totalStudyTimeMinutes: null == totalStudyTimeMinutes
          ? _value.totalStudyTimeMinutes
          : totalStudyTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      difficultyStats: null == difficultyStats
          ? _value._difficultyStats
          : difficultyStats // ignore: cast_nullable_to_non_nullable
              as Map<WordDifficulty, DifficultyProgress>,
      categoryStats: null == categoryStats
          ? _value._categoryStats
          : categoryStats // ignore: cast_nullable_to_non_nullable
              as Map<String, CategoryProgress>,
      stageBreakdown: null == stageBreakdown
          ? _value._stageBreakdown
          : stageBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<LearningStage, int>,
      recentActions: null == recentActions
          ? _value._recentActions
          : recentActions // ignore: cast_nullable_to_non_nullable
              as List<UserReviewAction>,
      weeklyProgress: null == weeklyProgress
          ? _value._weeklyProgress
          : weeklyProgress // ignore: cast_nullable_to_non_nullable
              as List<DailyProgress>,
      learningVelocity: null == learningVelocity
          ? _value.learningVelocity
          : learningVelocity // ignore: cast_nullable_to_non_nullable
              as double,
      milestones: null == milestones
          ? _value._milestones
          : milestones // ignore: cast_nullable_to_non_nullable
              as List<Milestone>,
      joinDate: freezed == joinDate
          ? _value.joinDate
          : joinDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStatisticsImpl implements _UserStatistics {
  const _$UserStatisticsImpl(
      {required this.totalWordsLearned,
      required this.wordsLearnedToday,
      required this.wordsLearnedThisWeek,
      required this.currentStreak,
      required this.longestStreak,
      required this.averageAccuracy,
      required this.totalStudyTimeMinutes,
      required final Map<WordDifficulty, DifficultyProgress> difficultyStats,
      required final Map<String, CategoryProgress> categoryStats,
      required final Map<LearningStage, int> stageBreakdown,
      required final List<UserReviewAction> recentActions,
      required final List<DailyProgress> weeklyProgress,
      required this.learningVelocity,
      required final List<Milestone> milestones,
      this.joinDate})
      : _difficultyStats = difficultyStats,
        _categoryStats = categoryStats,
        _stageBreakdown = stageBreakdown,
        _recentActions = recentActions,
        _weeklyProgress = weeklyProgress,
        _milestones = milestones;

  factory _$UserStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatisticsImplFromJson(json);

// Overall progress tracking
  @override
  final int totalWordsLearned;
  @override
  final int wordsLearnedToday;
  @override
  final int wordsLearnedThisWeek;
  @override
  final int currentStreak;
  @override
  final int longestStreak;
  @override
  final double averageAccuracy;
  @override
  final int totalStudyTimeMinutes;
// Difficulty-based breakdown
  final Map<WordDifficulty, DifficultyProgress> _difficultyStats;
// Difficulty-based breakdown
  @override
  Map<WordDifficulty, DifficultyProgress> get difficultyStats {
    if (_difficultyStats is EqualUnmodifiableMapView) return _difficultyStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_difficultyStats);
  }

// Category-based breakdown
  final Map<String, CategoryProgress> _categoryStats;
// Category-based breakdown
  @override
  Map<String, CategoryProgress> get categoryStats {
    if (_categoryStats is EqualUnmodifiableMapView) return _categoryStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryStats);
  }

// Learning stage progression
  final Map<LearningStage, int> _stageBreakdown;
// Learning stage progression
  @override
  Map<LearningStage, int> get stageBreakdown {
    if (_stageBreakdown is EqualUnmodifiableMapView) return _stageBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stageBreakdown);
  }

// Review action tracking
  final List<UserReviewAction> _recentActions;
// Review action tracking
  @override
  List<UserReviewAction> get recentActions {
    if (_recentActions is EqualUnmodifiableListView) return _recentActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentActions);
  }

// Time-based analytics
  final List<DailyProgress> _weeklyProgress;
// Time-based analytics
  @override
  List<DailyProgress> get weeklyProgress {
    if (_weeklyProgress is EqualUnmodifiableListView) return _weeklyProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeklyProgress);
  }

  @override
  final double learningVelocity;
// Milestones and achievements
  final List<Milestone> _milestones;
// Milestones and achievements
  @override
  List<Milestone> get milestones {
    if (_milestones is EqualUnmodifiableListView) return _milestones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_milestones);
  }

// User profile info
  @override
  final DateTime? joinDate;

  @override
  String toString() {
    return 'UserStatistics(totalWordsLearned: $totalWordsLearned, wordsLearnedToday: $wordsLearnedToday, wordsLearnedThisWeek: $wordsLearnedThisWeek, currentStreak: $currentStreak, longestStreak: $longestStreak, averageAccuracy: $averageAccuracy, totalStudyTimeMinutes: $totalStudyTimeMinutes, difficultyStats: $difficultyStats, categoryStats: $categoryStats, stageBreakdown: $stageBreakdown, recentActions: $recentActions, weeklyProgress: $weeklyProgress, learningVelocity: $learningVelocity, milestones: $milestones, joinDate: $joinDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatisticsImpl &&
            (identical(other.totalWordsLearned, totalWordsLearned) ||
                other.totalWordsLearned == totalWordsLearned) &&
            (identical(other.wordsLearnedToday, wordsLearnedToday) ||
                other.wordsLearnedToday == wordsLearnedToday) &&
            (identical(other.wordsLearnedThisWeek, wordsLearnedThisWeek) ||
                other.wordsLearnedThisWeek == wordsLearnedThisWeek) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.averageAccuracy, averageAccuracy) ||
                other.averageAccuracy == averageAccuracy) &&
            (identical(other.totalStudyTimeMinutes, totalStudyTimeMinutes) ||
                other.totalStudyTimeMinutes == totalStudyTimeMinutes) &&
            const DeepCollectionEquality()
                .equals(other._difficultyStats, _difficultyStats) &&
            const DeepCollectionEquality()
                .equals(other._categoryStats, _categoryStats) &&
            const DeepCollectionEquality()
                .equals(other._stageBreakdown, _stageBreakdown) &&
            const DeepCollectionEquality()
                .equals(other._recentActions, _recentActions) &&
            const DeepCollectionEquality()
                .equals(other._weeklyProgress, _weeklyProgress) &&
            (identical(other.learningVelocity, learningVelocity) ||
                other.learningVelocity == learningVelocity) &&
            const DeepCollectionEquality()
                .equals(other._milestones, _milestones) &&
            (identical(other.joinDate, joinDate) ||
                other.joinDate == joinDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalWordsLearned,
      wordsLearnedToday,
      wordsLearnedThisWeek,
      currentStreak,
      longestStreak,
      averageAccuracy,
      totalStudyTimeMinutes,
      const DeepCollectionEquality().hash(_difficultyStats),
      const DeepCollectionEquality().hash(_categoryStats),
      const DeepCollectionEquality().hash(_stageBreakdown),
      const DeepCollectionEquality().hash(_recentActions),
      const DeepCollectionEquality().hash(_weeklyProgress),
      learningVelocity,
      const DeepCollectionEquality().hash(_milestones),
      joinDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatisticsImplCopyWith<_$UserStatisticsImpl> get copyWith =>
      __$$UserStatisticsImplCopyWithImpl<_$UserStatisticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatisticsImplToJson(
      this,
    );
  }
}

abstract class _UserStatistics implements UserStatistics {
  const factory _UserStatistics(
      {required final int totalWordsLearned,
      required final int wordsLearnedToday,
      required final int wordsLearnedThisWeek,
      required final int currentStreak,
      required final int longestStreak,
      required final double averageAccuracy,
      required final int totalStudyTimeMinutes,
      required final Map<WordDifficulty, DifficultyProgress> difficultyStats,
      required final Map<String, CategoryProgress> categoryStats,
      required final Map<LearningStage, int> stageBreakdown,
      required final List<UserReviewAction> recentActions,
      required final List<DailyProgress> weeklyProgress,
      required final double learningVelocity,
      required final List<Milestone> milestones,
      final DateTime? joinDate}) = _$UserStatisticsImpl;

  factory _UserStatistics.fromJson(Map<String, dynamic> json) =
      _$UserStatisticsImpl.fromJson;

  @override // Overall progress tracking
  int get totalWordsLearned;
  @override
  int get wordsLearnedToday;
  @override
  int get wordsLearnedThisWeek;
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  double get averageAccuracy;
  @override
  int get totalStudyTimeMinutes;
  @override // Difficulty-based breakdown
  Map<WordDifficulty, DifficultyProgress> get difficultyStats;
  @override // Category-based breakdown
  Map<String, CategoryProgress> get categoryStats;
  @override // Learning stage progression
  Map<LearningStage, int> get stageBreakdown;
  @override // Review action tracking
  List<UserReviewAction> get recentActions;
  @override // Time-based analytics
  List<DailyProgress> get weeklyProgress;
  @override
  double get learningVelocity;
  @override // Milestones and achievements
  List<Milestone> get milestones;
  @override // User profile info
  DateTime? get joinDate;
  @override
  @JsonKey(ignore: true)
  _$$UserStatisticsImplCopyWith<_$UserStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DifficultyProgress _$DifficultyProgressFromJson(Map<String, dynamic> json) {
  return _DifficultyProgress.fromJson(json);
}

/// @nodoc
mixin _$DifficultyProgress {
  WordDifficulty get difficulty => throw _privateConstructorUsedError;
  int get totalWords => throw _privateConstructorUsedError;
  int get wordsLearned => throw _privateConstructorUsedError;
  int get wordsInProgress => throw _privateConstructorUsedError;
  double get averageAccuracy => throw _privateConstructorUsedError;
  int get totalReviews => throw _privateConstructorUsedError;
  DateTime? get lastReviewedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DifficultyProgressCopyWith<DifficultyProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DifficultyProgressCopyWith<$Res> {
  factory $DifficultyProgressCopyWith(
          DifficultyProgress value, $Res Function(DifficultyProgress) then) =
      _$DifficultyProgressCopyWithImpl<$Res, DifficultyProgress>;
  @useResult
  $Res call(
      {WordDifficulty difficulty,
      int totalWords,
      int wordsLearned,
      int wordsInProgress,
      double averageAccuracy,
      int totalReviews,
      DateTime? lastReviewedAt});
}

/// @nodoc
class _$DifficultyProgressCopyWithImpl<$Res, $Val extends DifficultyProgress>
    implements $DifficultyProgressCopyWith<$Res> {
  _$DifficultyProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? difficulty = null,
    Object? totalWords = null,
    Object? wordsLearned = null,
    Object? wordsInProgress = null,
    Object? averageAccuracy = null,
    Object? totalReviews = null,
    Object? lastReviewedAt = freezed,
  }) {
    return _then(_value.copyWith(
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as WordDifficulty,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      wordsLearned: null == wordsLearned
          ? _value.wordsLearned
          : wordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      wordsInProgress: null == wordsInProgress
          ? _value.wordsInProgress
          : wordsInProgress // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DifficultyProgressImplCopyWith<$Res>
    implements $DifficultyProgressCopyWith<$Res> {
  factory _$$DifficultyProgressImplCopyWith(_$DifficultyProgressImpl value,
          $Res Function(_$DifficultyProgressImpl) then) =
      __$$DifficultyProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {WordDifficulty difficulty,
      int totalWords,
      int wordsLearned,
      int wordsInProgress,
      double averageAccuracy,
      int totalReviews,
      DateTime? lastReviewedAt});
}

/// @nodoc
class __$$DifficultyProgressImplCopyWithImpl<$Res>
    extends _$DifficultyProgressCopyWithImpl<$Res, _$DifficultyProgressImpl>
    implements _$$DifficultyProgressImplCopyWith<$Res> {
  __$$DifficultyProgressImplCopyWithImpl(_$DifficultyProgressImpl _value,
      $Res Function(_$DifficultyProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? difficulty = null,
    Object? totalWords = null,
    Object? wordsLearned = null,
    Object? wordsInProgress = null,
    Object? averageAccuracy = null,
    Object? totalReviews = null,
    Object? lastReviewedAt = freezed,
  }) {
    return _then(_$DifficultyProgressImpl(
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as WordDifficulty,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      wordsLearned: null == wordsLearned
          ? _value.wordsLearned
          : wordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      wordsInProgress: null == wordsInProgress
          ? _value.wordsInProgress
          : wordsInProgress // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DifficultyProgressImpl implements _DifficultyProgress {
  const _$DifficultyProgressImpl(
      {required this.difficulty,
      required this.totalWords,
      required this.wordsLearned,
      required this.wordsInProgress,
      required this.averageAccuracy,
      required this.totalReviews,
      required this.lastReviewedAt});

  factory _$DifficultyProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$DifficultyProgressImplFromJson(json);

  @override
  final WordDifficulty difficulty;
  @override
  final int totalWords;
  @override
  final int wordsLearned;
  @override
  final int wordsInProgress;
  @override
  final double averageAccuracy;
  @override
  final int totalReviews;
  @override
  final DateTime? lastReviewedAt;

  @override
  String toString() {
    return 'DifficultyProgress(difficulty: $difficulty, totalWords: $totalWords, wordsLearned: $wordsLearned, wordsInProgress: $wordsInProgress, averageAccuracy: $averageAccuracy, totalReviews: $totalReviews, lastReviewedAt: $lastReviewedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DifficultyProgressImpl &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.wordsLearned, wordsLearned) ||
                other.wordsLearned == wordsLearned) &&
            (identical(other.wordsInProgress, wordsInProgress) ||
                other.wordsInProgress == wordsInProgress) &&
            (identical(other.averageAccuracy, averageAccuracy) ||
                other.averageAccuracy == averageAccuracy) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.lastReviewedAt, lastReviewedAt) ||
                other.lastReviewedAt == lastReviewedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      difficulty,
      totalWords,
      wordsLearned,
      wordsInProgress,
      averageAccuracy,
      totalReviews,
      lastReviewedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DifficultyProgressImplCopyWith<_$DifficultyProgressImpl> get copyWith =>
      __$$DifficultyProgressImplCopyWithImpl<_$DifficultyProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DifficultyProgressImplToJson(
      this,
    );
  }
}

abstract class _DifficultyProgress implements DifficultyProgress {
  const factory _DifficultyProgress(
      {required final WordDifficulty difficulty,
      required final int totalWords,
      required final int wordsLearned,
      required final int wordsInProgress,
      required final double averageAccuracy,
      required final int totalReviews,
      required final DateTime? lastReviewedAt}) = _$DifficultyProgressImpl;

  factory _DifficultyProgress.fromJson(Map<String, dynamic> json) =
      _$DifficultyProgressImpl.fromJson;

  @override
  WordDifficulty get difficulty;
  @override
  int get totalWords;
  @override
  int get wordsLearned;
  @override
  int get wordsInProgress;
  @override
  double get averageAccuracy;
  @override
  int get totalReviews;
  @override
  DateTime? get lastReviewedAt;
  @override
  @JsonKey(ignore: true)
  _$$DifficultyProgressImplCopyWith<_$DifficultyProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategoryProgress _$CategoryProgressFromJson(Map<String, dynamic> json) {
  return _CategoryProgress.fromJson(json);
}

/// @nodoc
mixin _$CategoryProgress {
  String get categoryName => throw _privateConstructorUsedError;
  int get totalWords => throw _privateConstructorUsedError;
  int get wordsLearned => throw _privateConstructorUsedError;
  int get wordsInProgress => throw _privateConstructorUsedError;
  double get averageAccuracy => throw _privateConstructorUsedError;
  Map<WordDifficulty, int> get difficultyBreakdown =>
      throw _privateConstructorUsedError;
  DateTime? get lastReviewedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CategoryProgressCopyWith<CategoryProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryProgressCopyWith<$Res> {
  factory $CategoryProgressCopyWith(
          CategoryProgress value, $Res Function(CategoryProgress) then) =
      _$CategoryProgressCopyWithImpl<$Res, CategoryProgress>;
  @useResult
  $Res call(
      {String categoryName,
      int totalWords,
      int wordsLearned,
      int wordsInProgress,
      double averageAccuracy,
      Map<WordDifficulty, int> difficultyBreakdown,
      DateTime? lastReviewedAt});
}

/// @nodoc
class _$CategoryProgressCopyWithImpl<$Res, $Val extends CategoryProgress>
    implements $CategoryProgressCopyWith<$Res> {
  _$CategoryProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryName = null,
    Object? totalWords = null,
    Object? wordsLearned = null,
    Object? wordsInProgress = null,
    Object? averageAccuracy = null,
    Object? difficultyBreakdown = null,
    Object? lastReviewedAt = freezed,
  }) {
    return _then(_value.copyWith(
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      wordsLearned: null == wordsLearned
          ? _value.wordsLearned
          : wordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      wordsInProgress: null == wordsInProgress
          ? _value.wordsInProgress
          : wordsInProgress // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      difficultyBreakdown: null == difficultyBreakdown
          ? _value.difficultyBreakdown
          : difficultyBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<WordDifficulty, int>,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryProgressImplCopyWith<$Res>
    implements $CategoryProgressCopyWith<$Res> {
  factory _$$CategoryProgressImplCopyWith(_$CategoryProgressImpl value,
          $Res Function(_$CategoryProgressImpl) then) =
      __$$CategoryProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String categoryName,
      int totalWords,
      int wordsLearned,
      int wordsInProgress,
      double averageAccuracy,
      Map<WordDifficulty, int> difficultyBreakdown,
      DateTime? lastReviewedAt});
}

/// @nodoc
class __$$CategoryProgressImplCopyWithImpl<$Res>
    extends _$CategoryProgressCopyWithImpl<$Res, _$CategoryProgressImpl>
    implements _$$CategoryProgressImplCopyWith<$Res> {
  __$$CategoryProgressImplCopyWithImpl(_$CategoryProgressImpl _value,
      $Res Function(_$CategoryProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryName = null,
    Object? totalWords = null,
    Object? wordsLearned = null,
    Object? wordsInProgress = null,
    Object? averageAccuracy = null,
    Object? difficultyBreakdown = null,
    Object? lastReviewedAt = freezed,
  }) {
    return _then(_$CategoryProgressImpl(
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      wordsLearned: null == wordsLearned
          ? _value.wordsLearned
          : wordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      wordsInProgress: null == wordsInProgress
          ? _value.wordsInProgress
          : wordsInProgress // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      difficultyBreakdown: null == difficultyBreakdown
          ? _value._difficultyBreakdown
          : difficultyBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<WordDifficulty, int>,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryProgressImpl implements _CategoryProgress {
  const _$CategoryProgressImpl(
      {required this.categoryName,
      required this.totalWords,
      required this.wordsLearned,
      required this.wordsInProgress,
      required this.averageAccuracy,
      required final Map<WordDifficulty, int> difficultyBreakdown,
      required this.lastReviewedAt})
      : _difficultyBreakdown = difficultyBreakdown;

  factory _$CategoryProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryProgressImplFromJson(json);

  @override
  final String categoryName;
  @override
  final int totalWords;
  @override
  final int wordsLearned;
  @override
  final int wordsInProgress;
  @override
  final double averageAccuracy;
  final Map<WordDifficulty, int> _difficultyBreakdown;
  @override
  Map<WordDifficulty, int> get difficultyBreakdown {
    if (_difficultyBreakdown is EqualUnmodifiableMapView)
      return _difficultyBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_difficultyBreakdown);
  }

  @override
  final DateTime? lastReviewedAt;

  @override
  String toString() {
    return 'CategoryProgress(categoryName: $categoryName, totalWords: $totalWords, wordsLearned: $wordsLearned, wordsInProgress: $wordsInProgress, averageAccuracy: $averageAccuracy, difficultyBreakdown: $difficultyBreakdown, lastReviewedAt: $lastReviewedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryProgressImpl &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.wordsLearned, wordsLearned) ||
                other.wordsLearned == wordsLearned) &&
            (identical(other.wordsInProgress, wordsInProgress) ||
                other.wordsInProgress == wordsInProgress) &&
            (identical(other.averageAccuracy, averageAccuracy) ||
                other.averageAccuracy == averageAccuracy) &&
            const DeepCollectionEquality()
                .equals(other._difficultyBreakdown, _difficultyBreakdown) &&
            (identical(other.lastReviewedAt, lastReviewedAt) ||
                other.lastReviewedAt == lastReviewedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      categoryName,
      totalWords,
      wordsLearned,
      wordsInProgress,
      averageAccuracy,
      const DeepCollectionEquality().hash(_difficultyBreakdown),
      lastReviewedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryProgressImplCopyWith<_$CategoryProgressImpl> get copyWith =>
      __$$CategoryProgressImplCopyWithImpl<_$CategoryProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryProgressImplToJson(
      this,
    );
  }
}

abstract class _CategoryProgress implements CategoryProgress {
  const factory _CategoryProgress(
      {required final String categoryName,
      required final int totalWords,
      required final int wordsLearned,
      required final int wordsInProgress,
      required final double averageAccuracy,
      required final Map<WordDifficulty, int> difficultyBreakdown,
      required final DateTime? lastReviewedAt}) = _$CategoryProgressImpl;

  factory _CategoryProgress.fromJson(Map<String, dynamic> json) =
      _$CategoryProgressImpl.fromJson;

  @override
  String get categoryName;
  @override
  int get totalWords;
  @override
  int get wordsLearned;
  @override
  int get wordsInProgress;
  @override
  double get averageAccuracy;
  @override
  Map<WordDifficulty, int> get difficultyBreakdown;
  @override
  DateTime? get lastReviewedAt;
  @override
  @JsonKey(ignore: true)
  _$$CategoryProgressImplCopyWith<_$CategoryProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserReviewAction _$UserReviewActionFromJson(Map<String, dynamic> json) {
  return _UserReviewAction.fromJson(json);
}

/// @nodoc
mixin _$UserReviewAction {
  String get word => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  WordDifficulty get wordDifficulty => throw _privateConstructorUsedError;
  ReviewActionType get actionType => throw _privateConstructorUsedError;
  ReviewDifficultyRating get userRating => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  Duration get timeSpent => throw _privateConstructorUsedError;
  bool get wasCorrect => throw _privateConstructorUsedError;
  LearningStage get previousStage => throw _privateConstructorUsedError;
  LearningStage get newStage => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserReviewActionCopyWith<UserReviewAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserReviewActionCopyWith<$Res> {
  factory $UserReviewActionCopyWith(
          UserReviewAction value, $Res Function(UserReviewAction) then) =
      _$UserReviewActionCopyWithImpl<$Res, UserReviewAction>;
  @useResult
  $Res call(
      {String word,
      String category,
      WordDifficulty wordDifficulty,
      ReviewActionType actionType,
      ReviewDifficultyRating userRating,
      DateTime timestamp,
      Duration timeSpent,
      bool wasCorrect,
      LearningStage previousStage,
      LearningStage newStage,
      String? notes});
}

/// @nodoc
class _$UserReviewActionCopyWithImpl<$Res, $Val extends UserReviewAction>
    implements $UserReviewActionCopyWith<$Res> {
  _$UserReviewActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? category = null,
    Object? wordDifficulty = null,
    Object? actionType = null,
    Object? userRating = null,
    Object? timestamp = null,
    Object? timeSpent = null,
    Object? wasCorrect = null,
    Object? previousStage = null,
    Object? newStage = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      wordDifficulty: null == wordDifficulty
          ? _value.wordDifficulty
          : wordDifficulty // ignore: cast_nullable_to_non_nullable
              as WordDifficulty,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as ReviewActionType,
      userRating: null == userRating
          ? _value.userRating
          : userRating // ignore: cast_nullable_to_non_nullable
              as ReviewDifficultyRating,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      timeSpent: null == timeSpent
          ? _value.timeSpent
          : timeSpent // ignore: cast_nullable_to_non_nullable
              as Duration,
      wasCorrect: null == wasCorrect
          ? _value.wasCorrect
          : wasCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      previousStage: null == previousStage
          ? _value.previousStage
          : previousStage // ignore: cast_nullable_to_non_nullable
              as LearningStage,
      newStage: null == newStage
          ? _value.newStage
          : newStage // ignore: cast_nullable_to_non_nullable
              as LearningStage,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserReviewActionImplCopyWith<$Res>
    implements $UserReviewActionCopyWith<$Res> {
  factory _$$UserReviewActionImplCopyWith(_$UserReviewActionImpl value,
          $Res Function(_$UserReviewActionImpl) then) =
      __$$UserReviewActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String word,
      String category,
      WordDifficulty wordDifficulty,
      ReviewActionType actionType,
      ReviewDifficultyRating userRating,
      DateTime timestamp,
      Duration timeSpent,
      bool wasCorrect,
      LearningStage previousStage,
      LearningStage newStage,
      String? notes});
}

/// @nodoc
class __$$UserReviewActionImplCopyWithImpl<$Res>
    extends _$UserReviewActionCopyWithImpl<$Res, _$UserReviewActionImpl>
    implements _$$UserReviewActionImplCopyWith<$Res> {
  __$$UserReviewActionImplCopyWithImpl(_$UserReviewActionImpl _value,
      $Res Function(_$UserReviewActionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? category = null,
    Object? wordDifficulty = null,
    Object? actionType = null,
    Object? userRating = null,
    Object? timestamp = null,
    Object? timeSpent = null,
    Object? wasCorrect = null,
    Object? previousStage = null,
    Object? newStage = null,
    Object? notes = freezed,
  }) {
    return _then(_$UserReviewActionImpl(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      wordDifficulty: null == wordDifficulty
          ? _value.wordDifficulty
          : wordDifficulty // ignore: cast_nullable_to_non_nullable
              as WordDifficulty,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as ReviewActionType,
      userRating: null == userRating
          ? _value.userRating
          : userRating // ignore: cast_nullable_to_non_nullable
              as ReviewDifficultyRating,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      timeSpent: null == timeSpent
          ? _value.timeSpent
          : timeSpent // ignore: cast_nullable_to_non_nullable
              as Duration,
      wasCorrect: null == wasCorrect
          ? _value.wasCorrect
          : wasCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      previousStage: null == previousStage
          ? _value.previousStage
          : previousStage // ignore: cast_nullable_to_non_nullable
              as LearningStage,
      newStage: null == newStage
          ? _value.newStage
          : newStage // ignore: cast_nullable_to_non_nullable
              as LearningStage,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserReviewActionImpl implements _UserReviewAction {
  const _$UserReviewActionImpl(
      {required this.word,
      required this.category,
      required this.wordDifficulty,
      required this.actionType,
      required this.userRating,
      required this.timestamp,
      required this.timeSpent,
      required this.wasCorrect,
      required this.previousStage,
      required this.newStage,
      this.notes});

  factory _$UserReviewActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserReviewActionImplFromJson(json);

  @override
  final String word;
  @override
  final String category;
  @override
  final WordDifficulty wordDifficulty;
  @override
  final ReviewActionType actionType;
  @override
  final ReviewDifficultyRating userRating;
  @override
  final DateTime timestamp;
  @override
  final Duration timeSpent;
  @override
  final bool wasCorrect;
  @override
  final LearningStage previousStage;
  @override
  final LearningStage newStage;
  @override
  final String? notes;

  @override
  String toString() {
    return 'UserReviewAction(word: $word, category: $category, wordDifficulty: $wordDifficulty, actionType: $actionType, userRating: $userRating, timestamp: $timestamp, timeSpent: $timeSpent, wasCorrect: $wasCorrect, previousStage: $previousStage, newStage: $newStage, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserReviewActionImpl &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.wordDifficulty, wordDifficulty) ||
                other.wordDifficulty == wordDifficulty) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.userRating, userRating) ||
                other.userRating == userRating) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.timeSpent, timeSpent) ||
                other.timeSpent == timeSpent) &&
            (identical(other.wasCorrect, wasCorrect) ||
                other.wasCorrect == wasCorrect) &&
            (identical(other.previousStage, previousStage) ||
                other.previousStage == previousStage) &&
            (identical(other.newStage, newStage) ||
                other.newStage == newStage) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      word,
      category,
      wordDifficulty,
      actionType,
      userRating,
      timestamp,
      timeSpent,
      wasCorrect,
      previousStage,
      newStage,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserReviewActionImplCopyWith<_$UserReviewActionImpl> get copyWith =>
      __$$UserReviewActionImplCopyWithImpl<_$UserReviewActionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserReviewActionImplToJson(
      this,
    );
  }
}

abstract class _UserReviewAction implements UserReviewAction {
  const factory _UserReviewAction(
      {required final String word,
      required final String category,
      required final WordDifficulty wordDifficulty,
      required final ReviewActionType actionType,
      required final ReviewDifficultyRating userRating,
      required final DateTime timestamp,
      required final Duration timeSpent,
      required final bool wasCorrect,
      required final LearningStage previousStage,
      required final LearningStage newStage,
      final String? notes}) = _$UserReviewActionImpl;

  factory _UserReviewAction.fromJson(Map<String, dynamic> json) =
      _$UserReviewActionImpl.fromJson;

  @override
  String get word;
  @override
  String get category;
  @override
  WordDifficulty get wordDifficulty;
  @override
  ReviewActionType get actionType;
  @override
  ReviewDifficultyRating get userRating;
  @override
  DateTime get timestamp;
  @override
  Duration get timeSpent;
  @override
  bool get wasCorrect;
  @override
  LearningStage get previousStage;
  @override
  LearningStage get newStage;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$UserReviewActionImplCopyWith<_$UserReviewActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyProgress _$DailyProgressFromJson(Map<String, dynamic> json) {
  return _DailyProgress.fromJson(json);
}

/// @nodoc
mixin _$DailyProgress {
  DateTime get date => throw _privateConstructorUsedError;
  int get wordsLearned => throw _privateConstructorUsedError;
  int get reviewsCompleted => throw _privateConstructorUsedError;
  int get studyTimeMinutes => throw _privateConstructorUsedError;
  Map<WordDifficulty, int> get difficultyBreakdown =>
      throw _privateConstructorUsedError;
  double get accuracyRate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailyProgressCopyWith<DailyProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyProgressCopyWith<$Res> {
  factory $DailyProgressCopyWith(
          DailyProgress value, $Res Function(DailyProgress) then) =
      _$DailyProgressCopyWithImpl<$Res, DailyProgress>;
  @useResult
  $Res call(
      {DateTime date,
      int wordsLearned,
      int reviewsCompleted,
      int studyTimeMinutes,
      Map<WordDifficulty, int> difficultyBreakdown,
      double accuracyRate});
}

/// @nodoc
class _$DailyProgressCopyWithImpl<$Res, $Val extends DailyProgress>
    implements $DailyProgressCopyWith<$Res> {
  _$DailyProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? wordsLearned = null,
    Object? reviewsCompleted = null,
    Object? studyTimeMinutes = null,
    Object? difficultyBreakdown = null,
    Object? accuracyRate = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      wordsLearned: null == wordsLearned
          ? _value.wordsLearned
          : wordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      reviewsCompleted: null == reviewsCompleted
          ? _value.reviewsCompleted
          : reviewsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      studyTimeMinutes: null == studyTimeMinutes
          ? _value.studyTimeMinutes
          : studyTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      difficultyBreakdown: null == difficultyBreakdown
          ? _value.difficultyBreakdown
          : difficultyBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<WordDifficulty, int>,
      accuracyRate: null == accuracyRate
          ? _value.accuracyRate
          : accuracyRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyProgressImplCopyWith<$Res>
    implements $DailyProgressCopyWith<$Res> {
  factory _$$DailyProgressImplCopyWith(
          _$DailyProgressImpl value, $Res Function(_$DailyProgressImpl) then) =
      __$$DailyProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      int wordsLearned,
      int reviewsCompleted,
      int studyTimeMinutes,
      Map<WordDifficulty, int> difficultyBreakdown,
      double accuracyRate});
}

/// @nodoc
class __$$DailyProgressImplCopyWithImpl<$Res>
    extends _$DailyProgressCopyWithImpl<$Res, _$DailyProgressImpl>
    implements _$$DailyProgressImplCopyWith<$Res> {
  __$$DailyProgressImplCopyWithImpl(
      _$DailyProgressImpl _value, $Res Function(_$DailyProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? wordsLearned = null,
    Object? reviewsCompleted = null,
    Object? studyTimeMinutes = null,
    Object? difficultyBreakdown = null,
    Object? accuracyRate = null,
  }) {
    return _then(_$DailyProgressImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      wordsLearned: null == wordsLearned
          ? _value.wordsLearned
          : wordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      reviewsCompleted: null == reviewsCompleted
          ? _value.reviewsCompleted
          : reviewsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      studyTimeMinutes: null == studyTimeMinutes
          ? _value.studyTimeMinutes
          : studyTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      difficultyBreakdown: null == difficultyBreakdown
          ? _value._difficultyBreakdown
          : difficultyBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<WordDifficulty, int>,
      accuracyRate: null == accuracyRate
          ? _value.accuracyRate
          : accuracyRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyProgressImpl implements _DailyProgress {
  const _$DailyProgressImpl(
      {required this.date,
      required this.wordsLearned,
      required this.reviewsCompleted,
      required this.studyTimeMinutes,
      required final Map<WordDifficulty, int> difficultyBreakdown,
      required this.accuracyRate})
      : _difficultyBreakdown = difficultyBreakdown;

  factory _$DailyProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyProgressImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int wordsLearned;
  @override
  final int reviewsCompleted;
  @override
  final int studyTimeMinutes;
  final Map<WordDifficulty, int> _difficultyBreakdown;
  @override
  Map<WordDifficulty, int> get difficultyBreakdown {
    if (_difficultyBreakdown is EqualUnmodifiableMapView)
      return _difficultyBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_difficultyBreakdown);
  }

  @override
  final double accuracyRate;

  @override
  String toString() {
    return 'DailyProgress(date: $date, wordsLearned: $wordsLearned, reviewsCompleted: $reviewsCompleted, studyTimeMinutes: $studyTimeMinutes, difficultyBreakdown: $difficultyBreakdown, accuracyRate: $accuracyRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyProgressImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.wordsLearned, wordsLearned) ||
                other.wordsLearned == wordsLearned) &&
            (identical(other.reviewsCompleted, reviewsCompleted) ||
                other.reviewsCompleted == reviewsCompleted) &&
            (identical(other.studyTimeMinutes, studyTimeMinutes) ||
                other.studyTimeMinutes == studyTimeMinutes) &&
            const DeepCollectionEquality()
                .equals(other._difficultyBreakdown, _difficultyBreakdown) &&
            (identical(other.accuracyRate, accuracyRate) ||
                other.accuracyRate == accuracyRate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      wordsLearned,
      reviewsCompleted,
      studyTimeMinutes,
      const DeepCollectionEquality().hash(_difficultyBreakdown),
      accuracyRate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyProgressImplCopyWith<_$DailyProgressImpl> get copyWith =>
      __$$DailyProgressImplCopyWithImpl<_$DailyProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyProgressImplToJson(
      this,
    );
  }
}

abstract class _DailyProgress implements DailyProgress {
  const factory _DailyProgress(
      {required final DateTime date,
      required final int wordsLearned,
      required final int reviewsCompleted,
      required final int studyTimeMinutes,
      required final Map<WordDifficulty, int> difficultyBreakdown,
      required final double accuracyRate}) = _$DailyProgressImpl;

  factory _DailyProgress.fromJson(Map<String, dynamic> json) =
      _$DailyProgressImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get wordsLearned;
  @override
  int get reviewsCompleted;
  @override
  int get studyTimeMinutes;
  @override
  Map<WordDifficulty, int> get difficultyBreakdown;
  @override
  double get accuracyRate;
  @override
  @JsonKey(ignore: true)
  _$$DailyProgressImplCopyWith<_$DailyProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Milestone _$MilestoneFromJson(Map<String, dynamic> json) {
  return _Milestone.fromJson(json);
}

/// @nodoc
mixin _$Milestone {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  MilestoneType get type => throw _privateConstructorUsedError;
  int get targetValue => throw _privateConstructorUsedError;
  int get currentValue => throw _privateConstructorUsedError;
  bool get isUnlocked => throw _privateConstructorUsedError;
  DateTime? get unlockedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MilestoneCopyWith<Milestone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilestoneCopyWith<$Res> {
  factory $MilestoneCopyWith(Milestone value, $Res Function(Milestone) then) =
      _$MilestoneCopyWithImpl<$Res, Milestone>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      MilestoneType type,
      int targetValue,
      int currentValue,
      bool isUnlocked,
      DateTime? unlockedAt});
}

/// @nodoc
class _$MilestoneCopyWithImpl<$Res, $Val extends Milestone>
    implements $MilestoneCopyWith<$Res> {
  _$MilestoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? targetValue = null,
    Object? currentValue = null,
    Object? isUnlocked = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MilestoneType,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as int,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as int,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MilestoneImplCopyWith<$Res>
    implements $MilestoneCopyWith<$Res> {
  factory _$$MilestoneImplCopyWith(
          _$MilestoneImpl value, $Res Function(_$MilestoneImpl) then) =
      __$$MilestoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      MilestoneType type,
      int targetValue,
      int currentValue,
      bool isUnlocked,
      DateTime? unlockedAt});
}

/// @nodoc
class __$$MilestoneImplCopyWithImpl<$Res>
    extends _$MilestoneCopyWithImpl<$Res, _$MilestoneImpl>
    implements _$$MilestoneImplCopyWith<$Res> {
  __$$MilestoneImplCopyWithImpl(
      _$MilestoneImpl _value, $Res Function(_$MilestoneImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? targetValue = null,
    Object? currentValue = null,
    Object? isUnlocked = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(_$MilestoneImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MilestoneType,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as int,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as int,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MilestoneImpl implements _Milestone {
  const _$MilestoneImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.targetValue,
      required this.currentValue,
      required this.isUnlocked,
      this.unlockedAt});

  factory _$MilestoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$MilestoneImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final MilestoneType type;
  @override
  final int targetValue;
  @override
  final int currentValue;
  @override
  final bool isUnlocked;
  @override
  final DateTime? unlockedAt;

  @override
  String toString() {
    return 'Milestone(id: $id, title: $title, description: $description, type: $type, targetValue: $targetValue, currentValue: $currentValue, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilestoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, type,
      targetValue, currentValue, isUnlocked, unlockedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      __$$MilestoneImplCopyWithImpl<_$MilestoneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MilestoneImplToJson(
      this,
    );
  }
}

abstract class _Milestone implements Milestone {
  const factory _Milestone(
      {required final String id,
      required final String title,
      required final String description,
      required final MilestoneType type,
      required final int targetValue,
      required final int currentValue,
      required final bool isUnlocked,
      final DateTime? unlockedAt}) = _$MilestoneImpl;

  factory _Milestone.fromJson(Map<String, dynamic> json) =
      _$MilestoneImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  MilestoneType get type;
  @override
  int get targetValue;
  @override
  int get currentValue;
  @override
  bool get isUnlocked;
  @override
  DateTime? get unlockedAt;
  @override
  @JsonKey(ignore: true)
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
