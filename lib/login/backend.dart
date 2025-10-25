// lib/login/backend.dart
// It's good practice to have a more generic name if it might handle more than just login in the future.

import 'dart:async';
import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../referral.dart';
import 'package:flutter/services.dart';

// --- Result Classes (Unchanged, they are perfect) ---

/// Represents the exhaustive set of outcomes for an email/password login attempt.
sealed class LoginResult {}

class LoginSuccess extends LoginResult {
  final User user;
  LoginSuccess(this.user);
}
class LoginEmailNotVerified extends LoginResult {
  final User user;
  LoginEmailNotVerified(this.user);
}
class LoginInvalidCredentials extends LoginResult {}
class LoginUserDisabled extends LoginResult {}
class LoginNetworkError extends LoginResult {}
class LoginUnknownError extends LoginResult {}


/// Represents the exhaustive set of outcomes for a registration attempt.
sealed class RegistrationResult {}

class RegistrationSuccess extends RegistrationResult {
  final User user;
  RegistrationSuccess(this.user);
}
class RegistrationUsernameTaken extends RegistrationResult {}
class RegistrationEmailInUse extends RegistrationResult {}
class RegistrationWeakPassword extends RegistrationResult {}
class RegistrationNetworkError extends RegistrationResult {}
class RegistrationUnknownError extends RegistrationResult {}


/// Represents the exhaustive set of outcomes for a Google Sign-In attempt.
sealed class GoogleSignInResult {}

class GoogleSignInSuccess extends GoogleSignInResult {
  final User user;
  GoogleSignInSuccess(this.user);
}
class GoogleSignInFailure extends GoogleSignInResult {}


