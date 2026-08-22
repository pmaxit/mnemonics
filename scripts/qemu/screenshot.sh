#!/usr/bin/env bash
# Capture the current QEMU display by sending `screendump` to the QEMU
# monitor (TCP 5556 from run.sh) and converting the resulting PPM to PNG.
#
# Usage:
#   scripts/qemu/screenshot.sh                 # -> scripts/qemu/.work/screen.png
#   scripts/qemu/screenshot.sh out.png
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$HERE/.work"
OUT="${1:-$WORK/screen.png}"

PPM="$WORK/screen.ppm"
rm -f "$PPM"

# Talk to the QEMU monitor (TCP 5556) and issue *only* `screendump`.
# Do NOT send `quit` -- that would terminate the whole VM.
exec 3<>/dev/tcp/127.0.0.1/5556
# Drain the banner (a couple of short lines).
read -r -t 2 _ <&3 || true
read -r -t 2 _ <&3 || true
printf 'screendump %s\n' "$PPM" >&3
# Wait for QEMU to write the file; the monitor prints "(qemu)" prompt when done.
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [ -s "$PPM" ] && break
  sleep 1
done
# Close the monitor connection cleanly (file descriptor close == disconnect).
exec 3<&- 3>&-

if [ ! -s "$PPM" ]; then
  echo "[screenshot] no PPM written. Is QEMU running and monitor on 5556?" >&2
  exit 1
fi

if command -v convert >/dev/null 2>&1; then
  convert "$PPM" "$OUT"
elif command -v ffmpeg >/dev/null 2>&1; then
  ffmpeg -y -loglevel error -i "$PPM" "$OUT"
else
  echo "[screenshot] need ImageMagick (convert) or ffmpeg to make PNG" >&2
  echo "[screenshot] PPM written to: $PPM" >&2
  exit 1
fi

ls -la "$OUT"
