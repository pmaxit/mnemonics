// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_statistics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProfileStatistics _$ProfileStatisticsFromJson(Map<String, dynamic> json) {
  return _ProfileStatistics.fromJson(json);
}

/// @nodoc
mixin _$ProfileStatistics {
  int get totalWordsLearned => throw _privateConstructorUsedError;
  int get wordsLearnedToday => throw _privateConstructorUsedError;
  int get wordsLearnedThisWeek => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int get totalStudyTimeMinutes => throw _privateConstructorUsedError;
  double get averageAccuracy => throw _privateConstructorUsedError;
  int get studySessionsThisWeek => throw _privateConstructorUsedError;
  double get learningVelocity => throw _privateConstructorUsedError;
  List<CategoryStats> get categoryStats => throw _privateConstructorUsedError;
  List<DifficultyStats> get difficultyStats =>
      throw _privateConstructorUsedError;
  List<Milestone> get milestones => throw _privateConstructorUsedError;
  DateTime? get joinDate => throw _privateConstructorUsedError;

  /// Serializes this ProfileStatistics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileStatisticsCopyWith<ProfileStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStatisticsCopyWith<$Res> {
  factory $ProfileStatisticsCopyWith(
          ProfileStatistics value, $Res Function(ProfileStatistics) then) =
      _$ProfileStatisticsCopyWithImpl<$Res, ProfileStatistics>;
  @useResult
  $Res call(
      {int totalWordsLearned,
      int wordsLearnedToday,
      int wordsLearnedThisWeek,
      int currentStreak,
      int longestStreak,
      int totalStudyTimeMinutes,
      double averageAccuracy,
      int studySessionsThisWeek,
      double learningVelocity,
      List<CategoryStats> categoryStats,
      List<DifficultyStats> difficultyStats,
      List<Milestone> milestones,
      DateTime? joinDate});
}

/// @nodoc
class _$ProfileStatisticsCopyWithImpl<$Res, $Val extends ProfileStatistics>
    implements $ProfileStatisticsCopyWith<$Res> {
  _$ProfileStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWordsLearned = null,
    Object? wordsLearnedToday = null,
    Object? wordsLearnedThisWeek = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? totalStudyTimeMinutes = null,
    Object? averageAccuracy = null,
    Object? studySessionsThisWeek = null,
    Object? learningVelocity = null,
    Object? categoryStats = null,
    Object? difficultyStats = null,
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
      totalStudyTimeMinutes: null == totalStudyTimeMinutes
          ? _value.totalStudyTimeMinutes
          : totalStudyTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      studySessionsThisWeek: null == studySessionsThisWeek
          ? _value.studySessionsThisWeek
          : studySessionsThisWeek // ignore: cast_nullable_to_non_nullable
              as int,
      learningVelocity: null == learningVelocity
          ? _value.learningVelocity
          : learningVelocity // ignore: cast_nullable_to_non_nullable
              as double,
      categoryStats: null == categoryStats
          ? _value.categoryStats
          : categoryStats // ignore: cast_nullable_to_non_nullable
              as List<CategoryStats>,
      difficultyStats: null == difficultyStats
          ? _value.difficultyStats
          : difficultyStats // ignore: cast_nullable_to_non_nullable
              as List<DifficultyStats>,
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
abstract class _$$ProfileStatisticsImplCopyWith<$Res>
    implements $ProfileStatisticsCopyWith<$Res> {
  factory _$$ProfileStatisticsImplCopyWith(_$ProfileStatisticsImpl value,
          $Res Function(_$ProfileStatisticsImpl) then) =
      __$$ProfileStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalWordsLearned,
      int wordsLearnedToday,
      int wordsLearnedThisWeek,
      int currentStreak,
      int longestStreak,
      int totalStudyTimeMinutes,
      double averageAccuracy,
      int studySessionsThisWeek,
      double learningVelocity,
      List<CategoryStats> categoryStats,
      List<DifficultyStats> difficultyStats,
      List<Milestone> milestones,
      DateTime? joinDate});
}

/// @nodoc
class __$$ProfileStatisticsImplCopyWithImpl<$Res>
    extends _$ProfileStatisticsCopyWithImpl<$Res, _$ProfileStatisticsImpl>
    implements _$$ProfileStatisticsImplCopyWith<$Res> {
  __$$ProfileStatisticsImplCopyWithImpl(_$ProfileStatisticsImpl _value,
      $Res Function(_$ProfileStatisticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWordsLearned = null,
    Object? wordsLearnedToday = null,
    Object? wordsLearnedThisWeek = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? totalStudyTimeMinutes = null,
    Object? averageAccuracy = null,
    Object? studySessionsThisWeek = null,
    Object? learningVelocity = null,
    Object? categoryStats = null,
    Object? difficultyStats = null,
    Object? milestones = null,
    Object? joinDate = freezed,
  }) {
    return _then(_$ProfileStatisticsImpl(
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
      totalStudyTimeMinutes: null == totalStudyTimeMinutes
          ? _value.totalStudyTimeMinutes
          : totalStudyTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      studySessionsThisWeek: null == studySessionsThisWeek
          ? _value.studySessionsThisWeek
          : studySessionsThisWeek // ignore: cast_nullable_to_non_nullable
              as int,
      learningVelocity: null == learningVelocity
          ? _value.learningVelocity
          : learningVelocity // ignore: cast_nullable_to_non_nullable
              as double,
      categoryStats: null == categoryStats
          ? _value._categoryStats
          : categoryStats // ignore: cast_nullable_to_non_nullable
              as List<CategoryStats>,
      difficultyStats: null == difficultyStats
          ? _value._difficultyStats
          : difficultyStats // ignore: cast_nullable_to_non_nullable
              as List<DifficultyStats>,
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
class _$ProfileStatisticsImpl implements _ProfileStatistics {
  const _$ProfileStatisticsImpl(
      {required this.totalWordsLearned,
      required this.wordsLearnedToday,
      required this.wordsLearnedThisWeek,
      required this.currentStreak,
      required this.longestStreak,
      required this.totalStudyTimeMinutes,
      required this.averageAccuracy,
      required this.studySessionsThisWeek,
      required this.learningVelocity,
      required final List<CategoryStats> categoryStats,
      required final List<DifficultyStats> difficultyStats,
      required final List<Milestone> milestones,
      this.joinDate})
      : _categoryStats = categoryStats,
        _difficultyStats = difficultyStats,
        _milestones = milestones;

  factory _$ProfileStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileStatisticsImplFromJson(json);

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
  final int totalStudyTimeMinutes;
  @override
  final double averageAccuracy;
  @override
  final int studySessionsThisWeek;
  @override
  final double learningVelocity;
  final List<CategoryStats> _categoryStats;
  @override
  List<CategoryStats> get categoryStats {
    if (_categoryStats is EqualUnmodifiableListView) return _categoryStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoryStats);
  }

  final List<DifficultyStats> _difficultyStats;
  @override
  List<DifficultyStats> get difficultyStats {
    if (_difficultyStats is EqualUnmodifiableListView) return _difficultyStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_difficultyStats);
  }

  final List<Milestone> _milestones;
  @override
  List<Milestone> get milestones {
    if (_milestones is EqualUnmodifiableListView) return _milestones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_milestones);
  }

  @override
  final DateTime? joinDate;

  @override
  String toString() {
    return 'ProfileStatistics(totalWordsLearned: $totalWordsLearned, wordsLearnedToday: $wordsLearnedToday, wordsLearnedThisWeek: $wordsLearnedThisWeek, currentStreak: $currentStreak, longestStreak: $longestStreak, totalStudyTimeMinutes: $totalStudyTimeMinutes, averageAccuracy: $averageAccuracy, studySessionsThisWeek: $studySessionsThisWeek, learningVelocity: $learningVelocity, categoryStats: $categoryStats, difficultyStats: $difficultyStats, milestones: $milestones, joinDate: $joinDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStatisticsImpl &&
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
            (identical(other.totalStudyTimeMinutes, totalStudyTimeMinutes) ||
                other.totalStudyTimeMinutes == totalStudyTimeMinutes) &&
            (identical(other.averageAccuracy, averageAccuracy) ||
                other.averageAccuracy == averageAccuracy) &&
            (identical(other.studySessionsThisWeek, studySessionsThisWeek) ||
                other.studySessionsThisWeek == studySessionsThisWeek) &&
            (identical(other.learningVelocity, learningVelocity) ||
                other.learningVelocity == learningVelocity) &&
            const DeepCollectionEquality()
                .equals(other._categoryStats, _categoryStats) &&
            const DeepCollectionEquality()
                .equals(other._difficultyStats, _difficultyStats) &&
            const DeepCollectionEquality()
                .equals(other._milestones, _milestones) &&
            (identical(other.joinDate, joinDate) ||
                other.joinDate == joinDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalWordsLearned,
      wordsLearnedToday,
      wordsLearnedThisWeek,
      currentStreak,
      longestStreak,
      totalStudyTimeMinutes,
      averageAccuracy,
      studySessionsThisWeek,
      learningVelocity,
      const DeepCollectionEquality().hash(_categoryStats),
      const DeepCollectionEquality().hash(_difficultyStats),
      const DeepCollectionEquality().hash(_milestones),
      joinDate);

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStatisticsImplCopyWith<_$ProfileStatisticsImpl> get copyWith =>
      __$$ProfileStatisticsImplCopyWithImpl<_$ProfileStatisticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileStatisticsImplToJson(
      this,
    );
  }
}

abstract class _ProfileStatistics implements ProfileStatistics {
  const factory _ProfileStatistics(
      {required final int totalWordsLearned,
      required final int wordsLearnedToday,
      required final int wordsLearnedThisWeek,
      required final int currentStreak,
      required final int longestStreak,
      required final int totalStudyTimeMinutes,
      required final double averageAccuracy,
      required final int studySessionsThisWeek,
      required final double learningVelocity,
      required final List<CategoryStats> categoryStats,
      required final List<DifficultyStats> difficultyStats,
      required final List<Milestone> milestones,
      final DateTime? joinDate}) = _$ProfileStatisticsImpl;

  factory _ProfileStatistics.fromJson(Map<String, dynamic> json) =
      _$ProfileStatisticsImpl.fromJson;

  @override
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
  int get totalStudyTimeMinutes;
  @override
  double get averageAccuracy;
  @override
  int get studySessionsThisWeek;
  @override
  double get learningVelocity;
  @override
  List<CategoryStats> get categoryStats;
  @override
  List<DifficultyStats> get difficultyStats;
  @override
  List<Milestone> get milestones;
  @override
  DateTime? get joinDate;

  /// Create a copy of ProfileStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStatisticsImplCopyWith<_$ProfileStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategoryStats _$CategoryStatsFromJson(Map<String, dynamic> json) {
  return _CategoryStats.fromJson(json);
}

/// @nodoc
mixin _$CategoryStats {
  String get categoryName => throw _privateConstructorUsedError;
  int get wordsLearned => throw _privateConstructorUsedError;
  int get totalWords => throw _privateConstructorUsedError;
  double get averageAccuracy => throw _privateConstructorUsedError;

  /// Serializes this CategoryStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryStatsCopyWith<CategoryStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryStatsCopyWith<$Res> {
  factory $CategoryStatsCopyWith(
          CategoryStats value, $Res Function(CategoryStats) then) =
      _$CategoryStatsCopyWithImpl<$Res, CategoryStats>;
  @useResult
  $Res call(
      {String categoryName,
      int wordsLearned,
      int totalWords,
      double averageAccuracy});
}

/// @nodoc
class _$CategoryStatsCopyWithImpl<$Res, $Val extends CategoryStats>
    implements $CategoryStatsCopyWith<$Res> {
  _$CategoryStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryName = null,
    Object? wordsLearned = null,
    Object? totalWords = null,
    Object? averageAccuracy = null,
  }) {
    return _then(_value.copyWith(
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      wordsLearned: null == wordsLearned
          ? _value.wordsLearned
          : wordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryStatsImplCopyWith<$Res>
    implements $CategoryStatsCopyWith<$Res> {
  factory _$$CategoryStatsImplCopyWith(
          _$CategoryStatsImpl value, $Res Function(_$CategoryStatsImpl) then) =
      __$$CategoryStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String categoryName,
      int wordsLearned,
      int totalWords,
      double averageAccuracy});
}

/// @nodoc
class __$$CategoryStatsImplCopyWithImpl<$Res>
    extends _$CategoryStatsCopyWithImpl<$Res, _$CategoryStatsImpl>
    implements _$$CategoryStatsImplCopyWith<$Res> {
  __$$CategoryStatsImplCopyWithImpl(
      _$CategoryStatsImpl _value, $Res Function(_$CategoryStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of CategoryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryName = null,
    Object? wordsLearned = null,
    Object? totalWords = null,
    Object? averageAccuracy = null,
  }) {
    return _then(_$CategoryStatsImpl(
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      wordsLearned: null == wordsLearned
          ? _value.wordsLearned
          : wordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryStatsImpl implements _CategoryStats {
  const _$CategoryStatsImpl(
      {required this.categoryName,
      required this.wordsLearned,
      required this.totalWords,
      required this.averageAccuracy});

  factory _$CategoryStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryStatsImplFromJson(json);

  @override
  final String categoryName;
  @override
  final int wordsLearned;
  @override
  final int totalWords;
  @override
  final double averageAccuracy;

  @override
  String toString() {
    return 'CategoryStats(categoryName: $categoryName, wordsLearned: $wordsLearned, totalWords: $totalWords, averageAccuracy: $averageAccuracy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryStatsImpl &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.wordsLearned, wordsLearned) ||
                other.wordsLearned == wordsLearned) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.averageAccuracy, averageAccuracy) ||
                other.averageAccuracy == averageAccuracy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, categoryName, wordsLearned, totalWords, averageAccuracy);

  /// Create a copy of CategoryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryStatsImplCopyWith<_$CategoryStatsImpl> get copyWith =>
      __$$CategoryStatsImplCopyWithImpl<_$CategoryStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryStatsImplToJson(
      this,
    );
  }
}

abstract class _CategoryStats implements CategoryStats {
  const factory _CategoryStats(
      {required final String categoryName,
      required final int wordsLearned,
      required final int totalWords,
      required final double averageAccuracy}) = _$CategoryStatsImpl;

  factory _CategoryStats.fromJson(Map<String, dynamic> json) =
      _$CategoryStatsImpl.fromJson;

  @override
  String get categoryName;
  @override
  int get wordsLearned;
  @override
  int get totalWords;
  @override
  double get averageAccuracy;

  /// Create a copy of CategoryStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryStatsImplCopyWith<_$CategoryStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DifficultyStats _$DifficultyStatsFromJson(Map<String, dynamic> json) {
  return _DifficultyStats.fromJson(json);
}

/// @nodoc
mixin _$DifficultyStats {
  String get difficulty => throw _privateConstructorUsedError;
  int get wordsLearned => throw _privateConstructorUsedError;
  int get totalWords => throw _privateConstructorUsedError;
  double get averageAccuracy => throw _privateConstructorUsedError;

  /// Serializes this DifficultyStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DifficultyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DifficultyStatsCopyWith<DifficultyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DifficultyStatsCopyWith<$Res> {
  factory $DifficultyStatsCopyWith(
          DifficultyStats value, $Res Function(DifficultyStats) then) =
      _$DifficultyStatsCopyWithImpl<$Res, DifficultyStats>;
  @useResult
  $Res call(
      {String difficulty,
      int wordsLearned,
      int totalWords,
      double averageAccuracy});
}

/// @nodoc
class _$DifficultyStatsCopyWithImpl<$Res, $Val extends DifficultyStats>
    implements $DifficultyStatsCopyWith<$Res> {
  _$DifficultyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DifficultyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? difficulty = null,
    Object? wordsLearned = null,
    Object? totalWords = null,
    Object? averageAccuracy = null,
  }) {
    return _then(_value.copyWith(
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      wordsLearned: null == wordsLearned
          ? _value.wordsLearned
          : wordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DifficultyStatsImplCopyWith<$Res>
    implements $DifficultyStatsCopyWith<$Res> {
  factory _$$DifficultyStatsImplCopyWith(_$DifficultyStatsImpl value,
          $Res Function(_$DifficultyStatsImpl) then) =
      __$$DifficultyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String difficulty,
      int wordsLearned,
      int totalWords,
      double averageAccuracy});
}

/// @nodoc
class __$$DifficultyStatsImplCopyWithImpl<$Res>
    extends _$DifficultyStatsCopyWithImpl<$Res, _$DifficultyStatsImpl>
    implements _$$DifficultyStatsImplCopyWith<$Res> {
  __$$DifficultyStatsImplCopyWithImpl(
      _$DifficultyStatsImpl _value, $Res Function(_$DifficultyStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DifficultyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? difficulty = null,
    Object? wordsLearned = null,
    Object? totalWords = null,
    Object? averageAccuracy = null,
  }) {
    return _then(_$DifficultyStatsImpl(
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      wordsLearned: null == wordsLearned
          ? _value.wordsLearned
          : wordsLearned // ignore: cast_nullable_to_non_nullable
              as int,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DifficultyStatsImpl implements _DifficultyStats {
  const _$DifficultyStatsImpl(
      {required this.difficulty,
      required this.wordsLearned,
      required this.totalWords,
      required this.averageAccuracy});

  factory _$DifficultyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DifficultyStatsImplFromJson(json);

  @override
  final String difficulty;
  @override
  final int wordsLearned;
  @override
  final int totalWords;
  @override
  final double averageAccuracy;

  @override
  String toString() {
    return 'DifficultyStats(difficulty: $difficulty, wordsLearned: $wordsLearned, totalWords: $totalWords, averageAccuracy: $averageAccuracy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DifficultyStatsImpl &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.wordsLearned, wordsLearned) ||
                other.wordsLearned == wordsLearned) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.averageAccuracy, averageAccuracy) ||
                other.averageAccuracy == averageAccuracy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, difficulty, wordsLearned, totalWords, averageAccuracy);

  /// Create a copy of DifficultyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DifficultyStatsImplCopyWith<_$DifficultyStatsImpl> get copyWith =>
      __$$DifficultyStatsImplCopyWithImpl<_$DifficultyStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DifficultyStatsImplToJson(
      this,
    );
  }
}

abstract class _DifficultyStats implements DifficultyStats {
  const factory _DifficultyStats(
      {required final String difficulty,
      required final int wordsLearned,
      required final int totalWords,
      required final double averageAccuracy}) = _$DifficultyStatsImpl;

  factory _DifficultyStats.fromJson(Map<String, dynamic> json) =
      _$DifficultyStatsImpl.fromJson;

  @override
  String get difficulty;
  @override
  int get wordsLearned;
  @override
  int get totalWords;
  @override
  double get averageAccuracy;

  /// Create a copy of DifficultyStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DifficultyStatsImplCopyWith<_$DifficultyStatsImpl> get copyWith =>
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

  /// Serializes this Milestone to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, type,
      targetValue, currentValue, isUnlocked, unlockedAt);

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
