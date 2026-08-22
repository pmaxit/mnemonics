// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistics_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StatisticsData _$StatisticsDataFromJson(Map<String, dynamic> json) {
  return _StatisticsData.fromJson(json);
}

/// @nodoc
mixin _$StatisticsData {
  int get totalLearned => throw _privateConstructorUsedError;
  int get learnedToday => throw _privateConstructorUsedError;
  int get newCount => throw _privateConstructorUsedError;
  int get inProgressCount => throw _privateConstructorUsedError;
  int get masteredCount => throw _privateConstructorUsedError;
  Map<String, int> get categoryBreakdown => throw _privateConstructorUsedError;
  Map<String, int> get difficultyBreakdown =>
      throw _privateConstructorUsedError;
  List<DailyProgress> get weeklyProgress => throw _privateConstructorUsedError;
  double get averageAccuracy => throw _privateConstructorUsedError;
  int get totalReviews => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StatisticsDataCopyWith<StatisticsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatisticsDataCopyWith<$Res> {
  factory $StatisticsDataCopyWith(
          StatisticsData value, $Res Function(StatisticsData) then) =
      _$StatisticsDataCopyWithImpl<$Res, StatisticsData>;
  @useResult
  $Res call(
      {int totalLearned,
      int learnedToday,
      int newCount,
      int inProgressCount,
      int masteredCount,
      Map<String, int> categoryBreakdown,
      Map<String, int> difficultyBreakdown,
      List<DailyProgress> weeklyProgress,
      double averageAccuracy,
      int totalReviews,
      int streak});
}

/// @nodoc
class _$StatisticsDataCopyWithImpl<$Res, $Val extends StatisticsData>
    implements $StatisticsDataCopyWith<$Res> {
  _$StatisticsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalLearned = null,
    Object? learnedToday = null,
    Object? newCount = null,
    Object? inProgressCount = null,
    Object? masteredCount = null,
    Object? categoryBreakdown = null,
    Object? difficultyBreakdown = null,
    Object? weeklyProgress = null,
    Object? averageAccuracy = null,
    Object? totalReviews = null,
    Object? streak = null,
  }) {
    return _then(_value.copyWith(
      totalLearned: null == totalLearned
          ? _value.totalLearned
          : totalLearned // ignore: cast_nullable_to_non_nullable
              as int,
      learnedToday: null == learnedToday
          ? _value.learnedToday
          : learnedToday // ignore: cast_nullable_to_non_nullable
              as int,
      newCount: null == newCount
          ? _value.newCount
          : newCount // ignore: cast_nullable_to_non_nullable
              as int,
      inProgressCount: null == inProgressCount
          ? _value.inProgressCount
          : inProgressCount // ignore: cast_nullable_to_non_nullable
              as int,
      masteredCount: null == masteredCount
          ? _value.masteredCount
          : masteredCount // ignore: cast_nullable_to_non_nullable
              as int,
      categoryBreakdown: null == categoryBreakdown
          ? _value.categoryBreakdown
          : categoryBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      difficultyBreakdown: null == difficultyBreakdown
          ? _value.difficultyBreakdown
          : difficultyBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      weeklyProgress: null == weeklyProgress
          ? _value.weeklyProgress
          : weeklyProgress // ignore: cast_nullable_to_non_nullable
              as List<DailyProgress>,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatisticsDataImplCopyWith<$Res>
    implements $StatisticsDataCopyWith<$Res> {
  factory _$$StatisticsDataImplCopyWith(_$StatisticsDataImpl value,
          $Res Function(_$StatisticsDataImpl) then) =
      __$$StatisticsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalLearned,
      int learnedToday,
      int newCount,
      int inProgressCount,
      int masteredCount,
      Map<String, int> categoryBreakdown,
      Map<String, int> difficultyBreakdown,
      List<DailyProgress> weeklyProgress,
      double averageAccuracy,
      int totalReviews,
      int streak});
}

/// @nodoc
class __$$StatisticsDataImplCopyWithImpl<$Res>
    extends _$StatisticsDataCopyWithImpl<$Res, _$StatisticsDataImpl>
    implements _$$StatisticsDataImplCopyWith<$Res> {
  __$$StatisticsDataImplCopyWithImpl(
      _$StatisticsDataImpl _value, $Res Function(_$StatisticsDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalLearned = null,
    Object? learnedToday = null,
    Object? newCount = null,
    Object? inProgressCount = null,
    Object? masteredCount = null,
    Object? categoryBreakdown = null,
    Object? difficultyBreakdown = null,
    Object? weeklyProgress = null,
    Object? averageAccuracy = null,
    Object? totalReviews = null,
    Object? streak = null,
  }) {
    return _then(_$StatisticsDataImpl(
      totalLearned: null == totalLearned
          ? _value.totalLearned
          : totalLearned // ignore: cast_nullable_to_non_nullable
              as int,
      learnedToday: null == learnedToday
          ? _value.learnedToday
          : learnedToday // ignore: cast_nullable_to_non_nullable
              as int,
      newCount: null == newCount
          ? _value.newCount
          : newCount // ignore: cast_nullable_to_non_nullable
              as int,
      inProgressCount: null == inProgressCount
          ? _value.inProgressCount
          : inProgressCount // ignore: cast_nullable_to_non_nullable
              as int,
      masteredCount: null == masteredCount
          ? _value.masteredCount
          : masteredCount // ignore: cast_nullable_to_non_nullable
              as int,
      categoryBreakdown: null == categoryBreakdown
          ? _value._categoryBreakdown
          : categoryBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      difficultyBreakdown: null == difficultyBreakdown
          ? _value._difficultyBreakdown
          : difficultyBreakdown // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      weeklyProgress: null == weeklyProgress
          ? _value._weeklyProgress
          : weeklyProgress // ignore: cast_nullable_to_non_nullable
              as List<DailyProgress>,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StatisticsDataImpl implements _StatisticsData {
  const _$StatisticsDataImpl(
      {required this.totalLearned,
      required this.learnedToday,
      required this.newCount,
      required this.inProgressCount,
      required this.masteredCount,
      required final Map<String, int> categoryBreakdown,
      required final Map<String, int> difficultyBreakdown,
      required final List<DailyProgress> weeklyProgress,
      required this.averageAccuracy,
      required this.totalReviews,
      required this.streak})
      : _categoryBreakdown = categoryBreakdown,
        _difficultyBreakdown = difficultyBreakdown,
        _weeklyProgress = weeklyProgress;

  factory _$StatisticsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatisticsDataImplFromJson(json);

  @override
  final int totalLearned;
  @override
  final int learnedToday;
  @override
  final int newCount;
  @override
  final int inProgressCount;
  @override
  final int masteredCount;
  final Map<String, int> _categoryBreakdown;
  @override
  Map<String, int> get categoryBreakdown {
    if (_categoryBreakdown is EqualUnmodifiableMapView)
      return _categoryBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryBreakdown);
  }

  final Map<String, int> _difficultyBreakdown;
  @override
  Map<String, int> get difficultyBreakdown {
    if (_difficultyBreakdown is EqualUnmodifiableMapView)
      return _difficultyBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_difficultyBreakdown);
  }

  final List<DailyProgress> _weeklyProgress;
  @override
  List<DailyProgress> get weeklyProgress {
    if (_weeklyProgress is EqualUnmodifiableListView) return _weeklyProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeklyProgress);
  }

  @override
  final double averageAccuracy;
  @override
  final int totalReviews;
  @override
  final int streak;

  @override
  String toString() {
    return 'StatisticsData(totalLearned: $totalLearned, learnedToday: $learnedToday, newCount: $newCount, inProgressCount: $inProgressCount, masteredCount: $masteredCount, categoryBreakdown: $categoryBreakdown, difficultyBreakdown: $difficultyBreakdown, weeklyProgress: $weeklyProgress, averageAccuracy: $averageAccuracy, totalReviews: $totalReviews, streak: $streak)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatisticsDataImpl &&
            (identical(other.totalLearned, totalLearned) ||
                other.totalLearned == totalLearned) &&
            (identical(other.learnedToday, learnedToday) ||
                other.learnedToday == learnedToday) &&
            (identical(other.newCount, newCount) ||
                other.newCount == newCount) &&
            (identical(other.inProgressCount, inProgressCount) ||
                other.inProgressCount == inProgressCount) &&
            (identical(other.masteredCount, masteredCount) ||
                other.masteredCount == masteredCount) &&
            const DeepCollectionEquality()
                .equals(other._categoryBreakdown, _categoryBreakdown) &&
            const DeepCollectionEquality()
                .equals(other._difficultyBreakdown, _difficultyBreakdown) &&
            const DeepCollectionEquality()
                .equals(other._weeklyProgress, _weeklyProgress) &&
            (identical(other.averageAccuracy, averageAccuracy) ||
                other.averageAccuracy == averageAccuracy) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.streak, streak) || other.streak == streak));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalLearned,
      learnedToday,
      newCount,
      inProgressCount,
      masteredCount,
      const DeepCollectionEquality().hash(_categoryBreakdown),
      const DeepCollectionEquality().hash(_difficultyBreakdown),
      const DeepCollectionEquality().hash(_weeklyProgress),
      averageAccuracy,
      totalReviews,
      streak);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StatisticsDataImplCopyWith<_$StatisticsDataImpl> get copyWith =>
      __$$StatisticsDataImplCopyWithImpl<_$StatisticsDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatisticsDataImplToJson(
      this,
    );
  }
}

