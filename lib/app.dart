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
        primary: AppColors.primaryColor,
        onPrimary: AppColors.primaryColor.inverted,
        secondary: AppColors.border,
        onSecondary: AppColors.quaternaryColor,
        surface: AppColors.background,
        onSurface: AppColors.primaryColor.inverted,
        error: AppColors.septenaryColor,
        onError: AppColors.primaryColor.inverted,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryColor.inverted,
        selectionColor: AppColors.senaryColor.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primaryColor.inverted,
      ),
      inputDecorationTheme: InputDecorationTheme(
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

// List of locales with incomplete Material translations.
const List<String> kUnsupportedMaterialLocales = <String>['az'];
