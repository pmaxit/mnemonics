"""Shared educational-comic prompt that matches the LUCID 6-panel template."""

from __future__ import annotations


def build_comic_prompt(
    word: str,
    meaning: str,
    *,
    category: str = '',
    situation: str = '',
    panels: list[str] | None = None,
) -> str:
    """Build a style-locked image prompt for a vocabulary comic page.

    Matches the LUCID template: yellow definition banner, 2x3 grid, two
    recurring Indian characters, cel-shaded educational webcomic, bright
    street setting, confusion-to-clarity story.
    """
    word = (word or '').strip()
    meaning = (meaning or 'vocabulary word').strip()
    situation = (situation or (
        f'an everyday Indian street moment that makes the meaning of "{word}" obvious'
    )).strip()
    category_line = f' Theme category: {category}.' if category else ''

    beats = panels if panels and len(panels) >= 6 else [
        f'The student looks confused about a situation involving "{word}"; question marks float around his head.',
        'A tangled grey scribble-cloud labeled CONFUSION hangs between student and mentor.',
        f'The mentor explains the key action that demonstrates "{word}" using a simple visual on a whiteboard.',
        'The turning point: the scene makes the meaning unmistakable.',
        f'The student gets it — thumbs up, bright expression, saying the word "{word}".',
        f'Resolution: both look at a now-clear visual; a speech bubble restates "{meaning}".',
    ]
    beat_lines = '\n'.join(f'Panel {i}: {beats[i - 1]}' for i in range(1, 7))

    return f'''ONE complete educational comic PAGE teaching the English GRE word "{word}" meaning "{meaning}".{category_line}

COPY THIS LAYOUT EXACTLY:
- Portrait page, bright and sunny, never dark.
- The top 10% of the page is a SOLID empty bright-yellow rectangle with NO letters, NO title, and NO logo. Leave that banner blank.
- Directly under that empty yellow banner: a 2-column by 3-row grid of SIX equal rectangular panels (left-to-right, then next row).
- Thin black panel borders, small white gutters between panels.
- Each panel has a small white caption box along its bottom edge with short readable English.

CAST — same two people in EVERY panel, same clothes, same faces:
- Student: young Indian boy, short black hair, bright orange t-shirt, dark backpack.
- Mentor: Indian man with glasses, light-blue button-down shirt tucked into dark trousers.
- Brown skin, clean cartoon faces, expressive eyes. Do not swap outfits or redesign them between panels.

SETTING: contemporary Indian city street in daylight. Recurring extras: yellow-green auto-rickshaw, pedestrians in sarees, colorful shopfronts, clear blue sky. Warm palette of orange, sky-blue, yellow, teal. Soft cel shading, even line weights, gentle highlights. Modern educational webcomic / clean digital storyboard. Not photorealistic, not anime, not 3D CGI, not watercolor, not stick figures, not collage.

STORY SITUATION: {situation}

{beat_lines}

TEXT RULES: English only. Short speech bubbles (max 8 words). No Hindi. No gibberish, no misspellings, no random letters. No watermarks, no logos, no extra panels, no missing header.

NEGATIVE: dark lighting, muddy colors, horror, gore, photorealism, inconsistent characters, 4-panel layout, 3-panel layout, single illustration instead of a 6-panel grid, extra title text above the panels, duplicate headers.'''
