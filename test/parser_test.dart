import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Copy of the logic from ai.dart for isolation testing
List<InlineSpan> _parseThinkingTextTest(String text) {
  if (text.isEmpty) return [];

  final List<InlineSpan> spans = [];
  // UPDATED REGEX candidate to test: handling newlines with dotAll check or manually
  // The original was: RegExp(r'\*\*(.*?)\*\*') which fails on multiline.
  // We want to verify that failure first, or implement a better one.

  // Let's use the one currently in ai.dart to demonstrate the failure first if needed,
  // but the user wants me to fix it. I will write the IMPROVED logic here directly
  // and then port it back if it passes.

  // Improved Regex: dotAll mode via (?s) or just [^] logic? Dart doesn't support (?s) easily in string pattern,
  // [FIX] Cleanup tags and artifacts BEFORE parsing formatting
  // 1. Tool Usage lines
  String processedText = text;

  // Simulate Block Parser consuming <think> tags:
  // In the real parser, these are caught by a Block Regex and rendered as a widget.
  // For this TextSpan test, we just want to ensure they don't appear as raw text artifacts.
  processedText = processedText.replaceAll(RegExp(r'<think>|</think>'), '');

  // 2. Remove Tool Usage lines (e.g. *Using get_weather...*)
  // Handling potential newlines around it
  processedText =
      processedText.replaceAll(RegExp(r'\*Using .*?\*(?: [^\n]*)?'), '');

  // 3. Remove Scattered Thinking Lines
  processedText = processedText.replaceAll(
      RegExp(r'(?:^|[\r\n]+)[ \t]*>?\s*\*Thinking\.\.\.\*[\r\n]*>?[ \t]?',
          caseSensitive: false),
      '');

  // 4. [REMOVED] Remove leading/hanging "> " artifacts from scattered streams - let the block parser handle it
  // processedText = processedText.replaceAll(RegExp(r'(?<=^|\n)>\s?'), '');

  // 3. Remove Widget Raw Data
  processedText = processedText.replaceAll(
      RegExp(r'<<<WIDGET:.*?>>>.*?<<<END>>>', dotAll: true), '');

  // [ADDED] Remove specific "Thinking..." artifacts
  processedText = processedText.replaceAll(
      RegExp(r'\*?Thinking\.\.\.\*?', caseSensitive: false), '');

  processedText = processedText.trim(); // Clean up extra whitespace

  final regex = RegExp(r'\*\*(.*?)\*\*', dotAll: true);

  int lastMatchEnd = 0;

  for (final match in regex.allMatches(processedText)) {
    // Text before match
    if (match.start > lastMatchEnd) {
      spans.add(
          TextSpan(text: processedText.substring(lastMatchEnd, match.start)));
    }

    // The **Matched Text** -> Header Style
    // We want to ensure it handles the content correctly
    String content = match.group(1) ?? "";
    spans.add(TextSpan(
      text: "\n$content\n",
      style: const TextStyle(fontWeight: FontWeight.bold),
    ));

    lastMatchEnd = match.end;
  }

  // Remaining text
  if (lastMatchEnd < processedText.length) {
    spans.add(TextSpan(text: processedText.substring(lastMatchEnd)));
  }

  return spans;
}

