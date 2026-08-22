#!/usr/bin/env bash
# Install the built Mnemonics bundle into /opt and register a desktop-session
# autostart entry so the app launches when the Pi user logs into the desktop.
#
# Run on the Pi after build-on-pi.sh has finished:
#   sudo ./scripts/pi/install-autostart.sh
#
# Layout:
#   /opt/mnemonics/                        copy of build bundle
#   /etc/xdg/autostart/mnemonics.desktop   system-wide LXDE/labwc autostart
#   /usr/local/bin/mnemonics               launcher symlink
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

ARCH="$(uname -m | sed 's/aarch64/arm64/;s/armv7l/arm/;s/x86_64/x64/')"
BUNDLE_SRC="build/linux/$ARCH/release/bundle"

if [ ! -x "$BUNDLE_SRC/mnemonics" ]; then
  echo "No release bundle at $BUNDLE_SRC. Run scripts/pi/build-on-pi.sh first." >&2
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "Re-running with sudo..."
  exec sudo --preserve-env=PATH "$0" "$@"
fi

INSTALL_DIR=/opt/mnemonics
echo "[install] copying bundle to $INSTALL_DIR"
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cp -r "$BUNDLE_SRC"/. "$INSTALL_DIR"/
chmod +x "$INSTALL_DIR/mnemonics"

echo "[install] symlinking /usr/local/bin/mnemonics"
ln -sf "$INSTALL_DIR/mnemonics" /usr/local/bin/mnemonics

echo "[install] writing /etc/xdg/autostart/mnemonics.desktop"
install -D -m 0644 "$REPO_ROOT/scripts/pi/mnemonics.desktop" \
  /etc/xdg/autostart/mnemonics.desktop

echo "[install] writing systemd user service (for headless / non-desktop boots)"
install -D -m 0644 "$REPO_ROOT/scripts/pi/mnemonics.service" \
  /etc/systemd/user/mnemonics.service

cat <<EOF

Done.

To enable autostart on desktop login (LXDE / labwc), the .desktop entry in
/etc/xdg/autostart/ takes effect immediately — just reboot or log out and
back in.

To enable as a systemd *user* service (auto-starts on session login):
    systemctl --user daemon-reload
    systemctl --user enable --now mnemonics.service

EOF
