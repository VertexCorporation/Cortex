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
import 'package:cortex/network/fulcrum_http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:record/record.dart';

import 'voice_health.dart';

/// One transcript update. Deepgram sends a running best guess and then a
/// settled version of the same span; [isFinal] separates them so the caller
/// can replace rather than append.
///
/// [confidence] is the provider's own confidence for this span (0..1), when
/// the provider reports one — Deepgram publishes it on every alternative,
/// AssemblyAI on every turn. Null means "unknown" (native fallback or a
/// provider payload without the field); consumers must treat it as
/// "cannot judge", never as zero.
class SttResult {
  const SttResult(this.text, {required this.isFinal, this.confidence});

  final String text;
  final bool isFinal;
  final double? confidence;
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

/// How the caller should react to a provider socket that closed on its own.
///
/// Deepgram's close frames are documented ("STT Troubleshooting WebSocket,
/// NET, and DATA Errors"): `1011`/`NET-0000` is a server-side fault, `1011`/
/// `NET-0001` means the client went silent, `1011`/`NET-0002` is the
/// no-audio idle timeout whose close reason carries `no_audio_timeout`, and
/// `1008`/`DATA-0000` means the submitted audio itself could not be decoded.
/// `1002` is a WebSocket protocol error. The class carries the DECISION so
/// VoiceService can pick a reconnect policy without knowing provider
/// internals; `1011` alone is not fatal.
enum SttCloseClass {
  /// Retry the connection: server-side hiccup (NET-0000) or an abnormal
  /// close with no further detail (network drop).
  reconnect,

  /// Retry quickly and keep the line warm: the server said the client went
  /// silent (NET-0001) while our microphone was supposed to be streaming.
  reconnectImmediate,

  /// Retry after an extended backoff: the no-audio idle timeout
  /// (NET-0002 / `no_audio_timeout`) — the connection was idle long enough
  /// that hammering it again immediately buys nothing.
  reconnectExtended,

  /// Retrying the same stream cannot succeed (protocol error `1002`, or
  /// audio the provider cannot decode `1008`/DATA-0000). The session must
  /// end, not reconnect.
  fatal,
}

/// Everything the provider told us about a socket that closed on its own.
class SttCloseInfo {
  const SttCloseInfo({
    required this.provider,
    required this.closeClass,
    this.closeCode,
    this.closeReason,
    this.msgCode,
  });

  /// 'deepgram' or 'assemblyai' — the session that died.
  final String provider;

  /// The WebSocket close status code, when the close frame exposed one.
  final int? closeCode;

  /// The UTF-8 close-reason payload, when the close frame exposed one.
  final String? closeReason;

  /// The provider's diagnostic code for the failure, when one surfaced —
  /// e.g. Deepgram `NET-0002` from the Error message that arrives just
  /// before the close. Null when neither the close frame nor any error
  /// message carried one; [closeClass] still decides the policy.
  final String? msgCode;

  /// The recommended reaction.
  final SttCloseClass closeClass;

  /// True when retrying the same stream cannot succeed — the session must
  /// end rather than reconnect.
  bool get isFatal => closeClass == SttCloseClass.fatal;

  /// Classifies a provider socket close using only what the provider
  /// actually surfaced — no invented detail. Priority: an explicit
  /// `msg_code` from the last Error message (the provider's own code, e.g.
  /// `NET-0002`), then the documented `no_audio_timeout` close-reason
  /// marker, then the raw close status code. Anything unrecognized keeps
  /// the historic behavior: a recoverable close that the caller may
  /// reconnect from.
  static SttCloseClass classify({
    required String provider,
    int? closeCode,
    String? closeReason,
    String? msgCode,
  }) {
    if (provider == 'deepgram') {
      switch (msgCode) {
        case 'NET-0000':
          return SttCloseClass.reconnect;
        case 'NET-0001':
          return SttCloseClass.reconnectImmediate;
        case 'NET-0002':
          return SttCloseClass.reconnectExtended;
      }
      // NET-0002's close reason carries `no_audio_timeout` even when the
      // Error message never made it before the close frame.
      if (closeReason != null && closeReason.contains('no_audio_timeout')) {
        return SttCloseClass.reconnectExtended;
      }
    }
    switch (closeCode) {
      // Protocol error: retrying the same stream cannot fix the handshake.
      case 1002:
        return SttCloseClass.fatal;
      // DATA-0000: the payload could not be decoded as audio — a retry of
      // the same encoder/config fails identically.
      case 1008:
        return SttCloseClass.fatal;
      // A server-side fault the close frame attributes no NET code to.
      case 1011:
        return SttCloseClass.reconnect;
      // Abnormal close with no close frame at all (network drop): the
      // historic reconnect behavior.
      default:
        return SttCloseClass.reconnect;
    }
  }
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
  static const String _listenUrl =
      "wss://api.deepgram.com/v1/listen"
      "?model=nova-3&language=multi&encoding=linear16"
      "&sample_rate=$_sampleRate&channels=1"
      "&interim_results=true&smart_format=true";

