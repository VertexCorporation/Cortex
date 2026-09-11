import 'package:cortex/chat/messages/markdown/inline.dart';
import 'package:cortex/chat/messages/markdown/patterns.dart';
import 'package:cortex/chat/messages/markdown/utils.dart';
import 'package:cortex/fog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LaTeX delimiters (patterns)', () {
    test('matches inline math and captures the source between the dollars',
        () {
      final match = RegexPatterns.inlineMath.firstMatch(r'Euler: $e^{i\pi}+1=0$!');
      expect(match, isNotNull);
      expect(match!.group(1), r'e^{i\pi}+1=0');
    });

    test('matches display math, including multi-line blocks', () {
      final match = RegexPatterns.displayMath
          .firstMatch('\$\$\n\\begin{matrix}a&b\\\\c&d\\end{matrix}\n\$\$');
      expect(match, isNotNull);
      expect(match!.group(1),
          '\n\\begin{matrix}a&b\\\\c&d\\end{matrix}\n');
    });

    test('prefers displayMath over inlineMath at the same position', () {
      final match =
          RegexPatterns.combinedInlinePattern.firstMatch(r'$$x^2$$');
      expect(match, isNotNull);
      expect(match!.namedGroup('displayMath'), isNotNull);
      expect(match.namedGroup('inlineMath'), isNull);
    });

    test('keeps code spans in front of math (code wins the scan order)', () {
      final match = RegexPatterns.combinedInlinePattern.firstMatch(r'`$x$`');
      expect(match, isNotNull);
      expect(match!.namedGroup('inlineCode'), isNotNull);
      expect(match.namedGroup('inlineMath'), isNull);
      expect(match.namedGroup('displayMath'), isNull);
    });

    test('never pairs currency prose as math', () {
      expect(RegexPatterns.inlineMath.hasMatch('costs \$5 and \$10 today'),
          isFalse);
      expect(RegexPatterns.inlineMath.hasMatch('price: \$9.99'), isFalse);
    });

    test('rejects dollars with whitespace just inside the delimiters', () {
      expect(RegexPatterns.inlineMath.hasMatch(r'not math: $ x $'), isFalse);
      expect(RegexPatterns.inlineMath.hasMatch('\$\n\n\$'), isFalse);
    });

    test(r'keeps escaped \$ literal and never opens a span with it', () {
      expect(RegexPatterns.inlineMath.hasMatch(r'\$x\$'), isFalse);
      expect(RegexPatterns.displayMath.hasMatch(r'\$\$x\$\$'), isFalse);
    });

    test('stays literal while a streamed equation is still open', () {
      // Streaming: the closing delimiter has not arrived yet.
      expect(RegexPatterns.displayMath.hasMatch('partial so far: \$\$x+y'),
          isFalse);
      expect(RegexPatterns.inlineMath.hasMatch('partial so far: \$x+y'),
          isFalse);
      // …and it snaps into math the moment it closes.
      expect(RegexPatterns.displayMath.hasMatch(r'done: $$x+y$$'), isTrue);
      expect(RegexPatterns.inlineMath.hasMatch(r'done: $x+y$'), isTrue);
    });

    test('never treats triple dollars as math', () {
      expect(RegexPatterns.displayMath.hasMatch(r'\$\$\$x\$\$\$'), isFalse);
      expect(RegexPatterns.displayMath.hasMatch('\$\$\$x\$\$\$'), isFalse);
    });
  });

  group('LaTeX in the inline pipeline', () {
    // Math spans may sit at the top level (plain paragraphs) or nested
    // inside styled segments (bold re-processes its content), so walk the
    // span tree instead of only checking the root list.
    bool hasMath(List<InlineSpan> spans) => spans.any((span) {
          if (span is WidgetSpan) return span.child is SafeMathTex;
          if (span is TextSpan && span.children != null) {
            return hasMath(span.children!);
          }
          return false;
        });

    Future<List<InlineSpan>> parse(
        WidgetTester tester, String text) async {
      var spans = <InlineSpan>[];
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            spans = processInlineElements(
                context, text, RegexPatterns.inlinePatterns, 16);
            return const SizedBox.shrink();
          },
        ),
      ));
      return spans;
    }

    testWidgets('renders inline math as a SafeMathTex widget span',
        (tester) async {
      final spans = await parse(tester, r'So we get $\alpha+\beta$ here.');

      expect(hasMath(spans), isTrue);
      final math = spans
          .whereType<WidgetSpan>()
          .map((s) => s.child as SafeMathTex)
          .single;
      expect(math.latex, r'\alpha+\beta');
      expect(math.display, isFalse);
    });

    testWidgets('renders display math as a block-level (display) SafeMathTex',
        (tester) async {
      final spans = await parse(tester, r'$$\int_0^1 x\,dx$$');

      final math = spans
          .whereType<WidgetSpan>()
          .map((s) => s.child as SafeMathTex)
          .single;
      expect(math.latex, r'\int_0^1 x\,dx');
      expect(math.display, isTrue);
    });

    testWidgets('renders math inside bold text too', (tester) async {
      final spans = await parse(tester, r'**$x^2$**');

      // Bold re-processes its content through the same inline pipeline, so
      // the math must survive inside the styled segment.
      expect(hasMath(spans), isTrue);
    });

    testWidgets('leaves escaped dollars as literal text', (tester) async {
      final spans = await parse(tester, r'The price is \$100 flat.');
      expect(hasMath(spans), isFalse);
    });

    testWidgets('leaves currency prose as literal text', (tester) async {
      final spans = await parse(tester, 'It costs \$5 or \$10.');
      expect(hasMath(spans), isFalse);
    });

    testWidgets('does not pair an unclosed streamed equation', (tester) async {
      final spans = await parse(tester, 'Streaming: \$\$x^2 + \\frac{1}{2}');
      expect(hasMath(spans), isFalse);
    });

    testWidgets('protects dollars inside inline code spans', (tester) async {
      final spans = await parse(tester, 'Run `\$x\$` in bash.');
      expect(hasMath(spans), isFalse);
    });
  });

  group('SafeMathTex widget', () {
    testWidgets('renders valid LaTeX through flutter_math_fork',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SafeMathTex(latex: 'x^2', textStyle: TextStyle()),
        ),
      ));

      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('falls back to the literal source text on malformed LaTeX',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SafeMathTex(latex: r'\frac{', textStyle: TextStyle()),
        ),
      ));

      // flutter_math_fork always constructs the Math widget; a parse error
      // makes its build render the onErrorFallback subtree instead. The
      // literal source must therefore appear as plain text.
      expect(find.byType(Math), findsOneWidget);
      expect(
        find.text(r'\frac{'),
        findsOneWidget,
        reason: 'onErrorFallback must render the literal source text',
      );
    });

    testWidgets('display mode scrolls horizontally behind fog edges',
        (tester) async {
      const wideLatex =
          r'\frac{a+b+c+d}{e+f+g+h}+\frac{a+b+c+d}{e+f+g+h}+\frac{a+b+c+d}{e+f+g+h}';
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: SafeMathTex(
              latex: wideLatex,
              textStyle: TextStyle(),
              display: true,
            ),
          ),
        ),
      ));
      await tester.pump();

      // Wide equations get the code-block treatment: horizontal scroll
      // wrapped in the shared fog-edge widget (lib/fog.dart).
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(ScrollFogHorizontal), findsOneWidget);
      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('display math lays out inside a real RichText paragraph',
        (tester) async {
      // Regression guard: the display span must not crash under the
      // constraints a WidgetSpan gets inside RichText.
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: Builder(
              builder: (context) {
                final spans = processInlineElements(
                    context, r'Before $$x^2$$ after', RegexPatterns.inlinePatterns, 16);
                return RichText(text: TextSpan(children: spans));
              },
            ),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(SafeMathTex), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
