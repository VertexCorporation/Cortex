// lib/chat/services/voice_turns.dart
//
// The per-turn transcript lifecycle for Voice Mode.
//
// THE BUG THIS FIXES: the microphone capture deliberately outlives a user
// turn (the continuous-session model — one socket, one reserved window,
// barge-in support). The STT layer therefore emits text cumulative since the
// CAPTURE started, and the voice session used to accept it as the CURRENT
// turn's text. Turn 1 "hello" committed, the user said "how are you?" for
// turn 2, and the outgoing message became "hello how are you?" — and it kept
// growing every turn.
//
// THE INVARIANTS (all enforced here, all tested):
//   1. Every listening user turn has its own identity (session + turn id).
//   2. STT fragments accumulate only inside the ACTIVE turn.
//   3. Once committed, the turn is preserved by the normal chat history and
//      the voice accumulator starts EMPTY for the next turn.
//   4. A later turn never inherits text from a committed one.
//   5. Stale STT callbacks from an older turn cannot append to the new one
//      (turn-id guards + a time-bound late-final guard against the race
//      where the provider's final for the committed utterance lands just
//      after the commit).
//   6. Reconnects within the SAME unfinished turn preserve that turn's text
//      (the buffer lives here, keyed by turn, not by the socket).
//   7. A new listening cycle after a completed response starts empty.
//   8. Barge-in mints/continues the NEW turn; the user's words spoken during
//      playback (already inside the engine's cumulative text) survive the
//      boundary via echo filtering rather than being dropped or mixed with
//      the committed turn.
//
// Echo suppression ([AssistantEchoFilter]) is applied at ingest: assistant
// speaker-bleed inside the cumulative text is stripped as spans, so genuine
// user words before/after the echo survive into the committed turn.

import 'package:flutter/foundation.dart';

import 'voice_echo.dart';
import 'voice_health.dart';

/// One user turn: identity + the accumulated transcript of that turn only.
@visibleForTesting
class VoiceUserTurn {
  VoiceUserTurn({required this.id});

  final int id;
  String text = '';
  bool committed = false;
}

/// Owns the session/turn identities and the current turn's buffer. Pure,
/// clock-injected (for the late-final guard window) and echo-injected.
class VoiceTurnTracker {
  VoiceTurnTracker({
    DateTime Function()? clock,
    AssistantEchoFilter? echoFilter,
  }) : _clock = clock ?? (() => DateTime.now()),
       _echo = echoFilter;

  /// A transcript frame arriving this soon after a commit that exactly
  /// matches (or extends) the committed text is the provider's late final
  /// for the ALREADY COMMITTED utterance — it belongs to the old turn and
  /// must never seed the new one.
  static const Duration staleFinalGuardWindow = Duration(seconds: 3);

  final DateTime Function() _clock;
  final AssistantEchoFilter? _echo;

  int? _sessionId;
  int _turnSeq = 0;
  VoiceUserTurn? _current;

  /// The committed text + time of the immediately previous turn — feeds the
  /// stale-final guard.
  String _committedText = '';
  DateTime? _committedAt;

  /// The session this tracker was last started for (observability/tests).
  int? get sessionId => _sessionId;

  /// The active (uncommitted) turn's id, or null when no session is live.
  int? get currentTurnId =>
      (_current != null && !_current!.committed) ? _current!.id : null;

  /// The active turn's accumulated text ('' when no live turn).
  String get buffer {
    final cur = _current;
    return (cur == null || cur.committed) ? '' : cur.text;
  }

  /// True when the active turn has recognisable text.
  bool get hasText => buffer.trim().isNotEmpty;

  /// Starts a fresh session [sessionId]: previous turns can never bleed in.
  /// The session's first user turn is minted immediately so fragments of the
  /// very first utterance have a live turn to land in.
  void beginSession(int sessionId) {
    _sessionId = sessionId;
    _turnSeq = 0;
    _current = null;
    _committedText = '';
    _committedAt = null;
    _turnLog('session $sessionId opened');
    beginTurn();
  }

  /// Full reset — session end.
  void reset() {
    _sessionId = null;
    _current = null;
    _committedText = '';
    _committedAt = null;
    _turnLog('reset');
  }

  /// Mints the next user turn (reusing an existing empty, uncommitted one —
  /// barge-in/resume boundaries are idempotent). Returns the turn id that
  /// subsequent STT fragments must be ingested under.
  int beginTurn() {
    final cur = _current;
    if (cur != null && !cur.committed && cur.text.trim().isEmpty) {
      _log('turn ${cur.id}: reuse empty live turn');
      return cur.id;
    }
    _current = VoiceUserTurn(id: ++_turnSeq);
    _log('turn ${_current!.id}: buffer reset (new user turn)');
    _turnLog('turn ${_current!.id} begins (session ${_sessionId ?? '—'})');
    return _current!.id;
  }

