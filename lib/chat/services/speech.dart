import 'dart:async';

import 'package:cortex/performance/frame_coalescer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'stt_remote.dart';

class SpeechService with ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  final RemoteSttService _remote = RemoteSttService.instance;
  final FrameCoalescer _levelNotifications = FrameCoalescer();

  bool _usingRemote = false;
  bool _remoteLevelAttached = false;
  bool _disposed = false;
  String _finalizedText = "";
  bool _isAvailable = false;
  bool _isDeviceSupported = true;
  bool _isListening = false;
  double _soundLevel = 0.0;
  String _localeId = "en_US";

  bool get isListening => _isListening;
  double get soundLevel =>
      _usingRemote ? _remote.soundLevel.value : _soundLevel;
  bool get isAvailable => _isAvailable;
  bool get isDeviceSupported => _isDeviceSupported;

  void _notifyNow() {
    if (_disposed) return;
    _levelNotifications.cancel();
    notifyListeners();
  }

  void _notifyVisualLevel() {
    if (_disposed) return;
    // Audio meters can emit substantially faster than the display. Keep the
    // newest value, but rebuild visual listeners at most once per frame.
    _levelNotifications.schedule(() {
      if (!_disposed) notifyListeners();
    });
  }

  void _attachRemoteLevel() {
    if (_remoteLevelAttached) return;
    _remote.soundLevel.addListener(_onRemoteLevel);
    _remoteLevelAttached = true;
  }

  void _detachRemoteLevel() {
    if (!_remoteLevelAttached) return;
    _remote.soundLevel.removeListener(_onRemoteLevel);
    _remoteLevelAttached = false;
  }

  Future<bool> _initializeDevice() async {
    return _speech.initialize(
      onStatus: (status) {
        if (_usingRemote || _disposed) return;
        final listening = status == 'listening';
        final changed = listening != _isListening;
        _isListening = listening;
        if (!listening) _soundLevel = 0.0;
        if (changed || !listening) _notifyNow();
      },
      onError: (e) {
        if (_usingRemote || _disposed) return;
        _isListening = false;
        _soundLevel = 0.0;
        if (e.errorMsg.contains('recognition service') ||
            e.errorMsg.contains('SpeechRecognizer')) {
          _isDeviceSupported = false;
        }
        debugPrint("Speech error: ${e.errorMsg}");
        _notifyNow();
      },
    );
  }

  Future<void> checkAvailability() async {
    if (_disposed) return;
    try {
      final available = await _initializeDevice();
      if (_disposed) return;
      if (available) {
        _isAvailable = true;
        _isDeviceSupported = true;
      }
    } catch (e) {
      debugPrint("Speech Check Critical Failure: $e");
      _isDeviceSupported = false;
    }
    _notifyNow();
  }

  Future<void> startListening({
    required String locale,
    required Function(String text) onResult,
  }) async {
    if (_disposed) return;
    _localeId = locale;
    _finalizedText = "";

    final startedRemote = await _remote.start(
      onResult: (result) {
        if (_disposed || !_usingRemote) return;
        final spoken = result.isFinal
            ? _appendFinal(result.text)
            : _withInterim(result.text);
        onResult(_capitalize(spoken));
      },
      onClosed: () {
        if (_disposed) return;
        _usingRemote = false;
        _isListening = false;
        _detachRemoteLevel();
        _notifyNow();
      },
    );

    if (_disposed) {
      if (startedRemote) await _remote.stop();
      return;
    }

    if (startedRemote) {
      _usingRemote = true;
      _isAvailable = true;
      _isDeviceSupported = true;
      _isListening = true;
      _attachRemoteLevel();
      _notifyNow();
      return;
    }

    if (!_isDeviceSupported) return;

    if (!_isAvailable) {
      bool initSuccess = false;
      try {
        initSuccess = await _initializeDevice();
      } on PlatformException catch (e) {
        debugPrint("Speech recognition not available (PlatformException): $e");
        _isDeviceSupported = false;
        _notifyNow();
        return;
      } catch (e) {
        debugPrint("Speech initialization failed in startListening: $e");
        _isDeviceSupported = false;
        _notifyNow();
        return;
      }

      if (_disposed || !initSuccess) return;
      _isAvailable = true;
    }

    await _speech.listen(
      localeId: _localeId,
      onResult: (result) {
        if (_disposed) return;
        onResult(_capitalize(result.recognizedWords));
      },
      onSoundLevelChange: (level) {
        if (_disposed || !_isListening) return;
        final normalized = ((level + 10) / 20).clamp(0.0, 1.0).toDouble();
        // Tiny microphone noise changes are not visually distinguishable. Skip
        // them before the frame coalescer to reduce scheduling work further.
        if ((normalized - _soundLevel).abs() < 0.005) return;
        _soundLevel = normalized;
        _notifyVisualLevel();
      },
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async {
    if (_disposed) return;
    _isListening = false;
    _soundLevel = 0.0;
    _notifyNow();

    if (_usingRemote) {
      _usingRemote = false;
      _detachRemoteLevel();
      await _remote.stop();
      return;
    }
    await _speech.stop();
  }

  void _onRemoteLevel() {
    if (!_usingRemote || _disposed) return;
    _notifyVisualLevel();
  }

  String _appendFinal(String span) {
    _finalizedText = _finalizedText.isEmpty ? span : "$_finalizedText $span";
    return _finalizedText;
  }

  String _withInterim(String span) =>
      _finalizedText.isEmpty ? span : "$_finalizedText $span";

  String _capitalize(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  @override
  void dispose() {
    _disposed = true;
    _detachRemoteLevel();
    _levelNotifications.dispose();
    super.dispose();
  }
}
