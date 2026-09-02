// lib/server/credits.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// The access bands of the daily credit engine, mirroring `ACCESS` in
/// functions/src/credits.js. The strings are the server's, not ours, so a
/// mismatch is a compile-time typo rather than a silent wrong gate.
abstract final class CreditAccess {
  static const String full = 'full';
  static const String lowOnly = 'low_only';
  static const String blocked = 'blocked';
}

/// Daily allowance per tier, mirroring `DAILY_GRANTS` in
/// functions/src/credits.js. Needed here only to locate the debt floor, which
/// is one grant below zero.
const Map<String, int> _dailyGrants = {
  'free': 100,
  'plus': 500,
  'pro': 1000,
  'ultra': 10000,
};

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

  /// Whether this account has been migrated to the single-credit billing
  /// engine. Migration is lazy and per-user, so both systems are live at once
  /// and every gate has to ask which one it is looking at.
  final ValueNotifier<bool> billingV2Notifier = ValueNotifier<bool>(false);

  /// Whether the daily credit engine is the one billing this account. Set by
  /// the server the first time it renews the allowance, so it turns on for a
  /// user at the same moment the gateway starts charging them that way.
  final ValueNotifier<bool> creditsV3Notifier = ValueNotifier<bool>(false);

  /// What the balance permits, mirroring `accessFor` in
  /// functions/src/credits.js:
  ///
  ///   full      everything the tier allows
  ///   low_only  Dynamic Chat, cheapest mode, no model choice
  ///   blocked   nothing until the allowance renews
  ///
  /// The server decides this again on every request; the client tracks it only
  /// so the UI can stop offering what would be refused.
  final ValueNotifier<String> accessNotifier =
      ValueNotifier<String>(CreditAccess.full);

  /// What the user can actually spend: the allowance bucket plus owned
  /// credits. This is the number the server gates on, so the client gates on
  /// the same one instead of guessing from a display total.
  final ValueNotifier<int?> spendableNotifier = ValueNotifier<int?>(null);

  /// Mirrors MIN_TEXT_BALANCE in functions/src/billing.js. Below this the
  /// server refuses to start a text request, so offering it would just produce
  /// a failure the user cannot act on.
  static const int minTextBalance = 50;

  /// Whether the user may pick a specific model, as opposed to being answered
  /// by Dynamic Chat.
  ///
  /// Two separate things close this door and the server treats them the same
  /// way: model choice is a paid feature, and it is also the first thing to go
  /// when a paid balance runs out. Deliberately *not* OR'd with the
  /// subscription flag — a subscriber in the debt band has lost the privilege
  /// just as a free user never had it, and offering a picker whose choice the
  /// gateway would silently override is worse than not offering one.
  ///
  /// Outside the daily engine this stays true and the old premium filters keep
  /// deciding what the picker shows.
  bool get canChooseModel {
    if (!creditsV3Notifier.value) return true;
    return accessNotifier.value == CreditAccess.full && _tierIsPaid;
  }

  /// Whether anything at all can be sent. Only the floor closes this.
  bool get canSendAnything {
    if (!creditsV3Notifier.value) return true;
    return accessNotifier.value != CreditAccess.blocked;
  }

  bool _tierIsPaid = false;

  /// Under billing v2 there is no premium lane — every model bills its real
  /// cost, so anything the user can afford is allowed and this is the only
  /// question worth asking. Before migration it falls back to the predit
  /// balance the old engine maintained.
  bool get canUsePremiumModel {
    if (creditsV3Notifier.value) return canChooseModel;
    if (billingV2Notifier.value) {
      return (spendableNotifier.value ?? 0) >= minTextBalance;
    }
    return (preditsNotifier.value ?? 0) > 0;
  }

  /// Dynamic Chat had its own currency (dredits) under the old engine. v2
  /// retires it: a dynamic turn is billed like any other text turn. The daily
  /// engine goes further — Dynamic Chat is what the user is *left* with in the
  /// debt band, so it stays open until the floor.
  bool get canSendDynamicChat {
    if (creditsV3Notifier.value) return canSendAnything;
    if (billingV2Notifier.value) {
      return (spendableNotifier.value ?? 0) >= minTextBalance;
    }
    return (dreditsNotifier.value ?? 0) >= 1;
  }

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

  /// Allowance balances are fractional on the server (credits accrue by the
  /// millisecond), so they arrive as doubles and have to be floored rather
  /// than parsed as ints.
  int _readFloor(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.floor();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed == null ? fallback : parsed.floor();
    }
    return fallback;
  }

  /// Mirrors `resolveTier` in functions/src/credits.js. Levels 4-6 are lifetime
  /// grants and carry no expiry; 1-3 lapse back to free.
  String _resolveTier(Map<String, dynamic> data) {
    final level = _readInt(data['hasCortexSubscription'], 0);
    if (level == 0) return 'free';

    final lifetime = level >= 4 && level <= 6;
    if (!lifetime) {
      final raw = data['subscriptionExpiresAt'];
      final expiry = raw is Timestamp ? raw.toDate() : null;
      if (expiry == null || !expiry.isAfter(DateTime.now())) return 'free';
    }

    switch (level) {
      case 1:
      case 4:
        return 'plus';
      case 2:
      case 5:
        return 'pro';
      case 3:
      case 6:
        return 'ultra';
      default:
        return 'free';
    }
  }

  /// Mirrors `accessFor` in functions/src/credits.js. The floor is measured on
  /// the allowance alone, so a purchased wallet widens the top band without
  /// letting the user go further into debt.
  String _accessFor(int allowance, int purchased, int grant) {
    final spendable = allowance + (purchased < 0 ? 0 : purchased);
    if (spendable > 0) return CreditAccess.full;
    if (allowance > -grant) return CreditAccess.lowOnly;
    return CreditAccess.blocked;
  }

  /// Puts the engine flags back to a neutral state.
  ///
  /// Neutral means *open*, not blocked: the server is the real gate, and
  /// failing closed here would lock a user out of their own app over a
  /// transient Firestore error.
  void _resetEngineFlags() {
    billingV2Notifier.value = false;
    creditsV3Notifier.value = false;
    accessNotifier.value = CreditAccess.full;
    _tierIsPaid = false;
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
      spendableNotifier.value = 0;
      _resetEngineFlags();
      return;
    }

    final uid = user.uid;
    final generation = _listenerGeneration;

    // Set to null to indicate that we are now fetching data for a new user.
    totalCreditsNotifier.value = null;
    preditsNotifier.value = null;
    dreditsNotifier.value = null;
    spendableNotifier.value = null;

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
        final billingV2 = data['billingV2'] == true;
        final creditsV3 = data['creditsV3'] == true;
        final main = _readInt(data['credits'], 0);
        billingV2Notifier.value = billingV2;
        creditsV3Notifier.value = creditsV3;

        if (creditsV3) {
          // One balance: the daily allowance plus whatever was purchased.
          // `credits` is the wallet and never renews, which is why the two are
          // kept apart on the server and only added up for display here.
          final allowance = _readFloor(data['dailyCredits'], 0);
          final spendable = allowance + main;
          final tier = _resolveTier(data);
          final grant = _dailyGrants[tier] ?? _dailyGrants['free']!;

          _tierIsPaid = tier != 'free';
          accessNotifier.value = _accessFor(allowance, main, grant);

          totalCreditsNotifier.value = spendable;
          spendableNotifier.value = spendable;
          // The legacy notifiers still drive a few overlays. Feeding them the
          // one balance keeps those readouts honest rather than showing a
          // currency that no longer moves.
          preditsNotifier.value = spendable;
          dreditsNotifier.value = spendable;

          debugPrint(
              "Balances updated (v3): Spendable=$spendable (allowance=$allowance, owned=$main), tier=$tier, access=${accessNotifier.value}");
        } else if (billingV2) {
          // One currency. Spendable is the allowance bucket plus owned
          // credits — exactly what authorizeRequest checks server-side.
          // predits/dredits still arrive as legacy mirrors for older clients;
          // they are ignored here in favour of the fields they mirror.
          final allowance = _readFloor(data['allowBalance'], 0);
          final spendable = allowance + main;

          totalCreditsNotifier.value = spendable;
          spendableNotifier.value = spendable;
          preditsNotifier.value = spendable;
          dreditsNotifier.value = spendable;

          debugPrint(
              "Balances updated (v2): Spendable=$spendable (allowance=$allowance, owned=$main)");
        } else {
          final bonus = _readInt(data['bonusCredits'], 0);
          final predits = _readInt(data['predits'], 100);
          final dredits = _readInt(data['dredits'], 100);

          totalCreditsNotifier.value = main + bonus;
          spendableNotifier.value = main + bonus;
          preditsNotifier.value = predits;
          dreditsNotifier.value = dredits;

          debugPrint(
              "Balances updated: Credits=${totalCreditsNotifier.value}, Predits=${preditsNotifier.value}, Dredits=${dreditsNotifier.value}");
        }
      } else {
        // User document doesn't exist yet, so they have 0 credits.
        debugPrint("CreditsManager: User document does not exist for $uid.");
        totalCreditsNotifier.value = 0;
        preditsNotifier.value = 0;
        dreditsNotifier.value = 0;
        spendableNotifier.value = 0;
        _resetEngineFlags();
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
      spendableNotifier.value = 0;
      _resetEngineFlags();
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
    spendableNotifier.value = null;
    _resetEngineFlags();
  }
}
