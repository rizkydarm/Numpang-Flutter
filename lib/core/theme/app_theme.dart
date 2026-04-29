import 'package:flutter/material.dart';
import 'text_themes.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: AppTextThemes.darkTextTheme,
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
      textTheme: AppTextThemes.lightTextTheme,
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
