import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LocaleProvider extends ChangeNotifier {
  Locale _locale;

  final List<String> _allowedLanguageCodes = [
    'en',
    'tr',
    'zh',
    'fr',
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
      Locale deviceLocale = ui.window.locale;
      if (_allowedLanguageCodes.contains(deviceLocale.languageCode)) {
        _locale = deviceLocale;
      } else {
        _locale = const Locale('en');
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