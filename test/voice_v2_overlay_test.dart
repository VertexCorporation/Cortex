// Voice entry owns the composer; orb taps only change presentation.

import 'dart:async';

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/services/send.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/screen/widgets/voice.dart';
import 'package:cortex/chat/screen/widgets/voice_orb.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/buttons.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/input.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/main.dart' show navigatorKey;
import 'package:cortex/funds/funds.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:cortex/server/subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Speech extends ChangeNotifier implements SpeechService {
  @override
  bool get isListening => false;
  @override
  bool get isDeviceSupported => true;
  @override
  double get soundLevel => 0;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _OverlayVoice extends ChangeNotifier implements VoiceService {
  _OverlayVoice(
    this._state, {
    this.transcript = '',
    this.exhausted = false,
    this.activeSession = true,
  });
  final bool exhausted;
  final bool activeSession;
  final VoiceState _state;

  /// Non-empty only in the no-text test — proves the overlay ignores it.
  final String transcript;

  int toggleFlowCalls = 0;
  int stopSessionCalls = 0;
  int startSessionCalls = 0;
  Completer<void>? pendingStop;
  @override
  void setFlowMode(bool enabled) {}
  @override
  Future<void> startSession({
    BuildContext? context,
    required String locale,
    required Function(String) onFinalSentence,
    String? systemPrompt,
  }) async {
    startSessionCalls++;
  }

  int startListeningCalls = 0;
  @override
  void startListening({BuildContext? context}) {
    startListeningCalls++;
  }

  @override
  VoiceState get state => _state;
  @override
  bool get voiceLimitReached => exhausted;

  @override
  void toggleFlowMode() {
    toggleFlowCalls++;
  }

  @override
  Future<void> stopSession({
    bool resetState = true,
    VoiceEndReason reason = VoiceEndReason.user,
  }) async {
    stopSessionCalls++;
    await pendingStop?.future;
  }

  @override
  bool get isSessionActive => activeSession;
  @override
  bool get isFlowActive => false;
  @override
  bool get isFlowMode => false;
  @override
  int get currentFlowAgentIndex => 0;
  @override
  VoiceEndReason? get lastEndReason => null;
  @override
  int? get remainingVoiceSeconds => 240;
  @override
  String get liveTranscript => transcript;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends ChangeNotifier implements ChatSessionProvider {
  @override
  Locale getLocale() => const Locale('en');
  @override
  ModelEntity? get selectedModel => null;
  @override
  bool get isFluxMode => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpOverlay(
  WidgetTester tester, {
  required InputProvider input,
  required _OverlayVoice voice,
  required ValueNotifier<double> panelHeight,
  required bool active,
  VoidCallback? onExited,
  NavigatorObserver? observer,
  UserProvider? user,
  Duration initialPump = const Duration(milliseconds: 400),
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<InputProvider>.value(value: input),
        ChangeNotifierProvider<VoiceService>.value(value: voice),
        ChangeNotifierProvider<ChatSessionProvider>(create: (_) => _Session()),
        ChangeNotifierProvider<SpeechService>(create: (_) => _Speech()),
        if (user != null)
          ChangeNotifierProvider<UserProvider>.value(value: user),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [?observer],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              // Composer stand-in pinned to the bottom whose height matches
              // the panel notifier the orb anchors to.
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: panelHeight.value,
                  color: Colors.amber,
                ),
              ),
              VoiceSessionOverlay(
                active: active,
                panelHeight: panelHeight,
                bottomSafe: 0,
                onExited: onExited ?? () {},
              ),
            ],
          ),
        ),
      ),
    ),
  );
  // The orb's ticker animates forever — pump a fixed window, never settle.
  await tester.pump(initialPump);
}

