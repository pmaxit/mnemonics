import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'common/design/theme_provider.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'features/home/domain/user_word_data.dart';
import 'features/home/domain/user_settings.dart';
import 'features/home/domain/review_activity.dart';
import 'features/profile/domain/user_statistics.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final appDocDir = await getApplicationDocumentsDirectory();
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
