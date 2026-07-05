// test/server_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
      expect(userProvider.isSubscriptionActive, false);
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

    group('Subscription Logic', () {
      test('Free Tier', () {
        userProvider.userData = {'hasCortexSubscription': 0};
        expect(userProvider.isSubscriptionActive, false);
      });

      test('Lifetime Tier (Level 4)', () {
        userProvider.userData = {'hasCortexSubscription': 4};
        expect(userProvider.isSubscriptionActive, true);
      });

      test('Premium Tier - Active (Future Date)', () {
        userProvider.userData = {
          'hasCortexSubscription': 1,
          'subscriptionExpiresAt':
              Timestamp.fromDate(DateTime.now().add(const Duration(days: 1)))
        };
        expect(userProvider.isSubscriptionActive, true);
      });

      test('Premium Tier - Active (Cached String Date)', () {
        final futureDate =
            DateTime.now().add(const Duration(days: 1)).toIso8601String();
        userProvider.userData = {
          'hasCortexSubscription': 1,
          'subscriptionExpiresAt': futureDate
        };
        expect(userProvider.isSubscriptionActive, true);
      });

      test('Premium Tier - Expired (Past Date)', () {
        userProvider.userData = {
          'hasCortexSubscription': 1,
          'subscriptionExpiresAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1)))
        };
        expect(userProvider.isSubscriptionActive, false);
      });

      test('Premium Tier - Invalid Date', () {
        userProvider.userData = {
          'hasCortexSubscription': 1,
          'subscriptionExpiresAt': 'not-a-date'
        };
        expect(userProvider.isSubscriptionActive, false);
      });

      test('Premium Tier - Missing Date', () {
        userProvider.userData = {
          'hasCortexSubscription': 1,
        };
        expect(userProvider.isSubscriptionActive, false);
      });
    });
  });
}
