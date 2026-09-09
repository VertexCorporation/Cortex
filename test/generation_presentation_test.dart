import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/screen/appbar/premium.dart';
import 'package:cortex/chat/screen/widgets/media.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget app(Widget child, {String language = 'tr', bool reduceMotion = false}) =>
    MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
          data: MediaQueryData(
              size: const Size(320, 640), disableAnimations: reduceMotion),
          child: Scaffold(body: child)),
    );

void main() {
  for (final language in ['tr', 'en']) {
    for (final type in MediaGenerationType.values
        .where((type) => type != MediaGenerationType.none)) {
      testWidgets(
          '$language $type has a centered label and icon across animation',
          (tester) async {
        await tester.pumpWidget(
            app(MediaShimmerPlaceholder(type: type), language: language));
        final label = find.descendant(
            of: find.byType(MediaShimmerPlaceholder),
            matching: find.byType(Text));
        final text = tester.widget<Text>(label);
        expect(text.data!.endsWith('...'), false);
        expect(text.data!.endsWith('…'), false);
        final original = tester.getCenter(label);
        expect(
            find.descendant(
                of: find.byType(MediaShimmerPlaceholder),
                matching: find.byType(Icon)),
            findsOneWidget);
        await tester.pump(const Duration(milliseconds: 700));
        expect(tester.getCenter(label), original);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  testWidgets('reduced motion generation card settles', (tester) async {
    await tester.pumpWidget(app(
        const MediaShimmerPlaceholder(type: MediaGenerationType.document),
        reduceMotion: true));
    await tester.pumpAndSettle();
    expect(find.text('Belge Oluşturuluyor'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'narrow premium action scales the full video label and remains tappable',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ThemeProvider('dark'),
        child: app(Center(
            child: SizedBox(
                width: 140,
                height: 48,
                child: PremiumButton(
                    label: 'Create Video', onTap: () => taps++))))));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Create Video'), findsOneWidget);
    final text = tester.widget<Text>(find.text('Create Video'));
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(
        find.ancestor(
            of: find.text('Create Video'), matching: find.byType(FittedBox)),
        findsOneWidget);
    await tester.tap(find.byType(PremiumButton));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
