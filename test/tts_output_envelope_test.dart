import 'dart:typed_data';

import 'package:cortex/chat/services/tts_remote.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'output envelope is derived from PCM samples, not a synthetic clock',
    () {
      final pcm = BytesBuilder();
      for (var i = 0; i < 320; i++) {
        final sample = i < 160 ? 0 : 12000;
        pcm.add(
          Uint8List(2)
            ..[0] = sample & 0xff
            ..[1] = (sample >> 8) & 0xff,
        );
      }

      final wave = RemoteTtsService.pcmWaveForTesting(pcm.toBytes());
      final envelope = RemoteTtsService.pcmEnvelopeForTesting(wave);

      expect(envelope, hasLength(1));
      expect(envelope.single, greaterThan(0.1));
      expect(envelope.single, lessThan(1.0));
    },
  );

  test('zero PCM produces a quiet output envelope', () {
    final wave = RemoteTtsService.pcmWaveForTesting(Uint8List(640));
    final envelope = RemoteTtsService.pcmEnvelopeForTesting(wave);

    expect(envelope, hasLength(1));
    expect(envelope.single, 0);
  });
}
