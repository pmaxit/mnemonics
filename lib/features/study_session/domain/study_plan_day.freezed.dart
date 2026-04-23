// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_plan_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StudyPlanDay _$StudyPlanDayFromJson(Map<String, dynamic> json) {
  return _StudyPlanDay.fromJson(json);
}

/// @nodoc
mixin _$StudyPlanDay {
  @JsonKey(name: 'day_number')
  int get dayNumber => throw _privateConstructorUsedError;
  List<String> get words => throw _privateConstructorUsedError;
  DayStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'started_at')
  DateTime? get startedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'done_at')
  DateTime? get doneAt => throw _privateConstructorUsedError;

  /// Serializes this StudyPlanDay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyPlanDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      {@JsonKey(name: 'day_number') int dayNumber,
      List<String> words,
      DayStatus status,
      @JsonKey(name: 'started_at') DateTime? startedAt,
      @JsonKey(name: 'done_at') DateTime? doneAt});
}

/// @nodoc
class _$StudyPlanDayCopyWithImpl<$Res, $Val extends StudyPlanDay>
    implements $StudyPlanDayCopyWith<$Res> {
  _$StudyPlanDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyPlanDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayNumber = null,
    Object? words = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? doneAt = freezed,
  }) {
    return _then(_value.copyWith(
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      words: null == words
          ? _value.words
          : words // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DayStatus,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      doneAt: freezed == doneAt
          ? _value.doneAt
          : doneAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      {@JsonKey(name: 'day_number') int dayNumber,
      List<String> words,
      DayStatus status,
      @JsonKey(name: 'started_at') DateTime? startedAt,
      @JsonKey(name: 'done_at') DateTime? doneAt});
}

/// @nodoc
class __$$StudyPlanDayImplCopyWithImpl<$Res>
    extends _$StudyPlanDayCopyWithImpl<$Res, _$StudyPlanDayImpl>
    implements _$$StudyPlanDayImplCopyWith<$Res> {
  __$$StudyPlanDayImplCopyWithImpl(
      _$StudyPlanDayImpl _value, $Res Function(_$StudyPlanDayImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyPlanDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayNumber = null,
    Object? words = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? doneAt = freezed,
  }) {
    return _then(_$StudyPlanDayImpl(
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      words: null == words
          ? _value._words
          : words // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DayStatus,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      doneAt: freezed == doneAt
          ? _value.doneAt
          : doneAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyPlanDayImpl implements _StudyPlanDay {
  const _$StudyPlanDayImpl(
      {@JsonKey(name: 'day_number') required this.dayNumber,
      required final List<String> words,
      this.status = DayStatus.notAttempted,
      @JsonKey(name: 'started_at') this.startedAt,
      @JsonKey(name: 'done_at') this.doneAt})
      : _words = words;

  factory _$StudyPlanDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyPlanDayImplFromJson(json);

  @override
  @JsonKey(name: 'day_number')
  final int dayNumber;
  final List<String> _words;
  @override
  List<String> get words {
    if (_words is EqualUnmodifiableListView) return _words;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_words);
  }

  @override
  @JsonKey()
  final DayStatus status;
  @override
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @override
  @JsonKey(name: 'done_at')
  final DateTime? doneAt;

  @override
  String toString() {
    return 'StudyPlanDay(dayNumber: $dayNumber, words: $words, status: $status, startedAt: $startedAt, doneAt: $doneAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyPlanDayImpl &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            const DeepCollectionEquality().equals(other._words, _words) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.doneAt, doneAt) || other.doneAt == doneAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, dayNumber,
      const DeepCollectionEquality().hash(_words), status, startedAt, doneAt);

  /// Create a copy of StudyPlanDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      {@JsonKey(name: 'day_number') required final int dayNumber,
      required final List<String> words,
      final DayStatus status,
      @JsonKey(name: 'started_at') final DateTime? startedAt,
      @JsonKey(name: 'done_at') final DateTime? doneAt}) = _$StudyPlanDayImpl;

  factory _StudyPlanDay.fromJson(Map<String, dynamic> json) =
      _$StudyPlanDayImpl.fromJson;

  @override
  @JsonKey(name: 'day_number')
  int get dayNumber;
  @override
  List<String> get words;
  @override
  DayStatus get status;
  @override
  @JsonKey(name: 'started_at')
  DateTime? get startedAt;
  @override
  @JsonKey(name: 'done_at')
  DateTime? get doneAt;

  /// Create a copy of StudyPlanDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyPlanDayImplCopyWith<_$StudyPlanDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
