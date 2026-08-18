import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitpro/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('Dark theme has correct colors', () {
      final theme = AppTheme.theme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppTheme.background);
      expect(theme.primaryColor, AppTheme.accent);
    });

    test('Color scheme is correctly configured', () {
      final theme = AppTheme.theme;
      final colorScheme = theme.colorScheme;

      expect(colorScheme.primary, AppTheme.accent);
      expect(colorScheme.secondary, AppTheme.accent);
      expect(colorScheme.surface, AppTheme.surface);
    });

    test('Text theme has correct colors', () {
      final theme = AppTheme.theme;
      final textTheme = theme.textTheme;

      expect(textTheme.headlineLarge?.color, AppTheme.textPrimary);
      expect(textTheme.bodyMedium?.color, AppTheme.textSecondary);
      expect(textTheme.bodySmall?.color, AppTheme.textTertiary);
    });

    test('App bar theme is correctly configured', () {
      final theme = AppTheme.theme;
      final appBarTheme = theme.appBarTheme;

      expect(appBarTheme.backgroundColor, AppTheme.background);
      expect(appBarTheme.foregroundColor, AppTheme.textPrimary);
      expect(appBarTheme.elevation, 0);
    });

    test('Card theme is correctly configured', () {
      final theme = AppTheme.theme;
      final cardTheme = theme.cardTheme;

      expect(cardTheme.color, AppTheme.surface);
      expect(cardTheme.elevation, 0);
    });

    test('Elevated button theme is correctly configured', () {
      final theme = AppTheme.theme;
      final buttonTheme = theme.elevatedButtonTheme;

      expect(
        buttonTheme.style?.backgroundColor?.resolve({}),
        AppTheme.accent,
      );
      expect(
        buttonTheme.style?.foregroundColor?.resolve({}),
        Colors.white,
      );
    });
  });
}
