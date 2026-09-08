import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/generation.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class GenerationSession extends ChangeNotifier implements ChatSessionProvider {
  bool dynamicChat = false;
  @override
  bool get isDynamicChat => dynamicChat;
  @override
  void startDynamicConversation({bool savePreference = true}) {
    dynamicChat = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('generationModeForTarget maps generation keys to input modes', () {
    expect(generationModeForTarget('image'), ChatInputMode.imageGeneration);
    expect(generationModeForTarget('video'), ChatInputMode.videoGeneration);
    expect(generationModeForTarget('audio'), ChatInputMode.audioGeneration);
    expect(generationModeForTarget('unknown'), isNull);
  });

  for (final type in ['image', 'video', 'audio']) {
    testWidgets('$type button activates the input feature mode',
        (tester) async {
      final input = InputProvider()..setFeatureMode(ChatInputMode.study);
      final session = GenerationSession();
      late BuildContext actionContext;
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<InputProvider>.value(value: input),
          ChangeNotifierProvider<ChatSessionProvider>.value(value: session),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(builder: (context) {
            actionContext = context;
            return const SizedBox();
          }),
        ),
      ));
      await tester.pumpAndSettle();

      final expectedMode = generationModeForTarget(type)!;

      // Activating the button switches the input into the matching feature
      // mode (same state as selecting a feature from the Features sheet).
      setGenerationFeatureMode(actionContext, targetType: type);
      expect(input.featureMode, expectedMode);
      expect(input.enableWebSearch, isFalse);
      expect(session.isDynamicChat, isTrue);

      // Tapping the same target again toggles the mode off.
      setGenerationFeatureMode(actionContext, targetType: type);
      expect(input.featureMode, ChatInputMode.none);

      // Tapping a different target switches to that mode instead.
      setGenerationFeatureMode(actionContext, targetType: type);
      setGenerationFeatureMode(actionContext, targetType: 'image');
      expect(
          input.featureMode,
          type == 'image'
              ? ChatInputMode.none
              : ChatInputMode.imageGeneration);

      await tester.pumpWidget(const SizedBox());
      input.dispose();
      session.dispose();
    });
  }
}
