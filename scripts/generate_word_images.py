#!/usr/bin/env python3
"""Generate LUCID-template educational comics for vocabulary words.

Pipeline:
  1) Text model writes a 6-beat English story that demonstrates the word
  2) Pollinations renders a 2x3 educational comic matching the yellow-banner
     Indian street / student-mentor template
  3) Pillow stamps a readable yellow header so the title is always English

Usage:
  python3 scripts/generate_word_images.py --limit 5 --force
  python3 scripts/generate_word_images.py --force --workers 4
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from io import BytesIO
from pathlib import Path
from urllib.parse import quote

from PIL import Image, ImageDraw, ImageFont

from comic_style import build_comic_prompt

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / '.env'
OUT_DIR = ROOT / 'generated' / 'word_images'
MANIFEST_PATH = OUT_DIR / 'manifest.json'
VOCAB_API = 'https://mnemonics-api-production.up.railway.app/vocabulary'
TEXT_MODEL = os.environ.get('GRE_TEXT_MODEL', 'google/gemini-2.5-flash')
IMAGE_MODEL = os.environ.get('POLLINATIONS_IMAGE_MODEL', 'gptimage')
IMAGE_WIDTH = int(os.environ.get('COMIC_IMAGE_WIDTH', '1024'))
IMAGE_HEIGHT = int(os.environ.get('COMIC_IMAGE_HEIGHT', '1536'))

SLUG_RE = re.compile(r'[^a-z0-9]+')


def load_env() -> dict[str, str]:
    env: dict[str, str] = {}
    if ENV_PATH.exists():
        for line in ENV_PATH.read_text().splitlines():
            if not line.strip() or line.strip().startswith('#') or '=' not in line:
                continue
            k, v = line.split('=', 1)
            env[k.strip()] = v.strip().strip('"').strip("'")
    return env


ENV = load_env()


def load_openrouter_key() -> str:
    return os.environ.get('OPENROUTER_API_KEY') or ENV.get('OPENROUTER_API_KEY') or ''


def load_pollinations_key() -> str:
    return (
        os.environ.get('POLLINATIONS_AI')
        or os.environ.get('POLLINATIONS_API_KEY')
        or ENV.get('POLLINATIONS_AI')
        or ENV.get('POLLINATIONS_API_KEY')
        or ''
    )


def word_slug(word: str) -> str:
    slug = SLUG_RE.sub('_', word.strip().lower()).strip('_')
    return slug or 'unknown'


def fetch_vocabulary() -> list[dict]:
    with urllib.request.urlopen(VOCAB_API, timeout=120) as resp:
        return json.load(resp)


def fallback_script(word: str, meaning: str) -> dict:
    return {
        'situation': (
            f'On a sunny Indian street, a student and mentor work through '
            f'what "{word}" really means.'
        ),
        'panels': [
            f'The boy looks confused about a situation involving "{word}"; question marks float around him.',
            'A tangled grey scribble-cloud labeled CONFUSION hangs between student and mentor.',
            f'The mentor uses a whiteboard to show the key action that is "{word}".',
            'The turning point: the scene makes the meaning unmistakable.',
            f'The boy gives a thumbs-up: "Ah, now I get {word}!"',
            f'Both stand by a now-clear diagram; a speech bubble says "{meaning}".',
        ],
    }


def generate_script(word: str, meaning: str) -> dict:
    api_key = load_openrouter_key()
    if not api_key:
        return fallback_script(word, meaning)

    prompt = f'''Write a 6-panel educational comic script that TEACHES the GRE word through a visual story.

Word: "{word}"
Meaning: "{meaning}"

Return ONLY valid JSON:
{{
  "situation": "one sentence: everyday Indian street scene that can show this meaning",
  "panels": [
    "Panel 1 visual beat, max 18 words",
    "Panel 2 visual beat, max 18 words",
    "Panel 3 visual beat, max 18 words",
    "Panel 4 visual beat, max 18 words",
    "Panel 5 visual beat, max 18 words",
    "Panel 6 visual beat that restates the meaning, max 18 words"
  ]
}}

Rules:
- English only.
- Cast is always: young Indian boy in an orange t-shirt with a backpack, and an Indian mentor with glasses in a light-blue shirt.
- Arc: confusion → problem → explanation → turning point → aha moment → meaning restated.
- Make the story demonstrate THIS word, not a generic classroom lecture.
- No other languages, no gore, family-friendly.
'''
    body = json.dumps({
        'model': TEXT_MODEL,
        'messages': [{'role': 'user', 'content': prompt}],
        'response_format': {'type': 'json_object'},
        'temperature': 0.6,
    }).encode()
    req = urllib.request.Request(
        'https://openrouter.ai/api/v1/chat/completions',
        data=body,
        headers={
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://mnemonics.app',
            'X-Title': 'mnemonics-lucid-comic',
        },
        method='POST',
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            payload = json.load(resp)
        data = json.loads(payload['choices'][0]['message']['content'])
        panels = data.get('panels') or []
        if not isinstance(panels, list) or len(panels) < 6:
            return fallback_script(word, meaning)
        return {
            'situation': str(data.get('situation') or '').strip()
            or fallback_script(word, meaning)['situation'],
            'panels': [str(p).strip() for p in panels[:6]],
        }
    except Exception:
        return fallback_script(word, meaning)


def _font(size: int, bold: bool = False) -> ImageFont.ImageFont:
    candidates = [
        '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf' if bold else '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
        '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf' if bold else '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size=size)
    return ImageFont.load_default()


def stamp_header(img: Image.Image, word: str, meaning: str) -> Image.Image:
    """Overwrite the top banner with guaranteed-readable English."""
    canvas = img.convert('RGB')
    w, h = canvas.size
    banner_h = max(72, int(h * 0.10))
    draw = ImageDraw.Draw(canvas)
    draw.rectangle((0, 0, w, banner_h), fill=(255, 214, 10))
    draw.line((0, banner_h - 2, w, banner_h - 2), fill=(30, 30, 30), width=3)

    text = f'{word.upper()}: {meaning.upper()}'
    font_size = 42
    font = _font(font_size, bold=True)
    while font_size > 16 and draw.textlength(text, font=font) > w - 32:
        font_size -= 2
        font = _font(font_size, bold=True)

    tw = draw.textlength(text, font=font)
    ty = max(8, (banner_h - font_size) // 2 - 2)
    draw.text(((w - tw) / 2, ty), text, fill=(20, 20, 20), font=font)
    return canvas


def _is_image_bytes(data: bytes) -> bool:
    return data[:3] == b'\xff\xd8\xff' or data[:8] == b'\x89PNG\r\n\x1a\n'


def fetch_comic_image(prompt: str, key: str) -> Image.Image:
    encoded = quote(prompt)
    query = f'model={IMAGE_MODEL}&width={IMAGE_WIDTH}&height={IMAGE_HEIGHT}&nologo=true'
    urls = [
        f'https://gen.pollinations.ai/image/{encoded}?{query}&key={quote(key)}' if key else '',
        f'https://image.pollinations.ai/prompt/{encoded}?{query}',
    ]
    last_error: Exception | None = None
    for url in urls:
        if not url:
            continue
        try:
            req = urllib.request.Request(
                url,
                headers={'User-Agent': 'mnemonics-comic/1.0', 'Accept': 'image/*'},
            )
            with urllib.request.urlopen(req, timeout=180) as resp:
                data = resp.read()
            if not _is_image_bytes(data):
                raise ValueError(f'non-image response ({len(data)} bytes)')
            return Image.open(BytesIO(data))
        except Exception as e:  # noqa: BLE001
            last_error = e
            continue
    raise RuntimeError(f'image generation failed: {last_error}')


def write_manifest(slugs: dict[str, str]) -> None:
    payload = {
        'version': 4,
        'count': len(slugs),
        'images': {
            word: f'generated/word_images/{slug}.jpg'
            for word, slug in sorted(slugs.items(), key=lambda x: x[0].lower())
        },
    }
    MANIFEST_PATH.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + '\n')


def generate_one(word: str, meaning: str, force: bool) -> tuple[str, str, str]:
    slug = word_slug(word)
    dest = OUT_DIR / f'{slug}.jpg'
    if dest.exists() and dest.stat().st_size > 1000 and not force:
        return word, slug, 'skip'

    script = generate_script(word, meaning)
    prompt = build_comic_prompt(
        word,
        meaning,
        situation=script.get('situation', ''),
        panels=script.get('panels'),
    )
    comic = fetch_comic_image(prompt, load_pollinations_key())
    final = stamp_header(comic, word, meaning)
    dest.parent.mkdir(parents=True, exist_ok=True)
    final.save(dest, format='JPEG', quality=90, optimize=True)
    return word, slug, 'ok'


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--limit', type=int, default=0)
    parser.add_argument('--offset', type=int, default=0)
    parser.add_argument('--workers', type=int, default=4)
    parser.add_argument('--force', action='store_true')
    parser.add_argument('--word', type=str, default='', help='Generate a single word')
    args = parser.parse_args()

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    words = fetch_vocabulary()
    seen: set[str] = set()
    unique: list[dict] = []
    for row in words:
        w = (row.get('word') or '').strip()
        if not w:
            continue
        key_w = w.lower()
        if key_w in seen:
            continue
        seen.add(key_w)
        unique.append(row)

    if args.word:
        wanted = args.word.strip().lower()
        batch = [row for row in unique if (row.get('word') or '').strip().lower() == wanted]
        if not batch:
            print(f'Word not found in vocabulary API: {args.word}', flush=True)
            return 1
    else:
        batch = unique[args.offset:]
        if args.limit > 0:
            batch = batch[: args.limit]

    print(
        f'Generating {len(batch)} / {len(unique)} LUCID-template comics → {OUT_DIR}',
        flush=True,
    )

    existing: dict[str, str] = {}
    ok = skip = fail = 0
    failures: list[str] = []
    with ThreadPoolExecutor(max_workers=max(1, args.workers)) as pool:
        futures = {
            pool.submit(
                generate_one,
                (row.get('word') or '').strip(),
                (row.get('meaning') or '').strip(),
                args.force,
            ): row
            for row in batch
        }
        done = 0
        for fut in as_completed(futures):
            done += 1
            try:
                word, slug, status = fut.result()
                existing[word] = slug
                if status == 'skip':
                    skip += 1
                else:
                    ok += 1
                print(f'[{done}/{len(batch)}] {status:4} {word}', flush=True)
            except Exception as e:  # noqa: BLE001
                fail += 1
                failures.append(str(e))
                print(f'[{done}/{len(batch)}] FAIL {e}', flush=True)
            if done % 20 == 0:
                write_manifest(existing)

    for row in unique:
        word = (row.get('word') or '').strip()
        slug = word_slug(word)
        if (OUT_DIR / f'{slug}.jpg').exists():
            existing[word] = slug
    write_manifest(existing)
    print(f'Done. ok={ok} skip={skip} fail={fail} manifest={len(existing)}', flush=True)
    for line in failures[:20]:
        print(' ', line, flush=True)
    return 1 if fail and ok == 0 else 0


if __name__ == '__main__':
    sys.exit(main())
