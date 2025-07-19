import 'package:hive/hive.dart';
import '../domain/user_info.dart';

class UserInfoRepository {
  static const String boxName = 'user_info';
  static const String userInfoKey = 'current_user';

  /// Get the current user info
  Future<UserInfo?> getCurrentUserInfo() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    final data = box.get(userInfoKey);
    if (data != null) {
      try {
        final jsonData = Map<String, dynamic>.from(data);
        return UserInfo.fromJson(jsonData);
      } catch (e) {
        // If there's an error parsing, return null and let the app create a new user
        return null;
      }
    }
    return null;
  }

  /// Save user info
  Future<void> saveUserInfo(UserInfo userInfo) async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    await box.put(userInfoKey, userInfo.toJson());
  }

  /// Update user preferences
  Future<void> updatePreferences(UserPreferences preferences) async {
    final currentUser = await getCurrentUserInfo();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(preferences: preferences);
      await saveUserInfo(updatedUser);
    }
  }

  /// Update last active date
  Future<void> updateLastActiveDate(DateTime lastActive) async {
    final currentUser = await getCurrentUserInfo();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(lastActiveDate: lastActive);
      await saveUserInfo(updatedUser);
    }
  }

  /// Update user profile information
  Future<void> updateUserProfile({
    String? name,
    String? bio,
    String? profileImageUrl,
    List<String>? preferredLanguages,
  }) async {
    final currentUser = await getCurrentUserInfo();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        bio: bio ?? currentUser.bio,
        profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
        preferredLanguages: preferredLanguages ?? currentUser.preferredLanguages,
      );
      await saveUserInfo(updatedUser);
    }
  }

  /// Clear user info (logout)
  Future<void> clearUserInfo() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    await box.delete(userInfoKey);
  }

  /// Create or get dummy user for demo purposes
  Future<UserInfo> createDummyUser() async {
    final existingUser = await getCurrentUserInfo();
    if (existingUser != null) {
      return existingUser;
    }

    // Create a dummy user based on realistic data
    final dummyUser = UserInfo(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Alex Johnson',
      email: 'alex.johnson@example.com',
      joinedDate: DateTime.now().subtract(const Duration(days: 45)), // Joined 45 days ago
      lastActiveDate: DateTime.now().subtract(const Duration(hours: 2)), // Last active 2 hours ago
      bio: 'Passionate about learning new vocabulary and expanding my knowledge!',
      preferredLanguages: ['English', 'Spanish'],
      timezone: 'America/New_York',
      subscriptionType: UserSubscriptionType.free,
      preferences: const UserPreferences(
        enableNotifications: true,
        enableSoundEffects: true,
        enableAnimations: true,
        reminderFrequency: NotificationFrequency.daily,
        reminderTime: TimeOfDay(hour: 9, minute: 0),
        shareProgress: false,
        enableAnalytics: true,
      ),
    );

    await saveUserInfo(dummyUser);
    return dummyUser;
  }
}