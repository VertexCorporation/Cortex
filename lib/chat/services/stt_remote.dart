// lib/chat/services/stt_remote.dart
//
// Realtime speech for Voice Mode and Flow Mode.
//
// The microphone streams straight to Deepgram (nova-3 multilingual) with
// AssemblyAI universal-3-5-pro as the live fallback, rather than through
// Fulcrum. Both providers run on short-lived tokens minted by the server, so
// the server only has to mint one and settle it — the audio itself never
// touches our infrastructure, which keeps latency to a single hop and the
// Cloud Function bill to one short call per session.
//
// Everything here degrades to false/null rather than throwing. The caller
// keeps the on-device recognizer as the final fallback, so a failure means
// "use the other engine", not "voice mode is broken".
//
// Ordinary prompt dictation deliberately does NOT come through here: it runs
// on the device's native recognizer (see speech.dart, SpeechOwner.dictation)
// and spends no remote speech credits.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:record/record.dart';

/// One transcript update. Deepgram sends a running best guess and then a
/// settled version of the same span; [isFinal] separates them so the caller
/// can replace rather than append.
class SttResult {
  const SttResult(this.text, {required this.isFinal});

  final String text;
  final bool isFinal;
}

class _SpeechLease {
  const _SpeechLease({
    required this.token,
    required this.sessionId,
    required this.provider,
    this.allowanceVoiceSeconds,
    this.remainingVoiceSeconds,
    this.reservedVoiceSeconds,
  });

  final String token;
  final String? sessionId;
  final String provider;
  final int? allowanceVoiceSeconds;
  final int? remainingVoiceSeconds;
  final int? reservedVoiceSeconds;
}

/// What the server told us when it minted the realtime-speech window: the
/// provider chosen, the usage session the settlement is booked under, and
/// the daily realtime-voice allowance state as the SERVER sees it. The
/// provider access token deliberately does not appear here — it never leaves
/// this service.
class SttLease {
  const SttLease({
    required this.provider,
    this.sessionId,
    this.allowanceVoiceSeconds,
    this.remainingVoiceSeconds,
    this.reservedVoiceSeconds,
  });

  final String provider;
  final String? sessionId;

  /// Daily realtime Voice/Flow allowance for the user's tier, in seconds.
  /// Null when the server predates the allowance contract.
  final int? allowanceVoiceSeconds;

  /// Seconds left in the pool AFTER this window's reservation.
  final int? remainingVoiceSeconds;

  /// Seconds reserved for THIS window.
  final int? reservedVoiceSeconds;
}

class RemoteSttService {
  RemoteSttService._();
  static final RemoteSttService instance = RemoteSttService._();

  static const String _tokenEndpoint =
      "https://getspeechtoken-o5h7dmtija-ew.a.run.app";
  static const String _assemblyTokenEndpoint =
      "https://getassemblytoken-o5h7dmtija-ew.a.run.app";
  static const String _settleUsageEndpoint =
      "https://settlespeechusage-o5h7dmtija-ew.a.run.app";

  // Raw PCM at 16 kHz mono: what Deepgram expects for linear16, and small
  // enough to stream comfortably on mobile data.
  static const int _sampleRate = 16000;

  /// `language=multi` selects nova-3 multilingual. Turkish is not covered by
  /// the cheaper monolingual model, so this is not an optional upgrade.
  static const String _listenUrl = "wss://api.deepgram.com/v1/listen"
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

  /// Session epoch, bumped on every lifecycle boundary. Listeners capture it
  /// when they are created; a callback that fires for a session that is no
  /// longer current is dropped instead of tearing down its successor — a
  /// stale WebSocket's late onDone used to stop() whatever session had
  /// replaced it.
  int _epoch = 0;

  /// Serializes start/stop through one queue: a second rapid start waits for
  /// the first to settle instead of opening a second microphone on top of
  /// the first recorder (the ghost-microphone race), and stop can never
  /// interleave with an in-flight start.
  Future<void>? _gate;

  /// Everything a caller can do to the lifecycle goes through here.
  Future<T> _exclusive<T>(Future<T> Function() action) {
    final previous = _gate ?? Future<void>.value();
    final result = previous.then((_) => action());
    _gate = result.then((_) {}, onError: (Object _) {});
    return result;
  }
  String? _provider;
  String? _sessionId;
  double? _providerDurationSeconds;
  double? _providerSessionDurationSeconds;
  String? _providerRequestId;
  DateTime? _sessionStartedAt;

