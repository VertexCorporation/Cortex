// app.dart
//
// Root application widget and shared app-level utilities.
//
// - Cortex: wraps [MaterialApp] with theming, localization, and navigator key.
// - InvertedColor: small color utility variant used across the app.

import 'package:cortex/analytics/service.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/language.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

/// Root application widget. Wraps [MaterialApp] with localization, theming,
/// and the global [navigatorKey].
class Cortex extends StatelessWidget {
  const Cortex({
    super.key,
    required this.navigatorKey,
    this.startupScreen,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget? startupScreen;

  static ThemeData? _cachedThemeData;
  static String? _cachedThemeName;

  static ThemeData themeFor(String currentTheme) {
    if (_cachedThemeName == currentTheme && _cachedThemeData != null) {
      return _cachedThemeData!;
    }

    final colors = AppColors.getThemeColors(currentTheme);
    final bool isDark =
        ThemeData.estimateBrightnessForColor(colors.background) ==
            Brightness.dark;
    final foreground =
        isDark ? const Color(0xFFF1F2F5) : const Color(0xFF20232B);
    final scheme = ColorScheme.fromSeed(
            seedColor: colors.senaryColor,
            brightness: isDark ? Brightness.dark : Brightness.light)
        .copyWith(surface: colors.background, onSurface: foreground);
    final ThemeData baseTheme = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: 'Inter',
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: CortexDesign.typography,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );

    _cachedThemeName = currentTheme;
    _cachedThemeData = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: foreground,
        displayColor: foreground,
        fontFamilyFallback: const [
          'Roboto',
          'Segoe UI',
          'San Francisco',
          'PingFang SC',
          'Heiti SC',
          'Noto Sans CJK SC',
          'Noto Sans CJK TC',
          'Noto Sans CJK JP',
          'Noto Sans CJK KR',
          'Arial',
          'Noto Sans',
          'sans-serif',
        ],
      ),
      primaryColor: colors.background,
      scaffoldBackgroundColor: colors.background,
      colorScheme: scheme,
      dividerTheme:
          DividerThemeData(color: colors.border, thickness: 1, space: 24),
      cardTheme: CardThemeData(
        color: colors.background,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CortexDesign.cardRadius),
            side: BorderSide(color: colors.border)),
      ),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
        backgroundColor: colors.background,
        foregroundColor: foreground,
        disabledBackgroundColor: colors.background,
        side: BorderSide(color: colors.border),
        minimumSize: const Size(48, CortexDesign.control),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CortexDesign.radius)),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
        backgroundColor: colors.background,
        foregroundColor: foreground,
        side: BorderSide(color: colors.border),
        minimumSize: const Size(48, CortexDesign.control),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CortexDesign.radius)),
      )),
      iconTheme: IconThemeData(size: CortexDesign.icon, color: foreground),
      iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
              iconSize: CortexDesign.icon, foregroundColor: foreground)),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        backgroundColor: colors.background,
        foregroundColor: foreground,
        disabledBackgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        side: BorderSide(color: colors.border),
        minimumSize: const Size(48, CortexDesign.control),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CortexDesign.radius)),
      )),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        constraints: const BoxConstraints(maxWidth: 680),
      ),
      dialogTheme: DialogThemeData(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryColor.inverted,
        selectionColor: AppColors.senaryColor.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primaryColor.inverted,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.background,
        focusColor: AppColors.senaryColor,
        hintStyle: TextStyle(color: AppColors.tertiaryColor),
        labelStyle: TextStyle(color: AppColors.tertiaryColor),
      ),
    );

    return _cachedThemeData!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: <NavigatorObserver>[
            AnalyticsService().observer,
          ],
          theme: themeFor(themeProvider.currentTheme),
          builder: (BuildContext context, Widget? child) {
            try {
              themeProvider.updateSystemUIOverlayStyle();
            } catch (_) {}
            return child!;
          },
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: startupScreen,
        );
      },
    );
  }
}

/// Soft luminance-based color inversion.
/// Light colors return a warm dark; dark colors return a warm light.
/// This avoids harsh arithmetic inversion and keeps the monochrome harmony.
extension InvertedColor on Color {
  Color get inverted {
    final l = computeLuminance();
    if (l > 0.5) {
      return const Color(0xFF2D2A26);
    } else {
      return const Color(0xFFE8E3DC);
    }
  }
}

