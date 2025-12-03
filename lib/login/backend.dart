// lib/login/backend.dart
// It's good practice to have a more generic name if it might handle more than just login in the future.

import 'dart:async';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import '../initialization.dart';
import '../main.dart';
import '../notifications/extrovert.dart';
import '../notifications/introvert.dart';
import '../referral.dart';
import 'package:flutter/services.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/server/credits.dart';

// --- Result Classes (Unchanged, they are perfect) ---

/// Represents the exhaustive set of outcomes for an email/password login attempt.
sealed class LoginResult {}

class LoginSuccess extends LoginResult {
  final User user;
  LoginSuccess(this.user);
}
class LoginInvalidCredentials extends LoginResult {}
class LoginUserDisabled extends LoginResult {}
class LoginNetworkError extends LoginResult {}
class LoginUnknownError extends LoginResult {}


/// Represents the exhaustive set of outcomes for a registration attempt.
sealed class RegistrationResult {}

class RegistrationSuccess extends RegistrationResult {}
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

/// Represents the outcomes for an anonymous sign-in attempt.
sealed class AnonymousSignInResult {}

class AnonymousSignInSuccess extends AnonymousSignInResult {
  final User user;
  AnonymousSignInSuccess(this.user);
}
class AnonymousSignInNetworkError extends AnonymousSignInResult {}
class AnonymousSignInFailure extends AnonymousSignInResult {}

/// Represents the exhaustive set of outcomes for an Apple Sign-In attempt.
sealed class AppleSignInResult {}

