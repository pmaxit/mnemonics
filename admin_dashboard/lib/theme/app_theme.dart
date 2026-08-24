import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF5B3DF6);
  static const primarySoft = Color(0xFFEEF0FF);
  static const bg = Color(0xFFF7F7FB);
  static const card = Colors.white;
  static const text = Color(0xFF1A1A2E);
  static const muted = Color(0xFF6B7280);

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary, surface: card),
    appBarTheme: const AppBarTheme(backgroundColor: card, elevation: 0, foregroundColor: text),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}
