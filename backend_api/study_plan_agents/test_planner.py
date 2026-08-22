"""Offline checks for study-plan mix logic (no database)."""

from study_plan_agents.planner import recommend_daily_mix
from study_plan_agents.coach import build_strategy
from study_plan_agents.incentive import build_incentives
from study_plan_agents.profile import classify_word
from datetime import datetime, timezone


def _word(name, **kwargs):
    base = {
        'word_id': hash(name) % 10000,
        'word': name,
        'category': kwargs.pop('category', 'common'),
        'difficulty': 'intermediate',
        'mnemonic': 'hint',
        'stage': 'learning',
        'is_new': False,
        'is_learning': True,
        'is_mastered': False,
        'due': False,
        'weak': False,
        'accuracy': 0.9,
        'total_answers': 4,
        'review_count': 2,
        'last_reviewed_at': None,
        'next_review': None,
    }
    base.update(kwargs)
    return base


def test_due_reviews_outrank_new_words():
    due = [_word(f'due{i}', due=True, stage='learning') for i in range(20)]
    news = [_word(f'new{i}', is_new=True, is_learning=False, stage='new', due=False) for i in range(40)]
    profile = {
        'user_id': 'u1',
        'today': '2026-08-21',
        'counts': {'new': 40, 'learning': 20, 'mastered': 0},
        'due': due,
        'weak': [],
        'new_words': news,
        'mastered': [],
        'weak_categories': [],
        'overall_accuracy': 0.8,
        'exam_kind': 'gre',
        'remaining_new': 40,
        'streak_days': 2,
        'daily_completions': [],
        'completed_today': False,
    }
    mix = recommend_daily_mix(profile, 20)
    assert mix['split']['review'] > mix['split']['new']
    assert mix['estimated_minutes'] >= 8
    strategy = build_strategy(profile, mix)
    assert 'review' in strategy['next_action'].lower() or 'due' in strategy['headline'].lower()
    incentive = build_incentives(profile, mix)
    assert incentive['daily_goal_words'] == mix['split']['review'] + mix['split']['weak'] + mix['split']['new']
    assert 'freeze' not in incentive['copy'].lower() or 'no freeze' in incentive['copy'].lower()


def test_new_student_gets_introductions():
    news = [_word(f'alpha{i}', is_new=True, is_learning=False, stage='new') for i in range(30)]
    profile = {
        'user_id': 'u2',
        'today': '2026-08-21',
        'counts': {'new': 30, 'learning': 2, 'mastered': 0},
        'due': [],
        'weak': [],
        'new_words': news,
        'mastered': [],
        'weak_categories': [],
        'overall_accuracy': 0,
        'exam_kind': None,
        'remaining_new': 30,
        'streak_days': 0,
        'daily_completions': [],
        'completed_today': False,
    }
    mix = recommend_daily_mix(profile, 15)
    assert mix['split']['new'] >= 2
    assert mix['items']


def test_classify_due_and_learned():
    now = datetime(2026, 8, 21, tzinfo=timezone.utc)
    due = classify_word({'learningStage': 'learning', 'nextReview': '2026-08-20T00:00:00Z', 'hasBeenTested': True}, now)
    assert due['due'] is True
    learned = classify_word({'isLearned': True, 'learningStage': 'newWord'}, now)
    assert learned['is_mastered'] is True
    assert learned['is_new'] is False


if __name__ == '__main__':
    test_due_reviews_outrank_new_words()
    test_new_student_gets_introductions()
    test_classify_due_and_learned()
    print('ok')
