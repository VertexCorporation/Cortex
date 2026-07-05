// models/backend/crypto.dart
// This class centralizes all cryptographic operations for the app.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/cupertino.dart';

class CryptoHelper {
  // Generates a secure, fixed-length key from the user's UID.
  static enc.Key _generateKey(String userId) {
    final bytes = utf8.encode(userId); // Convert UID to bytes
    final digest = sha256.convert(bytes); // Hash it with SHA-256
    return enc.Key.fromBase64(base64.encode(digest.bytes)); // Use the 32-byte hash as the key
  }

  // Encrypts a plaintext string using the user's ID as the key source.
  // Returns a combined string of "IV:Ciphertext" for easy storage.
  static String? encrypt(String plainText, String userId) {
    try {
      final key = _generateKey(userId);
      final iv = enc.IV.fromLength(16); // Generate a random 16-byte IV
      final encrypter = enc.Encrypter(enc.AES(key));

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      // Combine IV and ciphertext into a single string for storage.
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      debugPrint("[CryptoHelper] Encryption failed: $e");
      return null;
    }
  }

  // Decrypts a combined "IV:Ciphertext" string using the user's ID.
  // Returns the original plaintext, or null if decryption fails.
  static String? decrypt(String combined, String userId) {
    try {
      // Split the combined string to get the IV and the ciphertext.
      final parts = combined.split(':');
      if (parts.length != 2) throw Exception("Invalid encrypted format.");

      final iv = enc.IV.fromBase64(parts[0]);
      final encryptedText = enc.Encrypted.fromBase64(parts[1]);

      final key = _generateKey(userId);
      final encrypter = enc.Encrypter(enc.AES(key));

      final decrypted = encrypter.decrypt(encryptedText, iv: iv);
      return decrypted;
    } catch (e) {
      // This catch block is expected to fire when trying to decrypt another user's data.
      debugPrint("[CryptoHelper] Decryption failed (likely wrong user key): $e");
      return null;
    }
  }
}