void main() {
  group('Thinking UI Parser Tests', () {
    test('Standard single line bold', () {
      final text = "This is **Bold** text.";
      final spans = _parseThinkingTextTest(text);

      expect(spans.length, 3);
      expect((spans[0] as TextSpan).text, "This is ");
      expect((spans[1] as TextSpan).text, "\nBold\n");
      expect((spans[1] as TextSpan).style?.fontWeight, FontWeight.bold);
      expect((spans[2] as TextSpan).text, " text.");
    });

    test('Multiline bold content', () {
      final text = "Start **Bold\nLine** End";
      final spans = _parseThinkingTextTest(text);

      // If regex is correct, should find the match across lines
      expect(spans.length, 3);
      expect((spans[1] as TextSpan).text, "\nBold\nLine\n");
    });

    test('Multiple bold blocks', () {
      final text = "**One** and **Two**";
      final spans = _parseThinkingTextTest(text);

      expect(
          spans.length, 3); // Padding text in middle might count as one span?
      // Current logic:
      // Match 1: "**One**" -> adds (0-0 empty?), adds Bold "One"
      // lastMatchEnd = 7
      // Match 2: "**Two**" -> start 12. Adds " and ", adds Bold "Two"
      // lastMatchEnd = 19
      // Remaining: "" -> ignores? logic says if lastMatchEnd < text.length. 19 < 19 is false.

      expect(spans.length, 3); // Bold(One), Normal( and ), Bold(Two)
      // Wait, 0 > 0 is false, so first Span is skipped?
      // Match 1 start is 0. lastMatchEnd is 0. 0 > 0 False.
      // So no leading normal span. Correct.
    });

    test('Unclosed markers', () {
      final text = "This is **not bold";
      final spans = _parseThinkingTextTest(text);
      expect(spans.length, 1);
      expect((spans[0] as TextSpan).text, "This is **not bold");
    });

    test('Complex mixed content', () {
      final text = "Step 1: **Analyze**\nStep 2: **Execute**\nDone.";
      final spans = _parseThinkingTextTest(text);

      expect(spans.length, 5); // Normal, Bold, Normal, Bold, Normal
      expect((spans[1] as TextSpan).text, "\nAnalyze\n");
      expect((spans[3] as TextSpan).text, "\nExecute\n");
    });

    test('Empty content inside/outside', () {
      final text = "****"; // Empty bold
      final spans = _parseThinkingTextTest(text);
      expect(spans.length, 1);
      expect((spans[0] as TextSpan).text, "\n\n");
    });
    test('User reported scenario: <think> tags and tool artifacts', () {
      final text =
          "<think>I need to present the weather details in Turkish...</think>\n"
          "*Using get_weather...*\n"
          "<<<WIDGET:weather_card>>>{...}<<<END>>>\n"
          "Şu an Los Angeles'ta...";

      final spans = _parseThinkingTextTest(text);

      // We expect the <think> tags to be GONE, and the content inside to be handled.
      // We also expect *Using...* to be removed or handled gracefully.
      // Currently, the parser likely just regexes **bold**, so it might leave <think> as plain text.

      bool definitionsLeak =
      spans.any((s) => (s as TextSpan).text?.contains('<think>') ?? false);
      expect(definitionsLeak, isFalse,
          reason: "<think> tags should not be visible in spans");

      bool toolLeak =
      spans.any((s) => (s as TextSpan).text?.contains('*Using') ?? false);
      expect(toolLeak, isFalse, reason: "Tool usage text should be removed");
    });

    test('Scenario: Weather with <think> leakage', () {
      final text =
          "<think>I need to present the weather details in Turkish...</think>\n"
          "*Using get_weather...*\n"
          "<<<WIDGET:weather_card>>>{\"city\":\"Los Angeles\"}<<<END>>>\n"
          "Şu an Los Angeles'ta yaklaşık 11.8°C.";

      // We want to ensure NO <think> tags, NO *Using*, NO Widget data in the final spans if we are parsing for display (or at least handled widely)
      // The _parseThinkingTextTest is for the "Thinking Block" itself?
      // ACTUALLY, the user says these are issues in the MAIN chat view usually, not just inside thinking bubble.
      // But let's assume this parser logic we are testing is what's used for "Thinking" state or General state?
      // The user said "parser'ımız bu metinde think tokenlarını ayıklayamadı".
      // If this text is the *entire* message, the <think> part should probably be hidden or formatted as a Thought Block.
      // If it's a finished message, <think> should be removed or collapsed.

      final spans = _parseThinkingTextTest(text);

      bool leak =
      spans.any((s) => (s as TextSpan).text?.contains('<think>') ?? false);
      expect(leak, isFalse, reason: "<think> tags leaked");

      bool toolLeak =
      spans.any((s) => (s as TextSpan).text?.contains('*Using') ?? false);
      expect(toolLeak, isFalse, reason: "*Using...* leaked");
    });

    test('Scenario: Scattered Thinking lines (Legacy/DeepSeek style)', () {
      final text = "> *Thinking...*\n"
          "> **Dec\n"
          "\n\n"
          "> *Thinking...*\n"
          "> iding\n"
          "\n\n"
          "> *Thinking...*\n"
          ">  on\n"
          "\n\n"
          "> *Thinking...*\n"
          ">  city\n";

      // This input style is very fragmented. ideally we want to extract "Deciding on city" from this.
      // The current simple regex probably keeps them as separate lines or fails.

      final spans = _parseThinkingTextTest(text);
      // We'd expect the text to be cleaned up or at least not show "> *Thinking...*" fully.

      bool rawThinkingLeak = spans.any(
              (s) =>
          (s as TextSpan).text?.contains('> *Thinking...*') ?? false);
      expect(rawThinkingLeak, isFalse,
          reason: "Raw '> *Thinking...*' lines should be stripped/merged");

      String combinedText = spans.map((s) => (s as TextSpan).text).join();
      expect(combinedText.contains("Deciding on city"), isTrue,
          reason: "Should reconstruct the sentence 'Deciding on city'");
    });

    test('Scenario: Python Chart with <think> and tool', () {
      final text =
          "<think>**Clarifying chart**\nI might need to apologize...</think>\n"
          "*Using run_python_code...*\n"
          "<<<WIDGET:code_execution>>>{...}<<<END>>>\n"
          "Haklısın—burada 3B grafik...";

      final spans = _parseThinkingTextTest(text);

      bool leak =
      spans.any((s) => (s as TextSpan).text?.contains('<think>') ?? false);
      expect(leak, isFalse, reason: "<think> tags leaked");
    });

    test('Scenario: Stock Price with checkmark artifact', () {
      final text = "Okay, let me use the \n"
          "*Using get_stock_price...* ✅\n"
          "It looks like I'm having trouble...\n" // This might be thinking text too?
          "*Using get_stock_price...*\n"
          "<<<WIDGET:crypto_card>>>{...}<<<END>>>\n"
          "Based on prior info...";

      final spans = _parseThinkingTextTest(text);

      // The "*Using get_stock_price...* ✅" line should probably be gone too.
      bool toolLeak =
      spans.any((s) => (s as TextSpan).text?.contains('*Using') ?? false);
      expect(toolLeak, isFalse, reason: "*Using...* leaked");
    });
    test('Scenario: Inline Thinking Artifacts (Sticky)', () {
      final text = "JanuaryThinking... 25,Thinking... 2026";

      final spans = _parseThinkingTextTest(text);
      final combined = spans.map((s) => (s as TextSpan).text).join();

      expect(combined, contains("January 25, 2026"));
      expect(combined, isNot(contains("Thinking...")));
    });

    test('Scenario: Widget blocks stripped from text', () {
      final text = '''Some text.

<<<WIDGET:weather_card>>>{"city":"Istanbul"}<<<END>>>
Selam kanka!''';

      final spans = _parseThinkingTextTest(text);
      bool widgetLeak = spans.any(
          (s) => (s as TextSpan).text?.contains('<<<WIDGET') ?? false);
      expect(widgetLeak, isFalse,
          reason: "Widget tags should be stripped");
      
      final combined = spans.map((s) => (s as TextSpan).text).join();
      expect(combined, contains('Selam kanka'),
          reason: "Text after widget should be preserved");
    });

    test('Scenario: Scattered Thinking cleaned properly', () {
      final text = '''> *Thinking...*
> The


> *Thinking...*
>  user


> *Thinking...*
>  asks''';

      final spans = _parseThinkingTextTest(text);
      final combined = spans.map((s) => (s as TextSpan).text).join();

      bool rawLeak = spans.any(
          (s) => (s as TextSpan).text?.contains('> *Thinking...*') ?? false);
      expect(rawLeak, isFalse,
          reason: "Thinking markers should be stripped");

      expect(combined, contains("The user asks"),
          reason: "Should merge lines without gaps");
    });

    test('Scenario: Space Preservation (The + user)', () {
      final text = '''> *Thinking...*
> The 


> *Thinking...*
>  user''';

      final spans = _parseThinkingTextTest(text);
      final combined = spans.map((s) => (s as TextSpan).text).join();

      expect(combined, matches(RegExp(r"The\s+user")),
          reason: "Should preserve space between words");
      expect(combined, isNot(contains("Theuser")),
          reason: "Should not merge words without space");
    });
  });
}
