// lib/providers/user_provider.dart

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider class to manage the authenticated user's state and data.
///
/// This class is the single source of truth for user information. It handles
/// fetching data from Firestore, caching it locally, and providing reactive
/// updates to the UI.
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
  /// that automatically updates the provider's state when data changes in the database.
  void listenToUserData(User user) {
    // Cancel any existing subscription to avoid memory leaks.
    _userSubscription?.cancel();

    _userSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _userData = snapshot.data();
        _cacheUserData(_userData!); // Persist data to local cache.
        notifyListeners(); // Notify widgets to rebuild with new data.
        debugPrint("[UserProvider] User data updated for: ${user.uid}");
      }
    }, onError: (error) {
      debugPrint("[UserProvider] Error listening to user data: $error");
      // On error, fall back to a signed-out state by clearing all data.
      clearDataOnSignOut();
    });
  }

  /// Fetches the initial user data for a responsive UI on app launch or sign-in.
  ///
  /// It prioritizes loading from the cache for immediate UI feedback,
  /// then fetches the latest data from the server to ensure freshness.
  Future<void> fetchInitialData(User user) async {
    try {
      // First, load from cache so the UI isn't blocked.
      await _loadCachedUserData();
      notifyListeners();

      // Then, fetch the latest data from the server.
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _userData = doc.data();
        await _cacheUserData(_userData!);
        notifyListeners();
        debugPrint("[UserProvider] Initial user data fetched for: ${user.uid}");
      }
    } catch (e) {
      debugPrint("[UserProvider] Error fetching initial data: $e");
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
  Future<void> _cacheUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      data,
      toEncodable: (object) =>
      object is Timestamp ? object.toDate().toIso8601String() : object,
    );
    await prefs.setString('cached_user_data', jsonString);
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