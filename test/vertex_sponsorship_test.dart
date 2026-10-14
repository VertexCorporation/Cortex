import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/server/subscription.dart';

void main() {
  final sponsor = <String, dynamic>{
    'uid': 'member',
    'source': 'vertex',
    'tier': 'plus',
    'batch': List.filled(64, 'a').join(),
    'signature': '${List.filled(86, 'A').join()}==',
    'startedAt': '2026-01-01',
  };
  final user = <String, dynamic>{
    'isVertex': true,
    'vertexSponsorship': sponsor,
  };
  test('member display resolves Plus without changing paid map', () {
    final entitlement = SubscriptionEntitlement.fromUserData(
      user,
      uid: 'member',
    );
    expect(entitlement.effectiveTier, SubscriptionTier.plus);
    expect(entitlement.source, SubscriptionSource.vertex);
    expect(user.containsKey('subscription'), isFalse);
  });
  test('Pro and Ultra always keep store entitlement', () {
    for (final tier in ['plus', 'pro', 'ultra']) {
      final data = {
        ...user,
        'subscription': {
          'tier': tier,
          'status': 'active',
          'mode': 'lifetime',
          'source': 'app_store',
          'productId': 'own-product',
        },
      };
      final result = SubscriptionEntitlement.fromUserData(data, uid: 'member');
      expect(result.effectiveTier.value, tier);
      expect(result.productId, 'own-product');
    }
  });
  test(
    'deactivation, wrong UID, absent signature and anonymous display stay free',
    () {
      for (final data in [
        {...user, 'isVertex': false},
        {...user, 'accountType': 'anonymous'},
        {
          ...user,
          'vertexSponsorship': {...sponsor, 'signature': ''},
        },
      ]) {
        expect(
          SubscriptionEntitlement.fromUserData(
            data,
            uid: 'member',
          ).effectiveTier,
          SubscriptionTier.free,
        );
      }
      expect(
        SubscriptionEntitlement.fromUserData(
          user,
          uid: 'another',
        ).effectiveTier,
        SubscriptionTier.free,
      );
      expect(
        SubscriptionEntitlement.fromUserData(user).effectiveTier,
        SubscriptionTier.free,
      );
    },
  );
  test(
    'paid expiry falls back to sponsor; sponsor end keeps own paid plan',
    () {
      expect(
        SubscriptionEntitlement.fromUserData({
          ...user,
          'subscription': {
            'tier': 'pro',
            'mode': 'promotional',
            'status': 'expired',
          },
        }, uid: 'member').effectiveTier,
        SubscriptionTier.plus,
      );
      expect(
        SubscriptionEntitlement.fromUserData({
          ...user,
          'isVertex': false,
          'subscription': {
            'tier': 'pro',
            'mode': 'lifetime',
            'status': 'active',
          },
        }, uid: 'member').effectiveTier,
        SubscriptionTier.pro,
      );
    },
  );
}
