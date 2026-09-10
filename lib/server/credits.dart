// lib/server/credits.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

import 'subscription.dart';
import 'user.dart';

/// The access bands of the unified credit engine, mirroring `evaluateCreditPolicy`
/// in `functions/src/subscription.js`. The strings are the server's, not ours,
/// so a mismatch is a compile-time typo rather than a silent wrong gate.
abstract final class CreditAccess {
  static const String full = 'full';
  static const String lowOnly = 'low_only';
  static const String blocked = 'blocked';
}

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

  String _subscriptionTier = 'free';

  /// Server-published credit limits for the user's effective tier, cached
  /// from the user-data snapshot (see `CreditLimits`). Never hardcoded — the
  /// client mirrors whatever the server last published.
  CreditLimits _creditLimits = CreditLimits.fallback;

  /// What the balance permits, mirroring `evaluateCreditPolicy` in
  /// `functions/src/subscription.js`:
  ///
  ///   full      everything the tier allows
  ///   low_only  Dynamic Chat, cheapest mode, no model choice
  ///   blocked   nothing until the allowance renews
  ///
  /// The server decides this again on every request; the client tracks it only
  /// so the UI can stop offering what would be refused.
  final ValueNotifier<String> accessNotifier =
      ValueNotifier<String>(CreditAccess.full);

  /// What the user can actually spend. The server gates on the unified
  /// `credits` field, so the client gates on the same one.
  final ValueNotifier<int?> spendableNotifier = ValueNotifier<int?>(null);

  /// Whether the user may pick a specific model, as opposed to being answered
  /// by Dynamic Chat. Mirrors `manualModelSelectionAllowed` in the server's
  /// `evaluateCreditPolicy`: true only in the `full` band (credits >= 0);
  /// negative credits force Dynamic Chat and disable manual selection.
  bool get modelSelectionAllowed => accessNotifier.value == CreditAccess.full;

  /// Whether the user is allowed to spend credits on features that cost
  /// credits. Only the debt floor closes this.
  bool get canSendAnything => accessNotifier.value != CreditAccess.blocked;

  /// Whether the user is allowed to choose a model for dynamic chat.
  ///
  /// Returns `true` when the access band is `full`.
  bool get canChooseModel => modelSelectionAllowed;

  /// Daily credit grant for the user's effective tier, cached from the
  /// server-published `creditLimits` map on the user document.
  int get dailyGrant => _creditLimits.dailyGrant;

  /// Debt floor for the user's effective tier, cached from the
  /// server-published `creditLimits` map. At or below this balance nothing is
  /// sendable until the allowance renews.
  int get debtFloor => _creditLimits.debtFloor;

  /// The instant of the next daily credit renewal.
  ///
  /// Mirrors the server's `awardDailyBonusCredits` cron (`"0 0 * * *"` in
  /// `Europe/Istanbul`, functions/src/scheduled.js): the daily allowance
  /// lands at midnight Istanbul time. Presentation-only — the server stays
  /// the single source of truth for renewal; the client never derives credit
  /// state from this. Istanbul has kept a fixed UTC+3 offset since 2016, so
  /// the plain-UTC fallback remains exact even if the tz database is not
  /// loaded yet.
  DateTime nextDailyRenewal() {
    try {
      final istanbul = tz.getLocation('Europe/Istanbul');
      final now = tz.TZDateTime.now(istanbul);
      return tz.TZDateTime(istanbul, now.year, now.month, now.day)
          .add(const Duration(days: 1));
    } catch (_) {
      final now = DateTime.now().toUtc();
      var next = DateTime.utc(now.year, now.month, now.day, 21);
      if (!now.isBefore(next)) {
        next = next.add(const Duration(days: 1));
      }
      return next.toLocal();
    }
  }

  /// Whether the user can send a text request right now.
  ///
  /// Dynamic Chat stays open below zero but closes at the debt floor
  /// (`-dailyGrant`), mirroring `evaluateCreditPolicy`'s State B/C split.
  bool get canSendText {
    final spendable = spendableNotifier.value ?? 0;
    return spendable > _creditLimits.debtFloor;
  }

  // --- Internal State ---
  UserProvider? _userProvider;
  String? _activeUid;
  int _listenerGeneration = 0;

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  /// Resolves the effective tier from the nested `subscription` map.
  /// Terminal statuses (expired/revoked) and lapsed renewables resolve to
  /// 'free'; lifetime entitlements have no expiry and stay active.
  String _resolveTier(Map<String, dynamic> data) {
    return SubscriptionEntitlement.fromUserData(
      data,
      isAnonymous: data['accountType'] == 'anonymous',
    ).effectiveTier.value;
  }

  /// Mirrors `evaluateCreditPolicy` in `functions/src/subscription.js`:
  ///
  ///   - `blocked`  at or below the debt floor (`-dailyGrant`),
  ///   - `low_only`  negative but above the floor (Dynamic Chat only),
  ///   - `full`      non-negative balance.
  String _accessFor(int credits, int debtFloor) {
    if (credits <= debtFloor) return CreditAccess.blocked;
    if (credits < 0) return CreditAccess.lowOnly;
    return CreditAccess.full;
  }

  /// Puts the engine flags back to a neutral state.
  ///
  /// Neutral means *open*, not blocked: the server is the real gate, and
  /// failing closed here would lock a user out of their own app over a
  /// transient Firestore error.
  void _resetEngineFlags() {
    accessNotifier.value = CreditAccess.full;
  }

  bool _isStaleListener(int generation, String uid) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return generation != _listenerGeneration ||
        _activeUid != uid ||
        currentUid != uid;
  }

  /// Initializes the credit engine.
  /// Call this once when the user logs in.
  void listenToCredits(UserProvider userProvider) {
    // Cancel any existing listener before starting a new one.
    _listenerGeneration++;
    _userProvider?.removeListener(_onUserDataChanged);
    _userProvider = userProvider;

    final user = FirebaseAuth.instance.currentUser;
    _activeUid = user?.uid;
    if (user == null) {
      totalCreditsNotifier.value = 0; // User logged out, set to 0
      spendableNotifier.value = 0;
      _resetEngineFlags();
      return;
    }

    // Set to null to indicate that we are now fetching data for a new user.
    totalCreditsNotifier.value = null;
    spendableNotifier.value = null;

    userProvider.addListener(_onUserDataChanged);
    _onUserDataChanged();
  }

  /// Reacts to UserProvider updates (live snapshots, cache loads, sign-out).
  ///
  /// Only UserProvider holds the `users/{uid}` snapshot; this manager
  /// consumes the same document data through its change notifications.
  void _onUserDataChanged() {
    final uid = _activeUid;
    if (uid == null || _isStaleListener(_listenerGeneration, uid)) {
      debugPrint("CreditsManager: Ignored stale user data update.");
      return;
    }

    final data = _userProvider?.userData;
    if (data == null) {
      debugPrint("CreditsManager: No user data available for $uid yet.");
      totalCreditsNotifier.value = 0;
      spendableNotifier.value = 0;
      _resetEngineFlags();
      return;
    }

    final credits = _readInt(data['credits'], 0);
    _subscriptionTier = _resolveTier(data);

    // Server-published limits (single source of truth). The fallback only
    // applies to documents written before the server began publishing them;
    // every daily renewal re-asserts the effective tier's values.
    _creditLimits = CreditLimits.fromData(data['creditLimits']);
    final debtFloor = _creditLimits.debtFloor;

    // One unified balance. The server gates every request on this same field
    // via `evaluateCreditPolicy`, so the client bands match it exactly.
    accessNotifier.value = _accessFor(credits, debtFloor);
    totalCreditsNotifier.value = credits;
    spendableNotifier.value = credits;

    debugPrint(
        "[CreditsManager] Unified balance: credits=$credits, tier=$_subscriptionTier, debtFloor=$debtFloor, access=${accessNotifier.value}");
  }

  /// Call this when the user logs out to clean up resources.
  void dispose() {
    _listenerGeneration++;
    _userProvider?.removeListener(_onUserDataChanged);
    _userProvider = null;
    _activeUid = null;
    totalCreditsNotifier.value = null; // Reset to null on dispose
    spendableNotifier.value = null;
    _resetEngineFlags();
  }
}
