#!/usr/bin/env bash
# Build the Mnemonics Flutter app for the current (Pi / arm64 Linux) host.
#
# Designed to be run *inside* the Raspberry Pi (or an arm64 QEMU guest).
# Cross-compiling Flutter Linux for arm64 from an x86 host is non-trivial
# and brittle, so we build natively on the target.
#
# Usage:
#   sudo apt-get update
#   ./scripts/pi/build-on-pi.sh
#
# Result:
#   build/linux/arm64/release/bundle/  -- the runnable bundle, ~80MB
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

log() { printf '\033[1;36m[build-on-pi]\033[0m %s\n' "$*"; }

# --- 1. System dependencies needed by the Flutter Linux embedder + build ---
APT_PKGS=(
  curl git unzip xz-utils zip
  clang cmake ninja-build pkg-config
  libgtk-3-dev liblzma-dev libstdc++-12-dev
  # Wayland/X libraries; harmless if already pulled in by libgtk-3-dev
  libgl1-mesa-dri
)

if command -v apt-get >/dev/null 2>&1; then
  log "installing build dependencies (apt)"
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends "${APT_PKGS[@]}"
fi

# --- 2. Ensure Flutter SDK is on PATH ---
FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"
if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -d "$FLUTTER_DIR" ]; then
    log "cloning Flutter SDK (stable) to $FLUTTER_DIR"
    git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
  fi
  export PATH="$FLUTTER_DIR/bin:$PATH"
fi
log "flutter: $(flutter --version | head -1)"

# --- 3. Enable Linux desktop target + fetch packages ---
flutter config --enable-linux-desktop >/dev/null
flutter pub get

# --- 4. Build release bundle. On arm64 Pi this produces an arm64 binary. ---
log "building release bundle (this can take 5-30 min on a Pi)"
flutter build linux --release

OUT="build/linux/$(uname -m | sed 's/aarch64/arm64/;s/armv7l/arm/;s/x86_64/x64/')/release/bundle"
if [ ! -x "$OUT/mnemonics" ]; then
  echo "Build produced no binary at $OUT/mnemonics" >&2
  exit 1
fi
log "OK -> $OUT/mnemonics"
ls -la "$OUT/mnemonics"
