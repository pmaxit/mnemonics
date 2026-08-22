"""Orchestrator: researcher → planner → coach → incentive."""

from __future__ import annotations

from datetime import date, datetime, timezone

from .coach import build_strategy
from .incentive import build_incentives
from .planner import recommend_daily_mix
from .profile import load_student_profile


def ensure_daily_completion_table(cursor) -> None:
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS study_plan_daily_completions (
            user_id VARCHAR(128) NOT NULL,
            completed_on DATE NOT NULL,
            words_completed INTEGER DEFAULT 0,
            points INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (user_id, completed_on)
        )
        """
    )


def generate_daily_plan(cursor, user_id: str, available_minutes: int = 20) -> dict:
    ensure_daily_completion_table(cursor)
    profile = load_student_profile(cursor, user_id)
    mix = recommend_daily_mix(profile, available_minutes)
    strategy = build_strategy(profile, mix)
    incentive = build_incentives(profile, mix)

    snapshot = {
        'new': profile['counts'].get('new', 0),
        'learning': profile['counts'].get('learning', 0),
        'mastered': profile['counts'].get('mastered', 0),
        'due': len(profile.get('due') or []),
        'accuracy': profile.get('overall_accuracy'),
        'weak_categories': [c['category'] for c in (profile.get('weak_categories') or [])],
        'exam_kind': profile.get('exam_kind'),
        'remaining_new': profile.get('remaining_new'),
    }

    return {
        'date': profile['today'],
        'user_id': user_id,
        'estimated_minutes': mix['estimated_minutes'],
        'available_minutes': mix['available_minutes'],
        'split': mix['split'],
        'tracks': mix['tracks'],
        'items': mix['items'],
        'strategy': strategy,
        'incentive': incentive,
        'profile_snapshot': snapshot,
        'completed': incentive.get('completed_today', False),
        'generated_at': datetime.now(timezone.utc).isoformat(),
    }


def mark_daily_plan_complete(cursor, user_id: str, words_completed: int = 0, points: int = 0) -> dict:
    ensure_daily_completion_table(cursor)
    today = date.today()
    cursor.execute(
        """
        INSERT INTO study_plan_daily_completions (user_id, completed_on, words_completed, points)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (user_id, completed_on) DO UPDATE
        SET words_completed = EXCLUDED.words_completed,
            points = EXCLUDED.points
        """,
        (user_id, today, int(words_completed or 0), int(points or 0)),
    )
    return {
        'user_id': user_id,
        'completed_on': today.isoformat(),
        'words_completed': int(words_completed or 0),
        'points': int(points or 0),
        'status': 'completed',
    }
