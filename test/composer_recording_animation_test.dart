import 'dart:io';

import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/input.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/buttons.dart';
import 'package:cortex/chat/screen/widgets/bottom/panels/edit.dart';
import 'package:cortex/design.dart';
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
  AppLocalizations? localizations,
}) async {
  final loc =
      localizations ?? await AppLocalizations.delegate.load(const Locale('en'));
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
            isDynamicChatMode: false,
            isLimitExceeded: isLimitExceeded,
            controller: text,
            textFieldFocusNode: focus,
            onSend: onSend ?? () async {},
            onApplyEditedMessage: () async {},
            isPhotoLoading: false,
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
      // The pre-filled transcript already holds the capsule open (content
      // in the field must never fall back into the compact pill), so this
      // is the expanded width.
      final expandedFieldWidth = tester.getSize(field).width;
      expect(addPhoto, findsOneWidget);
      expect(mic, findsOneWidget);

      // Dictation starts: the "+" and the mic dim but stay put, Stop
      // takes over the action slot, and the field is covered by the
      // dictation waveform — nothing vanishes, and the already-expanded
      // capsule holds its width.
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
      expect(tester.getSize(field).width, closeTo(expandedFieldWidth, 0.5));
      expect(tester.state(find.byType(TextField)), same(originalField));
      expect(text.text, 'original draft');
      expect(tester.takeException(), isNull);

      // Dictation ends: the wave clears, dim and Stop lift, and the
      // capsule stays where it was — the transcript still holds it open.
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
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
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

      void expectEqualPadding(String hintLabel) {
        final fieldRect = tester.getRect(find.byType(TextField));
        // The decorator's own hint, sharing the field's exact style and
        // slot — vertically centered by construction, not by an overlay.
        final hintRect = tester.getRect(find.text(hintLabel));
        final topGap = hintRect.top - fieldRect.top;
        final bottomGap = fieldRect.bottom - hintRect.bottom;
        // The decorator's symmetric content padding still applies...
        expect(topGap, greaterThanOrEqualTo(7.5));
        // ...and the shared line metrics center the hint, so the gaps match.
        expect((topGap - bottomGap).abs(), lessThan(0.5));
      }

      // Collapsed capsule — the short semantic label.
      expectEqualPadding(loc.messageHintShort);

      // Expanded capsule — the full label; the field box changes width,
      // not balance.
      focus.requestFocus();
      await tester.pumpAndSettle();
      expectEqualPadding(loc.messageHint);

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

  testWidgets('caret, hint and typed text share one layout geometry',
      (tester) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
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
      focus.requestFocus();
      await tester.pumpAndSettle();

      // The field's responsive font size — the same formula the composer
      // uses.
      final base = width.clamp(0.0, 800.0);
      final double fontSize = base >= 600 ? base * 0.025 : base * 0.04;

      // The hint is the decorator's own — laid out in the editor's slot
      // with the field's exact style — and the caret is a dynamic fraction
      // of the same responsive font size: one geometry for hint, caret and
      // typed text at every screen width.
      final hint = tester.getRect(find.text(loc.messageHint));
      final editState =
          tester.state<EditableTextState>(find.byType(EditableText));
      final renderEditable = editState.renderEditable;
      final caretLocal =
          renderEditable.getLocalRectForCaret(const TextPosition(offset: 0));
      final caret = Rect.fromPoints(
        renderEditable.localToGlobal(caretLocal.topLeft),
        renderEditable.localToGlobal(caretLocal.bottomRight),
      );

      // Same origin: the caret sits immediately before the first glyph,
      // with no gap and no drift off the hint's line.
      expect((caret.left - hint.left).abs(), lessThan(1.0));
      expect((caret.top - hint.top).abs(), lessThan(2.0));
      // Shared line metrics: the caret and the hint run in one line box.
      expect((caret.height - hint.height).abs(), lessThan(2.0));
      // The stroke is a fraction of the responsive font size — never a
      // fixed fat bar — so at every screen width the bar stays a hairline.
      expect(caret.width, moreOrLessEquals(fontSize * 0.04, epsilon: 0.05));
      // Its reach past the hint's origin stays within a fraction of the
      // same responsive font size (the old fixed 2px bar reached 0.13em).
      expect(caret.right - hint.left, lessThan(fontSize * 0.07));

      // Typing lands at the exact insertion origin the hint occupies.
      text.value = const TextEditingValue(text: 'X');
      await tester.pumpAndSettle();
      final typed = tester.getRect(find.text('X'));
      expect((typed.left - hint.left).abs(), lessThan(1.0));

      await tester.pumpWidget(const SizedBox());
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('fresh load shows the collapsed composer with every control',
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
      // No focus, no feature mode, no taps — the state a cold app load
      // produces. The composer lands on stage in its collapsed capsule on
      // the very first frame: no third "absent" state, no entrance
      // animation to wait for.
      await _pumpComposer(tester, input: input, text: text, focus: focus);
      await tester.pumpAndSettle();

      // Findable (so not offstage anywhere) with real geometry, and every
      // control of the collapsed pill is hit-testable.
      final fieldFinder = find.byKey(const ValueKey('chat_input_field'));
      expect(fieldFinder, findsOneWidget);
      final collapsed = tester.getRect(fieldFinder);
      expect(collapsed.width, greaterThan(0));

      // The collapsed capsule is drawn at 85% of the share it used to fill
      // (0.68 of the reading band), floored on narrow phones where the
      // fixed control footprint — buttons, gaps, the field's own padding
      // and a 1.2em livable field — would otherwise crush the pill. The
      // expanded share is untouched, so the morph visibly grows the
      // capsule itself.
      final double available = width - 32; // readingInset is 16 at these widths
      final double buttonSize = (width * 0.086).clamp(32.0, 38.0);
      final double font = width >= 600 ? width * 0.025 : width * 0.04;
      final double minShare =
          ((8 + buttonSize + 14) + (8 + buttonSize * 2 + 4 + 14) + 6 + font * 1.2 + 12) /
              available;
      expect(
          tester
              .getRect(find.byKey(const ValueKey('composer_capsule')))
              .width,
          moreOrLessEquals(
              available * (0.68 * 0.85).clamp(minShare, 1.0),
              epsilon: 0.5));
      expect(find.byType(AddPhotoButton).hitTestable(), findsOneWidget);
      expect(find.byType(MicButton).hitTestable(), findsOneWidget);
      expect(
          find
              .byWidgetPredicate((w) =>
                  w.key is ValueKey<String> &&
                  const ['send', 'send_disabled', 'voice_chat', 'stop']
                      .contains((w.key as ValueKey<String>).value))
              .hitTestable()
              .evaluate(),
          isNotEmpty);

      // Focus expands the capsule — the one other state — and unfocusing
      // returns to the same collapsed geometry.
      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(tester.getRect(fieldFinder).width, greaterThan(collapsed.width));

      focus.unfocus();
      await tester.pumpAndSettle();
      expect(tester.getRect(fieldFinder).width,
          moreOrLessEquals(collapsed.width, epsilon: 0.5));

      // A selected feature mode expands the capsule too, and clearing it
      // collapses back — the two-state machine holds from every entry.
      input.setFeatureMode(ChatInputMode.study);
      await tester.pumpAndSettle();
      expect(tester.getRect(fieldFinder).width, greaterThan(collapsed.width));
      input.clearFeatureMode();
      await tester.pumpAndSettle();
      expect(tester.getRect(fieldFinder).width,
          moreOrLessEquals(collapsed.width, epsilon: 0.5));

      await tester.pumpWidget(const SizedBox());
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('provider churn never leaves the composer absent',
      (tester) async {
    const width = 390.0;
    tester.view.physicalSize = const Size(width, 1000);
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
    final field = find.byKey(const ValueKey('chat_input_field'));

    // Dictation churn: the live waveform animates endlessly by design, so
    // sample fixed frames while it runs instead of settling. Mid-morph and
    // settled, the composer stays on stage; no state exists in which it
    // disappears.
    input.setVoiceRecording(true);
    await tester.pump();
    expect(tester.getRect(field).width, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.getRect(field).width, greaterThan(0));
    expect(tester.takeException(), isNull);

    input.setVoiceRecording(false);
    await tester.pumpAndSettle();
    expect(tester.getRect(field).width, greaterThan(0));
    expect(tester.takeException(), isNull);

    // Feature-mode churn — the kind of flips a cold provider init can
    // emit — settles cleanly at every step.
    for (final churn in [
      () => input.setFeatureMode(ChatInputMode.study),
      () => input.clearFeatureMode(),
      () => input.setFeatureMode(ChatInputMode.offline),
      () => input.clearFeatureMode(),
    ]) {
      churn();
      await tester.pump();
      expect(tester.getRect(field).width, greaterThan(0));
      await tester.pumpAndSettle();
      expect(tester.getRect(field).width, greaterThan(0));
      expect(tester.takeException(), isNull);
    }

    // Navigation re-entry — teardown, then the panel rebuilt — lands
    // visible again, in the collapsed geometry.
    await tester.pumpWidget(const SizedBox());
    await _pumpComposer(tester, input: input, text: text, focus: focus);
    await tester.pumpAndSettle();
    expect(field, findsOneWidget);
    expect(tester.getRect(field).width, greaterThan(0));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'placeholder morphs between the two semantic labels with an anchored fade',
      (tester) async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
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

    final double fontSize = 390.0 * 0.04;
    final shortFinder = find.text(loc.messageHintShort);
    final fullFinder = find.text(loc.messageHint);

    // Collapsed: the short label at its normal intended size — rendered by
    // the decorator's own hint slot, never scaled, fitted or ellipsized.
    expect(shortFinder, findsOneWidget);
    expect(fullFinder, findsNothing);
    final shortText = tester.widget<Text>(shortFinder);
    expect(shortText.style!.fontSize, fontSize);
    expect(shortText.maxLines, 1);
    expect(shortText.overflow, isNot(TextOverflow.ellipsis));
    expect(
        find.descendant(
            of: find.byType(TextField), matching: find.byType(FittedBox)),
        findsNothing);

    // Expanding cross-fades to the full label on a shared start edge:
    // mid-transition both labels are on stage, pinned to the same left
    // origin, so the visible effect is the trailing portion fading in
    // beside an unmoving "Ask".
    focus.requestFocus();
    await tester.pump(); // builds the expanded state, starts the cross-fade
    await tester.pump(); // the cross-fade ticker's first frame (zero elapsed)
    await tester.pump(const Duration(milliseconds: 125)); // mid-fade
    final midShort = tester.getRect(shortFinder);
    final midFull = tester.getRect(fullFinder);
    expect(midFull.left, closeTo(midShort.left, 0.5));
    final fades = tester.widgetList<FadeTransition>(
        find.ancestor(of: fullFinder, matching: find.byType(FadeTransition)));
    expect(fades.any((f) => f.opacity.value > 0.0 && f.opacity.value < 1.0),
        isTrue);

    await tester.pumpAndSettle();
    expect(shortFinder, findsNothing);
    expect(fullFinder, findsOneWidget);
    final fullText = tester.widget<Text>(fullFinder);
    expect(fullText.style!.fontSize, fontSize);
    expect(fullText.overflow, isNot(TextOverflow.ellipsis));

    // Collapsing reverses the transition back to the short label.
    focus.unfocus();
    await tester.pumpAndSettle();
    expect(shortFinder, findsOneWidget);
    expect(fullFinder, findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a placeholder wider than the pill dissolves into right-edge fog',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final endFog = find.byKey(const ValueKey('hint_fog_end'));
    final startFog = find.byKey(const ValueKey('fog_start'));

    // The placeholder's strips carry their own keys: the dictation wave's
    // fog owns the plain 'fog_start'/'fog_end' pair, so the wave tests stay
    // unambiguous even when the placeholder fog is mounted.

    // English fits in both states — no fog is ever mounted. The negative
    // check runs at a roomy 800px width: the test font draws every glyph
    // one em wide, so at 320 the full expanded label genuinely clips in
    // tests even though the real proportional font fits.
    final input = InputProvider();
    final text = TextEditingController();
    final focus = FocusNode();
    addTearDown(input.dispose);
    addTearDown(text.dispose);
    addTearDown(focus.dispose);
    await _pumpComposer(tester, input: input, text: text, focus: focus);
    await tester.pumpAndSettle();
    expect(endFog, findsNothing);
    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(endFog, findsNothing);
    await tester.pumpWidget(const SizedBox());

    // Narrow viewport for the overflow legs below.
    tester.view.physicalSize = const Size(320, 1000);

    // Czech's short label ("Zeptejte se") is wider than the collapsed
    // pill's content box: instead of a hard clip the label dissolves into
    // the field's own right-edge fog — painted, contained, never hit.
    final csInput = InputProvider();
    final csText = TextEditingController();
    final csFocus = FocusNode();
    addTearDown(csInput.dispose);
    addTearDown(csText.dispose);
    addTearDown(csFocus.dispose);
    final csLoc = await AppLocalizations.delegate.load(const Locale('cs'));
    await _pumpComposer(tester,
        input: csInput, text: csText, focus: csFocus, localizations: csLoc);
    await tester.pumpAndSettle();
    expect(find.text(csLoc.messageHintShort), findsOneWidget);
    final fieldRect = tester.getRect(find.byType(TextField));
    final fogRect = tester.getRect(endFog);
    expect(fogRect.right, lessThanOrEqualTo(fieldRect.right + 0.5));
    expect(fogRect.left, greaterThan(fieldRect.left));
    expect(endFog.hitTestable(), findsNothing);
    expect(startFog, findsNothing);
    await tester.pumpWidget(const SizedBox());

    // Portuguese's full label ("Pergunte qualquer coisa") is wider than
    // even the expanded capsule's content box, and typing lifts the fog.
    final ptInput = InputProvider();
    final ptText = TextEditingController();
    final ptFocus = FocusNode();
    addTearDown(ptInput.dispose);
    addTearDown(ptText.dispose);
    addTearDown(ptFocus.dispose);
    final ptLoc = await AppLocalizations.delegate.load(const Locale('pt'));
    await _pumpComposer(tester,
        input: ptInput, text: ptText, focus: ptFocus, localizations: ptLoc);
    await tester.pumpAndSettle();
    ptFocus.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text(ptLoc.messageHint), findsOneWidget);
    expect(endFog, findsOneWidget);
    await tester.enterText(find.byType(TextField), 'olá');
    await tester.pumpAndSettle();
    expect(endFog, findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  // Regression: SizeTransition's vertical-axis default alignment is
  // AlignmentDirectional(-1, 0), which presses a child narrower than the
  // bar to the start edge. The edit banner is capsule-width, so it must
  // defend its own centering — exactly over the expanded capsule, never
  // flush against the left edge of the control bar.
  testWidgets('edit banner hugs the capsule and stays centered over the bar',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AnimationController(
        vsync: tester, duration: const Duration(milliseconds: 300));
    addTearDown(controller.dispose);
    final sizeFactor =
        CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    final fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    // Mirrors bottom.dart: a plain SizeTransition with the default
    // (start-pressing) alignment wrapping the banner inside the bottom bar.
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: SizeTransition(
            sizeFactor: sizeFactor,
            axis: Axis.vertical,
            child: EditPanelWidget(
                slideAnimation: slide, fadeAnimation: fade, onCancel: () {}),
          ),
        ),
      ),
    ));
    controller.forward();
    await tester.pumpAndSettle();

    final banner = tester.getRect(find.byKey(const ValueKey('edit_banner')));
    final double inset = CortexDesign.readingInset(390) +
        composerCapsuleInset(390, expanded: true);
    // Same width as the expanded capsule…
    expect(banner.width, closeTo(390 - 2 * inset, 0.5));
    // …and centered on it, never pressed to the bar's start edge.
    expect(banner.left, closeTo(inset, 0.5));
    expect(banner.right, closeTo(390 - inset, 0.5));
  });

  // Regression: the banner needs breathing room over the composer capsule
  // below it. The panel's total height must exceed the banner by a visible
  // proportional gap, and that gap must sit strictly BELOW the banner — it
  // rides inside the panel's SizeTransition, so it collapses away with the
  // banner and never lingers once edit mode closes.
  testWidgets('edit banner keeps breathing room above the composer capsule',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AnimationController(
        vsync: tester, duration: const Duration(milliseconds: 300));
    addTearDown(controller.dispose);
    final sizeFactor =
        CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    final fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(
          // Mirrors bottom.dart: the panel column hands the SizeTransition
          // an unbounded height, so the panel shrink-wraps to its natural
          // (banner + gap) height instead of stretching to the screen.
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizeTransition(
              sizeFactor: sizeFactor,
              axis: Axis.vertical,
              child: EditPanelWidget(
                  slideAnimation: slide, fadeAnimation: fade, onCancel: () {}),
            ),
          ],
        ),
      ),
    ));
    controller.forward();
    await tester.pumpAndSettle();

    final banner = tester.getRect(find.byKey(const ValueKey('edit_banner')));
    final panel = tester.getRect(find.byType(EditPanelWidget));
    final double expectedGap = 1000 * 0.015; // phone: screenHeight * 0.015
    // A visible gap between the banner and the capsule below it…
    expect(panel.height - banner.height, closeTo(expectedGap, 0.5));
    // …placed strictly below the banner: the banner tops the panel.
    expect(banner.top, closeTo(panel.top, 0.5));
  });

  // Regression: content must never fall back into the compact pill. Text
  // sitting in the field — or a running dictation wave — keeps the
  // capsule and the input field expanded even without focus; only once
  // the text is gone and nothing else holds it open may it collapse
  // back into the resting pill.
  testWidgets('text or dictation holds the capsule open without focus',
      (tester) async {
    final input = InputProvider();
    final text = TextEditingController();
    final focus = FocusNode();
    addTearDown(input.dispose);
    addTearDown(text.dispose);
    addTearDown(focus.dispose);
    await _pumpComposer(tester, input: input, text: text, focus: focus);
    await tester.pumpAndSettle();

    final fieldFinder = find.byKey(const ValueKey('chat_input_field'));
    final collapsed = tester.getRect(fieldFinder);

    // Focusing expands the capsule…
    focus.requestFocus();
    await tester.pumpAndSettle();
    final expanded = tester.getRect(fieldFinder);
    expect(expanded.width, greaterThan(collapsed.width));

    // …and unfocusing while the words are still in the field must not
    // shrink it back into the pill.
    text.value = const TextEditingValue(text: 'hello cortex');
    await tester.pumpAndSettle();
    focus.unfocus();
    await tester.pumpAndSettle();
    expect(tester.getRect(fieldFinder).width, closeTo(expanded.width, 0.5));

    // Words alone — the field never focused at all — hold it open too.
    text.value = const TextEditingValue(text: '');
    await tester.pumpAndSettle();
    expect(tester.getRect(fieldFinder).width, closeTo(collapsed.width, 0.5));
    text.value = const TextEditingValue(text: 'hello cortex');
    await tester.pumpAndSettle();
    expect(tester.getRect(fieldFinder).width, closeTo(expanded.width, 0.5));
    text.value = const TextEditingValue(text: '');
    await tester.pumpAndSettle();

    // An empty field still expands for a running dictation wave —
    // bounded pumps, the waveform owns an endless ticker.
    input.setVoiceRecording(true);
    await tester.pump(); // mounts the dictation frame; starts forward() post-frame
    await tester.pump(); // the expand ticker's first frame, still zero elapsed
    await tester
        .pump(const Duration(milliseconds: 300)); // carries the morph to its end
    expect(tester.getRect(fieldFinder).width, closeTo(expanded.width, 0.5));

    // Dictation ends with nothing in the field: back to the resting pill.
    input.setVoiceRecording(false);
    await tester.pumpAndSettle();
    expect(tester.getRect(fieldFinder).width, closeTo(collapsed.width, 0.5));
    expect(tester.takeException(), isNull);
  });

  // Regression: the attachment strip reveals on fade + motion together (one
  // quicker 200ms clock), and static EdgeFogs frame its far ends so a long
  // strip dissolves into the background instead of looking cut off.
  testWidgets('attachment strip reveals with fade, motion and edge fogs',
      (tester) async {
    final input = InputProvider();
    final text = TextEditingController();
    final focus = FocusNode();
    addTearDown(input.dispose);
    addTearDown(text.dispose);
    addTearDown(focus.dispose);
    await _pumpComposer(tester, input: input, text: text, focus: focus);
    await tester.pumpAndSettle();

    // The visible strip is the reveal box itself: SizeTransition clips its
    // child, so the child's own rect stays at full height mid-flight while
    // this box truly reflects what is on screen.
    final stripBox = find.byKey(const ValueKey('attachment_strip_reveal'));
    // Empty strip: fully collapsed.
    expect(tester.getRect(stripBox).height, 0.0);

    // The provider only needs a path to book-keep the slot; the preview
    // paints its fallback shell immediately and the image bytes never
    // load in the test VM (fake-async), which none of the geometry below
    // cares about. Creating real bytes would need `tester.runAsync`, and
    // plain `File.writeAsBytes` would deadlock the fake clock.
    input.addAttachment(
        File('${Directory.systemTemp.path}/cortex_attachment_test.png'),
        isImage: true);
    await tester.pump(); // the reveal clock starts
    // Mid-flight: the strip is growing AND dissolving in at once.
    await tester.pump(const Duration(milliseconds: 100));
    final stripFade = find.byKey(const ValueKey('attachment_strip_fade'));
    expect(stripFade, findsOneWidget);
    final halfIn = tester.widget<FadeTransition>(stripFade).opacity.value;
    expect(halfIn, greaterThan(0.0));
    expect(halfIn, lessThan(1.0));
    final midHeight = tester.getRect(stripBox).height;
    expect(midHeight, greaterThan(0.0));

    // Settled: fully grown, fully opaque, framed by both static fogs.
    await tester.pumpAndSettle();
    expect(tester.widget<FadeTransition>(stripFade).opacity.value, 1.0);
    final strip = tester.getRect(stripBox);
    expect(strip.height, greaterThan(midHeight));
    final startFog = find.byKey(const ValueKey('attachment_fog_start'));
    final endFog = find.byKey(const ValueKey('attachment_fog_end'));
    expect(startFog, findsOneWidget);
    expect(endFog, findsOneWidget);
    expect(tester.getRect(startFog).width, 24.0);
    expect(tester.getRect(endFog).width, 24.0);
    expect(tester.getRect(startFog).left, closeTo(strip.left, 0.5));
    expect(tester.getRect(endFog).right, closeTo(strip.right, 0.5));

    // Removing the last attachment collapses the strip back out.
    input.removeAttachmentAt(0);
    await tester.pumpAndSettle();
    expect(tester.getRect(stripBox).height, 0.0);
    expect(tester.widget<FadeTransition>(stripFade).opacity.value, 0.0);
    expect(tester.takeException(), isNull);
  });

  // Regression: the banner must fade in and out in lockstep with its slide —
  // one clock, two effects — so it glides up while dissolving in and glides
  // down while dissolving out, on the quicker 200ms ride.
  testWidgets('edit banner fades in and out with its slide', (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AnimationController(
        vsync: tester, duration: const Duration(milliseconds: 200));
    addTearDown(controller.dispose);
    final sizeFactor =
        CurvedAnimation(parent: controller, curve: Curves.easeOut);
    final slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    final fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: SizeTransition(
            sizeFactor: sizeFactor,
            axis: Axis.vertical,
            child: EditPanelWidget(
              slideAnimation: slide,
              fadeAnimation: fade,
              onCancel: () {},
            ),
          ),
        ),
      ),
    ));

    // The banner's own fade — keyed so the dismissed FadeTransitions hidden
    // deeper inside LiquidGlassPanel can't shadow it in finder order.
    final bannerFade = find.byKey(const ValueKey('edit_banner_fade'));

    // Halfway in: the banner is riding up AND dissolving in at once.
    controller.forward();
    await tester.pump(); // the ticker's first tick lands with zero elapsed
    await tester.pump(const Duration(milliseconds: 100));
    final halfIn = tester.widget<FadeTransition>(bannerFade).opacity.value;
    expect(halfIn, greaterThan(0.0));
    expect(halfIn, lessThan(1.0));
    await tester.pumpAndSettle();
    expect(tester.widget<FadeTransition>(bannerFade).opacity.value, 1.0);

    // Halfway out: still dissolving, never blinking off.
    controller.reverse();
    await tester.pump(); // same: the reverse ride starts at zero elapsed
    await tester.pump(const Duration(milliseconds: 100));
    final halfOut = tester.widget<FadeTransition>(bannerFade).opacity.value;
    expect(halfOut, greaterThan(0.0));
    expect(halfOut, lessThan(1.0));
    await tester.pumpAndSettle();
    expect(tester.widget<FadeTransition>(bannerFade).opacity.value, 0.0);
    expect(tester.takeException(), isNull);
  });
}