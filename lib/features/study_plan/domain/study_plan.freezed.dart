// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StudyPlan _$StudyPlanFromJson(Map<String, dynamic> json) {
  return _StudyPlan.fromJson(json);
}

/// @nodoc
mixin _$StudyPlan {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_words')
  int get totalWords => throw _privateConstructorUsedError;
  @JsonKey(name: 'words_per_day')
  int get wordsPerDay => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_days')
  int get totalDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String get startDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  List<StudyPlanDay> get days => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StudyPlanCopyWith<StudyPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyPlanCopyWith<$Res> {
  factory $StudyPlanCopyWith(StudyPlan value, $Res Function(StudyPlan) then) =
      _$StudyPlanCopyWithImpl<$Res, StudyPlan>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'total_words') int totalWords,
      @JsonKey(name: 'words_per_day') int wordsPerDay,
      @JsonKey(name: 'total_days') int totalDays,
      @JsonKey(name: 'start_date') String startDate,
      String status,
      @JsonKey(name: 'created_at') String? createdAt,
      List<StudyPlanDay> days});
}

/// @nodoc
class _$StudyPlanCopyWithImpl<$Res, $Val extends StudyPlan>
    implements $StudyPlanCopyWith<$Res> {
  _$StudyPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? totalWords = null,
    Object? wordsPerDay = null,
    Object? totalDays = null,
    Object? startDate = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? days = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      wordsPerDay: null == wordsPerDay
          ? _value.wordsPerDay
          : wordsPerDay // ignore: cast_nullable_to_non_nullable
              as int,
      totalDays: null == totalDays
          ? _value.totalDays
          : totalDays // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as List<StudyPlanDay>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyPlanImplCopyWith<$Res>
    implements $StudyPlanCopyWith<$Res> {
  factory _$$StudyPlanImplCopyWith(
          _$StudyPlanImpl value, $Res Function(_$StudyPlanImpl) then) =
      __$$StudyPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'total_words') int totalWords,
      @JsonKey(name: 'words_per_day') int wordsPerDay,
      @JsonKey(name: 'total_days') int totalDays,
      @JsonKey(name: 'start_date') String startDate,
      String status,
      @JsonKey(name: 'created_at') String? createdAt,
      List<StudyPlanDay> days});
}

/// @nodoc
class __$$StudyPlanImplCopyWithImpl<$Res>
    extends _$StudyPlanCopyWithImpl<$Res, _$StudyPlanImpl>
    implements _$$StudyPlanImplCopyWith<$Res> {
  __$$StudyPlanImplCopyWithImpl(
      _$StudyPlanImpl _value, $Res Function(_$StudyPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? totalWords = null,
    Object? wordsPerDay = null,
    Object? totalDays = null,
    Object? startDate = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? days = null,
  }) {
    return _then(_$StudyPlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      wordsPerDay: null == wordsPerDay
          ? _value.wordsPerDay
          : wordsPerDay // ignore: cast_nullable_to_non_nullable
              as int,
      totalDays: null == totalDays
          ? _value.totalDays
          : totalDays // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      days: null == days
          ? _value._days
          : days // ignore: cast_nullable_to_non_nullable
              as List<StudyPlanDay>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyPlanImpl implements _StudyPlan {
  const _$StudyPlanImpl(
      {required this.id,
      @JsonKey(name: 'user_id') this.userId = 'default',
      @JsonKey(name: 'total_words') required this.totalWords,
      @JsonKey(name: 'words_per_day') required this.wordsPerDay,
      @JsonKey(name: 'total_days') required this.totalDays,
      @JsonKey(name: 'start_date') required this.startDate,
      this.status = 'active',
      @JsonKey(name: 'created_at') this.createdAt,
      final List<StudyPlanDay> days = const []})
      : _days = days;

  factory _$StudyPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyPlanImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'total_words')
  final int totalWords;
  @override
  @JsonKey(name: 'words_per_day')
  final int wordsPerDay;
  @override
  @JsonKey(name: 'total_days')
  final int totalDays;
  @override
  @JsonKey(name: 'start_date')
  final String startDate;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final List<StudyPlanDay> _days;
  @override
  @JsonKey()
  List<StudyPlanDay> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  String toString() {
    return 'StudyPlan(id: $id, userId: $userId, totalWords: $totalWords, wordsPerDay: $wordsPerDay, totalDays: $totalDays, startDate: $startDate, status: $status, createdAt: $createdAt, days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.wordsPerDay, wordsPerDay) ||
                other.wordsPerDay == wordsPerDay) &&
            (identical(other.totalDays, totalDays) ||
                other.totalDays == totalDays) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._days, _days));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      totalWords,
      wordsPerDay,
      totalDays,
      startDate,
      status,
      createdAt,
      const DeepCollectionEquality().hash(_days));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyPlanImplCopyWith<_$StudyPlanImpl> get copyWith =>
      __$$StudyPlanImplCopyWithImpl<_$StudyPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyPlanImplToJson(
      this,
    );
  }
}

