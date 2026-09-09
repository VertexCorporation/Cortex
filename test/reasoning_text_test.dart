import 'package:cortex/chat/messages/messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReasoningText', () {
    test('splits a normal reasoning block from the final answer', () {
      final parsed = ReasoningText.parse(
        '<think>check constraints</think>Final answer',
      );

      expect(parsed.reasoning, 'check constraints');
      expect(parsed.answer, 'Final answer');
      expect(parsed.hasReasoning, isTrue);
      expect(parsed.isReasoningOpen, isFalse);
    });

    test('combines multiple reasoning blocks without losing answer text', () {
      final parsed = ReasoningText.parse(
        'A<think>one</think>B<think>two</think>C',
      );

      expect(parsed.answer, 'ABC');
      expect(parsed.reasoning, 'one\n\ntwo');
    });

    test('supports attributes, nesting and completion repair', () {
      final parsed = ReasoningText.parse(
        '<think data-provider="local">outer<think>inner',
      );

      expect(parsed.reasoning, 'outerinner');
      expect(parsed.answer, isEmpty);
      expect(parsed.isReasoningOpen, isTrue);
      expect(parsed.closingMarkup, '</think></think>');
    });

    test('keeps literal think tags inside markdown code', () {
      final inline = ReasoningText.parse('Use `<think>` literally.');
      final fenced = ReasoningText.parse(
        '```html\n<think>literal</think>\n```\nDone',
      );

      expect(inline.hasReasoning, isFalse);
      expect(inline.answer, 'Use `<think>` literally.');
      expect(fenced.hasReasoning, isFalse);
      expect(fenced.answer, contains('<think>literal</think>'));
      expect(fenced.answer, endsWith('Done'));
    });

    test('keeps escaped tags literal', () {
      final parsed = ReasoningText.parse(r'\<think>literal\</think>');

      expect(parsed.hasReasoning, isFalse);
      expect(parsed.answer, r'\<think>literal\</think>');
    });

    test('hides partial opening and closing markers while streaming', () {
      for (final value in ['<', '<t', '<thi', '<think']) {
        final parsed = ReasoningText.parse(value, isFinished: false);
        expect(parsed.answer, isEmpty, reason: value);
      }

      final open = ReasoningText.parse(
        '<think>working</thi',
        isFinished: false,
      );
      expect(open.reasoning, 'working');
      expect(open.answer, isEmpty);
    });

    test('does not swallow an unmatched closing tag', () {
      final parsed = ReasoningText.parse('answer </think> stays visible');

      expect(parsed.hasReasoning, isFalse);
      expect(parsed.answer, 'answer </think> stays visible');
    });
  });

  group('ReasoningGuidance', () {
    test('requires a final answer without inventing provider controls', () {
      final guidance = ReasoningGuidance.forLanguage('en');

      expect(guidance, contains('complete, direct answer'));
      expect(guidance, isNot(contains('reasoning_effort')));
      expect(guidance, isNot(contains('reasoning_tokens')));
    });
  });
}
