import 'package:flutter/material.dart';

/// Shared visual rhythm. Geometry scales independently of accessible text size.
abstract final class CortexDesign {
  static const double control = 48;
  static const double icon = 22;
  static const double iconSmall = 16;
  static const double iconLarge = 72;
  static double iconSize(double width, {int tier = 2}) {
    final base = tier == 1
        ? 16.0
        : tier == 3
            ? 72.0
            : 22.0;
    return (width / 375 * base).clamp(
        tier == 1
            ? 13.0
            : tier == 3
                ? 56.0
                : 18.0,
        tier == 1
            ? 19.0
            : tier == 3
                ? 96.0
                : 28.0);
  }

  static const double radius = 18;
  static const double cardRadius = 24;
  static const double readingWidth = 800;
  static const double pageWidth = 1120;
  static const Duration motion = Duration(milliseconds: 200);

  static double gutter(double width) => (width * .04).clamp(16.0, 32.0);
  static double drawerWidth(double width) => width < 600 ? width : 380;
  static double readingInset(double width) =>
      width > readingWidth + 32 ? (width - readingWidth) / 2 : 16;
  static int columns(double width, {double target = 200, int minimum = 2}) =>
      ((width - gutter(width) * 2) / target).floor().clamp(minimum, 6);

  static TextTheme get typography => const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 32,
            height: 1.18,
            fontWeight: FontWeight.w700,
            letterSpacing: -1),
        headlineMedium: TextStyle(
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: -.7),
        headlineSmall: TextStyle(
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w600,
            letterSpacing: -.5),
        titleLarge: TextStyle(
            fontSize: 20,
            height: 1.3,
            fontWeight: FontWeight.w600,
            letterSpacing: -.3),
        titleMedium:
            TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600),
        titleSmall:
            TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, height: 1.45),
        labelLarge:
            TextStyle(fontSize: 14, height: 1.3, fontWeight: FontWeight.w600),
        labelMedium:
            TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w600),
        labelSmall:
            TextStyle(fontSize: 11, height: 1.3, fontWeight: FontWeight.w500),
      );
}
