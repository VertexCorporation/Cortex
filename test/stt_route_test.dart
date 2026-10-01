import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/chat/services/stt_route.dart';

void main() {
  test('route contract preserves provider/model/audio/language metadata', () {
    final route = SttRoute.fromBody({
      'provider': 'elevenlabs',
      'model': 'scribe_v2_realtime',
      'token': 'opaque',
      'sessionId': 'session',
      'routeId': 'route',
      'language': {'mode': 'automatic', 'currentLanguage': 'tr'},
      'audio': {'format': 'pcm_16000', 'sampleRate': 16000, 'channels': 1},
      'voice': {'allowanceSeconds': 720, 'remainingSeconds': 420},
    });
    expect(route?.provider, 'elevenlabs');
    expect(route?.model, 'scribe_v2_realtime');
    expect(route?.sampleRate, 16000);
    expect(route?.remainingVoiceSeconds, 420);
  });

  test(
    'automatic language requires stable repeated evidence before switching',
    () {
      const initial = VoiceLanguageState();
      final first = initial.observe('tr', 0.9);
      expect(first.currentLanguage, isNull);
      final second = first.observe('tr', 0.92);
      expect(second.currentLanguage, 'tr');
    },
  );
}
