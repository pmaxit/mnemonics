"""Shared educational-comic prompt: a 2x2 realistic-cartoon storyboard per word."""

from __future__ import annotations


def build_comic_prompt(
    word: str,
    meaning: str,
    *,
    category: str = '',
    situation: str = '',
    panels: list[str] | None = None,
) -> str:
    """Build a style-locked image prompt for a 4-panel vocabulary comic.

    Layout: 2x2 grid, a short story sequence that makes the word's meaning
    obvious without needing the definition. Rendered in a polished,
    realistic-proportion cartoon style (semi-realistic digital illustration).
    """
    word = (word or '').strip()
    meaning = (meaning or 'vocabulary word').strip()
    situation = (situation or (
        f'an everyday scene that makes the meaning of "{word}" obvious'
    )).strip()
    category_line = f' Theme category: {category}.' if category else ''

    beats = panels if panels and len(panels) >= 4 else [
        f'Setup: a character is in a situation that will demonstrate "{word}".',
        f'Development: the situation escalates and the key behaviour of "{word}" appears.',
        f'Climax: the moment that makes "{word}" unmistakable.',
        f'Outcome: the result clearly shows the meaning "{meaning}".',
    ]
    beat_lines = '\n'.join(f'Panel {i}: {beats[i - 1]}' for i in range(1, 5))

    return f'''ONE square educational comic PAGE teaching the English word "{word}" meaning "{meaning}".{category_line}

LAYOUT (strict):
- A 2-column by 2-row grid of FOUR equal panels, read left-to-right then next row (1 2 / 3 4).
- Thin black panel borders with small white gutters. Nothing outside the grid except a thin white margin.
- A small numbered circle (1-4) in the top-left corner of each panel.
- Each panel has one short caption box along its bottom edge (max 8 words) narrating that beat.

ART STYLE: realistic cartoon. Semi-realistic digital illustration with natural human proportions, believable faces, detailed lighting, rich textures and cinematic composition, like a modern graphic-novel storyboard. Clean ink outlines, painterly shading, warm natural colour. Not chibi, not flat clip-art, not anime, not 3D CGI, not photographs.

CONTINUITY: the same one or two characters (same faces, hair, clothes) appear in all four panels, in a consistent setting. Expressions and body language must clearly show the emotion/action of the word.

STORY SITUATION: {situation}

{beat_lines}

The four panels together must let a viewer infer the meaning of "{word}" from the pictures alone. Show, don't lecture: no classroom whiteboard scenes unless the word is about teaching.

TEXT RULES: English only, correctly spelled. Captions and speech bubbles must be short and legible. Include the word "{word}" in at most one caption. No gibberish, no watermarks, no logos, no extra panels, no title banner.

AVOID: dark or muddy lighting, gore, horror, inconsistent characters, 6-panel or 3-panel layouts, a single full-page illustration, misspelled text.'''
