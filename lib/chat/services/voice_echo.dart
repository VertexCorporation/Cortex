// lib/chat/services/voice_echo.dart
//
// Assistant-echo suppression for the transcript accumulation path.
//
// The barge-in DECISION was already protected by BargeInDetector's echo
// fingerprint, but the LISTENING transcript path — the text that becomes the
// committed user turn — had no echo gate at all. When platform AEC fails to
// cancel the assistant's own speaker output (playback and capture sat in
// different audio domains), the STT finals contain the assistant's spoken
// words, and they used to flow straight into the outgoing user message.
//
// This filter strips matching assistant-echo SPANS from a transcript while
// preserving the genuine user words before and after the span. It is fed the
// exact sentences as they are queued for TTS (the best available fingerprint
// of "what the speaker just said") and applies:
//
//  * STRONG suppression while TTS is playing and briefly after playback
//    stops — that window is where speaker bleed physically happens, so a
//    generous span match is safe there;
//  * CONSERVATIVE suppression outside that window — only near-verbatim
//    quotes of most of a recent sentence count, so ordinary user speech
//    that merely reuses assistant vocabulary survives.
//
// Pure logic, clock-injected: fully testable without engines.

import 'package:flutter/foundation.dart';

/// One suppression strength profile. The filter picks [strong] inside the
/// TTS/post-TTS window and [conservative] everywhere else.
@visibleForTesting
class EchoStrength {
  const EchoStrength({
    required this.minSpanWords,
    required this.minFractionOfSentence,
    required this.gapTolerance,
    required this.resumeLookahead,
  });

  /// Minimum matched words a transcript span needs before it is treated as
  /// echo. Floors the fraction rule so short sentences still strip a full
  /// verbatim repeat while coincidental short overlaps never do.
  final int minSpanWords;

  /// The span must cover at least this fraction of the fingerprint sentence
  /// — echo clips the sentence, it does not invent a new short one.
  final double minFractionOfSentence;

  /// How many fingerprint words may be skipped when STT drops echo words
  /// mid-sentence (echo audio is degraded before it reaches the recognizer).
  final int gapTolerance;

  /// How many NON-matching transcript words may be bridged when a following
  /// word resumes the match (mis-transcribed echo). One bridging word max,
  /// and only when the match resumes — this is what keeps a *user
  /// correction* ("no, focus on the reader's attention instead") from being
  /// swallowed into a stripped span.
  final int resumeLookahead;

  static const EchoStrength strong = EchoStrength(
    minSpanWords: 3,
    minFractionOfSentence: 0.5,
    gapTolerance: 3,
    resumeLookahead: 1,
  );

  static const EchoStrength conservative = EchoStrength(
    minSpanWords: 5,
    minFractionOfSentence: 0.7,
    gapTolerance: 2,
    resumeLookahead: 0,
  );

  /// The word-count gate for a fingerprint of [sentenceWords] words.
  @visibleForTesting
  int minWordsFor(int sentenceWords) {
    final fractional = (sentenceWords * minFractionOfSentence).ceil();
    return minSpanWords > fractional ? minSpanWords : fractional;
  }
}

