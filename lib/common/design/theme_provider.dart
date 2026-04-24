import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'design_system.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        state = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        state = ThemeMode.system;
        break;
      case ThemeMode.system:
        state = ThemeMode.light;
        break;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

@riverpod
ThemeData lightTheme(LightThemeRef ref) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: MnemonicsColors.primaryGreen,
      secondary: MnemonicsColors.secondaryOrange,
      surface: MnemonicsColors.surface,
    ),
    textTheme: const TextTheme(
      displayLarge: MnemonicsTypography.headingLarge,
      displayMedium: MnemonicsTypography.headingMedium,
      bodyLarge: MnemonicsTypography.bodyLarge,
      bodyMedium: MnemonicsTypography.bodyRegular,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
      ),
      color: MnemonicsColors.background,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MnemonicsColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(MnemonicsSpacing.m),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      centerTitle: true,
      iconTheme: const IconThemeData(
        color: MnemonicsColors.textPrimary,
        size: 22,
      ),
      titleTextStyle: MnemonicsTypography.headingMedium.copyWith(
        color: MnemonicsColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    ),
  );
}

@riverpod
ThemeData darkTheme(DarkThemeRef ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: MnemonicsColors.primaryGreen,
      secondary: MnemonicsColors.secondaryOrange,
      surface: Color(0xFF1E1E1E),
    ),
    textTheme: TextTheme(
      displayLarge: MnemonicsTypography.headingLarge.copyWith(color: Colors.white),
      displayMedium: MnemonicsTypography.headingMedium.copyWith(color: Colors.white),
      bodyLarge: MnemonicsTypography.bodyLarge.copyWith(color: Colors.white),
      bodyMedium: MnemonicsTypography.bodyRegular.copyWith(color: Colors.white),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
      ),
      color: const Color(0xFF1E1E1E),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MnemonicsSpacing.radiusXL),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(MnemonicsSpacing.m),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      centerTitle: true,
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 22,
      ),
      titleTextStyle: MnemonicsTypography.headingMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    ),
  );
} 