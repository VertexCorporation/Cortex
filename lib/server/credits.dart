// ================ credits.dart (COMPLETE REPLACEMENT) ================

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Central, singleton-style service that keeps the **current user’s**
/// credit balance in memory for UI display purposes and provides a real-time
/// stream of the total credit value.
///
/// This manager now listens directly to Firestore for any changes to the user's
/// credit document, ensuring the UI is always up-to-date automatically.
///
/// * Structure in Firestore (`users/<uid>`):
///   • `credits`        – main credits (earned / purchased)
///   • `bonusCredits`   – daily / promotional bonuses
///
/// Usage
/// ```dart
/// final cm = CreditsManager.instance; // Access the singleton
///
/// // In a widget, use a ValueListenableBuilder to listen for changes:
/// ValueListenableBuilder<int>(
///   valueListenable: cm.totalCreditsNotifier,
///   builder: (context, totalCredits, child) {
///     return Text('Credits: $totalCredits');
///   },
/// );
/// ```
class CreditsManager {
  // --- Private constructor for singleton pattern ---
  CreditsManager._();
  static final CreditsManager instance = CreditsManager._();

  // --- Public Notifier for the UI to listen to ---
  /// A Notifier that broadcasts the user's *total* credits.
  /// Widgets can listen to this to get real-time updates.
  final ValueNotifier<int> totalCreditsNotifier = ValueNotifier(0);

  // --- Internal State ---
  int _credits = 0;
  int _bonusCredits = 0;
  StreamSubscription? _creditsSubscription;

  /// Initializes the credit listener.
  /// Call this once when the user logs in.
  void listenToCredits() {
    // Cancel any existing listener before starting a new one.
    _creditsSubscription?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _updateCredits(0, 0); // User logged out, reset credits to 0
      return;
    }

    // Listen to the user's document for real-time changes.
    _creditsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        final main = (data['credits'] ?? 0) as int;
        final bonus = (data['bonusCredits'] ?? 0) as int;
        _updateCredits(main, bonus);
      } else {
        // This can happen briefly if the doc hasn't been created yet.
        debugPrint("CreditsManager: User document does not exist for ${user.uid}.");
        _updateCredits(0, 0);
      }
    }, onError: (error) {
      debugPrint("Error listening to credits: $error");
      // In case of error, we keep the last known value instead of resetting to 0.
    });
  }

  /// Updates the internal state and notifies all listeners.
  void _updateCredits(int newCredits, int newBonusCredits) {
    _credits = newCredits;
    _bonusCredits = newBonusCredits;
    // Notify listeners with the new total.
    totalCreditsNotifier.value = _credits + _bonusCredits;
    debugPrint("Credits updated: Main=$_credits, Bonus=$_bonusCredits, Total=${totalCreditsNotifier.value}");
  }

  /// Call this when the user logs out to clean up resources.
  void dispose() {
    _creditsSubscription?.cancel();
    _creditsSubscription = null;
    totalCreditsNotifier.value = 0;
  }

  /// Forces a one-time refresh from the server.
  /// NOTE: This is less necessary with the real-time listener, but can be
  /// useful to confirm a state after a specific action.
  Future<void> refresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _updateCredits(0, 0);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snap.exists) {
        final data = snap.data() ?? {};
        final main  = (data['credits']      ?? 0) as int;
        final bonus = (data['bonusCredits'] ?? 0) as int;
        _updateCredits(main, bonus);
      }
    } catch (e) {
      debugPrint("Error refreshing credits manually: $e");
    }
  }
}