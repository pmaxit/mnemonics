# Raspberry Pi + QEMU pipeline for Mnemonics

This directory contains everything needed to build the Mnemonics Flutter app
for **64-bit Raspberry Pi (Pi 4 / Pi 5 on arm64 Pi OS)** and verify it
launches and autostarts inside a QEMU arm64 virtual machine.

## What you get

- `scripts/pi/build-on-pi.sh` — builds a Flutter Linux **release** bundle
  natively on any arm64 Linux (real Pi or QEMU VM).
- `scripts/pi/install-autostart.sh` — installs the bundle under `/opt/mnemonics`
  and registers two autostart mechanisms:
  - `/etc/xdg/autostart/mnemonics.desktop` — fires on every LXDE / labwc
    desktop login (this is what real Pi OS Desktop reads).
  - `/etc/systemd/user/mnemonics.service` — alternative systemd user unit
    for headless or kiosk setups.
- `scripts/qemu/*` — provision an arm64 Linux VM in QEMU, push this repo
  into it, build, and autostart, so you can see the app render before
  touching real hardware.

## Verified result

Tested end-to-end on x86_64 host with QEMU 9.2 (TCG, no KVM). Two boot modes
are supported:

**1. Desktop mode** — LXDE + LightDM autostart via the `.desktop` entry:

![Mnemonics autostarted on arm64 QEMU (LXDE)](../docs/qemu/mnemonics-on-arm64-qemu.png)

**2. Kiosk mode** — pure Xorg, no window manager, no taskbar. App is the only
X client. Enable with `sudo scripts/pi/install-kiosk.sh`:

![Mnemonics kiosk on arm64 QEMU (no WM)](../docs/qemu/mnemonics-kiosk-on-arm64-qemu.png)

In kiosk mode the process tree is just:

```
xinit /opt/mnemonics/mnemonics -- :0 vt1 -keeptty -nolisten tcp -novtswitch
 └─ /usr/lib/xorg/Xorg :0 vt1 ...
 └─ /opt/mnemonics/mnemonics       (MNEMONICS_KIOSK=1 -> fullscreen, no decorations)
```

`lightdm`, `lxsession`, `openbox`, and `getty@tty1` are all disabled.

## Honest caveats

1. **Firebase / Google Sign-In / Apple Sign-In / video_player** have no Linux
   implementation. The desktop build skips Firebase entirely and acts as a
   single-user local installation (see `lib/core/platform/desktop_compat.dart`).
   The mobile (Android / iOS) build is unchanged and still uses the full auth
   stack.
2. The QEMU VM uses a **Debian 12 arm64 cloud image** with LXDE installed,
   booted under `qemu-system-aarch64 -M virt`. This is the standard,
   reliable QEMU arm64 workflow. Real Pi OS arm64 *can* be booted under
   QEMU `-M raspi4b`, but it is capped at 2 GB RAM and has no GPU, which
   makes building Flutter inside it impractical. The arm64 binary you
   produce in QEMU is byte-for-byte the same one you deploy on a real
   Pi 4 / Pi 5 running Pi OS arm64 — the autostart files are designed for
   Pi OS's LXDE / labwc session and work unchanged.
3. First QEMU boot + provision (Flutter SDK download + LXDE install + full
   release build under TCG emulation on an x86 host) takes **30 minutes
   to a couple of hours**. There is no avoiding this — it is emulating an
   arm CPU on x86.
4. The QEMU host's `qemu-system-aarch64` typically cannot expose hardware
   GL to the guest (virglrenderer is rarely wired through). `provision.sh`
   therefore enables `LIBGL_ALWAYS_SOFTWARE=1` for the autostarted app
   inside the VM so Flutter paints via Mesa llvmpipe. On a real Pi 4/5
   this env var is left unset and hardware GL is used automatically.