  /// Ingests one STT emission for [turnId]. The incoming text is cumulative
  /// since the turn boundary (the engine's semantics); echo spans are
  /// stripped, a stale re-emit of the just-committed turn is dropped, and
  /// the cleaned text REPLACES the turn buffer. Fragments for any turn other
  /// than the active one are logged and dropped.
  void ingest({required int turnId, required String raw}) {
    final cur = _current;
    if (cur == null || cur.committed || cur.id != turnId) {
      final active = cur == null
          ? 'none'
          : cur.committed
          ? 'committed'
          : '${cur.id}';
      _log('DROP stale fragment for turn $turnId (active=$active) raw="$raw"');
      return;
    }
    if (raw.trim().isEmpty) return;

    final cleaned = _stripStaleCommitted(_echo?.strip(raw) ?? raw);

    cur.text = cleaned;
    _log(
      'turn $turnId ingest raw="$raw" echoCleaned="${_echo != null && cleaned != raw ? cleaned : '-'}" '
      'buffer="${cur.text}"',
    );
  }

  /// Commits the active turn: returns exactly the text of THIS turn, marks
  /// it committed and arms the stale-final guard. The caller mints the next
  /// turn ([beginTurn]) right after.
  String commit() {
    final cur = _current;
    if (cur == null) {
      _committedText = '';
      _committedAt = _clock();
      return '';
    }
    final text = cur.text.trim();
    cur.committed = true;
    _committedText = text;
    _committedAt = _clock();
    _log('turn ${cur.id}: COMMIT text="$text"');
    _turnLog('turn ${cur.id} committed: "$text"');
    return text;
  }

  /// Drops the committed-turn prefix from [cleaned] when the fragment is a
  /// late re-emit of the previous turn inside the guard window. The
  /// engine-level guard (SpeechService) handles the native plugin's
  /// permanently-cumulative text; this one covers the remote engine's late
  /// final racing the commit.
  String _stripStaleCommitted(String cleaned) {
    final committedAt = _committedAt;
    if (_committedText.trim().isEmpty || committedAt == null) return cleaned;
    if (_clock().difference(committedAt) > staleFinalGuardWindow) {
      return cleaned;
    }
    return stripCommittedPrefix(cleaned, _committedText);
  }

  /// Removes [committed] (case/punctuation-insensitive) from the FRONT of
  /// [incoming] when [incoming] is exactly the committed turn or an
  /// extension of it — the late final of the previous utterance. Returns
  /// [incoming] unchanged when the text does not extend the committed
  /// turn's words (a fresh utterance must never be stripped).
  ///
  /// Shared by the tracker's own late-final guard and SpeechService's
  /// engine-level turn boundary — one matcher, one behavior.
  static String stripCommittedPrefix(String incoming, String committed) {
    if (committed.trim().isEmpty || incoming.isEmpty) return incoming;
    var i = 0;
    var j = 0;
    var matched = 0;
    while (i < incoming.length && j < committed.length) {
      final ci = _normChar(incoming[i]);
      if (ci == null) {
        i++;
        continue;
      }
      final cj = _normChar(committed[j]);
      if (cj == null) {
        j++;
        continue;
      }
      if (ci == cj) {
        i++;
        j++;
        matched++;
        continue;
      }
      // A genuine new utterance: keep everything.
      return incoming;
    }
    if (matched < 2) return incoming;
    if (j < committed.length && i >= incoming.length) {
      // incoming's normalized text is a strict prefix of committed: a stale
      // partial re-emit, not new speech.
      return '';
    }
    // The committed span consumed its own words; any punctuation glued to
    // the last matched word (", HOW ARE YOU!") belongs to the stale span,
    // not to the remainder.
    while (i < incoming.length && _normChar(incoming[i]) == null) {
      i++;
    }
    return incoming.substring(i).trim();
  }

  /// Lowercase alphanumeric (Turkish letters included); null for anything
  /// else (punctuation/whitespace is skipped on both sides).
  static String? _normChar(String ch) {
    final lower = ch.toLowerCase();
    if (lower.isEmpty) return null;
    final c = lower[0];
    final ok =
        (c.compareTo('a') >= 0 && c.compareTo('z') <= 0) ||
        (c.compareTo('0') >= 0 && c.compareTo('9') <= 0) ||
        c == 'ç' ||
        c == 'ğ' ||
        c == 'ı' ||
        c == 'ö' ||
        c == 'ş' ||
        c == 'ü';
    return ok ? c : null;
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[VoiceTurn] sess=${_sessionId ?? '—'} $message');
    }
  }

  void _turnLog(String message) {
    VoiceTelemetry.mark('user turn: $message');
  }
}
