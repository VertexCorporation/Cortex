import 'dart:async';
import 'dart:math' as math;

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/server/user.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/stt_remote.dart';
import 'package:cortex/chat/services/tts_remote.dart';
import 'package:cortex/chat/services/voice_barge_in.dart';
import 'package:cortex/chat/services/voice_echo.dart';
import 'package:cortex/chat/services/voice_background.dart';
import 'package:cortex/chat/services/voice_health.dart';
import 'package:cortex/chat/services/voice_sounds.dart';
import 'package:cortex/chat/services/voice_turns.dart';
import 'package:cortex/chat/services/flow.dart';

import 'flow_text.dart';

/// The realtime Voice/Flow lifecycle. One enum, one truth: no combination of
/// booleans can put the session in two states at once. UI-compat: the four
/// original values keep their existing meaning for every consumer;
/// `connecting` (engine/session setup) and `failed` (the engine could not
/// start — the center button shows the mic so the user can retry) are new.
enum VoiceState { idle, connecting, listening, processing, speaking, failed }

/// Why the current (or most recent) session ended. Observability + near-limit
/// UX: the overlay can explain "limit reached" instead of just going dark.
enum VoiceEndReason { user, error, limit, inactivity, background }

class VoiceService extends ChangeNotifier with WidgetsBindingObserver {
  final SpeechService _speechService;
  final FlutterTts _flutterTts;
  VoiceState _state = VoiceState.idle;
  bool _listeningCuePlayed = false;

  VoiceState get state => _state;

  // TEST MODE: Simulate flow without hardware mic
  bool get isTestMode => false; // FORCE DISABLED for production/testing
  Timer? _testModeTimer;

  String _currentLocale = "en-US";
  Timer? _silenceTimer;
  Timer? _adaptiveSegmentTimer;
  Timer? _voiceTimer;
  Function(String)? _onFinalSentence; // Callback to send text to AI

  /// Prints the remote capture health line every few seconds while a
  /// session is live — last mic frame, last forwarded chunk, last
  /// transcript, socket state — so a stalled capture is visible in the
  /// device log instead of masquerading as "listening" (it once did: audio
  /// focus paused the recorder mid-session with zero other symptoms).
  Timer? _healthTimer;
  DateTime? _lastPlaybackEndedAt;
  int _sentenceSequence = 0;
  Future<Uint8List?>? _prefetchFuture;
  String? _prefetchText;
  int? _prefetchGeneration;

  /// Turn-scoped telemetry flags: the first streamed AI chunk of a turn and
  /// the first transcript after playback both produce one [VoiceTelemetry]
  /// mark each, which is exactly the pair of timings real-device testing
  /// cares about (STT final → first AI token; TTS complete → next user
  /// audio).
  bool _flowTurnCompleted = false;
  bool _firstAiChunkSeen = false;
  bool _firstSentenceSeen = false;
  bool _awaitingPostTtsTranscript = false;

  bool isFlowMode = false; // "Setup" mode (Flow selected but not started)
  bool isFlowActive = false; // "Active" mode (Flow loop running)
  int currentFlowAgentIndex = 0; // Blue, Red, Green, Yellow
  final FlowOrchestrator _flow = FlowOrchestrator();
  List<String> _flowModelIds = const [
    'cortex/auto',
    'cortex/auto',
    'cortex/auto',
    'cortex/auto',
  ];
  List<String?> _flowVoiceIds = const [null, null, null, null];
  FutureOr<void> Function(FlowParticipant participant, String modelId)?
  _onFlowTurn;
  VoidCallback? _onAssistantInterrupted;

  FlowPhase get flowPhase => _flow.phase;

  FlowParticipant get currentFlowParticipant =>
      FlowParticipant.values[currentFlowAgentIndex.clamp(0, 3)];

  List<String> get flowModelIds => List.unmodifiable(_flowModelIds);

  void configureFlow({
    required FutureOr<void> Function(
      FlowParticipant participant,
      String modelId,
    )
    onFlowTurn,
    required List<String> modelIds,
    List<String?>? voiceIds,
    VoidCallback? onAssistantInterrupted,
  }) {
    _onFlowTurn = onFlowTurn;
    _onAssistantInterrupted = onAssistantInterrupted;
    if (modelIds.length == FlowParticipant.values.length) {
      _flowModelIds = List.unmodifiable(modelIds);
    }
    if (voiceIds != null && voiceIds.length == FlowParticipant.values.length) {
      _flowVoiceIds = List.unmodifiable(voiceIds);
    }
  }

  // --- SESSION IDENTITY ---------------------------------------------------
  // Every async artifact of a voice session (STT results, silence timers,
  // TTS completions, flow turn timers, reconnect attempts) captures the
  // generation it belongs to; `_activeGeneration` is the only source of
  // "this session is alive". A callback whose generation is no longer active
  // is dropped — stale artifacts from a stopped session can never mutate its
  // successor. This is what makes start/stop idempotent under rapid taps.
  int _generation = 0;
  int? _activeGeneration;

  /// Null when no session is active.
  bool get isSessionActive => _activeGeneration != null;

  /// Why the last session ended (observability + UI messaging).
  VoiceEndReason? lastEndReason;

  // --- SESSION TIMEOUTS ---------------------------------------------------
  /// Inactivity timeout: a session that produces nothing (no speech, no
  /// assistant audio) for this long is an abandoned session — end it rather
  /// than letting it consume provider time and daily allowance forever.
  static const Duration _inactivityTimeout = Duration(seconds: 90);
  static const Duration _adaptiveSegmentPause = Duration(milliseconds: 700);
  static const int _adaptiveSegmentMinimum = 42;
  static const int _adaptiveSegmentMaximum = 220;
  Timer? _inactivityTimer;

  /// The realtime-speech window the server reserved for the CURRENT provider
  /// session (from the mint response). The session recycles the provider
  /// connection at the end of its window so the server re-checks the daily
  /// pool at each mint — the client keeps this duty, the SERVER stays
  /// authoritative (it simply refuses the next mint when the pool is empty).
  int? _voiceWindowSeconds;

  /// Seconds the current provider session may run before the client recycles
  /// it (observability + tests).
  int? get voiceWindowSeconds => _voiceWindowSeconds;
  Timer? _windowTimer;
  Timer? _budgetTicker;
  bool _recyclePending = false;

  // --- REALTIME VOICE ALLOWANCE (server-authoritative, client mirrors) ----
  /// Daily realtime allowance for the user's tier (published by the server in
  /// `creditLimits.voiceDailySeconds`); null when unpublished (very old
  /// documents) — the UI then hides the countdown and the server still
  /// enforces at mint time.
  int? voiceAllowanceSeconds;

  /// Seconds left in the daily pool as the server last reported it. Updated
  /// at every mint; ticked down locally between mints for the countdown.
  int? remainingVoiceSeconds;

  /// True when the last STT start failed specifically because the daily
  /// voice allowance was exhausted (server 403 voice_daily_limit).
  bool get voiceLimitReached =>
      lastEndReason == VoiceEndReason.limit ||
      _speechService.remoteVoiceLimitReached;

  /// Whether the current capture runs on a remote provider (Deepgram or
  /// AssemblyAI) — the orb and the observability logs care.
  bool get sttEngineIsRemote => _speechService.isRemoteActive;

  // --- BARGE-IN (user interrupts assistant speech by talking) ------------
  /// Confidence-gated detector replacing the old "one transcript frame +
  /// three loud samples" heuristic: echo bleeds through that gate far too
  /// easily, and echo was solved at the cost of nothing being solved. The
  /// microphone stays OPEN while the assistant speaks (continuous capture,
  /// AEC untouched); the DETECTOR decides which evidence means the user
  /// started talking. See [BargeInDetector] for the exact gates.
  late final BargeInDetector _bargeIn = BargeInDetector(clock: _clock);

  // --- ECHO SUPPRESSION (transcript path) --------------------------------
  /// The same fingerprints the barge-in gate uses to reject echo, applied to
  /// the text that becomes the committed user turn: assistant speaker-bleed
  /// spans are stripped at ingest (see [AssistantEchoFilter]) while genuine
  /// user words before/after the span survive.
  late final AssistantEchoFilter _echoFilter = AssistantEchoFilter(
    clock: _clock,
  );

