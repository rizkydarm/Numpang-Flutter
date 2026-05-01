import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFCA28),
        onPrimary: Color(0xFF705600),
        primaryContainer: Color(0xFFF3C01A),
        onPrimaryContainer: Color(0xFF705600),
        secondary: Color(0xFF9ECAFF),
        onSecondary: Color(0xFF003258),
        secondaryContainer: Color(0xFF1E95F2),
        onSecondaryContainer: Color(0xFF002B4D),
        tertiary: Color(0xFFDAF0FD),
        onTertiary: Color(0xFF1E333C),
        tertiaryContainer: Color(0xFFBED4E0),
        onTertiaryContainer: Color(0xFF475C66),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: Color(0xFF1A1C1C),
        onSurface: Color(0xFFE2E2E2),
        surfaceContainer: Color(0xFF1E2020),
        outline: Color(0xFF9B9079),
        outlineVariant: Color(0xFF4E4633),
      ),
      scaffoldBackgroundColor: const Color(0xFF121414),
      fontFamily: 'Plus Jakarta Sans',
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFFCA28),
        onPrimary: Color(0xFF705600),
        primaryContainer: Color(0xFFF3C01A),
        onPrimaryContainer: Color(0xFF705600),
        secondary: Color(0xFF9ECAFF),
        onSecondary: Color(0xFF003258),
        secondaryContainer: Color(0xFF1E95F2),
        onSecondaryContainer: Color(0xFF002B4D),
        tertiary: Color(0xFFDAF0FD),
        onTertiary: Color(0xFF1E333C),
        tertiaryContainer: Color(0xFFBED4E0),
        onTertiaryContainer: Color(0xFF475C66),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: Color(0xFFE2E2E2),
        onSurface: Color(0xFF1A1C1C),
        surfaceContainer: Color(0xFFE2E2E2),
        outline: Color(0xFF9B9079),
        outlineVariant: Color(0xFF4E4633),
      ),
      scaffoldBackgroundColor: const Color(0xFFE2E2E2),
      fontFamily: 'Plus Jakarta Sans',
    );
  }
}

/// App color constants for consistent usage across the app
class AppColors {
  // Primary
  static const Color primary = Color(0xFFFFCA28);
  static const Color onPrimary = Color(0xFF705600);
  static const Color primaryContainer = Color(0xFFF3C01A);
  static const Color onPrimaryContainer = Color(0xFF705600);

  // Surfaces
  static const Color surfaceDark = Color(0xFF1A1C1C);
  static const Color surfaceLight = Color(0xFFE2E2E2);
  static const Color scaffoldDark = Color(0xFF121414);
  static const Color scaffoldLight = Color(0xFFE2E2E2);

  // Text - Dark Mode
  static const Color textPrimaryDark = Color(0xFFE2E2E2);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF808080);

  // Text - Light Mode
  static const Color textPrimary = Color(0xFF1A1C1C);
  static const Color textSecondary = Color(0xFF505050);
  static const Color textTertiary = Color(0xFF808080);

  // Semantic
  static const Color error = Color(0xFFFFB4AB);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
}
