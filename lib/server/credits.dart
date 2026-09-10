// lib/server/credits.dart

import 'package:cortex/l10n/app_localizations.dart';
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

/// How long a dismissed credit briefing stays hidden before the same kind
/// may appear again through the normal trigger flow (input focus, rebuild,
/// chat switch, credit change…). Owned by [CreditsManager] — the
/// app-session singleton — and re-derived from the recorded timestamp on
/// every ordinary evaluation: no timer waits out this window, so a
/// briefing never pops back open on its own once the window passes.
const Duration creditBriefingDismissalCooldown = Duration(hours: 2);

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

  /// Published default credit charge for a generation operation lane
  /// ('image' | 'video' | 'music' | 'speech'), from the `operationCosts`
  /// map Fulcrum publishes inside `creditLimits` (its DEFAULT_CREDIT_CHARGES
  /// — image 100, video 1000, music 500, speech 100). The client's audio
  /// generation maps to the server's 'speech' lane (gateway.js routes
  /// audio_generation → speech). Null when the lane is unknown or the
  /// user document predates the publication; the server remains the
  /// enforcement point either way.
  int? defaultCostFor(String operation) =>
      _creditLimits.operationCosts[operation];

  /// Whether an [operation] lane can plausibly afford its default charge
  /// right now. Mirrors the server's charging model: the request must keep
  /// the balance at or above the debt floor after the lane's published
  /// default cost. Fail-open by design — without a live balance snapshot or
  /// a published cost for the lane the answer is yes and the server stays
  /// the final gate; a blocked band still means no.
  bool canGenerate(String operation) {
    if (accessNotifier.value == CreditAccess.blocked) return false;
    final spendable = spendableNotifier.value;
    if (spendable == null) return true;
    final cost = defaultCostFor(operation);
    if (cost == null) return true;
    return spendable - cost >= _creditLimits.debtFloor;
  }

  /// Test seam: injects a limits snapshot without going through
  /// UserProvider/Firebase. Production code must rely on the user-data
  /// snapshot only — this is never called by app code.
  @visibleForTesting
  void debugSetCreditLimits(CreditLimits limits) {
    _creditLimits = limits;
  }

  /// The effective subscription tier resolved from the last user-data
  /// snapshot ('free', 'plus', 'pro', 'ultra'). Presentation-only: it feeds
  /// tier-specific copy (credit briefings, send-failure recovery), never
  /// credit state — the server stays the single source of truth for that.
  String get subscriptionTier => _subscriptionTier;

  // --- Credit briefing dismissal (app-session-wide) ---

  /// App-session-wide record of dismissed credit briefings, keyed by the
  /// briefing's logical kind name (the `_BriefingKind` enum name in the
  /// briefing overlay). The engine owns this map — not any widget — so no
  /// overlay lifecycle (State recreation on chat switches, rebuilds,
  /// remounts, new-chat flows) can create, reset or outlive a cooldown.
  /// Kept in memory only, never persisted.
  ///
  /// Records die in exactly three ways: their
  /// [creditBriefingDismissalCooldown] window elapses (re-checked on every
  /// ordinary evaluation), the credit state *genuinely recovers* (a known
  /// balance outside every warning band, via [observeCreditBriefingState]),
  /// or the user session itself ends (`listenToCredits` for a new session,
  /// [dispose]). A transient unknown balance, a loading gap or a chat that
  /// resolves no briefing never clears anything — that is what wiped
  /// dismissals mid-session before this map moved into the engine.
  final Map<String, DateTime> _dismissedCreditBriefings = {};

  /// Records that the user just dismissed the credit briefing [kind] (tap
  /// or downward swipe), starting its cooldown window right now.
  void dismissCreditBriefing(String kind) {
    _dismissedCreditBriefings[kind] = DateTime.now();
  }

  /// Whether the dismissed credit briefing [kind] is still inside its
  /// cooldown window. Pure lookup: eligibility is re-derived from the
  /// recorded timestamp, so every ordinary evaluation (rebuild, input
  /// focus, chat switch, countdown tick) respects the window without
  /// owning a timer for it.
  bool isCreditBriefingSuppressed(String kind) {
    final dismissed = _dismissedCreditBriefings[kind];
    return dismissed != null &&
        DateTime.now().difference(dismissed) < creditBriefingDismissalCooldown;
  }

  /// Reports the balance a surface currently observes, so the engine — the
  /// owner of the cooldowns — can decide whether the credit state has
  /// genuinely recovered. Only a *known healthy* balance — at least one
  /// credit and above the debt floor, the exact complement of the credit
  /// warning bands — clears the records, so a later dip into a band is a
  /// fresh state transition. An unknown (`null`) balance or any
  /// warning-band balance keeps them: transient snapshot gaps, loading
  /// states and chat switches must never resurrect a dismissed briefing.
  void observeCreditBriefingState({
    required int? credits,
    required int debtFloor,
  }) {
    if (credits != null && credits >= 1 && credits > debtFloor) {
      _dismissedCreditBriefings.clear();
    }
  }

  /// Test-only: clears every dismissal record, so each test starts with an
  /// empty cooldown.
  @visibleForTesting
  void debugResetCreditBriefingDismissals() {
    _dismissedCreditBriefings.clear();
  }

  /// Test-only: shifts every recorded dismissal [by] into the past, as if
  /// the user had dismissed those briefings that much earlier. The
  /// cooldown has no clock of its own, so this is the only way to cross
  /// the window.
  @visibleForTesting
  void debugAgeCreditBriefingDismissals(Duration by) {
    _dismissedCreditBriefings
        .updateAll((kind, dismissed) => dismissed.subtract(by));
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

    // A listen cycle is the start of a user session (app start, sign-in,
    // sign-out): dismissal records from any earlier session never carry
    // over.
    _dismissedCreditBriefings.clear();

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

    // The engine observes its own snapshots too: a genuinely recovered
    // balance clears every briefing dismissal even if no overlay
    // evaluation happens at this instant.
    observeCreditBriefingState(credits: credits, debtFloor: debtFloor);

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
    _dismissedCreditBriefings.clear();
  }
}

