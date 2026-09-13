// test/voice_echo_test.dart
//
// AssistantEchoFilter invariants — the transcript-path echo gate:
//   * pure echo (whole sentence or clipped tail) never survives;
//   * pure user speech is never touched, inside or outside the window;
//   * echo + user suffix / user prefix + echo keep the user words;
//   * a user correcting the assistant's wording survives;
//   * short quoted assistant text outside the window is preserved
//     (conservative), whole-sentence verbatim repeats still strip;
//   * barge-in's mixed echo + user speech keeps only the user's words.
//
// All with an injected clock — no engines, no real time.

import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/chat/services/voice_echo.dart';

void main() {
  late DateTime fakeNow;
  late AssistantEchoFilter filter;

  setUp(() {
    fakeNow = DateTime(2026, 9, 13, 12);
    filter = AssistantEchoFilter(clock: () => fakeNow);
  });

  void playing(String sentence) {
    filter.onAssistantSpeechStarted(sentence);
  }

  void playbackStopped() {
    filter.onAssistantSpeechStopped();
  }

  const assistantSentence =
      'Got it. First impression: tactics focus on grabbing attention.';

  test('pure echo during playback is stripped entirely', () {
    playing(assistantSentence);
    expect(
      filter.strip(
        'Got it first impression tactics focus on grabbing attention',
      ),
      '',
    );
  });

  test(
    'pure echo right after playback stops is still stripped (strong window)',
    () {
      playing(assistantSentence);
      playbackStopped();
      expect(
        filter.strip(
          'Got it first impression tactics focus on grabbing attention',
        ),
        '',
      );
    },
  );

  test('short pure-echo tail right after playback is stripped', () {
    playing(assistantSentence);
    playbackStopped();
    expect(filter.strip('grabbing attention'), '');
    expect(filter.strip('tactics focus'), '');
  });

  test('pure user speech is never touched, even during playback', () {
    playing(assistantSentence);
    const user = 'Could you explain the second point in more detail please';
    expect(filter.strip(user), user);
  });

  test('echo + user suffix keeps only the user words (the spec example)', () {
    playing(assistantSentence);
    final result = filter.strip(
      'Got it first impression tactics focus on grabbing attention '
      'actually tell me the third one',
    );
    expect(result, 'actually tell me the third one');
  });

  test('user prefix + echo keeps only the user words', () {
    playing(assistantSentence);
    final result = filter.strip(
      'Wait wait got it first impression tactics focus on grabbing attention',
    );
    expect(result, 'Wait wait');
  });

  test('user correcting the assistant wording survives the strong window', () {
    playing(assistantSentence);
    final result = filter.strip(
      'No, focus on grabbing the reader\'s attention instead',
    );
    // The correction reuses assistant vocabulary but is NOT a verbatim echo
    // span; the bridging rule must not swallow it.
    expect(result, 'No, focus on grabbing the reader\'s attention instead');
  });

  test('short quoted assistant text outside the window is preserved', () {
    playing(assistantSentence);
    playbackStopped();
    fakeNow = fakeNow.add(const Duration(seconds: 5)); // outside strong window
    final result = filter.strip('You said tactics focus on grabbing, right?');
    // Conservative mode: a 4-word overlap is below the verbatim floor.
    expect(result, 'You said tactics focus on grabbing, right?');
  });

  test('whole-sentence verbatim repeat outside the window still strips', () {
    playing(assistantSentence);
    playbackStopped();
    fakeNow = fakeNow.add(const Duration(seconds: 5));
    expect(
      filter.strip(
        'Got it first impression tactics focus on grabbing attention',
      ),
      '',
    );
  });

  test('unrelated user speech outside the window is untouched', () {
    playing(assistantSentence);
    playbackStopped();
    fakeNow = fakeNow.add(const Duration(seconds: 5));
    const user = 'How about we move on to the next topic now';
    expect(filter.strip(user), user);
  });

  test('echo from the previous sentence still strips while the next plays', () {
    playing(assistantSentence);
    playbackStopped();
    filter.onAssistantSpeechStarted('Now let us look at three more options.');
    // The older sentence is still within the fingerprint depth.
    expect(
      filter.strip(
        'Got it first impression tactics focus on grabbing attention',
      ),
      '',
    );
  });

  test('multiple echo spans in one transcript all strip', () {
    playing(assistantSentence);
    final result = filter.strip(
      'Got it first impression tactics focus on grabbing attention '
      'and also tactics focus on grabbing attention again',
    );
    expect(result, 'and also again');
  });

  test('empty filter (no fingerprints) never strips anything', () {
    const user = 'Got it first impression tactics focus on grabbing attention';
    expect(filter.strip(user), user);
  });

  test('strong window closes after the post-TTS duration', () {
    playing(assistantSentence);
    playbackStopped();
    fakeNow = fakeNow.add(AssistantEchoFilter.strongWindowAfterStop);
    // Outside the window the span rule is conservative; the clipped tail
    // (below the conservative floor) is preserved.
    expect(filter.strip('tactics focus'), 'tactics focus');
  });

  test('echo with dropped words (STT clipped mid-echo) still strips', () {
    playing(assistantSentence);
    // The recognizer dropped "first impression" and "on" from the echo.
    expect(
      filter.strip('Got it tactics focus grabbing attention'),
      '',
      reason: 'whole-transcript containment of a degraded echo',
    );
  });

  test('user speech after a degraded echo span survives', () {
    playing(assistantSentence);
    final result = filter.strip(
      'Got it tactics focus grabbing attention now tell me the second one',
    );
    expect(result, 'now tell me the second one');
  });
}
