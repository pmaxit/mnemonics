// UserProfile model with enabledWordSets support
class UserProfile {
  final String userId;
  final String vocabularyLevel; // Stores comma-separated levels like "1,2,3"
  final String learningGoal;
  final bool hasCompletedOnboarding;
  final String enabledWordSets;

  UserProfile({
    required this.userId,
    this.vocabularyLevel = '1',
    this.learningGoal = '',
    this.hasCompletedOnboarding = false,
    this.enabledWordSets = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Handle both old int and new String formats during transition
    String level = '1';
    final rawLevel = json['vocabulary_level'];
    if (rawLevel is int) {
      level = rawLevel.toString();
    } else if (rawLevel is String) {
      level = rawLevel;
    }

    return UserProfile(
      userId: json['user_id'] as String,
      vocabularyLevel: level,
      learningGoal: json['learning_goal'] as String? ?? '',
      hasCompletedOnboarding: json['has_completed_onboarding'] as bool? ?? false,
      enabledWordSets: json['enabled_word_sets'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'vocabulary_level': vocabularyLevel,
    'learning_goal': learningGoal,
    'has_completed_onboarding': hasCompletedOnboarding,
    'enabled_word_sets': enabledWordSets,
  };

  UserProfile copyWith({
    String? userId,
    String? vocabularyLevel,
    String? learningGoal,
    bool? hasCompletedOnboarding,
    String? enabledWordSets,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      vocabularyLevel: vocabularyLevel ?? this.vocabularyLevel,
      learningGoal: learningGoal ?? this.learningGoal,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      enabledWordSets: enabledWordSets ?? this.enabledWordSets,
    );
  }
}
