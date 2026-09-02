// lib/chat/services/tts_remote.dart
//
// ElevenLabs speech for voice mode, one sentence at a time.
//
// Voice mode already splits the model's reply into sentences and speaks them
// from a queue, so this service is built around that shape: each call carries
// one sentence and returns finished audio. That keeps the Cloud Function open
// for a few hundred milliseconds per sentence instead of for the length of the
// conversation, and it means playback can start on sentence one while the
// model is still writing sentence three.
//
// Every entry point degrades to null rather than throwing. Voice mode must
// never go silent because the network hiccuped — the caller falls back to the
// on-device voice.

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RemoteTtsService {
  RemoteTtsService._();
  static final RemoteTtsService instance = RemoteTtsService._();

  static const String _endpoint =
      "https://synthesizespeech-o5h7dmtija-ew.a.run.app";

  /// Matches TTS_MAX_CHARS in functions/src/voice.js. Sentences longer than
  /// this are rejected server-side, so they are spoken on-device instead of
  /// spending a request to find that out.
  static const int maxChars = 800;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  AudioPlayer? _player;
  bool _contextConfigured = false;

  /// The voice the user picked, kept here so voice mode does not have to reach
  /// for a provider on every sentence. VoiceCatalogProvider writes it; null
  /// means the server picks.
  String? activeVoiceId;

  /// The audio session voice mode needs. flutter_tts configures this itself,
  /// so playing through audioplayers instead means configuring it here too —
  /// otherwise iOS routes playback to the earpiece and the microphone drops
  /// out mid-conversation.
  static final AudioContext _voiceContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playAndRecord,
      options: const {
        AVAudioSessionOptions.allowBluetooth,
        AVAudioSessionOptions.allowBluetoothA2DP,
        AVAudioSessionOptions.mixWithOthers,
        AVAudioSessionOptions.defaultToSpeaker,
      },
    ),
    android: AudioContextAndroid(
      isSpeakerphoneOn: true,
      stayAwake: true,
      contentType: AndroidContentType.speech,
      usageType: AndroidUsageType.assistant,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
  );

  Future<AudioPlayer> _ensurePlayer() async {
    if (!_contextConfigured) {
      try {
        await AudioPlayer.global.setAudioContext(_voiceContext);
        _contextConfigured = true;
      } catch (e) {
        debugPrint("[RemoteTts] Could not set audio context: $e");
      }
    }
    return _player ??= AudioPlayer();
  }

  /// Fetches spoken audio for one sentence.
  ///
  /// Returns null when speech is unavailable for any reason — no session, no
  /// balance, provider down — so the caller can fall back rather than stall.
  Future<Uint8List?> synthesize(String text, {String? voiceId}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > maxChars) return null;

    // An explicit id wins so the settings preview can audition a voice the
    // user has not committed to yet.
    final voice = voiceId ?? activeVoiceId;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken();
      if (token == null) return null;

      final response = await _dio.post<List<int>>(
        _endpoint,
        data: {
          'text': trimmed,
          if (voice != null && voice.isNotEmpty) 'voiceId': voice,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          // Handled below so a 402 does not surface as an exception.
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        debugPrint("[RemoteTts] Declined: HTTP ${response.statusCode}");
        return null;
      }
      final bytes = Uint8List.fromList(response.data!);
      return bytes.isEmpty ? null : bytes;
    } catch (e) {
      debugPrint("[RemoteTts] synthesize failed: $e");
      return null;
    }
  }

  /// Plays finished audio and returns when it has stopped.
  ///
  /// Returns false if playback could not start, so the caller can speak the
  /// same sentence on-device instead of skipping it.
  Future<bool> play(Uint8List bytes) async {
    try {
      final player = await _ensurePlayer();
      await player.stop();
      await player.play(BytesSource(bytes));

      // onPlayerComplete does not fire if playback is stopped from elsewhere,
      // so the state stream is watched as well.
      final completer = Completer<void>();
      late final StreamSubscription<void> onComplete;
      late final StreamSubscription<PlayerState> onState;

      void finish() {
        if (!completer.isCompleted) completer.complete();
      }

      onComplete = player.onPlayerComplete.listen((_) => finish());
      onState = player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          finish();
        }
      });

      await completer.future;
      await onComplete.cancel();
      await onState.cancel();
      return true;
    } catch (e) {
      debugPrint("[RemoteTts] play failed: $e");
      return false;
    }
  }

  /// Cuts playback short — used when the user interrupts.
  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (e) {
      debugPrint("[RemoteTts] stop failed: $e");
    }
  }

  Future<void> dispose() async {
    try {
      await _player?.dispose();
    } catch (_) {}
    _player = null;
  }
}
