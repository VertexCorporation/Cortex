// lib/funds/routing.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:cortex/funds/funds.dart';
import 'package:cortex/login/upgrade.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/server/subscription.dart';
import 'package:cortex/server/user.dart';

/// The plan a tier should be upsold to: exactly one step up the ladder, or
/// `null` for Ultra — the top of the ladder has nowhere further to go, so
/// its briefings stay dismiss-only.
String? nextSubscriptionPlanType(SubscriptionTier currentTier) =>
    switch (currentTier) {
      SubscriptionTier.free => 'plus',
      SubscriptionTier.plus => 'pro',
      SubscriptionTier.pro => 'ultra',
      SubscriptionTier.ultra => null,
    };

/// The one conversion funnel every premium-briefing tap routes through.
/// The next step is derived from the caller's live account state — never
/// from the wording on the panel:
///
///   anonymous → account upgrade flow (register, with a sign-in toggle)
///   free      → funds screen with Plus pre-selected
///   plus      → funds screen with Pro pre-selected
///   pro       → funds screen with Ultra pre-selected
///   ultra     → no higher plan: nothing happens (dismiss-only)
void openNextSubscriptionStep(BuildContext context) {
  final userProvider = context.read<UserProvider>();

  if (userProvider.isAnonymous) {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    navigateToScreen(
        const UpgradeAccountScreen(), direction: const Offset(0, 1));
    return;
  }

  final nextPlanType =
      nextSubscriptionPlanType(userProvider.subscription.effectiveTier);
  if (nextPlanType == null) return;

  HapticFeedback.lightImpact();
  FocusScope.of(context).unfocus();
  navigateToScreen(
    FundsScreen(initialPlanType: nextPlanType),
    direction: const Offset(1.0, 0.0),
  );
}
