import 'package:cortex/chat/services/reasoning_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retains ordinary answers and literal code tags exactly', () {
    for (final text in ['Hello', '2 + 2 = 4',
      '`<think>literal</think>`', '```xml\n<think>literal</think>\n```',
      '~~~xml\n<think>literal</think>\n~~~', r'\<think>literal',
      'an unmatched </think> tag']) {
      final parsed = ReasoningText.parse(text);
      expect(parsed.answer, text, reason: text);
      expect(parsed.hasReasoning, isFalse);
    }
  });

  test('separates every thinking block and keeps all answer segments', () {
    final parsed = ReasoningText.parse(
        'Before<think>First</think>Between<THINK>Second</THINK>After');
    expect(parsed.reasoning, 'First\n\nSecond');
    expect(parsed.answer, 'BeforeBetweenAfter');
    expect(parsed.isReasoningOpen, isFalse);
  });

  test('unfinished and nested thinking are not treated as final answers', () {
    final parsed = ReasoningText.parse('<think>First<think>Second</think>');
    expect(parsed.answer, isEmpty);
    expect(parsed.reasoning, 'FirstSecond');
    expect(parsed.isReasoningOpen, isTrue);
  });

  test('completion repair closes every open block and an unfinished code span', () {
    for (final text in ['<think>one<think>two', '<think>```python\nx = 1']) {
      final parsed = ReasoningText.parse(text);
      final repaired = ReasoningText.parse('${text}${parsed.closingMarkup}Status');
      expect(repaired.isReasoningOpen, isFalse);
      expect(repaired.answer, 'Status');
    }
  });

  test('reasoning length does not consume the answer animation', () {
    const raw = '<think>Many reasoning words here</think>Final answer';
    final parsed = ReasoningText.parse(raw);
    final answerStart = raw.indexOf('Final');
    expect(parsed.answerLengthBefore(answerStart), 0);
    expect(parsed.answerLengthBefore(answerStart + 3), 3);
    expect(parsed.answerLengthBefore(raw.length), 'Final answer'.length);
  });

  test('every partial opening/closing tag waits for the next stream chunk', () {
    for (var i = 1; i < '<think>'.length; i++) {
      final prefix = 'Answer${'<think>'.substring(0, i)}';
      expect(ReasoningText.parse(prefix, isFinished: false).answer, 'Answer');
    }
    for (var i = 1; i < '</think>'.length; i++) {
      final prefix = '<think>Working${'</think>'.substring(0, i)}';
      final parsed = ReasoningText.parse(prefix, isFinished: false);
      expect(parsed.answer, isEmpty);
      expect(parsed.reasoning, 'Working');
    }
    expect(ReasoningText.parse('Use <thi', isFinished: true).answer, 'Use <thi');
  });
}
