import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService with ChangeNotifier {
  final SpeechToText _speech = SpeechToText();

  bool _isAvailable = false;

  // Default to supported. Only disable if OS explicitly says "No Recognition Service".
  bool _isDeviceSupported = true;

  bool _isListening = false;
  double _soundLevel = 0.0;
  String _localeId = "en_US";

  // Getters
  bool get isListening => _isListening;

  double get soundLevel => _soundLevel;

  bool get isAvailable => _isAvailable;

  bool get isDeviceSupported => _isDeviceSupported;

  /// Lightweight availability check.
  Future<void> checkAvailability() async {
    try {
      bool available = await _speech.initialize(
        onError: (e) {
          // Only permanently disable buttons if the OS lacks the engine
          if (e.errorMsg.contains('recognition service') ||
              e.errorMsg.contains('SpeechRecognizer')) {
            _isDeviceSupported = false;
            notifyListeners();
          }
          debugPrint("Speech Availability Error: ${e.errorMsg}");
        },
      );
      if (available) {
        _isAvailable = true;
        _isDeviceSupported = true;
      }
    } catch (e) {
      debugPrint("Speech Check Critical Failure: $e");
      // This usually means a platform channel failure, implying no support.
      _isDeviceSupported = false;
    }
    notifyListeners();
  }

  /// Start listening and streaming text.
  Future<void> startListening({
    required String locale,
    required Function(String text) onResult,
  }) async {
    if (!_isDeviceSupported) return;

    // Ensure initialized if not already
    if (!_isAvailable) {
      bool initSuccess = await _speech.initialize(
        onStatus: (status) {
          _isListening = status == 'listening';
          if (!_isListening) {
            _soundLevel = 0.0;
          }
          notifyListeners();
        },
        onError: (errorNotification) {
          _isListening = false;
          _soundLevel = 0.0;
          // Note: We DO NOT set _isDeviceSupported=false here.
          // Temporary errors (network, silence) should not hide the feature.
          notifyListeners();
        },
      );

      if (!initSuccess) {
        // Initialization failed, but maybe temporary.
        return;
      }
      _isAvailable = true;
    }

    _localeId = locale;

    await _speech.listen(
      localeId: _localeId,
      onResult: (result) {
        // Send partial or final results immediately to the text field
        String text = result.recognizedWords;
        // Strict Capitalization: First letter of FIRST word upper, rest lower.
        if (text.isNotEmpty) {
          text = text.trim();
          if (text.isNotEmpty) {
            text = text[0].toUpperCase() + text.substring(1).toLowerCase();
          }
        }
        onResult(text);
      },
      onSoundLevelChange: (level) {
        if (!_isListening) return; // Guard against updates after stop
        // Normalize (-10 to 10) -> (0.0 to 1.0)
        _soundLevel = (level + 10) / 20;
        if (_soundLevel < 0) _soundLevel = 0;
        if (_soundLevel > 1) _soundLevel = 1;
        notifyListeners();
      },
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        partialResults: true, // Crucial for real-time updates
      ),
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    _soundLevel = 0.0;
    notifyListeners();
    await _speech.stop();
  }
}
