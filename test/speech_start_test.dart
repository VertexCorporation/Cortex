import 'package:cortex/chat/services/speech.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('native capture waits for listening and retries after refusal', (
    tester,
  ) async {
    const channel = MethodChannel('plugin.csdcorp.com/speech_to_text');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    var initializationCount = 0;
    var listenCount = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'initialize':
          initializationCount++;
          return true;
        case 'locales':
          return ['en_US:English'];
        case 'listen':
          listenCount++;
          return listenCount > 1;
        case 'stop':
          return true;
        default:
          return null;
      }
    });
    final speech = SpeechService();

    Future<bool> start() =>
        speech.startListening(locale: 'en-US', onResult: (_) {});

    final refused = start();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(await refused, isFalse);
    expect(speech.currentOwner, isNull);
    expect(speech.isListening, isFalse);

    final listening = start();
    await tester.pump();
    expect(speech.isListening, isFalse);
    await messenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('notifyStatus', 'listening'),
      ),
      null,
    );
    expect(await listening, isTrue);
    expect(speech.isListening, isTrue);
    expect(initializationCount, 1);

    await speech.stopListening();
    speech.dispose();
    await tester.pump(const Duration(seconds: 2));
  });
}
