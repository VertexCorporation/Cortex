import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/input.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/buttons.dart';
import 'package:cortex/chat/screen/widgets/wave.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/server/subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Speech extends ChangeNotifier implements SpeechService {
  @override
  bool get isListening => true;
  @override
  bool get isDeviceSupported => true;
  @override
  double get soundLevel => 0;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Voice extends ChangeNotifier implements VoiceService {
  @override
  VoiceState get state => VoiceState.idle;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends ChangeNotifier implements ChatSessionProvider {
  _Session({this.localModelLoaded = false});

  final bool localModelLoaded;

  @override
  ModelEntity? get selectedModel => null;
  @override
  bool get isLocalModelLoaded => localModelLoaded;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Internet extends ChangeNotifier implements InternetProvider {
  @override
  bool get isConnected => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// True when [button]'s subtree contains an [Opacity] gate at 40% — the
/// shared "dimmed but visible" treatment used while dictation runs.
bool _isDimmed(Finder button, WidgetTester tester) => tester
    .widgetList<Opacity>(
        find.descendant(of: button, matching: find.byType(Opacity)))
    .any((gate) => gate.opacity == 0.4);

Future<void> _pumpComposer(
  WidgetTester tester, {
  required InputProvider input,
  required TextEditingController text,
  required FocusNode focus,
  bool isLimitExceeded = true,
  bool isLocalModelLoaded = false,
  Future<void> Function()? onSend,
}) async {
  final loc = await AppLocalizations.delegate.load(const Locale('en'));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<InputProvider>.value(value: input),
      ChangeNotifierProvider<SpeechService>(create: (_) => _Speech()),
      ChangeNotifierProvider<VoiceService>(create: (_) => _Voice()),
      ChangeNotifierProvider<ChatSessionProvider>(
          create: (_) => _Session(localModelLoaded: isLocalModelLoaded)),
      ChangeNotifierProvider<InternetProvider>(create: (_) => _Internet()),
      // The real singleton's neutral state is "open" (full access band), so
      // the send/action gates pass without any Firestore wiring.
      Provider<CreditsManager>.value(value: CreditsManager.instance),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: InputField(
            localizations: loc,
            isModelSelected: true,
            isDynamicChatMode: false,
            isLimitExceeded: isLimitExceeded,
            controller: text,
            textFieldFocusNode: focus,
            onSend: onSend ?? () async {},
            onApplyEditedMessage: () async {},
            isPhotoLoading: false,
            slideAnimation: const AlwaysStoppedAnimation(Offset.zero),
            fadeAnimation: const AlwaysStoppedAnimation(1),
            isSending: false,
            isPremiumModel: false,
            isSubscribed: false,
            userTier: SubscriptionTier.free,
            isStorageSufficient: true,
            totalCredits: 0,
            isServerSideModel: false,
            onStop: () {},
            canHandleImage: false,
            modelMissing: false,
            onCancelEditing: () {},
          ),
        ),
      ),
    ),
  ));
}

