import 'dart:async';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/server/credits.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/tts_remote.dart';

enum VoiceState {
  listening,
  processing,
  speaking,
  idle,
}

class VoiceService with ChangeNotifier {
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
  String? _voiceSystemPrompt;

  String Function(String agentName, String previousResponse)?
      _flowPromptBuilder;
  bool isFlowMode = false; // "Setup" mode (Flow selected but not started)
  bool isFlowActive = false; // "Active" mode (Flow loop running)
  int currentFlowAgentIndex = 0; // 0, 1, 2 for the 3 agents

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
    required SpeechService speechService,
    FlutterTts? flutterTts,
  })  : _speechService = speechService,
        _flutterTts = flutterTts ?? FlutterTts() {
    _initTts();
    _speechService.addListener(_onSpeechStatusChange);
  }

  @override
  void dispose() {
    _speechService.removeListener(_onSpeechStatusChange);
    _silenceTimer?.cancel();
    super.dispose();
  }

  void _onSpeechStatusChange() {
    // If native speech service stops listening (timeout/silence)
    // We must update our internal state to IDLE so the UI shows the Mic button.
    // We DO NOT auto-restart here (to avoid tight loops).
    // User must tap Mic button to restart.
    if (!_speechService.isListening && _state == VoiceState.listening) {
      debugPrint(
          "[VoiceService] Native listener stopped. Setting state to IDLE. isFlowActive: $isFlowActive");
      // If Flow Active, we shouldn't necessarily go IDLE visible?
      // But we need to listen for interruption/wake word?
      // Actually Flow relies on AI-to-AI.
      // If native listener stops in Flow Mode, we just wait for AI.
      _updateState(VoiceState.idle);
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

    // IMMEDIATE INTERRUPTION LOGIC
    await stopSession(resetState: false);

    // TRANSITION LOGIC
    if (isFlowMode) {
      // Voice -> Flow
      // "Stop listening instantly and morph to line"
      _updateState(VoiceState.processing); // Forces "Line" visual
      debugPrint(
          "[VoiceService] Switched to Flow Mode: Stopped Listening, Visual=Line");
    } else {
      // Flow -> Voice
      // "Start listening instantly and morph to dot"
      // [FIX] Ensure we reset the "Flow" loop state so it doesn't auto-continue
      setAiGenerationComplete(false);

      _updateState(VoiceState.listening);
      debugPrint("[VoiceService] Switched to Voice Mode: Visual=Dot");
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
    isFlowActive = true;
    currentFlowAgentIndex = 0;
    _fullAiResponseBuffer.clear();

    // Switch to "Processing" to show 1st agent thinking
    _updateState(VoiceState.processing);
    _updateVoiceParams(0); // Reset voice

    // Trigger callback to send initial hidden message
    _shouldNextMessageBeHidden = true;
    if (_onFinalSentence != null) {
      _onFinalSentence!(prompt);
    }
  }

  bool _isFlowInterrupted = false;

  void interruptFlowAndListen() async {
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
    _restartListeningSafe();
  }

  void stopSpeaking({BuildContext? context}) async {
    await _flutterTts.stop();
    await _remoteTts.stop();
    _isSpeaking = false;
    _cancelPendingSpeech();
    _incomingTextBuffer.clear();

    // [FIX] Hard Stop: Breaking the Flow Loop entirely on manual stop.
    isFlowActive = false;

    // [FIX] Ensure we are in Listening state (Circle) if stopped manually
    _updateState(VoiceState.listening);

    // User interruption returns to listening
    if (context != null && context.mounted) {
      startListening(context: context);
    }
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

  /// Get the current voice system prompt for API calls
  String? get voiceSystemPrompt => _voiceSystemPrompt;

  /// Set a complete voice system prompt (replaces any existing)
  void setVoiceSystemPrompt(String? prompt) {
    _voiceSystemPrompt = prompt;
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

  // --- Main Control Methods ---

  Future<void> startSession({
    BuildContext? context,
    required String locale,
    required Function(String) onFinalSentence,
    String? systemPrompt,
    required String voiceSystemPrompt,
    required String Function(String agentName, String previousResponse)
        flowPromptBuilder,
  }) async {
    // -------------------------------------------------------------------------
    // 1. LIMIT & CREDIT CHECK (Before starting)
    // -------------------------------------------------------------------------
    if (context != null && !_checkLimits(context)) return;

    _currentLocale = locale;
    _onFinalSentence = onFinalSentence;

    // Store localized builders
    _flowPromptBuilder = flowPromptBuilder;
    _voiceSystemPrompt = voiceSystemPrompt;
    _isSpeaking = false;
    _liveTranscript = "";
    _cancelPendingSpeech();
    _incomingTextBuffer.clear();
    _fullAiResponseBuffer.clear();

    // Configure TTS language
    try {
      await _flutterTts.setLanguage(locale);
    } catch (e) {
      debugPrint("[VoiceService] TTS Language Set Error: $e");
    }

    if (context != null && context.mounted) {
      FocusScope.of(context).unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      startListening(context: context);
    }
  }

  bool _checkLimits(BuildContext context) {
    final session = context.read<ChatSessionProvider>();
    // final l10n = AppLocalizations.of(context)!; // Unused

    // Check Chat Limits (e.g. free user max messages)
    if (session.chatLimitManager
            ?.isLimitExceeded(context.read<ConversationProvider>().messages) ==
        true) {
      debugPrint("[VoiceService] Chat limit exceeded. Stopping.");
      stopSession();
      // Optionally show toast/snackbar
      return false;
    }

    // Check Credits
    final credits = context.read<CreditsManager>().totalCreditsNotifier.value;
    if (credits != null && credits <= 0) {
      // Credits check logic primarily happens at generation, but good to double check?
      // Actually CreditsManager handles it.
    }

    return true;
  }

  Future<void> stopSession({bool resetState = true}) async {
    _silenceTimer?.cancel();
    _testModeTimer?.cancel(); // Cancel test timer
    _voiceTimer?.cancel();

    if (resetState) {
      _updateState(
          VoiceState.idle); // Set idle FIRST to prevent auto-restart loop
    }

    await _speechService.stopListening();
    await _flutterTts.stop();

    // Ensure Flow logic is reset?
    // User might resume session, but flow state is persistent until toggled off?
    // Assuming stopSession completely stops everything.
    isFlowActive = false;
    _cancelPendingSpeech();
    _incomingTextBuffer.clear();
    _fullAiResponseBuffer.clear();
    _isSpeaking = false;
  }

  // --- STT Logic ---

  void startListening({BuildContext? context}) {
    _silenceTimer?.cancel();
    _updateState(VoiceState.listening);

    if (isTestMode) {
      _testModeTimer?.cancel();
      _testModeTimer = Timer(const Duration(seconds: 3), () {
        if (_state == VoiceState.listening) {
          debugPrint(
              "[VoiceService] Test Mode: Simulated user speech finished.");
          _finalizeUserSpeech(context);
        }
      });
      return;
    }

    _speechService.startListening(
      locale: _currentLocale,
      onResult: (text) {
        if (text.isNotEmpty) {
          _resetSilenceTimer(text, context);
        }
      },
    );
  }

  bool get hasRecognizedText => _lastRecognizedText.trim().isNotEmpty;

  void manualSubmit(BuildContext context) async {
    _silenceTimer?.cancel();
    if (hasRecognizedText) {
      _finalizeUserSpeech(context);
    } else {
      // If nothing recognized, cancel and go to idle (User tapped Stop/Mic without speaking)
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

  void _resetSilenceTimer(String recognizedText, BuildContext? context) {
    _lastRecognizedText = recognizedText;
    _liveTranscript = recognizedText;
    _isLiveUserMessage = true;
    notifyListeners();
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 2), () {
      _finalizeUserSpeech(context);
    });
  }

  void _finalizeUserSpeech(BuildContext? context) async {
    // Check limits again before sending
    if (context != null && context.mounted && !_checkLimits(context)) return;

    if (isTestMode) {
      _testModeTimer?.cancel();
      _updateState(VoiceState.processing);

      // Simulate processing delay
      _testModeTimer = Timer(const Duration(seconds: 1), () {
        if (_state == VoiceState.processing) {
          debugPrint("[VoiceService] Test Mode: Simulated AI speaking start.");
          _updateState(VoiceState.speaking);

          // Simulate AI speaking duration
          _testModeTimer = Timer(const Duration(seconds: 4), () {
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
      // [NEW] If interrupted but no speech (silence timeout), RESUME FLOW automatically.
      // This fixes the "stuck" issue when Flow pauses for input but user says nothing.
      if (isFlowActive && _state == VoiceState.listening) {
        // Logic: If we were waiting for user input during flow, and they timed out with silence
        // We should just let the flow continue (skip user turn or treat as "continue").
        // Actually, if _isFlowInterrupted was true, _restoreFlow handles it.
        // But what if just normal Flow pause? Flow doesn't pause for user input normally unless interrupted?
        // Ah, Flow is AI-to-AI. User only intervenes via Interrupt.
        // So if we are here, it means Interruption happened or Mic was open.

        debugPrint(
            "[VoiceService] Silence detected during Flow. Resuming automatically.");
        _restoreFlow();
        return;
      }

      if (_isFlowInterrupted) {
        _restoreFlow();
        return;
      }
      return;
    }

    _silenceTimer?.cancel();
    await _speechService.stopListening();
    _updateState(VoiceState.processing);

    String textToSend = _lastRecognizedText;

    // User speech is visible (breaks flow loop temporarily if needed, but per requirement user can intervene)
    _shouldNextMessageBeHidden = false;

    _lastRecognizedText = "";
    _aiGenerationComplete = false;
    _isFlowInterrupted = false; // Reset flag on successful speech

    if (_onFinalSentence != null) {
      // Pass only user text to callback - voice system prompt is handled separately
      _onFinalSentence!(textToSend);
    }
  }

  // --- TTS Logic (Streaming) ---

  /// Helper to clean raw streaming response for UI and TTS
  String _cleanResponseText(String text) {
    String cleaned = text;
    cleaned = cleaned.replaceAll(RegExp(r'<function[\s\S]*?</function>[\s:]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<function[\s\S]*?>[\s:]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<tool_call>[\s\S]*?</tool_call>[\s:]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<memory>[\s\S]*?</memory>[\s:]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<think>[\s\S]*?</think>[\s:]*'), '');
    return cleaned;
  }

  /// Called by SendService when AI streams text chunks.
  void onAiStreamCallback(String chunk) {
    _incomingTextBuffer.write(chunk);
    _fullAiResponseBuffer.write(chunk);
    _liveTranscript = _cleanResponseText(_fullAiResponseBuffer.toString());
    _isLiveUserMessage = false;
    notifyListeners();
    _checkForSentences();
  }

  /// Called when AI response is completely finished.
  void onAiResponseFinished() {
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

      // A null result means speech was unavailable — no balance, provider
      // down, no session. Voice mode falls back to the on-device voice rather
      // than going silent.
      bool spoken = false;
      if (audio != null) {
        spoken = await _remoteTts.play(audio);
      }
      if (generation != _speechGeneration) return;
      if (!spoken) {
        await _flutterTts.speak(next);
        // await _flutterTts.speak() waits because we set awaitSpeakCompletion(true)
        // So this line blocks until speech is done.
        if (generation != _speechGeneration) return;
      }

      _isSpeaking = false;
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

    // We can't access context here easily for limit checks unless passed or provided.
    // However, user intervention checks limits. AI-to-AI loop checks limits here?
    // We need a context reference or provider reference stored if we want to auto-stop in loop.
    // For now, let's rely on SendService failing if limits are hit.
    // But we should try to inject names properly.

    // NOTE: BuildContext is not available here easily without refactoring the whole Service to be dependent on it
    // or passing it in setAiGenerationComplete (which comes from SendService loop).
    // WORKAROUND: We will assume limits are checked at start of turn (SendService).
    // If SendService fails, it sets error message.

    if (complete && !_isSpeaking && _sentenceQueue.isEmpty) {
      // Flow Mode Logic: Cycle to next agent
      if (isFlowActive) {
        // Wait a bit before next turn
        _voiceTimer = Timer(const Duration(milliseconds: 800), () {
          if (!isFlowActive) return; // check if cancelled

          // Prepare next turn
          currentFlowAgentIndex = (currentFlowAgentIndex + 1) % 3;
          notifyListeners();
          _updateVoiceParams(currentFlowAgentIndex);

          // Send hidden message to next agent
          final previousResponse = _fullAiResponseBuffer.toString();
          _fullAiResponseBuffer.clear();

          // LOCALIZATION INJECTION POINT
          // We need localized names: "Red", "Blue", "Purple"
          // We don't have context here. We must store the localized names when starting the session.

          final agentName = _getAgentName(currentFlowAgentIndex);

          // Context prefix for the loop
          // [NEW] Use localized builder
          final String prompt = _flowPromptBuilder != null
              ? _flowPromptBuilder!(agentName, previousResponse)
              : "Cortex Flow Mode ($agentName). Previous: $previousResponse";

          _updateState(VoiceState.processing);

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

      // Edge case: Generation finished but nothing was spoken (e.g. very short answer or bug)
      // Or generation finished while we were idle.
      _voiceTimer = Timer(const Duration(milliseconds: 500), () {
        if (_state != VoiceState.idle) {
          if (!isFlowActive) {
            // STRICT CHECK
            // We need context to restart listening with limits check.
            // Since we can't pass it easily asynchronously here, we skip explicit check
            // assuming stopSession wasn't called.
            _restartListeningSafe();
          } else {
            // Flow Active, but loop handled above in `if (isFlowActive)` block.
            // If we reach here, it implies we might be out of sync?
            // Actually `if (isFlowActive)` above handles it.
            // This else block is for NORMAL Voice Mode (user turn).

            // NO OP here for Flow Mode.
          }
        }
      });
    }
  }

  void _restartListeningSafe() {
    _silenceTimer?.cancel();
    _updateState(VoiceState.listening);
    _speechService.startListening(
      locale: _currentLocale,
      onResult: (text) {
        if (text.isNotEmpty) {
          // We can't access context here for resetSilenceTimer, so we use null and skip limit check in finalize
          // This is a tradeoff. Ideally we store context or providers.
          _resetSilenceTimer(text, null);
        }
      },
    );
  }

  // Store localized names
  List<String> _agentNames = ["Agent 1", "Agent 2", "Agent 3"];

  void setAgentNames(List<String> names) {
    if (names.length == 3) {
      _agentNames = names;
    }
  }

  String _getAgentName(int index) {
    if (index >= 0 && index < _agentNames.length) {
      return _agentNames[index];
    }
    return "Agent $index";
  }
}
