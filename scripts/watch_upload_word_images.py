#!/usr/bin/env python3
"""Watch generated/word_images and upload new/changed comics to Railway."""

from __future__ import annotations

import os
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMG_DIR = ROOT / 'generated' / 'word_images'
API = os.environ.get('API_BASE', 'https://mnemonics-api-production.up.railway.app')
STATE = Path('/tmp/uploaded_word_images.state')


def token() -> str:
    t = os.environ.get('IMAGE_UPLOAD_TOKEN', '').strip()
    if t:
        return t
    p = Path('/tmp/image_upload_token.txt')
    if p.exists():
        return p.read_text().strip()
    raise SystemExit('IMAGE_UPLOAD_TOKEN missing')


def load_state() -> dict[str, float]:
    if not STATE.exists():
        return {}
    out = {}
    for line in STATE.read_text().splitlines():
        if '=' in line:
            k, v = line.split('=', 1)
            try:
                out[k] = float(v)
            except ValueError:
                pass
    return out


def save_state(state: dict[str, float]) -> None:
    STATE.write_text(''.join(f'{k}={v}\n' for k, v in sorted(state.items())))


def upload(path: Path, tok: str) -> None:
    slug = path.stem
    req = urllib.request.Request(
        f'{API.rstrip("/")}/admin/word_images/{slug}',
        data=path.read_bytes(),
        method='PUT',
        headers={
            'Authorization': f'Bearer {tok}',
            'Content-Type': 'image/jpeg',
        },
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        resp.read()


def main() -> None:
    tok = token()
    state = load_state()
    print(f'Watching {IMG_DIR}', flush=True)
    while True:
        changed = []
        for path in sorted(IMG_DIR.glob('*.jpg')):
            mtime = path.stat().st_mtime
            if state.get(path.name) != mtime:
                changed.append((path, mtime))
        for path, mtime in changed:
            try:
                upload(path, tok)
                state[path.name] = mtime
                save_state(state)
                print(f'uploaded {path.name}', flush=True)
            except Exception as e:  # noqa: BLE001
                print(f'FAIL {path.name}: {e}', flush=True)
                time.sleep(1)
        time.sleep(8)


if __name__ == '__main__':
    main()
