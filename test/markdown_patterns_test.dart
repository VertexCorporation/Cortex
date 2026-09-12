import 'package:cortex/chat/messages/markdown/patterns.dart';
import 'package:cortex/chat/messages/markdown/streaming.dart';
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

  group(r'TeX math delimiters \(...\) and \[...\]', () {
    test('matches \\(...\\) inline math and captures the body', () {
      final match =
          RegexPatterns.inlineMathParen.firstMatch(r'Euler: \(e^{i\pi}+1=0\)');
      expect(match, isNotNull);
      expect(match!.group(1), r'e^{i\pi}+1=0');
    });

    test('requires the closing \\) while a response is still streaming', () {
      expect(RegexPatterns.inlineMathParen.hasMatch(r'partial: \(x + \frac{1}{2}'),
          isFalse);
      expect(
          RegexPatterns.inlineMathParen.hasMatch(r'done: \(x + \frac{1}{2}\)'),
          isTrue);
    });

    test('keeps \\(...\\) on one line and non-empty', () {
      expect(RegexPatterns.inlineMathParen.hasMatch('\\(multi\nline\\)'),
          isFalse);
      expect(RegexPatterns.inlineMathParen.hasMatch(r'\(\)'), isFalse);
    });

    test('never opens a span at an escaped \\\\( or with a backtick body', () {
      expect(
          RegexPatterns.inlineMathParen.hasMatch(r'literal \\(x\\) stays'),
          isFalse);
      expect(RegexPatterns.inlineMathParen.hasMatch(r'\(a`b\)'), isFalse);
    });

    test('code spans keep priority over \\(...\\) in the combined scan', () {
      final match = RegexPatterns.combinedInlinePattern
          .firstMatch(r'`\(\sqrt{2}\)` stays literal');
      expect(match, isNotNull);
      expect(match!.namedGroup('inlineCode'), isNotNull);
      expect(match.namedGroup('inlineMathParen'), isNull);
    });

    test('matches \\[...\\] display blocks anchored to line ends', () {
      final match =
          RegexPatterns.displayMathBracket.firstMatch('\\[\nE = mc^2\n\\]');
      expect(match, isNotNull);
      expect(match!.group(1), '\nE = mc^2\n');
    });

    test('requires the closing \\] while a response is still streaming', () {
      expect(
          RegexPatterns.displayMathBracket
              .hasMatch('partial:\n\\[\n\\frac{n(n+'),
          isFalse);
      expect(
          RegexPatterns.displayMathBracket
              .hasMatch('done:\n\\[\n\\frac{n(n+1)(2n+1)}{6}\n\\]'),
          isTrue);
    });

    test('requires \\[ at a line start and \\] at a line end', () {
      expect(RegexPatterns.displayMathBracket.hasMatch(r'mid \[x\] line'),
          isFalse);
      expect(
          RegexPatterns.displayMathBracket.hasMatch(r'\[x\] trailing text'),
          isFalse);
      expect(RegexPatterns.displayMathBracket.hasMatch('  \\[x\\]'), isTrue);
      expect(RegexPatterns.displayMathBracket.hasMatch(r'> \[x\]'), isFalse);
    });

    test('matches consecutive display blocks independently', () {
      expect(RegexPatterns.displayMathBracket.allMatches('\\[a\\]\n\n\\[b\\]'),
          hasLength(2));
    });

    test('keeps bullet-like lines inside the equation body', () {
      final matches = RegexPatterns.displayMathBracket
          .allMatches('\\[\n- x + y = 0\n\\]')
          .toList();
      expect(matches, hasLength(1));
      expect(matches.first.group(1), '\n- x + y = 0\n');
    });
  });

  group('streaming delimiter completion (provisional layer)', () {
    test('completes a dangling bold at the paragraph end', () {
      expect(closeStreamingDelimiters('Stream: **bold tex'),
          'Stream: **bold tex**');
    });

    test('never completes a dangling bold across the blank line', () {
      const text = 'A **bold\n\nunrelated prose';
      expect(
          closeStreamingDelimiters(text), 'A **bold**\n\nunrelated prose');
    });

    test('completes dangling italic, strikethrough and bold-italic', () {
      expect(closeStreamingDelimiters('B *ital'), 'B *ital*');
      expect(closeStreamingDelimiters('U _under'), 'U _under_');
      expect(closeStreamingDelimiters('S ~~gone'), 'S ~~gone~~');
      expect(closeStreamingDelimiters('***big'), '***big***');
    });

    test('completes a dangling inline code span at the line end', () {
      expect(closeStreamingDelimiters('run `flutt'), 'run `flutt`');
    });

    test('completes a dangling link, but never a prose paren', () {
      expect(closeStreamingDelimiters('see [docs](https://ex'),
          'see [docs](https://ex)');
      const prose = 'note [a](see chapter 3';
      expect(closeStreamingDelimiters(prose), prose);
    });

    test('completes a dangling \$\$ display block before the blank line', () {
      const text = 'Eq:\n\$\$x = 1\n\nProse after';
      expect(
          closeStreamingDelimiters(text), 'Eq:\n\$\$x = 1\$\$\n\nProse after');
    });

    test('completes a dangling \\[ display block before the blank line', () {
      const text = 'Math:\n\\[\nx = y\n\nunrelated prose';
      expect(closeStreamingDelimiters(text),
          'Math:\n\\[\nx = y\\]\n\nunrelated prose');
    });

    test('keeps \\[x\\] trailing text literal (closer already spent)', () {
      const text = '\\[x\\] trailing text';
      expect(closeStreamingDelimiters(text), text);
    });

    test('keeps mid-line \\[ untouched (block opener needs a line start)',
        () {
      const text = 'note \\[a and more';
      expect(closeStreamingDelimiters(text), text);
    });

    test('bounds a dangling \\( at the first line end', () {
      const text = 'Part: \\(x + y\nnext line';
      expect(closeStreamingDelimiters(text),
          'Part: \\(x + y\\)\nnext line');
    });

    test('closes only the second of two \\( openers on one line', () {
      expect(closeStreamingDelimiters(r'a \(b\) c \(d'), r'a \(b\) c \(d\)');
    });

    test(r'never treats an escaped \\( as an opener', () {
      const text = r'literal \\(escaped';
      expect(closeStreamingDelimiters(text), text);
    });

    test('completes an open code fence and claims its content', () {
      expect(closeStreamingDelimiters('```dart\nprint(1);'),
          '```dart\nprint(1);\n```');
      // Delimiters inside the streaming code body are code, not markdown:
      expect(closeStreamingDelimiters('```dart\n**not bold \\(x'),
          '```dart\n**not bold \\(x\n```');
      // A bare opener with no body yet stays literal until content arrives.
      const bare = 'text\n```';
      expect(closeStreamingDelimiters(bare), bare);
    });

    test('nests naturally: math inside dangling bold closes first', () {
      expect(closeStreamingDelimiters('**bold and \\(math'),
          '**bold and \\(math\\)**');
      // Inside a math claim nothing else completes: math owns its body.
      expect(closeStreamingDelimiters('\\(math and **bold'),
          '\\(math and **bold\\)');
    });

    test('a dangling code span wins over later delimiters on its line', () {
      // (Invisible trailing spaces are trimmed before the closer is added.)
      expect(closeStreamingDelimiters('Run `\\(x + '), 'Run `\\(x +`');
      // A math opener whose body would contain a backtick is refused by the
      // finalized rule; the guard falls back to the code span instead.
      expect(closeStreamingDelimiters('\\(x and `fo'), '\\(x and `fo`');
    });

    test('never touches currency prose (single \$ has no provisional layer)',
        () {
      const text = 'It costs \$5 or \$10.';
      expect(closeStreamingDelimiters(text), text);
    });

    test('completed constructs are byte-identical no-ops', () {
      const text =
          '**b** *i* __u__ ~~s~~ `c` [l](u) \\(m\\) mid \\[q\\] and \$\$x\$\$ end';
      expect(closeStreamingDelimiters(text), text);
    });

    test('completes two constructs at different paragraphs at once', () {
      const text = '\\[\nx\n\nprose **bold';
      expect(closeStreamingDelimiters(text),
          '\\[\nx\\]\n\nprose **bold**');
    });

    test('marker-only input stays exactly as the finalized parser sees it',
        () {
      expect(closeStreamingDelimiters('****'), '****');
      expect(closeStreamingDelimiters('***'), '***');
      expect(closeStreamingDelimiters('**'), '**');
      expect(closeStreamingDelimiters('*'), '*');
      expect(closeStreamingDelimiters('~~'), '~~');
      expect(closeStreamingDelimiters('\$\$\$\$'), '\$\$\$\$');
      expect(closeStreamingDelimiters('*-*'), '*-*');
      expect(closeStreamingDelimiters(r'\('), r'\(');
    });

    test('is idempotent: completing twice changes nothing further', () {
      const text = '**a\n\nb \\(c';
      final once = closeStreamingDelimiters(text);
      expect(once, '**a**\n\nb \\(c\\)');
      expect(closeStreamingDelimiters(once), once);
    });

    group('provisional streaming tables: synthesis', () {
      test('first streamed table row renders through the table pipeline',
          () {
        expect(closeStreamingDelimiters('| Model | Context'),
            '| Model | Context|\n|---|---|\n');
        expect(closeStreamingDelimiters('| Model | Context |'),
            '| Model | Context |\n|---|---|\n');
      });

      test('column count grows as cells stream in', () {
        expect(closeStreamingDelimiters('| A | B'), '| A | B|\n|---|---|\n');
        expect(closeStreamingDelimiters('| A | B | C'),
            '| A | B | C|\n|---|---|---|\n');
      });

      test('a single-cell row is not "clearly a table" yet', () {
        const partial = '| Model';
        expect(closeStreamingDelimiters(partial), same(partial));
        const oneCell = '| Model |';
        expect(closeStreamingDelimiters(oneCell), same(oneCell));
      });

      test('incomplete row shapes never crash and never synthesize', () {
        for (final t in ['|', '| ', '| |', '|x|', '| Foo |']) {
          expect(closeStreamingDelimiters(t), same(t));
        }
      });

      test('multiple rows stream before any separator exists', () {
        expect(closeStreamingDelimiters('| A | B |\n| 1 | 2 |\n| 3'),
            '| A | B |\n|---|---|\n| 1 | 2 |\n| 3|');
      });

      test('a live table absorbs the row still being typed', () {
        expect(closeStreamingDelimiters('| A | B |\n|---|\n| 1'),
            '| A | B |\n|---|\n| 1|');
        expect(closeStreamingDelimiters('| A | B |\n|---|\n| 1 | 2 |\n| 3'),
            '| A | B |\n|---|\n| 1 | 2 |\n| 3|');
      });

      test('escaped pipes are content, not column delimiters', () {
        expect(closeStreamingDelimiters(r'| A \| B | C'),
            r'| A \| B | C|' '\n' r'|---|---|' '\n');
      });

      test('a trailing lone backslash never becomes a closing pipe', () {
        const trapped = r'| A | B \';
        expect(closeStreamingDelimiters(trapped), same(trapped));
      });

      test('an even backslash run closes normally', () {
        expect(closeStreamingDelimiters(r'| A | B \\'),
            r'| A | B \\|' '\n' r'|---|---|' '\n');
      });

      test('a completed inline construct inside a cell still forms a table',
          () {
        const text = '| \$x\$ | y';
        expect(closeStreamingDelimiters(text), '| \$x\$ | y|\n|---|---|\n');
      });

      test('an inline claim across the header hides the row structure', () {
        // The bold pair completed across the line masks the interior
        // pipes, so no provisional table is inferred — the line renders as
        // emphasized text, exactly as the closer layer decided.
        expect(closeStreamingDelimiters('| **A | B'), '| **A | B**');
      });
    });

    group('provisional streaming tables: safety and handoff', () {
      test('prose pipes never become a table', () {
        const prose = 'Pick a | b or c | d';
        expect(closeStreamingDelimiters(prose), same(prose));
        const sentence = '|x| is the absolute value of x.';
        expect(closeStreamingDelimiters(sentence), same(sentence));
      });

      test('pipes inside code, math and fences are shielded', () {
        const inline = 'see `a | b` in code';
        expect(closeStreamingDelimiters(inline), same(inline));
        const math = r'\(|a|b\)';
        expect(closeStreamingDelimiters(math), same(math));
        // An open fence closes first, then shields its code content.
        final fenced = closeStreamingDelimiters('```sql\nSELECT a | b FROM t');
        expect(fenced, '```sql\nSELECT a | b FROM t\n```');
        expect(fenced, isNot(contains('|---')));
      });

      test('a blank line ends the forming table at the paragraph boundary',
          () {
        const abandoned = '| A | B\n\nUnrelated prose follows.';
        expect(closeStreamingDelimiters(abandoned), same(abandoned));
      });

      test('prose directly after a forming row never gets swallowed', () {
        const text = '| A | B\nSome prose';
        expect(closeStreamingDelimiters(text), same(text));
      });

      test('a finished row without its closing pipe stays literal', () {
        const malformed = '| A | B\n| 1 | 2 |\n| 3';
        expect(closeStreamingDelimiters(malformed), same(malformed));
      });

      test('the separator being typed is never rendered as data', () {
        const typing = '| A | B |\n| ---';
        expect(closeStreamingDelimiters(typing), same(typing));
        const typing2 = '| A | B |\n| --- | ---';
        expect(closeStreamingDelimiters(typing2), same(typing2));
      });

      test('the real separator row makes provisional processing a no-op',
          () {
        const headerOnly = '| A | B |\n|---|---|';
        expect(closeStreamingDelimiters(headerOnly), same(headerOnly));
        const complete = '| A | B |\n|---|---|\n| 1 | 2 |';
        expect(closeStreamingDelimiters(complete), same(complete));
      });

      test('a second table forms after prose while the first is complete',
          () {
        expect(
            closeStreamingDelimiters('| A |\n|---|\n| 1 |\n\nintro\n\n| X | Y'),
            '| A |\n|---|\n| 1 |\n\nintro\n\n| X | Y|\n|---|---|\n');
      });

      test('a complete table followed by prose returns the same instance',
          () {
        const text = '| A | B |\n|---|---|\n| 1 | 2 |\n\nDone.';
        expect(closeStreamingDelimiters(text), same(text));
      });

      test('tables: idempotent, completing twice changes nothing further',
          () {
        final once = closeStreamingDelimiters('| A | B |\n| 1');
        expect(once, '| A | B |\n|---|---|\n| 1|');
        expect(closeStreamingDelimiters(once), once);
        final grown = closeStreamingDelimiters('| A | B |\n|---|\n| 1');
        expect(grown, '| A | B |\n|---|\n| 1|');
        expect(closeStreamingDelimiters(grown), grown);
      });
    });
  });
}
