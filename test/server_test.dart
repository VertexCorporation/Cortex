// test/server_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/server/subscription.dart';
import 'package:cortex/server/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProvider Tests', () {
    late UserProvider userProvider;

    setUp(() {
      // We pass nothing, so it defaults to "real" instances lazily.
      // But we won't touch methods that trigger them.
      userProvider = UserProvider();
    });

    test('Initial state logic (skipping isLoggedIn)', () {
      // expect(userProvider.isLoggedIn, false); // Triggers _auth, will fail without app
      expect(userProvider.isAnonymous, false);
      expect(userProvider.username, 'Guest');
      expect(userProvider.profileInitial, '?');
      expect(userProvider.subscription.isActive, false);
      expect(userProvider.subscription.effectiveTier, SubscriptionTier.free);
    });

    test('Anonymous User Logic', () {
      userProvider.userData = {
        'accountType': 'anonymous',
        'username': 'AnonUser'
      };

      // expect(userProvider.isLoggedIn, false);
      expect(userProvider.isAnonymous, true);
      expect(userProvider.username, 'AnonUser');
    });

    test('Standard User Logic', () {
      userProvider.userData = {
        'accountType': 'standard',
        'username': 'John Doe'
      };

      expect(userProvider.isAnonymous, false);
      expect(userProvider.username, 'John Doe');
      expect(userProvider.profileInitial, 'J');
    });

    test('isVertex defaults to false and toggles with the document flag', () {
      userProvider.userData = {
        'accountType': 'standard',
        'username': 'John Doe'
      };
      expect(userProvider.isVertex, false);

      userProvider.userData = {
        'accountType': 'standard',
        'username': 'John Doe',
        'isVertex': true
      };
      expect(userProvider.isVertex, true);

      // Falsy values must not leak through as true.
      userProvider.userData = {
        'accountType': 'standard',
        'username': 'John Doe',
        'isVertex': false
      };
      expect(userProvider.isVertex, false);
    });

    group('Subscription Logic', () {
      test('Free Tier (explicit free map)', () {
        userProvider.userData = {
          'subscription': {'tier': 'free'}
        };
        expect(userProvider.subscription.isActive, false);
      });

      test('Missing Map (Free)', () {
        userProvider.userData = {};
        expect(userProvider.subscription.isActive, false);
        expect(userProvider.subscription.effectiveTier, SubscriptionTier.free);
      });

      test('Lifetime Tier (No expiresAt)', () {
        userProvider.userData = {
          'subscription': {
            'tier': 'pro',
            'mode': 'lifetime',
            'status': 'active',
            'source': 'admin',
          }
        };
        expect(userProvider.subscription.isActive, true);
        expect(userProvider.subscription.effectiveTier, SubscriptionTier.pro);
      });

      test('Renewable - Active (Future Date)', () {
        userProvider.userData = {
          'subscription': {
            'tier': 'plus',
            'mode': 'renewable',
            'status': 'active',
            'expiresAt':
                Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
            'productId': 'vertex_ai_monthly_sub',
            'billingPeriod': 'monthly',
            'source': 'app_store',
          }
        };
        expect(userProvider.subscription.isActive, true);
      });

      test('Renewable - Active (Cached ISO String Date)', () {
        final futureDate =
            DateTime.now().add(const Duration(days: 1)).toIso8601String();
        userProvider.userData = {
          'subscription': {
            'tier': 'plus',
            'mode': 'renewable',
            'status': 'active',
            'expiresAt': futureDate,
          }
        };
        expect(userProvider.subscription.isActive, true);
      });

      test('Renewable - Expired (Past Date)', () {
        userProvider.userData = {
          'subscription': {
            'tier': 'plus',
            'mode': 'renewable',
            'status': 'active',
            'expiresAt': Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 1))),
          }
        };
        expect(userProvider.subscription.isActive, false);
        expect(userProvider.subscription.effectiveTier, SubscriptionTier.free);
      });

      test('Renewable - Invalid Date', () {
        userProvider.userData = {
          'subscription': {
            'tier': 'plus',
            'mode': 'renewable',
            'status': 'active',
            'expiresAt': 'not-a-date',
          }
        };
        expect(userProvider.subscription.isActive, false);
      });

      test('Renewable - Missing expiresAt', () {
        userProvider.userData = {
          'subscription': {
            'tier': 'plus',
            'mode': 'renewable',
            'status': 'active',
          }
        };
        expect(userProvider.subscription.isActive, false);
      });

      test('Terminal Status (expired)', () {
        userProvider.userData = {
          'subscription': {
            'tier': 'ultra',
            'mode': 'renewable',
            'status': 'expired',
          }
        };
        expect(userProvider.subscription.isActive, false);
        // The nominal tier is kept for history.
        expect(userProvider.subscription.tier, SubscriptionTier.ultra);
      });

      test('Anonymous Account (Free even with a paid map)', () {
        userProvider.userData = {
          'accountType': 'anonymous',
          'subscription': {
            'tier': 'ultra',
            'mode': 'lifetime',
            'status': 'active',
          }
        };
        expect(userProvider.subscription.isActive, false);
        expect(userProvider.subscription.effectiveTier, SubscriptionTier.free);
      });
    });
  });
}