  // Enough of the session to tell the difference between a microphone that
  // never produced anything, audio that Deepgram never answered, and a
  // transcript that arrived. A session the user simply ends leaves no other
  // trace, so "it did nothing" and "it worked" looked identical from here.
  int _chunksSent = 0;
  int _transcriptsSeen = 0;

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

  /// True when the most recent token request was refused because the user's
  /// daily realtime-voice allowance is exhausted (server 403
  /// voice_daily_limit). Reset at the start of every new session attempt.
  /// The caller uses this to explain the failure to the user instead of
  /// showing a generic dead microphone.
  bool dailyVoiceLimitReached = false;

  /// Build number and hardware, attached to every report.
  ///
  /// Two testers on two builds produced logs that could not be told apart,
  /// and the microphone question is a hardware question — which phone, which
  /// Android — so guessing at it from the server was hopeless. Gathered once
  /// and cached; failures are rare and this must never be the reason one goes
  /// unreported.
  Map<String, dynamic>? _context;

  Future<Map<String, dynamic>> _deviceContext() async {
    final cached = _context;
    if (cached != null) return cached;

    final gathered = <String, dynamic>{};
    try {
      gathered["build"] = (await PackageInfo.fromPlatform()).buildNumber;
    } catch (_) {}
    try {
      final plugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await plugin.androidInfo;
        gathered["device"] = "${a.manufacturer} ${a.model}";
        gathered["os"] = "Android ${a.version.release} (SDK ${a.version.sdkInt})";
      } else if (Platform.isIOS) {
        final i = await plugin.iosInfo;
        gathered["device"] = i.utsname.machine;
        gathered["os"] = "iOS ${i.systemVersion}";
      }
    } catch (_) {}

