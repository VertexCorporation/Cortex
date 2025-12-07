// lib/settings/providers/general.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Provider & Service Imports
import '../../internet.dart';
import '../../cache.dart';
import '../../notifications/introvert.dart';
import '../services/auth.dart';
import '../services/profile.dart';

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

  String? _trackedUserId;

  // --- Public Getters ---
  bool get isLoading => _isLoading;
  bool get hasInternet => _hasInternet;
  bool get isResendingEmail => _isResendingEmail;
  Map<String, dynamic>? get userData => _userData;

  bool get isVerified => _authService.isCurrentUserVerified();
  bool get isAnonymous {
    if (_userData == null) return false;
    return _userData!['accountType'] == 'anonymous';
  }

  // --- Computed Properties ---
  Timestamp? get subscriptionExpiresAt {
    final expires = _userData?['subscriptionExpiresAt'];
    if (expires is Timestamp) return expires;
    if (expires is String) {
      final parsedDate = DateTime.tryParse(expires);
      return parsedDate != null ? Timestamp.fromDate(parsedDate) : null;
    }
    return null;
  }

  int get activeSubscriptionLevel {
    final level = _userData?['hasCortexSubscription'] as int? ?? 0;
    if (level >= 4) return level;
    if (level == 0) return 0;
    final expires = subscriptionExpiresAt;
    if (expires == null || expires.toDate().isBefore(DateTime.now())) return 0;
    return level;
  }

  int get verificationAttempts => _userData?['verifyAttempts'] as int? ?? 0;

  Timestamp? get createdAt {
    final created = _userData?['createdAt'];
    if (created is Timestamp) return created;
    if (created is String) {
      final parsedDate = DateTime.tryParse(created);
      return parsedDate != null ? Timestamp.fromDate(parsedDate) : null;
    }
    return null;
  }

  SettingsGeneralProvider({
    required AuthService authService,
    required ProfileService profileService,
    required IntrovertNotificationService notificationService,
  })  : _authService = authService,
        _profileService = profileService,
        _notificationService = notificationService;

  void updateUser(User? user) {
    if (user == null) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_authService.currentUser == null) {
          _userData = null;
          _trackedUserId = null;
          notifyListeners();
          debugPrint("[GeneralProvider] Data cleared gracefully after exit animation.");
        }
      });

    } else {
      if (_trackedUserId != user.uid) {
        debugPrint("[GeneralProvider] User changed (Old: $_trackedUserId, New: ${user.uid}). Immediate reset.");
        _userData = null;
        _trackedUserId = user.uid;
        notifyListeners();
        loadInitialData();
      }
    }
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

    final cachedData = CacheService.get<Map<String, dynamic>>(CacheKey.settingsUserData);
    final currentUser = _authService.currentUser;

    if (cachedData != null && currentUser != null) {
      bool isCacheValid = true;

      final String? cachedUserId = cachedData['userId'];
      if (cachedUserId != null && cachedUserId != currentUser.uid) {
        isCacheValid = false;
      }

      final String? cachedEmail = cachedData['email'];
      if (currentUser.isAnonymous && (cachedEmail != null && cachedEmail.isNotEmpty)) {
        isCacheValid = false;
      }

      if (isCacheValid) {
        _userData = cachedData;
        _trackedUserId = currentUser.uid;
      } else {
        CacheService.invalidate(CacheKey.settingsUserData);
        _userData = null;
      }
    }

    _isLoading = false;
    notifyListeners();

    if (_hasInternet && currentUser != null) {
      await refreshData(isInitialLoad: true);
    }
  }

  Future<void> refreshData({bool isInitialLoad = false}) async {
    if (!_hasInternet) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      await _authService.reloadCurrentUser();
      final freshData = await _profileService.fetchUserData();

      freshData['userId'] = currentUser.uid;

      _userData = freshData;
      _trackedUserId = currentUser.uid;

      CacheService.set(CacheKey.settingsUserData, freshData);
      notifyListeners();
    } catch (e) {
      if (!isInitialLoad && _userData == null) {
        debugPrint("[GeneralProvider] Error refreshing data: $e");
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
      if (hasListeners) notifyListeners();
    }
  }
}