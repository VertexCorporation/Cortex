import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The iOS app owns the duplex session while Voice/Flow uses the recorder.
class IosVoiceAudioSession {
  static const _channel = MethodChannel('com.vertex.cortex/voice_audio');

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static Future<void> activate() => _channel.invokeMethod<void>('activate');

  static Future<void> deactivate() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('deactivate');
    } catch (error) {
      debugPrint('[VoiceAudio] Could not release iOS audio session: $error');
    }
  }
}
