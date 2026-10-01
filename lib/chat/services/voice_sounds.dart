import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'tts_remote.dart';

/// Bundled, quiet interaction cues. No network, recorder, focus request, or
/// changes to the application's existing play-and-record session.
class VoiceInteractionSounds {
  VoiceInteractionSounds._();
  static AudioPlayer? _player;
  static int _generation = 0;

  static Future<void> _play(String asset) async {
    final generation = ++_generation;
    try {
      final player = _player ??= AudioPlayer();
      await player.setAudioContext(
        AudioContext(
          iOS: RemoteTtsService.voiceAudioContext.iOS,
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      if (generation != _generation) return;
      await player.stop();
      if (generation != _generation) return;
      await player.play(AssetSource(asset), volume: 1.0);
    } catch (_) {
      // Cues are best effort and cannot prevent the user entering Voice.
      debugPrint('[VoiceSounds] Interaction cue unavailable.');
    }
  }

  static void enteringVoice() => unawaited(_play('voice_enter.wav'));
  static void listeningReady() => unawaited(_play('voice_ready.wav'));
  static void leavingVoice() => unawaited(_play('voice_exit.wav'));
}
