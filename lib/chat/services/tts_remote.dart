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
import 'package:cortex/network/fulcrum_http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'voice_health.dart';

class RemoteTtsService {
  RemoteTtsService._();
  static final RemoteTtsService instance = RemoteTtsService._();

  static const String _endpoint =
      "https://synthesizespeech-o5h7dmtija-ew.a.run.app";

  /// Matches TTS_MAX_CHARS in functions/src/voice.js. Sentences longer than
  /// this are rejected server-side, so they are spoken on-device instead of
  /// spending a request to find that out.
  static const int maxChars = 800;

  final Dio _dio = createFulcrumHttp(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  AudioPlayer? _player;
  bool _contextConfigured = false;
  final Set<CancelToken> _requests = {};
  int _generation = 0;

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
      // NO audio focus, deliberately. record_android's AudioRecorder
      // registers an audio-focus listener for the microphone by default and
      // PAUSES the recording forever on any focus loss (its resume path only
      // exists in pauseResume mode). Requesting focus per sentence here used
      // to make every sentence's playback silently kill the microphone —
      // verified on device: the socket stayed alive and only KeepAlive frames
      // flowed, so the user's next utterance never reached STT. Voice Mode's
      // own playback is short-form speech; ducking others is not worth the
      // microphone. The recorder side is also hardened (its config now uses
      // AudioInterruptionMode.none), so neither component does focus games
      // while the mic should be live.
      audioFocus: AndroidAudioFocus.none,
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

  /// Fire-and-forget request sent when a voice session OPENS. The synthesis
  /// endpoint runs on a scale-to-zero container, and the device log showed
  /// the FIRST real sentence paying an ~8-second cold boot before playback
  /// could begin — every later sentence on the warm instance took ~1–3s.
  /// This request is rejected by the server (empty text) within
  /// milliseconds, but it still boots the container while the user is still
  /// talking, so the first sentence's synthesis hits a warm instance.
  ///
  /// Never throws, never blocks the caller, and does not spend speech
  /// credits: the server rejects empty text before any synthesis.
  Future<void> warmup() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      if (token == null) return;
      final started = DateTime.now();
      await _dio.post<List<int>>(
        _endpoint,
        data: const {'text': ''},
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          validateStatus: (_) => true,
        ),
      );
      VoiceTelemetry.mark(
        'TTS warmup done '
        '(${DateTime.now().difference(started).inMilliseconds}ms)',
      );
    } catch (e) {
      // Warmup is best-effort by definition: the network being cold now does
      // not stop the session, it just leaves the container cold.
      debugPrint('[RemoteTts] Warmup unavailable: $e');
    }
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
    final generation = _generation;
    final cancelToken = CancelToken();
    _requests.add(cancelToken);
    final synthStartedAt = DateTime.now();
    final preview = trimmed.length > 18
        ? '${trimmed.substring(0, 18)}…'
        : trimmed;
    VoiceTelemetry.mark('TTS synth request start: "$preview"');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken();
      if (token == null ||
          cancelToken.isCancelled ||
          FirebaseAuth.instance.currentUser?.uid != user.uid) {
        return null;
      }

      final response = await _dio.post<List<int>>(
        _endpoint,
        cancelToken: cancelToken,
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

      if (generation != _generation ||
          FirebaseAuth.instance.currentUser?.uid != user.uid) {
        return null;
      }
      if (response.statusCode != 200 || response.data == null) {
        debugPrint("[RemoteTts] Declined: HTTP ${response.statusCode}");
        return null;
      }
      final bytes = Uint8List.fromList(response.data!);
      if (bytes.isEmpty) return null;
      VoiceTelemetry.mark(
        'TTS bytes ready (${DateTime.now().difference(synthStartedAt).inMilliseconds}ms, '
        '${(bytes.length / 1024).round()}KB)',
      );
      return bytes;
    } catch (e) {
      if (kDebugMode) debugPrint('[RemoteTts] Synthesis unavailable.');
      return null;
    } finally {
      _requests.remove(cancelToken);
    }
  }

  /// Plays finished audio and returns when it has stopped.
  ///
  /// Returns false if playback could not start, so the caller can speak the
  /// same sentence on-device instead of skipping it.
  Future<bool> play(Uint8List bytes) async {
    StreamSubscription<void>? onComplete;
    StreamSubscription<PlayerState>? onState;
    final generation = _generation;
    try {
      final player = await _ensurePlayer();
      if (generation != _generation) return true;
      await player.stop();
      if (generation != _generation) return true;

      // onPlayerComplete does not fire if playback is stopped from elsewhere,
      // so the state stream is watched as well.
      final completer = Completer<void>();

      void finish() {
        if (!completer.isCompleted) completer.complete();
      }

      onComplete = player.onPlayerComplete.listen((_) => finish());
      onState = player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          finish();
        }
      });

      // Subscribe before play: short clips can finish before play() returns.
      VoiceTelemetry.mark('TTS playback start');
      await player.play(BytesSource(bytes));
      await completer.future;
      VoiceTelemetry.mark('TTS playback complete');
      return true;
    } catch (e) {
      debugPrint("[RemoteTts] play failed: $e");
      return false;
    } finally {
      await onComplete?.cancel();
      await onState?.cancel();
    }
  }

  /// Cuts playback short — used when the user interrupts.
  Future<void> stop() async {
    _generation++;
    for (final request in _requests) {
      request.cancel('Voice interrupted');
    }
    try {
      await _player?.stop();
    } catch (e) {
      debugPrint("[RemoteTts] stop failed: $e");
    }
  }

  Future<void> dispose() async {
    await stop();
    try {
      await _player?.dispose();
    } catch (_) {}
    _player = null;
  }
}
