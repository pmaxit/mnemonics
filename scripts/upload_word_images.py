#!/usr/bin/env python3
"""Upload local comic word images to the Railway mnemonics-api volume.

Usage:
  IMAGE_UPLOAD_TOKEN=... python3 scripts/upload_word_images.py
  python3 scripts/upload_word_images.py --dir assets/word_images --workers 8
"""

from __future__ import annotations

import argparse
import os
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DIR = ROOT / 'generated' / 'word_images'
DEFAULT_API = 'https://mnemonics-api-production.up.railway.app'


def load_token() -> str:
    token = os.environ.get('IMAGE_UPLOAD_TOKEN', '').strip()
    if token:
        return token
    env = ROOT / '.env'
    if env.exists():
        for line in env.read_text().splitlines():
            if line.startswith('IMAGE_UPLOAD_TOKEN='):
                return line.split('=', 1)[1].strip().strip('"').strip("'")
    raise SystemExit('IMAGE_UPLOAD_TOKEN required')


def upload_one(api: str, token: str, path: Path) -> tuple[str, str]:
    slug = path.stem
    url = f'{api.rstrip("/")}/admin/word_images/{slug}'
    data = path.read_bytes()
    req = urllib.request.Request(
        url,
        data=data,
        method='PUT',
        headers={
            'Authorization': f'Bearer {token}',
            'Content-Type': 'image/jpeg',
            'Content-Length': str(len(data)),
        },
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        body = resp.read().decode('utf-8', errors='replace')
        return slug, f'{resp.status} {body[:120]}'


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--dir', type=Path, default=DEFAULT_DIR)
    parser.add_argument('--api', default=os.environ.get('API_BASE', DEFAULT_API))
    parser.add_argument('--workers', type=int, default=6)
    parser.add_argument('--limit', type=int, default=0)
    args = parser.parse_args()

    token = load_token()
    files = sorted(args.dir.glob('*.jpg'))
    if args.limit > 0:
        files = files[: args.limit]
    if not files:
        print(f'No jpg files in {args.dir}')
        return 1

    print(f'Uploading {len(files)} images to {args.api}', flush=True)
    ok = fail = 0
    with ThreadPoolExecutor(max_workers=max(1, args.workers)) as pool:
        futures = {pool.submit(upload_one, args.api, token, p): p for p in files}
        done = 0
        for fut in as_completed(futures):
            done += 1
            path = futures[fut]
            try:
                slug, msg = fut.result()
                ok += 1
                print(f'[{done}/{len(files)}] ok {slug} {msg}', flush=True)
            except Exception as e:  # noqa: BLE001
                fail += 1
                print(f'[{done}/{len(files)}] FAIL {path.name}: {e}', flush=True)
                time.sleep(0.2)

    print(f'Done ok={ok} fail={fail}', flush=True)
    return 0 if fail == 0 else 2


if __name__ == '__main__':
    sys.exit(main())
