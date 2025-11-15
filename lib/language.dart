import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LocaleProvider extends ChangeNotifier {
  Locale _locale;

  final List<String> _allowedLanguageCodes = [
    'en', // English
    'tr', // Turkish
    'zh', // Chinese
    'fr', // French
    'hi', // Hindi
    'pt', // Portuguese
    'id', // Indonesian
    'az', // Azerbaijani
    'de', // German
    'es', // Spanish
    'it', // Italian
    'ja', // Japanese
    'ar', // Arabic
    'ku', // Kurdish
    'nl', // Dutch
    'ru', // Russian
    'ko', // Korean
  ];

  LocaleProvider() : _locale = const Locale('en') {
    _setInitialLocale();
  }

  Locale get locale => _locale;

  Future<void> _setInitialLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('language_code');

    if (savedLanguageCode != null && _allowedLanguageCodes.contains(savedLanguageCode)) {
      _locale = Locale(savedLanguageCode);
    } else {
      final dispatcher = ui.PlatformDispatcher.instance;
      // Get the locale from the dispatcher.
      final Locale deviceLocale = dispatcher.locale;

      if (_allowedLanguageCodes.contains(deviceLocale.languageCode)) {
        _locale = deviceLocale;
      } else {
        _locale = const Locale('en'); // Fallback to English
      }
      await _saveLocale(_locale);
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!_allowedLanguageCodes.contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
    await _saveLocale(locale);
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  Future<void> clearLocale() async {
    _locale = const Locale('en');
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
  }
}