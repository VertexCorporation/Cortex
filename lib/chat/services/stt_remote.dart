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

  /// How long to wait for the first buffer before deciding a microphone is
  /// not going to produce one. Android normally delivers within a couple of
  /// hundred milliseconds, and nothing waits on the full window when it does.
  static const Duration _audioProbe = Duration(milliseconds: 1500);

  /// Speech captured while the socket is still being opened, so the opening
  /// words are not lost. Bounded: a socket that never arrives must not grow
  /// this without limit. 200 buffers of 16 kHz mono is a few seconds.
  static const int _maxPendingChunks = 200;

  AudioRecorder? _recorder;
  WebSocket? _socket;
  StreamSubscription<Uint8List>? _micSubscription;
  final List<Uint8List> _pending = [];
  Completer<void>? _firstChunk;
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

  /// Sends the last failure on its own, buying nothing.
  ///
  /// Used when the session ends before a token is needed. The server
  /// recognises `reportOnly` and logs without charging, so diagnosing a broken
  /// microphone never costs the user credits.
  Future<void> _report() async {
    final failure = _lastFailure;
    if (failure == null) return;
    _lastFailure = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final idToken = await user.getIdToken();
      if (idToken == null) return;

      await _dio.post<Map<String, dynamic>>(
        _tokenEndpoint,
        data: <String, dynamic>{'lastFailure': failure, 'reportOnly': true},
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          validateStatus: (_) => true,
        ),
      );
    } catch (e) {
      debugPrint("[RemoteStt] Could not report failure: $e");
    }
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
  ///
  /// The microphone is opened and proven to be producing audio *before* a
  /// token is asked for. That ordering matters twice over. A grant costs the
  /// user credits, and a device whose microphone yields nothing was being
  /// charged for a session that could never transcribe a word. It also fixes
  /// the diagnosis: Deepgram closes an idle socket with a generic timeout, so
  /// a silent microphone used to surface as a network-looking error several
  /// steps away from the actual fault.
  Future<bool> start({
    required void Function(SttResult result) onResult,
    void Function()? onClosed,
  }) async {
    if (_socket != null) return true;
    _closing = false;
    _pending.clear();

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

    _recorder = recorder;

    // ── 1. A microphone that is actually recording ──
    if (!await _openMicrophone(recorder, onClosed: onClosed)) {
      // Nothing further will be requested, so this failure would never reach
      // the server on its own — and a microphone that never yields audio is
      // exactly the failure worth seeing. Reported explicitly, without buying
      // anything.
      unawaited(_report());
      await stop();
      return false;
    }

    // ── 2. Now that there is audio to send, buy a token ──
    final token = await _fetchToken();
    if (token == null) {
      _fail("NO_TOKEN");
      await stop();
      return false;
    }

    // ── 3. The socket. Speech captured while it opens is buffered, so the
    //       first word survives the round trip. ──
    try {
      _socket = await WebSocket.connect(
        _listenUrl,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      _fail("CONNECT_FAILED", e);
      await stop();
      return false;
    }

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

    return true;
  }

  /// Starts recording and waits for the device to prove it by handing over a
  /// buffer.
  ///
  /// `echoCancel` and `noiseSuppress` make record_android ask for the
  /// VOICE_COMMUNICATION audio source instead of the plain microphone. On some
  /// hardware that source starts without complaint and then stays silent
  /// forever — `startStream` succeeds, `isRecording` reports true, and not one
  /// buffer ever arrives. Waiting for real audio is the only way to catch it,
  /// since nothing throws.
  ///
  /// The second attempt gives up the effects. Worse audio for Deepgram to work
  /// with beats no audio at all.
  Future<bool> _openMicrophone(
    AudioRecorder recorder, {
    void Function()? onClosed,
  }) async {
    const withEffects = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: 1,
      echoCancel: true,
      noiseSuppress: true,
    );
    const plain = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: 1,
    );

    for (final attempt in const [
      (config: withEffects, label: "with_effects"),
      (config: plain, label: "plain"),
    ]) {
      final Stream<Uint8List> stream;
      try {
        stream = await recorder.startStream(attempt.config);
      } catch (e) {
        _fail("MIC_START_FAILED_${attempt.label}", e);
        continue;
      }

      _firstChunk = Completer<void>();
      _micSubscription = stream.listen(
        (chunk) {
          if (!(_firstChunk?.isCompleted ?? true)) _firstChunk!.complete();
          soundLevel.value = _levelOf(chunk);

          final socket = _socket;
          if (socket != null && socket.readyState == WebSocket.open) {
            if (_pending.isNotEmpty) {
              for (final held in _pending) {
                socket.add(held);
              }
              _pending.clear();
            }
            socket.add(chunk);
          } else if (_pending.length < _maxPendingChunks) {
            _pending.add(chunk);
          }
        },
        onError: (Object e) {
          _fail("MIC_ERROR", e);
          unawaited(stop());
          onClosed?.call();
        },
        cancelOnError: true,
      );

      var gotAudio = true;
      try {
        await _firstChunk!.future.timeout(_audioProbe);
      } on TimeoutException {
        gotAudio = false;
      }

      if (gotAudio) return true;

      var recording = false;
      try {
        recording = await recorder.isRecording();
      } catch (_) {}
      _fail(
        "NO_AUDIO_${attempt.label}",
        "isRecording=$recording after ${_audioProbe.inMilliseconds}ms",
      );

      await _micSubscription?.cancel();
      _micSubscription = null;
      _pending.clear();
      try {
        await recorder.stop();
      } catch (_) {}
    }

    return false;
  }

  /// Closes the microphone and the socket, asking Deepgram to flush whatever
  /// it is still holding so the last words are not lost.
  Future<void> stop() async {
    _closing = true;
    soundLevel.value = 0.0;
    _pending.clear();
    _firstChunk = null;

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
