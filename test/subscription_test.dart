// test/subscription_test.dart
//
// Unit tests for the nested `users/{uid}.subscription` entitlement model.
// Covers the "missing = not applicable" rule, terminal states, anonymous
// accounts, the cache-tolerant date parsing, and the server-published
// `creditLimits` map (CreditLimits).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/server/subscription.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionEntitlement.fromUserData', () {
    test('missing map resolves to free', () {
      final entitlement = SubscriptionEntitlement.fromUserData(null);
      expect(entitlement.tier, SubscriptionTier.free);
      expect(entitlement.isActive, false);
      expect(entitlement.isPaid, false);
      expect(entitlement.effectiveTier, SubscriptionTier.free);
      expect(entitlement.chatCharacterLimit, 100000);
    });

    test('explicit free map resolves to free', () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        const {'subscription': {'tier': 'free'}},
      );
      expect(entitlement.isActive, false);
      expect(entitlement, SubscriptionEntitlement.none);
    });

    test('anonymous account is always free', () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        {
          'subscription': {
            'tier': 'ultra',
            'mode': 'lifetime',
            'status': 'active',
          }
        },
        isAnonymous: true,
      );
      expect(entitlement.isActive, false);
      expect(entitlement.effectiveTier, SubscriptionTier.free);
    });

    test('unknown tier string resolves to free', () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        const {
          'subscription': {
            'tier': 'gigachad',
            'mode': 'lifetime',
            'status': 'active',
          }
        },
      );
      expect(entitlement.isActive, false);
    });

    test('lifetime without expiresAt is active', () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        const {
          'subscription': {
            'tier': 'pro',
            'mode': 'lifetime',
            'status': 'active',
            'source': 'admin',
          }
        },
      );
      expect(entitlement.isActive, true);
      expect(entitlement.effectiveTier, SubscriptionTier.pro);
      // Store-only fields are absent for admin grants.
      expect(entitlement.productId, isNull);
      expect(entitlement.billingPeriod, isNull);
      expect(entitlement.source, SubscriptionSource.admin);
    });

    test('renewable with future expiresAt is active', () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        {
          'subscription': {
            'tier': 'ultra',
            'mode': 'renewable',
            'status': 'active',
            'expiresAt':
                Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
            'productId': 'cortex_ultra_annual',
            'billingPeriod': 'annual',
            'source': 'app_store',
          }
        },
      );
      expect(entitlement.isActive, true);
      expect(entitlement.effectiveTier, SubscriptionTier.ultra);
      expect(entitlement.productId, 'cortex_ultra_annual');
      expect(entitlement.billingPeriod, SubscriptionBillingPeriod.annual);
    });

    test('expired renewable resolves to free but keeps nominal tier', () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        {
          'subscription': {
            'tier': 'plus',
            'mode': 'renewable',
            'status': 'active',
            'expiresAt': Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 1))),
          }
        },
      );
      expect(entitlement.isActive, false);
      expect(entitlement.effectiveTier, SubscriptionTier.free);
      expect(entitlement.tier, SubscriptionTier.plus);
    });

    test('terminal statuses resolve to free but keep nominal tier', () {
      for (final status in ['expired', 'revoked']) {
        final entitlement = SubscriptionEntitlement.fromUserData(
          {
            'subscription': {
              'tier': 'pro',
              'mode': 'renewable',
              'status': status,
            }
          },
        );
        expect(entitlement.isActive, false, reason: 'status: $status');
        expect(entitlement.effectiveTier, SubscriptionTier.free,
            reason: 'status: $status');
        expect(entitlement.tier, SubscriptionTier.pro,
            reason: 'status: $status');
      }
    });

    test('ISO string expiry (SharedPreferences cache) is tolerated', () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        {
          'subscription': {
            'tier': 'plus',
            'mode': 'promotional',
            'status': 'active',
            'expiresAt':
                DateTime.now().add(const Duration(days: 1)).toIso8601String(),
            'source': 'referral',
          }
        },
      );
      expect(entitlement.isActive, true);
      expect(entitlement.mode, SubscriptionMode.promotional);
      expect(entitlement.source, SubscriptionSource.referral);
      // Promotional grants carry no store fields.
      expect(entitlement.productId, isNull);
      expect(entitlement.billingPeriod, isNull);
    });

    test('internal_test grant parses source and testGrant marker', () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        {
          'subscription': {
            'tier': 'pro',
            'mode': 'promotional',
            'status': 'active',
            'expiresAt':
                Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 60))),
            'source': 'internal_test',
            'testGrant': true,
          }
        },
      );
      expect(entitlement.isActive, true);
      expect(entitlement.effectiveTier, SubscriptionTier.pro);
      expect(entitlement.source, SubscriptionSource.internalTest);
      expect(entitlement.testGrant, true);
      expect(entitlement.isTestEntitlement, true);
      // Test grants never carry store-only fields.
      expect(entitlement.productId, isNull);
      expect(entitlement.billingPeriod, isNull);
    });

    test('testGrant flag defaults to false for non-test sources', () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        {
          'subscription': {
            'tier': 'pro',
            'mode': 'renewable',
            'status': 'active',
            'expiresAt':
                Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
            'productId': 'cortex_pro_monthly',
            'billingPeriod': 'monthly',
            'source': 'play_store',
          }
        },
      );
      expect(entitlement.testGrant, false);
      expect(entitlement.isTestEntitlement, false);
      expect(entitlement.source, SubscriptionSource.playStore);
    });

    test('lapsed internal_test grant resolves to free but keeps the marker',
        () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        {
          'subscription': {
            'tier': 'ultra',
            'mode': 'promotional',
            'status': 'active',
            'expiresAt': Timestamp.fromDate(
                DateTime.now().subtract(const Duration(minutes: 5))),
            'source': 'internal_test',
            'testGrant': true,
          }
        },
      );
      expect(entitlement.isActive, false);
      expect(entitlement.effectiveTier, SubscriptionTier.free);
      // Nominal data is kept for history, including the test marker.
      expect(entitlement.tier, SubscriptionTier.ultra);
      expect(entitlement.isTestEntitlement, true);
    });

    test('SubscriptionSource.internalTest round-trips', () {
      expect(SubscriptionSource.internalTest.value, 'internal_test');
      expect(
        SubscriptionSource.fromValue('internal_test'),
        SubscriptionSource.internalTest,
      );
      expect(SubscriptionSource.fromValue('unknown_source'), isNull);
    });

    test('equality distinguishes test grants from identical real grants', () {
      final expiresAt = DateTime.now().add(const Duration(minutes: 60));
      final real = SubscriptionEntitlement(
        tier: SubscriptionTier.pro,
        mode: SubscriptionMode.promotional,
        status: SubscriptionStatus.active,
        expiresAt: expiresAt,
        source: SubscriptionSource.referral,
      );
      final test = SubscriptionEntitlement(
        tier: SubscriptionTier.pro,
        mode: SubscriptionMode.promotional,
        status: SubscriptionStatus.active,
        expiresAt: expiresAt,
        source: SubscriptionSource.internalTest,
        testGrant: true,
      );
      final sameTest = SubscriptionEntitlement(
        tier: SubscriptionTier.pro,
        mode: SubscriptionMode.promotional,
        status: SubscriptionStatus.active,
        expiresAt: expiresAt,
        source: SubscriptionSource.internalTest,
        testGrant: true,
      );

      expect(real == test, false);
      expect(real.hashCode == test.hashCode, false);
      expect(test, sameTest);
      expect(test.hashCode, sameTest.hashCode);
    });

    test('renewable without expiresAt is not active (defensive)', () {
      final entitlement = SubscriptionEntitlement.fromUserData(
        const {
          'subscription': {
            'tier': 'plus',
            'mode': 'renewable',
            'status': 'active',
          }
        },
      );
      expect(entitlement.isActive, false);
    });

    test('capabilities follow the effective tier', () {
      final active = SubscriptionEntitlement.fromUserData(
        {
          'subscription': {
            'tier': 'ultra',
            'mode': 'renewable',
            'status': 'active',
            'expiresAt':
                Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
          }
        },
      );
      expect(active.chatCharacterLimit, 1000000);

      final lapsed = SubscriptionEntitlement.fromUserData(
        {
          'subscription': {
            'tier': 'ultra',
            'mode': 'renewable',
            'status': 'active',
            'expiresAt': Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 7))),
          }
        },
      );
      expect(lapsed.chatCharacterLimit, 100000);
    });

    test('equality covers all entitlement fields', () {
      const a = SubscriptionEntitlement(
        tier: SubscriptionTier.plus,
        mode: SubscriptionMode.renewable,
        status: SubscriptionStatus.active,
      );
      const b = SubscriptionEntitlement(
        tier: SubscriptionTier.plus,
        mode: SubscriptionMode.renewable,
        status: SubscriptionStatus.active,
      );
      const c = SubscriptionEntitlement(
        tier: SubscriptionTier.pro,
        mode: SubscriptionMode.renewable,
        status: SubscriptionStatus.active,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, false);
    });

    test('tier planIndex ordering', () {
      expect(SubscriptionTier.free.planIndex, 0);
      expect(SubscriptionTier.plus.planIndex, 1);
      expect(SubscriptionTier.pro.planIndex, 2);
      expect(SubscriptionTier.ultra.planIndex, 3);
      expect(
        SubscriptionTier.pro.planIndex > SubscriptionTier.plus.planIndex,
        true,
      );
    });
  });

  group('CreditLimits.fromData', () {
    test('absent map resolves to the free fallback', () {
      final limits = CreditLimits.fromData(null);
      expect(limits, CreditLimits.fallback);
      expect(limits.dailyGrant, 50);
      expect(limits.debtFloor, -50);
    });

    test('non-map values resolve to the free fallback', () {
      expect(CreditLimits.fromData('free'), CreditLimits.fallback);
      expect(CreditLimits.fromData(42), CreditLimits.fallback);
    });

    test('parses the server-published values', () {
      final limits = CreditLimits.fromData(const {
        'dailyGrant': 1250,
        'debtFloor': -1250,
      });
      expect(limits.dailyGrant, 1250);
      expect(limits.debtFloor, -1250);
    });

    test('num values are coerced to int', () {
      final limits = CreditLimits.fromData(const {
        'dailyGrant': 125.0,
        'debtFloor': -125.0,
      });
      expect(limits.dailyGrant, 125);
      expect(limits.debtFloor, -125);
    });

    test('partial maps resolve to the free fallback', () {
      expect(
        CreditLimits.fromData(const {'dailyGrant': 1250}),
        CreditLimits.fallback,
      );
      expect(
        CreditLimits.fromData(const {'debtFloor': -125}),
        CreditLimits.fallback,
      );
    });

    test('equality covers both fields', () {
      const a = CreditLimits(dailyGrant: 125, debtFloor: -125);
      const b = CreditLimits(dailyGrant: 125, debtFloor: -125);
      const c = CreditLimits(dailyGrant: 1250, debtFloor: -1250);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, false);
    });
  });
}
