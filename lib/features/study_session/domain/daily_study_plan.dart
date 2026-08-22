class DailyStudyPlan {
  final String date;
  final String userId;
  final int estimatedMinutes;
  final int availableMinutes;
  final DailyPlanSplit split;
  final List<StudyPlanTrack> tracks;
  final List<StudyPlanItem> items;
  final StudyStrategy strategy;
  final StudyIncentive incentive;
  final ProfileSnapshot profileSnapshot;
  final bool completed;

  const DailyStudyPlan({
    required this.date,
    required this.userId,
    required this.estimatedMinutes,
    required this.availableMinutes,
    required this.split,
    required this.tracks,
    required this.items,
    required this.strategy,
    required this.incentive,
    required this.profileSnapshot,
    required this.completed,
  });

  factory DailyStudyPlan.fromJson(Map<String, dynamic> json) {
    return DailyStudyPlan(
      date: json['date'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 0,
      availableMinutes: (json['available_minutes'] as num?)?.toInt() ?? 20,
      split: DailyPlanSplit.fromJson(
        json['split'] as Map<String, dynamic>? ?? const {},
      ),
      tracks: (json['tracks'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => StudyPlanTrack.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => StudyPlanItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      strategy: StudyStrategy.fromJson(
        json['strategy'] as Map<String, dynamic>? ?? const {},
      ),
      incentive: StudyIncentive.fromJson(
        json['incentive'] as Map<String, dynamic>? ?? const {},
      ),
      profileSnapshot: ProfileSnapshot.fromJson(
        json['profile_snapshot'] as Map<String, dynamic>? ?? const {},
      ),
      completed: json['completed'] as bool? ?? false,
    );
  }

  List<String> get requiredWords => items
      .where((item) => item.reason != 'bonus')
      .map((item) => item.word)
      .toList();
}

class DailyPlanSplit {
  final int review;
  final int weak;
  final int newWords;
  final int bonus;

  const DailyPlanSplit({
    this.review = 0,
    this.weak = 0,
    this.newWords = 0,
    this.bonus = 0,
  });

  factory DailyPlanSplit.fromJson(Map<String, dynamic> json) {
    return DailyPlanSplit(
      review: (json['review'] as num?)?.toInt() ?? 0,
      weak: (json['weak'] as num?)?.toInt() ?? 0,
      newWords: (json['new'] as num?)?.toInt() ?? 0,
      bonus: (json['bonus'] as num?)?.toInt() ?? 0,
    );
  }
}

class StudyPlanTrack {
  final String id;
  final String title;
  final String why;
  final int priority;
  final List<StudyPlanItem> items;

  const StudyPlanTrack({
    required this.id,
    required this.title,
    required this.why,
    required this.priority,
    required this.items,
  });

  factory StudyPlanTrack.fromJson(Map<String, dynamic> json) {
    return StudyPlanTrack(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      why: json['why'] as String? ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => StudyPlanItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class StudyPlanItem {
  final int? wordId;
  final String word;
  final String reason;
  final String category;
  final String difficulty;
  final String stage;
  final double accuracy;
  final bool mnemonicHint;

  const StudyPlanItem({
    this.wordId,
    required this.word,
    required this.reason,
    this.category = '',
    this.difficulty = '',
    this.stage = '',
    this.accuracy = 0,
    this.mnemonicHint = false,
  });

  factory StudyPlanItem.fromJson(Map<String, dynamic> json) {
    return StudyPlanItem(
      wordId: (json['word_id'] as num?)?.toInt(),
      word: json['word'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      stage: json['stage'] as String? ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      mnemonicHint: json['mnemonic_hint'] as bool? ?? false,
    );
  }

  String get reasonLabel {
    switch (reason) {
      case 'due':
        return 'Due';
      case 'weak':
        return 'Weak';
      case 'new':
        return 'New';
      case 'exam':
        return 'Pace';
      case 'bonus':
        return 'Bonus';
      default:
        return reason;
    }
  }
}

class StudyStrategy {
  final String headline;
  final String howToStudy;
  final String nextAction;
  final List<String> tips;

  const StudyStrategy({
    required this.headline,
    required this.howToStudy,
    required this.nextAction,
    required this.tips,
  });

  factory StudyStrategy.fromJson(Map<String, dynamic> json) {
    return StudyStrategy(
      headline: json['headline'] as String? ?? '',
      howToStudy: json['how_to_study'] as String? ?? '',
      nextAction: json['next_action'] as String? ?? '',
      tips: (json['tips'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class StudyIncentive {
  final int streakDays;
  final int dailyGoalWords;
  final int dailyGoalMinutes;
  final int pointsIfCompleted;
  final String pointsNote;
  final StudyMilestone? nextMilestone;
  final bool completedToday;
  final String copy;

  const StudyIncentive({
    required this.streakDays,
    required this.dailyGoalWords,
    required this.dailyGoalMinutes,
    required this.pointsIfCompleted,
    required this.pointsNote,
    this.nextMilestone,
    required this.completedToday,
    required this.copy,
  });

  factory StudyIncentive.fromJson(Map<String, dynamic> json) {
    final mile = json['next_milestone'];
    return StudyIncentive(
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      dailyGoalWords: (json['daily_goal_words'] as num?)?.toInt() ?? 0,
      dailyGoalMinutes: (json['daily_goal_minutes'] as num?)?.toInt() ?? 0,
      pointsIfCompleted: (json['points_if_completed'] as num?)?.toInt() ?? 0,
      pointsNote: json['points_note'] as String? ?? '',
      nextMilestone: mile is Map
          ? StudyMilestone.fromJson(Map<String, dynamic>.from(mile))
          : null,
      completedToday: json['completed_today'] as bool? ?? false,
      copy: json['copy'] as String? ?? '',
    );
  }
}

class StudyMilestone {
  final String id;
  final String label;
  final int remaining;
  final String kind;

  const StudyMilestone({
    required this.id,
    required this.label,
    required this.remaining,
    required this.kind,
  });

  factory StudyMilestone.fromJson(Map<String, dynamic> json) {
    return StudyMilestone(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      kind: json['kind'] as String? ?? '',
    );
  }
}

class ProfileSnapshot {
  final int newCount;
  final int learningCount;
  final int masteredCount;
  final int dueCount;
  final double accuracy;
  final List<String> weakCategories;
  final String? examKind;
  final int remainingNew;

  const ProfileSnapshot({
    this.newCount = 0,
    this.learningCount = 0,
    this.masteredCount = 0,
    this.dueCount = 0,
    this.accuracy = 0,
    this.weakCategories = const [],
    this.examKind,
    this.remainingNew = 0,
  });

  factory ProfileSnapshot.fromJson(Map<String, dynamic> json) {
    return ProfileSnapshot(
      newCount: (json['new'] as num?)?.toInt() ?? 0,
      learningCount: (json['learning'] as num?)?.toInt() ?? 0,
      masteredCount: (json['mastered'] as num?)?.toInt() ?? 0,
      dueCount: (json['due'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      weakCategories: (json['weak_categories'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      examKind: json['exam_kind'] as String?,
      remainingNew: (json['remaining_new'] as num?)?.toInt() ?? 0,
    );
  }
}
