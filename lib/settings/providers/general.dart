// lib/settings/providers/general.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Provider & Service Imports
import '../../internet.dart';
import '../../server/user.dart';
import '../../notifications/introvert.dart';
import '../services/auth.dart';
import '../services/profile.dart';

/// Manages the general state and data specifically for the settings screen.
///
/// This provider acts as the primary ViewModel for the settings UI.
/// Includes a "Freeze" mechanism to prevent UI flickering during logout.
class SettingsGeneralProvider with ChangeNotifier {
  // --- Service Dependencies ---
  final AuthService _authService;
  final ProfileService _profileService;
  final IntrovertNotificationService _notificationService;
  final UserProvider _userProvider;

  // --- Private State Variables ---
  bool _isLoading = false;
  bool _hasInternet = true;
  bool _isResendingEmail = false;

  // --- Freeze Mechanism State ---
  // These variables hold a snapshot of the user data during the logout process.
  bool _isFrozen = false;
  Map<String, dynamic>? _frozenUserData;
  bool _frozenIsAnonymous = false;
  bool _frozenIsVerified = true;
  int _frozenSubscriptionLevel = 0;

  /// Constructor: Injects services and starts the initialization process.
  SettingsGeneralProvider({
    required AuthService authService,
    required ProfileService profileService,
    required IntrovertNotificationService notificationService,
    required UserProvider userProvider,
  })
      : _authService = authService,
        _profileService = profileService,
        _notificationService = notificationService,
        _userProvider = userProvider;

  // --- Public Getters for UI State ---

  bool get isLoading => _isLoading;

  bool get hasInternet => _hasInternet;

  bool get isResendingEmail => _isResendingEmail;

  /// Snapshots the current user state and locks the UI to these values.
  /// Call this immediately before signing out to prevent UI flickering.
  void freezeForLogout() {
    _frozenUserData = _userProvider.userData;
    _frozenIsAnonymous = _userProvider.isAnonymous;
    _frozenIsVerified = _authService.isCurrentUserVerified();

    // Snapshot subscription level logic
    _frozenSubscriptionLevel = _userProvider.isSubscriptionActive
        ? (_userProvider.userData?['hasCortexSubscription'] as int? ?? 0)
        : 0;

    _isFrozen = true;
    notifyListeners();
  }

  /// Returns the user data.
  /// If frozen (logging out), returns the snapshot.
  /// Otherwise, returns live data from UserProvider.
  Map<String, dynamic>? get userData =>
      _isFrozen ? _frozenUserData : _userProvider.userData;

  bool get isVerified =>
      _isFrozen ? _frozenIsVerified : _authService.isCurrentUserVerified();

  /// Checks if the current user is in 'Guest/Anonymous' mode.
  bool get isAnonymous =>
      _isFrozen ? _frozenIsAnonymous : _userProvider.isAnonymous;

  // --- Computed Properties ---

  /// The expiration date of the user's subscription, if any.
  /// Accesses `userData` via the getter, so it respects the frozen state.
  Timestamp? get subscriptionExpiresAt {
    final data = userData;
    if (data == null) return null;

    final expires = data['subscriptionExpiresAt'];
    if (expires is Timestamp) return expires; // Live data
    if (expires is String) {
      final parsedDate = DateTime.tryParse(expires); // Cached data
      return parsedDate != null ? Timestamp.fromDate(parsedDate) : null;
    }
    return null;
  }

  /// The user's **active** subscription level (e.g., 0 for Free, 1 for Plus).
  int get activeSubscriptionLevel {
    if (_isFrozen) return _frozenSubscriptionLevel;

    return _userProvider.isSubscriptionActive
        ? (userData?['hasCortexSubscription'] as int? ?? 0)
        : 0;
  }

  /// The number of times a verification email has been resent.
  int get verificationAttempts => userData?['verifyAttempts'] as int? ?? 0;

  /// The timestamp of when the user account was created.
  Timestamp? get createdAt {
    final created = userData?['createdAt'];
    if (created is Timestamp) return created;
    if (created is String) {
      final parsedDate = DateTime.tryParse(created);
      return parsedDate != null ? Timestamp.fromDate(parsedDate) : null;
    }
    return null;
  }

  // --- Methods ---

  void updateConnectivity(InternetProvider internetProvider) {
    // If we are logging out (frozen), ignore connectivity updates to keep UI stable.
    if (_isFrozen) return;

    final bool wasConnected = _hasInternet;
    _hasInternet = internetProvider.isConnected;
    if (_hasInternet && !wasConnected) {
      debugPrint("[GeneralProvider] Internet reconnected. Refreshing data.");
      refreshData();
    }
  }

  /// Refreshes the user data by reloading the auth user and fetching the latest profile.
  Future<void> refreshData() async {
    // Prevent refreshing if no internet or if UI is frozen for logout.
    if (!_hasInternet || _isFrozen) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.reloadCurrentUser();
      // fetchInitialData updates the UserProvider's internal state (and cache).
      if (_authService.currentUser != null) {
        await _userProvider.fetchInitialData(_authService.currentUser!);
      }
      debugPrint("[GeneralProvider] Data refreshed via UserProvider.");
    } catch (e) {
      debugPrint("[GeneralProvider] Error refreshing user data: $e");
      _notificationService.showNotification(
          message: "Could not refresh profile data.",
          type: NotificationType.error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail() async {
    if (isResendingEmail || verificationAttempts >= 2 || !_hasInternet ||
        _isFrozen) {
      return;
    }
    _isResendingEmail = true;
    notifyListeners();
    try {
      await _authService.sendVerificationEmail();
      await _profileService.incrementVerificationAttempts();
      _notificationService.showNotification(
          message: "Verification link sent!", type: NotificationType.success);
      await refreshData();
    } catch (e) {
      _notificationService.showNotification(
          message: e.toString(), type: NotificationType.error);
    } finally {
      _isResendingEmail = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  /// Called when UserProvider updates (e.g. logout or new data fetched).
  void onUserProviderUpdate() {
    // If frozen, ignore updates from the underlying UserProvider to keep the UI static.
    if (!_isFrozen) {
      notifyListeners();
    }
  }
}