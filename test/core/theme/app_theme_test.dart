import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:numpang_app/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('darkTheme returns a ThemeData object', () {
      final theme = AppTheme.darkTheme;
      expect(theme, isNotNull);
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('lightTheme returns a ThemeData object', () {
      final theme = AppTheme.lightTheme;
      expect(theme, isNotNull);
      expect(theme.brightness, equals(Brightness.light));
    });
  });
}