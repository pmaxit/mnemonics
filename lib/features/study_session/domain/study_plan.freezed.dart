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
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_words')
  int get totalWords => throw _privateConstructorUsedError;
  @JsonKey(name: 'num_days')
  int get numDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'words_per_day')
  int get wordsPerDay => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String get startDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<StudyPlanDay> get days => throw _privateConstructorUsedError;

  /// Serializes this StudyPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyPlanCopyWith<StudyPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyPlanCopyWith<$Res> {
  factory $StudyPlanCopyWith(StudyPlan value, $Res Function(StudyPlan) then) =
      _$StudyPlanCopyWithImpl<$Res, StudyPlan>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String title,
      @JsonKey(name: 'total_words') int totalWords,
      @JsonKey(name: 'num_days') int numDays,
      @JsonKey(name: 'words_per_day') int wordsPerDay,
      @JsonKey(name: 'start_date') String startDate,
      String status,
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

  /// Create a copy of StudyPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? totalWords = null,
    Object? numDays = null,
    Object? wordsPerDay = null,
    Object? startDate = null,
    Object? status = null,
    Object? days = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      numDays: null == numDays
          ? _value.numDays
          : numDays // ignore: cast_nullable_to_non_nullable
              as int,
      wordsPerDay: null == wordsPerDay
          ? _value.wordsPerDay
          : wordsPerDay // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String title,
      @JsonKey(name: 'total_words') int totalWords,
      @JsonKey(name: 'num_days') int numDays,
      @JsonKey(name: 'words_per_day') int wordsPerDay,
      @JsonKey(name: 'start_date') String startDate,
      String status,
      List<StudyPlanDay> days});
}

/// @nodoc
class __$$StudyPlanImplCopyWithImpl<$Res>
    extends _$StudyPlanCopyWithImpl<$Res, _$StudyPlanImpl>
    implements _$$StudyPlanImplCopyWith<$Res> {
  __$$StudyPlanImplCopyWithImpl(
      _$StudyPlanImpl _value, $Res Function(_$StudyPlanImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? totalWords = null,
    Object? numDays = null,
    Object? wordsPerDay = null,
    Object? startDate = null,
    Object? status = null,
    Object? days = null,
  }) {
    return _then(_$StudyPlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      totalWords: null == totalWords
          ? _value.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      numDays: null == numDays
          ? _value.numDays
          : numDays // ignore: cast_nullable_to_non_nullable
              as int,
      wordsPerDay: null == wordsPerDay
          ? _value.wordsPerDay
          : wordsPerDay // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
      @JsonKey(name: 'user_id') required this.userId,
      required this.title,
      @JsonKey(name: 'total_words') required this.totalWords,
      @JsonKey(name: 'num_days') required this.numDays,
      @JsonKey(name: 'words_per_day') required this.wordsPerDay,
      @JsonKey(name: 'start_date') required this.startDate,
      this.status = 'active',
      final List<StudyPlanDay> days = const <StudyPlanDay>[]})
      : _days = days;

  factory _$StudyPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyPlanImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String title;
  @override
  @JsonKey(name: 'total_words')
  final int totalWords;
  @override
  @JsonKey(name: 'num_days')
  final int numDays;
  @override
  @JsonKey(name: 'words_per_day')
  final int wordsPerDay;
  @override
  @JsonKey(name: 'start_date')
  final String startDate;
  @override
  @JsonKey()
  final String status;
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
    return 'StudyPlan(id: $id, userId: $userId, title: $title, totalWords: $totalWords, numDays: $numDays, wordsPerDay: $wordsPerDay, startDate: $startDate, status: $status, days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.numDays, numDays) || other.numDays == numDays) &&
            (identical(other.wordsPerDay, wordsPerDay) ||
                other.wordsPerDay == wordsPerDay) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._days, _days));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      title,
      totalWords,
      numDays,
      wordsPerDay,
      startDate,
      status,
      const DeepCollectionEquality().hash(_days));

  /// Create a copy of StudyPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      required final String title,
      @JsonKey(name: 'total_words') required final int totalWords,
      @JsonKey(name: 'num_days') required final int numDays,
      @JsonKey(name: 'words_per_day') required final int wordsPerDay,
      @JsonKey(name: 'start_date') required final String startDate,
      final String status,
      final List<StudyPlanDay> days}) = _$StudyPlanImpl;

  factory _StudyPlan.fromJson(Map<String, dynamic> json) =
      _$StudyPlanImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get title;
  @override
  @JsonKey(name: 'total_words')
  int get totalWords;
  @override
  @JsonKey(name: 'num_days')
  int get numDays;
  @override
  @JsonKey(name: 'words_per_day')
  int get wordsPerDay;
  @override
  @JsonKey(name: 'start_date')
  String get startDate;
  @override
  String get status;
  @override
  List<StudyPlanDay> get days;

  /// Create a copy of StudyPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyPlanImplCopyWith<_$StudyPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
