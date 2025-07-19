// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserInfoImpl _$$UserInfoImplFromJson(Map<String, dynamic> json) =>
    _$UserInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      profileImageUrl: json['profileImageUrl'] as String?,
      bio: json['bio'] as String?,
      preferredLanguages: (json['preferredLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      timezone: json['timezone'] as String? ?? 'UTC',
      subscriptionType: $enumDecodeNullable(
              _$UserSubscriptionTypeEnumMap, json['subscriptionType']) ??
          UserSubscriptionType.free,
      lastActiveDate: json['lastActiveDate'] == null
          ? null
          : DateTime.parse(json['lastActiveDate'] as String),
      preferences: json['preferences'] == null
          ? const UserPreferences()
          : UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserInfoImplToJson(_$UserInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'joinedDate': instance.joinedDate.toIso8601String(),
      'profileImageUrl': instance.profileImageUrl,
      'bio': instance.bio,
      'preferredLanguages': instance.preferredLanguages,
      'timezone': instance.timezone,
      'subscriptionType':
          _$UserSubscriptionTypeEnumMap[instance.subscriptionType]!,
      'lastActiveDate': instance.lastActiveDate?.toIso8601String(),
      'preferences': instance.preferences,
    };

const _$UserSubscriptionTypeEnumMap = {
  UserSubscriptionType.free: 'free',
  UserSubscriptionType.premium: 'premium',
  UserSubscriptionType.family: 'family',
};

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesImpl(
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enableSoundEffects: json['enableSoundEffects'] as bool? ?? true,
      enableAnimations: json['enableAnimations'] as bool? ?? true,
      reminderFrequency: $enumDecodeNullable(
              _$NotificationFrequencyEnumMap, json['reminderFrequency']) ??
          NotificationFrequency.daily,
      reminderTime: json['reminderTime'] == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay.fromJson(json['reminderTime'] as Map<String, dynamic>),
      shareProgress: json['shareProgress'] as bool? ?? false,
      enableAnalytics: json['enableAnalytics'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'enableNotifications': instance.enableNotifications,
      'enableSoundEffects': instance.enableSoundEffects,
      'enableAnimations': instance.enableAnimations,
      'reminderFrequency':
          _$NotificationFrequencyEnumMap[instance.reminderFrequency]!,
      'reminderTime': instance.reminderTime,
      'shareProgress': instance.shareProgress,
      'enableAnalytics': instance.enableAnalytics,
    };

const _$NotificationFrequencyEnumMap = {
  NotificationFrequency.never: 'never',
  NotificationFrequency.daily: 'daily',
  NotificationFrequency.weekly: 'weekly',
  NotificationFrequency.custom: 'custom',
};

_$TimeOfDayImpl _$$TimeOfDayImplFromJson(Map<String, dynamic> json) =>
    _$TimeOfDayImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$$TimeOfDayImplToJson(_$TimeOfDayImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };
