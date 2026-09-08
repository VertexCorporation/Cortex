import 'package:cortex/chat/messages/markdown/patterns.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Markdown patterns', () {
    test('recognises case-insensitive think tags with attributes', () {
      final match = RegexPatterns.thinking
          .firstMatch('<THINK source="model">plan</THINK>Answer');

      expect(match?.group(0), '<THINK source="model">plan</THINK>');
    });

    test('keeps a balanced parenthesis in markdown link URLs', () {
      final match = RegexPatterns.link
          .firstMatch('[function](https://example.com/Function_(math))');

      expect(match?.group(1), 'function');
      expect(match?.group(2), 'https://example.com/Function_(math)');
    });

    test('does not consume sentence punctuation after a bare URL', () {
      final match =
          RegexPatterns.bareUrl.firstMatch('Read https://example.com/docs.');

      expect(match?.group(1), 'https://example.com/docs');
    });

    test('requires a single marker type for horizontal rules', () {
      expect(RegexPatterns.horizontalRule.hasMatch('---'), isTrue);
      expect(RegexPatterns.horizontalRule.hasMatch('*-*'), isFalse);
    });

    test('recognises underscore emphasis without matching identifiers', () {
      expect(RegexPatterns.italic.hasMatch('_emphasis_'), isTrue);
      expect(RegexPatterns.italic.hasMatch('snake_case_identifier'), isFalse);
    });

    test('combined inline expression remains compilable', () {
      expect(RegexPatterns.combinedInlinePattern.hasMatch('**bold**'), isTrue);
    });
  });
}
