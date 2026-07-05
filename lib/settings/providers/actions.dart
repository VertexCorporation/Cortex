// lib/settings/providers/actions.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Required for accessing GeneralProvider
import '../../initialization.dart';
import '../../internet.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/introvert.dart';
import '../services/auth.dart';
import '../services/profile.dart';
import 'general.dart'; // Import to access freezeForLogout

/// Manages user-initiated actions and their corresponding UI states.
class SettingsActionProvider with ChangeNotifier {
  final AuthService _authService;
  final ProfileService _profileService;
  final IntrovertNotificationService _notificationService;
  final InternetProvider _internetProvider;
  final AppInitializer _appInitializer;

  SettingsActionProvider({
    required AuthService authService,
    required ProfileService profileService,
    required IntrovertNotificationService notificationService,
    required InternetProvider internetProvider,
    required AppInitializer appInitializer,
  })  : _authService = authService,
        _profileService = profileService,
        _notificationService = notificationService,
        _internetProvider = internetProvider,
        _appInitializer = appInitializer;

  // --- UI State Variables ---
  bool _isUpdatingUsername = false;

  bool get isUpdatingUsername => _isUpdatingUsername;

  bool _isChangingPassword = false;

  bool get isChangingPassword => _isChangingPassword;

  bool _isLoggingOut = false;

  bool get isLoggingOut => _isLoggingOut;

  bool _isDeletingAccount = false;

  bool get isDeletingAccount => _isDeletingAccount;

  bool _isRedeemingCode = false;

  bool get isRedeemingCode => _isRedeemingCode;

  // --- Private Helpers ---

  bool _checkInternet(AppLocalizations localizations) {
    if (!_internetProvider.isConnected) {
      _notificationService.showNotification(
        message: localizations.noInternetConnection,
        type: NotificationType.error,
      );
      return false;
    }
    return true;
  }

  String _getLocalizedProfileError(
      AppLocalizations localizations, String code) {
    switch (code) {
      case 'already-exists':
        return localizations.usernameTaken;
      case 'invalid-argument':
        return localizations.invalidUsernameCharacters;
      case 'not-found':
        return localizations.tagNotFound;
      case 'resource-exhausted':
        return localizations.tooManyRequests;
      default:
        return localizations.anErrorOccurred;
    }
  }

  String _getLocalizedAuthError(AppLocalizations localizations, String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return localizations.wrongPassword;
      case 'weak-password':
        return localizations.weakPassword;
      case 'too-many-requests':
        return localizations.tooManyRequests;
      default:
        return localizations.anErrorOccurred;
    }
  }

  // --- Public Methods / Actions ---

  Future<void> updateUsername(BuildContext context, String newUsername) async {
    final localizations = AppLocalizations.of(context)!;
    if (isUpdatingUsername || !_checkInternet(localizations)) return;

    _isUpdatingUsername = true;
    notifyListeners();

    try {
      await _profileService.updateUsername(newUsername);
      _notificationService.showNotification(
          message: localizations.profileUpdated,
          type: NotificationType.success);
    } on ProfileException catch (e) {
      throw Exception(_getLocalizedProfileError(localizations, e.code));
    } catch (_) {
      throw Exception(localizations.anErrorOccurred);
    } finally {
      _isUpdatingUsername = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(
    BuildContext context, {
    required String oldPassword,
    required String newPassword,
  }) async {
    final localizations = AppLocalizations.of(context)!;
    if (isChangingPassword || !_checkInternet(localizations)) return;

    _isChangingPassword = true;
    notifyListeners();

    try {
      await _authService.changePassword(
          oldPassword: oldPassword, newPassword: newPassword);
      _notificationService.showNotification(
          message: localizations.passwordUpdated,
          type: NotificationType.success);
    } on AuthException catch (e) {
      throw Exception(_getLocalizedAuthError(localizations, e.code));
    } catch (_) {
      throw Exception(localizations.anErrorOccurred);
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  Future<void> redeemCode(BuildContext context, String code) async {
    final localizations = AppLocalizations.of(context)!;
    if (isRedeemingCode || !_checkInternet(localizations)) return;

    _isRedeemingCode = true;
    notifyListeners();

    try {
      await _profileService.redeemCreatorCode(code);
      _notificationService.showNotification(
          message: localizations.creatorSupportedSuccess,
          type: NotificationType.success);
    } on ProfileException catch (e) {
      throw Exception(_getLocalizedProfileError(localizations, e.code));
    } catch (_) {
      throw Exception(localizations.anErrorOccurred);
    } finally {
      _isRedeemingCode = false;
      notifyListeners();
    }
  }

  /// Performs the logout process and handles UI navigation upon success.
  /// Freezes the GeneralProvider state before signing out to prevent UI flicker.
  Future<void> performLogout(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    if (_isLoggingOut) return;

    _isLoggingOut = true;
    notifyListeners();

    // 1. FREEZE UI STATE
    // We snapshot the current settings data immediately.
    // This ensures the UI doesn't "panic" or flicker when user data is cleared
    // from the underlying providers during the signOut process.
    if (context.mounted) {
      context.read<SettingsGeneralProvider>().freezeForLogout();
    }

    try {
      // 2. PERFORM LOGOUT
      await _appInitializer.signOut();

      // 3. NAVIGATION
      if (context.mounted) {
        // Pop the Logout Confirmation Dialog
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Pop the Settings Screen to reveal MainScreen/AuthScreen underneath
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint("SettingsActionProvider: An error occurred during logout: $e");
      _notificationService.showNotification(
          message: localizations.anErrorOccurred, type: NotificationType.error);
    } finally {
      _isLoggingOut = false;
      // We check mounted again because the navigator pops above might have unmounted us
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    if (isDeletingAccount || !_checkInternet(localizations)) {
      throw Exception(localizations.noInternetConnection);
    }

    _isDeletingAccount = true;
    notifyListeners();

    // Freeze UI state for account deletion as well to prevent layout shifts.
    if (context.mounted) {
      context.read<SettingsGeneralProvider>().freezeForLogout();
    }

    try {
      await _profileService.requestAccountDeletion();
      _notificationService.showNotification(
          message: localizations.accountDeletionRequested,
          type: NotificationType.success);

      await _appInitializer.signOut();

      // Pop dialogs
      if (context.mounted) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } on ProfileException catch (e) {
      final message = _getLocalizedProfileError(localizations, e.code);
      _notificationService.showNotification(
          message: message, type: NotificationType.error);
      rethrow;
    } catch (e) {
      _notificationService.showNotification(
          message: localizations.anErrorOccurred, type: NotificationType.error);
      rethrow;
    } finally {
      _isDeletingAccount = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }
}