    _context = gathered;
    return gathered;
  }

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
        data: <String, dynamic>{
          'lastFailure': failure,
          'reportOnly': true,
          ...await _deviceContext(),
        },
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
  Future<_SpeechLease?> _fetchToken({String? mode}) async {
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
          if (previousFailure != null) ...{
            'lastFailure': previousFailure,
            ...await _deviceContext(),
          },
          'mode': ?mode,
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
        dailyVoiceLimitReached = response.statusCode == 403 &&
            response.data?['error'] == 'voice_daily_limit';
        debugPrint("[RemoteStt] Token declined: HTTP ${response.statusCode}");
        return null;
      }
      final token = response.data?['token'];
      if (token is! String || token.isEmpty) return null;
      final sessionId = response.data?['sessionId'];
      final voice = _readVoiceFields(response.data);
      return _SpeechLease(
        token: token,
        sessionId: sessionId is String ? sessionId : null,
        provider: response.data?['provider'] == 'assemblyai' ? 'assemblyai' : 'deepgram',
        allowanceVoiceSeconds: voice?['allowanceSeconds'],
        remainingVoiceSeconds: voice?['remainingSeconds'],
        reservedVoiceSeconds: voice?['reservedSeconds'],
      );
    } catch (e) {
      debugPrint("[RemoteStt] Token request failed: $e");
      return null;
    }
  }

  /// Parses the server's `voice` allowance block from a mint response.
  /// Null values everywhere when the server predates the allowance contract.
  static Map<String, int?>? _readVoiceFields(Map<String, dynamic>? data) {
    final voice = data?['voice'];
    if (voice is! Map) return null;
    int? read(String key) {
      final value = voice[key];
      return value is num ? value.round() : null;
    }
    return {
      'allowanceSeconds': read('allowanceSeconds'),
      'remainingSeconds': read('remainingSeconds'),
      'reservedSeconds': read('reservedSeconds'),
    };
  }

  Future<_SpeechLease?> _fetchAssemblyToken({String? mode}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final idToken = await user.getIdToken();
      if (idToken == null) return null;

      final response = await _dio.post<Map<String, dynamic>>(
        _assemblyTokenEndpoint,
        data: mode == null
            ? const <String, dynamic>{}
            : <String, dynamic>{'mode': mode},
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          validateStatus: (_) => true,
        ),
      );
      if (response.statusCode != 200) {
        dailyVoiceLimitReached = response.statusCode == 403 &&
            response.data?['error'] == 'voice_daily_limit';
        return null;
      }
      final token = response.data?['token'];
      if (token is! String || token.isEmpty) return null;
      final sessionId = response.data?['sessionId'];
      final voice = _readVoiceFields(response.data);
      return _SpeechLease(
        token: token,
        sessionId: sessionId is String ? sessionId : null,
        provider: 'assemblyai',
        allowanceVoiceSeconds: voice?['allowanceSeconds'],
        remainingVoiceSeconds: voice?['remainingSeconds'],
        reservedVoiceSeconds: voice?['reservedSeconds'],
      );
    } catch (e) {
      debugPrint("[RemoteStt] AssemblyAI token request failed: $e");
      return null;
    }
  }

  Future<bool> _startAssemblyAi({
    required AudioRecorder recorder,
    required String token,
    required int epoch,
    String? sessionId,
    required void Function(SttResult result) onResult,
    void Function()? onClosed,
  }) async {
    try {
      // Temporary tokens must be redeemed via the `token` query parameter —
      // the documented interface for one-time streaming tokens — and the
      // speech_model must mirror the label/rate Fulcrum books usage under
      // ("universal-3-5-pro"). Uri.replace encodes the token safely.
      final assemblyUrl =
          Uri.parse('wss://streaming.assemblyai.com/v3/ws').replace(
        queryParameters: {
          'sample_rate': '$_sampleRate',
          'speech_model': 'universal-3-5-pro',
          'token': token,
        },
      );
      _socket = await WebSocket.connect(assemblyUrl.toString())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint("[RemoteStt] AssemblyAI connect failed: $e");
      _socket = null;
      return false;
    }

    _recorder = recorder;
    _provider = 'assemblyai';
    _sessionId = sessionId;
    _sessionStartedAt = DateTime.now();
    _socket!.listen(
      (dynamic message) {
        if (epoch != _epoch) return;
        if (message is! String) return;
        _captureAssemblyUsage(message);
        final result = _parseAssemblyTranscript(message);
        if (result != null) onResult(result);
      },
      onError: (Object e) {
        if (epoch != _epoch) return;
        debugPrint("[RemoteStt] AssemblyAI socket error: $e");
        unawaited(stop());
        onClosed?.call();
      },
      onDone: () {
        if (epoch != _epoch) return;
        if (!_closing) onClosed?.call();
        unawaited(stop());
      },
      cancelOnError: true,
    );

    // The microphone is already streaming from _openMicrophone: its
    // subscription reads _socket on every chunk, so the live audio (and
    // anything buffered in _pending while the socket was opening) flows to
    // AssemblyAI from here on without restarting the recorder.
    return true;
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
    void Function(SttLease lease)? onLease,
    String? mode,
  }) {
    // Serialized with every other lifecycle operation: rapid repeated calls
    // can never open a second microphone or socket on top of the first — the
    // race that used to leave a ghost recorder streaming forever.
    return _exclusive(() => _startInternal(
          onResult: onResult,
          onClosed: onClosed,
          onLease: onLease,
          mode: mode,
        ));
  }

  Future<bool> _startInternal({
    required void Function(SttResult result) onResult,
    void Function()? onClosed,
    void Function(SttLease lease)? onLease,
    String? mode,
  }) async {
    final int epoch = ++_epoch;
    dailyVoiceLimitReached = false;
    // Defense in depth: a previous session that somehow survived is torn
    // down before anything new opens — exactly one recorder and one socket
    // may exist at any moment.
    if (_socket != null || _recorder != null || _micSubscription != null) {
      await _stopInternal();
      if (epoch != _epoch) return false;
    }
    _closing = false;
    _pending.clear();

    final recorder = AudioRecorder();
    try {
      if (!await recorder.hasPermission()) {
        // Reported like any other failure. This one returns before a token is
        // ever needed, so without saying so explicitly a device that simply
        // never got microphone permission is invisible from the server —
        // indistinguishable from a tester who did not try.
        _fail("PERMISSION_DENIED");
        unawaited(_report());
        await recorder.dispose();
        return false;
      }
    } catch (e) {
      _fail("PERMISSION_CHECK_FAILED", e);
      unawaited(_report());
      await recorder.dispose();
      return false;
    }

    _recorder = recorder;

    void announceLease(_SpeechLease lease) {
      onLease?.call(SttLease(
        provider: lease.provider,
        sessionId: lease.sessionId,
        allowanceVoiceSeconds: lease.allowanceVoiceSeconds,
        remainingVoiceSeconds: lease.remainingVoiceSeconds,
        reservedVoiceSeconds: lease.reservedVoiceSeconds,
      ));
    }

    // ── 1. A microphone that is actually recording ──
    if (!await _openMicrophone(recorder, epoch: epoch, onClosed: onClosed)) {
      // Nothing further will be requested, so this failure would never reach
      // the server on its own — and a microphone that never yields audio is
      // exactly the failure worth seeing. Reported explicitly, without buying
      // anything.
      unawaited(_report());
      await _stopInternal();
      return false;
    }

    // ── 2. Now that there is audio to send, buy a token ──
    final lease = await _fetchToken(mode: mode);
    if (lease == null) {
      // Deepgram is out of tokens; AssemblyAI takes over the same live
      // microphone before the session is torn down.
      final assemblyLease = await _fetchAssemblyToken(mode: mode);
      if (assemblyLease != null) {
        final startedAssembly = await _startAssemblyAi(
          recorder: recorder,
          token: assemblyLease.token,
          sessionId: assemblyLease.sessionId,
          epoch: epoch,
          onResult: onResult,
          onClosed: onClosed,
        );
        if (startedAssembly) {
          announceLease(assemblyLease);
          return true;
        }
      }
      _fail("NO_TOKEN");
      await _stopInternal();
      return false;
    }

    // ── 3. The socket. Speech captured while it opens is buffered, so the
    //       first word survives the round trip. ──
    try {
      _socket = await WebSocket.connect(
        _listenUrl,
        headers: {'Authorization': 'Bearer ${lease.token}'},
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      _fail("CONNECT_FAILED", e);
      _socket = null;
      // Deepgram's door did not open; AssemblyAI takes over the same live
      // microphone before the session is torn down.
      final assemblyLease = await _fetchAssemblyToken(mode: mode);
      if (assemblyLease != null) {
        final startedAssembly = await _startAssemblyAi(
          recorder: recorder,
          token: assemblyLease.token,
          sessionId: assemblyLease.sessionId,
          epoch: epoch,
          onResult: onResult,
          onClosed: onClosed,
        );
        if (startedAssembly) {
          announceLease(assemblyLease);
          return true;
        }
      }
      await _stopInternal();
      return false;
    }

    _provider = 'deepgram';
    _sessionId = lease.sessionId;
    _sessionStartedAt = DateTime.now();

    _socket!.listen(
      (dynamic message) {
        if (epoch != _epoch) return;
        if (message is! String) return;
        _captureDeepgramUsage(message);
        final result = _parseTranscript(message);
        if (result != null) {
          _transcriptsSeen++;
          onResult(result);
        }
      },
      onError: (Object e) {
        if (epoch != _epoch) return;
        _fail("SOCKET_ERROR", e);
        unawaited(stop());
        onClosed?.call();
      },
      onDone: () {
        if (epoch != _epoch) return;
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

    announceLease(lease);
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
    required int epoch,
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
          // A microphone owned by a superseded session must not feed a
          // successor's socket.
          if (epoch != _epoch) return;
          if (!(_firstChunk?.isCompleted ?? true)) _firstChunk!.complete();
          _chunksSent++;
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
  Future<void> stop() {
    // Serialized with start: a stop issued while a start is still connecting
    // waits its turn and then tears the session down, and repeated stops are
    // safe by construction.
    return _exclusive(_stopInternal);
  }

  Future<void> _stopInternal() async {
    // Invalidate every listener created by the session being stopped FIRST:
    // a late socket onDone or mic error arriving after this point must find
    // its epoch stale and do nothing.
    ++_epoch;

    // A session that captured audio and got nothing back is the case with no
    // other symptom: the socket behaved, the waveform moved, and the text
    // field stayed empty. Record it before the counters are cleared.
    if (_chunksSent > 0 && _transcriptsSeen == 0 && _socket != null) {
      _fail("NO_TRANSCRIPT", "chunks=$_chunksSent");
      // Sent now rather than waiting to ride along with the next token
      // request: a user who gets nothing back tends not to try again, and
      // that is exactly the session worth hearing about.
      unawaited(_report());
    }
    _chunksSent = 0;
    _transcriptsSeen = 0;

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
    final provider = _provider;
    final sessionId = _sessionId;
    final startedAt = _sessionStartedAt;
    _socket = null;
    if (socket != null) {
      try {
        if (socket.readyState == WebSocket.open) {
          socket.add(jsonEncode({
            'type': provider == 'assemblyai' ? 'Terminate' : 'CloseStream',
          }));
          // Let the provider deliver its final usage metadata before closing.
          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
        await socket.close();
      } catch (e) {
        debugPrint("[RemoteStt] Socket close failed: $e");
      }
    }
    await _settleUsage(
      provider: provider,
      sessionId: sessionId,
      fallbackDurationSeconds: startedAt == null
          ? 0
          : DateTime.now().difference(startedAt).inMilliseconds / 1000.0,
    );
    _provider = null;
    _sessionId = null;
    _providerDurationSeconds = null;
    _providerSessionDurationSeconds = null;
    _providerRequestId = null;
    _sessionStartedAt = null;
  }

  Future<void> _settleUsage({
    required String? provider,
    required String? sessionId,
    required double fallbackDurationSeconds,
  }) async {
    if (provider == null || sessionId == null) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) return;
      await _dio.post<void>(
        _settleUsageEndpoint,
        data: <String, dynamic>{
          'provider': provider,
          'sessionId': sessionId,
          if (_providerRequestId != null) 'requestId': _providerRequestId,
          'durationSeconds': _providerDurationSeconds ?? fallbackDurationSeconds,
          if (_providerSessionDurationSeconds != null)
            'sessionDurationSeconds': _providerSessionDurationSeconds,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          validateStatus: (_) => true,
        ),
      );
    } catch (e) {
      debugPrint('[RemoteStt] Usage settlement failed: $e');
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

  void _captureDeepgramUsage(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic> && decoded['type'] == 'Metadata') {
        final requestId = decoded['request_id'];
        if (requestId is String && requestId.isNotEmpty) {
          _providerRequestId = requestId;
        }
        final duration = num.tryParse('${decoded['duration'] ?? ''}');
        if (duration != null && duration >= 0) {
          _providerDurationSeconds = duration.toDouble();
        }
      }
    } catch (_) {}
  }

  void _captureAssemblyUsage(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic> && decoded['type'] == 'Termination') {
        final audio = num.tryParse('${decoded['audio_duration_seconds'] ?? ''}');
        final session = num.tryParse('${decoded['session_duration_seconds'] ?? ''}');
        if (audio != null && audio >= 0) _providerDurationSeconds = audio.toDouble();
        if (session != null && session >= 0) _providerSessionDurationSeconds = session.toDouble();
      }
    } catch (_) {}
  }

  SttResult? _parseAssemblyTranscript(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || decoded['type'] != 'Turn') {
        return null;
      }

      final transcript = decoded['transcript'];
      if (transcript is! String || transcript.trim().isEmpty) return null;

      return SttResult(
        transcript.trim(),
        isFinal: decoded['end_of_turn'] == true,
      );
    } catch (e) {
      debugPrint("[RemoteStt] Could not parse AssemblyAI message: $e");
      return null;
    }
  }

  /// RMS of a little-endian 16-bit PCM chunk, normalised to 0..1 and eased so
  /// the meter responds the way the on-device one does.
  double _levelOf(Uint8List chunk) {
    final int byteCount = chunk.lengthInBytes;
    final int sampleCount = byteCount ~/ 2;
    if (sampleCount == 0) return 0.0;

    // The recorder can hand us views whose byte offset is odd (seen live as
    // "Offset (5) must be a multiple of BYTES_PER_ELEMENT"), which
    // asInt16List rejects outright and took the whole app down with it.
    // ByteData reads are alignment-agnostic, so walk the samples directly
    // instead of slicing an Int16 view.
    final bytes = ByteData.view(chunk.buffer, chunk.offsetInBytes, byteCount);
    var sum = 0.0;
    for (var i = 0; i < sampleCount; i++) {
      final normalised = bytes.getInt16(i * 2, Endian.little) / 32768.0;
      sum += normalised * normalised;
    }
    final rms = math.sqrt(sum / sampleCount);
    return (rms * 3.0).clamp(0.0, 1.0);
  }
}
