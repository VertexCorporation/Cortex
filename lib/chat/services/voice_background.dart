import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Small platform bridge for the lifetime of an already-active Voice session.
/// The native side owns only the foreground-service notification; microphone
/// capture and playback remain owned by the existing Flutter services.
class VoiceBackgroundService {
  static const MethodChannel _channel = MethodChannel(
    'com.vertex.cortex/voice_background',
  );

  VoidCallback? onStopRequested;

  VoiceBackgroundService() {
    _channel.setMethodCallHandler(_handlePlatformCall);
  }

  Future<Object?> _handlePlatformCall(MethodCall call) async {
    if (call.method == 'stopRequested') {
      onStopRequested?.call();
    }
    return null;
  }

  Future<bool> start() async {
    if (kIsWeb) return false;
    try {
      await _channel.invokeMethod<void>('start');
      return true;
    } on MissingPluginException {
      // iOS uses its AVAudioSession/background mode instead of an Android
      // foreground service. Older builds also have no native bridge yet.
      return false;
    } on PlatformException catch (error) {
      debugPrint('[VoiceBackground] start failed: ${error.code}');
      return false;
    }
  }

  Future<void> stop() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // No native lifetime to stop on this platform/build.
    } on PlatformException catch (error) {
      debugPrint('[VoiceBackground] stop failed: ${error.code}');
    }
  }
}
