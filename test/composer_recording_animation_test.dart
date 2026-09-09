import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/input.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/buttons.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/recording_layout.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/l10n/app_localizations.dart';
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
  @override
  ModelEntity? get selectedModel => null;
  @override
  bool get isLocalModelLoaded => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Internet extends ChangeNotifier implements InternetProvider {
  @override
  bool get isConnected => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final width in [320.0, 390.0, 800.0]) {
    testWidgets('composer entry/exit and rapid reversal at $width',
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
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider<InputProvider>.value(value: input),
            ChangeNotifierProvider<SpeechService>(create: (_) => _Speech()),
            ChangeNotifierProvider<VoiceService>(create: (_) => _Voice()),
            ChangeNotifierProvider<ChatSessionProvider>(
                create: (_) => _Session()),
            ChangeNotifierProvider<InternetProvider>(
                create: (_) => _Internet()),
          ],
          child: MaterialApp(
              home: Scaffold(
                  body: Align(
            alignment: Alignment.bottomCenter,
            child: InputField(
                localizations: loc,
                isModelSelected: true,
                isDynamicChatMode: false,
                isLimitExceeded: true,
                controller: text,
                textFieldFocusNode: focus,
                onSend: () async {},
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
                onCancelEditing: () {}),
          )))));
      await tester.pumpAndSettle();
      final layout = find.byType(RecordingLayout);
      final idle = tester.getSize(layout);
      final fieldState = tester.state(find.byType(TextField));
      final entryHeights = <double>[];
      input.setVoiceRecording(true);
      await tester.pump();
      entryHeights.add(tester.getSize(layout).height);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 60));
        entryHeights.add(tester.getSize(layout).height);
      }
      input.setVoiceRecording(false);
      await tester.pump();
      for (var i = 0; i <= 10; i++) {
        if (i > 0) await tester.pump(const Duration(milliseconds: 60));
        expect(
            tester.getSize(layout).height, closeTo(entryHeights[10 - i], 0.01));
        if (i < 6) {
          final fade = tester.widget<FadeTransition>(find
              .ancestor(
                  of: find.byType(AddPhotoButton),
                  matching: find.byType(FadeTransition))
              .first);
          expect(fade.opacity.value, 0,
              reason: 'controls remain hidden until shrinking finishes');
        }
      }
      for (var i = 0; i < 8; i++) {
        input.setVoiceRecording(i.isEven);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 73));
        expect(tester.takeException(), isNull);
      }
      input.setVoiceRecording(false);
      await tester.pumpAndSettle();
      expect(tester.getSize(layout), idle);
      expect(tester.state(find.byType(TextField)), same(fieldState));
      expect(text.text, 'original draft');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
