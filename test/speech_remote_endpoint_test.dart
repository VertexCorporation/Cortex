import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/stt_remote.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'endpoint-only frames are forwarded as control, not transcript text',
    () {
      expect(
        SpeechService.shouldAccumulateRemoteTranscript(
          const SttResult('', isFinal: true, isEndOfTurn: true),
        ),
        isFalse,
      );
      expect(
        SpeechService.shouldAccumulateRemoteTranscript(
          const SttResult('Buffered phrase', isFinal: true, isEndOfTurn: true),
        ),
        isTrue,
      );
    },
  );
}