  // --- PER-TURN TRANSCRIPT LIFECYCLE --------------------------------------
  /// Session/turn identities and the CURRENT turn's buffer. The engine
  /// emissions are cumulative since the capture started (the capture
  /// deliberately outlives a turn); this tracker is what keeps every
  /// committed turn's words out of the next turn's outgoing message.
  late final VoiceTurnTracker _turns = VoiceTurnTracker(
    clock: _clock,
    echoFilter: _echoFilter,
  );

  /// The active user turn's transcript ('' when no live turn) — the live
  /// transcript card reads this.
  String get userTurnText => _turns.buffer;

  // --- RECONNECT ----------------------------------------------------------
  /// Provider sockets can die mid-session (idle closes, network drops). The
  /// session is still alive: reconnect up to this many times per session,
  /// then fall back and, if that fails too, end with [VoiceEndReason.error].
  static const int _maxReconnectsPerSession = 3;
  int _reconnectAttempts = 0;
  bool _reconnecting = false;

  /// Native-fallback auto-stop restarts (speech_to_text stops itself after
  /// silence): a bounded number of empty restarts before the session is
  /// given up as failed, so a broken recognizer cannot tight-loop.
  static const int _maxEmptyNativeRestarts = 3;
  int _emptyNativeRestarts = 0;

  // Live Transcript for UI Top Card
  String _liveTranscript = "";
  bool _isLiveUserMessage = true;

  String get liveTranscript => _liveTranscript;
  bool get isLiveUserMessage => _isLiveUserMessage;

  // Queue for TTS to speak text as it streams in from AI
  final List<String> _sentenceQueue = [];
  bool _isSpeaking = false;

  final RemoteTtsService _remoteTts = RemoteTtsService.instance;
  final VoiceBackgroundService _backgroundService = VoiceBackgroundService();

  /// Bumped whenever speech is cancelled. Remote audio is fetched over the
  /// network, so a sentence can still be in flight when the user interrupts;
  /// without this the reply they cut off would play a moment later.
  int _speechGeneration = 0;

  /// Abandons anything queued or in flight. Callers that clear the queue must
  /// go through here, otherwise an already-dispatched request still speaks.
  void _cancelPendingSpeech() {
    _speechGeneration++;
    _sentenceQueue.clear();
    _adaptiveSegmentTimer?.cancel();
    _adaptiveSegmentTimer = null;
    _prefetchFuture = null;
    _prefetchText = null;
    _prefetchGeneration = null;
    // Playback is over from the barge-in detector's point of view too: the
    // post-TTS echo discard window starts here. The transcript echo filter
    // opens its strong window from the same instant.
    _bargeIn.onAssistantSpeechStopped();
    _echoFilter.onAssistantSpeechStopped();
    unawaited(_remoteTts.stop());
  }

  final StringBuffer _incomingTextBuffer = StringBuffer();
  final StringBuffer _fullAiResponseBuffer =
      StringBuffer(); // Accumulates full response for Flow Loop

  // Need to know when to switch back to listening
  bool _aiGenerationComplete = false;

  VoiceService({
    required this._speechService,
    FlutterTts? flutterTts,
    DateTime Function()? clock,
    Duration Function(SttCloseInfo info, int attempt)? reconnectBackoff,
  }) : _clock = clock ?? DateTime.now,
       _reconnectBackoffOverride = reconnectBackoff,
       _flutterTts = flutterTts ?? FlutterTts() {
    _initTts();
    _backgroundService.onStopRequested = () {
      unawaited(stopSession(reason: VoiceEndReason.user));
    };
    _speechService.addListener(_onSpeechStatusChange);
    // An active Voice session opts into the platform's audio lifetime before
    // the activity can be backgrounded. The native service owns only the
    // notification/process lifetime; Flutter remains the sole recorder,
    // socket and playback owner.
    WidgetsBinding.instance.addObserver(this);
  }

  /// Time source, injectable so tests can drive the barge-in windows
  /// deterministically instead of sleeping real milliseconds.
  final DateTime Function() _clock;

