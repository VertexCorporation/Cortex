// lib/settings/providers/general.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Provider & Service Imports
import '../../internet.dart';
import '../../cache.dart';
import '../../notifications/introvert.dart';
import '../services/auth.dart';
import '../services/profile.dart';


/// Manages the general state and data specifically for the settings screen.
///
/// This provider acts as the primary ViewModel for the settings UI. Its main
/// responsibilities are scoped to the lifecycle of the settings screen:
///
/// 1.  **Data Loading & Caching:** It fetches a snapshot of the user's data
///     from services upon initialization. It leverages `CacheService` to
///     provide instant data loading on subsequent visits and to reduce
///     unnecessary network requests.
/// 2.  **State Management:** It tracks UI-specific states like the overall
///     loading status (`isLoading`), internet connectivity (`hasInternet`),
///     and the state of actions like resending a verification email (`isResendingEmail`).
/// 3.  **Data Source for UI Components:** It acts as the single source of truth
///     for all data displayed on the settings screen, such as username,
///     email, subscription level, etc.
class SettingsGeneralProvider with ChangeNotifier {
  // --- Service Dependencies ---
  final AuthService _authService;
  final ProfileService _profileService;
  final IntrovertNotificationService _notificationService;

  // --- Private State Variables ---
  bool _isLoading = true;
  bool _hasInternet = true;
  bool _isResendingEmail = false;
  Map<String, dynamic>? _userData;

  // --- Public Getters for UI State ---
  bool get isLoading => _isLoading;

  bool get hasInternet => _hasInternet;

  bool get isResendingEmail => _isResendingEmail;

  Map<String, dynamic>? get userData => _userData;

  bool get isVerified => _authService.isCurrentUserVerified();

  // --- Computed Properties from UserData (Safe Getters) ---

  /// The expiration date of the user's subscription, if any.
  ///
  /// This robust getter correctly handles both `Timestamp` objects from a live
  /// Firestore fetch and `String` representations from a JSON cache.
  Timestamp? get subscriptionExpiresAt {
    final expires = _userData?['subscriptionExpiresAt'];
    if (expires is Timestamp) return expires; // Live data
    if (expires is String) {
      final parsedDate = DateTime.tryParse(expires); // Cached data
      return parsedDate != null ? Timestamp.fromDate(parsedDate) : null;
    }
    return null;
  }

  /// The user's **active** subscription level (e.g., 0 for Free, 1 for Plus).
  ///
  /// This getter serves as the single source of truth for the active subscription status.
  /// It combines the raw subscription level with its expiration date, returning 0
  /// if the subscription is expired. This makes it safe to use throughout the UI
  /// for feature locking and display logic.
  int get activeSubscriptionLevel {
    final level = _userData?['hasCortexSubscription'] as int? ?? 0;

    // Legacy subscriptions (levels 4, 5, 6) are considered lifetime and always active.
    if (level >= 4) {
      return level;
    }

    // If the user is on the free tier, no further checks are needed.
    if (level == 0) {
      return 0;
    }

    // For standard subscriptions, check if the expiration date is valid and in the future.
    final expires = subscriptionExpiresAt;
    if (expires == null || expires.toDate().isBefore(DateTime.now())) {
      return 0; // Subscription is expired or has no expiration date.
    }

    // If all checks pass, the subscription is active.
    return level;
  }

  /// The number of times a verification email has been resent.
  int get verificationAttempts => _userData?['verifyAttempts'] as int? ?? 0;

  /// The timestamp of when the user account was created.
  Timestamp? get createdAt {
    final created = _userData?['createdAt'];
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
  })
      : _authService = authService,
        _profileService = profileService,
        _notificationService = notificationService {
    loadInitialData();
  }

  void updateConnectivity(InternetProvider internetProvider) {
    final bool wasConnected = _hasInternet;
    _hasInternet = internetProvider.isConnected;
    if (_hasInternet && !wasConnected) {
      debugPrint("[GeneralProvider] Internet reconnected. Refreshing data.");
      refreshData();
    }
  }

  Future<void> loadInitialData() async {
    _isLoading = true;

    final cachedData = CacheService.get<Map<String, dynamic>>(
        CacheKey.settingsUserData);
    if (cachedData != null) {
      _userData = cachedData;
    }

    _isLoading = false;
    notifyListeners();

    if (_hasInternet) {
      await refreshData(isInitialLoad: true);
    }
  }

  Future<void> refreshData({bool isInitialLoad = false}) async {
    if (!_hasInternet) {
      return;
    }
    try {
      await _authService.reloadCurrentUser();
      final freshData = await _profileService.fetchUserData();
      _userData = freshData;
      CacheService.set(CacheKey.settingsUserData, freshData);
      notifyListeners();
    } catch (e) {
      debugPrint("[GeneralProvider] Error refreshing user data: $e");
      if (!isInitialLoad && _userData == null) {
        _notificationService.showNotification(
            message: "Could not load your profile data.",
            type: NotificationType.error);
      }
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
}