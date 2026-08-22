#!/usr/bin/env bash
# Boot the arm64 QEMU VM prepared by setup.sh.
#
# Modes:
#   ./run.sh             # foreground, VNC display on :1 (port 5901), monitor on :5556
#   ./run.sh --gui       # foreground, native QEMU window (GTK), keyboard+mouse
#   ./run.sh --headless  # serial console only, no graphics, useful for CI
#   ./run.sh --daemon    # background; pid written to .work/qemu.pid (VNC display)
#
# Forwarded ports on localhost:
#   5022 -> 22   (ssh)
#   5556          QEMU monitor (TCP)
#   5901          VNC (display :1)  -- VNC modes only
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$HERE/.work"

[ -f "$WORK/debian-arm64.qcow2" ] || { echo "Run setup.sh first." >&2; exit 1; }
[ -f "$WORK/QEMU_EFI.fd"        ] || { echo "Run setup.sh first." >&2; exit 1; }
[ -f "$WORK/seed.iso"           ] || { echo "Run setup.sh first." >&2; exit 1; }

MODE="${1:-foreground}"

# Use KVM only if host is arm64; on x86_64 we're emulating, no acceleration.
ACCEL_ARGS=(-cpu cortex-a72 -machine virt,gic-version=3)
if [ "$(uname -m)" = "aarch64" ] && [ -e /dev/kvm ]; then
  ACCEL_ARGS=(-enable-kvm -cpu host -machine virt,gic-version=host)
fi

# Detect physical core count for -smp; cap at 4 (more wastes for emulation).
SMP=$(nproc 2>/dev/null || echo 4)
[ "$SMP" -gt 4 ] && SMP=4

# Prefer GL-accelerated virtio-gpu (Flutter's GL surface paints correctly with
# this). Falls back to plain virtio-gpu-pci if libvirglrenderer is missing
# on the host, in which case windows open but stay black until a software
# rasteriser is plugged in.
GPU_ARGS=(-device virtio-gpu-pci)
DISPLAY_GL=""
if ldconfig -p 2>/dev/null | grep -q libvirglrenderer; then
  GPU_ARGS=(-device virtio-gpu-gl-pci)
  DISPLAY_GL=",gl=on"
fi

COMMON_ARGS=(
  "${ACCEL_ARGS[@]}"
  -m 4096 -smp "$SMP"
  -drive if=pflash,format=raw,readonly=on,file="$WORK/QEMU_EFI.fd"
  -drive if=pflash,format=raw,file="$WORK/VARS.fd"
  -drive if=virtio,format=qcow2,file="$WORK/debian-arm64.qcow2"
  -drive if=virtio,format=raw,file="$WORK/seed.iso"
  -device virtio-net-pci,netdev=n0
  -netdev user,id=n0,hostfwd=tcp::5022-:22
  "${GPU_ARGS[@]}"
  -device qemu-xhci -device usb-kbd -device usb-tablet
  -monitor tcp::5556,server=on,wait=off
  -name mnemonics-pi
)

case "$MODE" in
  --headless)
    echo "[run] headless boot, serial on stdout"
    exec qemu-system-aarch64 "${COMMON_ARGS[@]}" -nographic
    ;;
  --gui)
    echo "[run] foreground GUI; native QEMU window (GTK), monitor on tcp:5556, ssh on tcp:5022"
    # GTK display gives a real window with keyboard/mouse capture. gl=on uses
    # virglrenderer when available; otherwise GTK falls back gracefully.
    exec qemu-system-aarch64 "${COMMON_ARGS[@]}" \
      -display "gtk${DISPLAY_GL}" \
      -serial mon:stdio
    ;;
  --daemon)
    echo "[run] daemonising (logs in $WORK/qemu.log)"
    nohup qemu-system-aarch64 "${COMMON_ARGS[@]}" \
      -display "vnc=:1${DISPLAY_GL}" \
      -serial file:"$WORK/qemu.log" \
      </dev/null >>"$WORK/qemu.log" 2>&1 &
    echo $! > "$WORK/qemu.pid"
    echo "[run] pid $(cat "$WORK/qemu.pid")  vnc 127.0.0.1:5901  ssh 127.0.0.1:5022  monitor 127.0.0.1:5556"
    ;;
  *)
    echo "[run] foreground; VNC on :1 (port 5901), monitor on tcp:5556, ssh on tcp:5022"
    exec qemu-system-aarch64 "${COMMON_ARGS[@]}" \
      -display "vnc=:1${DISPLAY_GL}" \
      -serial mon:stdio
    ;;
esac
