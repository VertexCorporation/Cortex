// lib/chat/services/tts.dart
//
// Text-to-Speech service for reading messages aloud.

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_remote.dart';

enum TtsState { idle, playing, paused }

/// Which engine is speaking. The device recogniser and the remote voice have
/// different notions of position and completion, so every transport control
/// has to know which one it is talking to.
enum _TtsEngine { device, remote }

class TtsService with ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  // ── Remote voice ─────────────────────────────────────────────────────────
  //
  // Reading a message aloud used to be the one place the app still spoke in
  // the device's robot voice, which reads as a bug once the user has picked a
  // voice in settings. It now uses the same voice as voice mode, and keeps the
  // device engine for when that is not possible — offline, out of credit, or
  // synthesis simply failing.
  //
  // Playback is driven here rather than through RemoteTtsService.play, which
  // returns only when the audio has finished. The player UI needs pause,
  // resume and seek, so it needs the player itself.

  /// The server takes 800 characters per request, so a message is spoken in
  /// pieces. Sentence boundaries are preferred; the limit is what decides.
  static const int _remoteChunkLimit = 700;

  AudioPlayer? _remotePlayer;
  StreamSubscription<void>? _remoteComplete;
  StreamSubscription<Duration>? _remotePosition;
  StreamSubscription<Duration>? _remoteDurationSub;
  Duration? _remoteDurationCache;

  _TtsEngine _engine = _TtsEngine.device;

  /// The message split for the remote voice, with the character offset each
  /// piece starts at, so progress can be reported against the whole text
  /// rather than the piece being spoken.
  List<String> _chunks = const [];
  List<int> _chunkStarts = const [];

  TtsState _state = TtsState.idle;
  Timer? _ttsTimer;
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
        _ttsTimer = Timer(const Duration(milliseconds: 2000), () {
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
      _ttsTimer?.cancel();
      await _ttsTimerAndWait(const Duration(milliseconds: 50));
    }
    _isInterrupted = false;

    // --- ENHANCED REGEX FILTERING ---
    // 0. Remove <think> and <memory> blocks and their trailing colons/whitespace
    String cleanText =
        text.replaceAll(RegExp(r'<think>[\s\S]*?</think>[\s:]*'), '');
    cleanText =
        cleanText.replaceAll(RegExp(r'<memory>[\s\S]*?</memory>[\s:]*'), '');
    cleanText =
        cleanText.replaceAll(RegExp(r'\[SYSTEM MEMORY DIRECTIVE\][\s\S]*'), '');

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
    cleanText =
        cleanText.replaceAll(RegExp(r'\b[A-Z][a-zA-Z]*\s*\([^)]*\)'), '');

    // 10. Remove remaining noisy symbols
    cleanText =
        cleanText.replaceAll(RegExp(r'[\=\\\$\;\<\>\{\}\[\]\^\_\|\~]'), '');

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

  Future<void> _ttsTimerAndWait(Duration duration) {
    _ttsTimer?.cancel();
    final completer = Completer<void>();
    _ttsTimer = Timer(duration, () => completer.complete());
    return completer.future;
  }

  Future<void> _speakInternal(String textChunk) async {
    _currentText = textChunk; // This is the chunk currently being spoken
    _state = TtsState.playing;
    notifyListeners();

    // The picked voice first. It falls back rather than failing, so a device
    // that cannot reach it still reads the message aloud.
    if (await _speakRemote(textChunk)) return;

    _engine = _TtsEngine.device;
    await _flutterTts.speak(textChunk);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REMOTE VOICE
  // ─────────────────────────────────────────────────────────────────────────

  /// Splits text into pieces the server will accept, breaking at sentence
  /// ends where it can and mid-text only when a single sentence is too long
  /// to send.
  List<String> _splitForRemote(String text) {
    final pieces = <String>[];
    final sentences = text.split(RegExp(r'(?<=[.!?…])\s+'));

    var current = "";
    void flush() {
      final trimmed = current.trim();
      if (trimmed.isNotEmpty) pieces.add(trimmed);
      current = "";
    }

    for (final sentence in sentences) {
      if (sentence.length > _remoteChunkLimit) {
        flush();
        for (var i = 0; i < sentence.length; i += _remoteChunkLimit) {
          final end = (i + _remoteChunkLimit).clamp(0, sentence.length);
          pieces.add(sentence.substring(i, end).trim());
        }
        continue;
      }
      if (current.length + sentence.length + 1 > _remoteChunkLimit) flush();
      current = current.isEmpty ? sentence : "$current $sentence";
    }
    flush();

    return pieces.where((p) => p.isNotEmpty).toList(growable: false);
  }

  /// Starts the remote voice. Returns false when it could not speak at all,
  /// leaving nothing playing so the caller can use the device engine.
  Future<bool> _speakRemote(String text) async {
    await _stopRemote();

    final pieces = _splitForRemote(text);
    if (pieces.isEmpty) return false;

    // Offsets are measured against the text actually spoken, so the progress
    // bar tracks the whole message rather than restarting at each piece.
    final starts = <int>[];
    var offset = 0;
    for (final piece in pieces) {
      starts.add(offset);
      offset += piece.length + 1;
    }

    _chunks = pieces;
    _chunkStarts = starts;
    _engine = _TtsEngine.remote;

    if (await _playChunk(0)) return true;

    // Nothing was produced; leave no trace for the device engine to trip over.
    _engine = _TtsEngine.device;
    _chunks = const [];
    _chunkStarts = const [];
    return false;
  }

  Future<bool> _playChunk(int index) async {
    if (index < 0 || index >= _chunks.length) return false;

    final bytes = await RemoteTtsService.instance.synthesize(_chunks[index]);
    if (bytes == null) return false;

    try {
      final player = _remotePlayer ??= AudioPlayer();
      await player.stop();

      await _remoteComplete?.cancel();
      await _remotePosition?.cancel();
      await _remoteDurationSub?.cancel();

      // Duration arrives after playback starts, so progress within a piece is
      // reported only once it is known. Until then the bar sits at the piece's
      // starting offset rather than jumping around.
      _remoteDurationCache = null;
      _remoteDurationSub = player.onDurationChanged.listen((d) {
        _remoteDurationCache = d;
      });

      _remotePosition = player.onPositionChanged.listen((position) {
        _reportRemoteProgress(index, position);
      });

      _remoteComplete = player.onPlayerComplete.listen((_) {
        unawaited(_advanceRemote(index));
      });

      await player.play(BytesSource(bytes));
      _state = TtsState.playing;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("[TtsService] Remote playback failed: $e");
      return false;
    }
  }

  void _reportRemoteProgress(int index, Duration position) {
    if (_engine != _TtsEngine.remote || _originalText.isEmpty) return;
    if (index >= _chunkStarts.length) return;

    final total = _remoteDurationCache;
    final chunkLength = _chunks[index].length;

    var within = 0.0;
    if (total != null && total.inMilliseconds > 0) {
      within = position.inMilliseconds / total.inMilliseconds;
      if (within > 1.0) within = 1.0;
    }

    final spoken = _chunkStarts[index] + (chunkLength * within);
    _progress = (spoken / _originalText.length).clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Moves to the next piece, or settles as finished.
  Future<void> _advanceRemote(int finished) async {
    if (_engine != _TtsEngine.remote) return;
    if (_isInterrupted) return;

    final next = finished + 1;
    if (next < _chunks.length && await _playChunk(next)) return;

    _state = TtsState.idle;
    _progress = 1.0;
    notifyListeners();

    _ttsTimer = Timer(const Duration(milliseconds: 2000), () {
      if (_state == TtsState.idle) {
        _progress = 0.0;
        _currentText = '';
        notifyListeners();
      }
    });
  }

  Future<void> _stopRemote() async {
    await _remoteComplete?.cancel();
    await _remotePosition?.cancel();
    await _remoteDurationSub?.cancel();
    _remoteComplete = null;
    _remotePosition = null;
    _remoteDurationSub = null;
    _remoteDurationCache = null;
    try {
      await _remotePlayer?.stop();
    } catch (_) {}
  }

  Future<void> stop() async {
    _isInterrupted = false; // Allow completion handler to clean up
    _ttsTimer?.cancel();
    await _stopRemote();
    _engine = _TtsEngine.device;
    _chunks = const [];
    _chunkStarts = const [];
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
    if (_state != TtsState.playing) return;

    _isInterrupted = true; // Don't treat this as "finished"
    if (_engine == _TtsEngine.remote) {
      // Real audio, so it can be suspended where it stands rather than
      // restarted from a character offset.
      try {
        await _remotePlayer?.pause();
      } catch (e) {
        debugPrint("[TtsService] Remote pause failed: $e");
      }
    } else {
      // Using stop so playback can restart from the offset precisely.
      await _flutterTts.stop();
    }
    _state = TtsState.paused;
    _isInterrupted = false;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_state != TtsState.paused) return;

    if (_engine == _TtsEngine.remote) {
      try {
        await _remotePlayer?.resume();
        _state = TtsState.playing;
        notifyListeners();
        return;
      } catch (e) {
        debugPrint("[TtsService] Remote resume failed: $e");
      }
    }

    if (_originalText.isNotEmpty) {
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

    if (_engine == _TtsEngine.remote && _chunks.isNotEmpty) {
      // Seeking lands on the piece containing that point and starts it from
      // the beginning. Sub-piece accuracy would mean mapping characters onto
      // milliseconds, which the audio gives no way to do honestly.
      final target = (newProgress * _originalText.length).toInt();
      var piece = 0;
      for (var i = 0; i < _chunkStarts.length; i++) {
        if (_chunkStarts[i] <= target) piece = i;
      }
      _isInterrupted = false;
      _progress = newProgress;
      notifyListeners();
      if (await _playChunk(piece)) return;
      // Falling through means the remote voice gave out mid-message; the
      // device engine picks up from the requested point.
      _engine = _TtsEngine.device;
    }

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
    unawaited(_stopRemote());
    _remotePlayer?.dispose();
    _remotePlayer = null;
    super.dispose();
  }
}
