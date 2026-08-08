// models/backend/crypto.dart
// This class centralizes all cryptographic operations for the app.

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/cupertino.dart';

class CryptoHelper {
  static const int _saltLength = 16;
  static const int _iterations = 100000;

  // Generates a secure key from the user's UID and a salt using PBKDF2-like stretching.
  static enc.Key _generateKey(String userId, List<int> salt) {
    final keyMaterial = utf8.encode(userId);
    final hmac = Hmac(sha256, keyMaterial);
    var digest = hmac.convert(salt).bytes;
    for (int i = 1; i < _iterations; i++) {
      digest = hmac.convert(digest).bytes;
    }
    return enc.Key.fromBase64(base64.encode(digest.sublist(0, 32)));
  }

  // Encrypts a plaintext string using the user's ID as the key source.
  // Returns a combined string of "Salt:IV:Ciphertext" for easy storage.
  static String? encrypt(String plainText, String userId) {
    try {
      final random = Random.secure();
      final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
      final key = _generateKey(userId, salt);
      final iv = enc.IV.fromLength(16);
      final encrypter = enc.Encrypter(enc.AES(key));

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return '${base64.encode(salt)}:${iv.base64}:${encrypted.base64}';
    } catch (e) {
      debugPrint("[CryptoHelper] Encryption failed: $e");
      return null;
    }
  }

  // Decrypts a combined "Salt:IV:Ciphertext" string using the user's ID.
  // Returns the original plaintext, or null if decryption fails.
  static String? decrypt(String combined, String userId) {
    try {
      final parts = combined.split(':');
      if (parts.length != 3) throw Exception("Invalid encrypted format.");

      final salt = base64.decode(parts[0]);
      final iv = enc.IV.fromBase64(parts[1]);
      final encryptedText = enc.Encrypted.fromBase64(parts[2]);

      final key = _generateKey(userId, salt);
      final encrypter = enc.Encrypter(enc.AES(key));

      final decrypted = encrypter.decrypt(encryptedText, iv: iv);
      return decrypted;
    } catch (e) {
      debugPrint(
          "[CryptoHelper] Decryption failed (likely wrong user key): $e");
      return null;
    }
  }
}
