// test/language_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cortex/language.dart';

void main() {
  group('LocaleProvider Tests', () {
    late LocaleProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial locale defaults to English (or device default logic)',
        () async {
      provider = LocaleProvider();

      // Async init
      await Future.delayed(Duration.zero);

      // Default mock preferences are empty, so it might default to 'en' or device locale substitute in test env
      // Usually test env doesn't report specific device locale easily without more mocking, but fallback is 'en'.
      expect(provider.locale.languageCode, 'en');
    });

    test('Loads saved locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'language_code': 'tr'});

      provider = LocaleProvider();
      await Future.delayed(Duration.zero); // wait for _setInitialLocale

      expect(provider.locale.languageCode, 'tr');
    });

    test('Ignores invalid saved locale', () async {
      SharedPreferences.setMockInitialValues(
          {'language_code': 'xx'}); // Invalid

      provider = LocaleProvider();
      await Future.delayed(Duration.zero);

      expect(provider.locale.languageCode, 'en'); // Fallback
    });

    test('setLocale updates state and preference', () async {
      provider = LocaleProvider();
      await Future.delayed(Duration.zero);

      await provider.setLocale(const Locale('fr'));

      expect(provider.locale.languageCode, 'fr');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language_code'), 'fr');
    });

    test('setLocale rejects unsupported locale', () async {
      provider = LocaleProvider();
      await Future.delayed(Duration.zero);

      await provider.setLocale(const Locale('xx')); // Invalid

      expect(provider.locale.languageCode, 'en'); // No change
    });

    test('clearLocale resets to English', () async {
      SharedPreferences.setMockInitialValues({'language_code': 'tr'});
      provider = LocaleProvider();
      await Future.delayed(Duration.zero);

      expect(provider.locale.languageCode, 'tr');

      await provider.clearLocale();

      expect(provider.locale.languageCode, 'en');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('language_code'), false);
    });
  });
}
