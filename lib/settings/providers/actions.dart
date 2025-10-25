// lib/settings/providers/user.dart

import 'package:flutter/foundation.dart';
import '../../initialization.dart';
import '../../notifications.dart';
import '../../internet.dart';
import '../services/auth.dart';
import '../services/profile.dart';

/// Manages user-initiated actions and their corresponding UI states.
///
/// This provider acts as a ViewModel in an MVVM architecture. It orchestrates
/// user operations like updating a profile, changing a password, or deleting an
/// account by communicating with the appropriate services (`AuthService`, `ProfileService`).
///
/// It holds the state for ongoing operations (e.g., `isUpdatingUsername`)
/// and notifies listeners, allowing the UI to react with loading indicators
/// or state changes. For global actions like signing out, it delegates to the
/// `AppInitializer` to ensure a clean and complete session teardown.
class SettingsActionProvider with ChangeNotifier {
  final AuthService _authService;
  final ProfileService _profileService;
  final NotificationService _notificationService;
  final InternetProvider _internetProvider;
  final AppInitializer _appInitializer;

  SettingsActionProvider({
    required AuthService authService,
    required ProfileService profileService,
    required NotificationService notificationService,
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

  // --- Private Helper ---
  bool _checkInternet() {
    if (!_internetProvider.isConnected) {
      _notificationService.showNotification(
        message: "No internet connection. Please try again later.",
        isSuccess: false,
      );
      return false;
    }
    return true;
  }

  // --- Public Methods / Actions ---

  /// Attempts to update the user's username.
  ///
  /// Shows notifications for success or failure states.
  /// Returns `true` on success, `false` otherwise.
  ///
  /// Throws: Catches `ProfileException` for specific user-friendly error messages.
  Future<bool> updateUsername(String newUsername) async {
    if (isUpdatingUsername || !_checkInternet()) return false;

    _isUpdatingUsername = true;
    notifyListeners();

    try {
      await _profileService.updateUsername(newUsername);
      _notificationService.showNotification(
          message: "Your profile has been updated successfully.",
          isSuccess: true);
      return true;
    } on ProfileException catch (e) {
      _notificationService.showNotification(message: e.message, isSuccess: false);
      return false;
    } catch (e) {
      _notificationService.showNotification(
          message: "An unexpected error occurred.", isSuccess: false);
      return false;
    } finally {
      _isUpdatingUsername = false;
      notifyListeners();
    }
  }

  /// Attempts to change the current user's password.
  ///
  /// Shows notifications for success or failure states.
  /// Returns `true` on success, `false` otherwise.
  ///
  /// Throws: Catches `AuthException` for specific user-friendly error messages.
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (isChangingPassword || !_checkInternet()) return false;

    _isChangingPassword = true;
    notifyListeners();

    try {
      await _authService.changePassword(
          oldPassword: oldPassword, newPassword: newPassword);
      _notificationService.showNotification(
          message: "Your password has been updated.", isSuccess: true);
      return true;
    } on AuthException catch (e) {
      _notificationService.showNotification(message: e.message, isSuccess: false);
      return false;
    } catch (e) {
      _notificationService.showNotification(
          message: "An unexpected error occurred.", isSuccess: false);
      return false;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  /// Attempts to redeem a creator or promotional code.
  ///
  /// Shows notifications for success or failure states.
  /// Returns `true` on success, `false` otherwise.
  ///
  /// Throws: Catches `ProfileException` for specific user-friendly error messages.
  Future<bool> redeemCode(String code) async {
    if (isRedeemingCode || !_checkInternet()) return false;

    _isRedeemingCode = true;
    notifyListeners();

    try {
      await _profileService.redeemCreatorCode(code);
      _notificationService.showNotification(
          message: "Creator supported successfully!", isSuccess: true);
      return true;
    } on ProfileException catch (e) {
      _notificationService.showNotification(message: e.message, isSuccess: false);
      return false;
    } catch (e) {
      _notificationService.showNotification(
          message: "An unexpected error occurred.", isSuccess: false);
      return false;
    } finally {
      _isRedeemingCode = false;
      notifyListeners();
    }
  }

  /// Initiates the full, orchestrated sign-out process.
  /// Delegates the core logic to `AppInitializer` for a clean session teardown.
  Future<void> performLogout() async {
    if (_isLoggingOut) return;

    _isLoggingOut = true;
    notifyListeners();

    try {
      await _appInitializer.signOut();
    } catch (e) {
      debugPrint("UserProvider: An error occurred during the orchestrated logout: $e");
      _notificationService.showNotification(
          message: "Could not log out. Please try again.", isSuccess: false);
    } finally {
      // The AppInitializer's auth listener handles UI navigation.
      // We only reset the local state, ensuring we don't call notifyListeners
      // on a disposed widget.
      _isLoggingOut = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  /// Initiates the permanent deletion of the user's account.
  ///
  /// This is a two-step process:
  /// 1. Request account deletion from the backend via `ProfileService`.
  /// 2. Delegate the full sign-out process to `AppInitializer`.
  /// Returns `true` on success, `false` otherwise.
  Future<bool> deleteAccount() async {
    if (isDeletingAccount || !_checkInternet()) return false;

    _isDeletingAccount = true;
    notifyListeners();

    try {
      await _profileService.requestAccountDeletion();
      _notificationService.showNotification(
          message: "Account deletion request sent. You will be logged out.",
          isSuccess: true);

      // After a successful request, perform a full sign-out.
      await _appInitializer.signOut();
      return true;
    } on ProfileException catch (e) {
      _notificationService.showNotification(message: e.message, isSuccess: false);
      return false;
    } catch (e) {
      _notificationService.showNotification(
          message: "An unexpected error occurred.", isSuccess: false);
      return false;
    } finally {
      _isDeletingAccount = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }
}