#!/usr/bin/env bash
# Convert the system to kiosk mode: boot straight into the Mnemonics
# Flutter app on a bare Xorg server, with no window manager, no LightDM,
# no LXDE panel. Reversible with --disable.
#
# Run on the Pi after build-on-pi.sh + install-autostart.sh have placed
# the app under /opt/mnemonics.
#
#   sudo ./scripts/pi/install-kiosk.sh           # enable kiosk
#   sudo ./scripts/pi/install-kiosk.sh --disable # revert to LightDM/LXDE
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

if [ "$(id -u)" -ne 0 ]; then
  exec sudo --preserve-env=PATH "$0" "$@"
fi

MODE="${1:-enable}"

case "$MODE" in
  --disable|disable)
    echo "[kiosk] disabling kiosk mode"
    systemctl disable --now mnemonics-kiosk.service || true
    rm -f /etc/systemd/system/mnemonics-kiosk.service
    # Re-enable a display manager if present, otherwise leave multi-user.
    if systemctl list-unit-files | grep -q '^lightdm\.service'; then
      systemctl enable --now lightdm.service || true
      systemctl set-default graphical.target
    fi
    systemctl daemon-reload
    echo "[kiosk] done. Reboot to confirm."
    exit 0
    ;;
  enable|"") ;;
  *) echo "Unknown arg: $MODE (use --disable)" >&2; exit 2 ;;
esac

[ -x /opt/mnemonics/mnemonics ] || {
  echo "Mnemonics not installed at /opt/mnemonics. Run install-autostart.sh first." >&2
  exit 1
}

# 1. Minimal X server + utilities. Skip lxde-core, lightdm, openbox.
echo "[kiosk] installing minimal X stack"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  xserver-xorg-core xserver-xorg-input-libinput xserver-xorg-input-evdev \
  xserver-xorg-video-modesetting xserver-xorg-video-fbdev \
  xinit x11-xserver-utils \
  libgl1-mesa-dri libglx-mesa0

# 2. Allow non-root users to start X on tty1.
#    (Debian ships /etc/X11/Xwrapper.config with allowed_users=console which
#    needs the user to own the tty; root or systemd-launched processes fail
#    without this override.)
install -D -m 0644 /dev/stdin /etc/X11/Xwrapper.config <<'EOF'
allowed_users=anybody
needs_root_rights=yes
EOF

# 3. Disable competing display managers + the tty1 getty (the kiosk owns it).
systemctl disable --now lightdm.service 2>/dev/null || true
systemctl disable --now gdm.service 2>/dev/null || true
systemctl disable --now sddm.service 2>/dev/null || true
systemctl mask getty@tty1.service

# 4. Install the kiosk unit and enable it.
install -D -m 0644 "$REPO_ROOT/scripts/pi/mnemonics-kiosk.service" \
  /etc/systemd/system/mnemonics-kiosk.service
systemctl daemon-reload
systemctl set-default graphical.target
systemctl enable mnemonics-kiosk.service

# 5. Also remove the desktop-session autostart entry so we don't double-launch
#    if the user ever logs into a graphical session manually.
rm -f /etc/xdg/autostart/mnemonics.desktop

cat <<EOF

[kiosk] enabled. On next boot the Pi will go straight to the Mnemonics
        app fullscreen on /dev/tty1 with no window manager.

To start it now without rebooting:
    sudo systemctl isolate multi-user.target  # stop any active GUI first
    sudo systemctl start mnemonics-kiosk.service

To revert:
    sudo $0 --disable

EOF
