// lib/server/subscription.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Tier of a Cortex subscription entitlement.
enum SubscriptionTier {
  free('free'),
  plus('plus'),
  pro('pro'),
  ultra('ultra');

  const SubscriptionTier(this.value);

  /// The string stored in `users/{uid}.subscription.tier`.
  final String value;

  /// Parses the stored tier string; anything unknown resolves to [free].
  static SubscriptionTier fromValue(String? value) {
    return switch (value) {
      'plus' => SubscriptionTier.plus,
      'pro' => SubscriptionTier.pro,
      'ultra' => SubscriptionTier.ultra,
      _ => SubscriptionTier.free,
    };
  }

  /// Index of the tier for plan-comparison arithmetic
  /// (free < plus < pro < ultra).
  int get planIndex => switch (this) {
        SubscriptionTier.free => 0,
        SubscriptionTier.plus => 1,
        SubscriptionTier.pro => 2,
        SubscriptionTier.ultra => 3,
      };
}

/// How the entitlement was granted. `renewable` and `promotional` are
/// time-bound and carry an `expiresAt`; `lifetime` never does.
enum SubscriptionMode {
  renewable('renewable'),
  lifetime('lifetime'),
  promotional('promotional');

  const SubscriptionMode(this.value);
  final String value;

  static SubscriptionMode? fromValue(String? value) {
    return switch (value) {
      'renewable' => SubscriptionMode.renewable,
      'lifetime' => SubscriptionMode.lifetime,
      'promotional' => SubscriptionMode.promotional,
      _ => null,
    };
  }
}

/// Lifecycle of the entitlement. Only `active` grants the tier; terminal
/// states keep the nominal tier for history but resolve to free.
enum SubscriptionStatus {
  active('active'),
  gracePeriod('grace_period'),
  pastDue('past_due'),
  expired('expired'),
  revoked('revoked');

  const SubscriptionStatus(this.value);
  final String value;

  static SubscriptionStatus? fromValue(String? value) {
    return switch (value) {
      'active' => SubscriptionStatus.active,
      'grace_period' => SubscriptionStatus.gracePeriod,
      'past_due' => SubscriptionStatus.pastDue,
      'expired' => SubscriptionStatus.expired,
      'revoked' => SubscriptionStatus.revoked,
      _ => null,
    };
  }
}

/// Billing cadence of a store subscription. Absent for non-store grants.
enum SubscriptionBillingPeriod {
  monthly('monthly'),
  annual('annual');

  const SubscriptionBillingPeriod(this.value);
  final String value;

  static SubscriptionBillingPeriod? fromValue(String? value) {
    return switch (value) {
      'monthly' => SubscriptionBillingPeriod.monthly,
      'annual' => SubscriptionBillingPeriod.annual,
      _ => null,
    };
  }
}

/// Where the entitlement came from.
enum SubscriptionSource {
  appStore('app_store'),
  playStore('play_store'),
  referral('referral'),
  admin('admin'),
  internalTest('internal_test');

  const SubscriptionSource(this.value);
  final String value;

  static SubscriptionSource? fromValue(String? value) {
    return switch (value) {
      'app_store' => SubscriptionSource.appStore,
      'play_store' => SubscriptionSource.playStore,
      'referral' => SubscriptionSource.referral,
      'admin' => SubscriptionSource.admin,
      'internal_test' => SubscriptionSource.internalTest,
      _ => null,
    };
  }
}

/// The user's subscription entitlement, parsed from the nested
/// `users/{uid}.subscription` map.
///
/// Schema (written by the server; see functions/src/subscription.js):
///
///   subscription: {
///     tier:          'free' | 'plus' | 'pro' | 'ultra',
///     mode:          'renewable' | 'lifetime' | 'promotional',
///     status:        'active' | 'grace_period' | 'past_due' | 'expired' | 'revoked',
///     expiresAt:     Timestamp,             // renewable/promotional only
///     productId:     String,                // store subscriptions only
///     billingPeriod: 'monthly' | 'annual',  // store subscriptions only
///     source:        'app_store' | 'play_store' | 'referral' | 'admin' |
///                    'internal_test',
///     testGrant:     bool,                  // internal_test grants only
///     updatedAt:     Timestamp
///   }
///
/// CORE RULE — "missing = not applicable": fields that do not apply to an
/// entitlement are omitted entirely, never stored as null. A lifetime
/// entitlement has no `expiresAt`; a referral grant has no `productId`.
///
/// The parser tolerates [Timestamp]s (live Firestore), [DateTime]s and
/// ISO-8601 strings (the SharedPreferences cache serializes timestamps as
/// strings), so the same code path serves live and cached data.
class SubscriptionEntitlement {
  const SubscriptionEntitlement({
    this.tier = SubscriptionTier.free,
    this.mode,
    this.status,
    this.expiresAt,
    this.productId,
    this.billingPeriod,
    this.source,
    this.updatedAt,
    this.testGrant = false,
  });