/// Strips assistant-echo spans out of incoming STT text.
class AssistantEchoFilter {
  AssistantEchoFilter({DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now());

  /// How long after playback stops the strong window stays open: the tail of
  /// the assistant's audio typically transcribes in the first moments of the
  /// next listening cycle.
  static const Duration strongWindowAfterStop = Duration(milliseconds: 1500);

  /// How many recently spoken sentences are kept as fingerprints. Speaker
  /// bleed arrives within a sentence or two of being spoken; anything older
  /// can no longer be the source.
  static const int fingerprintDepth = 4;

  final DateTime Function() _clock;

  /// Normalized word lists of the most recently spoken assistant sentences.
  final List<List<String>> _fingerprints = [];

  /// While TTS is actively playing. Stronger than the post-stop window
  /// because the speaker is live.
  bool _playbackActive = false;

  /// When playback last stopped (strong window anchor).
  DateTime? _stoppedAt;

  /// The assistant started saying [sentence] — feed it as an echo
  /// fingerprint exactly when it becomes audible.
  void onAssistantSpeechStarted(String sentence) {
    final words = AssistantEchoFilter.normalizeWords(sentence);
    if (words.isEmpty) return;
    _fingerprints.add(words);
    if (_fingerprints.length > fingerprintDepth) {
      _fingerprints.removeAt(0);
    }
    _playbackActive = true;
    _stoppedAt = null;
  }

  /// The assistant's playback stopped (queue drained or audio halted).
  void onAssistantSpeechStopped() {
    _playbackActive = false;
    _stoppedAt = _clock();
  }

  /// True while the speaker is live or within [strongWindowAfterStop] of it
  /// stopping — the window where echoed assistant audio plausibly arrives.
  @visibleForTesting
  bool get strongWindow {
    if (_playbackActive) return true;
    final stoppedAt = _stoppedAt;
    return stoppedAt != null &&
        _clock().difference(stoppedAt) < strongWindowAfterStop;
  }

  /// Full reset — a new session.
  void reset() {
    _fingerprints.clear();
    _playbackActive = false;
    _stoppedAt = null;
  }

  /// Removes assistant-echo spans from [transcript], preserving the genuine
  /// user words before and after each span. Returns the cleaned text with
  /// original casing and collapsed whitespace; returns the input unchanged
  /// when nothing matches.
  String strip(String transcript) {
    final raw = transcript.trim();
    if (raw.isEmpty || _fingerprints.isEmpty) return transcript;

    final rawWords = raw.split(RegExp(r'\s+'));
    final words = List.generate(
      rawWords.length,
      (i) => AssistantEchoFilter._normalizeWord(rawWords[i]),
      growable: false,
    );
    if (words.every((w) => w.isEmpty)) return transcript;

    final strength = strongWindow
        ? EchoStrength.strong
        : EchoStrength.conservative;

    // Short PURE-echo tails first: the last word or two of the assistant's
    // sentence often transcribes right after playback stops, and the span
    // rule alone would never reach its own word floor. If the ENTIRE
    // transcript is an ordered subset of one recent sentence, the utterance
    // contains no user words at all. Strong window only — outside it, a
    // user intentionally quoting two words of the assistant is real speech.
    if (strength == EchoStrength.strong) {
      final meaningful = words.where((w) => w.isNotEmpty).length;
      if (meaningful >= 2) {
        for (final fingerprint in _fingerprints) {
          if (_isOrderedSubset(words, fingerprint)) {
            return '';
          }
        }
      }
    }

    final removed = List.filled(rawWords.length, false);

    for (final fingerprint in _fingerprints) {
      _stripAgainst(words, fingerprint, strength, removed);
    }

    final kept = <String>[];
    for (var i = 0; i < rawWords.length; i++) {
      if (!removed[i]) kept.add(rawWords[i]);
    }
    if (kept.length == rawWords.length) return transcript; // nothing stripped
    return kept.join(' ');
  }

  /// Whether every non-empty word of [words] appears in [fingerprint] in the
  /// same order (any gaps). Used only on whole transcripts in the strong
  /// window to catch clipped pure-echo tails below the span word floor.
  bool _isOrderedSubset(List<String> words, List<String> fingerprint) {
    var f = 0;
    for (final w in words) {
      if (w.isEmpty) continue;
      while (f < fingerprint.length && fingerprint[f] != w) {
        f++;
      }
      if (f >= fingerprint.length) return false;
      f++;
    }
    return true;
  }

  /// Marks transcript word indices covered by echo spans of [fingerprint].
  void _stripAgainst(
    List<String> words,
    List<String> fingerprint,
    EchoStrength strength,
    List<bool> removed,
  ) {
    final minWords = strength.minWordsFor(fingerprint.length);
    var i = 0;
    while (i < words.length) {
      if (words[i].isEmpty || removed[i]) {
        i++;
        continue;
      }
      var bestRun = 0;
      var bestEnd = i;
      // The echo may start mid-sentence (its first words were clipped), so
      // try aligning against every fingerprint position.
      for (var f = 0; f < fingerprint.length; f++) {
        if (fingerprint[f] != words[i]) continue;
        final run = _runLength(words, fingerprint, i, f, strength);
        if (run > bestRun) {
          bestRun = run;
          bestEnd = i + run;
        }
      }
      if (bestRun >= minWords) {
        for (var k = i; k < bestEnd; k++) {
          removed[k] = true;
        }
        i = bestEnd;
      } else {
        i++;
      }
    }
  }

  /// Longest run of transcript words starting at [ti] that aligns with the
  /// fingerprint from [fi], allowing the fingerprint to skip up to
  /// [EchoStrength.gapTolerance] words and the transcript to bridge up to
  /// [EchoStrength.resumeLookahead] non-matching words when the match
  /// resumes right after.
  int _runLength(
    List<String> words,
    List<String> fingerprint,
    int ti,
    int fi,
    EchoStrength strength,
  ) {
    var matched = 0;
    var j = ti;
    var f = fi;
    while (j < words.length && f < fingerprint.length) {
      while (j < words.length && words[j].isEmpty) {
        j++;
      }
      if (j >= words.length) break;
      if (fingerprint[f] == words[j]) {
        j++;
        f++;
        matched++;
        continue;
      }
      // Fingerprint-side gap: the recognizer dropped an echo word.
      var f2 = f + 1;
      var skipped = 0;
      while (f2 < fingerprint.length &&
          fingerprint[f2] != words[j] &&
          skipped < strength.gapTolerance) {
        f2++;
        skipped++;
      }
      if (f2 < fingerprint.length && fingerprint[f2] == words[j]) {
        f = f2;
        continue;
      }
      // Transcript-side bridge: one mis-transcribed word, and only when a
      // following transcript word resumes the fingerprint match. Without the
      // resume requirement a user's trailing words after a partial echo
      // would be swallowed into the span.
      if (strength.resumeLookahead > 0 && matched > 0) {
        var bridged = false;
        for (var ahead = 1; ahead <= strength.resumeLookahead; ahead++) {
          final resume = j + ahead;
          if (resume < words.length && fingerprint[f] == words[resume]) {
            j = resume;
            matched += ahead + 1;
            f++;
            bridged = true;
            break;
          }
        }
        if (bridged) continue;
      }
      break;
    }
    return matched;
  }

  /// Splits into words and normalizes each (see [_normalizeWord]).
  @visibleForTesting
  static List<String> normalizeWords(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .map(AssistantEchoFilter._normalizeWord)
        .where((w) => w.isNotEmpty)
        .toList(growable: false);
  }

  /// Lowercase alphanumeric word (Turkish letters included), punctuation
  /// stripped. Same normalization the barge-in detector uses so the two
  /// layers judge echo identically.
  static String _normalizeWord(String word) {
    return word.toLowerCase().replaceAll(RegExp(r'[^a-z0-9çğıöşü]'), '');
  }
}