abstract class _StudyPlan implements StudyPlan {
  const factory _StudyPlan(
      {required final int id,
      @JsonKey(name: 'user_id') final String userId,
      @JsonKey(name: 'total_words') required final int totalWords,
      @JsonKey(name: 'words_per_day') required final int wordsPerDay,
      @JsonKey(name: 'total_days') required final int totalDays,
      @JsonKey(name: 'start_date') required final String startDate,
      final String status,
      @JsonKey(name: 'created_at') final String? createdAt,
      final List<StudyPlanDay> days}) = _$StudyPlanImpl;

  factory _StudyPlan.fromJson(Map<String, dynamic> json) =
      _$StudyPlanImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'total_words')
  int get totalWords;
  @override
  @JsonKey(name: 'words_per_day')
  int get wordsPerDay;
  @override
  @JsonKey(name: 'total_days')
  int get totalDays;
  @override
  @JsonKey(name: 'start_date')
  String get startDate;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  List<StudyPlanDay> get days;
  @override
  @JsonKey(ignore: true)
  _$$StudyPlanImplCopyWith<_$StudyPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudyPlanDay _$StudyPlanDayFromJson(Map<String, dynamic> json) {
  return _StudyPlanDay.fromJson(json);
}

/// @nodoc
mixin _$StudyPlanDay {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_number')
  int get dayNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'scheduled_date')
  String get scheduledDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get theme => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_words')
  int get totalWords => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_words')
  int get completedWords => throw _privateConstructorUsedError;
  @JsonKey(name: 'in_progress_words')
  int get inProgressWords => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StudyPlanDayCopyWith<StudyPlanDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyPlanDayCopyWith<$Res> {
  factory $StudyPlanDayCopyWith(
          StudyPlanDay value, $Res Function(StudyPlanDay) then) =
      _$StudyPlanDayCopyWithImpl<$Res, StudyPlanDay>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'day_number') int dayNumber,
      @JsonKey(name: 'scheduled_date') String scheduledDate,
      String status,
      String? theme,
      @JsonKey(name: 'total_words') int totalWords,
      @JsonKey(name: 'completed_words') int completedWords,
      @JsonKey(name: 'in_progress_words') int inProgressWords});
}

/// @nodoc
class _$StudyPlanDayCopyWithImpl<$Res, $Val extends StudyPlanDay>
    implements $StudyPlanDayCopyWith<$Res> {
  _$StudyPlanDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayNumber = null,
    Object? scheduledDate = null,
    Object? status = null,
    Object? theme = freezed,
    Object? totalWords = null,
    Object? completedWords = null,
    Object? inProgressWords = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      theme: freezed == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String?,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      completedWords: null == completedWords
          ? _value.completedWords
          : completedWords // ignore: cast_nullable_to_non_nullable
              as int,
      inProgressWords: null == inProgressWords
          ? _value.inProgressWords
          : inProgressWords // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyPlanDayImplCopyWith<$Res>
    implements $StudyPlanDayCopyWith<$Res> {
  factory _$$StudyPlanDayImplCopyWith(
          _$StudyPlanDayImpl value, $Res Function(_$StudyPlanDayImpl) then) =
      __$$StudyPlanDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'day_number') int dayNumber,
      @JsonKey(name: 'scheduled_date') String scheduledDate,
      String status,
      String? theme,
      @JsonKey(name: 'total_words') int totalWords,
      @JsonKey(name: 'completed_words') int completedWords,
      @JsonKey(name: 'in_progress_words') int inProgressWords});
}

