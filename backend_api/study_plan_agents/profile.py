"""Researcher agent: assemble a student profile from existing tables."""

from __future__ import annotations

from datetime import date, datetime, timezone
from typing import Any


def _parse_dt(value: Any) -> datetime | None:
    if value is None:
        return None
    if isinstance(value, datetime):
        return value if value.tzinfo else value.replace(tzinfo=timezone.utc)
    if isinstance(value, date) and not isinstance(value, datetime):
        return datetime(value.year, value.month, value.day, tzinfo=timezone.utc)
    if isinstance(value, str):
        text = value.strip()
        if not text:
            return None
        try:
            parsed = datetime.fromisoformat(text.replace('Z', '+00:00'))
        except ValueError:
            return None
        return parsed if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)
    return None


def _as_int(value: Any, default: int = 0) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _as_float(value: Any, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _as_bool(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        return value.lower() in {'true', '1', 'yes'}
    return bool(value)


def _progress_dict(raw: Any) -> dict:
    if raw is None:
        return {}
    if isinstance(raw, dict):
        return raw
    if isinstance(raw, str):
        import json
        try:
            parsed = json.loads(raw)
            return parsed if isinstance(parsed, dict) else {}
        except (TypeError, ValueError):
            return {}
    return {}


def classify_word(progress: dict, now: datetime) -> dict:
    """Map Hive/API progress JSON onto SRS buckets used by the planner."""
    stage = str(progress.get('learningStage') or progress.get('learning_stage') or 'newWord')
    is_learned = _as_bool(progress.get('isLearned') if 'isLearned' in progress else progress.get('is_learned'))
    has_been_tested = _as_bool(progress.get('hasBeenTested') if 'hasBeenTested' in progress else progress.get('has_been_tested'))
    review_count = _as_int(progress.get('reviewCount') or progress.get('review_count'))
    correct = _as_int(progress.get('correctAnswers') or progress.get('correct_answers'))
    total = _as_int(progress.get('totalAnswers') or progress.get('total_answers'))
    next_review = _parse_dt(progress.get('nextReview') or progress.get('next_review'))
    last_reviewed = _parse_dt(progress.get('lastReviewedAt') or progress.get('last_reviewed_at'))
    accuracy = (correct / total) if total > 0 else 0.0

    is_mastered = (
        stage == 'mastered'
        or (is_learned and accuracy >= 0.8 and total >= 3)
        or (is_learned and total == 0 and not has_been_tested)
    )
    is_learning = (stage == 'learning' or has_been_tested or review_count > 0) and not is_mastered
    is_new = not is_learning and not is_mastered and not has_been_tested and review_count == 0

    due = False
    if next_review is not None:
        due = next_review <= now
    elif is_learning and last_reviewed is not None:
        due = (now - last_reviewed).days >= 1
    elif is_learning:
        due = True

    weak = (total >= 2 and accuracy < 0.7) or (is_learning and accuracy < 0.75 and total >= 1)

    return {
        'stage': 'mastered' if is_mastered else ('learning' if is_learning else 'new'),
        'is_new': is_new,
        'is_learning': is_learning,
        'is_mastered': is_mastered,
        'due': due and not is_new,
        'weak': weak and not is_new,
        'accuracy': round(accuracy, 3),
        'total_answers': total,
        'review_count': review_count,
        'last_reviewed_at': last_reviewed.isoformat() if last_reviewed else None,
        'next_review': next_review.isoformat() if next_review else None,
    }


def load_student_profile(cursor, user_id: str, now: datetime | None = None) -> dict:
    now = now or datetime.now(timezone.utc)
    today = now.date()

    cursor.execute(
        """
        SELECT user_id, vocabulary_level, learning_goal, has_completed_onboarding
        FROM user_profiles
        WHERE user_id = %s
        """,
        (user_id,),
    )
    profile_row = cursor.fetchone() or {}
    learning_goal = str(profile_row.get('learning_goal') or '').strip().lower()
    vocab_level = str(profile_row.get('vocabulary_level') or '1')

    cursor.execute(
        "SELECT word FROM user_learned_words WHERE user_id = %s AND is_learned = TRUE",
        (user_id,),
    )
    learned = {row['word'] for row in cursor.fetchall() if row.get('word')}

    cursor.execute(
        "SELECT word, progress_data FROM user_word_progress WHERE user_id = %s",
        (user_id,),
    )
    progress_rows = cursor.fetchall()

    cursor.execute(
        """
        SELECT id, word, category, difficulty, mnemonic
        FROM vocabulary
        ORDER BY word ASC
        """
    )
    vocab_rows = cursor.fetchall()

    cursor.execute(
        """
        SELECT DISTINCT DATE(spd.done_at) AS done_day
        FROM study_plan_days spd
        JOIN study_plans sp ON sp.id = spd.plan_id
        WHERE sp.user_id = %s AND spd.status = 'done' AND spd.done_at IS NOT NULL
        """,
        (user_id,),
    )
    plan_done_days = {
        row['done_day'] if isinstance(row['done_day'], date) else _parse_dt(row['done_day']).date()
        for row in cursor.fetchall()
        if row.get('done_day')
    }

    cursor.execute(
        """
        SELECT completed_on FROM study_plan_daily_completions
        WHERE user_id = %s
        ORDER BY completed_on DESC
        """,
        (user_id,),
    )
    daily_completions = []
    for row in cursor.fetchall():
        value = row.get('completed_on')
        if isinstance(value, date):
            daily_completions.append(value)
        else:
            parsed = _parse_dt(value)
            if parsed:
                daily_completions.append(parsed.date())

    progress_by_word = {}
    for row in progress_rows:
        word = row.get('word')
        if word:
            progress_by_word[word] = _progress_dict(row.get('progress_data'))

    words = []
    counts = {'new': 0, 'learning': 0, 'mastered': 0}
    due = []
    weak = []
    new_words = []
    mastered = []
    category_stats: dict[str, dict[str, float]] = {}
    active_days: set[date] = set(plan_done_days)
    reviewed_today = 0
    correct_sum = 0
    total_sum = 0

    for row in vocab_rows:
        word = row.get('word')
        if not word:
            continue
        raw = dict(progress_by_word.get(word) or {})
        if word in learned and 'isLearned' not in raw:
            raw['isLearned'] = True
        classified = classify_word(raw, now)
        item = {
            'word_id': row.get('id'),
            'word': word,
            'category': row.get('category') or 'common',
            'difficulty': row.get('difficulty') or 'intermediate',
            'mnemonic': (row.get('mnemonic') or '').strip(),
            **classified,
        }
        words.append(item)
        counts[classified['stage']] = counts.get(classified['stage'], 0) + 1
        if classified['due']:
            due.append(item)
        if classified['weak']:
            weak.append(item)
        if classified['is_new']:
            new_words.append(item)
        if classified['is_mastered']:
            mastered.append(item)

        cat = item['category']
        bucket = category_stats.setdefault(cat, {'correct': 0, 'total': 0, 'learning': 0})
        bucket['correct'] += _as_int(raw.get('correctAnswers') or raw.get('correct_answers'))
        bucket['total'] += _as_int(raw.get('totalAnswers') or raw.get('total_answers'))
        if classified['is_learning'] or classified['weak']:
            bucket['learning'] += 1

        correct_sum += _as_int(raw.get('correctAnswers') or raw.get('correct_answers'))
        total_sum += _as_int(raw.get('totalAnswers') or raw.get('total_answers'))

        last_reviewed = _parse_dt(raw.get('lastReviewedAt') or raw.get('last_reviewed_at'))
        if last_reviewed:
            active_days.add(last_reviewed.date())
            if last_reviewed.date() == today:
                reviewed_today += 1

    weak_categories = []
    for name, stats in category_stats.items():
        total = stats['total']
        if total < 3:
            continue
        accuracy = stats['correct'] / total
        if accuracy < 0.75 or stats['learning'] >= 3:
            weak_categories.append({
                'category': name,
                'accuracy': round(accuracy, 3),
                'sample': int(total),
            })
    weak_categories.sort(key=lambda c: (c['accuracy'], -c['sample']))

    streak = 0
    cursor_day = today
    # Allow yesterday to keep the streak if the student has not studied yet today.
    if today not in active_days:
        cursor_day = today.fromordinal(today.toordinal() - 1)
    while cursor_day in active_days:
        streak += 1
        cursor_day = cursor_day.fromordinal(cursor_day.toordinal() - 1)

    remaining_new = counts['new']
    exam_kind = None
    for token in ('gre', 'sat', 'gmat', 'toefl', 'ielts'):
        if token in learning_goal:
            exam_kind = token
            break

    return {
        'user_id': user_id,
        'now': now.isoformat(),
        'today': today.isoformat(),
        'learning_goal': learning_goal,
        'exam_kind': exam_kind,
        'vocabulary_level': vocab_level,
        'counts': counts,
        'due': due,
        'weak': weak,
        'new_words': new_words,
        'mastered': mastered,
        'weak_categories': weak_categories[:5],
        'overall_accuracy': round((correct_sum / total_sum) if total_sum else 0.0, 3),
        'streak_days': streak,
        'reviewed_today': reviewed_today,
        'remaining_new': remaining_new,
        'daily_completions': [d.isoformat() for d in daily_completions],
        'completed_today': today in set(daily_completions),
        'active_days': [d.isoformat() for d in sorted(active_days)[-30:]],
        'total_catalog': len(words),
    }
