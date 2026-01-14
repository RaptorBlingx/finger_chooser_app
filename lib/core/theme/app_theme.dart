// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium design system for Finger Chooser app
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ========== COLORS ==========

  /// Primary gradient colors - Purple to Pink
  static const Color primaryStart = Color(0xFF6B4FFF);
  static const Color primaryEnd = Color(0xFFFF4F8D);

  /// Secondary gradient colors - Blue to Cyan
  static const Color secondaryStart = Color(0xFF4F7AFF);
  static const Color secondaryEnd = Color(0xFF4FFFE5);

  /// Accent gradient colors - Orange to Red
  static const Color accentStart = Color(0xFFFF8F4F);
  static const Color accentEnd = Color(0xFFFF4F4F);

  /// Success gradient
  static const Color successStart = Color(0xFF4FFF8F);
  static const Color successEnd = Color(0xFF4FFFDA);

  /// Background colors
  static const Color backgroundDark = Color(0xFF0F0F1E);
  static const Color backgroundLight = Color(0xFF1A1A2E);
  static const Color cardBackground = Color(0xFF252538);
  static const Color cardBackgroundLight = Color(0xFF2D2D42);

  /// Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8CC);
  static const Color textTertiary = Color(0xFF8585A3);

  /// Status colors
  static const Color warning = Color(0xFFFFA94F);
  static const Color error = Color(0xFFFF4F6D);
  static const Color success = Color(0xFF4FFFA9);
  static const Color info = Color(0xFF4FA9FF);

  // ========== GRADIENTS ==========

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryStart, secondaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentStart, accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successStart, successEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Shimmer gradient for loading states
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFF2D2D42),
      Color(0xFF3D3D52),
      Color(0xFF2D2D42),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );

  // ========== SPACING ==========

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ========== BORDER RADIUS ==========

  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;
  static const double radiusCircle = 999.0;

  // ========== SHADOWS ==========

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryStart.withOpacity(0.4),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryEnd.withOpacity(0.6),
      blurRadius: 30,
      spreadRadius: 5,
    ),
  ];

  // ========== TYPOGRAPHY ==========

  static TextStyle get headingXL => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static TextStyle get headingL => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );

  static TextStyle get headingM => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get headingS => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get bodyL => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyM => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyS => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textTertiary,
    height: 1.4,
  );

  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  // ========== THEME DATA ==========

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryStart,
    colorScheme: ColorScheme.dark(
      primary: primaryStart,
      secondary: secondaryStart,
      surface: cardBackground,
      error: error,
    ),
    textTheme: TextTheme(
      displayLarge: headingXL,
      displayMedium: headingL,
      displaySmall: headingM,
      headlineMedium: headingS,
      bodyLarge: bodyL,
      bodyMedium: bodyM,
      bodySmall: bodyS,
      labelSmall: caption,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        elevation: 0,
      ),
    ),
    cardTheme: CardTheme(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusL),
      ),
    ),
  );
}

/// Animation durations
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// Animation curves
class AppCurves {
  AppCurves._();

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;
}