5. `lightdm` autologins only on the *first* greeter run after configuration.
   If you log out inside the VM, the next session needs a manual `pi` /
   `raspberry` login (this only matters for QEMU; on a real Pi the boot
   sequence is what you'd test). Sending the password through the QEMU
   monitor:
   ```sh
   ( exec 3<>/dev/tcp/127.0.0.1/5556
     for c in p i; do printf 'sendkey %s\n' "$c" >&3; sleep 0.05; done
     printf 'sendkey tab\n' >&3
     for c in r a s p b e r r y; do printf 'sendkey %s\n' "$c" >&3; sleep 0.05; done
     printf 'sendkey ret\n' >&3
     sleep 1; exec 3<&- 3>&- )
   ```

## End-to-end

Host prerequisites (Debian/Ubuntu):

```sh
sudo apt-get install -y \
  qemu-system-arm qemu-utils qemu-efi-aarch64 \
  cloud-image-utils openssh-client rsync curl imagemagick
```

Then:

```sh
# 1. Prepare disk image, UEFI, SSH key, cloud-init seed.
scripts/qemu/setup.sh

# 2. Boot the VM in the background.
scripts/qemu/run.sh --daemon

# 3. Push the repo, install Flutter + LXDE, build the app, install autostart.
#    First run downloads Flutter SDK and runs a release build in emulation;
#    expect 30-120 min.
scripts/qemu/provision.sh

# 4. Capture the running display.
scripts/qemu/screenshot.sh   # -> scripts/qemu/.work/screen.png

# Or interactively, connect a VNC viewer to localhost:5901 .
```

To stop the VM:

```sh
kill "$(cat scripts/qemu/.work/qemu.pid)"
```

## Deploying to a real Raspberry Pi

On a Pi 4 / Pi 5 running Pi OS arm64 (Desktop edition):

```sh
sudo apt-get update
git clone <this-repo> ~/mnemonics
cd ~/mnemonics
./scripts/pi/build-on-pi.sh         # 5-30 min on real hardware
sudo ./scripts/pi/install-autostart.sh
sudo reboot                         # app appears at next desktop login
```

For a true **kiosk** boot (no desktop, no window manager, app fills screen
from `boot → systemd → Xorg → mnemonics`):

```sh
./scripts/pi/build-on-pi.sh
sudo ./scripts/pi/install-autostart.sh
sudo ./scripts/pi/install-kiosk.sh   # removes LightDM, masks getty@tty1
sudo reboot
# revert with: sudo ./scripts/pi/install-kiosk.sh --disable
```

If you want the app to also start under a pure systemd user session
(e.g. an existing LXDE setup with no greeter), enable the user service:

```sh
systemctl --user daemon-reload
systemctl --user enable --now mnemonics.service
```

## File map

| Path | Purpose |
| --- | --- |
| `lib/core/platform/desktop_compat.dart` | Platform shim: skips Firebase + auto-logs in a local user on Linux. |
| `lib/main.dart` | Skips `Firebase.initializeApp` on Linux; tolerant `.env` load. |
| `lib/app.dart` | Linux branch builds a router that lands directly on `/main/home`. |
| `lib/features/auth/providers/user_profile_provider.dart` | Linux branch returns a pre-onboarded local `UserProfile`. |
| `lib/features/home/providers.dart` | Uses local user id on Linux instead of `FirebaseAuth.currentUser`. |
| `lib/features/auth/infrastructure/auth_repository.dart` | `firebaseAuthProvider` throws a clear error if read on Linux. |
| `lib/features/study_session/infrastructure/study_plan_repository.dart` | Uses local user id on Linux. |
| `scripts/pi/build-on-pi.sh` | Native arm64 build script. |
| `scripts/pi/install-autostart.sh` | Installs bundle + autostart files. |
| `scripts/pi/install-kiosk.sh` | Switches the system to kiosk: bare Xorg + Flutter, no WM. |
| `scripts/pi/mnemonics.desktop` | XDG autostart for Pi OS desktop sessions. |
| `scripts/pi/mnemonics.service` | systemd user unit for headless / kiosk. |
| `scripts/pi/mnemonics-kiosk.service` | systemd system unit: `xinit → Xorg → mnemonics` on tty1. |
| `linux/my_application.cc` | GTK shell — reads `MNEMONICS_KIOSK=1` to drop decorations + go fullscreen. |
| `scripts/qemu/setup.sh` | Downloads + prepares Debian arm64 disk + cloud-init. |
| `scripts/qemu/run.sh` | Boots the VM (foreground, daemon, or headless). |
| `scripts/qemu/provision.sh` | rsyncs repo, installs Flutter, builds, sets autostart. |
| `scripts/qemu/screenshot.sh` | Captures the QEMU display to PNG. |
