#!/usr/bin/env python3
"""Generate 2x2 realistic-cartoon educational comics for vocabulary words.

Pipeline:
  1) OpenAI text model writes a 4-beat visual story that demonstrates the word
  2) OpenAI gpt-image renders a 2x2 realistic-cartoon comic page

Usage:
  python3 scripts/generate_word_images.py --word dilettante --force
  python3 scripts/generate_word_images.py --limit 5 --force --workers 4
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import re
import sys
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from io import BytesIO
from pathlib import Path

from PIL import Image

from comic_style import build_comic_prompt

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / '.env'
OUT_DIR = ROOT / 'generated' / 'word_images'
MANIFEST_PATH = OUT_DIR / 'manifest.json'
VOCAB_API = 'https://mnemonics-api-production.up.railway.app/vocabulary'
TEXT_MODEL = os.environ.get('GRE_TEXT_MODEL', 'gpt-4o-mini')
IMAGE_MODEL = os.environ.get('OPENAI_IMAGE_MODEL', 'gpt-image-1.5')
IMAGE_QUALITY = os.environ.get('OPENAI_IMAGE_QUALITY', 'medium')
IMAGE_SIZE = os.environ.get('COMIC_IMAGE_SIZE', '1024x1024')

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


def load_openai_key() -> str:
    return os.environ.get('OPENAI_API_KEY') or ENV.get('OPENAI_API_KEY') or ''


def word_slug(word: str) -> str:
    slug = SLUG_RE.sub('_', word.strip().lower()).strip('_')
    return slug or 'unknown'


def fetch_vocabulary() -> list[dict]:
    with urllib.request.urlopen(VOCAB_API, timeout=120) as resp:
        return json.load(resp)


def fallback_script(word: str, meaning: str) -> dict:
    return {
        'situation': f'An everyday scene that shows what "{word}" really means.',
        'panels': [
            f'Setup: a character faces a situation involving "{word}".',
            f'Development: the key behaviour of "{word}" appears.',
            f'Climax: the moment that makes "{word}" unmistakable.',
            f'Outcome: the result clearly shows "{meaning}".',
        ],
    }


def generate_script(word: str, meaning: str) -> dict:
    api_key = load_openai_key()
    if not api_key:
        return fallback_script(word, meaning)

    prompt = f'''Write a 4-panel comic script that TEACHES a vocabulary word through a visual story.

Word: "{word}"
Meaning: "{meaning}"

Return ONLY valid JSON:
{{
  "situation": "one sentence describing the setting and the one or two characters (age, look, clothes)",
  "panels": ["Panel 1 visual beat, max 25 words", "Panel 2 ...", "Panel 3 ...", "Panel 4 ..."]
}}

Rules:
- English only, family-friendly, no gore.
- Arc: setup -> escalation -> climax that makes the meaning obvious -> outcome.
- The pictures alone must let a learner infer the meaning; show behaviour and emotion, do not lecture.
- Use the same one or two characters throughout; describe concrete visuals (actions, expressions, objects).
'''
    body = json.dumps({
        'model': TEXT_MODEL,
        'messages': [{'role': 'user', 'content': prompt}],
        'response_format': {'type': 'json_object'},
        'temperature': 0.7,
    }).encode()
    req = urllib.request.Request(
        'https://api.openai.com/v1/chat/completions',
        data=body,
        headers={'Authorization': f'Bearer {api_key}', 'Content-Type': 'application/json'},
        method='POST',
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            payload = json.load(resp)
        data = json.loads(payload['choices'][0]['message']['content'])
        panels = data.get('panels') or []
        if not isinstance(panels, list) or len(panels) < 4:
            return fallback_script(word, meaning)
        return {
            'situation': str(data.get('situation') or '').strip()
            or fallback_script(word, meaning)['situation'],
            'panels': [str(p).strip() for p in panels[:4]],
        }
    except Exception:
        return fallback_script(word, meaning)


def fetch_comic_image(prompt: str) -> Image.Image:
    api_key = load_openai_key()
    if not api_key:
        raise RuntimeError('OPENAI_API_KEY required')
    body = json.dumps({
        'model': IMAGE_MODEL,
        'prompt': prompt,
        'size': IMAGE_SIZE,
        'quality': IMAGE_QUALITY,
        'n': 1,
    }).encode()
    req = urllib.request.Request(
        'https://api.openai.com/v1/images/generations',
        data=body,
        headers={'Authorization': f'Bearer {api_key}', 'Content-Type': 'application/json'},
        method='POST',
    )
    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            payload = json.load(resp)
        return Image.open(BytesIO(base64.b64decode(payload['data'][0]['b64_json'])))
    except urllib.error.HTTPError as e:
        raise RuntimeError(f'image generation failed: {e.code} {e.read()[:300]!r}') from e


def write_manifest(slugs: dict[str, str]) -> None:
    payload = {
        'version': 5,
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
    final = fetch_comic_image(prompt).convert('RGB')
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
        f'Generating {len(batch)} / {len(unique)} 2x2 comics → {OUT_DIR}',
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
