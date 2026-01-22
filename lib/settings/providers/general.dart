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
/// This provider acts as the primary ViewModel for the settings UI. Its main
/// responsibilities are scoped to the lifecycle of the settings screen:
///
/// 1.  **Data Source (Single Source of Truth):** It delegates all user data access
///     to the [UserProvider]. This ensures that when the global user state changes
///     (e.g., logout), the settings screen updates immediately without stale data.
/// 2.  **State Management:** It tracks UI-specific states like
///     internet connectivity (`hasInternet`) and action states (`isResendingEmail`).
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

  // --- Public Getters for UI State ---

  bool get isLoading => _isLoading;

  bool get hasInternet => _hasInternet;

  bool get isResendingEmail => _isResendingEmail;

  /// Returns the global user data directly from UserProvider.
  Map<String, dynamic>? get userData => _userProvider.userData;

  bool get isVerified => _authService.isCurrentUserVerified();

  /// Checks if the current user is in 'Guest/Anonymous' mode via UserProvider.
  bool get isAnonymous => _userProvider.isAnonymous;

  // --- Computed Properties from UserProvider (Safe Getters) ---

  /// The expiration date of the user's subscription, if any.
  Timestamp? get subscriptionExpiresAt {
    // We can rely on UserProvider's logic or parse here if needed.
    // Since UserProvider doesn't expose raw valid dates as Timestamps for UI,
    // we access the map directly to keep consistent usage.
    final expires = userData?['subscriptionExpiresAt'];
    if (expires is Timestamp) return expires; // Live data
    if (expires is String) {
      final parsedDate = DateTime.tryParse(expires); // Cached data
      return parsedDate != null ? Timestamp.fromDate(parsedDate) : null;
    }
    return null;
  }

  /// The user's **active** subscription level (e.g., 0 for Free, 1 for Plus).
  ///
  /// Delegates to UserProvider's robust logic if possible, or implements
  /// view-specific logic here.
  int get activeSubscriptionLevel => _userProvider.isSubscriptionActive
      ? (userData?['hasCortexSubscription'] as int? ?? 0)
      : 0;

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

  /// Constructor: Injects services and starts the initialization process.
  SettingsGeneralProvider({
    required AuthService authService,
    required ProfileService profileService,
    required IntrovertNotificationService notificationService,
    required UserProvider userProvider,
  })  : _authService = authService,
        _profileService = profileService,
        _notificationService = notificationService,
        _userProvider = userProvider;

  void updateConnectivity(InternetProvider internetProvider) {
    final bool wasConnected = _hasInternet;
    _hasInternet = internetProvider.isConnected;
    if (_hasInternet && !wasConnected) {
      debugPrint("[GeneralProvider] Internet reconnected. Refreshing data.");
      refreshData();
    }
  }

  /// Refreshes the user data by reloading the auth user and fetching the latest profile.
  /// The [UserProvider] will be updated via the fetch, keeping everything in sync.
  Future<void> refreshData() async {
    if (!_hasInternet) return;

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
    if (isResendingEmail || verificationAttempts >= 2 || !_hasInternet) return;
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
  /// We notify our listeners so the UI rebuilds with the new UserProvider data.
  void onUserProviderUpdate() {
    notifyListeners();
  }
}
