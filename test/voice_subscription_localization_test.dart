import 'dart:convert';
import 'dart:io';

import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cortex/funds/widgets/subscriptions.dart';
import 'package:cortex/server/subscription.dart';

void main() {
  for (final plan in ['plus', 'pro', 'ultra']) {
    testWidgets('$plan renders the localized voice allowance benefit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SubscriptionContentWidget(
              planType: plan,
              availableProducts: const [],
              selectedBillingOption: 'monthly',
              subscription: SubscriptionEntitlement.none,
              onBillingOptionChanged: (_) {},
              animateBenefits: false,
              onBenefitsAnimated: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Daha fazla sesli sohbet'), findsOneWidget);
      expect(find.text('More voice chat'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    });
  }

  test('voice benefit is translated in every supported localization', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final resources = jsonDecode(
        File('lib/l10n/app_${locale.languageCode}.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      final benefit = resources['benefitMoreVoiceChat'] as String;
      expect(benefit.trim(), isNotEmpty);
      if (locale.languageCode != 'en') {
        expect(benefit, isNot('More voice chat'));
      }
      final generated = await AppLocalizations.delegate.load(locale);
      expect(generated.benefitMoreVoiceChat, benefit);
      if (locale.languageCode == 'tr') {
        expect(benefit, 'Daha fazla sesli sohbet');
      }
    }
  });
}