  /// The entitlement of a free user: no map, anonymous, or tier 'free'.
  static const SubscriptionEntitlement none = SubscriptionEntitlement();

  /// The nominal tier stored in the document. Kept after expiry for history,
  /// so gate on [effectiveTier] instead.
  final SubscriptionTier tier;

  /// Null when not applicable (free state or unknown data).
  final SubscriptionMode? mode;

  /// Null when the map carries no status (free state or unknown data).
  final SubscriptionStatus? status;

  /// Only present for time-bound modes (renewable/promotional).
  final DateTime? expiresAt;

  /// Only present for store subscriptions.
  final String? productId;

  /// Only present for store subscriptions.
  final SubscriptionBillingPeriod? billingPeriod;

  /// Only present for paid grants.
  final SubscriptionSource? source;

  /// True only for simulated entitlements granted by the server's test
  /// purchase flow (source `internal_test`). Mirrors the server-side marker.
  final bool testGrant;

  /// Whether this entitlement is an active simulated test grant.
  bool get isTestEntitlement => testGrant;

  final DateTime? updatedAt;

  /// Parses the entitlement from a user document's data.
  ///
  /// [isAnonymous] forces the free entitlement — anonymous accounts can
  /// never hold a subscription, regardless of what the document says.
  static SubscriptionEntitlement fromUserData(
    Map<String, dynamic>? userData, {
    bool isAnonymous = false,
  }) {
    if (isAnonymous) return none;

    final raw = userData?['subscription'];
    if (raw is! Map) return none;

    final tier = SubscriptionTier.fromValue(_readString(raw['tier']));
    if (tier == SubscriptionTier.free) return none;

    return SubscriptionEntitlement(
      tier: tier,
      mode: SubscriptionMode.fromValue(_readString(raw['mode'])),
      status: SubscriptionStatus.fromValue(_readString(raw['status'])),
      expiresAt: _parseDate(raw['expiresAt']),
      productId: _readString(raw['productId']),
      billingPeriod:
          SubscriptionBillingPeriod.fromValue(_readString(raw['billingPeriod'])),
      source: SubscriptionSource.fromValue(_readString(raw['source'])),
      testGrant: raw['testGrant'] == true,
      updatedAt: _parseDate(raw['updatedAt']),
    );
  }

  static String? _readString(dynamic value) =>
      value is String && value.isNotEmpty ? value : null;

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Whether the entitlement currently grants its tier:
  ///   - the stored status must be `active`, and
  ///   - time-bound modes (renewable/promotional) must have a future expiry.
  ///
  /// Lifetime entitlements carry no expiry by definition.
  bool get isActive {
    if (tier == SubscriptionTier.free) return false;
    if (status != SubscriptionStatus.active) return false;
    if (mode == SubscriptionMode.lifetime) return true;
    final expiry = expiresAt;
    return expiry != null && expiry.isAfter(DateTime.now());
  }

  /// Whether the user is paying (or is otherwise granted) right now.
  bool get isPaid => isActive;

  /// The tier the user is actually entitled to: the nominal tier while
  /// active, [SubscriptionTier.free] otherwise.
  SubscriptionTier get effectiveTier =>
      isActive ? tier : SubscriptionTier.free;

  /// Maximum characters allowed in a chat context, mirroring the server.
  int get chatCharacterLimit => switch (effectiveTier) {
        SubscriptionTier.free => 100000,
        SubscriptionTier.plus => 250000,
        SubscriptionTier.pro => 500000,
        SubscriptionTier.ultra => 1000000,
      };

  /// Daily credit grant for the tier, mirroring `TIER_LIMITS` on the server.
  int get dailyGrant => switch (effectiveTier) {
        SubscriptionTier.free => 100,
        SubscriptionTier.plus => 500,
        SubscriptionTier.pro => 1000,
        SubscriptionTier.ultra => 10000,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionEntitlement &&
          other.tier == tier &&
          other.mode == mode &&
          other.status == status &&
          other.expiresAt == expiresAt &&
          other.productId == productId &&
          other.billingPeriod == billingPeriod &&
          other.source == source &&
          other.testGrant == testGrant;

  @override
  int get hashCode => Object.hash(
        tier,
        mode,
        status,
        expiresAt,
        productId,
        billingPeriod,
        source,
        testGrant,
      );

  @override
  String toString() =>
      'SubscriptionEntitlement(tier: ${tier.value}, effective: '
      '${effectiveTier.value}, mode: ${mode?.value}, status: ${status?.value}, '
      'expiresAt: $expiresAt, productId: $productId, testGrant: $testGrant)';
}
