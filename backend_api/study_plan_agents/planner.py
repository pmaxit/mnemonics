"""Planner agent: pick today's coordinated multiplan mix."""

from __future__ import annotations

import hashlib
from typing import Iterable


SECONDS_PER_REVIEW = 45
SECONDS_PER_WEAK = 60
SECONDS_PER_NEW = 90
SECONDS_PER_BONUS = 30

MAX_REVIEWS = 24
MAX_WEAK = 6
MAX_NEW = 12


def _dedupe(items: Iterable[dict], seen: set[str]) -> list[dict]:
    result = []
    for item in items:
        word = item.get('word')
        if not word or word in seen:
            continue
        seen.add(word)
        result.append(item)
    return result


def _sort_due(items: list[dict]) -> list[dict]:
    def key(item: dict):
        next_review = item.get('next_review') or ''
        return (next_review, -item.get('review_count', 0), item.get('word', ''))
    return sorted(items, key=key)


def _sort_weak(items: list[dict]) -> list[dict]:
    return sorted(items, key=lambda i: (i.get('accuracy', 1.0), -i.get('total_answers', 0), i.get('word', '')))


def _stable_pick(items: list[dict], seed: str, count: int) -> list[dict]:
    if not items or count <= 0:
        return []
    ranked = sorted(
        items,
        key=lambda i: hashlib.sha256(f"{seed}:{i.get('word')}".encode()).hexdigest(),
    )
    return ranked[:count]


def recommend_daily_mix(profile: dict, available_minutes: int = 20) -> dict:
    minutes = max(8, min(int(available_minutes or 20), 60))
    budget = minutes * 60
    seen: set[str] = set()

    due = _sort_due(profile.get('due') or [])
    weak = _sort_weak(profile.get('weak') or [])
    new_words = profile.get('new_words') or []
    mastered = profile.get('mastered') or []
    weak_categories = [c['category'] for c in (profile.get('weak_categories') or [])]

    # Prefer introducing words from weak categories when the student is past onboarding.
    if weak_categories:
        new_words = sorted(
            new_words,
            key=lambda i: (0 if i.get('category') in weak_categories else 1, i.get('word', '')),
        )
    else:
        new_words = sorted(new_words, key=lambda i: (i.get('difficulty', ''), i.get('word', '')))

    # SRS first: reviews protect memory. New words scale down when the due pile is large.
    due_pressure = len(due)
    if due_pressure >= 20:
        review_share = 0.7
        new_share = 0.15
        weak_share = 0.15
    elif due_pressure >= 8:
        review_share = 0.55
        new_share = 0.25
        weak_share = 0.2
    elif profile.get('counts', {}).get('learning', 0) < 8:
        review_share = 0.25
        new_share = 0.6
        weak_share = 0.15
    else:
        review_share = 0.4
        new_share = 0.4
        weak_share = 0.2

    review_budget = int(budget * review_share)
    weak_budget = int(budget * weak_share)
    new_budget = budget - review_budget - weak_budget

    review_cap = min(MAX_REVIEWS, max(3, review_budget // SECONDS_PER_REVIEW))
    weak_cap = min(MAX_WEAK, max(1, weak_budget // SECONDS_PER_WEAK))
    new_cap = min(MAX_NEW, max(2, new_budget // SECONDS_PER_NEW))

    reviews = _dedupe(due, seen)[:review_cap]
    weak_items = _dedupe(weak, seen)[:weak_cap]
    intros = _dedupe(new_words, seen)[:new_cap]

    seed = f"{profile.get('user_id')}:{profile.get('today')}"
    bonus_pool = [w for w in mastered if w.get('word') not in seen]
    bonus = _stable_pick(bonus_pool, seed, 1)

    exam_items = []
    exam_kind = profile.get('exam_kind')
    remaining_new = int(profile.get('remaining_new') or 0)
    if exam_kind and remaining_new > 0:
        # Pace track: extra new words only if the due pile is light.
        extra_cap = 2 if due_pressure < 12 else 0
        exam_items = _dedupe(new_words, seen)[:extra_cap]

    tracks = []
    if reviews:
        tracks.append(_track(
            'due_reviews',
            'Due reviews',
            'These words are past their spaced-repetition due date. Review them first so they do not slip.',
            1,
            reviews,
            'due',
        ))
    if weak_items:
        cat_note = f" Focus on {', '.join(weak_categories[:2])}." if weak_categories else ''
        tracks.append(_track(
            'weak_rescue',
            'Weak-area rescue',
            f'Low accuracy or still in the learning stage.{cat_note}'.strip(),
            2,
            weak_items,
            'weak',
        ))
    if intros:
        tracks.append(_track(
            'new_words',
            'New word introduction',
            'A small set of unseen GRE words. Encode with the mnemonic, then try to recall the meaning from memory.',
            3,
            intros,
            'new',
        ))
    if exam_items:
        weeks = max(1, round(remaining_new / max(len(intros) + len(exam_items), 1) / 7))
        tracks.append(_track(
            'exam_pace',
            f'{exam_kind.upper()} countdown pace',
            f'{remaining_new} new words remain. At today\'s pace this is roughly {weeks} week(s) of new introductions.',
            4,
            exam_items,
            'exam',
        ))
    if bonus:
        tracks.append(_track(
            'confidence_bonus',
            'Confidence bonus',
            'One mastered word to close the session with a successful retrieval — optional, not required for the streak.',
            5,
            bonus,
            'bonus',
        ))

    items = []
    for track in tracks:
        items.extend(track['items'])

    seconds = (
        len(reviews) * SECONDS_PER_REVIEW
        + len(weak_items) * SECONDS_PER_WEAK
        + (len(intros) + len(exam_items)) * SECONDS_PER_NEW
        + len(bonus) * SECONDS_PER_BONUS
    )
    estimated = max(5, round(seconds / 60))

    return {
        'available_minutes': minutes,
        'estimated_minutes': estimated,
        'split': {
            'review': len(reviews),
            'weak': len(weak_items),
            'new': len(intros) + len(exam_items),
            'bonus': len(bonus),
        },
        'tracks': tracks,
        'items': items,
        'empty': not items,
    }


def _track(track_id: str, title: str, why: str, priority: int, words: list[dict], reason: str) -> dict:
    return {
        'id': track_id,
        'title': title,
        'why': why,
        'priority': priority,
        'items': [
            {
                'word_id': w.get('word_id'),
                'word': w.get('word'),
                'reason': reason,
                'category': w.get('category'),
                'difficulty': w.get('difficulty'),
                'stage': w.get('stage'),
                'accuracy': w.get('accuracy'),
                'mnemonic_hint': bool((w.get('mnemonic') or '').strip()),
            }
            for w in words
        ],
    }
