"""Coach agent: tell the student WHY today's mix and HOW to study it."""

from __future__ import annotations


def build_strategy(profile: dict, mix: dict) -> dict:
    split = mix.get('split') or {}
    counts = profile.get('counts') or {}
    exam_kind = profile.get('exam_kind')
    accuracy = float(profile.get('overall_accuracy') or 0)
    due_n = split.get('review') or 0
    new_n = split.get('new') or 0
    weak_n = split.get('weak') or 0

    if not profile.get('total_catalog'):
        headline = 'No vocabulary is loaded yet — import words, then this mix will fill in.'
        how = 'The planner needs the GRE word catalog on the server before it can assign due reviews or new introductions.'
    elif mix.get('empty'):
        headline = 'You are caught up — browse a few new words when you have energy.'
        how = 'There is nothing overdue. Add a short encoding session rather than grinding extra reviews.'
    elif due_n >= new_n and due_n > 0:
        headline = 'Protect what you already started before adding more GRE words.'
        how = (
            'Do due reviews first, closed-book. Look at the word, say the meaning, then check. '
            'Only then study new items with the mnemonic and a phrase you invent.'
        )
    elif new_n > 0 and counts.get('learning', 0) < 8:
        headline = 'Build a small learning set you can actually review tomorrow.'
        how = (
            'For each new word: read the meaning, picture the mnemonic, then hide it and retrieve. '
            'Two good retrievals beat ten rereads.'
        )
    else:
        headline = 'Mix retrieval (old words) with encoding (new words) in one sitting.'
        how = (
            'Reviews first, then weak-area rescue, then new introductions. '
            'Stop if you cannot recall — that is the signal to encode again, not to skip.'
        )

    tips = []
    if due_n:
        tips.append(f'Retrieve {due_n} due word(s) from memory before flipping the card.')
    if weak_n:
        tips.append('On weak words, say a full sentence out loud — isolated synonyms fade faster.')
    if new_n:
        tips.append('For new words, link the mnemonic image to the meaning, then test yourself once.')
    if accuracy and accuracy < 0.7:
        tips.append('Accuracy is under 70%. Prefer fewer new words today and slower reviews.')
    if exam_kind:
        tips.append(f'{exam_kind.upper()} payoff comes from recall under time pressure, not from rereading lists.')
    if not tips:
        tips.append('Keep the session short and complete. Consistency beats volume.')

    next_action = 'Start with due reviews.' if due_n else (
        'Start with new-word encoding.' if new_n else 'Open the first word and retrieve the meaning.'
    )

    return {
        'headline': headline,
        'how_to_study': how,
        'next_action': next_action,
        'tips': tips[:4],
    }
