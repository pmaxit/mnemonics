// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) {
  return _UserInfo.fromJson(json);
}

/// @nodoc
mixin _$UserInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  DateTime get joinedDate => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  List<String> get preferredLanguages => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  UserSubscriptionType get subscriptionType =>
      throw _privateConstructorUsedError;
  DateTime? get lastActiveDate => throw _privateConstructorUsedError;
  UserPreferences get preferences => throw _privateConstructorUsedError;

  /// Serializes this UserInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserInfoCopyWith<UserInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserInfoCopyWith<$Res> {
  factory $UserInfoCopyWith(UserInfo value, $Res Function(UserInfo) then) =
      _$UserInfoCopyWithImpl<$Res, UserInfo>;
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      DateTime joinedDate,
      String? profileImageUrl,
      String? bio,
      List<String> preferredLanguages,
      String timezone,
      UserSubscriptionType subscriptionType,
      DateTime? lastActiveDate,
      UserPreferences preferences});

  $UserPreferencesCopyWith<$Res> get preferences;
}

/// @nodoc
class _$UserInfoCopyWithImpl<$Res, $Val extends UserInfo>
    implements $UserInfoCopyWith<$Res> {
  _$UserInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? joinedDate = null,
    Object? profileImageUrl = freezed,
    Object? bio = freezed,
    Object? preferredLanguages = null,
    Object? timezone = null,
    Object? subscriptionType = null,
    Object? lastActiveDate = freezed,
    Object? preferences = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      joinedDate: null == joinedDate
          ? _value.joinedDate
          : joinedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredLanguages: null == preferredLanguages
          ? _value.preferredLanguages
          : preferredLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      subscriptionType: null == subscriptionType
          ? _value.subscriptionType
          : subscriptionType // ignore: cast_nullable_to_non_nullable
              as UserSubscriptionType,
      lastActiveDate: freezed == lastActiveDate
          ? _value.lastActiveDate
          : lastActiveDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences,
    ) as $Val);
  }

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<$Res> get preferences {
    return $UserPreferencesCopyWith<$Res>(_value.preferences, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserInfoImplCopyWith<$Res>
    implements $UserInfoCopyWith<$Res> {
  factory _$$UserInfoImplCopyWith(
          _$UserInfoImpl value, $Res Function(_$UserInfoImpl) then) =
      __$$UserInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      DateTime joinedDate,
      String? profileImageUrl,
      String? bio,
      List<String> preferredLanguages,
      String timezone,
      UserSubscriptionType subscriptionType,
      DateTime? lastActiveDate,
      UserPreferences preferences});

  @override
  $UserPreferencesCopyWith<$Res> get preferences;
}

/// @nodoc
class __$$UserInfoImplCopyWithImpl<$Res>
    extends _$UserInfoCopyWithImpl<$Res, _$UserInfoImpl>
    implements _$$UserInfoImplCopyWith<$Res> {
  __$$UserInfoImplCopyWithImpl(
      _$UserInfoImpl _value, $Res Function(_$UserInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? joinedDate = null,
    Object? profileImageUrl = freezed,
    Object? bio = freezed,
    Object? preferredLanguages = null,
    Object? timezone = null,
    Object? subscriptionType = null,
    Object? lastActiveDate = freezed,
    Object? preferences = null,
  }) {
    return _then(_$UserInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      joinedDate: null == joinedDate
          ? _value.joinedDate
          : joinedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredLanguages: null == preferredLanguages
          ? _value._preferredLanguages
          : preferredLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      subscriptionType: null == subscriptionType
          ? _value.subscriptionType
          : subscriptionType // ignore: cast_nullable_to_non_nullable
              as UserSubscriptionType,
      lastActiveDate: freezed == lastActiveDate
          ? _value.lastActiveDate
          : lastActiveDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserInfoImpl implements _UserInfo {
  const _$UserInfoImpl(
      {required this.id,
      required this.name,
      required this.email,
      required this.joinedDate,
      this.profileImageUrl,
      this.bio,
      final List<String> preferredLanguages = const [],
      this.timezone = 'UTC',
      this.subscriptionType = UserSubscriptionType.free,
      this.lastActiveDate,
      this.preferences = const UserPreferences()})
      : _preferredLanguages = preferredLanguages;

  factory _$UserInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final DateTime joinedDate;
  @override
  final String? profileImageUrl;
  @override
  final String? bio;
  final List<String> _preferredLanguages;
  @override
  @JsonKey()
  List<String> get preferredLanguages {
    if (_preferredLanguages is EqualUnmodifiableListView)
      return _preferredLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredLanguages);
  }

  @override
  @JsonKey()
  final String timezone;
  @override
  @JsonKey()
  final UserSubscriptionType subscriptionType;
  @override
  final DateTime? lastActiveDate;
  @override
  @JsonKey()
  final UserPreferences preferences;

  @override
  String toString() {
    return 'UserInfo(id: $id, name: $name, email: $email, joinedDate: $joinedDate, profileImageUrl: $profileImageUrl, bio: $bio, preferredLanguages: $preferredLanguages, timezone: $timezone, subscriptionType: $subscriptionType, lastActiveDate: $lastActiveDate, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.joinedDate, joinedDate) ||
                other.joinedDate == joinedDate) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality()
                .equals(other._preferredLanguages, _preferredLanguages) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.subscriptionType, subscriptionType) ||
                other.subscriptionType == subscriptionType) &&
            (identical(other.lastActiveDate, lastActiveDate) ||
                other.lastActiveDate == lastActiveDate) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      email,
      joinedDate,
      profileImageUrl,
      bio,
      const DeepCollectionEquality().hash(_preferredLanguages),
      timezone,
      subscriptionType,
      lastActiveDate,
      preferences);

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserInfoImplCopyWith<_$UserInfoImpl> get copyWith =>
      __$$UserInfoImplCopyWithImpl<_$UserInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserInfoImplToJson(
      this,
    );
  }
}