void main() {
  testWidgets(
    'voice button morphs before audio teardown completes and X cancels entry',
    (tester) async {
      final input = InputProvider();
      final voice = _OverlayVoice(VoiceState.idle, activeSession: false);
      voice.pendingStop = Completer<void>();
      addTearDown(input.dispose);
      await _pumpComposerVoice(tester, input: input, voice: voice);
      await tester.tap(find.byKey(const ValueKey('voice_chat')));
      expect(input.isVoiceModeActive, isTrue);
      expect(input.isVoiceOverlayExpanded, isFalse);
      await tester.pump();
      // Establish the post-frame animation ticker, then advance its clock.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.byKey(const ValueKey('flow_icon')).hitTestable(),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('voice_exit')).hitTestable(),
        findsOneWidget,
      );
      final opacity = tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: find.byKey(const ValueKey('composer_capsule')),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity;
      expect(opacity, lessThan(1));
      expect(voice.startSessionCalls, 0);
      await tester.tap(find.byKey(const ValueKey('voice_exit')));
      voice.pendingStop!.complete();
      await tester.pumpAndSettle();
      expect(input.isVoiceModeActive, isFalse);
      expect(voice.startSessionCalls, 0);
      expect(find.byKey(const ValueKey('plus_icon')), findsOneWidget);
    },
  );

  test(
    'authoritative allowance respects live reservations and daily renewal',
    () {
      tz.initializeTimeZones();
      final user = _VoiceUser(
        60,
        VoiceUsage(day: VoiceUsage.todayIstanbulKey(), consumedSeconds: 60),
      );
      final stopped = _OverlayVoice(VoiceState.idle, activeSession: false);
      expect(voiceAllowanceExhausted(stopped, user), isTrue);
      expect(
        voiceAllowanceExhausted(_OverlayVoice(VoiceState.listening), user),
        isFalse,
      );
      expect(
        voiceAllowanceExhausted(stopped, _VoiceUser(null, const VoiceUsage())),
        isFalse,
      );
      expect(
        voiceAllowanceExhausted(
          stopped,
          _VoiceUser(
            60,
            const VoiceUsage(day: '2000-01-01', consumedSeconds: 60),
          ),
        ),
        isFalse,
      );
      expect(
        voiceAllowanceExhausted(stopped, _VoiceUser(0, const VoiceUsage())),
        isTrue,
      );
    },
  );

  testWidgets('exhausted orb glides purple and opens Plus without retrying', (
    tester,
  ) async {
    final input = InputProvider()..setVoiceModeActive(true);
    final voice = _OverlayVoice(
      VoiceState.failed,
      exhausted: true,
      activeSession: false,
    );
    final height = ValueNotifier<double>(80);
    final observer = _Routes();
    addTearDown(input.dispose);
    addTearDown(height.dispose);
    await _pumpOverlay(
      tester,
      input: input,
      voice: voice,
      panelHeight: height,
      active: true,
      observer: observer,
    );
    final orb = tester.widget<VoiceOrb>(find.byType(VoiceOrb));
    final before = orb.controller.colorACurrent;
    for (var i = 0; i < 90; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(orb.controller.colorACurrent, isNot(before));
    expect(orb.controller.phase, VoiceOrbPhase.subdued);
    await tester.tap(find.byType(VoiceOrb));
    expect(voice.startListeningCalls, 0);
    expect(input.isVoiceOverlayExpanded, isFalse);
    final route = observer.last as PageRouteBuilder;
    final page = route.pageBuilder(
      tester.element(find.byType(VoiceOrb)),
      const AlwaysStoppedAnimation(1),
      const AlwaysStoppedAnimation(0),
    );
    expect(page, isA<FundsScreen>());
    expect((page as FundsScreen).initialPlanType, 'plus');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('exhausted upgrade routing is tier-correct', () {
    // Free → Plus, Plus → Pro, Pro → Ultra: always the NEXT plan up.
    expect(voiceUpgradePlanType(SubscriptionTier.free), 'plus');
    expect(voiceUpgradePlanType(SubscriptionTier.plus), 'pro');
    expect(voiceUpgradePlanType(SubscriptionTier.pro), 'ultra');
    // Ultra has nothing above it: no redirect at all — the exhausted orb's
    // purple visual is the whole affordance.
    expect(voiceUpgradePlanType(SubscriptionTier.ultra), isNull);
  });

  testWidgets('exhausted Plus orb opens Pro (never their own plan)', (
    tester,
  ) async {
    final input = InputProvider()..setVoiceModeActive(true);
    final voice = _OverlayVoice(
      VoiceState.failed,
      exhausted: true,
      activeSession: false,
    );
    final height = ValueNotifier<double>(80);
    final observer = _Routes();
    addTearDown(input.dispose);
    addTearDown(height.dispose);
    await _pumpOverlay(
      tester,
      input: input,
      voice: voice,
      panelHeight: height,
      active: true,
      observer: observer,
      user: _TieredVoiceUser(SubscriptionTier.plus),
    );
    await tester.tap(find.byType(VoiceOrb));
    expect(voice.startListeningCalls, 0);
    expect(input.isVoiceOverlayExpanded, isFalse);
    final route = observer.last as PageRouteBuilder;
    final page = route.pageBuilder(
      tester.element(find.byType(VoiceOrb)),
      const AlwaysStoppedAnimation(1),
      const AlwaysStoppedAnimation(0),
    );
    expect(page, isA<FundsScreen>());
    // The sheet pre-selects the plan ABOVE the one the user holds.
    expect((page as FundsScreen).initialPlanType, 'pro');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('exhausted Ultra orb opens nothing (no plan above it)', (
    tester,
  ) async {
    final input = InputProvider()..setVoiceModeActive(true);
    final voice = _OverlayVoice(
      VoiceState.failed,
      exhausted: true,
      activeSession: false,
    );
    final height = ValueNotifier<double>(80);
    final observer = _Routes();
    addTearDown(input.dispose);
    addTearDown(height.dispose);
    await _pumpOverlay(
      tester,
      input: input,
      voice: voice,
      panelHeight: height,
      active: true,
      observer: observer,
      user: _TieredVoiceUser(SubscriptionTier.ultra),
    );
    // The observer's last route BEFORE the tap is the MaterialApp's own
    // initial route; the tap must leave it untouched.
    final initialRoute = observer.last;
    await tester.tap(find.byType(VoiceOrb));
    // No route was pushed and no retry fired: Ultra has nothing to upgrade
    // to, so the tap stays on the exhausted orb's purple visual.
    expect(observer.last, same(initialRoute));
    expect(voice.startListeningCalls, 0);
    expect(input.isVoiceOverlayExpanded, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'the compact orb floats above the composer and tracks its height',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final input = InputProvider();
      final voice = _OverlayVoice(VoiceState.listening);
      final panelHeight = ValueNotifier<double>(80);
      addTearDown(input.dispose);
      addTearDown(panelHeight.dispose);

      await _pumpOverlay(
        tester,
        input: input,
        voice: voice,
        panelHeight: panelHeight,
        active: true,
      );
      expect(find.byType(VoiceOrb), findsOneWidget);
      final orb = tester.getCenter(find.byType(VoiceOrb));
      final composerTop = 800 - 80;
      expect(orb.dy, lessThan(composerTop - 10));
      expect(input.isVoiceOverlayExpanded, isFalse);

      // Attachments/edit growth: a taller composer pushes the orb upward.
      panelHeight.value = 200;
      await tester.pump(const Duration(milliseconds: 120));
      final orbTaller = tester.getCenter(find.byType(VoiceOrb));
      expect(orbTaller.dy, lessThan(orb.dy - 100));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tapping the orb expands to fullscreen and collapses back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final input = InputProvider();
    final voice = _OverlayVoice(VoiceState.listening);
    final panelHeight = ValueNotifier<double>(80);
    addTearDown(input.dispose);
    addTearDown(panelHeight.dispose);
    input.setVoiceModeActive(true);

    await _pumpOverlay(
      tester,
      input: input,
      voice: voice,
      panelHeight: panelHeight,
      active: true,
    );
    final compactCenter = tester.getCenter(find.byType(VoiceOrb));

    // The expansion controller's ticker only establishes its start time on the
    // first tick after forward(): pump once to start, once to advance through
    // the whole 420 ms expansion (pumpAndSettle is unusable — the orb's shader
    // ticker animates forever).
    await tester.tap(find.byType(VoiceOrb));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(input.isVoiceOverlayExpanded, isTrue);
    final fullCenter = tester.getCenter(find.byType(VoiceOrb));
    // The orb settled at the SafeArea's true vertical center (an inset-less
    // 800pt test surface → 400; the retired 0.40·h anchor rode high under
    // the notch on real devices).
    expect(fullCenter.dy, lessThan(compactCenter.dy - 200));
    expect((fullCenter.dy - 400).abs(), lessThan(40));

    // Tapping again collapses back to compact.
    await tester.tap(find.byType(VoiceOrb));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(input.isVoiceOverlayExpanded, isFalse);
    final backCenter = tester.getCenter(find.byType(VoiceOrb));
    expect((backCenter.dy - compactCenter.dy).abs(), lessThan(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('deactivating animates the orb away and reports completion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final input = InputProvider();
    final voice = _OverlayVoice(VoiceState.listening);
    final panelHeight = ValueNotifier<double>(80);
    addTearDown(input.dispose);
    addTearDown(panelHeight.dispose);

    var exited = false;
    await _pumpOverlay(
      tester,
      input: input,
      voice: voice,
      panelHeight: panelHeight,
      active: true,
      onExited: () => exited = true,
    );
    expect(find.byType(VoiceOrb), findsOneWidget);

    // X pressed elsewhere: the host deactivates while the exit fades.
    await _pumpOverlay(
      tester,
      input: input,
      voice: voice,
      panelHeight: panelHeight,
      active: false,
      onExited: () => exited = true,
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(exited, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'voice activation hides the capsule and immediately offers Flow/X',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final input = InputProvider();
      addTearDown(input.dispose);
      input.setVoiceModeActive(true);
      await _pumpComposerVoice(tester, input: input);

      // The field is the voice session's read-only surface: no IME, no focus.
      final field = find.byType(TextField);
      expect(field, findsOneWidget);
      final textField = tester.widget<TextField>(field);
      expect(
        textField.readOnly,
        isTrue,
        reason: 'the voice session owns the input path',
      );
      expect(
        textField.canRequestFocus,
        isFalse,
        reason: 'the keyboard may never reopen over the orb',
      );

      // The dictation mic is gone — Voice Mode owns the microphone. The button
      // stays mounted so the row's layout does not reflow, but it renders as
      // pure zero-size shrink.
      final mic = find.byType(MicButton);
      expect(mic, findsOneWidget);
      expect(
        tester.getSize(mic),
        Size.zero,
        reason: 'the mic must render at zero size during voice mode',
      );

      expect(find.byKey(const ValueKey('plus_icon')), findsNothing);
      expect(
        find.byKey(const ValueKey('flow_icon')).hitTestable(),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('voice_chat')), findsNothing);
      expect(
        find.byKey(const ValueKey('voice_exit')).hitTestable(),
        findsOneWidget,
      );

      final capsuleOpacity = tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: find.byKey(const ValueKey('composer_capsule')),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity;
      expect(capsuleOpacity, 0.0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'fullscreen hides ONLY the capsule — Flow and X remain, hittable, and exit',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final input = InputProvider();
      final voice = _OverlayVoice(VoiceState.listening);
      addTearDown(input.dispose);
      input.setVoiceModeActive(true);
      await _pumpComposerVoice(tester, input: input, voice: voice);

      input.setVoiceOverlayExpanded(true);
      await tester.pumpAndSettle();

      // ONLY the center capsule dissolves — its own scale + opacity channel.
      final capsuleOpacity = tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: find.byKey(const ValueKey('composer_capsule')),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity;
      expect(capsuleOpacity, 0.0);
      expect(find.byKey(const ValueKey('composer_capsule')), findsOneWidget);

      // The LEFT shell crossfaded into Flow INSIDE the same button: present
      // at full size and hittable — never scaled or faded away.
      final flow = find.byKey(const ValueKey('flow_icon'));
      expect(flow, findsOneWidget);
      expect(find.byKey(const ValueKey('plus_icon')), findsNothing);
      expect(find.byType(AddPhotoButton).hitTestable(), findsOneWidget);
      expect(
        tester.getSize(find.byType(AddPhotoButton)).width,
        greaterThan(30),
        reason: 'the + shell keeps its full size (no inherited shrink)',
      );

      // The RIGHT shell crossfaded into X: present and hittable.
      final x = find.byKey(const ValueKey('voice_exit'));
      expect(x, findsOneWidget);
      expect(x.hitTestable(), findsOneWidget);
      expect(
        tester.getSize(x).width,
        greaterThan(30),
        reason: 'the X shell keeps its full size (no inherited shrink)',
      );

      // Flow tap routes to the service's own toggle, exactly once.
      await tester.tap(flow);
      await tester.pumpAndSettle();
      expect(voice.toggleFlowCalls, 1);

      input.setVoiceOverlayExpanded(false);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('plus_icon')), findsNothing);
      expect(flow.hitTestable(), findsOneWidget);
      expect(x.hitTestable(), findsOneWidget);
      expect(
        tester
            .widget<Opacity>(
              find
                  .ancestor(
                    of: find.byKey(const ValueKey('composer_capsule')),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        0,
      );

      // X tears the voice session and the whole UI mode down.
      await tester.tap(x);
      await tester.pumpAndSettle();
      expect(voice.stopSessionCalls, 1);
      expect(input.isVoiceModeActive, isFalse);
      expect(input.isVoiceOverlayExpanded, isFalse);

      // Only X restores the original controls.
      expect(find.byKey(const ValueKey('plus_icon')), findsOneWidget);
      expect(find.byKey(const ValueKey('voice_chat')), findsOneWidget);
      expect(find.byKey(const ValueKey('flow_icon')), findsNothing);
      expect(find.byKey(const ValueKey('voice_exit')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'expanded overlay has no rectangular dim edge above the controls',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final input = InputProvider();
      final voice = _OverlayVoice(VoiceState.listening);
      final panelHeight = ValueNotifier<double>(80);
      addTearDown(input.dispose);
      addTearDown(panelHeight.dispose);
      input.setVoiceModeActive(true);

      await _pumpOverlay(
        tester,
        input: input,
        voice: voice,
        panelHeight: panelHeight,
        active: true,
      );
      await tester.tap(find.byType(VoiceOrb));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const ValueKey('voice_stage_dim')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the fullscreen stage carries NO text — the chat itself is the transcript',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final input = InputProvider();
      final voice = _OverlayVoice(
        VoiceState.listening,
        transcript: 'these words must never render',
      );
      final panelHeight = ValueNotifier<double>(80);
      addTearDown(input.dispose);
      addTearDown(panelHeight.dispose);
      input.setVoiceModeActive(true);

      await _pumpOverlay(
        tester,
        input: input,
        voice: voice,
        panelHeight: panelHeight,
        active: true,
      );
      await tester.tap(find.byType(VoiceOrb));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // The stage exists — dim + orb — but NOT a single Text widget: the
      // service publishes a live transcript AND remaining seconds (240),
      // and the overlay renders NEITHER. Speech lives in the normal chat
      // pipeline; the conversation behind the dim is the transcript.
      expect(find.byKey(const ValueKey('voice_stage_dim')), findsNothing);
      expect(find.byType(VoiceOrb), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(VoiceSessionOverlay),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
      expect(find.text('these words must never render'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'repeated compact/fullscreen cycles keep one orb and accumulate nothing',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final input = InputProvider();
      final voice = _OverlayVoice(VoiceState.listening);
      final panelHeight = ValueNotifier<double>(80);
      addTearDown(input.dispose);
      addTearDown(panelHeight.dispose);
      input.setVoiceModeActive(true);

      await _pumpOverlay(
        tester,
        input: input,
        voice: voice,
        panelHeight: panelHeight,
        active: true,
      );

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(VoiceOrb));
        // Two-step pump (the expansion ticker establishes its start time on
        // the first tick after forward()): start, then advance through the
        // whole 420ms expansion.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 600));
        expect(input.isVoiceOverlayExpanded, isTrue);
        expect(find.byType(VoiceOrb), findsOneWidget);

        await tester.tap(find.byType(VoiceOrb));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 600));
        expect(input.isVoiceOverlayExpanded, isFalse);
        expect(find.byType(VoiceOrb), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'entry and exit animation frames keep every opacity inside [0, 1]',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final input = InputProvider();
      final voice = _OverlayVoice(VoiceState.listening);
      final panelHeight = ValueNotifier<double>(80);
      var exits = 0;
      addTearDown(input.dispose);
      addTearDown(panelHeight.dispose);

      // Mount WITHOUT advancing the clock: the presence animation must be
      // traversed frame by frame. A single 400ms pump jumps the controller
      // to completion without ever BUILDING the easeOutBack overshoot region
      // (~80% progress, presence ≈ 1.05) — which is why the device crashed
      // on the Opacity assertion while these tests stayed green.
      await _pumpOverlay(
        tester,
        input: input,
        voice: voice,
        panelHeight: panelHeight,
        active: true,
        initialPump: Duration.zero,
      );

      // Entry: step through the whole presence animation (260ms) at frame
      // granularity, asserting every built Opacity stays in range. The old
      // easeOutBack-driven opacity crashed mid-entry here.
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 10));
        final opacities = tester
            .widgetList<Opacity>(find.byType(Opacity))
            .map((widget) => widget.opacity);
        for (final opacity in opacities) {
          expect(opacity, inInclusiveRange(0.0, 1.0));
        }
      }
      expect(tester.takeException(), isNull);

      // Exit: the reverse pass goes back through the same overshoot region
      // and reports completion to the host when fully faded.
      await _pumpOverlay(
        tester,
        input: input,
        voice: voice,
        panelHeight: panelHeight,
        active: false,
        initialPump: Duration.zero,
        onExited: () => exits++,
      );
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 10));
        expect(tester.takeException(), isNull);
      }
      expect(exits, 1, reason: 'the exit animation reports completion');
    },
  );
}

class _Internet extends ChangeNotifier implements InternetProvider {
  @override
  bool get isConnected => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The composer-side pump for the voice-lock contract (field read-only,
/// mic hidden, controls crossfaded). Mirrors the harness of
/// composer_feature_state_test.dart.
Future<void> _pumpComposerVoice(
  WidgetTester tester, {
  required InputProvider input,
  _OverlayVoice? voice,
}) async {
  final loc = await AppLocalizations.delegate.load(const Locale('en'));
  final text = TextEditingController();
  final focus = FocusNode();
  addTearDown(text.dispose);
  addTearDown(focus.dispose);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<InputProvider>.value(value: input),
        ChangeNotifierProvider<SpeechService>(create: (_) => _Speech()),
        ChangeNotifierProvider<VoiceService>.value(
          value: voice ?? _OverlayVoice(VoiceState.listening),
        ),
        ChangeNotifierProvider<ChatSessionProvider>(create: (_) => _Session()),
        ChangeNotifierProvider<InternetProvider>(create: (_) => _Internet()),
        Provider<CreditsManager>.value(value: CreditsManager.instance),
        ChangeNotifierProvider<ConversationProvider>(
          create: (_) => _Conversation(),
        ),
        Provider<SendService>(create: (_) => _Send()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: InputField(
              localizations: loc,
              isDynamicChatMode: false,
              isLimitExceeded: false,
              controller: text,
              textFieldFocusNode: focus,
              onSend: () async {},
              onApplyEditedMessage: () async {},
              isPhotoLoading: false,
              isSending: false,
              isPremiumModel: false,
              isSubscribed: false,
              userTier: SubscriptionTier.free,
              isStorageSufficient: true,
              totalCredits: 100,
              isServerSideModel: true,
              onStop: () {},
              canHandleImage: false,
              modelMissing: false,
              onCancelEditing: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _Routes extends NavigatorObserver {
  Route<dynamic>? last;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    last = route;
  }
}

class _VoiceUser extends ChangeNotifier implements UserProvider {
  _VoiceUser(this.allowance, this.usage);
  final int? allowance;
  final VoiceUsage usage;
  @override
  CreditLimits get creditLimits =>
      CreditLimits(dailyGrant: 0, debtFloor: 0, voiceDailySeconds: allowance);
  @override
  VoiceUsage get voiceUsage => usage;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A user whose ACTIVE subscription tier is [tier] — for the tier-correct
/// upgrade-routing tests. Lifetime + active keeps `effectiveTier` equal to
/// the nominal tier (see SubscriptionEntitlement.effectiveTier).
class _TieredVoiceUser extends _VoiceUser {
  _TieredVoiceUser(this.tier) : super(60, const VoiceUsage());
  final SubscriptionTier tier;
  @override
  SubscriptionEntitlement get subscription => SubscriptionEntitlement(
    tier: tier,
    mode: SubscriptionMode.lifetime,
    status: SubscriptionStatus.active,
  );
}

class _Conversation extends ChangeNotifier implements ConversationProvider {
  @override
  List<Message> get messages => [];
  @override
  bool get isWaitingForResponse => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Send implements SendService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
