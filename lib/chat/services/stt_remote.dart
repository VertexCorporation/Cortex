// lib/chat/services/stt_remote.dart
//
// Deepgram dictation.
//
// The microphone streams straight to Deepgram rather than through Fulcrum.
// Deepgram issues short-lived tokens, so the server only has to mint one and
// charge for it — the audio itself never touches our infrastructure, which
// keeps latency to a single hop and the Cloud Function bill to one short call
// per session.
//
// Everything here degrades to false/null rather than throwing. The caller
// keeps the on-device recogniser as a fallback, so a failure means "use the
// other engine", not "dictation is broken".

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

/// One transcript update. Deepgram sends a running best guess and then a
/// settled version of the same span; [isFinal] separates them so the caller
/// can replace rather than append.
class SttResult {
  const SttResult(this.text, {required this.isFinal});

  final String text;
  final bool isFinal;
}

class RemoteSttService {
  RemoteSttService._();
  static final RemoteSttService instance = RemoteSttService._();

  static const String _tokenEndpoint =
      "https://getspeechtoken-o5h7dmtija-ew.a.run.app";

  // Raw PCM at 16 kHz mono: what Deepgram expects for linear16, and small
  // enough to stream comfortably on mobile data.
  static const int _sampleRate = 16000;

  /// `language=multi` selects nova-3 multilingual. Turkish is not covered by
  /// the cheaper monolingual model, so this is not an optional upgrade.
  static const String _listenUrl =
      "wss://api.deepgram.com/v1/listen"
      "?model=nova-3&language=multi&encoding=linear16"
      "&sample_rate=$_sampleRate&channels=1"
      "&interim_results=true&smart_format=true";

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  AudioRecorder? _recorder;
  WebSocket? _socket;
  StreamSubscription<Uint8List>? _micSubscription;
  bool _closing = false;

  bool get isActive => _socket != null;

  /// Latest microphone loudness, 0..1, derived from the PCM the recorder hands
  /// us. The on-device recogniser reports this itself; here it has to be
  /// measured, otherwise the waveform in the UI would sit still.
  final ValueNotifier<double> soundLevel = ValueNotifier<double>(0.0);

  /// Asks the server for a short-lived Deepgram token. Returns null when
  /// dictation is unavailable — no session, no balance, provider down.
  Future<String?> _fetchToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final idToken = await user.getIdToken();
      if (idToken == null) return null;

      final response = await _dio.post<Map<String, dynamic>>(
        _tokenEndpoint,
        data: const <String, dynamic>{},
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode != 200) {
        debugPrint("[RemoteStt] Token declined: HTTP ${response.statusCode}");
        return null;
      }
      final token = response.data?['token'];
      return token is String && token.isNotEmpty ? token : null;
    } catch (e) {
      debugPrint("[RemoteStt] Token request failed: $e");
      return null;
    }
  }

  /// Opens the microphone and starts transcribing.
  ///
  /// Returns false if the remote path could not be established, in which case
  /// nothing has been started and the caller should use the on-device engine.
  Future<bool> start({
    required void Function(SttResult result) onResult,
    void Function()? onClosed,
  }) async {
    if (_socket != null) return true;
    _closing = false;

    final recorder = AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        debugPrint("[RemoteStt] Microphone permission denied.");
        await recorder.dispose();
        return false;
      }
    } catch (e) {
      debugPrint("[RemoteStt] Permission check failed: $e");
      await recorder.dispose();
      return false;
    }

    final token = await _fetchToken();
    if (token == null) {
      await recorder.dispose();
      return false;
    }

    try {
      _socket = await WebSocket.connect(
        _listenUrl,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint("[RemoteStt] Connect failed: $e");
      await recorder.dispose();
      _socket = null;
      return false;
    }

    _recorder = recorder;

    _socket!.listen(
      (dynamic message) {
        if (message is! String) return;
        final result = _parseTranscript(message);
        if (result != null) onResult(result);
      },
      onError: (Object e) {
        debugPrint("[RemoteStt] Socket error: $e");
        unawaited(stop());
        onClosed?.call();
      },
      onDone: () {
        if (!_closing) onClosed?.call();
        unawaited(stop());
      },
      cancelOnError: true,
    );

    try {
      final stream = await recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
          echoCancel: true,
          noiseSuppress: true,
        ),
      );

      _micSubscription = stream.listen(
        (chunk) {
          soundLevel.value = _levelOf(chunk);
          final socket = _socket;
          if (socket != null && socket.readyState == WebSocket.open) {
            socket.add(chunk);
          }
        },
        onError: (Object e) {
          debugPrint("[RemoteStt] Microphone error: $e");
          unawaited(stop());
          onClosed?.call();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("[RemoteStt] Could not start microphone: $e");
      await stop();
      return false;
    }

    return true;
  }

  /// Closes the microphone and the socket, asking Deepgram to flush whatever
  /// it is still holding so the last words are not lost.
  Future<void> stop() async {
    _closing = true;
    soundLevel.value = 0.0;

    await _micSubscription?.cancel();
    _micSubscription = null;

    try {
      await _recorder?.stop();
    } catch (e) {
      debugPrint("[RemoteStt] Recorder stop failed: $e");
    }
    try {
      await _recorder?.dispose();
    } catch (_) {}
    _recorder = null;

    final socket = _socket;
    _socket = null;
    if (socket != null) {
      try {
        if (socket.readyState == WebSocket.open) {
          socket.add(jsonEncode({'type': 'CloseStream'}));
        }
        await socket.close();
      } catch (e) {
        debugPrint("[RemoteStt] Socket close failed: $e");
      }
    }
  }

  /// Deepgram wraps transcripts in a Results envelope; anything else on the
  /// socket (metadata, keep-alives) is not a transcript.
  SttResult? _parseTranscript(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['type'] != 'Results') return null;

      final alternatives =
          decoded['channel']?['alternatives'] as List<dynamic>?;
      if (alternatives == null || alternatives.isEmpty) return null;

      final transcript = alternatives.first?['transcript'];
      if (transcript is! String || transcript.trim().isEmpty) return null;

      return SttResult(
        transcript.trim(),
        isFinal: decoded['is_final'] == true,
      );
    } catch (e) {
      debugPrint("[RemoteStt] Could not parse message: $e");
      return null;
    }
  }

  /// RMS of a little-endian 16-bit PCM chunk, normalised to 0..1 and eased so
  /// the meter responds the way the on-device one does.
  double _levelOf(Uint8List chunk) {
    if (chunk.length < 2) return 0.0;
    final samples = chunk.buffer.asInt16List(
      chunk.offsetInBytes,
      chunk.lengthInBytes ~/ 2,
    );
    if (samples.isEmpty) return 0.0;

    var sum = 0.0;
    for (final sample in samples) {
      final normalised = sample / 32768.0;
      sum += normalised * normalised;
    }
    final rms = math.sqrt(sum / samples.length);
    return (rms * 3.0).clamp(0.0, 1.0);
  }
}
