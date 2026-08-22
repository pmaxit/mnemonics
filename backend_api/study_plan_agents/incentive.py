"""Incentive agent: goals, streaks, and milestones without dark patterns."""

from __future__ import annotations

from datetime import date


MILESTONES = (
    {'id': 'streak_3', 'kind': 'streak', 'threshold': 3, 'label': '3-day streak'},
    {'id': 'streak_7', 'kind': 'streak', 'threshold': 7, 'label': '7-day streak'},
    {'id': 'streak_14', 'kind': 'streak', 'threshold': 14, 'label': '14-day streak'},
    {'id': 'streak_30', 'kind': 'streak', 'threshold': 30, 'label': '30-day streak'},
    {'id': 'words_50', 'kind': 'mastered', 'threshold': 50, 'label': '50 words in motion'},
    {'id': 'words_100', 'kind': 'mastered', 'threshold': 100, 'label': '100 words learned'},
    {'id': 'words_250', 'kind': 'mastered', 'threshold': 250, 'label': '250-word GRE core'},
)


def _points(split: dict) -> int:
    return (
        int(split.get('review') or 0) * 10
        + int(split.get('weak') or 0) * 12
        + int(split.get('new') or 0) * 15
        + int(split.get('bonus') or 0) * 5
        + 25  # completion bonus, granted only when they finish
    )


def build_incentives(profile: dict, mix: dict) -> dict:
    split = mix.get('split') or {}
    counts = profile.get('counts') or {}
    streak = int(profile.get('streak_days') or 0)
    mastered = int(counts.get('mastered') or 0) + int(counts.get('learning') or 0)
    goal_words = sum(split.values()) if split else 0
    # Bonus track is optional — daily goal excludes it.
    goal_words = max(0, goal_words - int(split.get('bonus') or 0))
    points = _points(split)

    next_milestone = None
    for mile in MILESTONES:
        current = streak if mile['kind'] == 'streak' else mastered
        if current < mile['threshold']:
            next_milestone = {
                'id': mile['id'],
                'label': mile['label'],
                'remaining': mile['threshold'] - current,
                'kind': mile['kind'],
            }
            break

    today = date.fromisoformat(profile['today']) if profile.get('today') else date.today()
    completions = {date.fromisoformat(d) for d in (profile.get('daily_completions') or []) if d}
    completed_today = profile.get('completed_today') or today in completions

    copy = _copy(streak, completed_today, goal_words, next_milestone)
    return {
        'streak_days': streak,
        'streak_protected_if_done_today': True,
        'uses_streak_freeze': False,
        'daily_goal_words': goal_words,
        'daily_goal_minutes': mix.get('estimated_minutes') or mix.get('available_minutes'),
        'points_if_completed': points,
        'points_note': 'Points mark finished retrieval, not a leaderboard. The optional bonus word is extra.',
        'next_milestone': next_milestone,
        'completed_today': bool(completed_today),
        'copy': copy,
    }


def _copy(streak: int, completed_today: bool, goal_words: int, milestone: dict | None) -> str:
    if completed_today:
        if streak:
            return f'Today is done. Your {streak}-day streak is already counted.'
        return 'Today is done. Come back tomorrow for a fresh mix — no penalty for rest days beyond losing a count.'
    if streak == 0:
        return f'Finish {goal_words} words to start a streak. Missing a day only resets the count — nothing is locked.'
    if milestone and milestone.get('kind') == 'streak' and milestone.get('remaining') == 1:
        return f'One more complete day unlocks {milestone["label"]}. Skipping only resets the streak number.'
    return (
        f'Keep a {streak}-day streak by finishing today\'s {goal_words} words. '
        'There is no freeze or paywall — just an honest count of consecutive study days.'
    )
