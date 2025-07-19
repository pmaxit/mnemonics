import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_info_provider.dart';
import '../domain/user_info.dart';

final userActivityTrackerProvider = Provider<UserActivityTracker>((ref) {
  return UserActivityTracker(ref);
});

class UserActivityTracker {
  final Ref _ref;
  
  UserActivityTracker(this._ref);

  /// Track user activity when they open the app
  Future<void> trackAppOpen() async {
    final notifier = _ref.read(userInfoNotifierProvider.notifier);
    await notifier.markUserActive();
  }

  /// Track user activity when they complete a learning session
  Future<void> trackLearningSession() async {
    final notifier = _ref.read(userInfoNotifierProvider.notifier);
    await notifier.markUserActive();
  }

  /// Track user activity when they review words
  Future<void> trackWordReview() async {
    final notifier = _ref.read(userInfoNotifierProvider.notifier);
    await notifier.markUserActive();
  }

  /// Track user activity when they complete a timer session
  Future<void> trackTimerSession() async {
    final notifier = _ref.read(userInfoNotifierProvider.notifier);
    await notifier.markUserActive();
  }

  /// Track user activity when they change settings
  Future<void> trackSettingsChange() async {
    final notifier = _ref.read(userInfoNotifierProvider.notifier);
    await notifier.markUserActive();
  }

  /// Check if user should be encouraged to continue learning
  Future<bool> shouldShowEngagementPrompt() async {
    final userInfoAsync = _ref.read(currentUserProvider);
    return userInfoAsync.when(
      data: (userInfo) {
        final daysSinceLastActive = userInfo.daysSinceLastActive;
        // Show engagement prompt if user hasn't been active for 3+ days
        return daysSinceLastActive != null && daysSinceLastActive >= 3;
      },
      loading: () => false,
      error: (error, stack) => false,
    );
  }

  /// Get user engagement level based on activity
  Future<UserEngagementLevel> getUserEngagementLevel() async {
    final userInfoAsync = _ref.read(currentUserProvider);
    return userInfoAsync.when(
      data: (userInfo) {
        final daysSinceLastActive = userInfo.daysSinceLastActive;
        
        if (daysSinceLastActive == null || daysSinceLastActive == 0) {
          return UserEngagementLevel.high;
        } else if (daysSinceLastActive <= 2) {
          return UserEngagementLevel.medium;
        } else if (daysSinceLastActive <= 7) {
          return UserEngagementLevel.low;
        } else {
          return UserEngagementLevel.inactive;
        }
      },
      loading: () => UserEngagementLevel.unknown,
      error: (error, stack) => UserEngagementLevel.unknown,
    );
  }

  /// Get personalized welcome message based on activity
  Future<String> getPersonalizedWelcomeMessage() async {
    final userInfoAsync = _ref.read(currentUserProvider);
    return userInfoAsync.when(
      data: (userInfo) {
        final daysSinceLastActive = userInfo.daysSinceLastActive;
        final firstName = userInfo.displayName.split(' ').first;
        
        if (daysSinceLastActive == null || daysSinceLastActive == 0) {
          return 'Welcome back, $firstName!';
        } else if (daysSinceLastActive == 1) {
          return 'Good to see you again, $firstName!';
        } else if (daysSinceLastActive <= 3) {
          return 'Welcome back, $firstName! Ready to continue learning?';
        } else if (daysSinceLastActive <= 7) {
          return 'Hey $firstName! It\'s been a while. Let\'s get back to learning!';
        } else {
          return 'Welcome back, $firstName! We\'ve missed you!';
        }
      },
      loading: () => 'Welcome back!',
      error: (error, stack) => 'Welcome back!',
    );
  }

  /// Get suggested action based on user activity
  Future<String> getSuggestedAction() async {
    final userInfoAsync = _ref.read(currentUserProvider);
    return userInfoAsync.when(
      data: (userInfo) {
        final daysSinceLastActive = userInfo.daysSinceLastActive;
        
        if (daysSinceLastActive == null || daysSinceLastActive == 0) {
          return 'Continue your learning streak!';
        } else if (daysSinceLastActive <= 2) {
          return 'Keep up the great work!';
        } else if (daysSinceLastActive <= 7) {
          return 'Let\'s rebuild your learning habit!';
        } else {
          return 'Start with a quick 5-minute session!';
        }
      },
      loading: () => 'Start learning!',
      error: (error, stack) => 'Start learning!',
    );
  }
}

enum UserEngagementLevel {
  high,
  medium,
  low,
  inactive,
  unknown,
}

extension UserEngagementLevelExtension on UserEngagementLevel {
  String get displayName {
    switch (this) {
      case UserEngagementLevel.high:
        return 'Highly Engaged';
      case UserEngagementLevel.medium:
        return 'Moderately Engaged';
      case UserEngagementLevel.low:
        return 'Low Engagement';
      case UserEngagementLevel.inactive:
        return 'Inactive';
      case UserEngagementLevel.unknown:
        return 'Unknown';
    }
  }

  String get description {
    switch (this) {
      case UserEngagementLevel.high:
        return 'Active daily learner';
      case UserEngagementLevel.medium:
        return 'Regular learner';
      case UserEngagementLevel.low:
        return 'Occasional learner';
      case UserEngagementLevel.inactive:
        return 'Needs re-engagement';
      case UserEngagementLevel.unknown:
        return 'Activity unknown';
    }
  }
}