// lib/settings/services/auth.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// --- Custom Exceptions for Clear Error Handling ---

/// A base class for all authentication-related exceptions.
/// It carries a machine-readable error code.
class AuthException implements Exception {
  final String code;

  AuthException(this.code);

  @override
  String toString() => 'AuthException: $code';
}

/// A generic exception for unknown or unexpected authentication errors.
class AuthUnknownException extends AuthException {
  AuthUnknownException() : super('unknown-error');
}

/// A service dedicated to handling all authentication-related operations.
///
/// This class acts as an abstraction layer over the Firebase Authentication SDK.
/// It centralizes all logic for user sign-in, sign-out, password management,
/// and email verification. When errors occur, it throws `AuthException` with a
/// specific error code, leaving localization to the ViewModel layer.
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isLoggedIn => currentUser != null;

  bool isCurrentUserVerified() {
    return currentUser?.emailVerified ?? false;
  }

  bool hasPasswordProvider() {
    if (!isLoggedIn) return false;
    return currentUser!.providerData.any((provider) =>
    provider.providerId == 'password');
  }

  Future<void> reloadCurrentUser() async {
    await currentUser?.reload();
  }

  Future<void> sendVerificationEmail() async {
    if (!isLoggedIn) {
      throw AuthException('no-user-signed-in');
    }
    try {
      await currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      debugPrint("AuthService: Error sending verification email: ${e.code}");
      throw AuthException(e.code);
    } catch (_) {
      throw AuthUnknownException();
    }
  }

  /// Re-authenticates the current user with their password.
  Future<void> _reauthenticate(String password) async {
    if (!isLoggedIn) {
      throw AuthException('no-user-signed-in');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      await currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint("AuthService: Re-authentication error: ${e.code}");
      throw AuthException(e.code);
    }
  }

  /// Updates the current user's password.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!isLoggedIn) {
      throw AuthException('no-user-signed-in');
    }
    // First, ensure the user is who they say they are.
    await _reauthenticate(oldPassword);

    // If re-authentication is successful, update the password.
    try {
      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      debugPrint("AuthService: Update password error: ${e.code}");
      throw AuthException(e.code);
    }
  }

  Future<void> signOutFromProviders() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      debugPrint("AuthService: Signed out from Google and Firebase.");
    } catch (e) {
      debugPrint("AuthService: Error during low-level sign out: $e");
    }
  }
}