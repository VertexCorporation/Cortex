import 'dart:convert';
import 'dart:io';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/settings/widgets/grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('premium gate translations exist for every supported locale', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final loc = await AppLocalizations.delegate.load(locale);
      final arb = jsonDecode(File('lib/l10n/app_${locale.languageCode}.arb')
          .readAsStringSync()) as Map;
      expect(loc.premiumChatGateTitle, arb['premiumChatGateTitle']);
      expect(loc.premiumChatGateDescription, arb['premiumChatGateDescription']);
      expect(loc.premiumChatGateCta, arb['premiumChatGateCta']);
      for (final key in [
        'premiumChatGateTitle',
        'premiumChatGateDescription',
        'premiumChatGateCta'
      ]) {
        expect(arb[key],
            isA<String>().having((s) => s.isNotEmpty, 'nonempty', true));
      }
    }
  });

  testWidgets(
      'premium and destructive settings rows keep standard dimensions and taps',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Column(children: [
      SettingsActionRow(label: 'English', onTap: () => taps++),
      SettingsActionRow(
          label: 'My Plan',
          backgroundColor: Colors.amber,
          borderColor: Colors.amber,
          onTap: () => taps++),
      SettingsActionRow(
          label: 'Delete all conversations',
          backgroundColor: Colors.red,
          onTap: () => taps++),
      const SizedBox(height: 12),
      SettingsActionRow(
          label: 'Delete account',
          backgroundColor: Colors.red,
          onTap: () => taps++),
    ]))));
    final rows = find.byType(SettingsActionRow);
    for (var i = 1; i < 4; i++) {
      expect(tester.getSize(rows.at(i)), tester.getSize(rows.first));
    }
    expect(
        tester.getTopLeft(rows.at(3)).dy - tester.getBottomLeft(rows.at(2)).dy,
        12);
    await tester.tap(find.text('My Plan'));
    expect(taps, 1);
  });
}
