// test/theme_test.dart
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Theme System Tests', () {
    late String originalTheme;

    setUp(() {
      originalTheme = AppColors.currentTheme;
    });

    tearDown(() {
      AppColors.currentTheme = originalTheme;
    });

    test('AppColors returns only light and dark themes', () {
      final defs = AppColors.themeDefinitions;
      expect(defs.keys, {AppTheme.light, AppTheme.dark});
    });

    test('Theme fallback logic', () {
      final colors = AppColors.getThemeColors('grayscale');
      expect(
          colors.background, AppColors.themeDefinitions[AppTheme.light]!.background);
    });

    test('Legacy theme names normalize to light', () {
      expect(AppTheme.normalize('love'), AppTheme.light);
      expect(AppTheme.normalize('grayscale'), AppTheme.light);
      expect(AppTheme.normalize('cyberpunk'), AppTheme.light);
    });

    test('Dark theme parameter verification', () {
      final dark = AppColors.themeDefinitions[AppTheme.dark]!;
      expect(dark.primaryColor, const Color(0xFF121212));
      expect(dark.statusBarIconBrightness, Brightness.light);
    });

    test('Overlay styles map generation', () {
      final styles = AppColors.overlayStyles;
      expect(styles[AppTheme.light]!['navigationBarColor'],
          const Color(0xFFFFFFFF));
      expect(styles[AppTheme.dark]!['statusBarIconBrightness'], Brightness.light);
    });

    test('Darken utility', () {
      final color = const Color(0xFFFFFFFF);
      final darker = AppColors.darken(color, 0.5);

      expect(darker.computeLuminance() < color.computeLuminance(), true);
    });

    test('Static getters use currentTheme', () {
      AppColors.currentTheme = AppTheme.dark;
      expect(AppColors.background, const Color(0xFF000000));

      AppColors.currentTheme = AppTheme.light;
      expect(AppColors.background, const Color(0xFFFFFFFF));
    });
  });
}