abstract class _UserInfo implements UserInfo {
  const factory _UserInfo(
      {required final String id,
      required final String name,
      required final String email,
      required final DateTime joinedDate,
      final String? profileImageUrl,
      final String? bio,
      final List<String> preferredLanguages,
      final String timezone,
      final UserSubscriptionType subscriptionType,
      final DateTime? lastActiveDate,
      final UserPreferences preferences}) = _$UserInfoImpl;

  factory _UserInfo.fromJson(Map<String, dynamic> json) =
      _$UserInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;
  @override
  DateTime get joinedDate;
  @override
  String? get profileImageUrl;
  @override
  String? get bio;
  @override
  List<String> get preferredLanguages;
  @override
  String get timezone;
  @override
  UserSubscriptionType get subscriptionType;
  @override
  DateTime? get lastActiveDate;
  @override
  UserPreferences get preferences;

  /// Create a copy of UserInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserInfoImplCopyWith<_$UserInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  bool get enableNotifications => throw _privateConstructorUsedError;
  bool get enableSoundEffects => throw _privateConstructorUsedError;
  bool get enableAnimations => throw _privateConstructorUsedError;
  NotificationFrequency get reminderFrequency =>
      throw _privateConstructorUsedError;
  TimeOfDay get reminderTime => throw _privateConstructorUsedError;
  bool get shareProgress => throw _privateConstructorUsedError;
  bool get enableAnalytics => throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) then) =
      _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call(
      {bool enableNotifications,
      bool enableSoundEffects,
      bool enableAnimations,
      NotificationFrequency reminderFrequency,
      TimeOfDay reminderTime,
      bool shareProgress,
      bool enableAnalytics});

  $TimeOfDayCopyWith<$Res> get reminderTime;
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableNotifications = null,
    Object? enableSoundEffects = null,
    Object? enableAnimations = null,
    Object? reminderFrequency = null,
    Object? reminderTime = null,
    Object? shareProgress = null,
    Object? enableAnalytics = null,
  }) {
    return _then(_value.copyWith(
      enableNotifications: null == enableNotifications
          ? _value.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSoundEffects: null == enableSoundEffects
          ? _value.enableSoundEffects
          : enableSoundEffects // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAnimations: null == enableAnimations
          ? _value.enableAnimations
          : enableAnimations // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderFrequency: null == reminderFrequency
          ? _value.reminderFrequency
          : reminderFrequency // ignore: cast_nullable_to_non_nullable
              as NotificationFrequency,
      reminderTime: null == reminderTime
          ? _value.reminderTime
          : reminderTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      shareProgress: null == shareProgress
          ? _value.shareProgress
          : shareProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAnalytics: null == enableAnalytics
          ? _value.enableAnalytics
          : enableAnalytics // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayCopyWith<$Res> get reminderTime {
    return $TimeOfDayCopyWith<$Res>(_value.reminderTime, (value) {
      return _then(_value.copyWith(reminderTime: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(_$UserPreferencesImpl value,
          $Res Function(_$UserPreferencesImpl) then) =
      __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enableNotifications,
      bool enableSoundEffects,
      bool enableAnimations,
      NotificationFrequency reminderFrequency,
      TimeOfDay reminderTime,
      bool shareProgress,
      bool enableAnalytics});

  @override
  $TimeOfDayCopyWith<$Res> get reminderTime;
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
      _$UserPreferencesImpl _value, $Res Function(_$UserPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableNotifications = null,
    Object? enableSoundEffects = null,
    Object? enableAnimations = null,
    Object? reminderFrequency = null,
    Object? reminderTime = null,
    Object? shareProgress = null,
    Object? enableAnalytics = null,
  }) {
    return _then(_$UserPreferencesImpl(
      enableNotifications: null == enableNotifications
          ? _value.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSoundEffects: null == enableSoundEffects
          ? _value.enableSoundEffects
          : enableSoundEffects // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAnimations: null == enableAnimations
          ? _value.enableAnimations
          : enableAnimations // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderFrequency: null == reminderFrequency
          ? _value.reminderFrequency
          : reminderFrequency // ignore: cast_nullable_to_non_nullable
              as NotificationFrequency,
      reminderTime: null == reminderTime
          ? _value.reminderTime
          : reminderTime // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      shareProgress: null == shareProgress
          ? _value.shareProgress
          : shareProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAnalytics: null == enableAnalytics
          ? _value.enableAnalytics
          : enableAnalytics // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {this.enableNotifications = true,
      this.enableSoundEffects = true,
      this.enableAnimations = true,
      this.reminderFrequency = NotificationFrequency.daily,
      this.reminderTime = const TimeOfDay(hour: 9, minute: 0),
      this.shareProgress = false,
      this.enableAnalytics = false});

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final bool enableNotifications;
  @override
  @JsonKey()
  final bool enableSoundEffects;
  @override
  @JsonKey()
  final bool enableAnimations;
  @override
  @JsonKey()
  final NotificationFrequency reminderFrequency;
  @override
  @JsonKey()
  final TimeOfDay reminderTime;
  @override
  @JsonKey()
  final bool shareProgress;
  @override
  @JsonKey()
  final bool enableAnalytics;

  @override
  String toString() {
    return 'UserPreferences(enableNotifications: $enableNotifications, enableSoundEffects: $enableSoundEffects, enableAnimations: $enableAnimations, reminderFrequency: $reminderFrequency, reminderTime: $reminderTime, shareProgress: $shareProgress, enableAnalytics: $enableAnalytics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            (identical(other.enableSoundEffects, enableSoundEffects) ||
                other.enableSoundEffects == enableSoundEffects) &&
            (identical(other.enableAnimations, enableAnimations) ||
                other.enableAnimations == enableAnimations) &&
            (identical(other.reminderFrequency, reminderFrequency) ||
                other.reminderFrequency == reminderFrequency) &&
            (identical(other.reminderTime, reminderTime) ||
                other.reminderTime == reminderTime) &&
            (identical(other.shareProgress, shareProgress) ||
                other.shareProgress == shareProgress) &&
            (identical(other.enableAnalytics, enableAnalytics) ||
                other.enableAnalytics == enableAnalytics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enableNotifications,
      enableSoundEffects,
      enableAnimations,
      reminderFrequency,
      reminderTime,
      shareProgress,
      enableAnalytics);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
      {final bool enableNotifications,
      final bool enableSoundEffects,
      final bool enableAnimations,
      final NotificationFrequency reminderFrequency,
      final TimeOfDay reminderTime,
      final bool shareProgress,
      final bool enableAnalytics}) = _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  bool get enableNotifications;
  @override
  bool get enableSoundEffects;
  @override
  bool get enableAnimations;
  @override
  NotificationFrequency get reminderFrequency;
  @override
  TimeOfDay get reminderTime;
  @override
  bool get shareProgress;
  @override
  bool get enableAnalytics;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeOfDay _$TimeOfDayFromJson(Map<String, dynamic> json) {
  return _TimeOfDay.fromJson(json);
}

/// @nodoc
mixin _$TimeOfDay {
  int get hour => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;

  /// Serializes this TimeOfDay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeOfDayCopyWith<TimeOfDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeOfDayCopyWith<$Res> {
  factory $TimeOfDayCopyWith(TimeOfDay value, $Res Function(TimeOfDay) then) =
      _$TimeOfDayCopyWithImpl<$Res, TimeOfDay>;
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class _$TimeOfDayCopyWithImpl<$Res, $Val extends TimeOfDay>
    implements $TimeOfDayCopyWith<$Res> {
  _$TimeOfDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_value.copyWith(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeOfDayImplCopyWith<$Res>
    implements $TimeOfDayCopyWith<$Res> {
  factory _$$TimeOfDayImplCopyWith(
          _$TimeOfDayImpl value, $Res Function(_$TimeOfDayImpl) then) =
      __$$TimeOfDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class __$$TimeOfDayImplCopyWithImpl<$Res>
    extends _$TimeOfDayCopyWithImpl<$Res, _$TimeOfDayImpl>
    implements _$$TimeOfDayImplCopyWith<$Res> {
  __$$TimeOfDayImplCopyWithImpl(
      _$TimeOfDayImpl _value, $Res Function(_$TimeOfDayImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_$TimeOfDayImpl(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeOfDayImpl implements _TimeOfDay {
  const _$TimeOfDayImpl({required this.hour, required this.minute});

  factory _$TimeOfDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeOfDayImplFromJson(json);

  @override
  final int hour;
  @override
  final int minute;

  @override
  String toString() {
    return 'TimeOfDay(hour: $hour, minute: $minute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeOfDayImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute);

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeOfDayImplCopyWith<_$TimeOfDayImpl> get copyWith =>
      __$$TimeOfDayImplCopyWithImpl<_$TimeOfDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeOfDayImplToJson(
      this,
    );
  }
}

abstract class _TimeOfDay implements TimeOfDay {
  const factory _TimeOfDay(
      {required final int hour, required final int minute}) = _$TimeOfDayImpl;

  factory _TimeOfDay.fromJson(Map<String, dynamic> json) =
      _$TimeOfDayImpl.fromJson;

  @override
  int get hour;
  @override
  int get minute;

  /// Create a copy of TimeOfDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeOfDayImplCopyWith<_$TimeOfDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
