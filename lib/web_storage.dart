import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Web-safe storage abstraction.
/// Uses flutter_secure_storage on mobile, falls back to shared_preferences on web.
class WebStorage {
  final FlutterSecureStorage? _secureStorage;

  WebStorage._() : _secureStorage = kIsWeb ? null : const FlutterSecureStorage();

  static final WebStorage instance = WebStorage._();

  Future<void> write({required String key, required String value}) async {
    if (_secureStorage != null) {
      await _secureStorage!.write(key: key, value: value);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  Future<String?> read({required String key}) async {
    if (_secureStorage != null) {
      return await _secureStorage!.read(key: key);
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
  }

  Future<void> delete({required String key}) async {
    if (_secureStorage != null) {
      await _secureStorage!.delete(key: key);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    }
  }
}
