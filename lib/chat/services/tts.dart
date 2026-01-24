// lib/chat/services/tts.dart
//
// Text-to-Speech service for reading messages aloud.

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { idle, playing, paused }

class TtsService with ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  TtsState _state = TtsState.idle;
  TtsState get state => _state;

  String _currentText = '';
  String get currentText => _currentText;

  double _progress = 0.0;
  double get progress => _progress;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _state = TtsState.playing;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _state = TtsState.idle;
        _progress = 1.0;
        notifyListeners();

        // Reset after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _progress = 0.0;
          _currentText = '';
          notifyListeners();
        });
      });

      _flutterTts.setCancelHandler(() {
        _state = TtsState.idle;
        _progress = 0.0;
        _currentText = '';
        notifyListeners();
      });

      _flutterTts.setErrorHandler((message) {
        debugPrint('[TtsService] Error: $message');
        _state = TtsState.idle;
        _progress = 0.0;
        notifyListeners();
      });

      _flutterTts.setProgressHandler((text, start, end, word) {
        // Calculate progress based on character position
        if (_currentText.isNotEmpty) {
          _progress = end / _currentText.length;
          notifyListeners();
        }
      });

      _isInitialized = true;
      debugPrint('[TtsService] Initialized successfully');
    } catch (e) {
      debugPrint('[TtsService] Initialization error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Stop any current speech
    if (_state == TtsState.playing) {
      await stop();
    }

    _currentText = text;
    _progress = 0.0;
    _state = TtsState.playing;
    notifyListeners();

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _state = TtsState.idle;
    _progress = 0.0;
    _currentText = '';
    notifyListeners();
  }

  Future<void> pause() async {
    if (_state == TtsState.playing) {
      await _flutterTts.pause();
      _state = TtsState.paused;
      notifyListeners();
    }
  }

  /// Set language based on app locale
  Future<void> setLanguage(String languageCode) async {
    String ttsLang;
    switch (languageCode) {
      case 'tr':
        ttsLang = 'tr-TR';
        break;
      case 'en':
        ttsLang = 'en-US';
        break;
      case 'de':
        ttsLang = 'de-DE';
        break;
      case 'fr':
        ttsLang = 'fr-FR';
        break;
      case 'es':
        ttsLang = 'es-ES';
        break;
      case 'it':
        ttsLang = 'it-IT';
        break;
      case 'pt':
        ttsLang = 'pt-BR';
        break;
      case 'ru':
        ttsLang = 'ru-RU';
        break;
      case 'ja':
        ttsLang = 'ja-JP';
        break;
      case 'ko':
        ttsLang = 'ko-KR';
        break;
      case 'zh':
        ttsLang = 'zh-CN';
        break;
      case 'ar':
        ttsLang = 'ar-SA';
        break;
      case 'hi':
        ttsLang = 'hi-IN';
        break;
      default:
        ttsLang = 'en-US';
    }

    await _flutterTts.setLanguage(ttsLang);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