/// @nodoc
class __$$StudyPlanDayImplCopyWithImpl<$Res>
    extends _$StudyPlanDayCopyWithImpl<$Res, _$StudyPlanDayImpl>
    implements _$$StudyPlanDayImplCopyWith<$Res> {
  __$$StudyPlanDayImplCopyWithImpl(
      _$StudyPlanDayImpl _value, $Res Function(_$StudyPlanDayImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayNumber = null,
    Object? scheduledDate = null,
    Object? status = null,
    Object? theme = freezed,
    Object? totalWords = null,
    Object? completedWords = null,
    Object? inProgressWords = null,
  }) {
    return _then(_$StudyPlanDayImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      theme: freezed == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String?,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      completedWords: null == completedWords
          ? _value.completedWords
          : completedWords // ignore: cast_nullable_to_non_nullable
              as int,
      inProgressWords: null == inProgressWords
          ? _value.inProgressWords
          : inProgressWords // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyPlanDayImpl implements _StudyPlanDay {
  const _$StudyPlanDayImpl(
      {required this.id,
      @JsonKey(name: 'day_number') required this.dayNumber,
      @JsonKey(name: 'scheduled_date') required this.scheduledDate,
      this.status = 'not_started',
      this.theme,
      @JsonKey(name: 'total_words') this.totalWords = 0,
      @JsonKey(name: 'completed_words') this.completedWords = 0,
      @JsonKey(name: 'in_progress_words') this.inProgressWords = 0});

  factory _$StudyPlanDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyPlanDayImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'day_number')
  final int dayNumber;
  @override
  @JsonKey(name: 'scheduled_date')
  final String scheduledDate;
  @override
  @JsonKey()
  final String status;
  @override
  final String? theme;
  @override
  @JsonKey(name: 'total_words')
  final int totalWords;
  @override
  @JsonKey(name: 'completed_words')
  final int completedWords;
  @override
  @JsonKey(name: 'in_progress_words')
  final int inProgressWords;

  @override
  String toString() {
    return 'StudyPlanDay(id: $id, dayNumber: $dayNumber, scheduledDate: $scheduledDate, status: $status, theme: $theme, totalWords: $totalWords, completedWords: $completedWords, inProgressWords: $inProgressWords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyPlanDayImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.completedWords, completedWords) ||
                other.completedWords == completedWords) &&
            (identical(other.inProgressWords, inProgressWords) ||
                other.inProgressWords == inProgressWords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, dayNumber, scheduledDate,
      status, theme, totalWords, completedWords, inProgressWords);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyPlanDayImplCopyWith<_$StudyPlanDayImpl> get copyWith =>
      __$$StudyPlanDayImplCopyWithImpl<_$StudyPlanDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyPlanDayImplToJson(
      this,
    );
  }
}

abstract class _StudyPlanDay implements StudyPlanDay {
  const factory _StudyPlanDay(
          {required final int id,
          @JsonKey(name: 'day_number') required final int dayNumber,
          @JsonKey(name: 'scheduled_date') required final String scheduledDate,
          final String status,
          final String? theme,
          @JsonKey(name: 'total_words') final int totalWords,
          @JsonKey(name: 'completed_words') final int completedWords,
          @JsonKey(name: 'in_progress_words') final int inProgressWords}) =
      _$StudyPlanDayImpl;

  factory _StudyPlanDay.fromJson(Map<String, dynamic> json) =
      _$StudyPlanDayImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'day_number')
  int get dayNumber;
  @override
  @JsonKey(name: 'scheduled_date')
  String get scheduledDate;
  @override
  String get status;
  @override
  String? get theme;
  @override
  @JsonKey(name: 'total_words')
  int get totalWords;
  @override
  @JsonKey(name: 'completed_words')
  int get completedWords;
  @override
  @JsonKey(name: 'in_progress_words')
  int get inProgressWords;
  @override
  @JsonKey(ignore: true)
  _$$StudyPlanDayImplCopyWith<_$StudyPlanDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudyPlanDayDetail _$StudyPlanDayDetailFromJson(Map<String, dynamic> json) {
  return _StudyPlanDayDetail.fromJson(json);
}

/// @nodoc
mixin _$StudyPlanDayDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_number')
  int get dayNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'scheduled_date')
  String get scheduledDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get theme => throw _privateConstructorUsedError;
  List<StudyPlanWord> get words => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StudyPlanDayDetailCopyWith<StudyPlanDayDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyPlanDayDetailCopyWith<$Res> {
  factory $StudyPlanDayDetailCopyWith(
          StudyPlanDayDetail value, $Res Function(StudyPlanDayDetail) then) =
      _$StudyPlanDayDetailCopyWithImpl<$Res, StudyPlanDayDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'day_number') int dayNumber,
      @JsonKey(name: 'scheduled_date') String scheduledDate,
      String status,
      String? theme,
      List<StudyPlanWord> words});
}

