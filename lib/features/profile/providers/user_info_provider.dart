import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_info.dart';
import '../infrastructure/user_info_repository.dart';

final userInfoRepositoryProvider = Provider<UserInfoRepository>((ref) {
  return UserInfoRepository();
});

final currentUserProvider = FutureProvider<UserInfo>((ref) async {
  final repository = ref.watch(userInfoRepositoryProvider);

  // Try to get existing user, if none exists, create dummy user
  final existingUser = await repository.getCurrentUserInfo();
  if (existingUser != null) {
    // Update last active date when user info is accessed
    await repository.updateLastActiveDate(DateTime.now());
    return existingUser;
  }

  // Create dummy user if none exists
  return await repository.createDummyUser();
});

final userInfoNotifierProvider =
    AsyncNotifierProvider<UserInfoNotifier, UserInfo>(() {
  return UserInfoNotifier();
});

class UserInfoNotifier extends AsyncNotifier<UserInfo> {
  UserInfoRepository get _repository => ref.read(userInfoRepositoryProvider);

  @override
  Future<UserInfo> build() async {
    // Initialize with current user or create dummy user
    final repository = ref.watch(userInfoRepositoryProvider);
    final existingUser = await repository.getCurrentUserInfo();

    if (existingUser != null) {
      // Update last active date
      await repository.updateLastActiveDate(DateTime.now());
      return existingUser;
    }

    return await repository.createDummyUser();
  }

  /// Update user profile information
  Future<void> updateProfile({
    String? name,
    String? bio,
    String? profileImageUrl,
    List<String>? preferredLanguages,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _repository.updateUserProfile(
        name: name,
        bio: bio,
        profileImageUrl: profileImageUrl,
        preferredLanguages: preferredLanguages,
      );

      final updatedUser = await _repository.getCurrentUserInfo();
      if (updatedUser != null) {
        state = AsyncValue.data(updatedUser);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update user preferences
  Future<void> updatePreferences(UserPreferences preferences) async {
    state = const AsyncValue.loading();

    try {
      await _repository.updatePreferences(preferences);

      final updatedUser = await _repository.getCurrentUserInfo();
      if (updatedUser != null) {
        state = AsyncValue.data(updatedUser);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? enableNotifications,
    NotificationFrequency? reminderFrequency,
    TimeOfDay? reminderTime,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedPreferences = currentUser.preferences.copyWith(
      enableNotifications:
          enableNotifications ?? currentUser.preferences.enableNotifications,
      reminderFrequency:
          reminderFrequency ?? currentUser.preferences.reminderFrequency,
      reminderTime: reminderTime ?? currentUser.preferences.reminderTime,
    );

    await updatePreferences(updatedPreferences);
  }

  /// Update UI preferences
  Future<void> updateUIPreferences({
    bool? enableSoundEffects,
    bool? enableAnimations,
    bool? shareProgress,
    bool? enableAnalytics,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    final updatedPreferences = currentUser.preferences.copyWith(
      enableSoundEffects:
          enableSoundEffects ?? currentUser.preferences.enableSoundEffects,
      enableAnimations:
          enableAnimations ?? currentUser.preferences.enableAnimations,
      shareProgress: shareProgress ?? currentUser.preferences.shareProgress,
      enableAnalytics:
          enableAnalytics ?? currentUser.preferences.enableAnalytics,
    );

    await updatePreferences(updatedPreferences);
  }

  /// Mark user as active (call this when user interacts with the app)
  Future<void> markUserActive() async {
    try {
      await _repository.updateLastActiveDate(DateTime.now());

      final currentUser = state.value;
      if (currentUser != null) {
        final updatedUser =
            currentUser.copyWith(lastActiveDate: DateTime.now());
        state = AsyncValue.data(updatedUser);
      }
    } catch (error) {
      // Don't update state for this error to avoid disrupting the UI
      // Just log or handle silently
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _repository.clearUserInfo();
      // After logout, create a new dummy user
      final newUser = await _repository.createDummyUser();
      state = AsyncValue.data(newUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh user data
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.getCurrentUserInfo();
      if (user != null) {
        state = AsyncValue.data(user);
      } else {
        final newUser = await _repository.createDummyUser();
        state = AsyncValue.data(newUser);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