  /// Reconnect backoff policy, injectable for tests (the default is the
  /// classification-driven jittered policy in [_reconnectDelayFor]).
  final Duration Function(SttCloseInfo info, int attempt)?
  _reconnectBackoffOverride;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final gen = _activeGeneration;
    if (gen != null &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached)) {
      debugPrint(
        '[VoiceService] Session $gen remains active while app is $state.',
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speechService.removeListener(_onSpeechStatusChange);
    _cancelAllTimers();
    _activeGeneration = null;
    _cancelPendingSpeech();
    unawaited(_remoteTts.stop());
    unawaited(_backgroundService.stop());
    super.dispose();
  }

  /// Prints the remote capture's health line every few seconds while the
  /// session is live: socket state, mic state, recorder state, and the ages
  /// of the last received frame / forwarded chunk / transcript. With this
  /// line in the log a "listening" session with a dead capture path is
  /// impossible to miss — the exact failure real-device testing caught.
  void _startHealthTimer(int gen) {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (gen != _activeGeneration) {
        _healthTimer?.cancel();
        _healthTimer = null;
        return;
      }
      debugPrint("[VoiceHealth] ${_speechService.remoteHealthLine()}");
    });
  }

  void _cancelAllTimers() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _adaptiveSegmentTimer?.cancel();
    _adaptiveSegmentTimer = null;
    _voiceTimer?.cancel();
    _voiceTimer = null;
    _testModeTimer?.cancel();
    _testModeTimer = null;
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _windowTimer?.cancel();
    _windowTimer = null;
    _budgetTicker?.cancel();
    _budgetTicker = null;
    _healthTimer?.cancel();
    _healthTimer = null;
  }

  void _onSpeechStatusChange() {
    final gen = _activeGeneration;
    if (gen == null) return;

    // 1. Barge-in sampling: the remote mic stays open while the assistant
    //    speaks, and level updates flow through here into the detector.
    //    The microphone is never muted during playback; the detector's
    //    gates (sustained amplitude + confident, non-echo transcript)
    //    decide what counts as the user talking over the audio.
    if (_state == VoiceState.speaking && _speechService.isRemoteActive) {
      _bargeIn.onLevel(_speechService.soundLevel);
      if (_bargeIn.shouldBargeIn) {
        _interruptForBargeIn(gen);
        return;
      }
    } else {
      _bargeIn.onLevel(0.0);
    }

    // 2. Native-fallback auto-stop (speech_to_text stops itself after
    //    silence): finalize the captured text if there is any, otherwise
    //    restart — the session continues, but a recognizer that keeps
    //    producing nothing must not tight-loop (bounded empty restarts).
    if (!_speechService.isListening &&
        !_speechService.isRemoteActive &&
        _state == VoiceState.listening) {
      debugPrint(
        "[VoiceService] Native listener stopped (session $gen). hasText: $hasRecognizedText",
      );
      if (hasRecognizedText) {
        _emptyNativeRestarts = 0;
        unawaited(_finalizeUserSpeech(gen));
      } else if (_emptyNativeRestarts >= _maxEmptyNativeRestarts) {
        _updateState(VoiceState.failed);
        unawaited(_endSession(gen, VoiceEndReason.error));
      } else {
        _emptyNativeRestarts++;
        unawaited(_beginListening(gen, quiet: true));
      }
    }
  }

  Future<void> _initTts() async {
    debugPrint("[VoiceService] Initializing TTS...");
    await _flutterTts.setVolume(1.0); // Maximum volume
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playAndRecord,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
      ],
      IosTextToSpeechAudioMode.voiceChat,
    );

    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _updateState(VoiceState.speaking);
    });

    _flutterTts.setCompletionHandler(() {
      debugPrint("[VoiceService] Native TTS Completion Callback fired.");
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      debugPrint("[VoiceService] TTS Error: $msg");
      _processQueue();
    });
  }

  void _updateState(VoiceState newState) {
    if (_state != newState) {
      if (newState == VoiceState.listening &&
          _state == VoiceState.connecting &&
          !_listeningCuePlayed) {
        _listeningCuePlayed = true;
        VoiceInteractionSounds.listeningReady();
      }
      _state = newState;
      notifyListeners();
    }
  }

  void toggleFlowMode() {
    if (isFlowMode) {
      isFlowMode = false;
      isFlowActive = false;
      _voiceTimer?.cancel();
      _flow.stop();
      _onAssistantInterrupted?.call();
      final gen = _activeGeneration;
      if (gen != null) unawaited(_haltAssistantSpeech(gen));
      currentFlowAgentIndex = 0;
      if (_activeGeneration != null) {
        _updateState(VoiceState.listening);
      }
      notifyListeners();
      return;
    }

    isFlowMode = true;
    isFlowActive = true;
    _flow.begin(newGeneration: (_activeGeneration ?? 0) + 1);
    currentFlowAgentIndex = FlowParticipant.blue.index;
    _isFlowInterrupted = false;
    _updateState(VoiceState.listening);
    notifyListeners();

    // Flow is layered on the existing Voice session. The microphone stays
    // alive so the user can interrupt any participant without a new session.
  }

  void setFlowMode(bool enabled) {
    if (isFlowMode == enabled) return;
    isFlowMode = enabled;
    isFlowActive = false;
    _voiceTimer?.cancel();
    if (!enabled) _flow.stop();
    currentFlowAgentIndex = 0;
    notifyListeners();
  }

  void startFlow() async {
    if (_activeGeneration == null) return;
    isFlowActive = true;
    isFlowMode = true;
    currentFlowAgentIndex = 0;
    _flow.begin(newGeneration: _activeGeneration!);
    _requestFlowTurn(_activeGeneration!);
  }

  // Overload startFlow to accept the prompt text directly from UI
  void startFlowWithPrompt(String prompt) {
    // A flow turn needs the same session identity voice turns use; create it
    // if the overlay somehow started flow without one.
    final gen = _ensureSession();
    isFlowActive = true;
    isFlowMode = true;
    currentFlowAgentIndex = 0;
    _flow.begin(newGeneration: gen);
    _fullAiResponseBuffer.clear();

    // Switch to "Processing" to show 1st agent thinking
    _updateState(VoiceState.processing);
    _updateVoiceParams(0); // Reset voice
    _armInactivityTimer(gen);

    // Legacy test/embedding seam: callers that have not supplied the new
    // participant callback still receive the original initial prompt once.
    if (_onFlowTurn != null) {
      _requestFlowTurn(gen);
    } else if (_onFinalSentence != null) {
      debugPrint("[VoiceService] Flow turn started (session $gen).");
      _onFinalSentence!(prompt);
    }
  }

  void _requestFlowTurn(int gen) {
    if (gen != _activeGeneration || !isFlowActive || _onFlowTurn == null) {
      return;
    }
    _flowTurnCompleted = false;
    _aiGenerationComplete = false;
    _firstAiChunkSeen = false;
    _firstSentenceSeen = false;
    _fullAiResponseBuffer.clear();
    _incomingTextBuffer.clear();
    final participant = currentFlowParticipant;
    final modelId = _flowModelIds[participant.index];
    final flowGeneration = _flow.generation;
    _flow.beginAiTurn(participant);
    _updateState(VoiceState.processing);
    _armInactivityTimer(gen);
    debugPrint(
      '[VoiceService] Flow turn requested round=${_flow.round} participant=${participant.key} model=$modelId generation=$flowGeneration',
    );
    unawaited(
      Future<void>.sync(() => _onFlowTurn!(participant, modelId)).catchError((
        error,
      ) {
        debugPrint(
          '[VoiceService] Flow participant ${participant.key} failed: $error',
        );
        if (gen == _activeGeneration && flowGeneration == _flow.generation) {
          _advanceFlowAfterTurn(gen, flowGeneration);
        }
      }),
    );
  }

  void _advanceFlowAfterTurn(int gen, int flowGeneration) {
    if (gen != _activeGeneration ||
        flowGeneration != _flow.generation ||
        !isFlowActive) {
      return;
    }
    if (_flowTurnCompleted) return;
    _flowTurnCompleted = true;
    final next = _flow.completeAi(expectedGeneration: flowGeneration);
    if (next == null) {
      _updateState(VoiceState.listening);
      _voiceTimer?.cancel();
      _voiceTimer = Timer(const Duration(milliseconds: 1400), () {
        if (gen != _activeGeneration || !isFlowActive) return;
        _flow.beginNextRound(expectedGeneration: flowGeneration);
        currentFlowAgentIndex = FlowParticipant.blue.index;
        notifyListeners();
        _requestFlowTurn(gen);
      });
      return;
    }
    currentFlowAgentIndex = next.index;
    notifyListeners();
    _voiceTimer?.cancel();
    _voiceTimer = Timer(const Duration(milliseconds: 220), () {
      if (gen != _activeGeneration || !isFlowActive) return;
      _requestFlowTurn(gen);
    });
  }

  bool _isFlowInterrupted = false;

  void interruptFlowAndListen() async {
    final gen = _activeGeneration;
    debugPrint(
      "[VoiceService] Interrupting Flow. Transitioning to Listen Mode.",
    );
    _isFlowInterrupted = true;
    _flow.interruptForUser();
    currentFlowAgentIndex = FlowParticipant.blue.index;
    _voiceTimer?.cancel();
    _onAssistantInterrupted?.call();
    _isSpeaking = false;
    _firstSentenceSeen = false;
    _cancelPendingSpeech();
    _incomingTextBuffer.clear();

    // [FIX] Ensure TTS is completely stopped
    await _flutterTts.stop();

    // [FIX] Reset flow loop flag so it doesn't resume
    setAiGenerationComplete(false);

    // [FIX] Set state to Listening (Round Circle)
    _updateState(VoiceState.listening);

    // [FIX] Open Microphone
    if (gen != null) {
      unawaited(_beginListening(gen));
    }
  }

  /// Everything "the assistant must stop talking now" does, shared by the
  /// manual stop button and the automatic barge-in.
  Future<void> _haltAssistantSpeech(int gen) async {
    if (gen != _activeGeneration) return;
    _isSpeaking = false;
    _cancelPendingSpeech();
    _incomingTextBuffer.clear();
    await Future.wait([_remoteTts.stop(), _flutterTts.stop()]);
  }

  /// Barge-in: the user started talking over the assistant. Stops the
  /// currently playing audio, invalidates every queued/in-flight TTS chunk of
  /// this generation, and returns to listening immediately — on a NEW user
  /// turn.
  ///
  /// The user's own words that were spoken DURING playback are already in
  /// the engine's cumulative text; they survive into the new turn through
  /// the tracker's echo filtering (assistant-bleed spans are stripped,
  /// genuine user words are not), while the previously COMMITTED turn can
  /// never be appended to — the tracker minted a fresh turn identity here.
  void _interruptForBargeIn(int gen) {
    if (gen != _activeGeneration || _state != VoiceState.speaking) return;
    debugPrint("[VoiceService] Barge-in (session $gen): cutting audio.");
    final interruptedText = _bargeIn.acceptedTranscript;
    _onAssistantInterrupted?.call();
    // Switch the transcript consumer synchronously so the result that triggered
    // interruption is accepted by SpeechService's following text callback.
    _turns.beginTurn();
    _liveTranscript = "";
    _isLiveUserMessage = true;
    if (isFlowActive) {
      _voiceTimer?.cancel();
      _flow.interruptForUser();
      currentFlowAgentIndex = FlowParticipant.blue.index;
    }
    _updateState(VoiceState.listening);
    _armInactivityTimer(gen);
    unawaited(_haltAssistantSpeech(gen));
    if (interruptedText.isNotEmpty) _onSttResult(gen, interruptedText);
  }

  void stopSpeaking({BuildContext? context}) async {
    final gen = _activeGeneration;
    if (gen == null) return;

    await _haltAssistantSpeech(gen);
    if (gen != _activeGeneration) return;

    // [FIX] Hard Stop: Breaking the Flow Loop entirely on manual stop.
    isFlowActive = false;

    // Back to listening. On the remote engine the capture never stopped
    // (continuous session — no re-mint, no reconnect gap); the native
    // fallback stopped itself and is reopened by the resume path.
    _resumeListeningAfterTurn(gen);
  }

  void _restoreFlow() {
    debugPrint("[VoiceService] Resuming Flow after silence/interruption.");
    _isFlowInterrupted = false;
    final gen = _activeGeneration;
    if (gen != null && isFlowActive) _requestFlowTurn(gen);
  }

  bool _shouldNextMessageBeHidden = false;

  bool get shouldNextMessageBeHidden {
    final val = _shouldNextMessageBeHidden;
    _shouldNextMessageBeHidden = false; // consume it
    return val;
  }

  void _updateVoiceParams(int index) async {
    // 0: Normal
    // 1: Deeper/Slower
    // 2: Higher/Faster
    // Also use Language
    await _flutterTts.setLanguage(_currentLocale);

    switch (index) {
      case 0:
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5); // Default is usually 0.5
        break;
      case 1:
        await _flutterTts.setPitch(0.65);
        await _flutterTts.setSpeechRate(0.45);
        break;
      case 2:
        await _flutterTts.setPitch(1.3);
        await _flutterTts.setSpeechRate(0.55);
        break;
      default:
        await _flutterTts.setPitch(1.0);
    }
  }

  // --- Main Control Methods ---------------------------------------------------

  /// Starts a Voice/Flow session. IDEMPOTENT: while a session is active this
  /// is a no-op — rapid repeated presses of the Voice button can never create
  /// a second microphone, a second STT connection, or a second callback set.
  Future<void> startSession({
    BuildContext? context,
    required String locale,
    required Function(String) onFinalSentence,
    String? systemPrompt,
  }) async {
    if (_activeGeneration != null) {
      debugPrint(
        "[VoiceService] startSession ignored: a session is already active.",
      );
      return;
    }

    // -------------------------------------------------------------------------
    // 1. LIMIT & CREDIT CHECK (Before starting)
    // -------------------------------------------------------------------------
    if (context != null && !_checkLimits(context)) return;

    _lastContext = context;
    _currentLocale = locale;
    _onFinalSentence = onFinalSentence;

    // Timing window for the whole session: every hop (mic frames, socket,
    // STT final, first AI token, sentence queue, TTS, playback) logs its
    // delta from this instant. Also warm the speech-synthesis endpoint
    // now: the container is scale-to-zero and its cold boot (~8s, measured)
    // used to sit on the critical path of the FIRST sentence. The warmup
    // request is rejected by the server within milliseconds — it boots the
    // container while the user is still speaking.
    VoiceTelemetry.begin();
    _listeningCuePlayed = false;
    VoiceTelemetry.mark('voice session opening');
    unawaited(_remoteTts.warmup());

    _isSpeaking = false;
    _liveTranscript = "";
    _cancelPendingSpeech();
    _incomingTextBuffer.clear();
    _fullAiResponseBuffer.clear();

    // Microphone ownership: dictation must terminate before Voice Mode takes
    // the mic — SpeechService arbitration enforces it too, but the dictation
    // UI flag has to clear here or the composer stays in recording mode.
    if (context != null && context.mounted) {
      try {
        final inputProvider = context.read<InputProvider>();
        if (inputProvider.isVoiceRecording) {
          inputProvider.setVoiceRecording(false);
        }
      } catch (_) {
        // Provider not in scope (tests) — nothing to release.
      }
      FocusScope.of(context).unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }

    // TTS configuration is not a microphone prerequisite. Start it without
    // waiting; only the foreground lifetime must precede capture on Android.
    unawaited(
      _flutterTts.setLanguage(locale).then<void>((_) {}).catchError((e) {
        debugPrint("[VoiceService] TTS Language Set Error: $e");
      }),
    );

    final gen = _ensureSession();
    debugPrint(
      "[VoiceService] Session $gen starting (${isFlowMode ? "flow" : "voice"}).",
    );
    // Expose the startup state before the platform foreground bridge and
    // recorder/socket initialization begin. The orb can therefore stay
    // dormant immediately on entry instead of briefly implying readiness.
    _updateState(VoiceState.connecting);
    await _backgroundService.start();
    if (gen != _activeGeneration) return;
    if (context != null && !context.mounted) return;
    VoiceTelemetry.mark('voice foreground lifetime requested');
    await _beginListening(gen);
  }

  bool _checkLimits(BuildContext context) {
    final session = context.read<ChatSessionProvider>();

    // Check Chat Limits (e.g. free user max messages)
    if (session.chatLimitManager?.isLimitExceeded(
          context.read<ConversationProvider>().messages,
        ) ==
        true) {
      debugPrint("[VoiceService] Chat limit exceeded. Stopping.");
      stopSession();
      return false;
    }

    // Daily realtime voice allowance. The client mirrors what the server
    // published (`creditLimits.voiceDailySeconds` + `voiceUsage`); the server
    // re-checks the pool at every token mint, so this is a UX early-out, not
    // a security boundary.
    try {
      final user = context.read<UserProvider>();
      final allowance = user.creditLimits.voiceDailySeconds ?? 0;
      final usage = user.voiceUsage;
      if (allowance > 0 && usage.remainingToday(allowance) <= 0) {
        debugPrint("[VoiceService] Daily voice allowance exhausted.");
        lastEndReason = VoiceEndReason.limit;
        _updateState(VoiceState.failed);
        notifyListeners();
        return false;
      }
    } catch (_) {
      // UserProvider unavailable (tests) — the server still enforces at mint.
    }

    // Credits: generation-time charging stays authoritative in the send
    // pipeline (sendMessage charges the LLM turn exactly once); speech-layer
    // credits are settled by the voice endpoints themselves.
    return true;
  }

  /// Ends the session. IDEMPOTENT: safe to call any number of times — with no
  /// active session it still sweeps everything (cheap, and it guarantees no
  /// microphone, socket, player or timer can ever survive a closed overlay).
  ///
  /// Order matters: `_activeGeneration` is cleared FIRST, so every in-flight
  /// artifact of the session (STT results, silence/finalize timers, TTS
  /// completions, flow turns, reconnects) is already dead by the time the
  /// microphone and audio players are torn down.
  Future<void> stopSession({
    bool resetState = true,
    VoiceEndReason reason = VoiceEndReason.user,
  }) async {
    final gen = _activeGeneration;
    _activeGeneration = null;
    lastEndReason ??= reason;

    _cancelAllTimers();
    if (resetState) _updateState(VoiceState.idle);

    _cancelPendingSpeech();
    _liveTranscript = "";
    _isSpeaking = false;
    _reconnecting = false;
    _bargeIn.reset();
    _echoFilter.reset();
    _turns.reset();

    // Microphone, native TTS and the remote audio player all released.
    await _speechService.stopListening();
    await _flutterTts.stop();
    await _remoteTts.stop();
    await _backgroundService.stop();

    // stopSession stops everything, including a running flow loop.
    isFlowActive = false;
    _flow.stop();
    currentFlowAgentIndex = FlowParticipant.blue.index;
    _incomingTextBuffer.clear();
    _fullAiResponseBuffer.clear();
    if (gen != null) {
      debugPrint("[VoiceService] Session $gen ended ($reason).");
      notifyListeners();
    }
  }

  /// Terminal path for lifecycle-driven ends (engine failure, inactivity,
  /// daily limit, app background): records the reason and terminal state,
  /// then performs the standard teardown WITHOUT overwriting the terminal
  /// state — `stopSession`'s idle reset must not erase the failure the UI is
  /// about to explain.
  Future<void> _endSession(int gen, VoiceEndReason reason) async {
    if (gen != _activeGeneration) return;
    lastEndReason = reason;
    final terminalFailed =
        reason == VoiceEndReason.limit || reason == VoiceEndReason.error;
    if (terminalFailed) _updateState(VoiceState.failed);
    await stopSession(resetState: !terminalFailed, reason: reason);
  }

  // --- STT Logic -------------------------------------------------------------

  /// (Re)opens the microphone for the current session — also the UI's
  /// "restart from idle" entry point: when no session is active it creates a
  /// fresh session generation (the stored send-callback and locale are
  /// reused), so rapid repeated presses simply reuse the same idempotent path.
  void startListening({BuildContext? context}) {
    final gen = _ensureSession();
    if (context != null) _lastContext = context;
    _silenceTimer?.cancel();
    _emptyNativeRestarts = 0;
    unawaited(_beginListening(gen));
  }

  /// True when the CURRENT user turn has recognisable text. Turn-scoped by
  /// definition: a committed turn's words never count here again.
  bool get hasRecognizedText => _turns.hasText;

  void manualSubmit(BuildContext context) async {
    final gen = _activeGeneration;
    if (gen == null) return;
    _silenceTimer?.cancel();
    if (hasRecognizedText) {
      await _finalizeUserSpeech(gen);
    } else {
      // Nothing recognized: the user tapped Stop/Mic without speaking. The
      // capture is released (their explicit intent) and the state resets.
      debugPrint("[VoiceService] Manual stop with no text. Going to Idle.");
      await _speechService.stopListening();

      if (_isFlowInterrupted) {
        _restoreFlow();
      } else {
        _updateState(VoiceState.idle);
      }
    }
  }

  BuildContext? _lastContext;

  /// One STT emission arrived for the ACTIVE user turn. The engine text is
  /// cumulative since the turn boundary; the tracker owns the turn's buffer
  /// (echo-stripped, stale-guarded) and the silence timer is keyed to the
  /// turn it captured, so a timer from an already-committed turn can never
  /// finalize its successor.
  void _resetSilenceTimer(int gen) {
    if (gen != _activeGeneration) return;
    final turnId = _turns.currentTurnId;
    if (turnId == null) return;
    _liveTranscript = _turns.buffer;
    _isLiveUserMessage = true;
    notifyListeners();
    _armInactivityTimer(gen);
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 2), () {
      if (gen != _activeGeneration) return;
      if (turnId != _turns.currentTurnId) return; // this turn already ended
      VoiceTelemetry.mark('user speech endpoint detected');
      unawaited(_finalizeUserSpeech(gen, turnId: turnId));
    });
  }

  /// End-of-turn: the silence timer fired, or the user pressed submit.
  /// Generation-guarded. The provider connection STAYS OPEN across turns —
  /// the continuous-session model (lower latency, barge-in support, one
  /// reserved window per provider session) — only the turn state changes.
  ///
  /// [turnId] keys this finalize to ONE user turn when driven by the silence
  /// timer; a timer that outlived its turn must never commit its successor's
  /// text (or an empty buffer) by accident.
  Future<void> _finalizeUserSpeech(int gen, {int? turnId}) async {
    if (gen != _activeGeneration) return;
    if (turnId != null && turnId != _turns.currentTurnId) return;

    // Check limits again before sending
    final context = _lastContext;
    if (context != null && context.mounted && !_checkLimits(context)) return;

    _silenceTimer?.cancel();
    _armInactivityTimer(gen);

    if (isTestMode) {
      _testModeTimer?.cancel();
      _updateState(VoiceState.processing);

      // Simulate processing delay
      _testModeTimer = Timer(const Duration(seconds: 1), () {
        if (gen != _activeGeneration) return;
        if (_state == VoiceState.processing) {
          debugPrint("[VoiceService] Test Mode: Simulated AI speaking start.");
          _updateState(VoiceState.speaking);

          // Simulate AI speaking duration
          _testModeTimer = Timer(const Duration(seconds: 4), () {
            if (gen != _activeGeneration) return;
            if (_state == VoiceState.speaking) {
              debugPrint(
                "[VoiceService] Test Mode: Simulated AI speaking done. Restarting loop.",
              );
              startListening(context: context);
            }
          });
        }
      });
      return;
    }

    if (_turns.buffer.trim().isEmpty) {
      // Silence during a Flow pause (interrupted but nothing said): the
      // AI-to-AI loop resumes automatically instead of hanging.
      if (isFlowActive && _state == VoiceState.listening) {
        debugPrint("[VoiceService] Silence detected during Flow. Resuming.");
        _restoreFlow();
        return;
      }

      if (_isFlowInterrupted) {
        _restoreFlow();
        return;
      }
      return;
    }

    _updateState(VoiceState.processing);
    _firstAiChunkSeen = false;
    _firstSentenceSeen = false;
    _flowTurnCompleted = false;
    _aiGenerationComplete = false;
    _fullAiResponseBuffer.clear();
    _incomingTextBuffer.clear();

    // Commit the turn: exactly THIS turn's speech — the tracker guarantees
    // the buffer never contains words of previously committed turns.
    final String textToSend = _turns.commit();
    VoiceTelemetry.mark('STT final received');
    VoiceTelemetry.mark('STT final → chat request: "$textToSend"');

    // User speech is visible (breaks the flow loop temporarily; the user can
    // always intervene).
    _shouldNextMessageBeHidden = false;

    // THE TURN BOUNDARY: the conversation keeps the committed message
    // through the normal chat history; the voice accumulator starts empty
    // for the NEXT turn, and the engine's cumulative-text boundary moves
    // with it so "hello" can never grow into "hello how are you?".
    _turns.beginTurn();
    _speechService.beginNewUserTurn();

    _aiGenerationComplete = false;
    _isFlowInterrupted = false; // Reset flag on successful speech
    _emptyNativeRestarts = 0;

    if (isFlowActive) {
      _voiceTimer?.cancel();
      _flow.interruptForUser();
      currentFlowAgentIndex = FlowParticipant.blue.index;
      notifyListeners();
    }

    if (_onFinalSentence != null) {
      // Pass only user text to callback - voice system prompt is handled separately
      debugPrint('[VoiceService] sending committed voice turn');
      _onFinalSentence!(textToSend);
    }
  }

  // --- TTS Logic (Streaming) ---

  /// Helper to clean raw streaming response for UI and TTS
  String _cleanResponseText(String text) {
    String cleaned = text;
    cleaned = cleaned.replaceAll(
      RegExp(r'<function[\s\S]*?</function>[\s:]*'),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'<function[\s\S]*?>[\s:]*'), '');
    cleaned = cleaned.replaceAll(
      RegExp(r'<tool_call>[\s\S]*?</tool_call>[\s:]*'),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'<memory>[\s\S]*?</memory>[\s:]*'),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'<think>[\s\S]*?</think>[\s:]*'), '');
    return cleaned;
  }

  String? _flowVoiceId() =>
      isFlowActive ? _flowVoiceIds[currentFlowParticipant.index] : null;

  /// Called by SendService when AI streams text chunks.
  void onAiStreamCallback(String chunk) {
    final gen = _activeGeneration;
    if (gen == null) return; // No live session: nothing to speak into.
    if (!_firstAiChunkSeen) {
      _firstAiChunkSeen = true;
      VoiceTelemetry.mark('first AI token received');
    }
    if (isFlowActive && _flow.phase == FlowPhase.thinking) {
      _flow.markAiSpeaking();
      notifyListeners();
    }
    final previous = isFlowActive
        ? FlowText.sanitize(_fullAiResponseBuffer.toString(), streaming: true)
        : _fullAiResponseBuffer.toString();
    _fullAiResponseBuffer.write(chunk);
    final visible = isFlowActive
        ? FlowText.sanitize(_fullAiResponseBuffer.toString(), streaming: true)
        : _fullAiResponseBuffer.toString();
    if (visible.startsWith(previous)) {
      _incomingTextBuffer.write(visible.substring(previous.length));
    }
    _liveTranscript = _cleanResponseText(visible);
    _isLiveUserMessage = false;
    notifyListeners();
    _armInactivityTimer(gen);
    _checkForSentences();
  }

  /// Called when AI response is completely finished.
  void onAiResponseFinished() {
    final gen = _activeGeneration;
    if (gen == null) return;
    _adaptiveSegmentTimer?.cancel();
    _adaptiveSegmentTimer = null;
    // Speak any remaining text in buffer
    if (_incomingTextBuffer.isNotEmpty) {
      String text = _cleanResponseText(_incomingTextBuffer.toString());

      if (text.trim().isNotEmpty) {
        _enqueueSentence(text);
      }
      _incomingTextBuffer.clear();
    }
    setAiGenerationComplete(true);
  }

  void _checkForSentences() {
    String currentText = _cleanResponseText(_incomingTextBuffer.toString());

    // If there is an unclosed tag wait for more chunks
    if (currentText.contains('<function') ||
        currentText.contains('<memory>') ||
        currentText.contains('<think>')) {
      _adaptiveSegmentTimer?.cancel();
      _adaptiveSegmentTimer = null;
      _incomingTextBuffer.clear();
      _incomingTextBuffer.write(currentText);
      return;
    }

    currentText = currentText.replaceAll("```", "");

    // Natural multilingual sentence boundaries: the punctuation must be
    // followed by whitespace or the end of the currently streamed text so a
    // decimal number or an abbreviation is not split prematurely.
    RegExp delimiter = RegExp(r'[.?!：。](?=\s|$)');

    while (true) {
      final match = delimiter.firstMatch(currentText);
      if (match == null) break;
      final splitIndex = match.end; // Include the punctuation.
      final sentence = currentText.substring(0, splitIndex).trim();
      currentText = currentText.substring(splitIndex);
      if (sentence.isNotEmpty) {
        _enqueueSentence(sentence);
      }
    }

    _incomingTextBuffer
      ..clear()
      ..write(currentText);
    _scheduleAdaptiveSegmentFlush();
  }

  /// When a model pauses inside a long clause, wait for a short real stream
  /// pause and split only at a word boundary. This starts TTS before the full
  /// response arrives without chopping Turkish/multilingual words or creating
  /// tiny fragments.
  void _scheduleAdaptiveSegmentFlush() {
    _adaptiveSegmentTimer?.cancel();
    _adaptiveSegmentTimer = null;
    final gen = _activeGeneration;
    if (gen == null || _aiGenerationComplete) return;

    final current = _cleanResponseText(_incomingTextBuffer.toString()).trim();
    if (current.length < _adaptiveSegmentMinimum) return;
    final speechGeneration = _speechGeneration;
    _adaptiveSegmentTimer = Timer(_adaptiveSegmentPause, () {
      _adaptiveSegmentTimer = null;
      if (gen != _activeGeneration ||
          speechGeneration != _speechGeneration ||
          _aiGenerationComplete) {
        return;
      }

      final latest = _cleanResponseText(_incomingTextBuffer.toString()).trim();
      final splitIndex = _adaptiveSplitIndex(latest);
      if (splitIndex == null) return;
      final chunk = latest.substring(0, splitIndex).trim();
      final remaining = latest.substring(splitIndex).trimLeft();
      if (chunk.length < _adaptiveSegmentMinimum) return;

      _incomingTextBuffer
        ..clear()
        ..write(remaining);
      VoiceTelemetry.mark(
        'adaptive speech chunk ready (${chunk.length} chars)',
      );
      _enqueueSentence(chunk);
      _checkForSentences();
    });
  }

  int? _adaptiveSplitIndex(String text) {
    if (text.length < _adaptiveSegmentMinimum) return null;
    final limit = math.min(text.length, _adaptiveSegmentMaximum);
    final bounded = text.substring(0, limit);
    final whitespace = bounded.lastIndexOf(RegExp(r'\s'));
    if (whitespace < _adaptiveSegmentMinimum) return null;
    return whitespace;
  }

  void _enqueueSentence(String sentence) {
    String speechText = _cleanResponseText(sentence);
    speechText = speechText.replaceAll(RegExp(r'\`\`\`.*'), '');
    speechText = speechText.replaceAll('*', '');

    if (speechText.trim().isEmpty) return;

    debugPrint(
      "[VoiceService] Enqueuing Sentence: ${speechText.substring(0, speechText.length > 20 ? 20 : speechText.length)}...",
    );
    VoiceTelemetry.mark(
      'sentence queued (${_sentenceQueue.length + 1}): "${speechText.length > 18 ? '${speechText.substring(0, 18)}…' : speechText}"',
    );
    VoiceTelemetry.mark(
      _firstSentenceSeen
          ? 'speakable sentence extracted'
          : 'first speakable sentence extracted',
    );
    VoiceTelemetry.mark('generation chunk ready (${speechText.length} chars)');
    _firstSentenceSeen = true;
    _sentenceQueue.add(speechText);
    if (_isSpeaking) {
      VoiceTelemetry.mark(
        'sentence prefetch eligible (queue=${_sentenceQueue.length})',
      );
      _startPrefetchIfNeeded();
    }
    _processQueue();
  }

  /// Keep at most one ordered look-ahead synthesis in flight. This is called
  /// both when the current sentence starts and when a later sentence arrives
  /// while playback is already running, which avoids queue starvation when
  /// punctuation arrives after sentence N has begun playing.
  void _startPrefetchIfNeeded() {
    if (_prefetchFuture != null || _sentenceQueue.isEmpty) return;
    final generation = _speechGeneration;
    final text = _sentenceQueue.first;
    _prefetchText = text;
    _prefetchGeneration = generation;
    VoiceTelemetry.mark(
      'TTS prefetch start for sentence ${_sentenceSequence + 1}',
    );
    _prefetchFuture = _remoteTts.synthesize(
      text,
      voiceId: _flowVoiceId(),
      telemetryLabel: 'sentence ${_sentenceSequence + 1}',
    );
  }

  Future<void> _processQueue() async {
    final gen = _activeGeneration;
    if (gen == null) return; // No live session: nothing speaks.
    if (_isSpeaking) {
      // Already active.
      return;
    }

    // Safety Loop
    while (_sentenceQueue.isNotEmpty) {
      // Check if interrupted?
      // user logic might call stopSpeaking which clears queue.
      if (_sentenceQueue.isEmpty) break;

      _isSpeaking = true;
      _updateState(VoiceState.speaking);
      final int generation = _speechGeneration;
      final String next = _sentenceQueue.removeAt(0);
      final sentenceNumber = ++_sentenceSequence;

      if (_lastPlaybackEndedAt != null) {
        VoiceTelemetry.mark(
          'sentence $sentenceNumber playback gap '
          '${DateTime.now().difference(_lastPlaybackEndedAt!).inMilliseconds}ms',
        );
      }

      // The sentence being spoken becomes the barge-in detector's echo
      // fingerprint: transcripts of these words arriving during playback are
      // speaker bounce, not the user. The transcript echo filter keeps the
      // same fingerprint so the words can never commit as user text either.
      _bargeIn.onAssistantSpeechStarted(next);
      _echoFilter.onAssistantSpeechStarted(next);

      debugPrint("[VoiceService] Speaking: $next");

      final prefetched =
          _prefetchFuture != null &&
              _prefetchText == next &&
              _prefetchGeneration == generation
          ? _prefetchFuture!
          : _remoteTts.synthesize(
              next,
              voiceId: _flowVoiceId(),
              telemetryLabel: 'sentence $sentenceNumber',
            );
      _prefetchFuture = null;
      _prefetchText = null;
      _prefetchGeneration = null;
      // Start the next look-ahead before awaiting sentence N's bytes or
      // playback. It may complete entirely while N is being spoken.
      _startPrefetchIfNeeded();
      final Future<Uint8List?> pending = prefetched;

      final Uint8List? audio = await pending;
      if (generation != _speechGeneration) return;
      if (gen != _activeGeneration) return;

      // A null result means speech was unavailable — no balance, provider
      // down, no session. Voice mode falls back to the on-device voice rather
      // than going silent.
      bool spoken = false;
      if (audio != null) {
        spoken = await _remoteTts.play(
          audio,
          label: 'sentence $sentenceNumber',
        );
      }
      if (generation != _speechGeneration) return;
      if (gen != _activeGeneration) return;
      if (!spoken) {
        // The platform flutter_tts fallback does not expose decoded PCM
        // samples. Keep continuous idle motion instead of fabricating an
        // output waveform; remote PCM playback supplies the real envelope.
        _remoteTts.outputLevel.value = 0;
        await _flutterTts.speak(next);
        // await _flutterTts.speak() waits because we set awaitSpeakCompletion(true)
        // So this line blocks until speech is done.
        if (generation != _speechGeneration) return;
        if (gen != _activeGeneration) return;
        _remoteTts.outputLevel.value = 0;
      }

      _isSpeaking = false;
      _lastPlaybackEndedAt = DateTime.now();
      _armInactivityTimer(gen);
    }

    // Loop Finished
    debugPrint("[VoiceService] Queue Finished.");
    VoiceTelemetry.mark('TTS queue finished — returning to listening');
    // The next transcript that arrives proves the post-TTS capture path is
    // alive end to end (mic frames → STT): it closes the "TTS completion →
    // next user audio forwarded" timing.
    _awaitingPostTtsTranscript = true;
    _isSpeaking = false;
    _prefetchFuture = null;
    _prefetchText = null;
    _prefetchGeneration = null;
    // Natural end of playback: the post-TTS echo discard window starts, and
    // the autonomous-resume path below returns the session to listening
    // without the user doing anything.
    _bargeIn.onAssistantSpeechStopped();
    _echoFilter.onAssistantSpeechStopped();

    // Trigger Completion Logic (replaces the Handler callback logic)
    if (_aiGenerationComplete) {
      setAiGenerationComplete(true);
    }
  }

  void setAiGenerationComplete(bool complete) {
    _aiGenerationComplete = complete;
    final gen = _activeGeneration;
    if (gen == null) return;

    // Limits inside the AI-to-AI flow loop stay enforced where they always
    // were: SendService fails the turn when the server refuses it, and the
    // session reacts through the ordinary lifecycle.

    if (complete && !_isSpeaking && _sentenceQueue.isEmpty) {
      if (isFlowActive) {
        if (_flow.phase == FlowPhase.idle || _flow.phase == FlowPhase.stopped) {
          _flow.begin(newGeneration: gen);
          _flow.beginAiTurn(currentFlowParticipant);
        }
        // A user turn is the first Blue response of a restarted round. The
        // normal send path has already persisted that user message; advance
        // only after Blue's audio has finished.
        if (_flow.phase == FlowPhase.userSpeaking) {
          _flow.beginAiTurn(FlowParticipant.blue);
          currentFlowAgentIndex = FlowParticipant.blue.index;
        }
        _advanceFlowAfterTurn(gen, _flow.generation);
        return;
      }

      // Edge case: generation finished but nothing was spoken (e.g. very
      // short answer or bug), or generation finished while we were idle.
      _voiceTimer?.cancel();
      _voiceTimer = Timer(const Duration(milliseconds: 500), () {
        if (gen != _activeGeneration) return;
        if (_state != VoiceState.idle && !isFlowActive) {
          _resumeListeningAfterTurn(gen);
        }
      });
    }
  }

  // ===========================================================================
  // SESSION CORE: engine lifecycle, turn routing, reconnect, recycle,
  // allowance plumbing, timeouts. Everything is generation-guarded.
  // ===========================================================================

  /// Returns the active session generation, creating a fresh one when none is
  /// active. A fresh session starts with a clean slate of timers and flags.
  int _ensureSession() {
    final active = _activeGeneration;
    if (active != null) return active;
    final gen = ++_generation;
    _activeGeneration = gen;
    _reconnectAttempts = 0;
    _emptyNativeRestarts = 0;
    _recyclePending = false;
    _lastPlaybackEndedAt = null;
    _sentenceSequence = 0;
    _bargeIn.reset();
    _echoFilter.reset();
    // A fresh session starts a fresh turn lifecycle: no fragment of any
    // earlier session/turn can survive into this one's buffers.
    _turns.beginSession(gen);
    lastEndReason = null;
    return gen;
  }

  /// Opens the capture for [gen] and moves to `listening` on success. On
  /// failure the session ends with a precise reason (allowance exhausted vs
  /// engine failure) so the overlay can explain itself.
  Future<void> _beginListening(int gen, {bool quiet = false}) async {
    if (gen != _activeGeneration) return;
    _silenceTimer?.cancel();
    if (!quiet) _updateState(VoiceState.connecting);
    notifyListeners();

    if (isTestMode) {
      _testModeTimer?.cancel();
      _updateState(VoiceState.listening);
      _testModeTimer = Timer(const Duration(seconds: 3), () {
        if (gen != _activeGeneration) return;
        if (_state == VoiceState.listening) {
          debugPrint(
            "[VoiceService] Test Mode: Simulated user speech finished.",
          );
          unawaited(_finalizeUserSpeech(gen));
        }
      });
      return;
    }

    final started = await _restartEngine(gen);

    if (gen != _activeGeneration) return;
    if (started) {
      _reconnecting = false;
      if (!quiet || _state == VoiceState.connecting) {
        _updateState(VoiceState.listening);
        VoiceTelemetry.mark(
          quiet ? 're-listening (reconnect)' : 'listening ready',
        );
      }
      _startHealthTimer(gen);
      _armInactivityTimer(gen);
      notifyListeners();
    } else {
      // Both engines failed: distinguish "daily allowance exhausted" (the
      // server refused the mint) from a real failure for the UI message.
      final reason = _speechService.remoteVoiceLimitReached
          ? VoiceEndReason.limit
          : VoiceEndReason.error;
      await _endSession(gen, reason);
    }
  }

  /// Opens the capture under this session's owner. Returns whether a capture
  /// actually started.
  Future<bool> _restartEngine(int gen) {
    return _speechService.startListening(
      locale: _currentLocale,
      owner: isFlowMode ? SpeechOwner.flow : SpeechOwner.voice,
      onResult: (text) => _onSttResult(gen, text),
      onClosed: (info) => _handleSttClosed(gen, info),
      onLease: (lease) => _applyLease(gen, lease),
      onSttResult: (result) => _onSttStructuredResult(gen, result),
    );
  }

  /// Routes one STT result by session state:
  ///  * listening — ingested into the ACTIVE user turn (echo-stripped,
  ///    stale-guarded by the tracker) and re-arms the silence timer keyed to
  ///    that turn;
  ///  * speaking — ignored here: the text evidence that matters during
  ///    playback is the STRUCTURED frame (with the provider confidence),
  ///    which arrives via [_onSttStructuredResult] and feeds the barge-in
  ///    detector; echo-transcribed assistant words never leak into the
  ///    user's turn either way;
  ///  * processing/connecting — ignored (the turn is already in flight).
  void _onSttResult(int gen, String text) {
    if (gen != _activeGeneration || text.isEmpty) return;
    if (_awaitingPostTtsTranscript && _state == VoiceState.listening) {
      _awaitingPostTtsTranscript = false;
      VoiceTelemetry.mark('post-TTS user audio reached STT');
    }
    switch (_state) {
      case VoiceState.listening:
        final turnId = _turns.currentTurnId;
        if (turnId == null) break;
        // The engine emission is cumulative since the turn boundary; the
        // tracker owns per-turn accumulation, echo stripping and the
        // stale-fragment guard.
        _turns.ingest(turnId: turnId, raw: text);
        _resetSilenceTimer(gen);
        break;
      default:
        break;
    }
  }

  /// The structured remote frame behind every text result. While the
  /// assistant speaks it feeds the barge-in detector (confidence gate,
  /// word-count gate, echo fingerprint, post-TTS discard window — see
  /// [BargeInDetector]). In the other states the text path alone is enough.
  void _onSttStructuredResult(int gen, SttResult result) {
    if (gen != _activeGeneration || result.text.isEmpty) return;
    if (_state == VoiceState.speaking) {
      _bargeIn.onUserTranscript(
        text: result.text,
        confidence: result.confidence,
      );
      if (_bargeIn.shouldBargeIn) _interruptForBargeIn(gen);
    }
  }

  /// The remote socket closed on its own. The classification (see
  /// [SttCloseInfo]) decides the policy: fatal closes end the session —
  /// retrying a protocol error or undecodable audio stream cannot succeed —
  /// and every other close reconnects under the SAME generation, bounded per
  /// session, with the microphone preserved whenever it is still live.
  void _handleSttClosed(int gen, SttCloseInfo info) {
    if (gen != _activeGeneration || _reconnecting) return;

    if (info.isFatal) {
      debugPrint(
        "[VoiceService] STT closed fatally (session $gen): code=${info.closeCode} msg=${info.msgCode ?? info.closeReason ?? 'n/a'}.",
      );
      unawaited(_endSession(gen, VoiceEndReason.error));
      return;
    }
    if (_state == VoiceState.listening ||
        _state == VoiceState.connecting ||
        _state == VoiceState.speaking) {
      debugPrint(
        "[VoiceService] STT closed (session $gen, ${info.closeClass}) — reconnecting.",
      );
      unawaited(_reconnect(gen, info));
    }
  }

  /// Jittered backoff for a reconnect attempt, driven by the close
  /// classification. Pure and exposed for tests.
  ///
  ///  * reconnectImmediate (Deepgram NET-0001, the client went silent):
  ///    retry fast and keep the line warm — the microphone is supposedly
  ///    streaming, so this is a blip, and the socket-only reconnect makes
  ///    the gap a few hundred milliseconds.
  ///  * reconnect (NET-0000 / unknown abnormal close): exponential from
  ///    0.5s, capped at 3s so a user never waits longer than that for a
  ///    provider hiccup.
  ///  * reconnectExtended (NET-0002 no-audio idle timeout): the
  ///    connection was idle long enough to time out — take the retry slower
  ///    and let the keep-alive supervision own the steady state.
  ///
  /// The jitter keeps a fleet of clients from thundering a provider blip
  /// in lockstep.
  @visibleForTesting
  static Duration reconnectDelayFor(SttCloseInfo info, int attempt) {
    final jitter = DateTime.now().microsecondsSinceEpoch % 250;
    switch (info.closeClass) {
      case SttCloseClass.reconnectImmediate:
        return Duration(milliseconds: 250 + jitter);
      case SttCloseClass.reconnectExtended:
        final total = 2000 + jitter * 4 + (attempt - 1) * 1000;
        return Duration(milliseconds: total > 6000 ? 6000 : total);
      case SttCloseClass.reconnect:
        final base = 500 * (1 << (attempt - 1));
        final total = base + jitter;
        return Duration(milliseconds: total > 3000 ? 3000 : total);
      case SttCloseClass.fatal:
        return Duration.zero; // callers never reconnect on fatal
    }
  }

  Duration _backoffFor(SttCloseInfo info, int attempt) {
    final override = _reconnectBackoffOverride;
    if (override != null) return override(info, attempt);
    return reconnectDelayFor(info, attempt);
  }

  Future<void> _reconnect(int gen, SttCloseInfo info) async {
    if (gen != _activeGeneration || _reconnecting) return;
    if (_reconnectAttempts >= _maxReconnectsPerSession) {
      debugPrint("[VoiceService] Reconnect budget exhausted (session $gen).");
      if (_state == VoiceState.listening || _state == VoiceState.connecting) {
        await _endSession(gen, VoiceEndReason.error);
      }
      return;
    }
    _reconnecting = true;
    _reconnectAttempts++;

    final delay = _backoffFor(info, _reconnectAttempts);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (gen != _activeGeneration) {
      _reconnecting = false;
      return;
    }

    // 1. Socket-only reconnect: the microphone never stopped — its chunks
    //    kept buffering through the gap, so the user's first word after it
    //    flows to the fresh socket instead of being lost to a re-open.
    bool started = false;
    if (_speechService.isRemoteSocketReconnectable) {
      started = await _speechService.reconnectRemoteSocket();
    }
    // 2. Full engine restart: native capture, dead microphone, or a socket
    //    that could not be re-established. If the daily pool was exhausted,
    //    the server refuses this mint and the restart falls back to native;
    //    if that fails too the session ends below.
    if (gen != _activeGeneration) {
      _reconnecting = false;
      return;
    }
    if (!started) {
      started = await _restartEngine(gen);
    }
    if (gen != _activeGeneration) {
      _reconnecting = false;
      return;
    }
    _reconnecting = false;
    if (!started) {
      final reason = _speechService.remoteVoiceLimitReached
          ? VoiceEndReason.limit
          : VoiceEndReason.error;
      await _endSession(gen, reason);
    } else if (_state == VoiceState.connecting) {
      _updateState(VoiceState.listening);
    }
  }

  /// Applies the server's mint response for the CURRENT window: the
  /// authoritative allowance numbers, and the reserved window that schedules
  /// the next provider socket rotation (the server re-checks the pool at each
  /// mint — that is what keeps the server authoritative even though the client
  /// holds the connection).
  ///
  /// `remainingVoiceSeconds` is the DAILY POOL after this window's
  /// reservation (the server reserves min(remaining, 300s) at mint), so 0 is
  /// its normal state right after the first mint of the day on free tier —
  /// not a leak and not an error.
  void _applyLease(int gen, SttLease lease) {
    if (gen != _activeGeneration) return;
    debugPrint(
      "[VoiceService] Lease (session $gen): provider=${lease.provider} allowance=${lease.allowanceVoiceSeconds} remaining=${lease.remainingVoiceSeconds} window=${lease.reservedVoiceSeconds}",
    );
    if (lease.allowanceVoiceSeconds != null) {
      voiceAllowanceSeconds = lease.allowanceVoiceSeconds;
    }
    if (lease.remainingVoiceSeconds != null) {
      remainingVoiceSeconds = lease.remainingVoiceSeconds;
    }
    final window = lease.reservedVoiceSeconds;
    if (window != null && window > 0) {
      _voiceWindowSeconds = window;
      _windowTimer?.cancel();
      _windowTimer = Timer(
        Duration(seconds: windowRecycleDelaySeconds(window)),
        () {
          if (gen != _activeGeneration) return;
          _recyclePending = true;
          _maybeRecycle(gen);
        },
      );
    }
    _startBudgetTicker(gen);
    notifyListeners();
  }

  /// Seconds after a lease lands at which the window-boundary rotation may
  /// fire. Long windows rotate 10 s BEFORE the reservation expires so the
  /// re-mint lands in time; SHORT windows — the daily pool's final seconds —
  /// run their full length instead. The old `window - 10` went NEGATIVE for
  /// any window <= 10 s (window=3 scheduled a recycle at -7 s) and fired the
  /// recycle the instant the lease arrived, tearing the session down before
  /// the user's first word — the immediate-recycle failure seen on device.
  @visibleForTesting
  static int windowRecycleDelaySeconds(int window) {
    assert(window > 0, 'a lease never reserves a non-positive window');
    return window > 10 ? window - 10 : window;
  }

  /// Rotates the provider SOCKET at a TURN BOUNDARY once the reserved window
  /// is nearly exhausted — never mid-utterance (the user's first word must
  /// not land in a reconnect gap). Deferred while the user is speaking; the
  /// next boundary picks it up. The microphone capture is NEVER touched: the
  /// recorder keeps streaming while a freshly minted socket replaces the old
  /// one underneath it (the server re-checks the pool at every mint — that is
  /// the whole point of recycling). The native fallback has no window.
  void _maybeRecycle(int gen) {
    if (gen != _activeGeneration || !_recyclePending) return;
    if (_state != VoiceState.listening || hasRecognizedText) return;
    if (!_speechService.isRemoteActive) return;
    _recyclePending = false;
    debugPrint(
      "[VoiceService] Recycling STT connection at window boundary (session $gen).",
    );
    unawaited(
      _speechService.rotateRemoteSocket().then((rotated) async {
        if (gen != _activeGeneration || rotated) return;
        if (_speechService.remoteVoiceLimitReached) {
          // The server refused the re-mint: the daily pool is genuinely
          // empty. End with the limit reason — the honest, explained exit.
          // A full engine restart is deliberately NOT tried: it would tear
          // the healthy capture down only to bypass the server's allowance
          // contract on the native engine.
          debugPrint(
            "[VoiceService] Window rotation refused: daily allowance "
            "exhausted (session $gen).",
          );
          await _endSession(gen, VoiceEndReason.limit);
          return;
        }
        // Rotation failed for a non-limit reason (network): the socket is
        // gone and only a full engine restart can recover the line — the
        // microphone re-opens with it, which is acceptable exactly because
        // nothing less can recover a failed rotation. If that fails too the
        // session ends with the generic error.
        final started = await _restartEngine(gen);
        if (gen != _activeGeneration || started) return;
        await _endSession(gen, VoiceEndReason.error);
      }),
    );
  }

  /// Inactivity timeout: a session that produces nothing (no speech, no
  /// assistant audio) is an abandoned session and ends itself, so the daily
  /// pool cannot be burned by an open-but-forgotten Voice Mode.
  void _armInactivityTimer(int gen) {
    if (gen != _activeGeneration) return;
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityTimeout, () {
      if (gen != _activeGeneration) return;
      debugPrint("[VoiceService] Session $gen ended: inactivity timeout.");
      unawaited(_endSession(gen, VoiceEndReason.inactivity));
    });
  }

  /// Smooth local countdown between mints; the server's numbers stay
  /// authoritative at every mint and settlement.
  void _startBudgetTicker(int gen) {
    if (gen != _activeGeneration) return;
    _budgetTicker?.cancel();
    _budgetTicker = Timer.periodic(const Duration(seconds: 5), (_) {
      if (gen != _activeGeneration) {
        _budgetTicker?.cancel();
        return;
      }
      final remaining = remainingVoiceSeconds;
      if (remaining != null && remaining > 0) {
        remainingVoiceSeconds = remaining > 5 ? remaining - 5 : 0;
        notifyListeners();
      }
    });
  }

  /// Turn boundary back into listening. On the remote engine the capture is
  /// continuous — nothing to reopen; the native fallback stopped itself after
  /// its last final, so it is restarted here.
  ///
  /// A NEW user turn starts here: the tracker mints its identity (the
  /// buffer starts empty — nothing of the committed turn can carry over)
  /// and the engine's cumulative-text boundary moves with it, flushing any
  /// echo finals the speaker dropped into the accumulator during playback.
  void _resumeListeningAfterTurn(int gen) {
    if (gen != _activeGeneration) return;
    _turns.beginTurn();
    _speechService.beginNewUserTurn();
    _liveTranscript = "";
    _isLiveUserMessage = true;
    _updateState(VoiceState.listening);
    if (!_speechService.isListening) {
      unawaited(_beginListening(gen, quiet: true));
    }
    _maybeRecycle(gen);
    _armInactivityTimer(gen);
  }
}
