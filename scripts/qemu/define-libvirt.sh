#!/usr/bin/env bash
# Define (or redefine) the mnemonics-pi VM in libvirt's per-user session
# (qemu:///session) so it can be managed graphically by virt-manager.
#
# Why session mode? Avoids sudo, libvirt group, AppArmor and file-permission
# gymnastics: QEMU runs as you and accesses scripts/qemu/.work/ directly.
#
# Why no SSH port-forward? libvirt's default SLIRP user-mode network does
# not support <portForward>. Use virt-manager's console for interactive
# access, or install `passt` and switch the <interface> backend to it.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$HERE/.work"

[ -f "$WORK/debian-arm64.qcow2" ] || { echo "Run setup.sh first." >&2; exit 1; }
[ -f "$WORK/seed.iso"           ] || { echo "Run setup.sh first." >&2; exit 1; }

# Work around any active Python venv shadowing /usr/bin/env python3 used by
# virt-install's shebang.
SYS=(env -i
  HOME="$HOME" USER="$USER" PATH=/usr/bin:/bin
  DISPLAY="${DISPLAY:-}" XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
  WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}"
  XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
  LIBVIRT_DEFAULT_URI=qemu:///session
)

echo "[libvirt] removing any previous mnemonics-pi VM"
"${SYS[@]}" virsh destroy mnemonics-pi  2>/dev/null || true
"${SYS[@]}" virsh undefine --nvram mnemonics-pi 2>/dev/null || true

echo "[libvirt] defining mnemonics-pi"
"${SYS[@]}" virt-install \
  --connect qemu:///session \
  --name mnemonics-pi \
  --memory 4096 \
  --vcpus 4 \
  --arch aarch64 \
  --machine virt \
  --cpu cortex-a72 \
  --osinfo debian12 \
  --boot uefi \
  --disk path="$WORK/debian-arm64.qcow2",bus=virtio,format=qcow2 \
  --disk path="$WORK/seed.iso",bus=virtio,format=raw,readonly=on \
  --network user,model=virtio \
  --graphics vnc,listen=127.0.0.1,port=5901 \
  --video virtio \
  --controller usb,model=qemu-xhci \
  --input keyboard,bus=usb \
  --input tablet,bus=usb \
  --noautoconsole \
  --import

cat <<EOF

[libvirt] mnemonics-pi is defined and started.
          Console:  virt-viewer --connect qemu:///session mnemonics-pi
          GUI:      virt-manager --connect qemu:///session
          VNC:      127.0.0.1:5901
          List:     virsh --connect qemu:///session list --all

Common ops:
  virsh --connect qemu:///session shutdown mnemonics-pi
  virsh --connect qemu:///session destroy  mnemonics-pi   # force off
  virsh --connect qemu:///session start    mnemonics-pi
EOF
