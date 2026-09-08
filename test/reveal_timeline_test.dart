import 'package:cortex/chat/messages/tiles/ai/reveal_timeline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  late RevealTimeline reveal;
  setUp(() => reveal = RevealTimeline());
  tearDown(() => reveal.dispose());
  void frame([int milliseconds = 16]) =>
      reveal.advance(Duration(milliseconds: milliseconds));

  test('reveals first token while the network is still open and resumes after gaps', () {
    reveal.reset('', complete: false);
    reveal.accept('H', complete: false);
    frame();
    expect(reveal.visibleText, 'H');
    expect(reveal.networkComplete, false);
    frame(100);
    frame(100);
    frame(100);
    expect(reveal.needsFrames, false);
    reveal.accept('Hello', complete: false);
    expect(reveal.needsFrames, true);
    frame();
    expect(reveal.visibleText, 'He');
    expect(reveal.visualComplete, false);
  });

  test('matches reference frame cadence and pressure thresholds', () {
    for (final length in [10, 23, 49, 91]) {
      reveal.reset('a' * length, complete: false);
      frame();
      expect(reveal.revealedLength, length > 48 ? 2 : 1);
      frame();
      expect(reveal.revealedLength, greaterThan(length > 48 ? 2 : 1));
      expect(reveal.isSettled, false); // characters overlap for 280ms
    }
  });

  test('network completion waits for queue AND final fade', () {
    reveal.accept('Merhaba dünya', complete: true);
    expect(reveal.visualComplete, false);
    while (reveal.pendingLength > 0) {
      frame();
    }
    expect(reveal.visualComplete, false);
    frame(100);
    frame(100);
    frame(79);
    expect(reveal.visualComplete, false);
    frame(1);
    expect(reveal.visualComplete, true);
    expect(reveal.needsFrames, false);
  });

  test(
      'network end after an idle drained stream completes without another tick',
      () {
    reveal.accept('a', complete: false);
    frame();
    frame(100);
    frame(100);
    frame(80);
    expect(reveal.visualComplete, false);
    reveal.accept('a', complete: true);
    expect(reveal.visualComplete, true);
  });

  test('trim at EOF preserves pending text rather than flushing it', () {
    reveal.accept('Hello world  ', complete: false);
    frame();
    reveal.accept('Hello world', complete: true);
    expect(reveal.visibleText, 'H');
    expect(reveal.pendingLength, 10);
    expect(reveal.visualComplete, false);
  });

  test('whitespace and Unicode survive fragmented network updates', () {
    const source = 'İyi  günler\n👨‍👩‍👧‍👦 e\u0301 🇹🇷';
    var input = '';
    for (final unit in source.codeUnits) {
      input += String.fromCharCode(unit);
      reveal.accept(input, complete: false);
      frame();
    }
    reveal.accept(source, complete: true);
    while (reveal.needsFrames) {
      frame();
    }
    expect(reveal.visibleText, source);
    expect(reveal.visualComplete, true);
    reveal.reset(source, complete: true);
    while (reveal.pendingLength > 0) {
      frame();
      expect(
          source.characters
              .take(reveal.visibleText.characters.length)
              .toString(),
          reveal.visibleText);
    }
  });

  test('flush does not finish a still-open source or erase historical text',
      () {
    reveal.reset('saved', complete: true, showImmediately: true);
    reveal.flush();
    expect(reveal.visibleText, 'saved');
    reveal.reset('stream', complete: false);
    reveal.flush();
    expect(reveal.visualComplete, false);
    reveal.accept('stream next', complete: false);
    expect(reveal.pendingLength, 5);
    frame();
    expect(reveal.visibleText, 'stream ');
  });

  test('restart discards old work and a background gap cannot flush a burst',
      () {
    reveal.accept('a' * 1000, complete: true);
    reveal.advance(const Duration(seconds: 10));
    expect(reveal.revealedLength, greaterThan(0));
    expect(reveal.revealedLength, lessThan(1000));
    final generation = reveal.generation;
    reveal.reset('new', complete: false);
    expect(reveal.generation, generation + 1);
    expect(reveal.visibleText, isEmpty);
    frame();
    expect(reveal.visibleText, 'n');
  });

  test('large bursts finish near one second without shortening glyph fades', () {
    reveal.reset('hello ' * 100, complete: true);
    var elapsed = 0;
    while (reveal.pendingLength > 0) {
      frame();
      elapsed += 16;
      expect(reveal.visualComplete, false);
      expect(elapsed, lessThan(800));
    }
    frame(100);
    frame(100);
    frame(79);
    expect(reveal.visualComplete, false);
    frame(1);
    expect(reveal.visualComplete, true);
    expect(elapsed + 280, lessThanOrEqualTo(1100));
    reveal.accept('${reveal.sourceText}new', complete: false);
    frame();
    expect(reveal.pendingLength, 2);
  });
}
