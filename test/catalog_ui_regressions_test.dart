import 'dart:convert';
import 'dart:io';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/settings/widgets/grouped_button.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/recording_layout.dart';
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

  for (final width in [320.0, 390.0, 800.0]) {
    testWidgets('recording layout reverses without jumps at width $width',
        (tester) async {
      final progress = ValueNotifier<double>(0);
      addTearDown(progress.dispose);
      final text = TextEditingController(text: 'draft');
      addTearDown(text.dispose);
      await tester.pumpWidget(MaterialApp(
          home: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
            width: width,
            child: ValueListenableBuilder<double>(
              valueListenable: progress,
              builder: (_, value, __) => RecordingLayout(
                  progress: value,
                  input: SizedBox(
                      height: 48,
                      child: Material(child: TextField(controller: text))),
                  waveform: const SizedBox(height: 90, width: double.infinity)),
            )),
      )));
      final originalField = tester.state(find.byType(TextField));
      // Include interrupted reversals and restarts, not just the endpoints.
      for (final value in [0.0, 0.2, 0.8, 1.0, 0.8, 0.5, 0.7, 0.1, 0.9, 0.0]) {
        progress.value = value;
        await tester.pump();
        expect(tester.getSize(find.byType(RecordingLayout)).height,
            closeTo(48 + 42 * value, 0.001));
        expect(tester.state(find.byType(TextField)), same(originalField));
        expect(text.text, 'draft');
        expect(tester.takeException(), isNull);
      }
    });
  }

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