/// @nodoc
class _$StudyPlanDayDetailCopyWithImpl<$Res, $Val extends StudyPlanDayDetail>
    implements $StudyPlanDayDetailCopyWith<$Res> {
  _$StudyPlanDayDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayNumber = null,
    Object? scheduledDate = null,
    Object? status = null,
    Object? theme = freezed,
    Object? words = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      theme: freezed == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String?,
      words: null == words
          ? _value.words
          : words // ignore: cast_nullable_to_non_nullable
              as List<StudyPlanWord>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyPlanDayDetailImplCopyWith<$Res>
    implements $StudyPlanDayDetailCopyWith<$Res> {
  factory _$$StudyPlanDayDetailImplCopyWith(_$StudyPlanDayDetailImpl value,
          $Res Function(_$StudyPlanDayDetailImpl) then) =
      __$$StudyPlanDayDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'day_number') int dayNumber,
      @JsonKey(name: 'scheduled_date') String scheduledDate,
      String status,
      String? theme,
      List<StudyPlanWord> words});
}

/// @nodoc
class __$$StudyPlanDayDetailImplCopyWithImpl<$Res>
    extends _$StudyPlanDayDetailCopyWithImpl<$Res, _$StudyPlanDayDetailImpl>
    implements _$$StudyPlanDayDetailImplCopyWith<$Res> {
  __$$StudyPlanDayDetailImplCopyWithImpl(_$StudyPlanDayDetailImpl _value,
      $Res Function(_$StudyPlanDayDetailImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayNumber = null,
    Object? scheduledDate = null,
    Object? status = null,
    Object? theme = freezed,
    Object? words = null,
  }) {
    return _then(_$StudyPlanDayDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      theme: freezed == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String?,
      words: null == words
          ? _value._words
          : words // ignore: cast_nullable_to_non_nullable
              as List<StudyPlanWord>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyPlanDayDetailImpl implements _StudyPlanDayDetail {
  const _$StudyPlanDayDetailImpl(
      {required this.id,
      @JsonKey(name: 'day_number') required this.dayNumber,
      @JsonKey(name: 'scheduled_date') required this.scheduledDate,
      this.status = 'not_started',
      this.theme,
      final List<StudyPlanWord> words = const []})
      : _words = words;

  factory _$StudyPlanDayDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyPlanDayDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'day_number')
  final int dayNumber;
  @override
  @JsonKey(name: 'scheduled_date')
  final String scheduledDate;
  @override
  @JsonKey()
  final String status;
  @override
  final String? theme;
  final List<StudyPlanWord> _words;
  @override
  @JsonKey()
  List<StudyPlanWord> get words {
    if (_words is EqualUnmodifiableListView) return _words;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_words);
  }

  @override
  String toString() {
    return 'StudyPlanDayDetail(id: $id, dayNumber: $dayNumber, scheduledDate: $scheduledDate, status: $status, theme: $theme, words: $words)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyPlanDayDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            const DeepCollectionEquality().equals(other._words, _words));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, dayNumber, scheduledDate,
      status, theme, const DeepCollectionEquality().hash(_words));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyPlanDayDetailImplCopyWith<_$StudyPlanDayDetailImpl> get copyWith =>
      __$$StudyPlanDayDetailImplCopyWithImpl<_$StudyPlanDayDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyPlanDayDetailImplToJson(
      this,
    );
  }
}

abstract class _StudyPlanDayDetail implements StudyPlanDayDetail {
  const factory _StudyPlanDayDetail(
      {required final int id,
      @JsonKey(name: 'day_number') required final int dayNumber,
      @JsonKey(name: 'scheduled_date') required final String scheduledDate,
      final String status,
      final String? theme,
      final List<StudyPlanWord> words}) = _$StudyPlanDayDetailImpl;

  factory _StudyPlanDayDetail.fromJson(Map<String, dynamic> json) =
      _$StudyPlanDayDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'day_number')
  int get dayNumber;
  @override
  @JsonKey(name: 'scheduled_date')
  String get scheduledDate;
  @override
  String get status;
  @override
  String? get theme;
  @override
  List<StudyPlanWord> get words;
  @override
  @JsonKey(ignore: true)
  _$$StudyPlanDayDetailImplCopyWith<_$StudyPlanDayDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudyPlanWord _$StudyPlanWordFromJson(Map<String, dynamic> json) {
  return _StudyPlanWord.fromJson(json);
}

