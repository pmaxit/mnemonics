// Platform compatibility helpers for desktop targets (Linux / Raspberry Pi).
//
// The mobile build of this app depends on Firebase, google_sign_in, and
// sign_in_with_apple. None of those plugins have a Linux implementation,
// so on Linux we:
//   * skip Firebase.initializeApp,
//   * present the UI as if a default local user were already signed-in,
//   * skip onboarding so the app lands directly on /main/home.
//
// This file is the single source of truth for those decisions, so the
// behaviour can be flipped (e.g. in tests) by overriding [desktopAuthBypass].
import 'dart:io' show Platform;

/// True when the current process is running on a desktop/embedded Linux
/// target (which includes Raspberry Pi OS).
///
/// We intentionally do not bypass auth on macOS / Windows because the
/// mobile auth stack is expected to keep working there.
bool get isLinuxDesktop {
  try {
    return Platform.isLinux;
  } catch (_) {
    // dart:io is unavailable on web; in that case we are not "Linux desktop".
    return false;
  }
}

/// Whether the app should skip Firebase + auth and treat the user as
/// a local signed-in account. Currently equal to [isLinuxDesktop] but
/// kept as a separate symbol so tests / other entrypoints can override.
bool get desktopAuthBypass => isLinuxDesktop;

/// Stable local user id used in desktop bypass mode. The home screen,
/// study plan repository, etc. read this when no Firebase user is
/// available.
const String desktopLocalUserId = 'local-desktop-user';
