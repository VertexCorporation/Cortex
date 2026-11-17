// test/server_test.dart
// Firebase seals these interfaces; lightweight fakes are used only in tests.
// ignore_for_file: subtype_of_sealed_class, must_be_immutable

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/server/subscription.dart';
import 'package:cortex/server/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeFirebaseAuth(this.currentUser);

  @override
  final User? currentUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseUser implements User {
  _FakeFirebaseUser({this.displayName});

  @override
  String get uid => 'test-uid';

  @override
  bool get isAnonymous => false;

  @override
  final String? displayName;

  @override
  String? get email => 'fatih@example.com';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseFirestore implements FirebaseFirestore {
  _FakeFirebaseFirestore(this.collectionReference);

  final CollectionReference<Map<String, dynamic>> collectionReference;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      collectionReference;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCollectionReference
    implements CollectionReference<Map<String, dynamic>> {
  _FakeCollectionReference(this.documentReference);

  final DocumentReference<Map<String, dynamic>> documentReference;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      documentReference;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDocumentReference
    implements DocumentReference<Map<String, dynamic>> {
  _FakeDocumentReference(this.streams);

  final Stream<DocumentSnapshot<Map<String, dynamic>>> Function() streams;

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) =>
      streams();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDocumentSnapshot
    implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  bool get exists => true;

  @override
  Map<String, dynamic>? data() => {
    'uid': 'test-uid',
    'username': 'Recovered User',
    'accountType': 'standard',
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('UserProvider Tests', () {
    late UserProvider userProvider;

    setUp(() {
      // We pass nothing, so it defaults to "real" instances lazily.
      // But we won't touch methods that trigger them.
      userProvider = UserProvider();
    });

    test('retries a profile listener after permission is denied', () async {
      final user = _FakeFirebaseUser();
      final profileSnapshot = _FakeDocumentSnapshot();
      final firstAttempt =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>();
      final retryAttempt =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>();
      var snapshotAttempts = 0;
      final document = _FakeDocumentReference(() {
        snapshotAttempts++;
        return snapshotAttempts == 1 ? firstAttempt.stream : retryAttempt.stream;
      });
      final firestore = _FakeFirebaseFirestore(
        _FakeCollectionReference(document),
      );
      final provider = UserProvider(
        auth: _FakeFirebaseAuth(user),
        firestore: firestore,
      );
      addTearDown(() async {
        provider.dispose();
        await firstAttempt.close();
        await retryAttempt.close();
      });

      provider.listenToUserData(user);
      firstAttempt.addError(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 1100));
      expect(snapshotAttempts, 2);

      retryAttempt.add(profileSnapshot);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(provider.username, 'Recovered User');
      expect(provider.isAnonymous, false);
    });

    test('linked Firebase identity overrides stale anonymous profile cache', () {
      final user = _FakeFirebaseUser(displayName: 'Fatih');

      final provider = UserProvider(
        auth: _FakeFirebaseAuth(user),
        initialData: {
          'uid': 'test-uid',
          'accountType': 'anonymous',
          'username': 'Guest',
        },
      );
      addTearDown(provider.dispose);

      expect(provider.isAnonymous, false);
      expect(provider.username, 'Fatih');
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
