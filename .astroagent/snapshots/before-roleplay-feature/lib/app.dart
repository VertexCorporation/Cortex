// app.dart
//
// Root application widget and shared app-level utilities.
//
// - Cortex: wraps [MaterialApp] with theming, localization, and navigator key.
// - InvertedColor: small color utility variant used across the app.
// - kUnsupportedMaterialLocales: locales with incomplete Material translations.

import 'package:cortex/analytics/service.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/language.dart';
import 'package:cortex/theme.dart';
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

  ThemeData _buildTheme(String currentTheme) {
    if (_cachedThemeName == currentTheme && _cachedThemeData != null) {
      return _cachedThemeData!;
    }

    final bool isDark = currentTheme == 'dark';
    final ThemeData baseTheme = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: 'Inter',
    );

    _cachedThemeName = currentTheme;
    _cachedThemeData = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        fontFamily: 'Inter',
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
      primaryColor: AppColors.background,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppColors.primaryColor.inverted,
        onPrimary: AppColors.primaryColor,
        secondary: AppColors.border,
        onSecondary: AppColors.quaternaryColor,
        surface: AppColors.background,
        onSurface: AppColors.primaryColor.inverted,
        error: AppColors.septenaryColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryColor.inverted,
        selectionColor: AppColors.secondaryColor.inverted.withValues(
            alpha: 0.3),
        selectionHandleColor: AppColors.primaryColor.inverted,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusColor: AppColors.primaryColor.inverted,
        hintStyle: TextStyle(color: AppColors.tertiaryColor),
        labelStyle: TextStyle(color: AppColors.tertiaryColor),
      ),
    );

    return _cachedThemeData!;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    final LocaleProvider localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: <NavigatorObserver>[
        AnalyticsService().observer,
      ],
      theme: _buildTheme(themeProvider.currentTheme),
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
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        final Locale chosenLocale = localeProvider.locale;
        if (kUnsupportedMaterialLocales.contains(chosenLocale.languageCode)) {
          return const Locale('en');
        }
        return chosenLocale;
      },
      home: startupScreen,
    );
  }
}

/// Helper variant to make color inversion cleaner and reusable.
extension InvertedColor on Color {
  /// Returns the inverted version of this color.
  Color get inverted {
    final int a = (this.a * 255).round();
    final int r = (this.r * 255).round();
    final int g = (this.g * 255).round();
    final int b = (this.b * 255).round();

    return Color.fromARGB(
      a,
      255 - r,
      255 - g,
      255 - b,
    );
  }
}

// List of locales with incomplete Material translations.
const List<String> kUnsupportedMaterialLocales = <String>['az'];