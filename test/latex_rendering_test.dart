import 'package:cortex/chat/messages/codeblocks.dart';
import 'package:cortex/chat/messages/markdown/inline.dart';
import 'package:cortex/chat/messages/markdown/parser.dart';
import 'package:cortex/chat/messages/markdown/patterns.dart';
import 'package:cortex/chat/messages/markdown/utils.dart';
import 'package:cortex/fog.dart';
import 'package:cortex/l10n/app_localizations.dart';
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

  // parseText runs the real block + inline pipeline the chat tiles use;
  // mounting the result in a RichText also exercises real layout so a
  // WidgetSpan that throws would surface here, not just in production.
  // [isFinished] mirrors the production call sites: false while the SSE
  // stream is still live (provisional streaming layer active), true for a
  // finalized message (finalized rules only).
  Future<List<InlineSpan>> parseFull(WidgetTester tester, String text,
      {bool isFinished = false}) async {
    var spans = <InlineSpan>[];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            spans = parseText(context, text, isFinished: isFinished);
            return RichText(text: TextSpan(children: spans));
          },
        ),
      ),
    ));
    await tester.pump();
    return spans;
  }

  List<SafeMathTex> collectMath(List<InlineSpan> spans) {
    final found = <SafeMathTex>[];
    for (final span in spans) {
      if (span is WidgetSpan && span.child is SafeMathTex) {
        found.add(span.child as SafeMathTex);
      } else if (span is TextSpan && span.children != null) {
        found.addAll(collectMath(span.children!));
      }
    }
    return found;
  }

  String collectText(List<InlineSpan> spans) {
    final buffer = StringBuffer();
    for (final span in spans) {
      if (span is TextSpan) {
        if (span.text != null) buffer.write(span.text);
        if (span.children != null) {
          buffer.write(collectText(span.children!));
        }
      }
    }
    return buffer.toString();
  }

  group(r'TeX delimiters \(...\) and \[...\] in the full pipeline', () {

    testWidgets('renders \\(...\\) as inline math', (tester) async {
      final math = collectMath(
          await parseFull(tester, r'Euler: \(e^{i\pi} + 1 = 0\)!'));
      expect(math, hasLength(1));
      expect(math.first.latex, r'e^{i\pi} + 1 = 0');
      expect(math.first.display, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders \\[...\\] as a display block', (tester) async {
      final math =
          collectMath(await parseFull(tester, '\\[\nE = mc^2\n\\]'));
      expect(math, hasLength(1));
      expect(math.first.latex, 'E = mc^2');
      expect(math.first.display, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the quadratic formula block', (tester) async {
      const text =
          'Roots:\n\\[\nx = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}\n\\]\n';
      final math = collectMath(await parseFull(tester, text));
      expect(math, hasLength(1));
      expect(math.first.display, isTrue);
      expect(math.first.latex, r'x = \frac{-b \pm \sqrt{b^2-4ac}}{2a}');
    });

    testWidgets('renders a pmatrix display block', (tester) async {
      const text =
          '\\[\n\\begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\end{pmatrix}\n\\]';
      final math = collectMath(await parseFull(tester, text));
      expect(math, hasLength(1));
      expect(
          math.first.latex, r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}');
    });

    testWidgets('renders \\(...\\) inside bold text', (tester) async {
      final math =
          collectMath(await parseFull(tester, r'**Weight \(m\) matters**'));
      expect(math, hasLength(1));
      expect(math.first.latex, 'm');
    });

    testWidgets('renders the full five-section Greek-letter sample',
        (tester) async {
      const sample = '''
### 1. Temel Yunan harfleri

\\[
\\alpha, \\beta, \\gamma, \\delta, \\epsilon, \\varepsilon, \\zeta, \\eta, \\theta, \\iota, \\kappa, \\lambda, \\mu, \\nu, \\xi, \\omicron, \\pi, \\rho, \\sigma, \\tau, \\upsilon, \\phi, \\varphi, \\chi, \\psi, \\omega, \\Gamma, \\Delta, \\Theta, \\Lambda, \\Xi, \\Pi, \\Sigma, \\Upsilon, \\Phi, \\Psi, \\Omega
\\]

### 2. Matematiksel işlemler

\\[
\\sum_{i=1}^{n} i^{2} = \\frac{n(n+1)(2n+1)}{6}
\\]

\\[
\\prod_{i=1}^{n} i = n!
\\]

\\[
\\int_{0}^{\\infty} e^{-x^{2}}\\,dx = \\frac{\\sqrt{\\pi}}{2} \\qquad x \\in \\mathbb{R}
\\]

### 3. Diğer gösterimler

Karekök: \\(\\sqrt[3]{x}\\), Mutlak değer: \\(|x|\\), Vektör: \\(\\vec{v}\\), Matris: \\(\\begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\end{pmatrix}\\)

### 4. Mantıksal ve küme simgeleri

\\[
\\forall \\epsilon > 0, \\exists \\delta > 0 : |x - x_{0}| < \\delta \\Rightarrow |f(x) - f(x_{0})| < \\epsilon
\\]

\\[
\\mathbb{R}, \\mathbb{Z}, \\mathbb{N}, \\mathbb{Q}, \\mathbb{C}, \\emptyset, \\varnothing, \\subseteq, \\supseteq, \\in, \\notin, \\cap, \\cup, \\times, \\bigcirc
\\]

### 5. Ok ve benzeri semboller

\\(\\dots\\), \\(\\cdots\\), \\(\\leftarrow,\\ \\Rightarrow\\), \\(\\leftrightarrow\\), \\(\\mapsto\\), \\(\\uparrow\\), \\(\\downarrow\\)
''';

      final spans = await parseFull(tester, sample);
      // 6 display blocks (sections 1, 2 and 4) + 11 inline spans (3 and 5).
      final math = collectMath(spans);
      expect(math, hasLength(17));
      expect(math.where((m) => m.display), hasLength(6));
      expect(math.where((m) => !m.display), hasLength(11));
      expect(find.byType(SafeMathTex), findsNWidgets(17));
      final text = collectText(spans);
      // Headings and prose survive as text…
      expect(text, contains('1. Temel Yunan harfleri'));
      expect(text, contains('5. Ok ve benzeri semboller'));
      expect(text, contains('Karekök'));
      // …and no raw LaTeX source leaks into the text spans.
      expect(text, isNot(contains('\\alpha')));
      expect(text, isNot(contains('\\frac{')));
      expect(text, isNot(contains('\\begin{pmatrix}')));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'a still-open \\[ block: literal when finished, provisional math while streaming',
        (tester) async {
      const partial = 'Yaklaşık:\n\\[\n\\frac{n(n+';
      // Finalized rules (message complete): an unclosed \[ stays literal.
      final done = await parseFull(tester, partial, isFinished: true);
      expect(collectMath(done), isEmpty);
      expect(collectText(done), contains('\\frac{n(n+'));
      expect(tester.takeException(), isNull);

      // Streaming: the closer is synthesized at the frontier, so the partial
      // equation renders as display math right away. The incomplete LaTeX
      // degrades to the literal source INSIDE SafeMathTex — never a crash,
      // and never raw \[ / \] delimiters in the bubble.
      final live = await parseFull(tester, partial, isFinished: false);
      final math = collectMath(live);
      expect(math, hasLength(1));
      expect(math.first.display, isTrue);
      expect(math.first.latex, '\\frac{n(n+');
      expect(tester.takeException(), isNull);

      // …and it snaps to the identical finalized result once the real
      // closer arrives — the provisional layer hands off seamlessly.
      final complete = '${partial}1)(2n+1)}{6}\n\\]';
      final closed = collectMath(await parseFull(tester, complete));
      expect(closed, hasLength(1));
      expect(closed.first.display, isTrue);
      expect(closed.first.latex, '\\frac{n(n+1)(2n+1)}{6}');
    });

    testWidgets(
        'a still-open \\( span: literal when finished, provisional math while streaming',
        (tester) async {
      const partial = r'Partial: \(x + \frac{1}{2}';
      final done = await parseFull(tester, partial, isFinished: true);
      expect(collectMath(done), isEmpty);
      expect(collectText(done), contains(r'\frac{1}{2}'));

      final live = await parseFull(tester, partial, isFinished: false);
      final math = collectMath(live);
      expect(math, hasLength(1));
      expect(math.first.latex, r'x + \frac{1}{2}');
      expect(tester.takeException(), isNull);

      // The real closer hands off to the finalized parser seamlessly.
      final closed = collectMath(await parseFull(tester, '$partial\\)'));
      expect(closed, hasLength(1));
      expect(closed.first.latex, r'x + \frac{1}{2}');
    });

    testWidgets('fenced code blocks keep the delimiters literal',
        (tester) async {
      const text = '''
LaTeX source:

```latex
\\[
E = mc^2
\\]
ve \\(x\\)
```
''';
      await parseFull(tester, text);
      expect(find.byType(CodeBlockWidget), findsOneWidget);
      expect(find.byType(SafeMathTex), findsNothing);
      // 'latex' is not a language the highlighter package knows, so the
      // block schedules a background auto-detect pass (Future(() {...})).
      // Advance the clock so that timer fires inside the test instead of
      // leaking out and tripping the binding's "timers pending" invariant.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('inline code spans keep \\(...\\) literal', (tester) async {
      final spans =
          await parseFull(tester, r'Run `\(\sqrt{2}\)` literally.');
      expect(collectMath(spans), isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('markdown markup inside \\[...\\] stays inert', (tester) async {
      final math =
          collectMath(await parseFull(tester, '\\[\n- x + y = 0\n\\]'));
      expect(math, hasLength(1));
      expect(math.first.display, isTrue);
      expect(math.first.latex, '- x + y = 0');
    });

    testWidgets('mid-line \\[ \\] stays plain text, \\( \\) still renders',
        (tester) async {
      final spans =
          await parseFull(tester, 'note \\[a\\] and \\(b\\) inline');
      final math = collectMath(spans);
      expect(math, hasLength(1));
      expect(math.first.latex, 'b');
      expect(collectText(spans), contains('\\[a\\]'));
    });

    testWidgets('display math with trailing text stays literal', (tester) async {
      final spans = await parseFull(tester, r'\[x\] trailing text');
      expect(collectMath(spans), isEmpty);
      expect(collectText(spans), contains(r'\[x\]'));
    });

    testWidgets('mixed Markdown and math renders both', (tester) async {
      const text = '''
**Kuadratik formula**

\\[
x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}
\\]

When \\(b^2 - 4ac \\geq 0\\), real roots exist.
''';
      final spans = await parseFull(tester, text);
      final math = collectMath(spans);
      expect(math, hasLength(2));
      expect(math.first.display, isTrue);
      expect(math.last.display, isFalse);
      final rendered = collectText(spans);
      expect(rendered, contains('Kuadratik formula'));
      expect(rendered, contains('real roots exist.'));
    });

    testWidgets(r'$$ and \[ \] styles coexist in one message', (tester) async {
      const text = r'''Old style: $$a^2$$

New style:
\[
b^2
\]''';
      final math = collectMath(await parseFull(tester, text));
      expect(math, hasLength(2));
      expect(math.first.display, isTrue); // legacy $$
      expect(math.last.display, isTrue); // TeX \[ \]
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

    testWidgets('renders every construct of the Greek-letter sample',
        (tester) async {
      // Every LaTeX command used by the five-section sample must parse in
      // flutter_math_fork — i.e. no onErrorFallback to the literal source.
      const constructs = [
        r'\alpha, \beta, \gamma, \delta, \epsilon, \varepsilon, \zeta, \eta',
        r'\theta, \iota, \kappa, \lambda, \mu, \nu, \xi, \omicron, \pi',
        r'\rho, \sigma, \tau, \upsilon, \phi, \varphi, \chi, \psi, \omega',
        r'\Gamma, \Delta, \Theta, \Lambda, \Xi, \Pi, \Sigma, \Upsilon, \Phi, \Psi, \Omega',
        r'\sum_{i=1}^{n} i^{2} = \frac{n(n+1)(2n+1)}{6}',
        r'\prod_{i=1}^{n} i = n!',
        r'\int_{0}^{\infty} e^{-x^{2}}\,dx = \frac{\sqrt{\pi}}{2}',
        r'\oint_C F \cdot dr',
        r'\sqrt[3]{x}',
        r'|x|',
        r'\vec{v}',
        r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}',
        r'\forall \epsilon > 0, \exists \delta > 0',
        r'\mathbb{R}, \mathbb{Z}, \mathbb{N}, \mathbb{Q}, \mathbb{C}',
        r'\emptyset, \varnothing, \subseteq, \supseteq, \in, \notin',
        r'\cap, \cup, \times, \bigcirc',
        r'\dots, \cdots, \leftarrow, \rightarrow, \leftrightarrow',
        r'\mapsto, \uparrow, \downarrow, \Rightarrow',
        r'a \qquad b \quad c \, d \: e \; f',
      ];
      for (final latex in constructs) {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SafeMathTex(latex: latex, textStyle: TextStyle()),
          ),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'crashed on: $latex');
        expect(
          find.text(latex),
          findsNothing,
          reason: 'unsupported by flutter_math_fork, fell back: $latex',
        );
      }
    });
  });

  group('LaTeX multline environments', () {
    test('normalizes a complete multline to aligned, keeping every row', () {
      const latex =
          '\\begin{multline}\nS_n = 1 \\\\\n\\quad + 2 \\\\\n\\dots\n\\end{multline}';
      expect(normalizeMultiline(latex),
          '\\begin{aligned}\nS_n = 1 \\\\\n\\quad + 2 \\\\\n\\dots\n\\end{aligned}');
    });

    test('handles the starred form and drops a trailing row break', () {
      expect(normalizeMultiline(r'\begin{multline*}a \\ b \\\end{multline*}'),
          r'\begin{aligned}a \\ b\end{aligned}');
    });

    test('auto-closes a still-streaming multline so partial rows render', () {
      expect(normalizeMultiline(r'\begin{multline}' '\n' r'S_n = 1 \\'),
          r'\begin{aligned}' '\n' r'S_n = 1' r'\end{aligned}');
    });

    test('leaves every other environment untouched (same instance)', () {
      const aligned = r'\begin{aligned}x &= 1 \\ y &= 2\end{aligned}';
      expect(normalizeMultiline(aligned), same(aligned));
      const cases = r'\begin{cases}a & b\end{cases}';
      expect(normalizeMultiline(cases), same(cases));
      const matrix = r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}';
      expect(normalizeMultiline(matrix), same(matrix));
      expect(normalizeMultiline('x^2'), 'x^2');
    });

    testWidgets('renders the canonical \$\$-wrapped multline from LLM output',
        (tester) async {
      const text =
          '\$\$\n\\begin{multline}\nS_n = \\sum_{k=1}^{n} k \\\\\n     = \\frac{n(n+1)}{2}\n\\end{multline}\n\$\$';
      final math =
          collectMath(await parseFull(tester, text, isFinished: true));
      expect(math, hasLength(1));
      expect(math.first.display, isTrue);
      // The span carries the model's source verbatim…
      expect(math.first.latex,
          '\n\\begin{multline}\nS_n = \\sum_{k=1}^{n} k \\\\\n     = \\frac{n(n+1)}{2}\n\\end{multline}\n');
      // …and the normalization maps it to aligned for flutter_math_fork:
      expect(
          normalizeMultiline(math.first.latex),
          '\n\\begin{aligned}\nS_n = \\sum_{k=1}^{n} k \\\\\n'
          '     = \\frac{n(n+1)}{2}\n\\end{aligned}\n');
      // The normalized body actually parses in flutter_math_fork — a parse
      // failure would fall back to a Text with this exact literal source.
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SafeMathTex(latex: math.first.latex, textStyle: TextStyle()),
        ),
      ));
      await tester.pump();
      expect(find.byType(Math), findsOneWidget);
      expect(find.text(math.first.latex), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('multline works inside the \\[...\\] display pipeline too',
        (tester) async {
      const text = '\\[\n\\begin{multline}\nA \\\\\nB\n\\end{multline}\n\\]';
      final math =
          collectMath(await parseFull(tester, text, isFinished: true));
      expect(math, hasLength(1));
      expect(math.first.display, isTrue);
      // The block handler trims the captured body:
      expect(math.first.latex, '\\begin{multline}\nA \\\\\nB\n\\end{multline}');
      expect(normalizeMultiline(math.first.latex),
          '\\begin{aligned}\nA \\\\\nB\n\\end{aligned}');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SafeMathTex(latex: math.first.latex, textStyle: TextStyle()),
        ),
      ));
      await tester.pump();
      expect(find.byType(Math), findsOneWidget);
      expect(find.text(math.first.latex), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Provisional streaming rendering (parseText layer)', () {
    bool hasBoldStyle(List<InlineSpan> spans) => spans.any((span) {
          if (span is TextSpan) {
            if (span.style?.fontWeight == FontWeight.bold) return true;
            if (span.children != null) return hasBoldStyle(span.children!);
          }
          return false;
        });

    testWidgets('dangling ** renders bold while streaming, literal once finished',
        (tester) async {
      const text = 'The answer is **42 and counting';
      final live = await parseFull(tester, text, isFinished: false);
      expect(collectText(live), isNot(contains('**')));
      expect(collectText(live), contains('42 and counting'));
      expect(hasBoldStyle(live), isTrue);

      final done = await parseFull(tester, text, isFinished: true);
      expect(collectText(done), contains('**42'));
      expect(hasBoldStyle(done), isFalse);
    });

    testWidgets('dangling \\[ stops at the blank line: later prose survives',
        (tester) async {
      const text = 'Intro:\n\\[\nx = y\n\nUnrelated prose follows.';
      final live = await parseFull(tester, text, isFinished: false);
      final math = collectMath(live);
      expect(math, hasLength(1));
      expect(math.first.display, isTrue);
      expect(math.first.latex, 'x = y');
      expect(collectText(live), contains('Unrelated prose follows.'));
      expect(tester.takeException(), isNull);

      final done = await parseFull(tester, text, isFinished: true);
      expect(collectMath(done), isEmpty);
      expect(collectText(done), contains('Unrelated prose follows.'));
    });

    testWidgets('dangling \$\$ renders display math while streaming',
        (tester) async {
      const text = 'Eqs:\n\$\$x + y';
      final live = await parseFull(tester, text, isFinished: false);
      final math = collectMath(live);
      expect(math, hasLength(1));
      expect(math.first.display, isTrue);
      expect(math.first.latex, 'x + y');

      final done = await parseFull(tester, text, isFinished: true);
      expect(collectMath(done), isEmpty);
    });

    testWidgets('a streaming multline renders as soon as \\[ opens',
        (tester) async {
      const partial = 'Derivation:\n\\[\n\\begin{multline}\nS_n = 1 \\\\\n';
      final live = await parseFull(tester, partial, isFinished: false);
      final math = collectMath(live);
      expect(math, hasLength(1));
      expect(math.first.display, isTrue);
      expect(math.first.latex, '\\begin{multline}\nS_n = 1 \\\\');
      // The normalized partial body actually renders (auto-closed to
      // aligned) — the multline arrives line by line as math, not as raw
      // source, and a literal fallback would show this exact string.
      expect(find.byType(Math), findsOneWidget);
      expect(find.text(math.first.latex), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an open code fence renders CodeBlockWidget immediately',
        (tester) async {
      const text = 'Example:\n```dart\nprint(1);';
      await parseFull(tester, text, isFinished: false);
      expect(find.byType(CodeBlockWidget), findsOneWidget);

      final done = await parseFull(tester, text, isFinished: true);
      expect(find.byType(CodeBlockWidget), findsNothing);
      expect(collectText(done), contains('print(1);'));
    });

    testWidgets('currency prose never becomes math, even mid-stream',
        (tester) async {
      const text = 'It costs \$5 or \$10 today.';
      final live = await parseFull(tester, text, isFinished: false);
      expect(collectMath(live), isEmpty);
      expect(collectText(live), contains('\$5'));
    });

    testWidgets('a dangling code span beats a dangling \\( on the same line',
        (tester) async {
      const text = 'Run `\\(x + now';
      final live = await parseFull(tester, text, isFinished: false);
      expect(collectMath(live), isEmpty);
      // The synthesized code chip holds the partial math source literally.
      expect(find.text('\\(x + now'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('incomplete LaTeX in a synthesized span never crashes',
        (tester) async {
      const text = 'Broken:\n\\[\n\\frac{n(n+ \\begin{multline} ^^{';
      final live = await parseFull(tester, text, isFinished: false);
      expect(collectMath(live), hasLength(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a closed message renders identically streaming or finished',
        (tester) async {
      const text = '**Bold**, \\(\\alpha\\), `code`, ~~gone~~ and \\(\\beta\\).';
      final live =
          collectText(await parseFull(tester, text, isFinished: false));
      final done =
          collectText(await parseFull(tester, text, isFinished: true));
      expect(live, done);
      expect(live, isNot(contains('**')));
      expect(live, isNot(contains('\\(')));
    });
    testWidgets('a forming table renders as a real Table while streaming',
        (tester) async {
      const text = '| Model | Context | Price';
      final live = await parseFull(tester, text, isFinished: false);
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Model', findRichText: true), findsOneWidget);
      expect(find.text('Context', findRichText: true), findsOneWidget);
      expect(find.text('Price', findRichText: true), findsOneWidget);
      expect(collectText(live), isNot(contains('| Model')));
      expect(tester.takeException(), isNull);

      final done = await parseFull(tester, text, isFinished: true);
      expect(find.byType(Table), findsNothing);
      expect(collectText(done), contains('| Model | Context | Price'));
    });

    testWidgets('the provisional table grows as cells stream in',
        (tester) async {
      await parseFull(tester, '| A | B', isFinished: false);
      expect(find.byType(Table), findsOneWidget);
      expect(
          tester
              .widget<Table>(find.byType(Table))
              .children
              .first
              .children
              .length,
          2);

      await parseFull(tester, '| A | B | C', isFinished: false);
      expect(find.byType(Table), findsOneWidget);
      expect(
          tester
              .widget<Table>(find.byType(Table))
              .children
              .first
              .children
              .length,
          3);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a real separator hands off seamlessly to the finalized parser',
        (tester) async {
      const text = '| A | B |\n|---|---|\n| 1 | 2 |';
      for (final finished in [false, true]) {
        await parseFull(tester, text, isFinished: finished);
        expect(find.byType(Table), findsOneWidget);
        // The separator row is consumed by the grammar — header + one data
        // row renders two TableRows, identically in both modes.
        expect(tester.widget<Table>(find.byType(Table)).children.length, 2);
        expect(find.text('A', findRichText: true), findsOneWidget);
        expect(find.text('1', findRichText: true), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('a live table absorbs the row still being typed',
        (tester) async {
      const text = '| A | B |\n|---|\n| 1';
      await parseFull(tester, text, isFinished: false);
      expect(find.byType(Table), findsOneWidget);
      expect(tester.widget<Table>(find.byType(Table)).children.length, 2);
      expect(find.text('1', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('multiple streamed rows render before any separator',
        (tester) async {
      const text = '| A | B |\n| 1 | 2 |\n| 3';
      await parseFull(tester, text, isFinished: false);
      expect(find.byType(Table), findsOneWidget);
      expect(tester.widget<Table>(find.byType(Table)).children.length, 3);
      expect(find.text('3', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('escaped pipes stay content in a streamed table',
        (tester) async {
      const text = r'| A \| B | C';
      await parseFull(tester, text, isFinished: false);
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('C', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('inline closers land inside the forming cells', (tester) async {
      const text = '| A | **B';
      await parseFull(tester, text, isFinished: false);
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('B', findRichText: true), findsOneWidget);
      expect(find.textContaining('**', findRichText: true), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('prose pipes never stream into a table', (tester) async {
      await parseFull(tester, 'Pick a | b or c', isFinished: false);
      expect(find.byType(Table), findsNothing);
      final mathProse = await parseFull(
          tester, '|x| is the absolute value of x.', isFinished: false);
      expect(find.byType(Table), findsNothing);
      expect(collectText(mathProse), contains('|x|'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an open fence shields pipe syntax from table detection',
        (tester) async {
      const text = '```sql\nSELECT a | b FROM t';
      await parseFull(tester, text, isFinished: false);
      expect(find.byType(CodeBlockWidget), findsOneWidget);
      expect(find.byType(Table), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('incomplete row shapes never crash while streaming',
        (tester) async {
      for (final t in ['|', '| Foo |']) {
        await parseFull(tester, t, isFinished: false);
        expect(tester.takeException(), isNull);
        expect(find.byType(Table), findsNothing);
      }
      await parseFull(tester, '| Foo | Bar', isFinished: false);
      expect(tester.takeException(), isNull);
      expect(find.byType(Table), findsOneWidget);
    });

  });
}
