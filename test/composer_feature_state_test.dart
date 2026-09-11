// test/composer_feature_state_test.dart
//
// The composer ACTIVE-STATE matrix (issue: "send/+ buttons disappear on
// feature toggle / focus change; feature-selected mode must keep the
// composer an ACTIVE composer").
//
// Contract under test (lib/chat/screen/widgets/bottom/input/input.dart):
//
//   isComposerExpanded = focus || dictation || text-in-field || FEATURE MODE
//
// A selected generation feature (image/video/audio/offline/reasoning — the
// "+" button shows the selected state) IS composer content/state: the
// capsule stays expanded and every control stays mounted with an EMPTY field
// and NO keyboard focus, and the state re-syncs when the feature is toggled
// WITHOUT any route transition (model-change rewrites, post-send clears) —
// the pre-fix gap that left the capsule's expansion stale.
//
// The send button follows its own content rule (text or attachments) — it
// stays VISIBLE for a feature-selected empty composer, which is what the
// incident requires: nothing may vanish.
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/buttons.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/input.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/credits.dart';
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

Future<void> _pumpComposer(
  WidgetTester tester, {
  required InputProvider input,
  required TextEditingController text,
  required FocusNode focus,
  Future<void> Function()? onSend,
}) async {
  final loc = await AppLocalizations.delegate.load(const Locale('en'));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<InputProvider>.value(value: input),
      ChangeNotifierProvider<SpeechService>(create: (_) => _Speech()),
      ChangeNotifierProvider<VoiceService>(create: (_) => _Voice()),
      ChangeNotifierProvider<ChatSessionProvider>(
          create: (_) => _Session(localModelLoaded: true)),
      ChangeNotifierProvider<InternetProvider>(create: (_) => _Internet()),
      Provider<CreditsManager>.value(value: CreditsManager.instance),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: InputField(
            localizations: loc,
            isDynamicChatMode: false,
            isLimitExceeded: false,
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
            isServerSideModel: true,
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
  testWidgets('a selected feature keeps the composer ACTIVE with an empty field and no focus — nothing vanishes', (tester) async {
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

    final field = find.byType(TextField);
    final addPhoto = find.byType(AddPhotoButton);
    final collapsedWidth = tester.getSize(field).width;

    // The feature is selected OUTSIDE any sheet/route transition — the
    // composer must re-evaluate from the provider notification itself.
    input.setFeatureMode(ChatInputMode.imageGeneration);
    await tester.pumpAndSettle();

    // The capsule is expanded: a selected feature IS composer state.
    expect(tester.getSize(field).width, greaterThan(collapsedWidth));
    // The + button stays present with the selected state.
    expect(addPhoto, findsOneWidget);
    // Nothing disappeared and no render/semantics assertion fired.
    expect(tester.takeException(), isNull);

    // Focus is gone entirely: the feature alone keeps the composer active.
    focus.unfocus();
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, greaterThan(collapsedWidth));
    expect(addPhoto, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deselecting the feature collapses the composer back — no stale expanded state', (tester) async {
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

    final field = find.byType(TextField);
    final collapsedWidth = tester.getSize(field).width;

    input.setFeatureMode(ChatInputMode.audioGeneration);
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, greaterThan(collapsedWidth));

    // Cleared WITHOUT any route transition (the post-send/model-change
    // shape): the capsule must collapse — this is the stale-state incident.
    input.clearFeatureMode();
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, closeTo(collapsedWidth, 1.0));
    expect(find.byType(AddPhotoButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapid feature toggles and focus flips never destabilise the composer', (tester) async {
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

    final originalField = tester.state(find.byType(TextField));

    for (var i = 0; i < 6; i++) {
      input.setFeatureMode(ChatInputMode.imageGeneration);
      await tester.pump(const Duration(milliseconds: 60));
      focus.requestFocus();
      await tester.pump(const Duration(milliseconds: 60));
      focus.unfocus();
      await tester.pump(const Duration(milliseconds: 60));
      input.setFeatureMode(ChatInputMode.featureReasoning);
      await tester.pump(const Duration(milliseconds: 60));
      input.clearFeatureMode();
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pumpAndSettle();

    // The TextField element is the SAME State object across the whole
    // storm: no teardown, no FocusNode/controller loss, no vanishing buttons.
    expect(tester.state(find.byType(TextField)), same(originalField));
    expect(find.byType(AddPhotoButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
