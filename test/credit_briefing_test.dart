import 'package:cortex/chat/screen/widgets/bottom/panels/briefing.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Full tier × credit-band briefing matrix. The declining band (zero or
/// negative credits above the debt floor) and the exhausted band (at or
/// below the floor) each get tier-aware copy with a live {renewalTime}
/// countdown; dismissal is keyed to the logical briefing kind, so a ticking
/// countdown never resurrects a dismissed panel, while crossing bands does.

/// A renewal instant [hours]/[minutes] from now, with 30 seconds of slack
/// inside the current minute: the formatter floors, so the rendered
/// "Xh Ym" stays stable for the few real seconds the test takes.
DateTime _renewalIn({int hours = 0, int minutes = 0}) => DateTime.now()
    .add(Duration(hours: hours, minutes: minutes, seconds: 30));

Widget _app({
  required int? credits,
  int debtFloor = -50,
  SubscriptionTier userTier = SubscriptionTier.free,
  DateTime? renewalAt,
  bool isDynamicChat = true,
  bool isVideoModel = false,
  bool isUserStateReady = true,
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
          renewalAt: renewalAt ?? _renewalIn(hours: 5, minutes: 42),
          photoSelected: false,
          isOfflineModel: false,
          modelMissing: false,
          inappropriate: false,
          limitReached: false,
          isStorageSufficient: true,
          isPremiumModel: false,
          isVideoModel: isVideoModel,
          isSubscribed: false,
          userTier: userTier,
          isDynamicChat: isDynamicChat,
          isSearchEnabled: false,
          isFalOffline: false,
          isUserStateReady: isUserStateReady,
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

/// Unmounts the tree so the countdown Timer is cancelled before the test
/// framework's pending-timer invariant check.
Future<void> _tearDown(WidgetTester tester) async {
  await tester.pumpWidget(Container());
}

void main() {
  group('tier × declining band (zero or negative credits above the floor)',
      () {
    testWidgets('Free gets the free-tier warning with the renewal countdown',
        (tester) async {
      await tester.pumpWidget(_app(credits: 0));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(_txt(loc.creditWarningFreeDecliningMessage('5h 42m')),
          findsOneWidget);
      expect(_txt(loc.reachedLimit), findsNothing);
      expect(_txt(loc.creditWarningExhaustedMessage('5h 42m')), findsNothing);
      await _tearDown(tester);
    });

    testWidgets('negative credits stay in the declining band', (tester) async {
      await tester.pumpWidget(_app(credits: -49));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(_txt(loc.creditWarningFreeDecliningMessage('5h 42m')),
          findsOneWidget);
      await _tearDown(tester);
    });

    testWidgets('Plus gets the paid-upgrade warning', (tester) async {
      await tester
          .pumpWidget(_app(credits: 0, userTier: SubscriptionTier.plus));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(
          _txt(loc.creditWarningPaidUpgradeMessage('5h 42m')), findsOneWidget);
      expect(_txt(loc.creditWarningFreeDecliningMessage('5h 42m')),
          findsNothing);
      await _tearDown(tester);
    });

    testWidgets('Pro gets the paid-upgrade warning too', (tester) async {
      await tester
          .pumpWidget(_app(credits: -10, userTier: SubscriptionTier.pro));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(
          _txt(loc.creditWarningPaidUpgradeMessage('5h 42m')), findsOneWidget);
      await _tearDown(tester);
    });

    testWidgets(
        'Ultra gets the plain low-usage warning, never an upgrade nudge',
        (tester) async {
      await tester
          .pumpWidget(_app(credits: 0, userTier: SubscriptionTier.ultra));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(_txt(loc.creditWarningUltraMessage('5h 42m')), findsOneWidget);
      expect(_txt(loc.creditWarningPaidUpgradeMessage('5h 42m')), findsNothing);
      // Copy contract: Ultra never sells an upgrade, the other tiers do.
      expect(loc.creditWarningUltraMessage('5h').contains('Upgrade'), isFalse);
      expect(loc.creditWarningUltraExhaustedMessage('5h').contains('Upgrade'),
          isFalse);
      expect(
          loc.creditWarningPaidUpgradeMessage('5h').contains('Upgrade'),
          isTrue);
      expect(loc.creditWarningExhaustedMessage('5h').contains('Upgrade'),
          isTrue);
      expect(loc.creditWarningFreeDecliningMessage('5h').contains('Upgrade'),
          isTrue);
      await _tearDown(tester);
    });
  });

  group('tier × exhausted band (credits at or below the floor)', () {
    testWidgets('Free at the floor shows the exhausted warning',
        (tester) async {
      await tester.pumpWidget(_app(credits: -50));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(
          _txt(loc.creditWarningExhaustedMessage('5h 42m')), findsOneWidget);
      expect(_txt(loc.reachedLimit), findsNothing);
      expect(_txt(loc.creditWarningFreeDecliningMessage('5h 42m')),
          findsNothing);
      await _tearDown(tester);
    });

    testWidgets('below the floor is still the exhausted band', (tester) async {
      await tester.pumpWidget(_app(credits: -60));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(
          _txt(loc.creditWarningExhaustedMessage('5h 42m')), findsOneWidget);
      await _tearDown(tester);
    });

    testWidgets('Plus at the floor shows the exhausted warning',
        (tester) async {
      await tester.pumpWidget(
          _app(credits: -50, userTier: SubscriptionTier.plus));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(
          _txt(loc.creditWarningExhaustedMessage('5h 42m')), findsOneWidget);
      await _tearDown(tester);
    });

    testWidgets('Ultra at the floor shows the no-upgrade exhausted warning',
        (tester) async {
      await tester.pumpWidget(
          _app(credits: -50, userTier: SubscriptionTier.ultra));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(_txt(loc.creditWarningUltraExhaustedMessage('5h 42m')),
          findsOneWidget);
      expect(_txt(loc.creditWarningExhaustedMessage('5h 42m')), findsNothing);
      await _tearDown(tester);
    });
  });

  group('{renewalTime} countdown', () {
    testWidgets('sub-hour renewals render as minutes only', (tester) async {
      await tester.pumpWidget(
          _app(credits: 0, renewalAt: _renewalIn(minutes: 47)));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(
          _txt(loc.creditWarningFreeDecliningMessage('47m')), findsOneWidget);
      await _tearDown(tester);
    });

    testWidgets('whole hours render without minutes', (tester) async {
      await tester
          .pumpWidget(_app(credits: 0, renewalAt: _renewalIn(hours: 5)));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(_txt(loc.creditWarningFreeDecliningMessage('5h')), findsOneWidget);
      await _tearDown(tester);
    });

    testWidgets('an expired renewal clamps at one minute, never negative',
        (tester) async {
      await tester.pumpWidget(_app(
          credits: 0,
          renewalAt: DateTime.now().subtract(const Duration(hours: 1))));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(
          _txt(loc.creditWarningFreeDecliningMessage('1m')), findsOneWidget);
      await _tearDown(tester);
    });

    testWidgets(
        'a countdown change under the same state updates the text in place',
        (tester) async {
      await tester.pumpWidget(
          _app(credits: 0, renewalAt: _renewalIn(hours: 5, minutes: 42)));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(_txt(loc.creditWarningFreeDecliningMessage('5h 42m')),
          findsOneWidget);

      // Same logical briefing, different countdown: the text swaps without
      // the panel sliding out and back in.
      await tester.pumpWidget(
          _app(credits: 0, renewalAt: _renewalIn(hours: 47, minutes: 20)));
      await tester.pumpAndSettle();
      expect(_txt(loc.creditWarningFreeDecliningMessage('47h 20m')),
          findsOneWidget);
      expect(_txt(loc.creditWarningFreeDecliningMessage('5h 42m')),
          findsNothing);
      await _tearDown(tester);
    });

    testWidgets('the countdown keeps ticking without replaying the animation',
        (tester) async {
      await tester.pumpWidget(_app(credits: 0));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      final first = loc.creditWarningFreeDecliningMessage('5h 42m');
      expect(_txt(first), findsOneWidget);

      // Fire one periodic refresh: the briefing must stay put.
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(_txt(first), findsOneWidget);
      await _tearDown(tester);
    });
  });

  group('dismissal is keyed to the briefing kind, not the rendered text', () {
    testWidgets('a dismissed briefing stays dead while the countdown changes',
        (tester) async {
      await tester.pumpWidget(
          _app(credits: 0, renewalAt: _renewalIn(hours: 5, minutes: 42)));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      final old = loc.creditWarningFreeDecliningMessage('5h 42m');
      expect(_txt(old), findsOneWidget);

      await tester.tap(_txt(old));
      await tester.pumpAndSettle();
      expect(_txt(old), findsNothing);

      // The countdown changed but the credit state did not: still dismissed.
      await tester.pumpWidget(
          _app(credits: 0, renewalAt: _renewalIn(hours: 3, minutes: 5)));
      await tester.pumpAndSettle();
      expect(_txt(loc.creditWarningFreeDecliningMessage('3h 5m')),
          findsNothing);
      await _tearDown(tester);
    });

    testWidgets('tap dismissal persists across rebuilds and conversations',
        (tester) async {
      await tester.pumpWidget(_app(credits: 0));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      final msg = loc.creditWarningFreeDecliningMessage('5h 42m');
      expect(_txt(msg), findsOneWidget);

      await tester.tap(_txt(msg));
      await tester.pumpAndSettle();
      expect(_txt(msg), findsNothing);

      await tester.pumpWidget(_app(credits: 0));
      await tester.pumpAndSettle();
      expect(_txt(msg), findsNothing);

      await tester.pumpWidget(_app(credits: 0, conversationId: 'other'));
      await tester.pumpAndSettle();
      expect(_txt(msg), findsNothing);
      await _tearDown(tester);
    });

    testWidgets('swiping the panel down fades it out for good',
        (tester) async {
      await tester.pumpWidget(_app(credits: 0));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      final msg = loc.creditWarningFreeDecliningMessage('5h 42m');
      expect(_txt(msg), findsOneWidget);

      await tester.fling(_txt(msg), const Offset(0, 300), 2000.0);
      await tester.pumpAndSettle();
      expect(_txt(msg), findsNothing);

      // Same state rebuild after the swipe: still gone.
      await tester.pumpWidget(_app(credits: 0));
      await tester.pumpAndSettle();
      expect(_txt(msg), findsNothing);
      await _tearDown(tester);
    });

    testWidgets(
        'crossing into a new band after dismissal surfaces the new briefing',
        (tester) async {
      await tester.pumpWidget(_app(credits: 0));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      final declining = loc.creditWarningFreeDecliningMessage('5h 42m');
      expect(_txt(declining), findsOneWidget);

      await tester.tap(_txt(declining));
      await tester.pumpAndSettle();
      expect(_txt(declining), findsNothing);

      // Falling to the floor is a different briefing kind: it reappears.
      await tester.pumpWidget(_app(credits: -50));
      await tester.pumpAndSettle();
      expect(
          _txt(loc.creditWarningExhaustedMessage('5h 42m')), findsOneWidget);

      // Recovery clears the dismissal, so a later dip warns afresh.
      await tester.pumpWidget(_app(credits: 25));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_app(credits: 0));
      await tester.pumpAndSettle();
      expect(_txt(declining), findsOneWidget);
      await _tearDown(tester);
    });
  });

  group('non-credit briefings', () {
    testWidgets('positive credits show no briefing', (tester) async {
      await tester.pumpWidget(_app(credits: 30));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(_txt(loc.reachedLimit), findsNothing);
      expect(
          _txt(loc.creditWarningFreeDecliningMessage('5h 42m')), findsNothing);
      expect(_txt(loc.creditWarningExhaustedMessage('5h 42m')), findsNothing);
      await _tearDown(tester);
    });

    testWidgets('manual models get the same credit bands', (tester) async {
      await tester.pumpWidget(_app(credits: 0, isDynamicChat: false));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(_txt(loc.creditWarningFreeDecliningMessage('5h 42m')),
          findsOneWidget);

      await tester.pumpWidget(_app(credits: -50, isDynamicChat: false));
      await tester.pumpAndSettle();
      expect(
          _txt(loc.creditWarningExhaustedMessage('5h 42m')), findsOneWidget);
      await _tearDown(tester);
    });

    testWidgets('video premium warning shows while credits last',
        (tester) async {
      await tester.pumpWidget(
          _app(credits: 100, isDynamicChat: false, isVideoModel: true));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(_txt(loc.videoPremiumWarning), findsOneWidget);
      await _tearDown(tester);
    });

    testWidgets('exhaustion preempts the video premium warning',
        (tester) async {
      await tester.pumpWidget(
          _app(credits: -50, isDynamicChat: false, isVideoModel: true));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(
          _txt(loc.creditWarningExhaustedMessage('5h 42m')), findsOneWidget);
      expect(_txt(loc.videoPremiumWarning), findsNothing);
      await _tearDown(tester);
    });

    testWidgets('nothing renders before the user state is ready',
        (tester) async {
      await tester.pumpWidget(_app(credits: -50, isUserStateReady: false));
      await tester.pumpAndSettle();
      final loc = _loc(tester);
      expect(_txt(loc.creditWarningExhaustedMessage('5h 42m')), findsNothing);
      await _tearDown(tester);
    });
  });
}
