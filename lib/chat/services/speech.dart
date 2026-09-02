import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'stt_remote.dart';

class SpeechService with ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  final RemoteSttService _remote = RemoteSttService.instance;

  /// True while Deepgram is driving. The on-device recogniser stays as the
  /// fallback for anyone the remote path cannot serve — no balance, no
  /// network, permission refused — so both engines have to be accounted for
  /// everywhere below.
  bool _usingRemote = false;

  /// Deepgram reports each settled span once and then moves on, while the
  /// text field wants the whole utterance. Finalised spans accumulate here
  /// and the current interim span is appended for display.
  String _finalizedText = "";

  bool _isAvailable = false;

  // Default to supported. Only disable if OS explicitly says "No Recognition Service".
  bool _isDeviceSupported = true;

  bool _isListening = false;
  double _soundLevel = 0.0;
  String _localeId = "en_US";

  // Getters
  bool get isListening => _isListening;

  double get soundLevel => _usingRemote ? _remote.soundLevel.value : _soundLevel;

  bool get isAvailable => _isAvailable;

  bool get isDeviceSupported => _isDeviceSupported;

  /// Initialises the on-device recogniser with both of its callbacks.
  ///
  /// `speech_to_text` keeps the handlers from the first successful
  /// `initialize` and ignores the ones passed to later calls. The availability
  /// check runs at startup and wins that race, so registering `onStatus` only
  /// at listen time meant it was never registered at all: `_isListening`
  /// stayed false for the whole device-recogniser session, which killed the
  /// waveform (it is gated on that flag) and made voice mode drop straight
  /// back to idle the moment it looked at the flag.
  ///
  /// Both callbacks therefore live here, and every caller goes through this.
  Future<bool> _initializeDevice() async {
    return _speech.initialize(
      onStatus: (status) {
        // Deepgram drives its own state; the device engine is not running.
        if (_usingRemote) return;
        _isListening = status == 'listening';
        if (!_isListening) _soundLevel = 0.0;
        notifyListeners();
      },
      onError: (e) {
        if (_usingRemote) return;
        _isListening = false;
        _soundLevel = 0.0;
        // Only the OS lacking an engine is permanent. Network hiccups and
        // silence timeouts must not hide the feature.
        if (e.errorMsg.contains('recognition service') ||
            e.errorMsg.contains('SpeechRecognizer')) {
          _isDeviceSupported = false;
        }
        debugPrint("Speech error: ${e.errorMsg}");
        notifyListeners();
      },
    );
  }

  /// Lightweight availability check.
  Future<void> checkAvailability() async {
    try {
      final available = await _initializeDevice();
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
    _localeId = locale;

    // Deepgram first, and before the on-device engine is touched at all.
    //
    // It needs nothing from the OS recogniser, so a phone that lacks one —
    // old hardware, no Google apps, the service disabled — should still be
    // able to dictate. The previous order asked the OS for permission to
    // proceed and gave up on exactly the devices the remote path exists to
    // serve.
    //
    // `start` returns false without having started anything when it cannot
    // run, so falling through to the fallback costs nothing.
    _finalizedText = "";
    final startedRemote = await _remote.start(
      onResult: (result) {
        final spoken = result.isFinal
            ? _appendFinal(result.text)
            : _withInterim(result.text);
        onResult(_capitalize(spoken));
      },
      onClosed: () {
        _usingRemote = false;
        _isListening = false;
        notifyListeners();
      },
    );

    if (startedRemote) {
      _usingRemote = true;
      _isAvailable = true;
      _isDeviceSupported = true;
      _isListening = true;
      _remote.soundLevel.addListener(_onRemoteLevel);
      notifyListeners();
      return;
    }

    // ── Fallback: the on-device recogniser ──
    if (!_isDeviceSupported) return;

    if (!_isAvailable) {
      bool initSuccess = false;
      try {
        initSuccess = await _initializeDevice();
      } on PlatformException catch (e) {
        debugPrint("Speech recognition not available (PlatformException): $e");
        _isDeviceSupported = false;
        notifyListeners();
        return;
      } catch (e) {
        debugPrint("Speech initialization failed in startListening: $e");
        _isDeviceSupported = false;
        notifyListeners();
        return;
      }

      if (!initSuccess) {
        // Initialization failed, but maybe temporary.
        return;
      }
      _isAvailable = true;
    }

    await _speech.listen(
      localeId: _localeId,
      onResult: (result) {
        // Send partial or final results immediately to the text field
        onResult(_capitalize(result.recognizedWords));
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

    if (_usingRemote) {
      _usingRemote = false;
      _remote.soundLevel.removeListener(_onRemoteLevel);
      await _remote.stop();
      return;
    }
    await _speech.stop();
  }

  void _onRemoteLevel() => notifyListeners();

  /// Adds a settled span to the utterance and returns the whole thing.
  String _appendFinal(String span) {
    _finalizedText = _finalizedText.isEmpty ? span : "$_finalizedText $span";
    return _finalizedText;
  }

  /// The utterance so far plus the span Deepgram is still revising.
  String _withInterim(String span) =>
      _finalizedText.isEmpty ? span : "$_finalizedText $span";

  /// Matches the on-device path: first letter upper, the rest lower, so the
  /// text field reads the same whichever engine produced it.
  String _capitalize(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }
}
