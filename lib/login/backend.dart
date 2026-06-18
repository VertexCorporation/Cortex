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
import '../internet.dart';
import 'package:provider/provider.dart';
import '../initialization.dart';
import '../main.dart';
import '../notifications/extrovert.dart';
import '../notifications/introvert.dart';
import '../referral.dart';
import 'anonymous_device_entitlement.dart';
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

class RegistrationInvalidUsername extends RegistrationResult {}

enum UsernameStatus { available, taken, invalid, error }

/// Represents the exhaustive set of outcomes for a Google Sign-In attempt.
sealed class GoogleSignInResult {}

class GoogleSignInSuccess extends GoogleSignInResult {
  final User user;

  GoogleSignInSuccess(this.user);
}

class GoogleSignInFailure extends GoogleSignInResult {}

class GoogleSignInCancelled extends GoogleSignInResult {}

class GoogleSignInNetworkError extends GoogleSignInResult {}

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

class AppleSignInCancelled extends AppleSignInResult {}

class AppleSignInNetworkError extends AppleSignInResult {}

/// A service class that encapsulates all backend authentication logic.
///
/// This class is completely decoupled from the UI. Its sole responsibility is to
/// communicate with backend services (Firebase, etc.) and return a strongly-typed
/// result object. It does not manage UI state like loading indicators.
class LoginBackendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');
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
    final extrovertNotificationService =
        context.read<ExtrovertNotificationService>();

    if (!await InternetService().hasInternet()) {
      notificationService.showNotification(
          message: l10n.noInternetConnection, type: NotificationType.error);
      return LoginNetworkError();
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found-after-signin');
      }

      await _handleSessionPersistence(email, password, rememberMe);
      // Removed redundant user.reload() for optimization.
      // The user object from signInWithEmailAndPassword is fresh enough for our needs.

      if (!user.emailVerified) {
        dev.log(
            '[Auth.Login] User email not verified. UID: ${user.uid}. Triggering verification flow.',
            name: 'LoginBackend');

        final initializer = Provider.of<AppInitializer>(
            context,
            listen: false);
        initializer.requestEmailVerification(
          email: user.email!,
          userId: user.uid,
          password: password,
        );

        _safeTokenSync(extrovertNotificationService);

        return LoginSuccess(user);
      }

      dev.log(
          '[Auth.Login] User verified. UID: ${user.uid}. Running post-login tasks.',
          name: 'LoginBackend');

      _safeTokenSync(extrovertNotificationService);

      return LoginSuccess(user);
    } on FirebaseAuthException catch (e) {
      dev.log('[Auth.Login] FirebaseAuthException: ${e.code}',
          name: 'LoginBackend', error: e.message);
      switch (e.code) {
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          return LoginInvalidCredentials();
        case 'user-disabled':
          return LoginUserDisabled();
        default:
          notificationService.showNotification(
              message: l10n.authError, type: NotificationType.error);
          return LoginUnknownError();
      }
    } catch (e, st) {
      dev.log('[Auth.Login] Generic error',
          name: 'LoginBackend', error: e, stackTrace: st);
      notificationService.showNotification(
          message: l10n.authError, type: NotificationType.error);
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
    final extrovertNotificationService =
        context.read<ExtrovertNotificationService>();
    final userProvider = context.read<UserProvider>();
    final initializer = Provider.of<AppInitializer>(
        context,
        listen: false);

    if (!await InternetService().hasInternet()) {
      notificationService.showNotification(
          message: l10n.noInternetConnection, type: NotificationType.error);
      return RegistrationNetworkError();
    }

    try {
      initializer.setRegistrationStatus(true);

      // --- ASYNC GAP 1 ---
      // --- ASYNC GAP 1 ---
      final availability =
          await _checkUsernameAvailability(username, notificationService, l10n);

      if (availability == UsernameStatus.invalid) {
        initializer.setRegistrationStatus(false);
        return RegistrationInvalidUsername();
      }

      if (availability != UsernameStatus.available) {
        initializer.setRegistrationStatus(false);
        if (availability == UsernameStatus.taken) {
          return RegistrationUsernameTaken();
        }
        // Username check failed (functions/internal/network). Don't mislabel as "taken".
        return RegistrationUnknownError();
      }

      // --- ASYNC GAP 2 ---
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-creation-returned-null');
      }

      userProvider.listenToUserData(user);
      CreditsManager.instance.listenToCredits();
      dev.log(
        '[Auth.Register] Manually attached UserProvider & CreditsManager listeners for new user (UID: ${user.uid}).',
        name: 'LoginBackend',
      );

      _safeTokenSync(extrovertNotificationService);

      // Fire and forget independent network tasks to reduce waiting time.
      _postUsernameSuggestion(uid: user.uid, username: username).ignore();
      user.sendEmailVerification().ignore();

      dev.log(
          '[Auth.Register] Verification email sent & suggestion posted for UID: ${user.uid}.',
          name: 'LoginBackend');

      initializer.requestEmailVerification(
        email: email,
        userId: user.uid,
        username: username,
        password: password,
      );

      return RegistrationSuccess();
    } on FirebaseAuthException catch (e) {
      dev.log('[Auth.Register] FirebaseAuthException: ${e.code}',
          name: 'LoginBackend', error: e.message);
      switch (e.code) {
        case 'email-already-in-use':
          return RegistrationEmailInUse();
        case 'weak-password':
          return RegistrationWeakPassword();
        default:
          notificationService.showNotification(
              message: l10n.authError, type: NotificationType.error);
          return RegistrationUnknownError();
      }
    } catch (e, st) {
      dev.log('[Auth.Register] Generic error',
          name: 'LoginBackend', error: e, stackTrace: st);
      notificationService.showNotification(
          message: l10n.authError, type: NotificationType.error);
      return RegistrationUnknownError();
    } finally {
      try {
        initializer.setRegistrationStatus(false);
      } catch (_) {
        dev.log(
            'Warning: Initializer disposed before registration lock could be released.');
      }
    }
  }

  /// Handles the entire Google Sign-In flow, aligned with the latest documentation.
  Future<GoogleSignInResult> signInWithGoogle({
    required BuildContext context,
    required IntrovertNotificationService notificationService,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final extrovertNotificationService =
        context.read<ExtrovertNotificationService>();

    try {
      // Step 0: Initialize GoogleSignIn with the required serverClientId.
      // This is the new, correct way to configure the sign-in process before starting.
      await _googleSignIn.initialize(
        serverClientId:
            '561391430514-nqjp6jl1s9oqi8ddg2fhm83lbvg94qca.apps.googleusercontent.com',
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

      // Step 4: Sign in or Link to Firebase.
      UserCredential userCredential;
      final currentUser = _auth.currentUser;
      bool wasAnonymousLinked = false;

      if (currentUser != null && currentUser.isAnonymous) {
        try {
          userCredential = await currentUser.linkWithCredential(credential);
          wasAnonymousLinked = true;
          dev.log('[Auth.Google] Successfully linked anonymous account.',
              name: 'LoginBackend');

          final callable =
              _functions.httpsCallable('completeAnonymousRegistration');
          await callable.call();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            dev.log(
                '[Auth.Google] Credential already in use. Falling back to signIn.',
                name: 'LoginBackend');
            userCredential = await _auth.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      } else {
        userCredential = await _auth.signInWithCredential(credential);
      }

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("Firebase sign in with Google returned a null user.");
      }

      // --- Post-login logic ---
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser || wasAnonymousLinked) {
        _postUsernameSuggestion(uid: user.uid, username: user.displayName);
      }

      await _secureStorage.write(key: 'remember_me', value: 'true');
      await _secureStorage.write(key: 'email', value: user.email);

      _safeTokenSync(extrovertNotificationService);

      dev.log('[Auth.Google] Sign-in complete for UID: ${user.uid}.',
          name: 'LoginBackend');
      return GoogleSignInSuccess(user);
    } catch (e, st) {
      if (e is PlatformException && e.code == 'network_error') {
        dev.log('[Auth.Google] A network error occurred during Google Sign-In',
            name: 'LoginBackend', error: e, stackTrace: st);
        notificationService.showNotification(
            message: l10n.noInternetConnection, type: NotificationType.error);
        await _googleSignIn.disconnect().catchError((_) {});
        if (_auth.currentUser?.isAnonymous != true) { await _auth.signOut().catchError((_) {}); }
        return GoogleSignInNetworkError();
      } else if ((e is GoogleSignInException &&
              e.code == GoogleSignInExceptionCode.canceled) ||
          (e is PlatformException && e.code == 'sign_in_canceled') ||
          (e is FirebaseAuthException && e.code == 'canceled')) {
        dev.log('[Auth.Google] Sign-in process was cancelled by the user.',
            name: 'LoginBackend');
        await _googleSignIn.disconnect().catchError((_) {});
        if (_auth.currentUser?.isAnonymous != true) { await _auth.signOut().catchError((_) {}); }
        return GoogleSignInCancelled();
      } else {
        dev.log(
            '[Auth.Google] An unexpected error occurred during Google Sign-In',
            name: 'LoginBackend',
            error: e,
            stackTrace: st);
        notificationService.showNotification(
            message: l10n.authError, type: NotificationType.error);
      }

      await _googleSignIn.disconnect().catchError((_) {});
      if (_auth.currentUser?.isAnonymous != true) { await _auth.signOut().catchError((_) {}); }

      return GoogleSignInFailure();
    }
  }

  /// Handles the anonymous sign-in flow.
  Future<AnonymousSignInResult> signInAnonymously({
    required BuildContext context,
    required IntrovertNotificationService notificationService,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final extrovertNotificationService =
        context.read<ExtrovertNotificationService>();

    if (!await InternetService().hasInternet()) {
      notificationService.showNotification(
        message: l10n.noInternetConnection,
        type: NotificationType.error,
      );
      return AnonymousSignInNetworkError();
    }

    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(code: 'anonymous-user-null');
      }

      await AnonymousDeviceEntitlement.instance.registerIfAnonymous(user);
      _safeTokenSync(extrovertNotificationService);

      dev.log('[Auth.Anonymous] Signed in anonymously. UID: ${user.uid}',
          name: 'LoginBackend');

      return AnonymousSignInSuccess(user);
    } catch (e, st) {
      dev.log('[Auth.Anonymous] Error during anonymous sign-in',
          name: 'LoginBackend', error: e, stackTrace: st);

      notificationService.showNotification(
          message: l10n.authError, type: NotificationType.error);
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
    final extrovertNotificationService =
        context.read<ExtrovertNotificationService>();

    try {
      // 1) Use Firebase's native provider flow
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final currentUser = FirebaseAuth.instance.currentUser;
      UserCredential userCredential;
      bool wasAnonymousLinked = false;

      if (currentUser != null && currentUser.isAnonymous) {
        try {
          userCredential = await currentUser.linkWithProvider(appleProvider);
          wasAnonymousLinked = true;
          dev.log('[Auth.Apple] Successfully linked anonymous account.',
              name: 'LoginBackend');

          final callable =
              _functions.httpsCallable('completeAnonymousRegistration');
          await callable.call();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' && e.credential != null) {
            dev.log(
                '[Auth.Apple] Credential already in use. Falling back to signIn.',
                name: 'LoginBackend');
            userCredential =
                await FirebaseAuth.instance.signInWithCredential(e.credential!);
          } else {
            rethrow;
          }
        }
      } else {
        userCredential =
            await FirebaseAuth.instance.signInWithProvider(appleProvider);
      }

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("Firebase sign in with Apple returned a null user.");
      }

      // 2) Post-login logic
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser || wasAnonymousLinked) {
        // Apple provider may set displayName (not guaranteed). Prefer Firebase user fields when available.
        final String? displayName = user.displayName?.trim().isEmpty ?? true
            ? null
            : user.displayName?.trim();

        _postUsernameSuggestion(uid: user.uid, username: displayName).ignore();

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
      _safeTokenSync(extrovertNotificationService);

      dev.log('[Auth.Apple] Sign-in complete for UID: ${user.uid}.',
          name: 'LoginBackend');

      return AppleSignInSuccess(user);
    } catch (e, st) {
      if (e is FirebaseAuthException && e.code == 'network_request_failed') {
        dev.log('[Auth.Apple] Network error during Apple Sign-In.',
            name: 'LoginBackend');
        notificationService.showNotification(
          message: l10n.noInternetConnection,
          type: NotificationType.error,
        );
        return AppleSignInNetworkError();
      }

      if ((e is FirebaseAuthException && e.code == 'canceled') ||
          (e is PlatformException && e.code == 'sign_in_canceled')) {
        dev.log('[Auth.Apple] Sign-in cancelled by user.',
            name: 'LoginBackend');
        return AppleSignInCancelled();
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
    final extrovertNotificationService =
        context.read<ExtrovertNotificationService>();

    if (user == null || !user.isAnonymous) return RegistrationUnknownError();

    if (!await InternetService().hasInternet()) {
      notificationService.showNotification(
          message: l10n.noInternetConnection, type: NotificationType.error);
      return RegistrationNetworkError();
    }

    try {
      final availability =
          await _checkUsernameAvailability(username, notificationService, l10n);
      if (availability == UsernameStatus.invalid) {
        return RegistrationInvalidUsername();
      }
      if (availability != UsernameStatus.available) {
        return RegistrationUsernameTaken();
      }

      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      await user.linkWithCredential(credential);

      final callable =
          _functions.httpsCallable('completeAnonymousRegistration');
      await callable.call();

      _safeTokenSync(extrovertNotificationService);

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
          notificationService.showNotification(
              message: l10n.authError, type: NotificationType.error);
          return RegistrationUnknownError();
      }
    } catch (e) {
      dev.log('[Auth.Link] Generic Error: $e', name: 'LoginBackend');
      notificationService.showNotification(
          message: l10n.authError, type: NotificationType.error);
      return RegistrationUnknownError();
    }
  }

  // --- Private Helper Methods ---

  Future<void> _postUsernameSuggestion(
      {required String uid, String? username}) async {
    try {
      final String? referrerId = await ReferralHandler.getSavedReferrerId();
      final expirationTime = DateTime.now().add(const Duration(hours: 1));

      await _firestore.collection('usernameSuggestions').doc(uid).set({
        'username': username,
        'invitedBy': referrerId,
        'expireAt': Timestamp.fromDate(expirationTime),
      });
      dev.log('[Auth.Suggestion] Posted suggestion for UID: $uid',
          name: 'LoginBackend');
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

  Future<UsernameStatus> _checkUsernameAvailability(String username,
      IntrovertNotificationService ns, AppLocalizations l10n) async {
    try {
      final callable = _functions.httpsCallable('isUsernameAvailable');
      final result =
          await callable.call<Map<String, dynamic>>({'username': username});
      final available = result.data['available'] as bool? ?? false;
      return available ? UsernameStatus.available : UsernameStatus.taken;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'invalid-argument') {
        dev.log('[UsernameCheck] Invalid argument: ${e.message}',
            name: 'LoginBackend');
        return UsernameStatus.invalid;
      }
      dev.log('[UsernameCheck] FirebaseFunctionsException: ${e.code}',
          name: 'LoginBackend', error: e.message);
      ns.showNotification(
          message: l10n.anErrorOccurred, type: NotificationType.error);
      return UsernameStatus.error;
    } catch (e) {
      dev.log('[UsernameCheck] Generic error: $e', name: 'LoginBackend');
      ns.showNotification(
          message: l10n.noInternetConnection, type: NotificationType.error);
      return UsernameStatus.error;
    }
  }

  Future<void> _handleSessionPersistence(
      String email, String password, bool rememberMe) async {
    if (rememberMe) {
      await _secureStorage.write(key: 'email', value: email);
      // H3 FIX: Do not store plaintext password. Firebase Auth handles session persistence.
      await _secureStorage.write(key: 'remember_me', value: 'true');
    } else {
      // Don't wipe unrelated keys (tokens, device state, etc.).
      await Future.wait([
        _secureStorage.delete(key: 'email'),
        _secureStorage.delete(key: 'password'),
        _secureStorage.delete(key: 'remember_me'),
      ]);
    }
  }

  /// A safe way to sync the token.
  /// It waits briefly to allow backend triggers (Cloud Functions) to create
  /// the user document in Firestore, preventing 'permission-denied' errors.
  void _safeTokenSync(ExtrovertNotificationService service) {
    service.syncTokenAfterLogin().ignore();
  }
}
