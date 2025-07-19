import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_info.freezed.dart';
part 'user_info.g.dart';

@freezed
class UserInfo with _$UserInfo {
  const factory UserInfo({
    required String id,
    required String name,
    required String email,
    required DateTime joinedDate,
    String? profileImageUrl,
    String? bio,
    @Default([]) List<String> preferredLanguages,
    @Default('UTC') String timezone,
    @Default(UserSubscriptionType.free) UserSubscriptionType subscriptionType,
    DateTime? lastActiveDate,
    @Default(UserPreferences()) UserPreferences preferences,
  }) = _UserInfo;

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool enableNotifications,
    @Default(true) bool enableSoundEffects,
    @Default(true) bool enableAnimations,
    @Default(NotificationFrequency.daily) NotificationFrequency reminderFrequency,
    @Default(TimeOfDay(hour: 9, minute: 0)) TimeOfDay reminderTime,
    @Default(false) bool shareProgress,
    @Default(false) bool enableAnalytics,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
}

@freezed
class TimeOfDay with _$TimeOfDay {
  const factory TimeOfDay({
    required int hour,
    required int minute,
  }) = _TimeOfDay;

  factory TimeOfDay.fromJson(Map<String, dynamic> json) => _$TimeOfDayFromJson(json);
}

enum UserSubscriptionType {
  free,
  premium,
  family,
}

enum NotificationFrequency {
  never,
  daily,
  weekly,
  custom,
}

extension UserSubscriptionTypeExtension on UserSubscriptionType {
  String get displayName {
    switch (this) {
      case UserSubscriptionType.free:
        return 'Free';
      case UserSubscriptionType.premium:
        return 'Premium';
      case UserSubscriptionType.family:
        return 'Family';
    }
  }

  String get description {
    switch (this) {
      case UserSubscriptionType.free:
        return 'Basic features with limited vocabulary';
      case UserSubscriptionType.premium:
        return 'Full access to all vocabulary and features';
      case UserSubscriptionType.family:
        return 'Premium features for up to 6 family members';
    }
  }

  bool get isPremium => this != UserSubscriptionType.free;
}

extension NotificationFrequencyExtension on NotificationFrequency {
  String get displayName {
    switch (this) {
      case NotificationFrequency.never:
        return 'Never';
      case NotificationFrequency.daily:
        return 'Daily';
      case NotificationFrequency.weekly:
        return 'Weekly';
      case NotificationFrequency.custom:
        return 'Custom';
    }
  }
}

extension UserInfoExtension on UserInfo {
  /// Gets the user's display name or falls back to email username
  String get displayName {
    if (name.isNotEmpty) return name;
    return email.split('@').first;
  }

  /// Gets the user's initials for avatar display
  String get initials {
    final displayName = this.displayName;
    final words = displayName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].length >= 2) {
      return words[0].substring(0, 2).toUpperCase();
    }
    return 'U';
  }

  /// Calculates days since the user joined
  int get daysSinceJoined {
    final now = DateTime.now();
    return now.difference(joinedDate).inDays;
  }

  /// Calculates days since last active
  int? get daysSinceLastActive {
    if (lastActiveDate == null) return null;
    final now = DateTime.now();
    return now.difference(lastActiveDate!).inDays;
  }

  /// Checks if user is considered active (used app in last 7 days)
  bool get isActiveUser {
    final daysSinceActive = daysSinceLastActive;
    return daysSinceActive == null || daysSinceActive <= 7;
  }

  /// Gets a formatted join date string
  String get joinDateFormatted {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[joinedDate.month - 1]} ${joinedDate.year}';
  }
}