abstract class _StatisticsData implements StatisticsData {
  const factory _StatisticsData(
      {required final int totalLearned,
      required final int learnedToday,
      required final int newCount,
      required final int inProgressCount,
      required final int masteredCount,
      required final Map<String, int> categoryBreakdown,
      required final Map<String, int> difficultyBreakdown,
      required final List<DailyProgress> weeklyProgress,
      required final double averageAccuracy,
      required final int totalReviews,
      required final int streak}) = _$StatisticsDataImpl;

  factory _StatisticsData.fromJson(Map<String, dynamic> json) =
      _$StatisticsDataImpl.fromJson;

  @override
  int get totalLearned;
  @override
  int get learnedToday;
  @override
  int get newCount;
  @override
  int get inProgressCount;
  @override
  int get masteredCount;
  @override
  Map<String, int> get categoryBreakdown;
  @override
  Map<String, int> get difficultyBreakdown;
  @override
  List<DailyProgress> get weeklyProgress;
  @override
  double get averageAccuracy;
  @override
  int get totalReviews;
  @override
  int get streak;
  @override
  @JsonKey(ignore: true)
  _$$StatisticsDataImplCopyWith<_$StatisticsDataImpl> get copyWith =>
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
  $Res call({DateTime date, int wordsLearned, int reviewsCompleted});
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
  $Res call({DateTime date, int wordsLearned, int reviewsCompleted});
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyProgressImpl implements _DailyProgress {
  const _$DailyProgressImpl(
      {required this.date,
      required this.wordsLearned,
      required this.reviewsCompleted});

  factory _$DailyProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyProgressImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int wordsLearned;
  @override
  final int reviewsCompleted;

  @override
  String toString() {
    return 'DailyProgress(date: $date, wordsLearned: $wordsLearned, reviewsCompleted: $reviewsCompleted)';
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
                other.reviewsCompleted == reviewsCompleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, wordsLearned, reviewsCompleted);

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
      required final int reviewsCompleted}) = _$DailyProgressImpl;

  factory _DailyProgress.fromJson(Map<String, dynamic> json) =
      _$DailyProgressImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get wordsLearned;
  @override
  int get reviewsCompleted;
  @override
  @JsonKey(ignore: true)
  _$$DailyProgressImplCopyWith<_$DailyProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
