import 'package:freezed_annotation/freezed_annotation.dart';
import 'study_plan_day.dart';

part 'study_plan.freezed.dart';
part 'study_plan.g.dart';

/// Difficulty preference for the study plan curve.
enum DifficultyPref {
  @JsonValue('easy_start')
  easyStart,
  @JsonValue('balanced')
  balanced,
  @JsonValue('challenging')
  challenging,
}

/// Daily commitment level chosen by the user.
enum DailyCommitment {
  @JsonValue('light')
  light,
  @JsonValue('standard')
  standard,
  @JsonValue('intensive')
  intensive,
}

@freezed
class StudyPlan with _$StudyPlan {
  const factory StudyPlan({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    @JsonKey(name: 'total_words') required int totalWords,
    @JsonKey(name: 'num_days') required int numDays,
    @JsonKey(name: 'words_per_day') required int wordsPerDay,
    @JsonKey(name: 'start_date') required String startDate,
    @Default('active') String status,
    @Default(<StudyPlanDay>[]) List<StudyPlanDay> days,
    @JsonKey(name: 'total_xp') @Default(0) int totalXp,
    @JsonKey(name: 'difficulty_pref') @Default('balanced') String difficultyPref,
    @JsonKey(name: 'daily_commitment') @Default('standard') String dailyCommitment,
  }) = _StudyPlan;

  factory StudyPlan.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanFromJson(json);

  const StudyPlan._();

  /// Computed: number of completed days
  int get completedDays =>
      days.where((d) => d.status == DayStatus.done).length;

  /// Computed: number of in-progress days
  int get inProgressDays =>
      days.where((d) => d.status == DayStatus.inProgress).length;

  /// Computed: overall progress 0.0–1.0 (day-based)
  double get progress =>
      numDays > 0 ? completedDays / numDays : 0.0;

  /// Unique words across all days (review days may repeat words).
  Set<String> get uniqueWords => days.expand((d) => d.words).toSet();

  /// Number of unique plan words that are learned, given the set of words
  /// the user has marked as learned. Words belonging to completed days
  /// always count as learned.
  int learnedWordCount(Set<String> learnedWords) {
    final doneWords = days
        .where((d) => d.status == DayStatus.done)
        .expand((d) => d.words)
        .toSet();
    return uniqueWords
        .where((w) => learnedWords.contains(w) || doneWords.contains(w))
        .length;
  }

  /// Word-level overall progress 0.0–1.0: the fraction of the plan's unique
  /// words the user has learned. Falls back to day-based [progress] when the
  /// plan carries no day data.
  double wordProgress(Set<String> learnedWords) {
    final words = uniqueWords;
    if (words.isEmpty) return progress;
    return (learnedWordCount(learnedWords) / words.length).clamp(0.0, 1.0);
  }

  /// Computed: XP earned so far (sum of xp for completed days)
  int get earnedXp =>
      days
          .where((d) => d.status == DayStatus.done)
          .fold(0, (sum, d) => sum + d.xpValue);

  /// Computed: current streak (consecutive completed days from day 1)
  int get streak {
    var s = 0;
    for (final d in days) {
      if (d.status == DayStatus.done) {
        s++;
      } else {
        break;
      }
    }
    return s;
  }

  /// Badges unlocked based on progress
  List<PlanBadge> get unlockedBadges {
    final badges = <PlanBadge>[];
    if (completedDays >= 1) badges.add(PlanBadge.firstSteps);
    if (streak >= 3) badges.add(PlanBadge.onFire);
    if (streak >= 7) badges.add(PlanBadge.weekWarrior);
    if (progress >= 0.5) badges.add(PlanBadge.halfway);
    if (completedDays == numDays && numDays > 0) badges.add(PlanBadge.champion);
    if (earnedXp >= 100) badges.add(PlanBadge.xpHunter);
    if (earnedXp >= 500) badges.add(PlanBadge.xpMaster);
    return badges;
  }
}

/// Gamification badges for study plans
enum PlanBadge {
  firstSteps('🎯', 'First Steps', 'Complete your first day'),
  onFire('🔥', 'On Fire', '3-day streak'),
  weekWarrior('⚔️', 'Week Warrior', '7-day streak'),
  halfway('🏔️', 'Halfway There', '50% complete'),
  champion('👑', 'Champion', 'Complete the entire plan'),
  xpHunter('⭐', 'XP Hunter', 'Earn 100 XP'),
  xpMaster('🏆', 'XP Master', 'Earn 500 XP');

  const PlanBadge(this.emoji, this.title, this.description);
  final String emoji;
  final String title;
  final String description;
}
