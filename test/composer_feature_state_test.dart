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
  _Session({this.localModelLoaded = false, this.model});

  final bool localModelLoaded;
  final ModelEntity? model;

  @override
  ModelEntity? get selectedModel => model;
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
  _Session? session,
  Future<void> Function()? onSend,
}) async {
  final loc = await AppLocalizations.delegate.load(const Locale('en'));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<InputProvider>.value(value: input),
      ChangeNotifierProvider<SpeechService>(create: (_) => _Speech()),
      ChangeNotifierProvider<VoiceService>(create: (_) => _Voice()),
      ChangeNotifierProvider<ChatSessionProvider>(
          create: (_) => session ?? _Session(localModelLoaded: true)),
      ChangeNotifierProvider<InternetProvider>(create: (_) => _Internet()),
      Provider<CreditsManager>.value(value: CreditsManager.instance),
    ],
    child: MaterialApp(
      // The RAG status chip (and other composer chrome) resolves localized
      // strings through the delegates, so the test app must register them.
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

  testWidgets(
      'web search active keeps the capsule open with no text, no focus and no dictation',
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

    final field = find.byType(TextField);
    final collapsedWidth = tester.getSize(field).width;

    // Web search turns the "+" bubble active: the capsule must expand too,
    // even though the field is empty, unfocused and dictation is idle.
    input.toggleWebSearch();
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, greaterThan(collapsedWidth));
    expect(find.byType(AddPhotoButton), findsOneWidget);

    // Focus flips never collapse it while the active feature is on.
    focus.requestFocus();
    await tester.pumpAndSettle();
    focus.unfocus();
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, greaterThan(collapsedWidth));

    // Clearing the feature with everything else idle may collapse again.
    input.clearWebSearch();
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, closeTo(collapsedWidth, 1.0));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'RAG (document chat) active keeps the capsule open until cleared',
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

    final field = find.byType(TextField);
    final collapsedWidth = tester.getSize(field).width;

    input.toggleRag();
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, greaterThan(collapsedWidth));

    // The empty, unfocused composer stays open while document chat is on.
    expect(find.byType(AddPhotoButton), findsOneWidget);

    input.setRagEnabled(false);
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, closeTo(collapsedWidth, 1.0));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'a model-implied active "+" (offline/media model) never lets the capsule collapse',
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

    // Baseline: a plain server-side text model, nothing selected — the
    // capsule is collapsed with an empty, unfocused field.
    await _pumpComposer(tester, input: input, text: text, focus: focus);
    await tester.pumpAndSettle();
    final field = find.byType(TextField);
    final collapsedWidth = tester.getSize(field).width;

    // Selecting an OFFLINE model paints the "+" active: the capsule must
    // stay open with the keyboard closed and the field empty.
    final offlineModel = ModelEntity.fromMap({
      'id': 'qwen3-06b',
      'title': 'Qwen 3 0.6B',
      'type': 'offline',
      'category': 'chat',
    }, 'en');
    await tester.pumpWidget(const SizedBox());
    await _pumpComposer(
      tester,
      input: input,
      text: text,
      focus: focus,
      session: _Session(localModelLoaded: true, model: offlineModel),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, greaterThan(collapsedWidth));
    expect(find.byType(AddPhotoButton), findsOneWidget);

    // Focus disappears entirely — the active "+" keeps the capsule open.
    focus.unfocus();
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, greaterThan(collapsedWidth));
    expect(tester.takeException(), isNull);

    // Switching back to a plain text model (feature cleared) with nothing
    // else active lets the capsule collapse again.
    await tester.pumpWidget(const SizedBox());
    await _pumpComposer(tester, input: input, text: text, focus: focus);
    await tester.pumpAndSettle();
    expect(tester.getSize(field).width, closeTo(collapsedWidth, 1.0));
    expect(tester.takeException(), isNull);
  });
}