class AppleSignInSuccess extends AppleSignInResult {
  final User user;
  AppleSignInSuccess(this.user);
}
class AppleSignInFailure extends AppleSignInResult {}

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
    required IntrovertNotificationService notificationService,
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final extrovertNotificationService = context.read<ExtrovertNotificationService>();

    if (!await InternetConnection().hasInternetAccess) {
      notificationService.showNotification(message: l10n.noInternetConnection, type: NotificationType.error);
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
        dev.log('[Auth.Login] User email not verified. UID: ${freshUser.uid}. Triggering verification flow.', name: 'LoginBackend');

        final initializer = Provider.of<AppInitializer>(navigatorKey.currentContext!, listen: false);
        initializer.requestEmailVerification(
          email: freshUser.email!,
          userId: freshUser.uid,
          password: password,
        );

        extrovertNotificationService.syncTokenAfterLogin().ignore();

        return LoginSuccess(freshUser);
      }

      dev.log('[Auth.Login] User verified. UID: ${freshUser.uid}. Running post-login tasks.', name: 'LoginBackend');

      extrovertNotificationService.syncTokenAfterLogin().ignore();

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
          notificationService.showNotification(message: l10n.authError, type: NotificationType.error);
          return LoginUnknownError();
      }
    } catch (e, st) {
      dev.log('[Auth.Login] Generic error', name: 'LoginBackend', error: e, stackTrace: st);
      notificationService.showNotification(message: l10n.authError, type: NotificationType.error);
      return LoginUnknownError();
    }
  }

  /// Handles the entire user registration flow.
  Future<RegistrationResult> registerWithEmail({
    required BuildContext context,
    required IntrovertNotificationService notificationService,
    required String username,
    required String email,
    required String password,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final extrovertNotificationService = context.read<ExtrovertNotificationService>();
    final userProvider = context.read<UserProvider>();
    final initializer = Provider.of<AppInitializer>(navigatorKey.currentContext!, listen: false);

    if (!await InternetConnection().hasInternetAccess) {
      notificationService.showNotification(message: l10n.noInternetConnection, type: NotificationType.error);
      return RegistrationNetworkError();
    }

    try {
      initializer.setRegistrationStatus(true);

      // --- ASYNC GAP 1 ---
      final isAvailable = await _isUsernameAvailable(username, notificationService, l10n);
      if (!isAvailable) {
        initializer.setRegistrationStatus(false);
        return RegistrationUsernameTaken();
      }

      // --- ASYNC GAP 2 ---
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null) throw FirebaseAuthException(code: 'user-creation-returned-null');

      userProvider.listenToUserData(user);
      CreditsManager.instance.listenToCredits();
      dev.log(
        '[Auth.Register] Manually attached UserProvider & CreditsManager listeners for new user (UID: ${user.uid}).',
        name: 'LoginBackend',
      );

      extrovertNotificationService.syncTokenAfterLogin().ignore();

      await _postUsernameSuggestion(uid: user.uid, username: username);

      await user.sendEmailVerification();
      dev.log('[Auth.Register] Verification email sent for UID: ${user.uid}.', name: 'LoginBackend');

      initializer.requestEmailVerification(
        email: email,
        userId: user.uid,
        username: username,
        password: password,
      );

      return RegistrationSuccess();

    } on FirebaseAuthException catch (e) {
      dev.log('[Auth.Register] FirebaseAuthException: ${e.code}', name: 'LoginBackend', error: e.message);
      switch (e.code) {
        case 'email-already-in-use':
          return RegistrationEmailInUse();
        case 'weak-password':
          return RegistrationWeakPassword();
        default:
          notificationService.showNotification(message: l10n.authError, type: NotificationType.error);
          return RegistrationUnknownError();
      }
    } catch (e, st) {
      dev.log('[Auth.Register] Generic error', name: 'LoginBackend', error: e, stackTrace: st);
      notificationService.showNotification(message: l10n.authError, type: NotificationType.error);
      return RegistrationUnknownError();
    } finally {
      try {
        initializer.setRegistrationStatus(false);
      } catch (_) {
        dev.log('Warning: Initializer disposed before registration lock could be released.');
      }
    }
  }

  /// Handles the entire Google Sign-In flow, aligned with the latest documentation.
  Future<GoogleSignInResult> signInWithGoogle({
    required BuildContext context,
    required IntrovertNotificationService notificationService,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final extrovertNotificationService = context.read<ExtrovertNotificationService>();

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

      extrovertNotificationService.syncTokenAfterLogin().ignore();

      dev.log('[Auth.Google] Sign-in complete for UID: ${user.uid}.', name: 'LoginBackend');
      return GoogleSignInSuccess(user);

    }  catch (e, st) {

      if (e is PlatformException && e.code == 'network_error') {
        dev.log('[Auth.Google] A network error occurred during Google Sign-In', name: 'LoginBackend', error: e, stackTrace: st);
        notificationService.showNotification(message: l10n.noInternetConnection, type: NotificationType.error);
      }
      else if (e is GoogleSignInException && e.code == GoogleSignInExceptionCode.canceled) {
        dev.log('[Auth.Google] Sign-in process was cancelled by the user.', name: 'LoginBackend');
      } else {
        dev.log('[Auth.Google] An unexpected error occurred during Google Sign-In', name: 'LoginBackend', error: e, stackTrace: st);
        notificationService.showNotification(message: l10n.authError, type: NotificationType.error);
      }

      await _googleSignIn.disconnect().catchError((_) {});
      await _auth.signOut().catchError((_) {});

      return GoogleSignInFailure();
    }
  }

  /// Handles the anonymous sign-in flow.
  Future<AnonymousSignInResult> signInAnonymously({
    required BuildContext context,
    required IntrovertNotificationService notificationService,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final extrovertNotificationService = context.read<ExtrovertNotificationService>();

    if (!await InternetConnection().hasInternetAccess) {
      notificationService.showNotification(
        message: l10n.noInternetConnection,
        type: NotificationType.error,
      );
      return AnonymousSignInNetworkError();
    }

    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      final User? user = userCredential.user;

      if (user == null) throw FirebaseAuthException(code: 'anonymous-user-null');

      extrovertNotificationService.syncTokenAfterLogin().ignore();

      dev.log('[Auth.Anonymous] Signed in anonymously. UID: ${user.uid}', name: 'LoginBackend');

      return AnonymousSignInSuccess(user);

    } catch (e, st) {
      dev.log(
          '[Auth.Anonymous] Error during anonymous sign-in',
          name: 'LoginBackend',
          error: e,
          stackTrace: st
      );

      notificationService.showNotification(
          message: l10n.authError,
          type: NotificationType.error
      );
      return AnonymousSignInFailure();
    }
  }

  /// Handles the Apple Sign-In flow.
  /// Uses FirebaseAuth's Apple provider to avoid "missing initial state" issues caused by web redirects.
  Future<AppleSignInResult> signInWithApple({
    required BuildContext context,
    required IntrovertNotificationService notificationService,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final extrovertNotificationService = context.read<ExtrovertNotificationService>();

    try {
      // 1) Use Firebase's native provider flow
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithProvider(appleProvider);

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("Firebase sign in with Apple returned a null user.");
      }

      // 2) Post-login logic
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Apple provider may set displayName (not guaranteed). Prefer Firebase user fields when available.
        final String? displayName = user.displayName?.trim().isEmpty ?? true
            ? null
            : user.displayName?.trim();

        await _postUsernameSuggestion(uid: user.uid, username: displayName);

        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
      }

      // 3) Persist session
      await _secureStorage.write(key: 'remember_me', value: 'true');
      if (user.email != null) {
        await _secureStorage.write(key: 'email', value: user.email);
      }

      // 4) Token sync (non-blocking)
      extrovertNotificationService.syncTokenAfterLogin().ignore();

      dev.log('[Auth.Apple] Sign-in complete for UID: ${user.uid}.',
          name: 'LoginBackend');

      return AppleSignInSuccess(user);
    } catch (e, st) {
      if (e is FirebaseAuthException && e.code == 'canceled') {
        dev.log('[Auth.Apple] Sign-in cancelled by user.', name: 'LoginBackend');
        return AppleSignInFailure();
      }

      dev.log('[Auth.Apple] Error during Apple Sign-In',
          name: 'LoginBackend', error: e, stackTrace: st);

      notificationService.showNotification(
        message: l10n.authError,
        type: NotificationType.error,
      );
      return AppleSignInFailure();
    }
  }

  /// Upgrades an anonymous account by linking it with Email/Password.
  /// Triggers the Cloud Function 'completeAnonymousRegistration' upon success.
  Future<RegistrationResult> linkAnonymousWithEmail({
    required BuildContext context,
    required IntrovertNotificationService notificationService,
    required String username,
    required String email,
    required String password,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final user = _auth.currentUser;
    final extrovertNotificationService = context.read<ExtrovertNotificationService>();

    if (user == null || !user.isAnonymous) return RegistrationUnknownError();

    if (!await InternetConnection().hasInternetAccess) {
      notificationService.showNotification(message: l10n.noInternetConnection, type: NotificationType.error);
      return RegistrationNetworkError();
    }

    try {
      final isAvailable = await _isUsernameAvailable(username, notificationService, l10n);
      if (!isAvailable) return RegistrationUsernameTaken();

      final credential = EmailAuthProvider.credential(email: email, password: password);
      await user.linkWithCredential(credential);

      final callable = _functions.httpsCallable('completeAnonymousRegistration');
      await callable.call();

      extrovertNotificationService.syncTokenAfterLogin().ignore();

      return RegistrationSuccess();

    } on FirebaseAuthException catch (e) {
      dev.log('[Auth.Link] Error: ${e.code}', name: 'LoginBackend');
      switch (e.code) {
        case 'email-already-in-use':
        case 'credential-already-in-use':
          return RegistrationEmailInUse();
        case 'weak-password':
          return RegistrationWeakPassword();
        default:
          notificationService.showNotification(message: l10n.authError, type: NotificationType.error);
          return RegistrationUnknownError();
      }
    } catch (e) {
      dev.log('[Auth.Link] Generic Error: $e', name: 'LoginBackend');
      notificationService.showNotification(message: l10n.authError, type: NotificationType.error);
      return RegistrationUnknownError();
    }
  }

  // --- Private Helper Methods ---

  Future<void> _postUsernameSuggestion({required String uid, String? username}) async {
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

  Future<bool> _isUsernameAvailable(String username, IntrovertNotificationService ns, AppLocalizations l10n) async {
    try {
      final callable = _functions.httpsCallable('isUsernameAvailable');
      final result = await callable.call<Map<String, dynamic>>({'username': username});
      return result.data['available'] as bool? ?? false;
    } on FirebaseFunctionsException catch (e) {
      dev.log('[UsernameCheck] FirebaseFunctionsException: ${e.code}', name: 'LoginBackend', error: e.message);
      ns.showNotification(message: l10n.anErrorOccurred, type: NotificationType.error);
      return false;
    } catch (e) {
      dev.log('[UsernameCheck] Generic error: $e', name: 'LoginBackend');
      ns.showNotification(message: l10n.noInternetConnection, type: NotificationType.error);
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