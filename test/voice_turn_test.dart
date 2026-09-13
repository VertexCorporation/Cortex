// test/voice_turn_test.dart
//
// PER-TURN TRANSCRIPT LIFECYCLE invariants — the growing-user-input bug:
//
//   Turn 1 spoken: "hello"        → outgoing "hello"
//   Turn 2 spoken: "how are you?" → outgoing "how are you?"  (NOT
//                                   "hello how are you?")
//
// The conversation still contains both messages through the chat history;
// the voice accumulator must never carry a committed turn's words into the
// next one. Everything is pure/injected — no engines.

import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/chat/services/voice_echo.dart';
import 'package:cortex/chat/services/voice_turns.dart';

void main() {
  late DateTime fakeNow;
  late AssistantEchoFilter echo;
  late VoiceTurnTracker turns;

  setUp(() {
    fakeNow = DateTime(2026, 9, 13, 12);
    echo = AssistantEchoFilter(clock: () => fakeNow);
    turns = VoiceTurnTracker(clock: () => fakeNow, echoFilter: echo);
  });

  test('the acceptance example: two turns, no growth', () {
    turns.beginSession(1);
    final t1 = turns.currentTurnId!;

    turns.ingest(turnId: t1, raw: 'hello');
    turns.ingest(turnId: t1, raw: 'Hello.');
    expect(turns.commit(), 'Hello.');

    turns.beginTurn();
    final t2 = turns.currentTurnId!;
    // The engine emission for turn 2 arrives CUMULATIVE (the capture
    // outlives the turn) — the tracker must keep only the new turn's words.
    turns.ingest(turnId: t2, raw: 'Hello. how are you');
    turns.ingest(turnId: t2, raw: 'Hello. how are you?');
    expect(turns.commit(), 'how are you?');
  });

  test('late final of the committed utterance never seeds the next turn', () {
    turns.beginSession(1);
    final t1 = turns.currentTurnId!;
    turns.ingest(turnId: t1, raw: 'hello');
    expect(turns.commit(), 'hello');

    turns.beginTurn();
    final t2 = turns.currentTurnId!;
    // The provider's final for turn 1's utterance lands just after commit.
    turns.ingest(turnId: t2, raw: 'hello');
    expect(turns.buffer, '', reason: 'stale re-emit must not seed turn 2');

    // Fresh speech after the stale frame accumulates normally.
    turns.ingest(turnId: t2, raw: 'hello what is the time');
    expect(turns.buffer, 'what is the time');
    expect(turns.commit(), 'what is the time');
  });

  test('stale callbacks for an old turn id are dropped', () {
    turns.beginSession(1);
    final t1 = turns.currentTurnId!;
    turns.ingest(turnId: t1, raw: 'hello');
    turns.commit();
    turns.beginTurn();
    final t2 = turns.currentTurnId!;

    // A straggler callback still carrying turn 1's identity.
    turns.ingest(turnId: t1, raw: 'how are you');
    expect(turns.buffer, '');

    turns.ingest(turnId: t2, raw: 'how are you');
    expect(turns.commit(), 'how are you');
  });

  test(
    'fragments accumulate within the active turn only (multi-utterance)',
    () {
      turns.beginSession(7);
      final t = turns.currentTurnId!;
      turns.ingest(turnId: t, raw: 'the first part');
      // A 1.2s pause mid-turn: the provider emits a new utterance final that
      // the engine appends — still the SAME turn (no silence commit yet).
      fakeNow = fakeNow.add(const Duration(milliseconds: 1200));
      turns.ingest(turnId: t, raw: 'the first part and the second part');
      expect(turns.buffer, 'the first part and the second part');
    },
  );

  test('reconnects within the same unfinished turn preserve its text', () {
    turns.beginSession(3);
    final t = turns.currentTurnId!;
    turns.ingest(turnId: t, raw: 'so I was saying');
    // A socket reconnect: the turn identity is untouched, so the buffer
    // survives and the next fragment extends it.
    turns.ingest(turnId: t, raw: 'so I was saying we should go tomorrow');
    expect(turns.buffer, 'so I was saying we should go tomorrow');
    expect(turns.commit(), 'so I was saying we should go tomorrow');
  });

  test('a new session can never inherit a previous session\'s turns', () {
    turns.beginSession(1);
    turns.ingest(turnId: turns.currentTurnId!, raw: 'hello');
    turns.commit();

    turns.beginSession(2);
    final fresh = turns.currentTurnId!;
    expect(turns.buffer, '');
    turns.ingest(turnId: fresh, raw: 'new topic');
    expect(turns.commit(), 'new topic');
  });

  test('barge-in mixed with echo keeps only the user\'s spoken words', () {
    echo.onAssistantSpeechStarted(
      'Got it. First impression: tactics focus on grabbing attention.',
    );
    turns.beginSession(9);
    final t1 = turns.currentTurnId!;
    turns.ingest(turnId: t1, raw: 'hello');
    turns.commit();

    // Barge-in: a NEW turn begins while the assistant was still speaking.
    turns.beginTurn();
    final t2 = turns.currentTurnId!;
    expect(t2, isNot(t1));
    // The engine's cumulative text still contains the echo finals picked up
    // during playback plus the user's barge-in words.
    turns.ingest(
      turnId: t2,
      raw:
          'Got it first impression tactics focus on grabbing attention '
          'actually tell me the third one',
    );
    expect(turns.buffer, 'actually tell me the third one');
    expect(turns.commit(), 'actually tell me the third one');
  });

  test('empty live turn is reused at repeated beginTurn boundaries', () {
    turns.beginSession(4);
    final first = turns.currentTurnId!;
    turns.beginTurn(); // e.g. resume-after-turn with nothing spoken
    expect(turns.currentTurnId, first);
    turns.beginTurn(); // barge-in with nothing spoken either
    expect(turns.currentTurnId, first);
    turns.ingest(turnId: first, raw: 'words');
    turns.beginTurn(); // a turn WITH text is never reused
    expect(turns.currentTurnId, isNot(first));
  });

  test('stale-final guard is time-bound: later identical speech survives', () {
    turns.beginSession(5);
    final t1 = turns.currentTurnId!;
    turns.ingest(turnId: t1, raw: 'hello');
    turns.commit();
    turns.beginTurn();
    final t2 = turns.currentTurnId!;

    // Far beyond the guard window, a genuine new utterance that happens to
    // repeat the committed words is real speech and must survive.
    fakeNow = fakeNow.add(const Duration(seconds: 10));
    turns.ingest(turnId: t2, raw: 'hello');
    expect(turns.buffer, 'hello');
  });

  test(
    'stripCommittedPrefix: exact, extended, mismatched and partial inputs',
    () {
      expect(VoiceTurnTracker.stripCommittedPrefix('Hello.', 'Hello.'), '');
      expect(
        VoiceTurnTracker.stripCommittedPrefix('Hello. how are you?', 'Hello.'),
        'how are you?',
      );
      expect(
        VoiceTurnTracker.stripCommittedPrefix('How are you?', 'Hello.'),
        'How are you?',
        reason: 'fresh speech is never stripped',
      );
      expect(
        VoiceTurnTracker.stripCommittedPrefix(
          'hello, HOW ARE YOU!',
          'hello how are you',
        ),
        '',
      );
      expect(VoiceTurnTracker.stripCommittedPrefix('', 'hello'), '');
      expect(VoiceTurnTracker.stripCommittedPrefix('words', ''), 'words');
    },
  );

  test('commit with no live turn yields empty text and stays safe', () {
    turns.beginSession(1);
    expect(turns.commit(), '');
  });
}
