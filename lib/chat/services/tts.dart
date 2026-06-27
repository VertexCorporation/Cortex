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

  String get originalText => _originalText;

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
        if (_isInterrupted) return; // Don't reset if we are seeking or pausing

        _state = TtsState.idle;
        _progress = 1.0;
        notifyListeners();

        // Reset after 2 seconds delay as requested
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (_state == TtsState.idle) {
            _progress = 0.0;
            _currentText = '';
            notifyListeners();
          }
        });
      });

      _flutterTts.setCancelHandler(() {
        if (_isInterrupted) return;

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
        // Calculate progress based on character position relative to ORIGINAL full text
        if (_originalText.isNotEmpty) {
          // end is relative to the current chunk being spoken
          int globalPos = _currentOffset + end;
          _progress = globalPos / _originalText.length;
          if (_progress > 1.0) _progress = 1.0;
          notifyListeners();
        }
      });

      _isInitialized = true;
      debugPrint('[TtsService] Initialized successfully');
    } catch (e) {
      debugPrint('[TtsService] Initialization error: $e');
    }
  }

  String _originalText = '';
  int _currentOffset = 0;
  bool _isInterrupted =
      false; // To prevent completion handler from clearing state during seek/pause

  Future<void> speak(String text, {String? languageCode}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (languageCode != null) {
      await setLanguage(languageCode);
    }

    // Stop and Reset
    _isInterrupted =
        true; // prevent completion handler from nuking state immediately
    if (_state == TtsState.playing) {
      await _flutterTts.stop();
      // [FIX] Error -8 often happens if we speak too fast after stop
      await Future.delayed(const Duration(milliseconds: 50));
    }
    _isInterrupted = false;

    // --- ENHANCED REGEX FILTERING ---
    // 0. Remove <think> and <memory> blocks and their trailing colons/whitespace
    String cleanText = text.replaceAll(RegExp(r'<think>[\s\S]*?</think>[\s:]*'), '');
    cleanText = cleanText.replaceAll(RegExp(r'<memory>[\s\S]*?</memory>[\s:]*'), '');
    cleanText = cleanText.replaceAll(RegExp(r'\[SYSTEM MEMORY DIRECTIVE\][\s\S]*'), '');

    // 1. Remove Code Blocks (```...```) content entirely
    cleanText = cleanText.replaceAll(RegExp(r'```[\s\S]*?```'), '');

    // 2. Remove Inline Code (`...`)
    cleanText = cleanText.replaceAll(RegExp(r'`.*?`'), '');

    // 3. Remove Markdown Links [Label](URL) -> Label
    cleanText =
        cleanText.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), (match) {
      return match.group(1) ?? '';
    });

    // 4. Remove generic URLs
    cleanText = cleanText.replaceAll(RegExp(r'https?://\S+'), '');

    // 5. Remove Bold/Italic markers (*, _)
    cleanText = cleanText.replaceAll(RegExp(r'[\*_]{1,3}'), '');

    // 6. Remove Headers (#)
    cleanText = cleanText.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');

    // 7. Filter Emojis & Specific Symbols
    final emojiRegex = RegExp(
        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]|[\u2700-\u27bf])');
    cleanText = cleanText.replaceAll(emojiRegex, '');

    // 8. Remove LaTeX/Math markers and block math
    // Remove display math blocks: $$...$$ or \[...\]
    cleanText = cleanText.replaceAll(RegExp(r'\$\$[\s\S]*?\$\$'), '');
    cleanText = cleanText.replaceAll(RegExp(r'\\\[[\s\S]*?\\\]'), '');
    // Remove inline math: $...$ or \(...\)
    cleanText = cleanText.replaceAll(RegExp(r'\$[^\$\n]+\$'), '');
    cleanText = cleanText.replaceAll(RegExp(r'\\\([\s\S]*?\\\)'), '');
    // Remove remaining LaTeX commands like \frac{}{}, \sqrt{}, etc.
    cleanText = cleanText.replaceAll(RegExp(r'\\[a-zA-Z]+\{[^}]*\}'), '');
    cleanText = cleanText.replaceAll(RegExp(r'\\[a-zA-Z]+'), '');

    // 9. Remove Widget/Flutter notation patterns (e.g., Widget(), Container(), etc.)
    // Match PascalCase followed by parentheses with content
    cleanText = cleanText.replaceAll(RegExp(r'\b[A-Z][a-zA-Z]*\s*\([^)]*\)'), '');

    // 10. Remove remaining noisy symbols
    cleanText = cleanText.replaceAll(RegExp(r'[\=\\\$\;\<\>\{\}\[\]\^\_\|\~]'), '');

    // 11. Remove standalone numbers that aren't part of sentences
    // (e.g., step numbers like "1." at start of line)
    cleanText = cleanText.replaceAll(RegExp(r'^\d+\.\s*', multiLine: true), '');

    // Cleanup extra whitespace
    cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (cleanText.isEmpty) return;

    _originalText = cleanText;
    _currentOffset = 0;
    _progress = 0.0;

    await _speakInternal(cleanText);
  }

  Future<void> _speakInternal(String textChunk) async {
    _currentText = textChunk; // This is the chunk currently being spoken
    _state = TtsState.playing;
    notifyListeners();
    await _flutterTts.speak(textChunk);
  }

  Future<void> stop() async {
    _isInterrupted = false; // Allow completion handler to clean up
    await _flutterTts.stop();
    // Handler will be called, but we can double check:
    _state = TtsState.idle;
    _progress = 0.0;
    _currentText = '';
    _originalText = '';
    _currentOffset = 0;
    notifyListeners();
  }

  Future<void> pause() async {
    if (_state == TtsState.playing) {
      _isInterrupted = true; // Don't treat this as "finished"
      await _flutterTts
          .stop(); // Using stop to ensure we can restart from offset precisely
      _state = TtsState.paused;
      _isInterrupted = false;
      notifyListeners();
    }
  }

  Future<void> resume() async {
    if (_state == TtsState.paused && _originalText.isNotEmpty) {
      // Calculate text remaining based on last progress
      // Progress = (offset + current_chunk_pos) / total
      // We can approximate the resumption point based on _progress
      int startIdx = (_progress * _originalText.length).toInt();
      if (startIdx >= _originalText.length) startIdx = 0;

      _currentOffset = startIdx;
      String textToSpeak = _originalText.substring(startIdx);
      await _speakInternal(textToSpeak);
    }
  }

  Future<void> seek(double newProgress) async {
    if (_originalText.isEmpty) return;

    _isInterrupted = true;
    await _flutterTts.stop();
    _isInterrupted = false;

    int newIndex = (newProgress * _originalText.length).toInt();
    if (newIndex >= _originalText.length) newIndex = _originalText.length - 1;
    if (newIndex < 0) newIndex = 0;

    _currentOffset = newIndex;
    _progress = newProgress; // Optimistic update

    // Only resume playing if we were playing or if requested (usually seek implies play)
    // But if we were paused, maybe stay paused? User usually expects seek -> play.
    // Let's assume seek -> play.
    String textToSpeak = _originalText.substring(newIndex);
    await _speakInternal(textToSpeak);
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