/// A service class that encapsulates all backend authentication logic.
///
/// This class is completely decoupled from the UI. Its sole responsibility is to
/// communicate with backend services (Firebase, etc.) and return a strongly-typed
/// result object. It does not manage UI state like loading indicators.
class LoginBackendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Handles the entire email and password login flow.
  Future<LoginResult> loginWithEmail({
    required BuildContext context, // Used only for AppLocalizations.
    required NotificationService notificationService,
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await InternetConnection().hasInternetAccess) {
      notificationService.showNotification(message: l10n.noInternetConnection, isSuccess: false);
      return LoginNetworkError();
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null) throw FirebaseAuthException(code: 'user-not-found-after-signin');

      await _handleSessionPersistence(email, password, rememberMe);
      await user.reload();
      final freshUser = _auth.currentUser;
      if (freshUser == null) throw FirebaseAuthException(code: 'user-disappeared-after-reload');

      if (!freshUser.emailVerified) {
        dev.log('[Auth.Login] User email not verified. UID: ${freshUser.uid}', name: 'LoginBackend');
        return LoginEmailNotVerified(freshUser);
      }

      dev.log('[Auth.Login] User verified. UID: ${freshUser.uid}. Running post-login tasks.', name: 'LoginBackend');

      return LoginSuccess(freshUser);

    } on FirebaseAuthException catch (e) {
      dev.log('[Auth.Login] FirebaseAuthException: ${e.code}', name: 'LoginBackend', error: e.message);
      switch (e.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          return LoginInvalidCredentials();
        case 'user-disabled':
          return LoginUserDisabled();
        default:
          notificationService.showNotification(message: l10n.authError, isSuccess: false);
          return LoginUnknownError();
      }
    } catch (e, st) {
      dev.log('[Auth.Login] Generic error', name: 'LoginBackend', error: e, stackTrace: st);
      notificationService.showNotification(message: l10n.authError, isSuccess: false);
      return LoginUnknownError();
    }
  }

  /// Handles the entire user registration flow.
  Future<RegistrationResult> registerWithEmail({
    required BuildContext context,
    required NotificationService notificationService,
    required String username,
    required String email,
    required String password,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await InternetConnection().hasInternetAccess) {
      notificationService.showNotification(message: l10n.noInternetConnection, isSuccess: false);
      return RegistrationNetworkError();
    }

    try {
      final isAvailable = await _isUsernameAvailable(username, notificationService, l10n);
      if (!isAvailable) {
        return RegistrationUsernameTaken();
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null) throw FirebaseAuthException(code: 'user-creation-returned-null');

      _postUsernameSuggestion(uid: user.uid, username: username);

      await user.sendEmailVerification();
      dev.log('[Auth.Register] Verification email sent for UID: ${user.uid}.', name: 'LoginBackend');

      return RegistrationSuccess(user);

    } on FirebaseAuthException catch (e) {
      dev.log('[Auth.Register] FirebaseAuthException: ${e.code}', name: 'LoginBackend', error: e.message);
      switch (e.code) {
        case 'email-already-in-use':
          return RegistrationEmailInUse();
        case 'weak-password':
          return RegistrationWeakPassword();
        default:
          notificationService.showNotification(message: l10n.authError, isSuccess: false);
          return RegistrationUnknownError();
      }
    } catch (e, st) {
      dev.log('[Auth.Register] Generic error', name: 'LoginBackend', error: e, stackTrace: st);
      notificationService.showNotification(message: l10n.authError, isSuccess: false);
      return RegistrationUnknownError();
    }
  }

  /// Handles the entire Google Sign-In flow, aligned with the latest documentation.
  Future<GoogleSignInResult> signInWithGoogle({
    required BuildContext context,
    required NotificationService notificationService,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Step 0: Initialize GoogleSignIn with the required serverClientId.
      // This is the new, correct way to configure the sign-in process before starting.
      await _googleSignIn.initialize(
        serverClientId: '561391430514-nqjp6jl1s9oqi8ddg2fhm83lbvg94qca.apps.googleusercontent.com',
      );

      // Step 1: Initiate the user-interactive sign-in process using authenticate().
      // This shows the Google account picker UI.
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Step 2: Get the authentication tokens from the successful sign-in.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Step 3: Create a Firebase credential using the idToken.
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase.
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("Firebase sign in with Google returned a null user.");
      }

      // --- Post-login logic ---
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        _postUsernameSuggestion(uid: user.uid, username: null);
      }

      await _secureStorage.write(key: 'remember_me', value: 'true');
      await _secureStorage.write(key: 'email', value: user.email);

      dev.log('[Auth.Google] Sign-in complete for UID: ${user.uid}.', name: 'LoginBackend');
      return GoogleSignInSuccess(user);

    }  catch (e, st) {

      if (e is PlatformException && e.code == 'network_error') {
        dev.log('[Auth.Google] A network error occurred during Google Sign-In', name: 'LoginBackend', error: e, stackTrace: st);
        notificationService.showNotification(message: l10n.noInternetConnection, isSuccess: false);
      }
      else if (e is GoogleSignInException && e.code == GoogleSignInExceptionCode.canceled) {
        dev.log('[Auth.Google] Sign-in process was cancelled by the user.', name: 'LoginBackend');
      } else {
        dev.log('[Auth.Google] An unexpected error occurred during Google Sign-In', name: 'LoginBackend', error: e, stackTrace: st);
        notificationService.showNotification(message: l10n.authError, isSuccess: false);
      }

      await _googleSignIn.disconnect().catchError((_) {});
      await _auth.signOut().catchError((_) {});

      return GoogleSignInFailure();
    }
  }

  // --- Private Helper Methods ---

  void _postUsernameSuggestion({required String uid, String? username}) async {
    try {
      final String? referrerId = await ReferralHandler.getSavedReferrerId();
      final expirationTime = DateTime.now().add(const Duration(hours: 1));

      await _firestore.collection('usernameSuggestions').doc(uid).set({
        'username': username,
        'invitedBy': referrerId,
        'expireAt': Timestamp.fromDate(expirationTime),
      });
      dev.log('[Auth.Suggestion] Posted suggestion for UID: $uid', name: 'LoginBackend');
      if (referrerId != null) {
        ReferralHandler.clearSavedReferrerId();
      }
    } catch (error) {
      dev.log(
        '[Auth.Suggestion] WARNING: Failed to post username suggestion. The backend will self-heal.',
        name: 'LoginBackend',
        error: error,
      );
    }
  }

  Future<bool> _isUsernameAvailable(String username, NotificationService ns, AppLocalizations l10n) async {
    try {
      final callable = _functions.httpsCallable('isUsernameAvailable');
      final result = await callable.call<Map<String, dynamic>>({'username': username});
      return result.data['available'] as bool? ?? false;
    } on FirebaseFunctionsException catch (e) {
      dev.log('[UsernameCheck] FirebaseFunctionsException: ${e.code}', name: 'LoginBackend', error: e.message);
      ns.showNotification(message: l10n.anErrorOccurred, isSuccess: false);
      return false;
    } catch (e) {
      dev.log('[UsernameCheck] Generic error: $e', name: 'LoginBackend');
      ns.showNotification(message: l10n.noInternetConnection, isSuccess: false);
      return false;
    }
  }

  Future<void> _handleSessionPersistence(String email, String password, bool rememberMe) async {
    if (rememberMe) {
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);
      await _secureStorage.write(key: 'remember_me', value: 'true');
    } else {
      await _secureStorage.deleteAll();
    }
  }
}