  final Dio _dio = createFulcrumHttp(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

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

  /// The callbacks of the ACTIVE capture, stored so a socket-only
  /// reconnect (see [reconnectSocket]) can reattach the same session's
  /// result/close/lease plumbing without re-opening the microphone.
  void Function(SttResult result)? _activeOnResult;
  void Function(SttCloseInfo info)? _activeOnClosed;
  void Function(SttLease lease)? _activeOnLease;
  String? _activeMode;

  /// When the last audio chunk actually reached the provider socket.
  /// KeepAlive is only sent while this is stale — never while audio frames
  /// are flowing (Deepgram's documented cadence is one `KeepAlive` every
  /// 3–5 seconds during expected gaps in audio).
  DateTime? _lastAudioSentAt;
  Timer? _keepAliveTimer;

  /// ── Capture-path health (real-device regression guard) ──
  ///
  /// A device log showed a session that claimed to be listening while the
  /// recorder had been silently paused by Android audio-focus churn: the
  /// socket stayed alive, KeepAlive frames flowed, and the only symptom was
  /// that no transcript ever arrived again. These counters make the capture
  /// path itself observable — a frame that is received from the microphone,
  /// a frame that is forwarded to the socket, and a transcript coming back
  /// are three different facts — and [_captureWatchdog] restarts the
  /// recorder when the first one stalls. See [captureStalled].

  /// When the last PCM frame was RECEIVED from the recorder, whether or not
  /// a socket was open to forward it to. Distinct from [_lastAudioSentAt]:
  /// a socket gap must not be misread as a microphone gap (and vice versa).
  DateTime? _lastMicFrameAt;

  /// When the current recorder last proved itself by delivering its first
  /// frame. Null until the capture opens.
  DateTime? _micOpenedAt;

  /// When the last transcript (interim or final) arrived from the provider.
  DateTime? _lastTranscriptAt;

  /// The last state the recorder reported (RECORD/PAUSE/STOP), for the
  /// health line — a capture that paused without stopping is exactly the
  /// failure the watchdog exists for.
  String? _recorderState;

  StreamSubscription? _recorderStateSub;
  Timer? _captureWatchdog;
  bool _recoveringCapture = false;

  /// A healthy recorder delivers frames continuously — silence is still
  /// bytes — so a gap this long means the capture path itself is dead
  /// (observed live: audio-focus churn paused the recorder mid-session).
  static const Duration captureStallThreshold = Duration(seconds: 2);

  /// How often the watchdog samples the capture path. Much shorter than
  /// [captureStallThreshold] so recovery begins within a second of the
  /// stall becoming visible.
  static const Duration _watchdogTick = Duration(milliseconds: 500);

  /// Pure stall decision for the capture watchdog, clock-injected for
  /// tests: has the microphone failed to deliver a frame for longer than
  /// [threshold]?
  ///
  /// Before the first frame ever arrives the clock runs from [micOpenedAt]
  /// instead, so the watchdog does not race the ordinary start probe; a
  /// null [micOpenedAt] means nothing is open yet, which is not a stall.
  @visibleForTesting
  static bool captureStalled({
    required DateTime? lastMicFrameAt,
    required DateTime? micOpenedAt,
    required DateTime now,
    Duration threshold = captureStallThreshold,
  }) {
    final reference = lastMicFrameAt ?? micOpenedAt;
    return reference != null && now.difference(reference) >= threshold;
  }

  /// The `msg_code` of the last provider Error message (e.g. `NET-0002`),
  /// captured before the close frame: Deepgram surfaces the NET code in the
  /// error it sends just before closing; the close frame itself often does
  /// not repeat it.
  String? _lastErrorMsgCode;

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
        gathered["os"] =
            "Android ${a.version.release} (SDK ${a.version.sdkInt})";
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
        dailyVoiceLimitReached =
            response.statusCode == 403 &&
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
        provider: response.data?['provider'] == 'assemblyai'
            ? 'assemblyai'
            : 'deepgram',
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
        dailyVoiceLimitReached =
            response.statusCode == 403 &&
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
    void Function(SttCloseInfo info)? onClosed,
  }) async {
    try {
      // Temporary tokens must be redeemed via the `token` query parameter —
      // the documented interface for one-time streaming tokens — and the
      // speech_model must mirror the label/rate Fulcrum books usage under
      // ("universal-3-5-pro"). Uri.replace encodes the token safely.
      final assemblyUrl = Uri.parse('wss://streaming.assemblyai.com/v3/ws')
          .replace(
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
    _lastErrorMsgCode = null;
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
        final socket = _socket;
        _handleUnexpectedSocketDeath(
          epoch,
          SttCloseInfo(
            provider: 'assemblyai',
            closeCode: socket?.closeCode,
            closeReason: socket?.closeReason,
            closeClass: SttCloseInfo.classify(
              provider: 'assemblyai',
              closeCode: socket?.closeCode,
              closeReason: socket?.closeReason,
              msgCode: _lastErrorMsgCode,
            ),
          ),
          onClosed,
        );
      },
      onDone: () {
        if (epoch != _epoch) return;
        if (!_closing) {
          final socket = _socket;
          final info = SttCloseInfo(
            provider: 'assemblyai',
            closeCode: socket?.closeCode,
            closeReason: socket?.closeReason,
            closeClass: SttCloseInfo.classify(
              provider: 'assemblyai',
              closeCode: socket?.closeCode,
              closeReason: socket?.closeReason,
              msgCode: _lastErrorMsgCode,
            ),
          );
          _fail(
            "SOCKET_CLOSED",
            "code=${socket?.closeCode} reason=${socket?.closeReason}",
          );
          _handleUnexpectedSocketDeath(epoch, info, onClosed);
          return;
        }
        unawaited(stop());
      },
      cancelOnError: true,
    );

    // The microphone is already streaming from _openMicrophone: its
    // subscription reads _socket on every chunk, so the live audio (and
    // anything buffered in _pending while the socket was opening) flows to
    // AssemblyAI from here on without restarting the recorder.
    _startCaptureWatchdog(epoch);
    VoiceTelemetry.mark('STT socket open (assemblyai)');
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
    void Function(SttCloseInfo info)? onClosed,
    void Function(SttLease lease)? onLease,
    String? mode,
  }) {
    // Serialized with every other lifecycle operation: rapid repeated calls
    // can never open a second microphone or socket on top of the first — the
    // race that used to leave a ghost recorder streaming forever.
    return _exclusive(
      () => _startInternal(
        onResult: onResult,
        onClosed: onClosed,
        onLease: onLease,
        mode: mode,
      ),
    );
  }

  Future<bool> _startInternal({
    required void Function(SttResult result) onResult,
    void Function(SttCloseInfo info)? onClosed,
    void Function(SttLease lease)? onLease,
    String? mode,
  }) async {
    final int epoch = ++_epoch;
    dailyVoiceLimitReached = false;
    // Every transcript that reaches the caller also refreshes the health
    // clock — "last transcript received" is one of the facts the health line
    // reports, and the watchdog's recovery decisions are auditable from it.
    void stampedOnResult(SttResult result) {
      _lastTranscriptAt = DateTime.now();
      onResult(result);
    }

    // The active capture's plumbing is stored for socket-only reconnects.
    _activeOnResult = stampedOnResult;
    _activeOnClosed = onClosed;
    _activeOnLease = onLease;
    _activeMode = mode;
    _lastErrorMsgCode = null;
    _lastAudioSentAt = null;
    _lastMicFrameAt = null;
    _micOpenedAt = null;
    _lastTranscriptAt = null;
    _recorderState = null;
    _recoveringCapture = false;
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
          onResult: stampedOnResult,
          onClosed: onClosed,
        );
        if (startedAssembly) {
          _announceLease(assemblyLease, onLease);
          return true;
        }
      }
      _fail("NO_TOKEN");
      await _stopInternal();
      return false;
    }

    // ── 3. The socket. Speech captured while it opens is buffered, so the
    //       first word survives the round trip. ──
    final opened = await _openDeepgramSocket(
      lease: lease,
      epoch: epoch,
      onResult: stampedOnResult,
      onClosed: onClosed,
    );
    if (opened) {
      _announceLease(lease, onLease);
      return true;
    }
    // Deepgram's door did not open; AssemblyAI takes over the same live
    // microphone before the session is torn down.
    final assemblyLease = await _fetchAssemblyToken(mode: mode);
    if (assemblyLease != null) {
      final startedAssembly = await _startAssemblyAi(
        recorder: recorder,
        token: assemblyLease.token,
        sessionId: assemblyLease.sessionId,
        epoch: epoch,
        onResult: stampedOnResult,
        onClosed: onClosed,
      );
      if (startedAssembly) {
        _announceLease(assemblyLease, onLease);
        return true;
      }
    }
    await _stopInternal();
    return false;
  }

  /// Opens the Deepgram socket for a freshly minted lease — shared by the
  /// initial start and a socket-only reconnect. Returns false when the
  /// connect fails (the caller decides about the AssemblyAI takeover).
  Future<bool> _openDeepgramSocket({
    required _SpeechLease lease,
    required int epoch,
    required void Function(SttResult result) onResult,
    void Function(SttCloseInfo info)? onClosed,
  }) async {
    try {
      _socket = await WebSocket.connect(
        _listenUrl,
        headers: {'Authorization': 'Bearer ${lease.token}'},
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      _fail("CONNECT_FAILED", e);
      _socket = null;
      return false;
    }

    _provider = 'deepgram';
    _sessionId = lease.sessionId;
    _sessionStartedAt = DateTime.now();
    _lastErrorMsgCode = null;

    _attachDeepgramListeners(epoch, onResult: onResult, onClosed: onClosed);
    _startKeepAlive(epoch);
    _startCaptureWatchdog(epoch);
    VoiceTelemetry.mark('STT socket open (deepgram)');
    return true;
  }

  /// Wires the Deepgram socket's message/error/done handlers. Every handler
  /// is epoch-guarded, so listeners of a superseded session can never touch
  /// its successor. A close we did not ask for is CLASSIFIED (close code +
  /// close reason + the NET code the last Error message carried) and handed
  /// to [onClosed]; when the microphone is still alive the session is NOT
  /// torn down — the caller reconnects the socket alone and the capture
  /// keeps buffering into [_pending] until it lands.
  void _attachDeepgramListeners(
    int epoch, {
    required void Function(SttResult result) onResult,
    void Function(SttCloseInfo info)? onClosed,
  }) {
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
        final socket = _socket;
        final info = SttCloseInfo(
          provider: 'deepgram',
          closeCode: socket?.closeCode,
          closeReason: socket?.closeReason,
          msgCode: _lastErrorMsgCode,
          closeClass: SttCloseInfo.classify(
            provider: 'deepgram',
            closeCode: socket?.closeCode,
            closeReason: socket?.closeReason,
            msgCode: _lastErrorMsgCode,
          ),
        );
        _handleUnexpectedSocketDeath(epoch, info, onClosed);
      },
      onDone: () {
        if (epoch != _epoch) return;
        // A close we did not ask for carries Deepgram's reason for it.
        if (!_closing) {
          final socket = _socket;
          final info = SttCloseInfo(
            provider: 'deepgram',
            closeCode: socket?.closeCode,
            closeReason: socket?.closeReason,
            msgCode: _lastErrorMsgCode,
            closeClass: SttCloseInfo.classify(
              provider: 'deepgram',
              closeCode: socket?.closeCode,
              closeReason: socket?.closeReason,
              msgCode: _lastErrorMsgCode,
            ),
          );
          _fail(
            "SOCKET_CLOSED",
            "code=${socket?.closeCode} "
                "reason=${socket?.closeReason} msg=${info.msgCode}",
          );
          _handleUnexpectedSocketDeath(epoch, info, onClosed);
          return;
        }
        unawaited(stop());
      },
      cancelOnError: true,
    );
  }

  /// A provider socket died on its own. With a LIVE microphone the capture
  /// is recoverable: the recorder keeps streaming (chunks buffer into
  /// [_pending] while the socket is down) and the caller reconnects the
  /// socket alone — tearing down the mic would throw away the user's
  /// opening words. Without a live mic there is nothing to preserve, so
  /// everything is swept as before.
  void _handleUnexpectedSocketDeath(
    int epoch,
    SttCloseInfo info,
    void Function(SttCloseInfo info)? onClosed,
  ) {
    if (epoch != _epoch) return;
    _stopKeepAlive();
    onClosed?.call(info);
    if (!isMicLive) {
      unawaited(stop());
    }
  }

  /// True when the current session's microphone capture is still alive
  /// (recorder + subscription present): a socket that died on top of a live
  /// microphone can be reconnected without touching the capture.
  bool get isMicLive => _recorder != null && _micSubscription != null;

  /// Deepgram closes a stream that receives neither audio nor a
  /// `KeepAlive` within a 10-second window. The documented cadence is one
  /// `{"type": "KeepAlive"}` text frame every 3–5 seconds — sent ONLY while
  /// no audio is flowing (sending it during active streaming wastes the
  /// slot), so the tick fires only after the last chunk has aged past the
  /// interval.
  static const Duration keepAliveInterval = Duration(seconds: 4);

  /// Whether a keep-alive frame is due for [provider] at [now], given the
  /// time the last audio chunk actually reached the socket. Pure and
  /// clock-injected for tests.
  @visibleForTesting
  static bool keepAliveDue({
    required String? provider,
    required DateTime? lastAudioSentAt,
    required DateTime now,
    Duration interval = keepAliveInterval,
  }) {
    // Only Deepgram's documented keep-alive protocol is implemented here;
    // AssemblyAI's streaming protocol is different, and sending Deepgram's
    // frame to it would be an invented assumption.
    if (provider != 'deepgram') return false;
    if (lastAudioSentAt == null) return true;
    return now.difference(lastAudioSentAt) >= interval;
  }

  void _startKeepAlive(int epoch) {
    _stopKeepAlive();
    _keepAliveTimer = Timer.periodic(keepAliveInterval, (_) {
      if (epoch != _epoch) {
        _stopKeepAlive();
        return;
      }
      final socket = _socket;
      if (socket == null || socket.readyState != WebSocket.open) return;
      if (!keepAliveDue(
        provider: _provider,
        lastAudioSentAt: _lastAudioSentAt,
        now: DateTime.now(),
      )) {
        return;
      }
      try {
        socket.add(jsonEncode({'type': 'KeepAlive'}));
        debugPrint(
          "[RemoteStt] KeepAlive sent (no audio for "
          "${keepAliveInterval.inSeconds}s).",
        );
      } catch (e) {
        debugPrint("[RemoteStt] KeepAlive failed: $e");
      }
    });
  }

  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  /// ── Capture-path watchdog & recovery ──
  ///
  /// Socket liveness is NOT capture health: the real-device failure had a
  /// perfectly alive socket with a microphone that had been paused by audio
  /// focus — KeepAlive kept the connection open while no frame could ever
  /// arrive. The watchdog samples the frames themselves and, when they
  /// stall, recovers the AUDIO CAPTURE path (a fresh recorder on the same
  /// epoch), leaving the socket alone when it is still open.

  /// Picks the built-in microphone so record_android does not run its
  /// 8 kHz default-device probe before opening the real 16 kHz stream.
  /// Falls back to a null device (the probe) when the platform list cannot
  /// be read — a working-but-slower microphone beats none.
  Future<InputDevice?> _resolveInputDevice(AudioRecorder recorder) async {
    try {
      final devices = await recorder.listInputDevices();
      for (final device in devices) {
        if (device.type == InputDeviceType.builtIn) return device;
      }
      return devices.isEmpty ? null : devices.first;
    } catch (e) {
      debugPrint("[RemoteStt] Input device list failed: $e");
      return null;
    }
  }

  /// Mirrors the recorder's own state stream into the health line. A PAUSE
  /// while a session is live is the exact signature of an external capture
  /// stop (the audio-focus bug), and is treated as a stall to recover from.
  void _listenToRecorderState(AudioRecorder recorder, {required int epoch}) {
    _recorderStateSub?.cancel();
    _recorderStateSub = null;
    try {
      _recorderStateSub = recorder.onStateChanged().listen(
        (state) {
          _recorderState = state.name;
          if (epoch != _epoch || _closing) return;
          if (state == RecordState.record) return;
          debugPrint("[RemoteStt] Recorder state -> ${state.name}");
          if (state == RecordState.pause) {
            unawaited(_recoverCapture(epoch, reason: 'recorder paused'));
          }
        },
        onError: (Object e) {
          debugPrint("[RemoteStt] Recorder state stream error: $e");
        },
      );
    } catch (e) {
      // Some platform builds do not expose a state stream; the frame watchdog
      // below still covers the failure mode.
      debugPrint("[RemoteStt] Recorder state stream unavailable: $e");
    }
  }

  void _startCaptureWatchdog(int epoch) {
    _stopCaptureWatchdog();
    _captureWatchdog = Timer.periodic(_watchdogTick, (_) {
      if (epoch != _epoch) {
        _stopCaptureWatchdog();
        return;
      }
      if (_closing || _recoveringCapture) return;
      if (!isMicLive) return; // Nothing to guard: no capture claims to exist.
      if (!captureStalled(
        lastMicFrameAt: _lastMicFrameAt,
        micOpenedAt: _micOpenedAt,
        now: DateTime.now(),
      )) {
        return;
      }
      final stallMs = DateTime.now()
          .difference(_lastMicFrameAt ?? _micOpenedAt ?? DateTime.now())
          .inMilliseconds;
      debugPrint(
        "[RemoteStt] MIC STALLED: no frame for ${stallMs}ms while "
        "listening. Recovering capture path (socket untouched).",
      );
      _fail("MIC_STALLED", "no frame for ${stallMs}ms");
      unawaited(_recoverCapture(epoch, reason: 'frames stalled'));
    });
  }

  void _stopCaptureWatchdog() {
    _captureWatchdog?.cancel();
    _captureWatchdog = null;
  }

  /// Rebuilds the capture path in place: the old recorder (and only it) is
  /// torn down, a fresh one opens on the SAME epoch, and any socket that is
  /// still open keeps running — chunks buffer in [_pending] while the
  /// microphone reopens and are flushed by the first live frame. Exactly one
  /// recorder and one subscription exist at any moment; [_recoveringCapture]
  /// makes overlapping recoveries impossible.
  ///
  /// When even the fresh recorder cannot produce audio, the capture is
  /// genuinely dead: the session's close callback fires with a reconnectable
  /// class so the caller falls back to its full engine restart.
  Future<void> _recoverCapture(int epoch, {required String reason}) async {
    if (_recoveringCapture || epoch != _epoch || _closing) return;
    _recoveringCapture = true;
    try {
      debugPrint("[RemoteStt] Recovering microphone capture ($reason).");
      final oldRecorder = _recorder;

      await _micSubscription?.cancel();
      _micSubscription = null;
      await _recorderStateSub?.cancel();
      _recorderStateSub = null;
      _firstChunk = null;
      _lastMicFrameAt = null;

      try {
        await oldRecorder?.stop();
      } catch (_) {}
      try {
        await oldRecorder?.dispose();
      } catch (_) {}
      _recorder = null;

      // A lifecycle change raced the recovery: the newer session owns the
      // microphone now — nothing left to do here.
      if (epoch != _epoch) return;

      final recorder = AudioRecorder();
      _recorder = recorder;
      final opened = await _openMicrophone(
        recorder,
        epoch: epoch,
        onClosed: _activeOnClosed,
      );
      if (epoch != _epoch) {
        // Superseded mid-recovery: the new session's start path will have
        // stopped this recorder through the epoch check above — it never
        // became ours.
        return;
      }
      if (opened) {
        debugPrint("[RemoteStt] Capture recovered on same epoch.");
        VoiceTelemetry.mark('mic capture recovered');
        return;
      }

      // The microphone cannot be reopened at all: report a reconnectable
      // capture death so the voice layer's full restart takes over.
      await _recorder?.dispose();
      _recorder = null;
      _fail("MIC_RECOVERY_FAILED", reason);
      _activeOnClosed?.call(
        SttCloseInfo(
          provider: _provider ?? 'deepgram',
          closeClass: SttCloseClass.reconnect,
          closeReason: 'microphone recovery failed: $reason',
        ),
      );
    } finally {
      _recoveringCapture = false;
    }
  }

  /// One line of runtime capture health. The voice session prints this
  /// periodically, which makes it impossible to claim "listening" while no
  /// audio frames are actually flowing: frame/forward/transcript ages are
  /// reported independently.
  String healthLine() {
    final now = DateTime.now();
    String ago(DateTime? at) =>
        at == null ? 'never' : '${now.difference(at).inMilliseconds}ms ago';
    final socket = _socket;
    final socketState = switch (socket?.readyState) {
      WebSocket.open => 'open',
      WebSocket.connecting => 'connecting',
      WebSocket.closing => 'closing',
      WebSocket.closed => 'closed',
      _ => 'none',
    };
    return 'socket=$socketState provider=${_provider ?? 'n/a'} '
        'mic=${isMicLive ? 'live' : 'down'} recorder=${_recorderState ?? 'unknown'} '
        'lastFrame=${ago(_lastMicFrameAt)} lastForwarded=${ago(_lastAudioSentAt)} '
        'lastTranscript=${ago(_lastTranscriptAt)} frames=$_chunksSent '
        'pendingBuffer=${_pending.length}';
  }

  /// Reconnects ONLY the provider socket of the current session, keeping
  /// the microphone capture (recorder + subscription) exactly as it is.
  /// Chunks keep buffering in [_pending] while the socket is down and are
  /// flushed to the new socket by the first live frame.
  ///
  /// Returns true when a socket is open again (including when the current
  /// one turned out to be alive already). Returns false when there is no
  /// live capture to reconnect on top of, or when neither provider can mint
  /// a fresh token — the caller then falls back to a full engine restart,
  /// which also settles whatever is left.
  Future<bool> reconnectSocket() => _exclusive(_reconnectSocketInternal);

  Future<bool> _reconnectSocketInternal() async {
    final onResult = _activeOnResult;
    final onClosed = _activeOnClosed;
    final onLease = _activeOnLease;
    if (onResult == null || !isMicLive) return false;

    // The socket is alive — nothing to do (a newer start may have landed
    // while this reconnect was queued behind it).
    final alive = _socket;
    if (alive != null && alive.readyState == WebSocket.open) return true;
    if (_closing) return false;

    // The dead socket's provider session still has to be settled before
    // the mint below replaces its identity, or its usage is never booked.
    final startedAt = _sessionStartedAt;
    await _settleUsage(
      provider: _provider,
      sessionId: _sessionId,
      fallbackDurationSeconds: startedAt == null
          ? 0
          : DateTime.now().difference(startedAt).inMilliseconds / 1000.0,
    );
    _providerDurationSeconds = null;
    _providerSessionDurationSeconds = null;
    _providerRequestId = null;

    final dead = _socket;
    _socket = null;
    try {
      await dead?.close();
    } catch (_) {}

    final epoch = _epoch;
    // A fresh token — the old one died with the socket. Deepgram first,
    // then the AssemblyAI takeover, mirroring the original start path.
    final lease = await _fetchToken(mode: _activeMode);
    if (lease != null) {
      final opened = await _openDeepgramSocket(
        lease: lease,
        epoch: epoch,
        onResult: onResult,
        onClosed: onClosed,
      );
      if (opened) {
        _announceLease(lease, onLease);
        return true;
      }
    }
    final assemblyLease = await _fetchAssemblyToken(mode: _activeMode);
    final recorder = _recorder;
    if (assemblyLease != null && recorder != null) {
      final started = await _startAssemblyAi(
        recorder: recorder,
        token: assemblyLease.token,
        sessionId: assemblyLease.sessionId,
        epoch: epoch,
        onResult: onResult,
        onClosed: onClosed,
      );
      if (started) {
        _announceLease(assemblyLease, onLease);
        return true;
      }
    }

    // The socket could not be re-established; the caller falls back to a
    // full engine restart (which also settles the surviving capture).
    _fail("RECONNECT_FAILED", "socket-only reconnect could not mint/open");
    return false;
  }

  /// Publishes a mint response to the caller's lease callback.
  void _announceLease(
    _SpeechLease lease,
    void Function(SttLease lease)? onLease,
  ) {
    onLease?.call(
      SttLease(
        provider: lease.provider,
        sessionId: lease.sessionId,
        allowanceVoiceSeconds: lease.allowanceVoiceSeconds,
        remainingVoiceSeconds: lease.remainingVoiceSeconds,
        reservedVoiceSeconds: lease.reservedVoiceSeconds,
      ),
    );
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
    void Function(SttCloseInfo info)? onClosed,
  }) async {
    // The capture is configured with two deliberate additions, both born on
    // a real-device failure:
    //
    //  * `device` — record_android otherwise probes the default input device
    //    by opening a THROWAWAY 8 kHz AudioRecord, starting it, reading the
    //    routed device, and releasing it — only then opening the real 16 kHz
    //    stream. That double microphone open doubled capture setup and made
    //    voice startup visibly slow. Passing the built-in microphone
    //    explicitly skips the probe: the pipeline opens directly at 16 kHz.
    //
    //  * `AudioInterruptionMode.none` — by default record_android requests
    //    audio focus for the microphone and PAUSES the recording forever on
    //    any focus loss (resume only exists in pauseResume mode). Our own
    //    TTS player used to request per-sentence focus, so the second
    //    sentence's playback silently killed the microphone — the socket
    //    stayed alive, KeepAlive frames flowed, and the user's next words
    //    never reached the server. Voice Mode needs the mic immune to focus
    //    churn; the watchdog below recovers the capture if anything else
    //    ever stops it. AEC/NS stay enabled in the withEffects config.
    final InputDevice? device = await _resolveInputDevice(recorder);
    final withEffects = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: 1,
      echoCancel: true,
      noiseSuppress: true,
      device: device,
      audioInterruption: AudioInterruptionMode.none,
    );
    final plain = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: _sampleRate,
      numChannels: 1,
      device: device,
      audioInterruption: AudioInterruptionMode.none,
    );

    for (final attempt in [
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
      _micOpenedAt = DateTime.now();
      _lastMicFrameAt = null;
      _listenToRecorderState(recorder, epoch: epoch);
      _micSubscription = stream.listen(
        (chunk) {
          // A microphone owned by a superseded session must not feed a
          // successor's socket.
          if (epoch != _epoch) return;
          // Frame RECEIVED from the recorder — independent of the socket, so
          // the watchdog can tell a dead capture from a dead socket.
          _lastMicFrameAt = DateTime.now();
          if (!(_firstChunk?.isCompleted ?? true)) {
            _firstChunk!.complete();
            VoiceTelemetry.mark('mic frames flowing (${attempt.label})');
          }
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
            // Active streaming: mark the line as flowing so the keep-alive
            // tick stays suppressed while audio frames move.
            _lastAudioSentAt = DateTime.now();
          } else if (_pending.length < _maxPendingChunks) {
            _pending.add(chunk);
          }
        },
        onError: (Object e) {
          _fail("MIC_ERROR", e);
          unawaited(stop());
          // The microphone itself died: no socket close to classify, but
          // the capture is gone, so the caller's reconnect path must fall
          // back to a full engine restart.
          onClosed?.call(
            SttCloseInfo(
              provider: _provider ?? 'deepgram',
              closeClass: SttCloseClass.reconnect,
            ),
          );
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
      await _recorderStateSub?.cancel();
      _recorderStateSub = null;
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

    // The keep-alive clock, the capture watchdog and the reconnect plumbing
    // die with the capture they belonged to.
    _stopKeepAlive();
    _stopCaptureWatchdog();
    _lastAudioSentAt = null;
    _lastMicFrameAt = null;
    _micOpenedAt = null;
    _lastTranscriptAt = null;
    _recorderState = null;
    _recoveringCapture = false;
    _lastErrorMsgCode = null;
    _activeOnResult = null;
    _activeOnClosed = null;
    _activeOnLease = null;
    _activeMode = null;

    await _micSubscription?.cancel();
    _micSubscription = null;
    await _recorderStateSub?.cancel();
    _recorderStateSub = null;

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
          socket.add(
            jsonEncode({
              'type': provider == 'assemblyai' ? 'Terminate' : 'CloseStream',
            }),
          );
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
          'durationSeconds':
              _providerDurationSeconds ?? fallbackDurationSeconds,
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
        // The `msg_code` (e.g. NET-0002) is what the close classification
        // needs; the close frame itself often does not repeat it.
        final msgCode = decoded['msg_code'];
        if (msgCode is String && msgCode.isNotEmpty) {
          _lastErrorMsgCode = msgCode;
        }
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

      // The alternative's own confidence, when the provider reports one —
      // barge-in gates on it.
      final confidence = alternatives.first?['confidence'];
      return SttResult(
        transcript.trim(),
        isFinal: decoded['is_final'] == true,
        confidence: confidence is num ? confidence.toDouble() : null,
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
        final audio = num.tryParse(
          '${decoded['audio_duration_seconds'] ?? ''}',
        );
        final session = num.tryParse(
          '${decoded['session_duration_seconds'] ?? ''}',
        );
        if (audio != null && audio >= 0) {
          _providerDurationSeconds = audio.toDouble();
        }
        if (session != null && session >= 0) {
          _providerSessionDurationSeconds = session.toDouble();
        }
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

      // AssemblyAI publishes a turn-level confidence; missing means unknown
      // (never zero) for the barge-in gate.
      final confidence = decoded['confidence'];
      return SttResult(
        transcript.trim(),
        isFinal: decoded['end_of_turn'] == true,
        confidence: confidence is num ? confidence.toDouble() : null,
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
