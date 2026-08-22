#!/usr/bin/env bash
# Prepare an arm64 QEMU disk image for building and running Mnemonics.
#
# Default: Debian 12 (bookworm) arm64 generic cloud image. We boot it under
# qemu-system-aarch64 -M virt, which is the reliable, GPU-less, scriptable
# arm64 QEMU workflow. The arm64 binary built inside this VM is byte-for-byte
# the same one you would deploy on a real Raspberry Pi 4/5 running Pi OS arm64.
#
# Outputs (all under scripts/qemu/.work/):
#   debian-arm64.qcow2     bootable VM disk (resized to ~24G)
#   QEMU_EFI.fd            UEFI firmware for the virt machine
#   seed.iso               cloud-init NoCloud datasource (user + ssh key)
#   ssh_id / ssh_id.pub    SSH key used to log into the VM
#
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$HERE/.work"
mkdir -p "$WORK"
cd "$WORK"

DEBIAN_URL="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-arm64.qcow2"
IMG=debian-arm64.qcow2

if [ ! -f "$IMG" ]; then
  echo "[setup] downloading Debian arm64 cloud image (~400MB)"
  curl -L --fail -o "$IMG.tmp" "$DEBIAN_URL"
  mv "$IMG.tmp" "$IMG"
fi

# Expand the disk so we have room for Flutter SDK (~2GB) + pub cache (~1GB)
# + build artifacts + LXDE packages.
echo "[setup] resizing disk to 24G"
qemu-img resize "$IMG" 24G >/dev/null

# Locate UEFI firmware for aarch64 virt board.
EFI_CANDIDATES=(
  /usr/share/qemu-efi-aarch64/QEMU_EFI.fd
  /usr/share/AAVMF/AAVMF_CODE.fd
  /usr/share/edk2/aarch64/QEMU_EFI.fd
)
EFI=""
for cand in "${EFI_CANDIDATES[@]}"; do
  if [ -f "$cand" ]; then EFI="$cand"; break; fi
done
if [ -z "$EFI" ]; then
  echo "[setup] no QEMU UEFI firmware found. Install with:" >&2
  echo "    sudo apt-get install qemu-efi-aarch64" >&2
  exit 1
fi
# Copy + pad to 64M as required by the virt machine.
cp "$EFI" QEMU_EFI.fd
truncate -s 64M QEMU_EFI.fd
truncate -s 64M VARS.fd

# Generate SSH key (no passphrase) for cloud-init to install.
if [ ! -f ssh_id ]; then
  ssh-keygen -t ed25519 -N "" -C "mnemonics-qemu" -f ssh_id
fi
PUBKEY="$(cat ssh_id.pub)"

# cloud-init: create user "pi" with our SSH key and passwordless sudo.
cat > user-data <<EOF
#cloud-config
hostname: mnemonics-pi
users:
  - name: pi
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: [sudo, video, audio, render]
    lock_passwd: false
    plain_text_passwd: raspberry
    ssh_authorized_keys:
      - $PUBKEY
ssh_pwauth: true
chpasswd:
  expire: false
# Pre-install just enough to bootstrap; the rest happens via provision.sh.
package_update: true
packages:
  - openssh-server
  - sudo
  - ca-certificates
  - rsync
runcmd:
  - systemctl enable --now ssh
EOF

cat > meta-data <<EOF
instance-id: mnemonics-pi-1
local-hostname: mnemonics-pi
EOF

# Build the NoCloud seed ISO (cloud-init reads cidata label).
if command -v cloud-localds >/dev/null 2>&1; then
  cloud-localds seed.iso user-data meta-data
elif command -v genisoimage >/dev/null 2>&1; then
  genisoimage -output seed.iso -volid cidata -joliet -rock user-data meta-data >/dev/null 2>&1
elif command -v xorriso >/dev/null 2>&1; then
  xorriso -as mkisofs -output seed.iso -volid cidata -joliet -rock user-data meta-data >/dev/null
else
  echo "[setup] need cloud-image-utils OR genisoimage OR xorriso. Install with:" >&2
  echo "    sudo apt-get install cloud-image-utils" >&2
  exit 1
fi

cat <<EOF

Setup complete. Files in: $WORK
  $IMG (24G qcow2 disk)
  QEMU_EFI.fd / VARS.fd (UEFI)
  seed.iso (cloud-init: user 'pi' / pass 'raspberry' + ssh key 'ssh_id')

Next:
  scripts/qemu/run.sh        # boot the VM (foreground, VNC :1, ssh on :5022)
  scripts/qemu/provision.sh  # install Flutter, build app, set autostart
EOF
