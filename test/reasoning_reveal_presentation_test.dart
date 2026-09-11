// test/reasoning_reveal_presentation_test.dart
//
// The reasoning (think-tag) presentation inside the AI message tile:
//
//  1. Streamed reasoning text runs through the SAME reveal pipeline
//     (RevealTimeline + RevealText) as the assistant's main answer — the
//     offline (and online) reasoning stream must not degrade to plain
//     typing while the answer uses the polished glyph reveal.
//  2. The reasoning header label follows the reasoning-stream lifecycle,
//     not the expand/collapse state: it shimmers "Thinking" while tokens
//     are still arriving, and cross-fades to "Thought" once the stream
//     closes. The settled "Thought" label never shimmers.
//  3. Both labels come from localization keys (no hardcoded strings).
//  4. A regenerated response restarts the lifecycle and shimmers again.
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/messages/tiles/ai.dart';
import 'package:cortex/chat/messages/tiles/ai/reveal_text.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/widgets/thinking.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/notifications/introvert.dart';
import 'package:cortex/server/credits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class _Models extends ChangeNotifier implements ModelService {
  @override
  bool hasModelInCache(String modelId) => true;

  @override
  ModelEntity getPreciseModelData(String modelId, {required String langCode}) =>
      ModelEntity.fromMap({
        'id': modelId.isEmpty ? 'cortex/auto' : modelId,
        'title': modelId.isEmpty ? 'Cortex' : modelId,
        'producer': 'Cortex',
        'type': 'online',
        'category': 'online',
      }, langCode);

  @override
  List<ModelEntity> getCachedModelsSync() => [];

  @override
  String getModelImagePath(ModelEntity model) => 'assets/icons/self.svg';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends ChangeNotifier implements ChatSessionProvider {
  @override
  ModelEntity? get selectedModel => null;

  @override
  bool get isLocalModelLoaded => false;

  @override
  bool get isUserSubscribed => false;

  @override
  bool get isDynamicChat => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Credits implements CreditsManager {
  final ValueNotifier<int?> _credits = ValueNotifier<int?>(10);

  @override
  ValueNotifier<int?> get totalCreditsNotifier => _credits;

  @override
  bool get modelSelectionAllowed => true;

  @override
  bool get canChooseModel => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Internet extends ChangeNotifier implements InternetProvider {
  @override
  bool get isConnected => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Introvert implements IntrovertNotificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpTile(
  WidgetTester tester, {
  required Message message,
  String language = 'en',
}) async {
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<ConversationProvider>(
          create: (_) => ConversationProvider()),
      ChangeNotifierProvider<ModelService>(create: (_) => _Models()),
      ChangeNotifierProvider<ChatSessionProvider>(create: (_) => _Session()),
      Provider<CreditsManager>(create: (_) => _Credits()),
      ChangeNotifierProvider<InternetProvider>(create: (_) => _Internet()),
      Provider<IntrovertNotificationService>(create: (_) => _Introvert()),
    ],
    child: MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 400,
            child: AIMessageTile(
              message: message,
              avatarPath: 'assets/icons/self.svg',
              onRegenerate: ({String? newModelId}) {},
              onReport: () {},
              onStop: () {},
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

/// The shimmer on the reasoning label (scoped to the reasoning widget).
Finder _thinkShimmer() => find.descendant(
    of: find.byType(ThinkingWidget), matching: find.byType(Shimmer));

/// The reasoning content's RevealText — the same presentation component the
/// main answer uses.
Finder _thinkReveal() => find.descendant(
    of: find.byType(ThinkingWidget), matching: find.byType(RevealText));

/// Advances the reveal clock in small frame steps (mirrors the production
/// ticker cadence) so the timeline can reveal the streamed characters.
Future<void> _streamFrames(WidgetTester tester, {int frames = 24}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

void main() {
  testWidgets(
      'streamed reasoning animates through the same RevealText pipeline and shimmers Thinking',
      (tester) async {
    final message =
        Message(text: '', isUserMessage: false, isThinking: true, model: null);
    await _pumpTile(tester, message: message);

    // First reasoning tokens arrive (the offline shape: the stream opens
    // with the think tag and the reasoning streams token by token).
    message.notifier.value = '<think>Working through the answer';
    await _streamFrames(tester);

    expect(find.byType(ThinkingWidget), findsOneWidget);
    // The reasoning label shimmers while tokens are still streaming.
    expect(_thinkShimmer(), findsOneWidget);
    expect(find.text('Thinking'), findsOneWidget);
    // The reasoning content is painted by the SAME reveal component.
    expect(_thinkReveal(), findsOneWidget);

    // More reasoning tokens stream in.
    message.notifier.value =
        '<think>Working through the answer step by step, carefully.';
    await _streamFrames(tester);
    expect(_thinkShimmer(), findsOneWidget);
    expect(_thinkReveal(), findsOneWidget);

    // Expand the reasoning block mid-stream: the label keeps shimmering —
    // the lifecycle is not tied to expand/collapse.
    await tester.tap(find.byType(ThinkingWidget), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 250));
    expect(_thinkShimmer(), findsOneWidget);

    // Collapse it again mid-stream: still shimmering.
    await tester.tap(find.byType(ThinkingWidget), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 250));
    expect(_thinkShimmer(), findsOneWidget);
  });

  testWidgets(
      'reasoning completion cross-fades the label to Thought and stops the shimmer',
      (tester) async {
    final message =
        Message(text: '', isUserMessage: false, isThinking: true, model: null);
    await _pumpTile(tester, message: message);

    message.notifier.value = '<think>Working through the answer';
    await _streamFrames(tester);
    expect(_thinkShimmer(), findsOneWidget);
    expect(find.text('Thinking'), findsOneWidget);

    // The reasoning closes, the answer streams and the message finalizes.
    final completed = message.copyWith(
      text: '<think>Working through the answer</think>'
          'Hello! I am doing great, thanks for asking.',
      isThinking: false,
    );
    await _pumpTile(tester, message: completed);
    await _streamFrames(tester);

    // Past the 400ms cross-fade the settled label reads "Thought" and the
    // shimmer is gone: the completed label must never shimmer.
    await tester.pump(const Duration(milliseconds: 500));
    expect(_thinkShimmer(), findsNothing);
    expect(find.text('Thought'), findsOneWidget);

    // The completed reasoning keeps rendering through the shared reveal
    // pipeline alongside the main answer's own RevealText.
    expect(_thinkReveal(), findsOneWidget);
    expect(find.byType(RevealText), findsNWidgets(2));
  });

  testWidgets(
      'a regenerated response restarts the reasoning lifecycle and shimmers Thinking again',
      (tester) async {
    // A completed previous response on this tile slot.
    final finished = Message(
      text: '<think>Old reasoning</think>Old answer',
      isUserMessage: false,
      isThinking: false,
      model: null,
    );
    await _pumpTile(tester, message: finished);
    await _streamFrames(tester, frames: 2);
    expect(find.text('Thought'), findsOneWidget);
    expect(_thinkShimmer(), findsNothing);

    // Regeneration: the same slot flips back to a live reasoning stream.
    final regen =
        Message(text: '', isUserMessage: false, isThinking: true, model: null);
    await _pumpTile(tester, message: regen);
    await tester.pump(const Duration(milliseconds: 600));
    regen.notifier.value = '<think>Fresh reasoning for the new answer';
    await _streamFrames(tester);

    // The label restarted: it shimmers "Thinking" again — it must not
    // inherit the previous response's settled "Thought" state.
    expect(_thinkShimmer(), findsOneWidget);
    expect(find.text('Thinking'), findsOneWidget);
    expect(find.text('Thought'), findsNothing);
    expect(_thinkReveal(), findsOneWidget);
  });

  testWidgets(
      'the labels are localized — a Turkish device sees Düşünüyor shimmer',
      (tester) async {
    final message =
        Message(text: '', isUserMessage: false, isThinking: true, model: null);
    await _pumpTile(tester, message: message, language: 'tr');

    message.notifier.value = '<think>Merhaba, cevabı düşünüyorum';
    await _streamFrames(tester);

    expect(find.text('Düşünüyor'), findsOneWidget);
    expect(_thinkShimmer(), findsOneWidget);

    // No hardcoded English strings leak into the localized UI.
    expect(find.text('Thinking'), findsNothing);
    expect(find.text('Thought'), findsNothing);
  });
}
