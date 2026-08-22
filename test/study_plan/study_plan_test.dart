import 'package:flutter_test/flutter_test.dart';
import 'package:mnemonics/features/study_session/domain/study_plan.dart';
import 'package:mnemonics/features/study_session/domain/study_plan_day.dart';

void main() {
  group('StudyPlan gamification metrics', () {
    test('completedDays counts only done days', () {
      final plan = StudyPlan(
        id: 'test1',
        userId: 'u1',
        title: 'Test Plan',
        totalWords: 50,
        numDays: 10,
        wordsPerDay: 5,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a', 'b', 'c'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 2, words: ['d', 'e', 'f'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 3, words: ['g', 'h', 'i'], status: DayStatus.inProgress),
          StudyPlanDay(dayNumber: 4, words: ['j', 'k', 'l'], status: DayStatus.notAttempted),
        ],
      );

      expect(plan.completedDays, 2);
      expect(plan.inProgressDays, 1);
      expect(plan.progress, 0.2);
    });

    test('wordProgress reflects learned words before any day is done', () {
      final plan = StudyPlan(
        id: 'test-word-progress',
        userId: 'u1',
        title: 'Test Plan',
        totalWords: 4,
        numDays: 2,
        wordsPerDay: 2,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a', 'b'], status: DayStatus.inProgress),
          StudyPlanDay(dayNumber: 2, words: ['c', 'd'], status: DayStatus.notAttempted),
        ],
      );

      // One word learned out of four → 25%, even though no day is done yet.
      expect(plan.progress, 0.0);
      expect(plan.learnedWordCount({'a'}), 1);
      expect(plan.wordProgress({'a'}), 0.25);
    });

    test('words on completed days always count as learned', () {
      final plan = StudyPlan(
        id: 'test-done-days',
        userId: 'u1',
        title: 'Test Plan',
        totalWords: 4,
        numDays: 2,
        wordsPerDay: 2,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a', 'b'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 2, words: ['c', 'd'], status: DayStatus.notAttempted),
        ],
      );

      expect(plan.learnedWordCount(<String>{}), 2);
      expect(plan.wordProgress(<String>{'c'}), 0.75);
      // All words learned → 100%.
      expect(plan.wordProgress({'a', 'b', 'c', 'd'}), 1.0);
    });

    test('uniqueWords dedupes words repeated on review days', () {
      final plan = StudyPlan(
        id: 'test-dedupe',
        userId: 'u1',
        title: 'Test Plan',
        totalWords: 4,
        numDays: 4,
        wordsPerDay: 2,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a', 'b'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 2, words: ['c', 'd'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 3, words: ['a', 'c'], status: DayStatus.notAttempted),
        ],
      );

      expect(plan.uniqueWords, {'a', 'b', 'c', 'd'});
      expect(plan.learnedWordCount(<String>{}), 4);
      expect(plan.wordProgress(<String>{}), 1.0);
    });

    test('wordProgress falls back to day-based progress without day data', () {
      final plan = StudyPlan(
        id: 'test-fallback',
        userId: 'u1',
        title: 'Test Plan',
        totalWords: 4,
        numDays: 2,
        wordsPerDay: 2,
        startDate: '2026-01-01',
        days: const [],
      );

      expect(plan.wordProgress({'a'}), 0.0);
    });

    test('earnedXp sums XP for completed days', () {
      final plan = StudyPlan(
        id: 'test2',
        userId: 'u1',
        title: 'Test Plan',
        totalWords: 30,
        numDays: 5,
        wordsPerDay: 6,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a'], status: DayStatus.done, xpValue: 20),
          StudyPlanDay(dayNumber: 2, words: ['b'], status: DayStatus.done, xpValue: 15),
          StudyPlanDay(dayNumber: 3, words: ['c'], status: DayStatus.inProgress, xpValue: 10),
          StudyPlanDay(dayNumber: 4, words: ['d'], status: DayStatus.notAttempted, xpValue: 10),
          StudyPlanDay(dayNumber: 5, words: ['e'], status: DayStatus.notAttempted, xpValue: 10),
        ],
      );

      expect(plan.earnedXp, 35); // 20 + 15
    });

    test('streak counts consecutive completed days from day 1', () {
      final plan = StudyPlan(
        id: 'test3',
        userId: 'u1',
        title: 'Test Plan',
        totalWords: 50,
        numDays: 7,
        wordsPerDay: 7,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 2, words: ['b'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 3, words: ['c'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 4, words: ['d'], status: DayStatus.inProgress),
          StudyPlanDay(dayNumber: 5, words: ['e'], status: DayStatus.notAttempted),
        ],
      );

      expect(plan.streak, 3);
    });

    test('streak is 0 if first day is not done', () {
      final plan = StudyPlan(
        id: 'test4',
        userId: 'u1',
        title: 'Test Plan',
        totalWords: 50,
        numDays: 7,
        wordsPerDay: 7,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a'], status: DayStatus.inProgress),
          StudyPlanDay(dayNumber: 2, words: ['b'], status: DayStatus.done),
        ],
      );

      expect(plan.streak, 0);
    });

    test('badges unlock at correct milestones', () {
      // 1 day done → First Steps
      final plan1 = StudyPlan(
        id: 'test5',
        userId: 'u1',
        title: 'Test',
        totalWords: 10,
        numDays: 10,
        wordsPerDay: 1,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a'], status: DayStatus.done),
        ],
      );
      expect(plan1.unlockedBadges.contains(PlanBadge.firstSteps), true);

      // 3-day streak → On Fire
      final plan3 = StudyPlan(
        id: 'test6',
        userId: 'u1',
        title: 'Test',
        totalWords: 10,
        numDays: 10,
        wordsPerDay: 1,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 2, words: ['b'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 3, words: ['c'], status: DayStatus.done),
        ],
      );
      expect(plan3.unlockedBadges.contains(PlanBadge.onFire), true);

      // 50% complete → Halfway
      final planHalf = StudyPlan(
        id: 'test7',
        userId: 'u1',
        title: 'Test',
        totalWords: 10,
        numDays: 4,
        wordsPerDay: 2,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 2, words: ['b'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 3, words: ['c'], status: DayStatus.notAttempted),
          StudyPlanDay(dayNumber: 4, words: ['d'], status: DayStatus.notAttempted),
        ],
      );
      expect(planHalf.unlockedBadges.contains(PlanBadge.halfway), true);

      // 100% complete → Champion
      final planDone = StudyPlan(
        id: 'test8',
        userId: 'u1',
        title: 'Test',
        totalWords: 6,
        numDays: 3,
        wordsPerDay: 2,
        startDate: '2026-01-01',
        days: [
          StudyPlanDay(dayNumber: 1, words: ['a'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 2, words: ['b'], status: DayStatus.done),
          StudyPlanDay(dayNumber: 3, words: ['c'], status: DayStatus.done),
        ],
      );
      expect(planDone.unlockedBadges.contains(PlanBadge.champion), true);
    });

    test('PlanBadge has emoji, title, and description', () {
      for (final badge in PlanBadge.values) {
        expect(badge.emoji.isNotEmpty, true);
        expect(badge.title.isNotEmpty, true);
        expect(badge.description.isNotEmpty, true);
      }
    });
  });

  group('StudyPlanDay', () {
    test('isReviewDay is true for day 4, 8, 12', () {
      expect(StudyPlanDay(dayNumber: 4, words: []).isReviewDay, true);
      expect(StudyPlanDay(dayNumber: 8, words: []).isReviewDay, true);
      expect(StudyPlanDay(dayNumber: 12, words: []).isReviewDay, true);
    });

    test('isReviewDay is false for day 1, 2, 3, 5', () {
      expect(StudyPlanDay(dayNumber: 1, words: []).isReviewDay, false);
      expect(StudyPlanDay(dayNumber: 2, words: []).isReviewDay, false);
      expect(StudyPlanDay(dayNumber: 3, words: []).isReviewDay, false);
      expect(StudyPlanDay(dayNumber: 5, words: []).isReviewDay, false);
    });

    test('dayLabel shows "Review Day" for review days', () {
      expect(StudyPlanDay(dayNumber: 4, words: []).dayLabel, 'Review Day 4');
      expect(StudyPlanDay(dayNumber: 1, words: []).dayLabel, 'Day 1');
    });

    test('default xpValue is 10', () {
      expect(StudyPlanDay(dayNumber: 1, words: []).xpValue, 10);
    });

    test('from json includes xpValue', () {
      final json = {
        'day_number': 1,
        'words': ['hello', 'world'],
        'status': 'not_attempted',
        'xp_value': 25,
      };
      final day = StudyPlanDay.fromJson(json);
      expect(day.xpValue, 25);
      expect(day.dayNumber, 1);
      expect(day.words, ['hello', 'world']);
    });
  });

  group('StudyPlan JSON serialization', () {
    test('fromJson parses all fields including gamification', () {
      final json = {
        'id': 'plan123',
        'user_id': 'user456',
        'title': 'GRE Mastery',
        'total_words': 200,
        'num_days': 30,
        'words_per_day': 7,
        'start_date': '2026-01-01',
        'status': 'active',
        'total_xp': 500,
        'difficulty_pref': 'challenging',
        'daily_commitment': 'intensive',
        'days': [],
      };
      final plan = StudyPlan.fromJson(json);
      expect(plan.id, 'plan123');
      expect(plan.title, 'GRE Mastery');
      expect(plan.totalXp, 500);
      expect(plan.difficultyPref, 'challenging');
      expect(plan.dailyCommitment, 'intensive');
    });
  });
}
