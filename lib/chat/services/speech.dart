import 'dart:async';

import 'package:cortex/performance/frame_coalescer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'stt_remote.dart';

/// Who owns the microphone right now. There is exactly one logical owner at
/// any moment; a new owner always terminates the previous one's capture
/// before its own begins (see [SpeechService.startListening]).
enum SpeechOwner { dictation, voice, flow }

/// The one microphone gateway for the whole app.
///
/// Two deliberately separate speech experiences live behind this service:
///
///  * **Ordinary dictation** (`owner: SpeechOwner.dictation`) — the composer
///    microphone button. Runs on the device's NATIVE recognizer only: it
///    must stay effectively unlimited and inexpensive, and never spends
///    remote speech credits. The app language is mapped to the best
///    installed recognizer locale, with English as the fallback.
///
///  * **Voice Mode / Flow Mode** (`owner: SpeechOwner.voice` / `flow`) — the
///    realtime conversational surfaces. Remote-first ([RemoteSttService]:
///    Deepgram, then AssemblyAI, both behind Fulcrum-minted tokens), with
///    the native recognizer as the final resilience fallback.
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

  /// Bumped on every stop: callbacks handed to a capture that has since been
  /// superseded are dropped instead of mutating the new session.
  int _generation = 0;

  /// Owner of the current capture (null while idle). Observability and the
  /// engine-status handlers both read this.
  SpeechOwner? _owner;

  /// Locale ids the native recognizer advertises (cached after the first
  /// native initialization). Null before the first probe.
  List<String>? _nativeLocaleIds;

  bool get isListening => _isListening;
  SpeechOwner? get currentOwner => _owner;

  /// True when the most recent remote mint was refused because the daily
  /// realtime-voice allowance is exhausted (server 403 voice_daily_limit).
  bool get remoteVoiceLimitReached => _remote.dailyVoiceLimitReached;

  /// Whether the CURRENT capture is running on a remote provider (vs native).
  bool get isRemoteActive => _usingRemote && _isListening;

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
        // A status event from a capture nobody owns anymore (or one that was
        // superseded) must not resurrect listening state.
        if (_usingRemote || _disposed || _owner == null) return;
        final listening = status == 'listening';
        final changed = listening != _isListening;
        _isListening = listening;
        if (!listening) _soundLevel = 0.0;
        if (changed || !listening) _notifyNow();
      },
      onError: (e) {
        if (_usingRemote || _disposed || _owner == null) return;
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

  /// Maps the app's language to the best native recognizer locale installed
  /// on this device, falling back to English when the language cannot be
  /// mapped. Requires the native engine to be initialized (call
  /// [_initializeDevice] first) so `locales()` can be probed.
  Future<String> _resolveNativeLocaleId(String languageCode) async {
    final code = languageCode.trim().toLowerCase();
    if (code.isEmpty) return 'en_US';
    if (_nativeLocaleIds == null) {
      try {
        final available = await _speech.locales();
        _nativeLocaleIds =
            available.map((locale) => locale.localeId).toList(growable: false);
      } catch (_) {
        _nativeLocaleIds = const <String>[];
      }
    }
    final ids = _nativeLocaleIds ?? const <String>[];
    for (final id in ids) {
      final idLower = id.toLowerCase();
      if (idLower == code ||
          idLower.startsWith('$code-') ||
          idLower.startsWith('${code}_')) {
        return id;
      }
    }
    // The app language is not a supported recognition locale here: English
    // keeps dictation and the native fallback working.
    return 'en_US';
  }

  /// Starts a microphone capture under [owner], terminating any previous
  /// capture first — the microphone has exactly one logical owner.
  ///
  /// Engine policy belongs to the OWNER, not the caller's mood:
  ///  * dictation → native recognizer only, never remote, never a credit;
  ///  * voice/flow → remote first (Deepgram, then AssemblyAI), with the
  ///    native recognizer as the final resilience fallback.
  ///
  /// Returns whether a capture actually started. Every callback handed out is
  /// generation-guarded: results from a superseded capture never reach the
  /// session that replaced it.
  Future<bool> startListening({
    required String locale,
    required Function(String text) onResult,
    SpeechOwner owner = SpeechOwner.dictation,
    void Function()? onClosed,
    void Function(SttLease lease)? onLease,
  }) async {
    if (_disposed) return false;

    // 1. Ownership arbitration FIRST: the bump kills every callback of the
    //    previous capture; the engines are torn down — remote socket, native
    //    recognizer, whatever was running — before the new capture begins.
    final int generation = ++_generation;
    await _stopEngines();
    if (_disposed || generation != _generation) return false;

    _owner = owner;
    _finalizedText = "";

    final mode = owner == SpeechOwner.flow ? 'flow' : 'voice';

    // 2. Voice/Flow: remote first.
    if (owner != SpeechOwner.dictation) {
      final startedRemote = await _remote.start(
        onResult: (result) {
          if (_disposed || generation != _generation || !_usingRemote) return;
          final spoken = result.isFinal
              ? _appendFinal(result.text)
              : _withInterim(result.text);
          onResult(_capitalize(spoken));
        },
        onClosed: () {
          if (_disposed || generation != _generation) return;
          _usingRemote = false;
          _isListening = false;
          _detachRemoteLevel();
          _notifyNow();
          onClosed?.call();
        },
        onLease: onLease,
        mode: mode,
      );

      if (_disposed || generation != _generation) {
        // Superseded or disposed mid-flight: nothing of ours may become
        // active now. The engines were already torn down by the newer owner.
        if (startedRemote) await _remote.stop();
        return false;
      }

      if (startedRemote) {
        _usingRemote = true;
        _isAvailable = true;
        _isDeviceSupported = true;
        _isListening = true;
        _attachRemoteLevel();
        _notifyNow();
        return true;
      }
    }

    // 3. Native path: always for dictation, the fallback for voice/flow.
    if (!_isDeviceSupported) return false;

    if (!_isAvailable) {
      bool initSuccess = false;
      try {
        initSuccess = await _initializeDevice();
      } on PlatformException catch (e) {
        debugPrint("Speech recognition not available (PlatformException): $e");
        _isDeviceSupported = false;
        _notifyNow();
        return false;
      } catch (e) {
        debugPrint("Speech initialization failed in startListening: $e");
        _isDeviceSupported = false;
        _notifyNow();
        return false;
      }

      if (_disposed || !initSuccess || generation != _generation) {
        return false;
      }
      _isAvailable = true;
    }

    // Locale mapping (app language → installed recognizer locale, English
    // fallback) happens here so BOTH dictation and the native fallback of
    // Voice/Flow honor the application language.
    _localeId = await _resolveNativeLocaleId(locale);
    if (_disposed || generation != _generation) return false;

    await _speech.listen(
      localeId: _localeId,
      onResult: (result) {
        if (_disposed || generation != _generation) return;
        onResult(_capitalize(result.recognizedWords));
      },
      onSoundLevelChange: (level) {
        if (_disposed || !_isListening || generation != _generation) return;
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

    if (_disposed || generation != _generation) {
      try {
        await _speech.stop();
      } catch (_) {}
      return false;
    }
    _isListening = true;
    _notifyNow();
    return true;
  }

  /// Tears down whatever engines might be running. RemoteSttService.stop is
  /// serialized internally and settles provider usage; calling it
  /// unconditionally guarantees no ghost recorder or WebSocket can ever
  /// survive a transition, even from an unexpected path.
  Future<void> _stopEngines() async {
    _usingRemote = false;
    _detachRemoteLevel();
    try {
      await _remote.stop();
    } catch (e) {
      debugPrint("[Speech] Remote stop failed: $e");
    }
    try {
      await _speech.stop();
    } catch (_) {
      // The native engine was never started — nothing to stop.
    }
  }

  Future<void> stopListening() async {
    if (_disposed) return;
    // Invalidate callbacks first, then release the microphone.
    _generation++;
    _owner = null;
    await _stopEngines();
    _isListening = false;
    _soundLevel = 0.0;
    _finalizedText = "";
    _notifyNow();
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
    _owner = null;
    _detachRemoteLevel();
    _levelNotifications.dispose();
    super.dispose();
  }
}
