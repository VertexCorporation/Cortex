import 'package:cortex/funds/routing.dart';
import 'package:cortex/server/subscription.dart';
import 'package:flutter_test/flutter_test.dart';

/// The premium-briefing ladder: each tier upsells exactly one step up, and
/// Ultra — the top of the ladder — has nowhere further to go (its briefings
/// stay dismiss-only, no navigation is triggered).
void main() {
  test('nextSubscriptionPlanType maps each tier to its next plan', () {
    expect(nextSubscriptionPlanType(SubscriptionTier.free), 'plus');
    expect(nextSubscriptionPlanType(SubscriptionTier.plus), 'pro');
    expect(nextSubscriptionPlanType(SubscriptionTier.pro), 'ultra');
    expect(nextSubscriptionPlanType(SubscriptionTier.ultra), isNull);
  });
}
