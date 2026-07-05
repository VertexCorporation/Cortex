// darkener.dart
//
// Utility for temporarily darkening the Android navigation-bar (and, if you
// wish, the status-bar) while a modal dialog is on-screen – then restoring the
// previous colours automatically.
//
// © 2025 Cortex
// ──────────────────────────────────────────────────────────────────────────────

import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme.dart'; // ↖ adjust the relative path if needed

/// Signature of the callback returned by [Darkener.darken].
typedef RestoreCallback = void Function();

/// Helper that *darkens* the system navigation-bar and provides methods
/// for both imperative and declarative styling.
class Darkener {
  Darkener._(); // no instances

  // ---------------------------------------------------------------------------
  // NEW METHOD for Declarative UI Styling
  // ---------------------------------------------------------------------------
  /// Returns a `SystemUiOverlayStyle` object with darkened colors.
  ///
  /// This is the recommended approach for new code, designed to be used with
  /// an `AnnotatedRegion` widget. It's a declarative way to style the system
  /// UI for a specific part of the widget tree.
  ///
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return AnnotatedRegion<SystemUiOverlayStyle>(
  ///     value: Darkener.getDarkenedOverlayStyle(affectStatusBar: true),
  ///     child: YourDialogWidget(),
  ///   );
  /// }
  /// ```
  static SystemUiOverlayStyle getDarkenedOverlayStyle({
    double factor = .5,
    bool affectStatusBar = false,
  }) {
    assert(factor >= 0 && factor <= 1, 'factor must be in the range [0,1]');

    // 1. Snapshot current system UI colors for reference.
    final theme = AppColors.currentTheme;
    final current = AppColors.getSystemUIOverlayStyleForTheme(theme);

    final origNavColor = current['navigationBarColor'] as Color;
    final origNavIcons = current['navigationBarIconBrightness'] as Brightness;
    final origStatusColor = current['statusBarColor'] as Color? ?? origNavColor;
    final origStatusIcons = current['statusBarIconBrightness'] as Brightness? ??
        origNavIcons;

    // 2. Compute the darkened color and appropriate icon brightness.
    final darkColor = _blendWithBlack(origNavColor, factor);
    final iconBrightness =
    ThemeData.estimateBrightnessForColor(darkColor) == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    // 3. Return the style object instead of applying it directly.
    return SystemUiOverlayStyle(
      systemNavigationBarColor: darkColor,
      systemNavigationBarIconBrightness: iconBrightness,
      systemStatusBarContrastEnforced: false,
      statusBarColor: affectStatusBar ? darkColor : origStatusColor,
      statusBarIconBrightness: affectStatusBar
          ? iconBrightness
          : origStatusIcons,
    );
  }


  // ---------------------------------------------------------------------------
  // ORIGINAL METHOD for Imperative UI Styling (UNCHANGED)
  // ---------------------------------------------------------------------------
  /// Darkens the nav-bar by [factor] and returns a function that restores
  /// the original style.
  ///
  /// This method is preserved for backward compatibility. For new widgets,
  /// prefer using `getDarkenedOverlayStyle` with an `AnnotatedRegion`.
  static RestoreCallback darken({
    double factor = .5,
    bool affectStatusBar = false,
  }) {
    assert(factor >= 0 && factor <= 1, 'factor must be in the range [0,1]');

    // 1. Snapshot current system-UI colours for later restoration
    final theme = AppColors.currentTheme;
    final current = AppColors.getSystemUIOverlayStyleForTheme(theme);

    final origNavColor = current['navigationBarColor'] as Color;
    final origNavIcons = current['navigationBarIconBrightness'] as Brightness;
    final origStatusColor = current['statusBarColor'] as Color? ?? origNavColor;
    final origStatusIcons = current['statusBarIconBrightness'] as Brightness? ??
        origNavIcons;

    // 2. Compute darkened shade & appropriate icon colour
    final darkColor = _blendWithBlack(origNavColor, factor);
    final iconBrightness = ThemeData.estimateBrightnessForColor(darkColor) ==
        Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    // 3. Apply the temporary style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: darkColor,
        systemNavigationBarIconBrightness: iconBrightness,
        systemStatusBarContrastEnforced: false,
        statusBarColor:
        affectStatusBar ? darkColor : origStatusColor,
        statusBarIconBrightness:
        affectStatusBar ? iconBrightness : origStatusIcons,
      ),
    );

    dev.log('[Darkener] applied (factor=$factor)', name: 'UI');

    // 4. Return a one-shot callback that restores the old values
    return () {
      dev.log('[Darkener] restoring…', name: 'UI');
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: origNavColor,
          systemNavigationBarIconBrightness: origNavIcons,
          statusBarColor: origStatusColor,
          statusBarIconBrightness: origStatusIcons,
        ),
      );
    };
  }

  /// Private: blends [color] with black by [factor].
  static Color _blendWithBlack(Color color, double factor) {
    return Color.lerp(color, Colors.black, factor)!;
  }
}