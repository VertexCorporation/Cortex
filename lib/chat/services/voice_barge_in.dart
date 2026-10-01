// lib/chat/services/voice_barge_in.dart
//
// Confidence-gated barge-in for Voice Mode.
//
// The remote microphone stays OPEN while the assistant speaks (continuous
// capture, no muting, whatever AEC the record config enabled stays on), so
// the problem is deciding which of the sounds and transcripts arriving
// during playback are the USER starting to talk rather than the assistant's
// own voice bouncing back.
//
// One kind of evidence alone is not enough — loud echo looks like speech,
// and speaker bleed transcribes as confident words. The detector fires only
// when several independent signals agree:
//
//   * a transcript the provider was confident about (>= [minConfidence]),
//     with at least [minWords] words (single-word echoes are rejected),
//   * that is not the assistant's own words echoed back ([echoSimilarity]
//     against the recently spoken sentences below [echoSimilarityLimit]),
//   * arriving outside the [postTtsDiscardWindow] after playback stopped
//     (the tail of the assistant's audio often transcribes right after TTS
//     ends),
//   * while the microphone amplitude has stayed above [amplitudeFloor] for
//     more than [amplitudeSustain] — a sustained voice, not a click or the
//     coalescer catching up.
//
// Pure logic, clock-injected: everything is testable without engines.

import 'package:flutter/foundation.dart';

class BargeInDetector {
  BargeInDetector({DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now());

  /// Microphone loudness floor (0..1) that counts as voice.
  static const double amplitudeFloor = 0.3;

  /// How long the level must stay above the floor to count as a sustained
  /// voice, not a transient blip.
  static const Duration amplitudeSustain = Duration(milliseconds: 180);

  /// Provider confidence an incoming transcript needs to count as evidence.
  /// Null confidence ("unknown", not "zero") does not disqualify — the
  /// native fallback never reports one and must not lose barge-in entirely.
  static const double minConfidence = 0.75;

  /// Minimum word count in the transcript evidence.
  static const int minWords = 1;

  /// Token-set similarity at or above which a transcript is judged to be
  /// the assistant's own words coming back (echo), not the user.
  static const double echoSimilarityLimit = 0.85;

  /// Transcripts arriving this soon after playback stopped are discarded:
  /// they are almost always the tail of the assistant's own audio.
  static const Duration postTtsDiscardWindow = Duration(milliseconds: 250);

  /// How many recent assistant sentences are kept as the echo fingerprint.
  static const int _fingerprintDepth = 3;

  final DateTime Function() _clock;

  /// Normalized text of the most recently spoken assistant sentences — the
  /// echo fingerprint. Bounded: only the last few sentences can still be
  /// audibly bleeding into the mic.
  final List<String> _assistantFingerprints = [];

  /// When the assistant's playback last stopped, for the discard window.
  DateTime? _assistantStoppedAt;

  /// When the amplitude first crossed the floor in the current loud run.
  DateTime? _loudSince;
  bool _loudNow = false;

  /// Whether an accepted transcript (confident, non-echo, in-window) has
  /// been seen since the last reset.
  bool _transcriptEvidence = false;
  String acceptedTranscript = '';

  /// One-shot latch: barge-in fires once per reset cycle.
  bool _fired = false;

  /// The assistant started saying [sentence]. Feeds the echo fingerprint.
  /// Also clears any playback-stopped discard window: while audio flows,
  /// transcripts are judged on confidence and similarity alone.
  void onAssistantSpeechStarted(String sentence) {
    final normalized = _normalize(sentence);
    if (normalized.isEmpty) return;
    _assistantFingerprints.add(normalized);
    if (_assistantFingerprints.length > _fingerprintDepth) {
      _assistantFingerprints.removeAt(0);
    }
    _assistantStoppedAt = null;
    _fired = false;
  }

  /// The assistant's playback stopped (queue drained or audio halted):
  /// starts the post-TTS discard window and clears the loudness run.
  void onAssistantSpeechStopped() {
    _assistantStoppedAt = _clock();
    _loudSince = null;
    _loudNow = false;
  }

  /// One transcript frame captured while the assistant speaks — interim or
  /// final alike: interims react faster, and the quality gates below already
  /// reject noise. Accepts it as barge-in evidence only when every gate
  /// passes. Cheap: returns early on the first disqualifier.
  void onUserTranscript({required String text, double? confidence}) {
    if (_fired) return;

    // The provider itself was unsure of these words.
    if (confidence != null && confidence < minConfidence) return;

    final words = _normalize(text).split(' ');
    if (words.where((w) => w.isNotEmpty).length < minWords) return;

    // The tail of the assistant's own playback transcribing right after
    // TTS stopped.
    final stoppedAt = _assistantStoppedAt;
    if (stoppedAt != null &&
        _clock().difference(stoppedAt) < postTtsDiscardWindow) {
      return;
    }

    // The assistant's own words bouncing back from the speaker.
    for (final fingerprint in _assistantFingerprints) {
      if (echoSimilarity(text, fingerprint) >= echoSimilarityLimit ||
          fingerprint.split(' ').contains(_normalize(text))) {
        return;
      }
    }

    _transcriptEvidence = true;
    acceptedTranscript = text;
  }

  /// One microphone level sample (0..1) observed while the assistant speaks.
  void onLevel(double level) {
    if (level > amplitudeFloor) {
      _loudSince ??= _clock();
      _loudNow = true;
    } else {
      _loudSince = null;
      _loudNow = false;
    }
  }

  /// Whether the accumulated evidence means "the user is talking over the
  /// assistant". One-shot: latches until [reset].
  bool get shouldBargeIn {
    if (_fired) return false;
    final loudSince = _loudSince;
    if (!_loudNow || loudSince == null) return false;
    if (!_transcriptEvidence) return false;
    if (_clock().difference(loudSince) < amplitudeSustain) return false;
    _fired = true;
    return true;
  }

  /// Full reset — a new session, a completed interrupt, a state where the
  /// detector no longer applies.
  void reset() {
    _assistantFingerprints.clear();
    _assistantStoppedAt = null;
    _loudSince = null;
    _loudNow = false;
    _transcriptEvidence = false;
    acceptedTranscript = '';
    _fired = false;
  }

  /// Token-set similarity between two utterances, 0..1 (Jaccard over the
  /// normalized word sets). Pure and exposed for tests.
  @visibleForTesting
  static double echoSimilarity(String candidate, String spoken) {
    final setA = _normalize(candidate)
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toSet();
    final setB = _normalize(spoken)
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toSet();
    if (setA.isEmpty || setB.isEmpty) return 0.0;
    final union = setA.union(setB).length;
    return union == 0 ? 0.0 : setA.intersection(setB).length / union;
  }

  /// Lowercase, alphanumeric words only (Turkish letters included).
  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .trim();
  }
}
