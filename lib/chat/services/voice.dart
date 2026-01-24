import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cortex/chat/services/speech.dart';

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

  String _currentLocale = "en-US";
  Timer? _silenceTimer;
  Function(String)? _onFinalSentence; // Callback to send text to AI

  // Queue for TTS to speak text as it streams in from AI
  final List<String> _sentenceQueue = [];
  bool _isSpeaking = false;
  final StringBuffer _incomingTextBuffer = StringBuffer();

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
          "[VoiceService] Native listener stopped. Setting state to IDLE.");
      _updateState(VoiceState.idle);
    }
  }

  Future<void> _initTts() async {
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
      _isSpeaking = false;
      if (_sentenceQueue.isNotEmpty) {
        _processQueue();
      } else if (_aiGenerationComplete) {
        // Finished all sentences and AI generation is done.
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_state != VoiceState.idle) {
            startListening();
          }
        });
      }
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

  // --- Main Control Methods ---

  Future<void> startSession({
    required String locale,
    required Function(String) onFinalSentence,
  }) async {
    _currentLocale = locale;
    _onFinalSentence = onFinalSentence;
    _isSpeaking = false;
    _sentenceQueue.clear();
    _incomingTextBuffer.clear();

    // Configure TTS language
    await _flutterTts.setLanguage(locale);

    startListening();
  }

  Future<void> stopSession() async {
    _silenceTimer?.cancel();
    _updateState(
        VoiceState.idle); // Set idle FIRST to prevent auto-restart loop
    await _speechService.stopListening();
    await _flutterTts.stop();
  }

  // --- STT Logic ---

  void startListening() {
    _silenceTimer?.cancel();
    _updateState(VoiceState.listening);

    _speechService.startListening(
      locale: _currentLocale,
      onResult: (text) {
        if (text.isNotEmpty) {
          _resetSilenceTimer(text);
        }
      },
    );
  }

  void manualSubmit() {
    _silenceTimer?.cancel();
    if (_lastRecognizedText.isNotEmpty) {
      _finalizeUserSpeech();
    } else {
      // If nothing recognized yet, do nothing or show visual hint?
    }
  }

  String _lastRecognizedText = "";

  void _resetSilenceTimer(String recognizedText) {
    _lastRecognizedText = recognizedText;
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 2), () {
      _finalizeUserSpeech();
    });
  }

  void _finalizeUserSpeech() async {
    if (_lastRecognizedText.trim().isEmpty) return;

    _silenceTimer?.cancel();
    await _speechService.stopListening();
    _updateState(VoiceState.processing);

    final textToSend = _lastRecognizedText;
    _lastRecognizedText = "";
    _aiGenerationComplete = false;

    if (_onFinalSentence != null) {
      _onFinalSentence!(textToSend);
    }
  }

  void stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    _sentenceQueue.clear();
    _incomingTextBuffer.clear();
    // After stopping, we assume we return to listening? or manual control?
    // User asked: "mikrofon butonu bu butona basıldığında eğer yapay zeka konuşuyosa otomatik olarak suscak ve konuşma sırası kullanıcıya geçicek"
    startListening();
  }

  // --- TTS Logic (Streaming) ---

  /// Called by SendService when AI streams text chunks.
  void onAiStreamCallback(String chunk) {
    _incomingTextBuffer.write(chunk);
    _checkForSentences();
  }

  /// Called when AI response is completely finished.
  void onAiResponseFinished() {
    // Speak any remaining text in buffer
    if (_incomingTextBuffer.isNotEmpty) {
      _enqueueSentence(_incomingTextBuffer.toString());
      _incomingTextBuffer.clear();
    }
    setAiGenerationComplete(true);
  }

  void _checkForSentences() {
    String currentText = _incomingTextBuffer.toString();
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
      }
    }
  }

  void _enqueueSentence(String sentence) {
    _sentenceQueue.add(sentence);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isSpeaking) return;
    if (_sentenceQueue.isEmpty) {
      return;
    }

    _isSpeaking = true;
    _updateState(VoiceState.speaking);
    String next = _sentenceQueue.removeAt(0);
    await _flutterTts.speak(next);
  }

  void setAiGenerationComplete(bool complete) {
    _aiGenerationComplete = complete;
    if (complete && !_isSpeaking && _sentenceQueue.isEmpty) {
      // Edge case: Generation finished but nothing was spoken (e.g. very short answer or bug)
      // Or generation finished while we were idle.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_state != VoiceState.idle) {
          startListening();
        }
      });
    }
  }
}
