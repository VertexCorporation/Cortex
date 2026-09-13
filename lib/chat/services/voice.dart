import 'dart:async';
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

  VoiceState get state => _state;

  // TEST MODE: Simulate flow without hardware mic
  bool get isTestMode => false; // FORCE DISABLED for production/testing
  Timer? _testModeTimer;

  String _currentLocale = "en-US";
  Timer? _silenceTimer;
  Timer? _voiceTimer;
  Function(String)? _onFinalSentence; // Callback to send text to AI

  bool isFlowMode = false; // "Setup" mode (Flow selected but not started)
  bool isFlowActive = false; // "Active" mode (Flow loop running)
  int currentFlowAgentIndex = 0; // 0, 1, 2 for the 3 agents

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
  /// While the assistant speaks and the remote mic stays open, sustained
  /// microphone level above this for [_bargeInSamples] consecutive samples
  /// PLUS at least one transcript frame counts as the user starting to talk.
  static const double _bargeInLevel = 0.45;
  static const int _bargeInSamples = 3;
  int _bargeInHits = 0;
  bool _heardSpeechWhileSpeaking = false;

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

  /// Bumped whenever speech is cancelled. Remote audio is fetched over the
  /// network, so a sentence can still be in flight when the user interrupts;
  /// without this the reply they cut off would play a moment later.
  int _speechGeneration = 0;

  /// Abandons anything queued or in flight. Callers that clear the queue must
  /// go through here, otherwise an already-dispatched request still speaks.
  void _cancelPendingSpeech() {
    _speechGeneration++;
    _sentenceQueue.clear();
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
  }) : _flutterTts = flutterTts ?? FlutterTts() {
    _initTts();
    _speechService.addListener(_onSpeechStatusChange);
    // App-lifecycle policy: backgrounding the app ends the realtime session
    // (microphone released, provider usage settled, audio stopped). Nothing
    // voice-related may keep running unobserved in the background.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final gen = _activeGeneration;
      if (gen != null) {
        debugPrint(
            "[VoiceService] Session $gen ended: app backgrounded ($state).");
        unawaited(_endSession(gen, VoiceEndReason.background));
      }
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
    super.dispose();
  }

  void _cancelAllTimers() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
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
  }

  void _onSpeechStatusChange() {
    final gen = _activeGeneration;
    if (gen == null) return;

    // 1. Barge-in sampling: the remote mic stays open while the assistant
    //    speaks, and level updates flow through here. Loudness alone is not
    //    enough (speaker echo can look loud without AEC): require sustained
    //    level AND at least one transcript frame, then cut the audio.
    if (_state == VoiceState.speaking && _speechService.isRemoteActive) {
      final level = _speechService.soundLevel;
      if (level >= _bargeInLevel) {
        _bargeInHits++;
        if (_bargeInHits >= _bargeInSamples && _heardSpeechWhileSpeaking) {
          _bargeInHits = 0;
          _interruptForBargeIn(gen);
          return;
        }
      } else {
        _bargeInHits = 0;
      }
    } else {
      _bargeInHits = 0;
    }

    // 2. Native-fallback auto-stop (speech_to_text stops itself after
    //    silence): finalize the captured text if there is any, otherwise
    //    restart — the session continues, but a recognizer that keeps
    //    producing nothing must not tight-loop (bounded empty restarts).
    if (!_speechService.isListening &&
        !_speechService.isRemoteActive &&
        _state == VoiceState.listening) {
      debugPrint(
          "[VoiceService] Native listener stopped (session $gen). hasText: $hasRecognizedText");
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
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
        ],
        IosTextToSpeechAudioMode.voiceChat);

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
      _state = newState;
      notifyListeners();
    }
  }

  void toggleFlowMode() async {
    isFlowMode = !isFlowMode;
    // Reset state when toggling
    isFlowActive = false;
    currentFlowAgentIndex = 0;

    // IMMEDIATE INTERRUPTION LOGIC: the current session (mic + speech) ends
    // cleanly; the toggled mode re-opens what it needs below.
    await stopSession(resetState: false);

    // TRANSITION LOGIC
    if (isFlowMode) {
      // Voice -> Flow: "Stop listening instantly and morph to line".
      _updateState(VoiceState.processing);
      debugPrint(
          "[VoiceService] Switched to Flow Mode: Stopped Listening, Visual=Line");
    } else {
      // Flow -> Voice: "Start listening instantly and morph to dot". A fresh
      // session generation is created by startListening — no stale artifacts.
      setAiGenerationComplete(false);
      _updateState(VoiceState.listening);
      debugPrint("[VoiceService] Switched to Voice Mode: Visual=Dot");
      startListening(context: _lastContext);
    }

    notifyListeners();
  }

  void setFlowMode(bool enabled) {
    if (isFlowMode == enabled) return;
    isFlowMode = enabled;
    isFlowActive = false;
    currentFlowAgentIndex = 0;
    notifyListeners();
  }

  void startFlow() async {
    isFlowActive = true;
    currentFlowAgentIndex = 0;
    _updateState(VoiceState.processing);
  }

  // Overload startFlow to accept the prompt text directly from UI
  void startFlowWithPrompt(String prompt) {
    // A flow turn needs the same session identity voice turns use; create it
    // if the overlay somehow started flow without one.
    final gen = _ensureSession();
    isFlowActive = true;
    currentFlowAgentIndex = 0;
    _fullAiResponseBuffer.clear();

    // Switch to "Processing" to show 1st agent thinking
    _updateState(VoiceState.processing);
    _updateVoiceParams(0); // Reset voice
    _armInactivityTimer(gen);

    // Trigger callback to send initial hidden message
    _shouldNextMessageBeHidden = true;
    if (_onFinalSentence != null) {
      debugPrint("[VoiceService] Flow turn started (session $gen).");
      _onFinalSentence!(prompt);
    }
  }

  bool _isFlowInterrupted = false;

  void interruptFlowAndListen() async {
    final gen = _activeGeneration;
    debugPrint(
        "[VoiceService] Interrupting Flow. Transitioning to Listen Mode.");
    _isFlowInterrupted = true;
    _isSpeaking = false;
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
    await _flutterTts.stop();
    await _remoteTts.stop();
  }

  /// Barge-in: the user started talking over the assistant. Stops the
  /// currently playing audio, invalidates every queued/in-flight TTS chunk of
  /// this generation, discards any partial transcript picked up during
  /// playback (so echo-transcribed assistant words never leak into the
  /// user's turn), and returns to listening immediately.
  void _interruptForBargeIn(int gen) {
    if (gen != _activeGeneration || _state != VoiceState.speaking) return;
    debugPrint("[VoiceService] Barge-in (session $gen): cutting audio.");
    unawaited(_haltAssistantSpeech(gen).then((_) {
      if (gen != _activeGeneration) return;
      _lastRecognizedText = "";
      _liveTranscript = "";
      _isLiveUserMessage = true;
      _heardSpeechWhileSpeaking = false;
      _updateState(VoiceState.listening);
      _armInactivityTimer(gen);
      notifyListeners();
    }));
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
    // Trigger the flow loop again naturally
    setAiGenerationComplete(true);
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
          "[VoiceService] startSession ignored: a session is already active.");
      return;
    }

    // -------------------------------------------------------------------------
    // 1. LIMIT & CREDIT CHECK (Before starting)
    // -------------------------------------------------------------------------
    if (context != null && !_checkLimits(context)) return;

    _lastContext = context;
    _currentLocale = locale;
    _onFinalSentence = onFinalSentence;
    _isSpeaking = false;
    _liveTranscript = "";
    _lastRecognizedText = "";
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

    // Configure TTS language
    try {
      await _flutterTts.setLanguage(locale);
    } catch (e) {
      debugPrint("[VoiceService] TTS Language Set Error: $e");
    }

    if (context != null && !context.mounted) return;

    final gen = _ensureSession();
    debugPrint(
        "[VoiceService] Session $gen starting (${isFlowMode ? "flow" : "voice"}).");
    await _beginListening(gen);
  }

  bool _checkLimits(BuildContext context) {
    final session = context.read<ChatSessionProvider>();

    // Check Chat Limits (e.g. free user max messages)
    if (session.chatLimitManager
            ?.isLimitExceeded(context.read<ConversationProvider>().messages) ==
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

    // Microphone, native TTS and the remote audio player all released.
    await _speechService.stopListening();
    await _flutterTts.stop();
    await _remoteTts.stop();

    // stopSession stops everything, including a running flow loop.
    isFlowActive = false;
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

  bool get hasRecognizedText => _lastRecognizedText.trim().isNotEmpty;

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

  String _lastRecognizedText = "";
  BuildContext? _lastContext;

  void _resetSilenceTimer(String recognizedText, int gen) {
    if (gen != _activeGeneration) return;
    _lastRecognizedText = recognizedText;
    _liveTranscript = recognizedText;
    _isLiveUserMessage = true;
    notifyListeners();
    _armInactivityTimer(gen);
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 2), () {
      unawaited(_finalizeUserSpeech(gen));
    });
  }

  /// End-of-turn: the silence timer fired, or the user pressed submit.
  /// Generation-guarded. The provider connection STAYS OPEN across turns —
  /// the continuous-session model (lower latency, barge-in support, one
  /// reserved window per provider session) — only the turn state changes.
  Future<void> _finalizeUserSpeech(int gen) async {
    if (gen != _activeGeneration) return;

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
                  "[VoiceService] Test Mode: Simulated AI speaking done. Restarting loop.");
              startListening(context: context);
            }
          });
        }
      });
      return;
    }

    if (_lastRecognizedText.trim().isEmpty) {
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

    String textToSend = _lastRecognizedText;

    // User speech is visible (breaks the flow loop temporarily; the user can
    // always intervene).
    _shouldNextMessageBeHidden = false;

    _lastRecognizedText = "";
    _aiGenerationComplete = false;
    _isFlowInterrupted = false; // Reset flag on successful speech
    _emptyNativeRestarts = 0;

    if (_onFinalSentence != null) {
      // Pass only user text to callback - voice system prompt is handled separately
      _onFinalSentence!(textToSend);
    }
  }

  // --- TTS Logic (Streaming) ---

  /// Helper to clean raw streaming response for UI and TTS
  String _cleanResponseText(String text) {
    String cleaned = text;
    cleaned =
        cleaned.replaceAll(RegExp(r'<function[\s\S]*?</function>[\s:]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<function[\s\S]*?>[\s:]*'), '');
    cleaned = cleaned.replaceAll(
        RegExp(r'<tool_call>[\s\S]*?</tool_call>[\s:]*'), '');
    cleaned =
        cleaned.replaceAll(RegExp(r'<memory>[\s\S]*?</memory>[\s:]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<think>[\s\S]*?</think>[\s:]*'), '');
    return cleaned;
  }

  /// Called by SendService when AI streams text chunks.
  void onAiStreamCallback(String chunk) {
    final gen = _activeGeneration;
    if (gen == null) return; // No live session: nothing to speak into.
    _incomingTextBuffer.write(chunk);
    _fullAiResponseBuffer.write(chunk);
    _liveTranscript = _cleanResponseText(_fullAiResponseBuffer.toString());
    _isLiveUserMessage = false;
    notifyListeners();
    _armInactivityTimer(gen);
    _checkForSentences();
  }

  /// Called when AI response is completely finished.
  void onAiResponseFinished() {
    final gen = _activeGeneration;
    if (gen == null) return;
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
      _incomingTextBuffer.clear();
      _incomingTextBuffer.write(currentText);
      return;
    }

    currentText = currentText.replaceAll("```", "");

    // Pattern: any of .?! followed by a space or new line
    RegExp delimiter = RegExp(r'[.?!：。](?=\s|$)');

    if (delimiter.hasMatch(currentText)) {
      int splitIndex =
          currentText.indexOf(delimiter) + 1; // Include the punctuation
      String sentence = currentText.substring(0, splitIndex).trim();
      String remaining = currentText.substring(splitIndex);

      if (sentence.isNotEmpty) {
        _enqueueSentence(sentence);
        _incomingTextBuffer.clear();
        _incomingTextBuffer.write(remaining);

        // Recursively check
        _checkForSentences();
      } else {
        _incomingTextBuffer.clear();
        _incomingTextBuffer.write(remaining);
      }
    }
  }

  void _enqueueSentence(String sentence) {
    String speechText = _cleanResponseText(sentence);
    speechText = speechText.replaceAll(RegExp(r'\`\`\`.*'), '');
    speechText = speechText.replaceAll('*', '');

    if (speechText.trim().isEmpty) return;

    debugPrint(
        "[VoiceService] Enqueuing Sentence: ${speechText.substring(0, speechText.length > 20 ? 20 : speechText.length)}...");
    _sentenceQueue.add(speechText);
    _processQueue();
  }

  Future<void> _processQueue() async {
    final gen = _activeGeneration;
    if (gen == null) return; // No live session: nothing speaks.
    if (_isSpeaking) {
      // Already active.
      return;
    }

    // The next sentence's audio is fetched while the current one plays, so the
    // gap between sentences is playback-to-playback rather than a network
    // round trip each time.
    Future<Uint8List?>? prefetched;

    // Safety Loop
    while (_sentenceQueue.isNotEmpty) {
      // Check if interrupted?
      // user logic might call stopSpeaking which clears queue.
      if (_sentenceQueue.isEmpty) break;

      _isSpeaking = true;
      _updateState(VoiceState.speaking);
      final int generation = _speechGeneration;
      final String next = _sentenceQueue.removeAt(0);

      debugPrint("[VoiceService] Speaking: $next");

      final Future<Uint8List?> pending =
          prefetched ?? _remoteTts.synthesize(next);
      prefetched = _sentenceQueue.isEmpty
          ? null
          : _remoteTts.synthesize(_sentenceQueue.first);

      final Uint8List? audio = await pending;
      if (generation != _speechGeneration) return;
      if (gen != _activeGeneration) return;

      // A null result means speech was unavailable — no balance, provider
      // down, no session. Voice mode falls back to the on-device voice rather
      // than going silent.
      bool spoken = false;
      if (audio != null) {
        spoken = await _remoteTts.play(audio);
      }
      if (generation != _speechGeneration) return;
      if (gen != _activeGeneration) return;
      if (!spoken) {
        await _flutterTts.speak(next);
        // await _flutterTts.speak() waits because we set awaitSpeakCompletion(true)
        // So this line blocks until speech is done.
        if (generation != _speechGeneration) return;
        if (gen != _activeGeneration) return;
      }

      _isSpeaking = false;
      _armInactivityTimer(gen);
    }

    // Loop Finished
    debugPrint("[VoiceService] Queue Finished.");
    _isSpeaking = false;

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
      // Flow Mode Logic: Cycle to next agent
      if (isFlowActive) {
        // Wait a bit before next turn
        _voiceTimer = Timer(const Duration(milliseconds: 800), () {
          if (gen != _activeGeneration) return;
          if (!isFlowActive) return; // check if cancelled

          // Prepare next turn
          currentFlowAgentIndex = (currentFlowAgentIndex + 1) % 3;
          notifyListeners();
          _updateVoiceParams(currentFlowAgentIndex);

          // Send hidden message to next agent
          final previousResponse = _fullAiResponseBuffer.toString();
          _fullAiResponseBuffer.clear();

          // Flow Mode turn: previous response is already in conversation context,
          // so we only re-inject it here to satisfy the non-empty message guard.
          final String prompt = previousResponse;

          _updateState(VoiceState.processing);
          _armInactivityTimer(gen);

          _shouldNextMessageBeHidden = true;
          if (_onFinalSentence != null) {
            debugPrint(
                "[VoiceService] Triggering verified next Flow turn: Agent $currentFlowAgentIndex");
            _onFinalSentence!(prompt);
          } else {
            debugPrint(
                "[VoiceService] CRITICAL ERROR: _onFinalSentence is null!");
          }
        });
        return;
      }

      // Edge case: generation finished but nothing was spoken (e.g. very
      // short answer or bug), or generation finished while we were idle.
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
    _bargeInHits = 0;
    _heardSpeechWhileSpeaking = false;
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
              "[VoiceService] Test Mode: Simulated user speech finished.");
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
      }
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
      onClosed: () => _handleSttClosed(gen),
      onLease: (lease) => _applyLease(gen, lease),
    );
  }

  /// Routes one STT result by session state:
  ///  * listening — feeds the transcript and the silence timer (turn taking);
  ///  * speaking — marks evidence of the user talking over the assistant
  ///    (barge-in); the text itself is discarded so echo-transcribed
  ///    assistant words can never leak into the user's next turn;
  ///  * processing/connecting — ignored (the turn is already in flight).
  void _onSttResult(int gen, String text) {
    if (gen != _activeGeneration || text.isEmpty) return;
    switch (_state) {
      case VoiceState.listening:
        _resetSilenceTimer(text, gen);
      case VoiceState.speaking:
        _heardSpeechWhileSpeaking = true;
      default:
        break;
    }
  }

  /// The remote socket closed on its own (idle close, network drop, provider
  /// session cap): the session is still alive — reconnect under the SAME
  /// generation, bounded per session.
  void _handleSttClosed(int gen) {
    if (gen != _activeGeneration || _reconnecting) return;
    if (_state == VoiceState.listening ||
        _state == VoiceState.connecting ||
        _state == VoiceState.speaking) {
      debugPrint("[VoiceService] STT closed (session $gen) — reconnecting.");
      unawaited(_reconnect(gen));
    }
  }

  Future<void> _reconnect(int gen) async {
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
    // If the daily pool was exhausted, the server refuses this mint and the
    // restart falls back to native; if that fails too the session ends below.
    final started = await _restartEngine(gen);
    if (gen != _activeGeneration) return;
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
  /// the next provider recycle (the server re-checks the pool at each mint —
  /// that is what keeps the server authoritative even though the client holds
  /// the connection).
  void _applyLease(int gen, SttLease lease) {
    if (gen != _activeGeneration) return;
    debugPrint(
        "[VoiceService] Lease (session $gen): provider=${lease.provider} allowance=${lease.allowanceVoiceSeconds} remaining=${lease.remainingVoiceSeconds} window=${lease.reservedVoiceSeconds}");
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
      _windowTimer = Timer(Duration(seconds: window - 10), () {
        if (gen != _activeGeneration) return;
        _recyclePending = true;
        _maybeRecycle(gen);
      });
    }
    _startBudgetTicker(gen);
    notifyListeners();
  }

  /// Recycles the provider connection at a TURN BOUNDARY once the reserved
  /// window is nearly exhausted — never mid-utterance (the user's first word
  /// must not land in a reconnect gap). Deferred while the user is speaking;
  /// the next boundary picks it up. The native fallback has no window.
  void _maybeRecycle(int gen) {
    if (gen != _activeGeneration || !_recyclePending) return;
    if (_state != VoiceState.listening || hasRecognizedText) return;
    if (!_speechService.isRemoteActive) return;
    _recyclePending = false;
    debugPrint(
        "[VoiceService] Recycling STT connection at window boundary (session $gen).");
    unawaited(_restartEngine(gen).then((started) {
      if (gen != _activeGeneration || started) return;
      final reason = _speechService.remoteVoiceLimitReached
          ? VoiceEndReason.limit
          : VoiceEndReason.error;
      unawaited(_endSession(gen, reason));
    }));
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
  void _resumeListeningAfterTurn(int gen) {
    if (gen != _activeGeneration) return;
    _updateState(VoiceState.listening);
    if (!_speechService.isListening) {
      unawaited(_beginListening(gen, quiet: true));
    }
    _maybeRecycle(gen);
    _armInactivityTimer(gen);
  }
}
