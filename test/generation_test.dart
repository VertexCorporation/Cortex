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

  test('audio feature routes explicit music prompts to music', () {
    for (final prompt in [
      'Create a 30 second lofi beat',
      'Make cinematic background music',
      '120 BPM instrumental with piano',
      '30 saniyelik sakin müzik üret',
      'Bir rap altyapısı için melodi ve akor oluştur',
      'Kısa bir şarkı bestele',
    ]) {
      expect(
        generationTargetForMode(ChatInputMode.audioGeneration, prompt),
        'music',
        reason: prompt,
      );
    }
  });

  test('audio feature keeps voice and sound effects on audio', () {
    for (final prompt in [
      'Say hello with a calm female voice',
      'Generate a thunder sound effect',
      'Create a heartbeat sound effect',
      'Türkçe bir anlatım sesi oluştur',
      'Kapı kapanma sesi üret',
    ]) {
      expect(
        generationTargetForMode(ChatInputMode.audioGeneration, prompt),
        'audio',
        reason: prompt,
      );
    }
  });

  test('generation targets map to the correct credit lanes', () {
    expect(generationCreditLaneForTarget('image'), 'image');
    expect(generationCreditLaneForTarget('video'), 'video');
    expect(generationCreditLaneForTarget('audio'), 'speech');
    expect(generationCreditLaneForTarget('music'), 'music');
    expect(generationCreditLaneForTarget(null), isNull);
  });

  test('non-audio generation targets ignore music-like words', () {
    expect(
      generationTargetForMode(
        ChatInputMode.imageGeneration,
        'album cover for my music',
      ),
      'image',
    );
    expect(
      generationTargetForMode(
        ChatInputMode.videoGeneration,
        'music video clip',
      ),
      'video',
    );
  });

  for (final type in ['image', 'video', 'audio']) {
    testWidgets('$type button activates the input feature mode', (
      tester,
    ) async {
      final input = InputProvider()..setFeatureMode(ChatInputMode.study);
      final session = GenerationSession();
      late BuildContext actionContext;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<InputProvider>.value(value: input),
            ChangeNotifierProvider<ChatSessionProvider>.value(value: session),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                actionContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expectedMode = generationModeForTarget(type)!;

      setGenerationFeatureMode(actionContext, targetType: type);
      expect(input.featureMode, expectedMode);
      expect(input.enableWebSearch, isFalse);
      expect(session.isDynamicChat, isTrue);

      setGenerationFeatureMode(actionContext, targetType: type);
      expect(input.featureMode, ChatInputMode.none);

      setGenerationFeatureMode(actionContext, targetType: type);
      setGenerationFeatureMode(actionContext, targetType: 'image');
      expect(
        input.featureMode,
        type == 'image' ? ChatInputMode.none : ChatInputMode.imageGeneration,
      );

      await tester.pumpWidget(const SizedBox());
      input.dispose();
      session.dispose();
    });
  }
}
