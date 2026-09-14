// lib/chat/services/voice_health.dart
//
// Debug telemetry for the realtime voice loop.
//
// Real-device testing showed that a voice session can *claim* to be listening
// while no microphone frames are actually flowing (audio-focus churn had
// paused the recorder without a single visible log line). These marks make
// every hop of the pipeline — tap, mic frames, socket, STT final, first AI
// token, sentence queue, TTS synthesis, playback — print a timestamped line,
// so a stall is visible in logcat instead of being inferred from silence.
//
// Debug-only by design: `mark` compiles to a no-op in profile/release builds.

import 'package:flutter/foundation.dart';

class VoiceTelemetry {
  VoiceTelemetry._();

  static DateTime? _anchor;
  static final Map<String, int> _marks = {};
  static DateTime? _endpointAt;
  static DateTime? _sttFinalAt;
  static DateTime? _sendAt;
  static DateTime? _firstTokenAt;
  static DateTime? _sentenceAt;
  static DateTime? _ttsRequestAt;
  static DateTime? _ttsBytesAt;

  /// Starts a new timing window (voice session open). All subsequent marks
  /// are reported as deltas from this instant.
  static void begin() {
    _anchor = DateTime.now();
    _marks.clear();
    _endpointAt = null;
    _sttFinalAt = null;
    _sendAt = null;
    _firstTokenAt = null;
    _sentenceAt = null;
    _ttsRequestAt = null;
    _ttsBytesAt = null;
  }

  /// Records one pipeline hop. Prints `[VT] +<ms>ms <label>` relative to the
  /// last [begin]; repeated labels are suffixed so no hop is silently lost.
  static void mark(String label) {
    final anchor = _anchor;
    final now = DateTime.now();
    final delta = anchor == null ? 0 : now.difference(anchor).inMilliseconds;
    final seen = _marks.containsKey(label) ? ' (#${_marks[label]! + 1})' : '';
    _marks[label] = (_marks[label] ?? 0) + 1;
    if (kDebugMode) {
      debugPrint(
        '[VT] +${delta.toString().padLeft(6)}ms '
        '${now.toString().substring(11, 23)} $label$seen',
      );
      _recordDerivedLatency(label, now);
    }
  }

  /// Emits the useful turn-level deltas beside the raw hop marks. Keeping
  /// these calculations here makes logcat measurements consistent across the
  /// remote and native speech paths without adding work to the UI.
  static void _recordDerivedLatency(String label, DateTime now) {
    if (label == 'user speech endpoint detected') {
      _endpointAt = now;
    } else if (label == 'STT final received') {
      _sttFinalAt = now;
      final start = _endpointAt;
      if (start != null) {
        debugPrint(
          '[VT] metric endpoint→STT-final '
          '${now.difference(start).inMilliseconds}ms',
        );
      }
    } else if (label == 'SendService invoked') {
      _sendAt = now;
      final start = _sttFinalAt;
      if (start != null) {
        debugPrint(
          '[VT] metric STT-final→send '
          '${now.difference(start).inMilliseconds}ms',
        );
      }
    } else if (label == 'first AI token received') {
      _firstTokenAt = now;
      final start = _sendAt;
      if (start != null) {
        debugPrint(
          '[VT] metric send→first-token '
          '${now.difference(start).inMilliseconds}ms',
        );
      }
    } else if (label == 'first speakable sentence extracted' ||
        label == 'speakable sentence extracted') {
      _sentenceAt = now;
      final start = _firstTokenAt;
      if (start != null && label == 'first speakable sentence extracted') {
        debugPrint(
          '[VT] metric first-token→sentence '
          '${now.difference(start).inMilliseconds}ms',
        );
      }
    } else if (label.startsWith('TTS synth request start:')) {
      _ttsRequestAt = now;
    } else if (label.startsWith('TTS bytes ready')) {
      _ttsBytesAt = now;
      final start = _ttsRequestAt;
      if (start != null) {
        debugPrint(
          '[VT] metric TTS-request→bytes '
          '${now.difference(start).inMilliseconds}ms',
        );
      }
      final sentence = _sentenceAt;
      if (sentence != null) {
        debugPrint(
          '[VT] metric sentence-ready→TTS-bytes '
          '${now.difference(sentence).inMilliseconds}ms',
        );
      }
    } else if (label.startsWith('TTS playback start')) {
      final start = _ttsBytesAt;
      if (start != null) {
        debugPrint(
          '[VT] metric TTS-bytes→playback '
          '${now.difference(start).inMilliseconds}ms',
        );
      }
    }
  }

  /// True when a timing window is active — callers use this to gate marks
  /// that would otherwise fire for non-voice surfaces (e.g. dictation).
  static bool get isActive => _anchor != null;
}
