// lib/server/credits.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Central, singleton-style service that keeps the **current user’s**
/// credit balance in memory for UI display purposes and provides a real-time
/// stream of the total credit value.
///
/// This manager now handles a "loading" state by using a nullable integer.
/// When the app starts or the user changes, the value will be `null` until
/// the first data snapshot is received from Firestore.
class CreditsManager {
  // --- Private constructor for singleton pattern ---
  CreditsManager._();
  static final CreditsManager instance = CreditsManager._();

  // --- Public Notifier for the UI to listen to ---
  /// A Notifier that broadcasts the user's *total* credits.
  /// It is nullable (`int?`) to represent the loading state (`null`).
  /// Widgets can listen to this to get real-time updates.
  final ValueNotifier<int?> totalCreditsNotifier = ValueNotifier<int?>(null);
  final ValueNotifier<int?> preditsNotifier = ValueNotifier<int?>(null);
  final ValueNotifier<int?> dreditsNotifier = ValueNotifier<int?>(null);

  // --- Internal State ---
  StreamSubscription? _creditsSubscription;
  String? _activeUid;
  int _listenerGeneration = 0;

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _isStaleListener(int generation, String uid) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return generation != _listenerGeneration ||
        _activeUid != uid ||
        currentUid != uid;
  }

  /// Initializes the credit listener.
  /// Call this once when the user logs in.
  void listenToCredits() {
    // Cancel any existing listener before starting a new one.
    _listenerGeneration++;
    _creditsSubscription?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    _activeUid = user?.uid;
    if (user == null) {
      totalCreditsNotifier.value = 0; // User logged out, set to 0
      preditsNotifier.value = 0;
      dreditsNotifier.value = 0;
      return;
    }

    final uid = user.uid;
    final generation = _listenerGeneration;

    // Set to null to indicate that we are now fetching data for a new user.
    totalCreditsNotifier.value = null;
    preditsNotifier.value = null;
    dreditsNotifier.value = null;

    // Listen to the user's document for real-time changes.
    _creditsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (_isStaleListener(generation, uid)) {
        debugPrint("CreditsManager: Ignored stale credit snapshot for $uid.");
        return;
      }

      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        final main = _readInt(data['credits'], 0);
        final bonus = _readInt(data['bonusCredits'], 0);
        final predits = _readInt(data['predits'], 100);
        final dredits = _readInt(data['dredits'], 100);

        // Notify listeners with the new total.
        totalCreditsNotifier.value = main + bonus;
        preditsNotifier.value = predits;
        dreditsNotifier.value = dredits;

        debugPrint(
            "Balances updated: Credits=${totalCreditsNotifier.value}, Predits=${preditsNotifier.value}, Dredits=${dreditsNotifier.value}");
      } else {
        // User document doesn't exist yet, so they have 0 credits.
        debugPrint("CreditsManager: User document does not exist for $uid.");
        totalCreditsNotifier.value = 0;
        preditsNotifier.value = 0;
        dreditsNotifier.value = 0;
      }
    }, onError: (error) {
      if (_isStaleListener(generation, uid)) {
        debugPrint("CreditsManager: Ignored stale credit error for $uid.");
        return;
      }

      debugPrint("Error listening to credits: $error");
      // On error, we might want to set to a known state, like 0.
      totalCreditsNotifier.value = 0;
      preditsNotifier.value = 0;
      dreditsNotifier.value = 0;
    });
  }

  /// Call this when the user logs out to clean up resources.
  void dispose() {
    _listenerGeneration++;
    _creditsSubscription?.cancel();
    _creditsSubscription = null;
    _activeUid = null;
    totalCreditsNotifier.value = null; // Reset to null on dispose
    preditsNotifier.value = null;
    dreditsNotifier.value = null;
  }
}
