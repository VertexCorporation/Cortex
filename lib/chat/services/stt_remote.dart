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

  /// Why the last attempt fell back, carried to the server on the next token
  /// request.
  ///
  /// Everything in this file degrades to false rather than throwing, which is
  /// right for the user and useless for diagnosis: a failure is indistinguishable
  /// from the feature not existing, and the only trace is a `debugPrint` on a
  /// device we do not have. Piggy-backing the reason onto a call the client
  /// already makes puts it in the function logs instead, with no new endpoint
  /// and nothing extra on the happy path.
  String? _lastFailure;

  void _fail(String code, [Object? detail]) {
    _lastFailure = detail == null ? code : "$code: $detail";
    debugPrint("[RemoteStt] $_lastFailure");
  }

  /// Asks the server for a short-lived Deepgram token. Returns null when
  /// dictation is unavailable — no session, no balance, provider down.
  Future<String?> _fetchToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final idToken = await user.getIdToken();
      if (idToken == null) return null;

      final previousFailure = _lastFailure;
      _lastFailure = null;

      final response = await _dio.post<Map<String, dynamic>>(
        _tokenEndpoint,
        data: <String, dynamic>{
          if (previousFailure != null) 'lastFailure': previousFailure,
        },
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
        _fail("PERMISSION_DENIED");
        await recorder.dispose();
        return false;
      }
    } catch (e) {
      _fail("PERMISSION_CHECK_FAILED", e);
      await recorder.dispose();
      return false;
    }

    final token = await _fetchToken();
    if (token == null) {
      _fail("NO_TOKEN");
      await recorder.dispose();
      return false;
    }

    try {
      _socket = await WebSocket.connect(
        _listenUrl,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      _fail("CONNECT_FAILED", e);
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
        _fail("SOCKET_ERROR", e);
        unawaited(stop());
        onClosed?.call();
      },
      onDone: () {
        // A close we did not ask for carries Deepgram's reason for it.
        if (!_closing) {
          final socket = _socket;
          _fail(
            "SOCKET_CLOSED",
            "code=${socket?.closeCode} reason=${socket?.closeReason}",
          );
          onClosed?.call();
        }
        unawaited(stop());
      },
      cancelOnError: true,
    );

    final stream = await _openMicrophone(recorder);
    if (stream == null) {
      await stop();
      return false;
    }

    _micSubscription = stream.listen(
      (chunk) {
        soundLevel.value = _levelOf(chunk);
        final socket = _socket;
        if (socket != null && socket.readyState == WebSocket.open) {
          socket.add(chunk);
        }
      },
      onError: (Object e) {
        _fail("MIC_ERROR", e);
        unawaited(stop());
        onClosed?.call();
      },
      cancelOnError: true,
    );

    return true;
  }

  /// Opens the microphone, dropping the audio effects if they are what the
  /// device objects to.
  ///
  /// `echoCancel` and `noiseSuppress` map onto Android's AcousticEchoCanceler
  /// and NoiseSuppressor, which are hardware features a lot of older phones
  /// simply do not have. Asking for them there can fail the whole recording
  /// rather than being ignored, so the second attempt gives them up: worse
  /// audio for Deepgram to work with beats no audio at all.
  Future<Stream<Uint8List>?> _openMicrophone(AudioRecorder recorder) async {
    const base = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: 1,
      echoCancel: true,
      noiseSuppress: true,
    );

    try {
      return await recorder.startStream(base);
    } catch (e) {
      _fail("MIC_START_FAILED", e);
    }

    try {
      return await recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
      ));
    } catch (e) {
      _fail("MIC_START_FAILED_PLAIN", e);
      return null;
    }
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

      // Deepgram reports a rejected request as a message on the open socket
      // rather than by refusing the upgrade — a bad model or an unsupported
      // language arrives here, not at connect time. Dropping everything that
      // is not a transcript would turn that into silence with no explanation.
      final type = decoded['type'];
      if (type == 'Error' || decoded['err_code'] != null) {
        _fail(
          "DEEPGRAM_ERROR",
          decoded['err_msg'] ?? decoded['description'] ?? raw,
        );
        return null;
      }

      if (type != 'Results') return null;

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