/// "23h 14m" / "5h 42m" / "47m" — never negative: if the renewal instant has
/// already passed but the refreshed snapshot has not landed yet, the countdown
/// holds at one minute instead of counting below zero.
///
/// Not user-facing: this compact form feeds only the structured facts
/// payload the send-failure recovery model receives
/// (`time_until_daily_renewal` in api.dart); every surface a human reads
/// uses [formatRenewalRemainingLocalized] instead.
String formatRenewalRemaining(Duration remaining) {
  if (remaining < const Duration(minutes: 1)) return '1m';
  final hours = remaining.inHours;
  final minutes = remaining.inMinutes % 60;
  if (hours == 0) return '${minutes}m';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}m';
}

/// "23 hours 14 minutes" / "5 hours" / "47 minutes" — fully localized words,
/// never "4m"-style abbreviations. Never negative either: if the renewal
/// instant has already passed but the refreshed snapshot has not landed yet,
/// the countdown holds at one minute instead of counting below zero.
///
/// Shared by every user-facing surface that shows the time until the daily
/// credit renewal (briefing overlay, send-failure recovery) so the wording
/// stays identical. The hour/minute words come from the locale's
/// `creditRenewalDurationHour` / `creditRenewalDurationMinute` plural
/// messages — grammatically correct in every language — and a mixed
/// remainder is joined with a single space in every locale ("2 hours 14
/// minutes").
String formatRenewalRemainingLocalized(
    Duration remaining, AppLocalizations localizations) {
  if (remaining < const Duration(minutes: 1)) {
    return localizations.creditRenewalDurationMinute(1);
  }
  final hours = remaining.inHours;
  final minutes = remaining.inMinutes % 60;
  if (hours == 0) return localizations.creditRenewalDurationMinute(minutes);
  if (minutes == 0) return localizations.creditRenewalDurationHour(hours);
  return '${localizations.creditRenewalDurationHour(hours)} '
      '${localizations.creditRenewalDurationMinute(minutes)}';
}