/// @nodoc
mixin _$StudyPlanWord {
  String get word => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  String? get completedAt => throw _privateConstructorUsedError;
  String? get meaning => throw _privateConstructorUsedError;
  String? get mnemonic => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StudyPlanWordCopyWith<StudyPlanWord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyPlanWordCopyWith<$Res> {
  factory $StudyPlanWordCopyWith(
          StudyPlanWord value, $Res Function(StudyPlanWord) then) =
      _$StudyPlanWordCopyWithImpl<$Res, StudyPlanWord>;
  @useResult
  $Res call(
      {String word,
      String status,
      @JsonKey(name: 'completed_at') String? completedAt,
      String? meaning,
      String? mnemonic,
      String? category,
      String? difficulty});
}

/// @nodoc
class _$StudyPlanWordCopyWithImpl<$Res, $Val extends StudyPlanWord>
    implements $StudyPlanWordCopyWith<$Res> {
  _$StudyPlanWordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? status = null,
    Object? completedAt = freezed,
    Object? meaning = freezed,
    Object? mnemonic = freezed,
    Object? category = freezed,
    Object? difficulty = freezed,
  }) {
    return _then(_value.copyWith(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      meaning: freezed == meaning
          ? _value.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String?,
      mnemonic: freezed == mnemonic
          ? _value.mnemonic
          : mnemonic // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyPlanWordImplCopyWith<$Res>
    implements $StudyPlanWordCopyWith<$Res> {
  factory _$$StudyPlanWordImplCopyWith(
          _$StudyPlanWordImpl value, $Res Function(_$StudyPlanWordImpl) then) =
      __$$StudyPlanWordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String word,
      String status,
      @JsonKey(name: 'completed_at') String? completedAt,
      String? meaning,
      String? mnemonic,
      String? category,
      String? difficulty});
}

/// @nodoc
class __$$StudyPlanWordImplCopyWithImpl<$Res>
    extends _$StudyPlanWordCopyWithImpl<$Res, _$StudyPlanWordImpl>
    implements _$$StudyPlanWordImplCopyWith<$Res> {
  __$$StudyPlanWordImplCopyWithImpl(
      _$StudyPlanWordImpl _value, $Res Function(_$StudyPlanWordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? status = null,
    Object? completedAt = freezed,
    Object? meaning = freezed,
    Object? mnemonic = freezed,
    Object? category = freezed,
    Object? difficulty = freezed,
  }) {
    return _then(_$StudyPlanWordImpl(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      meaning: freezed == meaning
          ? _value.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String?,
      mnemonic: freezed == mnemonic
          ? _value.mnemonic
          : mnemonic // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyPlanWordImpl implements _StudyPlanWord {
  const _$StudyPlanWordImpl(
      {required this.word,
      this.status = 'not_started',
      @JsonKey(name: 'completed_at') this.completedAt,
      this.meaning,
      this.mnemonic,
      this.category,
      this.difficulty});

  factory _$StudyPlanWordImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyPlanWordImplFromJson(json);

  @override
  final String word;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'completed_at')
  final String? completedAt;
  @override
  final String? meaning;
  @override
  final String? mnemonic;
  @override
  final String? category;
  @override
  final String? difficulty;

  @override
  String toString() {
    return 'StudyPlanWord(word: $word, status: $status, completedAt: $completedAt, meaning: $meaning, mnemonic: $mnemonic, category: $category, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyPlanWordImpl &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.mnemonic, mnemonic) ||
                other.mnemonic == mnemonic) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, word, status, completedAt,
      meaning, mnemonic, category, difficulty);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyPlanWordImplCopyWith<_$StudyPlanWordImpl> get copyWith =>
      __$$StudyPlanWordImplCopyWithImpl<_$StudyPlanWordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyPlanWordImplToJson(
      this,
    );
  }
}

abstract class _StudyPlanWord implements StudyPlanWord {
  const factory _StudyPlanWord(
      {required final String word,
      final String status,
      @JsonKey(name: 'completed_at') final String? completedAt,
      final String? meaning,
      final String? mnemonic,
      final String? category,
      final String? difficulty}) = _$StudyPlanWordImpl;

  factory _StudyPlanWord.fromJson(Map<String, dynamic> json) =
      _$StudyPlanWordImpl.fromJson;

  @override
  String get word;
  @override
  String get status;
  @override
  @JsonKey(name: 'completed_at')
  String? get completedAt;
  @override
  String? get meaning;
  @override
  String? get mnemonic;
  @override
  String? get category;
  @override
  String? get difficulty;
  @override
  @JsonKey(ignore: true)
  _$$StudyPlanWordImplCopyWith<_$StudyPlanWordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
