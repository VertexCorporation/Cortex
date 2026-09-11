// test/credit_routing_test.dart
//
// Regression coverage for the credit-band model routing invariant:
//
//   Credit restrictions ration SERVER-SIDE inference only. Below the `full`
//   band a server-side/manual selection is answered by Dynamic Chat
//   (cortex/auto — mirroring the gateway's manual_selection_disabled
//   policy), but an installed OFFLINE model keeps executing on-device at ANY
//   balance — including negative balances and the debt floor — and its
//   prompt never silently ships to Cortex through Dynamic Chat.
//
// Incident under test (2026-09-11): a user with -35 credits selected
// qwen3-06b, the model loaded, and send.dart rewrote the request to
// cortex/auto because the low-credit override did not distinguish local
// from server-side execution — both a usability and a privacy regression.
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/service.dart';
import 'package:cortex/chat/services/send.dart'
    show lowCreditsForcesDynamicChat, shouldGenerateTitleRemotely;
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Minimal stand-in for [ChatSessionProvider]: only what InputService reads.
class _FakeSession extends ChangeNotifier implements ChatSessionProvider {
  bool localModelLoaded = false;

  @override
  bool get isLocalModelLoaded => localModelLoaded;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The catalog shape of the incident: an installed offline model.
final ModelEntity offlineQwen = ModelEntity.fromMap(const {
  'id': 'qwen3-06b',
  'title': 'Qwen3 0.6B',
  'type': 'offline',
  'source': 'user',
  'category': 'chat',
  'tier': 'free',
}, 'en');

/// A manual server-side model.
final ModelEntity onlineModel = ModelEntity.fromMap(const {
  'id': 'gpt-test',
  'title': 'Test Online Model',
  'type': 'online',
  'source': 'openrouter',
  'category': 'chat',
  'tier': 'free',
}, 'en');

void main() {
  tearDown(() {
    // The CreditsManager is an app-session singleton; reset it between tests.
    CreditsManager.instance.accessNotifier.value = CreditAccess.full;
    CreditsManager.instance.spendableNotifier.value = null;
  });

  group('lowCreditsForcesDynamicChat — the routing matrix', () {
    test('credits=50 + online manual model → the selected online model answers',
        () {
      expect(
        lowCreditsForcesDynamicChat(
            canChooseModel: true, selectedModelIsServerSide: true),
        isFalse,
      );
    });

    test('credits=-1 + online manual model → cortex/auto (Dynamic Chat)', () {
      expect(
        lowCreditsForcesDynamicChat(
            canChooseModel: false, selectedModelIsServerSide: true),
        isTrue,
      );
    });

    test(
        'credits=-35 + offline qwen3-06b → qwen3-06b keeps executing locally',
        () {
      expect(
        lowCreditsForcesDynamicChat(
            canChooseModel: false, selectedModelIsServerSide: false),
        isFalse,
      );
    });

    test(
        'credits=-50 (debt floor) + offline model → local execution still allowed',
        () {
      expect(
        lowCreditsForcesDynamicChat(
            canChooseModel: false, selectedModelIsServerSide: false),
        isFalse,
      );
    });

    test('healthy credits + offline model → never overridden either', () {
      expect(
        lowCreditsForcesDynamicChat(
            canChooseModel: true, selectedModelIsServerSide: false),
        isFalse,
      );
    });
  });

  group('the canonical model execution property (ModelEntity.isServerSide)', () {
    test('an offline-type model is local; an online-type model is server-side',
        () {
      expect(offlineQwen.type, 'offline');
      expect(offlineQwen.isServerSide, isFalse);
      expect(onlineModel.isServerSide, isTrue);
    });

    test('the send-time matrix from the incident report', () {
      // (spendable credits, selected model, expected routed model id)
      final cases = <(int, ModelEntity, String)>[
        (50, onlineModel, 'gpt-test'),
        (-1, onlineModel, 'cortex/auto'),
        (-35, offlineQwen, 'qwen3-06b'),
        (-50, offlineQwen, 'qwen3-06b'),
      ];
      for (final (credits, model, expected) in cases) {
        // The access band mirrors the server's evaluateCreditPolicy.
        final access = credits <= -50
            ? CreditAccess.blocked
            : (credits < 0 ? CreditAccess.lowOnly : CreditAccess.full);
        final routedToDynamic = lowCreditsForcesDynamicChat(
          canChooseModel: access == CreditAccess.full,
          selectedModelIsServerSide: model.isServerSide,
        );
        final routed = routedToDynamic ? 'cortex/auto' : model.id;
        expect(routed, expected,
            reason: 'credits=$credits + ${model.id} must route to $expected');
      }
    });

    test(
        'offline inference never reaches the ApiService generation branch: with the model kept, the server branch is unreachable',
        () {
      // send.dart computes isServerSide = isAutoRouter || Utils.isServerSideModel(id)
      // and gates the ApiService execution branch AND the server-side memory
      // extraction on it. With the offline model never rewritten to
      // cortex/auto, that flag is false for every credit state — so no
      // generation or memory request carrying the conversation content can
      // be sent for this generation. Remote TitleGen is the single
      // product-defined exception (see the shouldGenerateTitleRemotely
      // group below) and only ever shares the first user message as a
      // short title prompt — never the conversation itself.
      for (final credits in [-35, -50]) {
        final forcedToDynamic = lowCreditsForcesDynamicChat(
            canChooseModel: false,
            selectedModelIsServerSide: offlineQwen.isServerSide);
        expect(forcedToDynamic, isFalse,
            reason:
                'credits=$credits: an offline selection must never be rewritten');
        final routed = forcedToDynamic ? 'cortex/auto' : offlineQwen.id;
        final isServerSide = routed == 'cortex/auto' || offlineQwen.isServerSide;
        expect(isServerSide, isFalse,
            reason: 'credits=$credits: the offline execution branch is taken');
      }
    });
  });

  group('shouldGenerateTitleRemotely — offline chats get AI titles when online',
      () {
    test('online chat → remote TitleGen (its message path required internet)',
        () {
      expect(
          shouldGenerateTitleRemotely(isServerSide: true, hasInternet: true),
          isTrue);
      // A server-side send with no internet never even reaches TitleGen: the
      // send itself throws ApiException(checkYourInternet) long before.
      expect(
          shouldGenerateTitleRemotely(isServerSide: true, hasInternet: false),
          isTrue);
    });

    test(
        'offline chat + internet → remote TitleGen fires; the conversation itself still never leaves the device',
        () {
      expect(
          shouldGenerateTitleRemotely(isServerSide: false, hasInternet: true),
          isTrue,
          reason: 'offline chats share only the first message as a title prompt');
    });

    test('offline chat + no internet → fallback title, zero doomed requests',
        () {
      expect(
          shouldGenerateTitleRemotely(isServerSide: false, hasInternet: false),
          isFalse,
          reason: 'with no connectivity TitleGen cannot succeed, so the chat '
              'must silently keep its local fallback title');
    });

    test('TitleGen stays reachable for offline chats at the debt floor', () {
      // Credits are never consulted for offline sends and TitleGen itself is
      // not credit-gated client-side. Any server-side refusal is caught — the
      // fallback title survives and the chat continues either way.
      for (final credits in [-35, -50]) {
        final forcedToDynamic = lowCreditsForcesDynamicChat(
            canChooseModel: false,
            selectedModelIsServerSide: offlineQwen.isServerSide);
        expect(forcedToDynamic, isFalse,
            reason: 'credits=$credits: offline stays on-device');
        expect(
            shouldGenerateTitleRemotely(isServerSide: false, hasInternet: true),
            isTrue,
            reason: 'credits=$credits: offline TitleGen must stay reachable');
      }
    });
  });

  group('InputService send-button gating — offline mode is never credit-gated',
      () {
    /// Pumps the provider stack InputService reads and evaluates the button.
    Future<bool> sendButtonEnabled(
      WidgetTester tester, {
      required bool isServerSideModel,
      required bool isDynamicChatMode,
      bool isPremiumModel = false,
      bool isSubscribed = false,
      bool localModelLoaded = true,
    }) async {
      final input = InputProvider();
      final session = _FakeSession()..localModelLoaded = localModelLoaded;
      final controller = TextEditingController(text: 'merhaba');
      late BuildContext actionContext;
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<InputProvider>.value(value: input),
          ChangeNotifierProvider<ChatSessionProvider>.value(value: session),
          Provider<CreditsManager>.value(value: CreditsManager.instance),
        ],
        child: MaterialApp(
          home: Builder(builder: (context) {
            actionContext = context;
            return const SizedBox();
          }),
        ),
      ));
      final enabled = InputService().isSendButtonEnabled(
        context: actionContext,
        controller: controller,
        isServerSideModel: isServerSideModel,
        isDynamicChatMode: isDynamicChatMode,
        isLimitExceeded: false,
        isSending: false,
        modelMissing: false,
        isStorageSufficient: true,
        isPremiumModel: isPremiumModel,
        isSubscribed: isSubscribed,
        isVideoModel: false,
        userTier: SubscriptionTier.free,
        totalCredits: CreditsManager.instance.spendableNotifier.value,
      );
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      input.dispose();
      session.dispose();
      return enabled;
    }

