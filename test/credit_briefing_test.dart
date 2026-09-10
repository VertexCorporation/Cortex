import 'package:cortex/chat/screen/widgets/bottom/panels/briefing.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Credit-state briefing coverage: the overlay must warn about degraded
/// intelligence from zero down to the plan's debt floor, switch to the
/// usage-limit message only at the floor, and once dismissed stay hidden
/// until the credit state actually changes.
Widget _app({
  required int? credits,
  int debtFloor = -50,
  bool isDynamicChat = true,
  String conversationId = 'briefing-test-conv',
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: BriefingOverlay(
          availableCredits: credits,
          debtFloor: debtFloor,
          photoSelected: false,
          isOfflineModel: false,
          modelMissing: false,
          inappropriate: false,
          limitReached: false,
          isStorageSufficient: true,
          isPremiumModel: false,
          isVideoModel: false,
          isSubscribed: false,
          userTier: SubscriptionTier.free,
          isDynamicChat: isDynamicChat,
          isSearchEnabled: false,
          isFalOffline: false,
          isUserStateReady: true,
          conversationId: conversationId,
        ),
      ),
    ),
  );
}

AppLocalizations _loc(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;

/// The briefing renders its message through a RichText, which plain
/// find.text() ignores by default.
Finder _txt(String message) => find.text(message, findRichText: true);

void main() {
  testWidgets(
      'zero credits above the floor warns about intelligence, not the usage limit',
      (tester) async {
    await tester.pumpWidget(_app(credits: 0));
    await tester.pumpAndSettle();
    final loc = _loc(tester);
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsOneWidget);
    expect(_txt(loc.reachedLimit), findsNothing);
  });

  testWidgets('negative credits above the floor still warn about intelligence',
      (tester) async {
    await tester.pumpWidget(_app(credits: -49));
    await tester.pumpAndSettle();
    final loc = _loc(tester);
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsOneWidget);
    expect(_txt(loc.reachedLimit), findsNothing);
  });

  testWidgets('reaching the plan debt floor is the usage limit', (tester) async {
    await tester.pumpWidget(_app(credits: -50));
    await tester.pumpAndSettle();
    final loc = _loc(tester);
    expect(_txt(loc.reachedLimit), findsOneWidget);
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsNothing);
  });

  testWidgets('below the floor is still the usage limit', (tester) async {
    await tester.pumpWidget(_app(credits: -51));
    await tester.pumpAndSettle();
    final loc = _loc(tester);
    expect(_txt(loc.reachedLimit), findsOneWidget);
  });

  testWidgets('positive credits show no briefing', (tester) async {
    await tester.pumpWidget(_app(credits: 30));
    await tester.pumpAndSettle();
    final loc = _loc(tester);
    expect(_txt(loc.reachedLimit), findsNothing);
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsNothing);
  });

  testWidgets('manual models get the same credit bands', (tester) async {
    await tester.pumpWidget(_app(credits: 0, isDynamicChat: false));
    await tester.pumpAndSettle();
    final loc = _loc(tester);
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsOneWidget);

    await tester.pumpWidget(_app(credits: -50, isDynamicChat: false));
    await tester.pumpAndSettle();
    expect(_txt(loc.reachedLimit), findsOneWidget);
  });

  testWidgets(
      'tap dismisses the warning and it stays dead across rebuilds and conversations',
      (tester) async {
    await tester.pumpWidget(_app(credits: 0));
    await tester.pumpAndSettle();
    final loc = _loc(tester);
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsOneWidget);

    // Tap: the panel must fade away and disappear completely.
    await tester.tap(_txt(loc.creditWarningFreeDecliningMessage));
    await tester.pumpAndSettle();
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsNothing);

    // Rebuilds with the same credit state must not resurrect it.
    await tester.pumpWidget(_app(credits: 0));
    await tester.pumpAndSettle();
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsNothing);

    // A new conversation is not a new credit state either.
    await tester.pumpWidget(_app(credits: 0, conversationId: 'other-conv'));
    await tester.pumpAndSettle();
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsNothing);

    // Hitting the floor is a new state: the usage limit shows again.
    await tester.pumpWidget(_app(credits: -50, conversationId: 'other-conv'));
    await tester.pumpAndSettle();
    expect(_txt(loc.reachedLimit), findsOneWidget);

    // Recovery clears the dismissal, so the next dip warns afresh.
    await tester.pumpWidget(_app(credits: 25, conversationId: 'other-conv'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_app(credits: 0, conversationId: 'other-conv'));
    await tester.pumpAndSettle();
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsOneWidget);
  });

  testWidgets('swiping the panel down fades it out for good', (tester) async {
    await tester.pumpWidget(_app(credits: 0));
    await tester.pumpAndSettle();
    final loc = _loc(tester);
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsOneWidget);

    await tester.fling(
      _txt(loc.creditWarningFreeDecliningMessage),
      const Offset(0, 300),
      2000.0,
    );
    await tester.pumpAndSettle();
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsNothing);

    // Same state rebuild after the swipe: still gone.
    await tester.pumpWidget(_app(credits: 0));
    await tester.pumpAndSettle();
    expect(_txt(loc.creditWarningFreeDecliningMessage), findsNothing);
  });
}
