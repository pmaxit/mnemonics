import 'package:flutter/material.dart';

/// Design system for the Mnemonics app
/// This file contains all the design tokens and styles used across the app
class MnemonicsDesign {
  // Colors
  static const Color primary = Color(0xFF4CAF8F); // Green from the UI
  static const Color secondary = Color(0xFFF4A261); // Orange accent
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkBorder = Color(0xFF404040);
  
  // Progress Colors
  static const Color progressGreen = Color(0xFF4CAF8F);
  static const Color progressPink = Color(0xFFF8BBD0);
  static const Color progressOrange = Color(0xFFF4A261);

  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static final BorderRadius borderRadiusS = BorderRadius.circular(radiusS);
  static final BorderRadius borderRadiusM = BorderRadius.circular(radiusM);
  static final BorderRadius borderRadiusL = BorderRadius.circular(radiusL);

  // Shadows
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // Card Styles
  static final CardTheme cardTheme = CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: borderRadiusM),
    color: background,
    margin: const EdgeInsets.all(spacingS),
  );

  // Button Styles
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
    shape: RoundedRectangleBorder(borderRadius: borderRadiusM),
    elevation: 2,
  );

  // Progress Indicator Styles
  static const double progressIndicatorHeight = 8.0;
  static const progressIndicatorTheme = ProgressIndicatorThemeData(
    color: primary,
    linearTrackColor: surface,
    linearMinHeight: progressIndicatorHeight,
    circularTrackColor: surface,
  );

  // Input Decoration
  static final inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: surface,
    border: OutlineInputBorder(
      borderRadius: borderRadiusM,
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.all(spacingM),
  );
}

/// Design system color constants for the Mnemonics app
class MnemonicsColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF4CAF8F);
  static const Color secondaryOrange = Color(0xFFF4A261);
  static const Color progressPink = Color(0xFFF8BBD0);

  // Background Colors
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8F9FA);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);

  // Semantic Colors
  static const Color success = primaryGreen;
  static const Color warning = secondaryOrange;
  static const Color progress = progressPink;

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000); // 10% black
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkBorder = Color(0xFF404040);

  // Elevation Overlays
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];
  
  // Dark theme shadows
  static const List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];
}

/// Extension methods for Color to support opacity modifications
extension ColorExtension on Color {
  Color withOpacity(double opacity) {
    return Color.fromRGBO(
      red,
      green,
      blue,
      opacity,
    );
  }
}

/// Typography styles for the Mnemonics app
class MnemonicsTypography {
  // Heading Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: MnemonicsColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    color: MnemonicsColors.textPrimary,
    height: 1.3,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
    color: MnemonicsColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: MnemonicsColors.textPrimary,
    height: 1.5,
  );

  // Helper method to create a responsive text style
  static TextStyle getResponsiveTextStyle(TextStyle baseStyle, BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseStyle;
    } else if (screenWidth < 960) {
      return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.1);
    } else {
      return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.2);
    }
  }
}

/// Spacing constants for consistent layout
class MnemonicsSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border radius constants
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;

  // Component specific spacing
  static const double buttonPaddingHorizontal = 16.0;
  static const double buttonPaddingVertical = 12.0;
  static const double cardPadding = 16.0;
  static const double bottomNavHeight = 56.0;
} 