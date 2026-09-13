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

  /// Starts a new timing window (voice session open). All subsequent marks
  /// are reported as deltas from this instant.
  static void begin() {
    _anchor = DateTime.now();
    _marks.clear();
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
    }
  }

  /// True when a timing window is active — callers use this to gate marks
  /// that would otherwise fire for non-voice surfaces (e.g. dictation).
  static bool get isActive => _anchor != null;
}
