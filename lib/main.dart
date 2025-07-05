import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'common/design/theme_provider.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/practice/presentation/screens/practice_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'features/home/domain/user_word_data.dart';
import 'features/home/presentation/screens/main_scaffold.dart';
import 'features/home/domain/user_settings.dart';
import 'features/home/domain/review_activity.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  Hive.registerAdapter(UserWordDataAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(ReviewActivityAdapter());
  runApp(
    const ProviderScope(
      child: MnemonicsApp(),
    ),
  );
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
    );
  }
}
