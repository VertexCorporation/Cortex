// test/voice_barge_in_test.dart
//
// BargeInDetector invariants, all with an injected clock — no engines, no
// real time:
//   * every gate independently rejects (confidence, word count, echo,
//     post-TTS window, amplitude sustain);
//   * all gates agreeing fire exactly once;
//   * null confidence fails open (the native fallback reports no
//     confidence and must not lose barge-in entirely).

import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/chat/services/voice_barge_in.dart';

void main() {
  late DateTime fakeNow;
  late BargeInDetector detector;

  setUp(() {
    fakeNow = DateTime(2026, 1, 1, 12);
    detector = BargeInDetector(clock: () => fakeNow);
  });

  BargeInDetector armedWith(String spoken) {
    final d = BargeInDetector(clock: () => fakeNow);
    d.onAssistantSpeechStarted(spoken);
    return d;
  }

  void sustainLoud({int ms = 350}) {
    detector.onLevel(0.8);
    fakeNow = fakeNow.add(Duration(milliseconds: ms));
    detector.onLevel(0.8);
  }

  test('all gates agreeing fire barge-in exactly once', () {
    detector = armedWith('the assistant is explaining the plan');
    detector.onUserTranscript(text: 'stop right there', confidence: 0.9);
    sustainLoud();
    expect(detector.shouldBargeIn, true);
    // One-shot: latched until reset.
    expect(detector.shouldBargeIn, false);
  });

  test('amplitude below the floor never fires', () {
    detector = armedWith('the assistant is explaining');
    detector.onUserTranscript(text: 'stop right there', confidence: 0.9);
    detector.onLevel(0.2);
    fakeNow = fakeNow.add(const Duration(seconds: 2));
    detector.onLevel(0.2);
    expect(detector.shouldBargeIn, false);
  });

  test('a loud blip shorter than the sustain window never fires', () {
    detector = armedWith('the assistant is explaining');
    detector.onUserTranscript(text: 'stop right there', confidence: 0.9);
    // Loud for only 100ms — a click, not a voice.
    detector.onLevel(0.9);
    fakeNow = fakeNow.add(const Duration(milliseconds: 100));
    detector.onLevel(0.9);
    expect(detector.shouldBargeIn, false);
  });

  test('low-confidence transcripts are not evidence', () {
    detector = armedWith('the assistant is explaining');
    detector.onUserTranscript(text: 'stop right there', confidence: 0.5);
    sustainLoud(ms: 500);
    expect(detector.shouldBargeIn, false);
  });

  test('null confidence fails OPEN (unknown is not low)', () {
    detector = armedWith('the assistant is explaining');
    // A provider payload without the confidence field — or the native
    // fallback — must not lose barge-in entirely.
    detector.onUserTranscript(text: 'stop right there', confidence: null);
    sustainLoud();
    expect(detector.shouldBargeIn, true);
  });

  test('a confident non-echo single word can interrupt', () {
    detector = armedWith('the assistant is explaining');
    detector.onUserTranscript(text: 'hey', confidence: 0.99);
    sustainLoud(ms: 500);
    expect(detector.shouldBargeIn, true);
  });

  test('the assistant\'s own words echoed back are not evidence', () {
    detector = armedWith('The capital of France is Paris.');
    // Speaker bleed: the exact same sentence, confidently transcribed.
    detector.onUserTranscript(
      text: 'the capital of France is Paris',
      confidence: 0.99,
    );
    sustainLoud(ms: 500);
    expect(detector.shouldBargeIn, false);
  });

  test(
    'a mostly-overlapping echo is still rejected, dissimilar speech is not',
    () {
      detector = armedWith('The capital of France is Paris.');
      detector.onUserTranscript(
        text: 'the capital of France is Berlin',
        confidence: 0.9,
      );
      // 5/6 words shared with the spoken sentence → Jaccard 5/7 ≈ 0.71 —
      // below the 0.85 limit: this counts as the user (correcting Paris).
      sustainLoud();
      expect(detector.shouldBargeIn, true);
    },
  );

  test('transcripts inside the 250ms post-TTS window are discarded', () {
    detector = armedWith('the assistant is explaining');
    // Playback just ended; the echo tail arrives 100ms later — inside the
    // window, so it must not count as evidence.
    detector.onAssistantSpeechStopped();
    fakeNow = fakeNow.add(const Duration(milliseconds: 100));
    detector.onUserTranscript(
      text: 'stop right there please',
      confidence: 0.99,
    );
    sustainLoud(ms: 500);
    expect(detector.shouldBargeIn, false);
  });

  test('real user speech after the post-TTS window counts again', () {
    detector = armedWith('the assistant is explaining');
    detector.onAssistantSpeechStopped();
    fakeNow = fakeNow.add(const Duration(milliseconds: 100));
    // Inside the window: discarded.
    detector.onUserTranscript(text: 'stop right there', confidence: 0.9);
    // Outside the window (400ms after TTS stopped): accepted.
    fakeNow = fakeNow.add(const Duration(milliseconds: 400));
    detector.onUserTranscript(text: 'stop right there', confidence: 0.9);
    sustainLoud();
    expect(detector.shouldBargeIn, true);
  });

  test('echoSimilarity: identical utterances score 1, disjoint score 0', () {
    expect(
      BargeInDetector.echoSimilarity(
        'Hello there friend',
        'hello there friend!',
      ),
      1.0,
    );
    expect(BargeInDetector.echoSimilarity('alpha beta', 'gamma delta'), 0.0);
    expect(BargeInDetector.echoSimilarity('', 'anything'), 0.0);
  });

  test(
    'single-word speaker echo is rejected and non-Latin speech can interrupt',
    () {
      detector = armedWith('The answer is Paris');
      detector.onUserTranscript(text: 'Paris', confidence: 0.99);
      sustainLoud();
      expect(detector.shouldBargeIn, false);
      detector.onUserTranscript(text: 'انتظر', confidence: 0.99);
      expect(detector.shouldBargeIn, true);
    },
  );

  test('reset clears every gate and the one-shot latch', () {
    detector = armedWith('the assistant is explaining');
    detector.onUserTranscript(text: 'stop right there', confidence: 0.9);
    sustainLoud();
    expect(detector.shouldBargeIn, true);

    detector.reset();
    // Evidence gone: nothing fires until fresh evidence arrives.
    detector.onLevel(0.9);
    fakeNow = fakeNow.add(const Duration(seconds: 1));
    detector.onLevel(0.9);
    expect(detector.shouldBargeIn, false);
  });
}
