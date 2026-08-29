#!/usr/bin/env python3
"""Generate a 10-second mnemonic video for a vocabulary word with Google Veo.

Cheapest supported model is Veo 3.1 Lite (~$0.05/s at 720p, paid Gemini API
tier); the script auto-falls back to Veo 3.1 Fast if Lite rejects a model.
Veo caps clips at 8s, so the pipeline assembles TWO clips that land on
exactly 10 seconds:

  1) gemini-2.5-flash writes a two-part Veo script that TEACHES the word
     (same boy + mentor cast as the LUCID comics, native audio included)
  2) Veo generates a 6s setup clip (confusing situation)
  3) The clip's last frame seeds an image-to-video 4s continuation
     (mentor reveals the word + meaning)
  4) ffmpeg concatenates to exactly 10s (fallbacks: scene extension,
     then 8s single clip slowed to 10s)

Usage:
  python3 scripts/generate_word_video.py --word obfuscate
  python3 scripts/generate_word_video.py --word ephemeral --meaning "lasting a very short time"
  python3 scripts/generate_word_video.py --word ubiquitous --dry-run
  VEO_MODEL=veo-3.1-fast-generate-preview python3 scripts/generate_word_video.py --word erudite
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / '.env'
VOCAB_PATH = ROOT / 'assets' / 'vocabulary.json'
VOCAB_API = 'https://mnemonics-api-production.up.railway.app/vocabulary'
OUT_DIR = ROOT / 'generated' / 'word_videos'
MANIFEST_PATH = OUT_DIR / 'manifest.json'

TEXT_MODEL = os.environ.get('GRE_TEXT_MODEL', 'gemini-2.5-flash')
VIDEO_MODEL = os.environ.get('VEO_MODEL', 'veo-3.1-lite-generate-preview')
VIDEO_MODEL_FALLBACK = os.environ.get('VEO_MODEL_FALLBACK', 'veo-3.1-fast-generate-preview')
ASPECT_RATIO = os.environ.get('VEO_ASPECT_RATIO', '16:9')
RESOLUTION = os.environ.get('VEO_RESOLUTION', '720p')
SETUP_SECONDS = 6
REVEAL_SECONDS = 4
TARGET_SECONDS = 10.0
POLL_INTERVAL = 15


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


def api_key() -> str:
    return os.environ.get('GEMINI_API_KEY') or ENV.get('GEMINI_API_KEY') or ''


def word_slug(word: str) -> str:
    slug = re.sub(r'[^a-z0-9]+', '_', word.strip().lower()).strip('_')
    return slug or 'unknown'


def lookup_meaning(word: str) -> str | None:
    needle = word.strip().lower()
    try:
        words = json.loads(VOCAB_PATH.read_text())
        for entry in words:
            if str(entry.get('word', '')).strip().lower() == needle:
                return entry.get('meaning')
    except Exception:
        pass
    try:
        with urllib.request.urlopen(VOCAB_API, timeout=60) as resp:
            for entry in json.load(resp):
                if str(entry.get('word', '')).strip().lower() == needle:
                    return entry.get('meaning')
    except Exception:
        pass
    return None


def make_client(key: str):
    try:
        from google import genai
    except ImportError:
        sys.exit('google-genai SDK missing: pip install google-genai')
    return genai.Client(api_key=key)


def check_key(client) -> None:
    from google.genai import errors
    try:
        client.models.get(model=TEXT_MODEL)
    except errors.APIError as e:
        msg = str(e)
        if 'API_KEY_INVALID' in msg or e.code in (400, 401, 403):
            sys.exit('GEMINI_API_KEY is not valid — paste a fresh key from '
                     'https://aistudio.google.com/apikey into .env')
        raise


def write_veo_script(client, word: str, meaning: str) -> dict:
    """Ask the text model for a 2-part Veo script: 6s setup + 4s reveal."""
    instruction = f'''You write prompts for Google Veo, a text-to-video model
that generates clips WITH native synchronized audio.

Write a TWO-PART script for a {TARGET_SECONDS:g}-second educational video that teaches
the GRE word "{word}" (meaning: {meaning}).

PART 1 (setup, exactly {SETUP_SECONDS} seconds of action): a concrete situation on a
sunny Indian street / chai stall / school gate that DEMONSTRATES confusion or
unclearness (the essence of "{word}"). Cast is always: a young Indian boy in
an orange t-shirt with a backpack, and an Indian mentor with glasses in a
light-blue shirt. End mid-scene, before the meaning is explained.

PART 2 (reveal, exactly {REVEAL_SECONDS} seconds of action): seamless continuation of
the SAME scene, lighting and camera. The mentor laughs warmly and says one
short clear line: "{word} — {meaning}." The boy reacts with an aha smile.

Hard rules for each part:
- English dialogue only, family-friendly, NO on-screen text or captions.
- Specify shots/camera, ambient sound, and exact spoken lines in quotes.
- Each part under 900 characters. Warm cinematic realism, 16:9.

Return ONLY valid JSON: {{"part1": "...", "part2": "..."}}'''
    from google.genai import types
    resp = client.models.generate_content(
        model=TEXT_MODEL,
        contents=instruction,
        config=types.GenerateContentConfig(
            response_mime_type='application/json', temperature=0.7),
    )
    data = json.loads(resp.text)
    part1 = str(data['part1']).strip()
    part2 = str(data['part2']).strip()
    if not part1 or not part2:
        raise RuntimeError('text model returned empty script parts')
    return {'part1': part1, 'part2': part2}


def run_video_op(client, model: str, desc: str, **kwargs):
    op = client.models.generate_videos(model=model, **kwargs)
    start = time.time()
    while not op.done:
        print(f'  [{desc}] generating... {int(time.time() - start)}s elapsed', flush=True)
        time.sleep(POLL_INTERVAL)
        op = client.operations.get(op)
    if op.error:
        raise RuntimeError(f'{desc} failed: {op.error}')
    sample = op.response.generated_videos[0]
    video = sample.video
    if video.video_bytes:
        return bytes(video.video_bytes)
    if not video.uri:
        raise RuntimeError(f'{desc} returned no video payload')
    return client.files.download(file=sample)


def generate_setup(client, model: str, prompt: str) -> bytes:
    return run_video_op(
        client, model, 'setup',
        prompt=prompt,
        config=dict(duration_seconds=SETUP_SECONDS, aspect_ratio=ASPECT_RATIO,
                    resolution=RESOLUTION))


def generate_reveal(client, model: str, prompt: str, seed_png: Path) -> bytes:
    from google.genai import types
    return run_video_op(
        client, model, 'reveal(i2v)',
        prompt=prompt,
        image=types.Image(image_bytes=seed_png.read_bytes(), mime_type='image/png'),
        config=dict(duration_seconds=REVEAL_SECONDS, aspect_ratio=ASPECT_RATIO,
                    resolution=RESOLUTION))


def generate_extend(client, model: str, prompt: str, clip1: bytes) -> bytes:
    from google.genai import types
    return run_video_op(
        client, model, 'extend',
        prompt=prompt,
        video=types.Video(video_bytes=clip1, mime_type='video/mp4'),
        config=dict(duration_seconds=REVEAL_SECONDS, aspect_ratio=ASPECT_RATIO,
                    resolution=RESOLUTION))


def ffprobe_duration(path: Path) -> float:
    out = subprocess.run(
        ['ffprobe', '-v', 'error', '-show_entries', 'format=duration',
         '-of', 'default=nw=1:nk=1', str(path)],
        capture_output=True, text=True, check=True)
    return float(out.stdout.strip())


def last_frame_png(video_path: Path, tmp: Path) -> Path:
    frame = tmp / 'last_frame.png'
    dur = ffprobe_duration(video_path)
    subprocess.run(
        ['ffmpeg', '-y', '-ss', f'{max(dur - 0.1, 0):.3f}', '-i', str(video_path),
         '-frames:v', '1', str(frame)],
        check=True, capture_output=True)
    return frame


def concat_exact(clips: list[Path], tmp: Path) -> Path:
    """Concat clips and trim to TARGET_SECONDS (re-encode: sources may differ)."""
    list_file = tmp / 'list.txt'
    list_file.write_text(''.join(f"file '{c}'\n" for c in clips))
    merged = tmp / 'merged.mp4'
    subprocess.run(
        ['ffmpeg', '-y', '-f', 'concat', '-safe', '0', '-i', str(list_file),
         '-c:v', 'libx264', '-c:a', 'aac', str(merged)],
        check=True, capture_output=True)
    final = tmp / 'final.mp4'
    subprocess.run(
        ['ffmpeg', '-y', '-i', str(merged), '-t', f'{TARGET_SECONDS}',
         '-c', 'copy', str(final)],
        check=True, capture_output=True)
    return final


def slow_to_target(clip: Path, tmp: Path) -> Path:
    """Last-resort fallback: stretch a single clip to TARGET_SECONDS."""
    final = tmp / 'final.mp4'
    speed = TARGET_SECONDS / ffprobe_duration(clip)
    subprocess.run(
        ['ffmpeg', '-y', '-i', str(clip),
         '-filter_complex',
         f'[0:v]setpts=PTS*{speed:.6f}[v];[0:a]atempo={1 / speed:.6f}[a]',
         '-map', '[v]', '-map', '[a]', '-c:v', 'libx264', '-c:a', 'aac',
         '-t', f'{TARGET_SECONDS}', str(final)],
        check=True, capture_output=True)
    return final


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('--word', required=True)
    parser.add_argument('--meaning')
    parser.add_argument('--model', default=VIDEO_MODEL)
    parser.add_argument('--dry-run', action='store_true',
                        help='write the Veo script to stdout, do not spend on video')
    parser.add_argument('--single-clip', action='store_true',
                        help='skip the 2-clip build; one 8s clip slowed to 10s')
    args = parser.parse_args()

    if shutil.which('ffmpeg') is None:
        sys.exit('ffmpeg not found on PATH (brew install ffmpeg)')

    word = args.word.strip()
    meaning = args.meaning or lookup_meaning(word)
    if not meaning:
        sys.exit(f'No meaning found for "{word}"; pass --meaning explicitly.')

    key = api_key()
    if not key:
        sys.exit('GEMINI_API_KEY missing (.env or environment).')
    client = make_client(key)
    check_key(client)

    print(f'Word: {word} — {meaning}')
    script = write_veo_script(client, word, meaning)
    print('--- Veo script ---')
    print('[part1]', script['part1'])
    print('[part2]', script['part2'])
    print('------------------')
    if args.dry_run:
        return

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    slug = word_slug(word)
    started = time.time()

    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        model = args.model
        clips: list[Path] = []

        if args.single_clip:
            print(f'Generating single 8s clip with {model}...')
            try:
                clip = run_video_op(
                    client, model, 'clip1', prompt=script['part1'],
                    config=dict(duration_seconds=8, aspect_ratio=ASPECT_RATIO,
                                resolution=RESOLUTION))
            except Exception as e:
                print(f'  {model} failed ({e}); retrying with {VIDEO_MODEL_FALLBACK}')
                model = VIDEO_MODEL_FALLBACK
                clip = run_video_op(
                    client, model, 'clip1', prompt=script['part1'],
                    config=dict(duration_seconds=8, aspect_ratio=ASPECT_RATIO,
                                resolution=RESOLUTION))
            first = tmp / 'clip1.mp4'
            first.write_bytes(clip)
            final = slow_to_target(first, tmp)
        else:
            print(f'Generating {SETUP_SECONDS}s setup clip with {model}...')
            try:
                clip1 = generate_setup(client, model, script['part1'])
            except Exception as e:
                print(f'  {model} failed ({e}); retrying with {VIDEO_MODEL_FALLBACK}')
                model = VIDEO_MODEL_FALLBACK
                clip1 = generate_setup(client, model, script['part1'])
            first = tmp / 'clip1.mp4'
            first.write_bytes(clip1)
            clips = [first]

            clip2 = None
            try:
                print(f'Generating {REVEAL_SECONDS}s reveal from last frame (i2v)...')
                frame = last_frame_png(first, tmp)
                clip2 = generate_reveal(client, model, script['part2'], frame)
            except Exception as e:
                print(f'  i2v reveal failed ({e}); trying scene extension')
            if clip2 is None:
                try:
                    clip2 = generate_extend(client, model, script['part2'], clip1)
                except Exception as e:
                    print(f'  scene extension failed ({e}); falling back to slow-motion')
            if clip2:
                second = tmp / 'clip2.mp4'
                second.write_bytes(clip2)
                clips.append(second)
                final = concat_exact(clips, tmp)
            else:
                final = slow_to_target(first, tmp)

        out_path = OUT_DIR / f'{slug}.mp4'
        shutil.move(str(final), out_path)
        dur = ffprobe_duration(out_path)
        print(f'Wrote {out_path} ({dur:.2f}s, model={model}, '
              f'{int(time.time() - started)}s wall)')

        manifest = {}
        if MANIFEST_PATH.exists():
            manifest = json.loads(MANIFEST_PATH.read_text())
        manifest[slug] = {
            'word': word,
            'meaning': meaning,
            'model': model,
            'seconds': round(dur, 2),
            'script': script,
            'updated': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
        }
        MANIFEST_PATH.write_text(json.dumps(manifest, indent=2))


if __name__ == '__main__':
    main()
