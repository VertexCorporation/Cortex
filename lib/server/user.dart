// lib/server/user.dart

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider class to manage the authenticated user's state and data.
///
/// This class is the single source of truth for user information. It handles
/// fetching data from Firestore, caching it locally to allow offline usage,
/// and providing reactive updates to the UI.
class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  // --- Public Getters ---

  /// The current user's data as a map. Returns null if not logged in.
  Map<String, dynamic>? get userData => _userData;

  /// Returns true if a user is authenticated and their data has been loaded.
  bool get isLoggedIn => _auth.currentUser != null && _userData != null;

  /// The user's display name. Defaults to 'Guest' if unavailable.
  String get username => _userData?['username'] as String? ?? 'Guest';

  /// Checks if the current user is in 'Guest/Anonymous' mode.
  /// Returns true ONLY if the accountType is explicitly 'anonymous'.
  bool get isAnonymous {
    if (_userData == null) return false;
    return _userData!['accountType'] == 'anonymous';
  }

  /// Returns true if the user has any active, non-free subscription tier.
  ///
  /// UPDATED LOGIC: This now correctly handles data sources from both Firestore
  /// (where dates are [Timestamp]) and local Cache (where dates are ISO [String]s).
  bool get isSubscriptionActive {
    final data = _userData;
    // Safety check: if no data is loaded yet, assume no subscription.
    if (data == null) {
      return false;
    }

    final int level = data['hasCortexSubscription'] as int? ?? 0;

    // Lifetime or high-tier subscription (no expiration check needed).
    if (level >= 4) {
      return true;
    }

    // Standard subscription tiers (check expiration).
    if (level > 0) {
      final dynamic expiresAtRaw = data['subscriptionExpiresAt'];

      DateTime? expiryDate;

      // Case 1: Live data from Firestore (Timestamp object).
      if (expiresAtRaw is Timestamp) {
        expiryDate = expiresAtRaw.toDate();
      }
      // Case 2: Cached data from SharedPreferences (String object).
      // jsonDecode returns the date as a String, so we must parse it.
      else if (expiresAtRaw is String) {
        try {
          expiryDate = DateTime.parse(expiresAtRaw);
        } catch (_) {
          // If the date string is malformed, treat it as invalid/expired.
          debugPrint("[UserProvider] Error parsing cached subscription date.");
        }
      }

      // If valid expiry date exists and is in the future, subscription is active.
      if (expiryDate != null && expiryDate.isAfter(DateTime.now())) {
        return true;
      }
    }

    return false;
  }

  /// The first initial of the user's name for use in avatars. Defaults to '?'.
  String get profileInitial {
    final name = username;
    if (name.trim().isEmpty || name == 'Guest') {
      return '?';
    }
    return name.trim()[0].toUpperCase();
  }

  /// Listens for real-time updates to the user's document in Firestore.
  ///
  /// This method should be called when a user signs in. It sets up a stream
  /// that automatically updates the provider's state when data changes.
  void listenToUserData(User user) {
    // Cancel any existing subscription to avoid memory leaks.
    _userSubscription?.cancel();

    _userSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();

        // Safety: Only update if data is not null.
        if (data != null) {
          _userData = data;
          _cacheUserData(data); // Persist updated data to local cache.

          debugPrint("[LOG | UserProvider] Firing notifyListeners() due to Firestore snapshot update.");
          notifyListeners();
          debugPrint("[UserProvider] User data updated for: ${user.uid}");
        }
      }
    }, onError: (error) {
      debugPrint("[UserProvider] Error listening to user data: $error");

      // UPDATED LOGIC: Do not clear data on transient network errors.
      // We only force a sign-out state if the permission is explicitly denied,
      // which usually means the user was banned or deleted server-side.
      // For network errors, we keep the stale data (Fault Tolerance).
      if (error is FirebaseException && error.code == 'permission-denied') {
        clearDataOnSignOut();
      }
    });
  }

  /// Fetches the initial user data for a responsive UI on app launch or sign-in.
  ///
  /// It prioritizes loading from the cache for immediate UI feedback,
  /// then fetches the latest data from the server to ensure freshness.
  Future<void> fetchInitialData(User user) async {
    try {
      // 1. Load from cache so the UI isn't blocked/blank.
      await _loadCachedUserData();
      // If we found cached data, notify immediately to show the UI.
      if (_userData != null) notifyListeners();

      // 2. Fetch the authoritative data from the server.
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _userData = data;
          await _cacheUserData(data);
          notifyListeners(); // Rebuild with fresh data.
          debugPrint("[UserProvider] Initial user data fetched for: ${user.uid}");
        }
      }
    } catch (e) {
      debugPrint("[UserProvider] Error fetching initial data: $e");
      // Note: We don't throw here. If fetching fails, we stay with cached data
      // (or null data), preventing a crash.
    }
  }


  /// Clears all user data and cancels the Firestore stream subscription.
  ///
  /// This should be called when the user signs out to clean up resources
  /// and reset the application's state.
  Future<void> clearDataOnSignOut() async {
    await _userSubscription?.cancel();
    _userSubscription = null;
    _userData = null;
    await _clearCachedUserData();
    notifyListeners();
    debugPrint("[UserProvider] All user data and listeners cleared.");
  }

  // --- Private Helper Methods ---

  /// Caches the user data to SharedPreferences as a JSON string.
  /// Handles Firestore [Timestamp] conversion to String for JSON compatibility.
  Future<void> _cacheUserData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(
        data,
        toEncodable: (object) =>
        object is Timestamp ? object.toDate().toIso8601String() : object,
      );
      await prefs.setString('cached_user_data', jsonString);
    } catch (e) {
      debugPrint("[UserProvider] Cache write error: $e");
    }
  }

  /// Loads user data from the SharedPreferences cache, if it exists.
  Future<void> _loadCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_user_data');
    if (jsonString != null) {
      try {
        _userData = jsonDecode(jsonString);
      } catch(e) {
        debugPrint("[UserProvider] Failed to parse cached user data: $e");
      }
    }
  }

  /// Removes the user data from the SharedPreferences cache.
  Future<void> _clearCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user_data');
  }
}