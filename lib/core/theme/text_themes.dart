import 'package:flutter/material.dart';

class AppTextThemes {
  static TextTheme get darkTextTheme {
    return const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        color: Color(0xFFE2E2E2),
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: Color(0xFFE2E2E2),
      ),
      titleMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        color: Color(0xFFE2E2E2),
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: Color(0xFFE2E2E2),
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: Color(0xFFD2C5AC),
      ),
      labelLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.5,
        color: Color(0xFFE2E2E2),
      ),
    );
  }

  static TextTheme get lightTextTheme {
    return const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        color: Color(0xFF1A1C1C),
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: Color(0xFF1A1C1C),
      ),
      titleMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        color: Color(0xFF1A1C1C),
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: Color(0xFF1A1C1C),
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: Color(0xFF4E4633),
      ),
      labelLarge: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.5,
        color: Color(0xFF1A1C1C),
      ),
    );
  }
}