    void setCredits(int spendable) {
      CreditsManager.instance.debugSetCreditLimits(
          const CreditLimits(dailyGrant: 50, debtFloor: -50));
      CreditsManager.instance.spendableNotifier.value = spendable;
      CreditsManager.instance.accessNotifier.value = spendable <= -50
          ? CreditAccess.blocked
          : (spendable < 0 ? CreditAccess.lowOnly : CreditAccess.full);
    }

    testWidgets('credits=-35 + offline model → send button stays enabled',
        (tester) async {
      setCredits(-35);
      expect(
        await sendButtonEnabled(tester,
            isServerSideModel: false, isDynamicChatMode: false),
        isTrue,
      );
    });

    testWidgets('credits=-50 (debt floor) + offline model → still enabled',
        (tester) async {
      setCredits(-50);
      expect(
        await sendButtonEnabled(tester,
            isServerSideModel: false, isDynamicChatMode: false),
        isTrue,
      );
    });

    testWidgets(
        'credits=-1 + online manual model → disabled (Dynamic Chat policy)',
        (tester) async {
      setCredits(-1);
      expect(
        await sendButtonEnabled(tester,
            isServerSideModel: true, isDynamicChatMode: false),
        isFalse,
      );
    });

    testWidgets('credits=50 + online manual model → enabled', (tester) async {
      setCredits(50);
      expect(
        await sendButtonEnabled(tester,
            isServerSideModel: true, isDynamicChatMode: false),
        isTrue,
      );
    });

    testWidgets(
        'credits=-1 + dynamic chat → still enabled (existing debt policy)',
        (tester) async {
      setCredits(-1);
      expect(
        await sendButtonEnabled(tester,
            isServerSideModel: true, isDynamicChatMode: true),
        isTrue,
      );
    });

    testWidgets('credits=-50 + dynamic chat → disabled at the floor',
        (tester) async {
      setCredits(-50);
      expect(
        await sendButtonEnabled(tester,
            isServerSideModel: true, isDynamicChatMode: true),
        isFalse,
      );
    });

    testWidgets('offline model not loaded → disabled (local engine required)',
        (tester) async {
      setCredits(50);
      expect(
        await sendButtonEnabled(tester,
            isServerSideModel: false,
            isDynamicChatMode: false,
            localModelLoaded: false),
        isFalse,
      );
    });

    testWidgets(
        'offline premium variant + low credits + no subscription → enabled (credit bands never gate local inference)',
        (tester) async {
      setCredits(-35);
      expect(
        await sendButtonEnabled(tester,
            isServerSideModel: false,
            isDynamicChatMode: false,
            isPremiumModel: true,
            isSubscribed: false),
        isTrue,
      );
    });
  });
}
