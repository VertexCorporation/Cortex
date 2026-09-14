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
import 'dart:math' as math;

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

  /// Live playback activity for the orb. It is driven by the actual player
  /// state/position, never by a second audio stream or recorder.
  final ValueNotifier<double> outputLevel = ValueNotifier<double>(0);

  /// The voice the user picked, kept here so voice mode does not have to reach
  /// for a provider on every sentence. VoiceCatalogProvider writes it; null
  /// means the server picks.
  String? activeVoiceId;

  /// The audio session voice mode needs. flutter_tts configures this itself,
  /// so playing through audioplayers instead means configuring it here too —
  /// otherwise iOS routes playback to the earpiece and the microphone drops
  /// out mid-conversation.
  static final AudioContext voiceAudioContext = AudioContext(
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
      // VOICE_COMMUNICATION, not ASSISTANT. Echo suppression (the platform
      // AEC that cancels the app's own speaker output inside the mic signal)
      // applies between streams of the SAME audio domain: the capture side
      // already runs in the voice-communication domain (record's
      // AndroidRecordConfig uses the voiceCommunication source with AEC/NS
      // enabled and AudioManagerMode.modeInCommunication), but playback used
      // to sit in the assistant domain, so the HAL had no reference signal
      // and the assistant's own spoken words transcribed back as user
      // speech — verified on device as finals containing the assistant's
      // exact sentences. Routing playback into the communication domain gives
      // platform AEC its reference; the software fingerprint layer
      // (AssistantEchoFilter) remains as the second line of defense.
      usageType: AndroidUsageType.voiceCommunication,
      // NO audio focus, deliberately. record_android's AudioRecorder
      // registers an audio-focus listener for the microphone by default and
      // PAUSES the recording forever on any focus loss (its resume path only
      // exists in pauseResume mode). Requesting focus per sentence here used
      // to make every sentence's playback silently kill the microphone —
      // verified on device: the socket stayed alive and only KeepAlive frames
      // flowed, so the user's next utterance never reached STT. Voice Mode's
      // own playback is short-form speech; ducking others is not worth the
      // microphone. The recorder side is also hardened (its config uses
      // AudioInterruptionMode.none), so neither component does focus games
      // while the mic should be live.
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  Future<AudioPlayer> _ensurePlayer() async {
    if (!_contextConfigured) {
      try {
        await AudioPlayer.global.setAudioContext(voiceAudioContext);
        _contextConfigured = true;
      } catch (e) {
        debugPrint("[RemoteTts] Could not set audio context: $e");
      }
    }
    if (_player == null) {
      final player = AudioPlayer();
      player.positionUpdater = TimerPositionUpdater(
        getPosition: player.getCurrentPosition,
        interval: const Duration(milliseconds: 40),
      );
      _player = player;
    }
    return _player!;
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
  Future<Uint8List?> synthesize(
    String text, {
    String? voiceId,
    String? telemetryLabel,
  }) async {
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
    final requestLabel = telemetryLabel == null ? '' : ' ($telemetryLabel)';
    VoiceTelemetry.mark('TTS synth request start$requestLabel: "$preview"');

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
      // The synthesis endpoint returns signed 16-bit mono PCM so the orb can
      // follow the same audio that is actually sent to the speaker.  Keep the
      // player contract stable by wrapping raw PCM in a small WAV container;
      // already-containerized responses remain untouched for compatibility
      // with older/local endpoints.
      final contentType =
          response.headers.value(Headers.contentTypeHeader)?.toLowerCase() ??
          '';
      final playable = _isWave(bytes) || !contentType.contains('pcm')
          ? bytes
          : _pcmToWave(bytes);
      VoiceTelemetry.mark(
        'TTS bytes ready (${DateTime.now().difference(synthStartedAt).inMilliseconds}ms, '
        '${(playable.length / 1024).round()}KB)',
      );
      return playable;
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
  Future<bool> play(Uint8List bytes, {String? label}) async {
    StreamSubscription<void>? onComplete;
    StreamSubscription<PlayerState>? onState;
    StreamSubscription<Duration>? onPosition;
    final generation = _generation;
    final envelope = _pcmEnvelope(bytes);
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
        if (state == PlayerState.playing && envelope.isNotEmpty) {
          outputLevel.value = envelope.first;
        }
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          outputLevel.value = 0;
          finish();
        }
      });

      // Subscribe before play: short clips can finish before play() returns.
      final name = label == null
          ? ''
          : ': "${label.length > 18 ? '${label.substring(0, 18)}…' : label}"';
      VoiceTelemetry.mark('TTS playback start$name');
      // Subscribe before play: short clips can finish before play() returns.
      onPosition = player.onPositionChanged.listen((value) {
        if (envelope.isEmpty) {
          outputLevel.value = 0;
          return;
        }
        final frame = (value.inMilliseconds * _envelopeRateHz / 1000).floor();
        outputLevel.value = envelope[frame.clamp(0, envelope.length - 1)];
      });
      await player.play(
        BytesSource(bytes, mimeType: _isWave(bytes) ? 'audio/wav' : null),
      );
      await completer.future;
      VoiceTelemetry.mark('TTS playback complete$name');
      return true;
    } catch (e) {
      debugPrint("[RemoteTts] play failed: $e");
      return false;
    } finally {
      outputLevel.value = 0;
      await onComplete?.cancel();
      await onState?.cancel();
      await onPosition?.cancel();
    }
  }

  /// Cuts playback short — used when the user interrupts.
  Future<void> stop() async {
    _generation++;
    outputLevel.value = 0;
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

  static const int _pcmSampleRate = 16000;
  static const int _pcmChannels = 1;
  static const int _pcmBitsPerSample = 16;
  static const int _envelopeFrameSamples = 320; // 20 ms at 16 kHz
  static const int _envelopeRateHz = _pcmSampleRate ~/ _envelopeFrameSamples;

  static bool _isWave(Uint8List bytes) {
    if (bytes.length < 12) return false;
    return String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WAVE';
  }

  static Uint8List _pcmToWave(Uint8List pcm) {
    final header = ByteData(44);
    final dataLength = pcm.length;
    final byteRate = _pcmSampleRate * _pcmChannels * _pcmBitsPerSample ~/ 8;
    final blockAlign = _pcmChannels * _pcmBitsPerSample ~/ 8;
    void ascii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        header.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    header.setUint32(4, 36 + dataLength, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, _pcmChannels, Endian.little);
    header.setUint32(24, _pcmSampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, _pcmBitsPerSample, Endian.little);
    ascii(36, 'data');
    header.setUint32(40, dataLength, Endian.little);
    return Uint8List.fromList(<int>[...header.buffer.asUint8List(), ...pcm]);
  }

  static List<double> _pcmEnvelope(Uint8List bytes) {
    if (!_isWave(bytes) || bytes.length < 44) return const <double>[];
    final data = ByteData.sublistView(bytes);
    var offset = 12;
    var dataOffset = -1;
    var dataLength = 0;
    var channels = _pcmChannels;
    var bits = _pcmBitsPerSample;
    while (offset + 8 <= bytes.length) {
      final id = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final length = data.getUint32(offset + 4, Endian.little);
      final body = offset + 8;
      if (body > bytes.length) break;
      if (id == 'fmt ' && length >= 16 && body + 16 <= bytes.length) {
        channels = data.getUint16(body + 2, Endian.little);
        bits = data.getUint16(body + 14, Endian.little);
      } else if (id == 'data') {
        dataOffset = body;
        dataLength = math.min(length, bytes.length - body);
        break;
      }
      offset = body + length + (length.isOdd ? 1 : 0);
    }
    if (dataOffset < 0 || bits != 16 || channels < 1 || dataLength < 2) {
      return const <double>[];
    }
    final sampleBytes = channels * 2;
    final samples = dataLength ~/ sampleBytes;
    final frameCount = (samples / _envelopeFrameSamples).ceil();
    final result = <double>[];
    for (var frame = 0; frame < frameCount; frame++) {
      final start = frame * _envelopeFrameSamples;
      final end = math.min(start + _envelopeFrameSamples, samples);
      if (start >= end) break;
      var sum = 0.0;
      var peak = 0.0;
      for (var sample = start; sample < end; sample++) {
        var channelSum = 0.0;
        for (var channel = 0; channel < channels; channel++) {
          final byte = dataOffset + (sample * channels + channel) * 2;
          final value = data.getInt16(byte, Endian.little) / 32768.0;
          channelSum += value;
        }
        final amplitude = (channelSum / channels).abs();
        sum += amplitude * amplitude;
        if (amplitude > peak) peak = amplitude;
      }
      // RMS gives a stable syllable envelope; a little peak contribution keeps
      // consonants visible without making the orb flash on every sample.
      final rms = math.sqrt(sum / (end - start));
      result.add((rms * 0.75 + peak * 0.25).clamp(0.0, 1.0));
    }
    return result;
  }

  @visibleForTesting
  static Uint8List pcmWaveForTesting(Uint8List pcm) => _pcmToWave(pcm);

  @visibleForTesting
  static List<double> pcmEnvelopeForTesting(Uint8List wave) =>
      _pcmEnvelope(wave);

  static String? mimeTypeForBytes(Uint8List bytes) =>
      _isWave(bytes) ? 'audio/wav' : null;
}
