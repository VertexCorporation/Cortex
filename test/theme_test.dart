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

    test('AppColors returns valid theme definitions', () {
      final defs = AppColors.themeDefinitions;
      expect(defs.containsKey('light'), true);
      expect(defs.containsKey('dark'), true);
      expect(defs.containsKey('ocean'), true);
    });

    test('Theme fallback logic', () {
      final colors = AppColors.getThemeColors('non_existent_theme');
      // Should fallback to light
      expect(
          colors.background, AppColors.themeDefinitions['light']!.background);
    });

    test('Specific theme parameter verification', () {
      final dark = AppColors.themeDefinitions['dark']!;
      expect(dark.primaryColor, Colors.black);
      expect(dark.statusBarIconBrightness, Brightness.light);
    });

    test('Overlay styles map generation', () {
      final styles = AppColors.overlayStyles;
      expect(styles['light']!['navigationBarColor'], Colors.white);
      expect(styles['dark']!['statusBarIconBrightness'], Brightness.light);
    });

    test('Darken utility', () {
      final color = const Color(0xFFFFFFFF); // White
      final darker = AppColors.darken(color, 0.5);

      // Should be darker (closer to black)
      expect(darker.computeLuminance() < color.computeLuminance(), true);
    });

    test('Static getters use currentTheme', () {
      AppColors.currentTheme = 'dark';
      expect(AppColors.background, const Color(0xFF090909)); // Dark background

      AppColors.currentTheme = 'light';
      expect(AppColors.background, const Color(0xFFFFFFFF)); // Light background
    });
  });
}
