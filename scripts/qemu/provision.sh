#!/usr/bin/env bash
# Wait for the QEMU VM (started by run.sh --daemon) to accept SSH, then
# rsync this repo into the VM, install LXDE + Flutter, build the app for
# arm64, install the autostart entry, and start a desktop session so the
# app appears on the VNC display.
#
# Usage: scripts/qemu/provision.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$HERE/.work"
REPO="$(cd "$HERE/../.." && pwd)"

SSH_KEY="$WORK/ssh_id"
SSH_OPTS=(-i "$SSH_KEY" -p 5022
  -o UserKnownHostsFile=/dev/null
  -o StrictHostKeyChecking=no
  -o LogLevel=ERROR
  -o ConnectTimeout=5)
SSH=(ssh "${SSH_OPTS[@]}" pi@127.0.0.1)
SCP=(scp "${SSH_OPTS[@]}")
RSYNC_RSH="ssh ${SSH_OPTS[*]}"

# --- 1. Wait for SSH (cloud-init can take a few minutes on first boot) ---
echo "[provision] waiting for VM SSH (up to 10 min for first boot)..."
for i in $(seq 1 120); do
  if "${SSH[@]}" -o BatchMode=yes true 2>/dev/null; then
    echo "[provision] SSH up after ${i}*5s"
    break
  fi
  sleep 5
  if [ "$i" -eq 120 ]; then echo "[provision] SSH never came up" >&2; exit 1; fi
done

# --- 2. Push the repo into the VM. Exclude build/ and .dart_tool/ to keep small ---
echo "[provision] syncing repo to VM:/home/pi/mnemonics ..."
"${SSH[@]}" 'mkdir -p ~/mnemonics'
rsync -az --delete \
  -e "$RSYNC_RSH" \
  --exclude '.git/' \
  --exclude 'build/' \
  --exclude '.dart_tool/' \
  --exclude 'scripts/qemu/.work/' \
  --exclude 'output/' \
  "$REPO"/ pi@127.0.0.1:/home/pi/mnemonics/

# --- 3. Install desktop env + run build + install autostart ---
echo "[provision] running build-on-pi + install-autostart in VM (~30-60 min on first run)"
"${SSH[@]}" 'bash -s' <<'REMOTE'
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
# 1. Replace the minimal cloud kernel with the full Debian arm64 kernel
#    so virtio-gpu / DRM modules are available (needed for X to start).
if ! dpkg -l linux-image-arm64 2>/dev/null | grep -q ^ii; then
  sudo apt-get install -y -qq linux-image-arm64
  # Default GRUB to the full kernel.
  sudo sed -i 's|^GRUB_DEFAULT=.*|GRUB_DEFAULT="Advanced options for Debian GNU/Linux>Debian GNU/Linux, with Linux 6.1.0-49-arm64"|' /etc/default/grub || true
  sudo update-grub
  echo "[remote] rebooting into full kernel..."
  ( sleep 1 ; sudo systemctl reboot ) &
  exit 99   # signal "please reboot then re-run"
fi

# 2. Bring up a lightweight X desktop similar in spirit to Pi OS Desktop (LXDE).
sudo apt-get install -y --no-install-recommends \
  xserver-xorg xinit \
  lxde-core lxsession lxpanel pcmanfm openbox \
  lightdm lightdm-gtk-greeter \
  accountsservice \
  x11-utils x11-xserver-utils xdotool \
  libgl1-mesa-dri libglx-mesa0 mesa-utils \
  imagemagick \
  rsync

# accountsservice is what lightdm queries for the user list.
sudo systemctl enable --now accounts-daemon
sudo mkdir -p /var/lib/lightdm/data
sudo chown -R lightdm:lightdm /var/lib/lightdm

# 3. Run the same build script we'd use on real Pi hardware.
cd ~/mnemonics
chmod +x scripts/pi/build-on-pi.sh scripts/pi/install-autostart.sh
./scripts/pi/build-on-pi.sh
sudo ./scripts/pi/install-autostart.sh

# 4. Force software GL inside the QEMU guest only. (Real Pi has HW GL and
#    leaves this unset; the .desktop entry uses ${MNEMONICS_FORCE_SOFT_GL:-0}.)
echo 'MNEMONICS_FORCE_SOFT_GL=1' | sudo tee /etc/environment.d/99-mnemonics-qemu.conf >/dev/null || true
echo 'MNEMONICS_FORCE_SOFT_GL=1' | sudo tee -a /etc/environment >/dev/null

# 5. Autologin pi into LXDE so the autostart .desktop entry fires without
#    a user typing a password.
sudo systemctl set-default graphical.target
sudo mkdir -p /etc/lightdm/lightdm.conf.d
sudo tee /etc/lightdm/lightdm.conf.d/50-autologin.conf >/dev/null <<EOF
[Seat:*]
autologin-user=pi
autologin-user-timeout=0
autologin-session=LXDE
user-session=LXDE
EOF
sudo groupadd -f autologin
sudo gpasswd -a pi autologin || true

# 6. Disable DPMS/screensaver so the QEMU framebuffer keeps painting.
sudo tee /etc/X11/Xsession.d/45disable-dpms >/dev/null <<'EOF'
xset s off -dpms s noblank 2>/dev/null || true
EOF
sudo chmod +x /etc/X11/Xsession.d/45disable-dpms

# Bring graphical target up now.
sudo systemctl reset-failed lightdm || true
sudo systemctl isolate graphical.target || true
REMOTE
RC=$?
if [ "$RC" = 99 ]; then
  echo "[provision] VM is rebooting into the full arm64 kernel; waiting..."
  sleep 30
  for i in $(seq 1 60); do
    if "${SSH[@]}" -o BatchMode=yes 'uname -r' 2>/dev/null | grep -qv cloud; then
      echo "[provision] back up on full kernel; re-running provisioner"
      exec "$0" "$@"
    fi
    sleep 5
  done
  echo "[provision] VM did not come back up cleanly" >&2
  exit 1
fi

echo ""
echo "[provision] done. Watch the app at vnc://127.0.0.1:5901"
echo "             screenshot with: scripts/qemu/screenshot.sh"
