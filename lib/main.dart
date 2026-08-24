import 'dart:async';
import 'dart:io' show Directory, Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'common/design/theme_provider.dart';
import 'core/platform/desktop_compat.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'features/home/domain/user_word_data.dart';
import 'features/home/domain/user_settings.dart';
import 'features/home/domain/review_activity.dart';
import 'features/profile/domain/user_statistics.dart';
import 'core/services/notification_service.dart';
import 'common/widgets/notification_display.dart';
import 'common/widgets/notification_listener.dart';
import 'app.dart';

/// Resolve a writable directory for Hive data. On Linux/Pi the standard
/// XDG user dirs may not be configured (minimal Pi OS, fresh sessions),
/// in which case [getApplicationDocumentsDirectory] throws. Fall back to
/// `$XDG_DATA_HOME/mnemonics` (or `$HOME/.local/share/mnemonics`).
Future<Directory> _resolveHiveDir() async {
  try {
    return await getApplicationDocumentsDirectory();
  } catch (_) {
    if (Platform.isLinux) {
      final home = Platform.environment['HOME'] ?? '/tmp';
      final base = Platform.environment['XDG_DATA_HOME'] ?? '$home/.local/share';
      final dir = Directory('$base/mnemonics');
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase plugins (firebase_core, firebase_auth, google_sign_in,
  // sign_in_with_apple) have no Linux implementation. Skip init on Linux
  // so the desktop/Pi build can launch; auth is bypassed in app.dart.
  if (!desktopAuthBypass) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  // The .env asset is optional on desktop demo builds; missing file
  // should not crash the app.
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // ignore: noop, dotenv lookups will fall back to empty values.
  }
  final appDocDir = await _resolveHiveDir();
  Hive.init(appDocDir.path);
  // Clear old user_word_data box to prevent type errors from legacy data
  //await Hive.deleteBoxFromDisk('user_word_data');
  Hive.registerAdapter(UserWordDataAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(ReviewActivityAdapter());
  Hive.registerAdapter(LearningStageAdapter());
  Hive.registerAdapter(ReviewDifficultyRatingAdapter());
  
  runApp(
    const ProviderScope(
      child: MnemonicsApp(),
    ),
  );
  // Do not block first frame on APNs/FCM — iOS permission and token
  // fetch can stall until the OS dialog is dismissed.
  unawaited(NotificationService().initialize());
}

class MnemonicsApp extends ConsumerWidget {
  const MnemonicsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);

    return MaterialApp.router(
      title: 'Mnemonics',
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final content = NotificationDisplay(child: child!);
        if (desktopAuthBypass) return content;
        return FcmNotificationListener(child: content);
      },
    );
  }
}