void main() {
  for (final width in [320.0, 390.0, 800.0]) {
    testWidgets('dictation keeps the composer in place at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final input = InputProvider();
      final text = TextEditingController(text: 'original draft');
      final focus = FocusNode();
      addTearDown(input.dispose);
      addTearDown(text.dispose);
      addTearDown(focus.dispose);
      await _pumpComposer(tester, input: input, text: text, focus: focus);
      await tester.pumpAndSettle();

      final addPhoto = find.byType(AddPhotoButton);
      final mic = find.byType(MicButton);
      final field = find.byType(TextField);
      final originalField = tester.state(find.byType(TextField));
      final collapsedFieldWidth = tester.getSize(field).width;
      expect(addPhoto, findsOneWidget);
      expect(mic, findsOneWidget);

      // Dictation starts: the capsule morphs wider, the "+" and the mic
      // dim but stay put, Stop takes over the action slot, and the field
      // is covered by the dictation waveform — nothing vanishes.
      input.setVoiceRecording(true);
      // The waveform runs its own ticker, so pumpAndSettle would spin
      // forever while dictation runs; bounded pumps carry the 250ms
      // capsule morph and the sheet's fade instead.
      // forward() is started from a post-frame callback, so the ticker's
      // first frame is consumed capturing its start time (zero elapsed) —
      // one extra bounded frame must run before the 250ms advance.
      await tester.pump(); // mounts the dictation frame; starts forward() post-frame
      await tester.pump(); // the expand ticker's first frame, still zero elapsed
      await tester.pump(const Duration(milliseconds: 300)); // carries the morph to its end
      expect(addPhoto, findsOneWidget);
      expect(mic, findsOneWidget);
      expect(_isDimmed(addPhoto, tester), isTrue);
      expect(_isDimmed(mic, tester), isTrue);
      expect(find.byKey(const ValueKey('stop')), findsOneWidget);
      expect(find.byType(WaveformVisualizer), findsOneWidget);
      expect(tester.getSize(field).width, greaterThan(collapsedFieldWidth));
      expect(tester.state(find.byType(TextField)), same(originalField));
      expect(text.text, 'original draft');
      expect(tester.takeException(), isNull);

      // Dictation ends: the wave clears, dim and Stop lift, and the
      // capsule settles back.
      input.setVoiceRecording(false);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('stop')), findsNothing);
      expect(find.byType(WaveformVisualizer), findsNothing);
      expect(_isDimmed(addPhoto, tester), isFalse);
      expect(_isDimmed(mic, tester), isFalse);
      expect(tester.state(find.byType(TextField)), same(originalField));
      expect(text.text, 'original draft');
      expect(tester.takeException(), isNull);
    });

    testWidgets('rapid dictation toggles do not destabilise the composer',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final input = InputProvider();
      final text = TextEditingController(text: 'original draft');
      final focus = FocusNode();
      addTearDown(input.dispose);
      addTearDown(text.dispose);
      addTearDown(focus.dispose);
      await _pumpComposer(tester, input: input, text: text, focus: focus);
      await tester.pumpAndSettle();

      // Interrupted expand/collapse reversals mid-flight, not just the
      // endpoints: the capsule animation must restart cleanly every time.
      for (var i = 0; i < 8; i++) {
        input.setVoiceRecording(i.isEven);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 73));
        expect(tester.takeException(), isNull);
      }
      input.setVoiceRecording(false);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(text.text, 'original draft');
      expect(find.byKey(const ValueKey('stop')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('detached bubbles stay tappable when expanded at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final input = InputProvider();
      final text = TextEditingController();
      final focus = FocusNode();
      addTearDown(input.dispose);
      addTearDown(text.dispose);
      addTearDown(focus.dispose);
      await _pumpComposer(tester, input: input, text: text, focus: focus);
      await tester.pumpAndSettle();

      // Collapsed: the bubbles live inside the capsule — trivially tappable.
      expect(find.byType(AddPhotoButton).hitTestable(), findsOneWidget);

      // Expanded: the "+" and action bubbles ride OUTSIDE the painted capsule
      // border, but their full visible area must stay inside the hit-test
      // region (visible area == tappable area).
      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(find.byType(AddPhotoButton).hitTestable(), findsOneWidget);
      expect(find.byType(MicButton).hitTestable(), findsOneWidget);
      expect(find.byType(TextField).hitTestable(), findsOneWidget);
      // Empty text + supported device → voice-chat empty state.
      expect(find.byKey(const ValueKey('voice_chat')).hitTestable(),
          findsOneWidget);

      // Collapsing back must keep them tappable as well.
      focus.unfocus();
      await tester.pumpAndSettle();
      expect(find.byType(AddPhotoButton).hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('detached bubbles are tappable mid-animation and right after it',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final input = InputProvider();
    final text = TextEditingController();
    final focus = FocusNode();
    addTearDown(input.dispose);
    addTearDown(text.dispose);
    addTearDown(focus.dispose);
    await _pumpComposer(tester, input: input, text: text, focus: focus);
    await tester.pumpAndSettle();

    focus.requestFocus();
    await tester.pump(); // frame that starts the 250ms expansion
    await tester.pump(const Duration(milliseconds: 125)); // mid-morph
    expect(find.byType(AddPhotoButton).hitTestable(), findsOneWidget);
    expect(find.byType(MicButton).hitTestable(), findsOneWidget);
    expect(find.byKey(const ValueKey('voice_chat')).hitTestable(),
        findsOneWidget);

    // And immediately once the morph settles.
    await tester.pumpAndSettle();
    expect(find.byType(AddPhotoButton).hitTestable(), findsOneWidget);
    expect(find.byKey(const ValueKey('voice_chat')).hitTestable(),
        findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping the detached action bubble sends the typed message',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final input = InputProvider();
    final text = TextEditingController();
    final focus = FocusNode();
    int sent = 0;
    addTearDown(input.dispose);
    addTearDown(text.dispose);
    addTearDown(focus.dispose);
    await _pumpComposer(
      tester,
      input: input,
      text: text,
      focus: focus,
      isLimitExceeded: false,
      isLocalModelLoaded: true,
      onSend: () async => sent++,
    );
    await tester.pumpAndSettle();

    // Tapping the field focuses it and expands the capsule.
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);

    // Typing switches the action bubble to Send; it must remain fully
    // hit-testable while detached outside the painted capsule border.
    await tester.enterText(find.byType(TextField), 'hello from the row');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('send')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('send')).hitTestable(), findsOneWidget);

    // Tapping the detached bubble must reach the send handler.
    await tester.tap(find.byKey(const ValueKey('send')));
    await tester.pump();
    expect(sent, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dictation waveform takes over the field slot and clears on stop',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final input = InputProvider();
    final text = TextEditingController();
    final focus = FocusNode();
    addTearDown(input.dispose);
    addTearDown(text.dispose);
    addTearDown(focus.dispose);
    await _pumpComposer(tester, input: input, text: text, focus: focus);
    await tester.pumpAndSettle();

    // No dictation, no wave.
    expect(find.byType(WaveformVisualizer), findsNothing);

    input.setVoiceRecording(true);
    await tester.pump(); // the sheet mounts and starts fading in
    expect(find.byType(WaveformVisualizer), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 125)); // mid-fade
    expect(find.byType(WaveformVisualizer), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 125)); // fade complete
    expect(find.byType(WaveformVisualizer), findsOneWidget);

    // The sheet spans the field's own box, so the wave lives inside the
    // capsule border and never reaches the detached bubbles.
    final fieldRect = tester.getRect(find.byType(TextField));
    final waveRect = tester.getRect(find.byType(WaveformVisualizer));
    expect(waveRect.left, greaterThanOrEqualTo(fieldRect.left));
    expect(waveRect.right, lessThanOrEqualTo(fieldRect.right));
    expect(waveRect.top, closeTo(fieldRect.top, 0.5));
    expect(waveRect.bottom, closeTo(fieldRect.bottom, 0.5));

    input.setVoiceRecording(false);
    await tester.pump(); // starts the exit fade
    await tester.pumpAndSettle(); // finishes it and disposes the ticker
    expect(find.byType(WaveformVisualizer), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final width in [320.0, 390.0, 800.0]) {
    testWidgets('dictation wave dissolves into symmetric fog at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final input = InputProvider();
      final text = TextEditingController();
      final focus = FocusNode();
      addTearDown(input.dispose);
      addTearDown(text.dispose);
      addTearDown(focus.dispose);
      await _pumpComposer(tester, input: input, text: text, focus: focus);
      await tester.pumpAndSettle();

      // No fog while the user is simply typing — the effect belongs to
      // dictation alone.
      expect(find.byKey(const ValueKey('fog_start')), findsNothing);
      expect(find.byKey(const ValueKey('fog_end')), findsNothing);

      input.setVoiceRecording(true);
      // The waveform runs its own ticker, so pumpAndSettle would spin
      // forever while dictation runs; bounded pumps carry the 250ms
      // capsule morph and the sheet's fade instead.
      // forward() is started from a post-frame callback, so the ticker's
      // first frame is consumed capturing its start time (zero elapsed) —
      // one extra bounded frame must run before the 300ms advance.
      await tester.pump(); // mounts the dictation frame; starts forward() post-frame
      await tester.pump(); // the expand ticker's first frame, still zero elapsed
      await tester
          .pump(const Duration(milliseconds: 300)); // carries the morph to its end

      final fieldRect = tester.getRect(find.byType(TextField));
      final startFog =
          tester.getRect(find.byKey(const ValueKey('fog_start')));
      final endFog = tester.getRect(find.byKey(const ValueKey('fog_end')));

      // Contained: both strips live inside the field's box — the fog can
      // never bleed outside the input capsule.
      expect(startFog.left, greaterThanOrEqualTo(fieldRect.left));
      expect(startFog.right, lessThanOrEqualTo(fieldRect.right));
      expect(endFog.left, greaterThanOrEqualTo(fieldRect.left));
      expect(endFog.right, lessThanOrEqualTo(fieldRect.right));

      // Symmetric: equal strips at mirrored insets, with the wave fully
      // visible in a window centered on the field.
      expect(startFog.width, endFog.width);
      expect(startFog.left - fieldRect.left,
          closeTo(fieldRect.right - endFog.right, 0.5));
      expect(endFog.left, greaterThan(startFog.right));
      expect((startFog.right + endFog.left) / 2,
          closeTo(fieldRect.center.dx, 0.5));

      // Painted, never hit: the strips must not intercept pointers, and
      // Stop — the way out of dictation — stays reachable.
      expect(find.byKey(const ValueKey('fog_start')).hitTestable(),
          findsNothing);
      expect(
          find.byKey(const ValueKey('fog_end')).hitTestable(), findsNothing);
      expect(find.byKey(const ValueKey('stop')).hitTestable(),
          findsOneWidget);

      // Dictation ends and the fog leaves with the sheet.
      input.setVoiceRecording(false);
      await tester.pump(); // starts the exit fade
      await tester.pumpAndSettle(); // finishes it and disposes the ticker
      expect(find.byKey(const ValueKey('fog_start')), findsNothing);
      expect(find.byKey(const ValueKey('fog_end')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('hint sits with equal padding above and below the text',
      (tester) async {
    for (final width in [320.0, 390.0, 800.0]) {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      final input = InputProvider();
      final text = TextEditingController();
      final focus = FocusNode();
      addTearDown(input.dispose);
      addTearDown(text.dispose);
      addTearDown(focus.dispose);
      await _pumpComposer(tester, input: input, text: text, focus: focus);
      await tester.pumpAndSettle();

      void expectEqualPadding() {
        final fieldRect = tester.getRect(find.byType(TextField));
        final hintRect =
            tester.getRect(find.byKey(const ValueKey('hint_overlay')));
        final topGap = hintRect.top - fieldRect.top;
        final bottomGap = fieldRect.bottom - hintRect.bottom;
        // The decorator's symmetric content padding still applies...
        expect(topGap, greaterThanOrEqualTo(7.5));
        // ...and the overlay centers the hint, so the two gaps match.
        expect((topGap - bottomGap).abs(), lessThan(0.5));
      }

      // Collapsed capsule.
      expectEqualPadding();

      // Expanded capsule — the field box changes width, not balance.
      focus.requestFocus();
      await tester.pumpAndSettle();
      expectEqualPadding();

      focus.unfocus();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('dictation toggles stay stable with semantics enabled',
      (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final input = InputProvider();
    final text = TextEditingController();
    final focus = FocusNode();
    addTearDown(input.dispose);
    addTearDown(text.dispose);
    addTearDown(focus.dispose);
    await _pumpComposer(tester, input: input, text: text, focus: focus);
    await tester.pumpAndSettle();

    // A live semantics owner walks the whole tree on every toggle — the
    // regime in which the child/parent render-object assertion fired on
    // device. The composer must toggle cleanly inside it, mid-animation
    // included.
    for (var i = 0; i < 3; i++) {
      input.setVoiceRecording(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150)); // mid-morph
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      input.setVoiceRecording(false);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    // Disposed explicitly in the body: the harness verifies handles at the
    // end of the test body, before addTearDown callbacks would run.
    semantics.dispose();
  });

  testWidgets('PROBE caret hint geometry', (tester) async {
    for (final width in [320.0, 390.0, 800.0]) {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final input = InputProvider();
      final text = TextEditingController();
      final focus = FocusNode();
      addTearDown(input.dispose);
      addTearDown(text.dispose);
      addTearDown(focus.dispose);
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await _pumpComposer(tester, input: input, text: text, focus: focus);
      await tester.pumpAndSettle();

      final hintCollapsed =
          tester.getRect(find.byKey(const ValueKey('hint_overlay')));

      focus.requestFocus();
      await tester.pumpAndSettle();

      final editState =
          tester.state<EditableTextState>(find.byType(EditableText));
      final renderEditable = editState.renderEditable;
      final caretLocal =
          renderEditable.getLocalRectForCaret(const TextPosition(offset: 0));
      final caretGlobal = Rect.fromPoints(
        renderEditable.localToGlobal(caretLocal.topLeft),
        renderEditable.localToGlobal(caretLocal.bottomRight),
      );
      final editorOrigin = renderEditable.localToGlobal(Offset.zero);
      final hintExpanded =
          tester.getRect(find.byKey(const ValueKey('hint_overlay')));
      final fieldRect = tester.getRect(find.byType(TextField));
      final base = width.clamp(0.0, 600.0);
      final fontSize = base >= 600 ? base * 0.025 : base * 0.04;
      final tp = TextPainter(
        text: TextSpan(
            text: loc.messageHint, style: TextStyle(fontSize: fontSize)),
        textDirection: TextDirection.ltr,
      )..layout();

      text.value = const TextEditingValue(text: 'X');
      await tester.pumpAndSettle();
      final typedRect = tester.getRect(find.text('X'));

      debugPrint('PROBE w=$width fontSize=$fontSize natural=${tp.width.toStringAsFixed(1)} '
          'hintCollapsed=$hintCollapsed hintExpanded=$hintExpanded '
          'scale=${(hintExpanded.width / tp.width).toStringAsFixed(3)} '
          'caret=$caretGlobal editorOrigin=$editorOrigin field=$fieldRect typedX=$typedRect');

      await tester.pumpWidget(const SizedBox());
    }
  });
}