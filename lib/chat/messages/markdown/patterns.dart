class RegexPatterns {
  static final thinking = RegExp(r'(<think\b[^>]*>[\s\S]*?(?:</think\s*>|$))',
      caseSensitive: false);
  // Markdown requires one repeated marker, rather than any mixture of `*`,
  // `_` and `-` (for example `*-*` is not a horizontal rule).
  static final horizontalRule =
      RegExp(r'^[ \t]*([*_-])(?:[ \t]*\1){2,}[ \t]*$', multiLine: true);
  static final codeBlock = RegExp(
      r'^[ \t]*(```+)([^\r\n]*)\r?\n([\s\S]*?)\r?\n^[ \t]*\1[ \t]*$',
      multiLine: true);
  static final blockquote = RegExp(r'^(?:\s*>\s?.+(?:\n|$))+', multiLine: true);
  static final table = RegExp(
      r'(^[ \t]*\|[^\r\n]+\|[ \t]*\r?\n[ \t]*\|(?:[ \t]*:?-+:?[ \t]*\|)+[ \t]*(?:\r?\n|$)(?:[ \t]*\|[^\r\n]*\|[ \t]*(?:\r?\n|$))*)',
      multiLine: true);
  static final heading = RegExp(r'^#{1,6}\s+.+$', multiLine: true);
  static final bulletList = RegExp(r'^\s*[*\-+]\s+(.+)$', multiLine: true);

  static final inlineCode = RegExp(r'(?<!`)`([^`\r\n]+)`(?!`)');
  // --- LATEX MATH ---
  // Display math: $$...$$. The content is lazy and may span lines, so the
  // canonical multi-line block form renders just like the single-line one.
  // The closing delimiter is REQUIRED — a streamed, still-open "$$" stays
  // literal text until its closing "$$" arrives (no flicker, no crash, no
  // swallowing of the rest of the response). Escaped dollars (\$) and runs of
  // three or more $ never open (or close) a math span.
  static final displayMath =
      RegExp(r'(?<![\\$])\$\$([\s\S]+?)(?<![\\$])\$\$(?!\$)');
  // Inline math: $...$. One line, non-empty, no space just inside either
  // delimiter (KaTeX/Pandoc rules), closing $ never followed by a digit —
  // so currency prose like "costs $5, $10" can never pair up as math.
  // Escaped dollars (\$) never open a span and stay literal text.
  static final inlineMath = RegExp(
      r'(?<![\\$])\$(?!\$)(?![ \t\n])((?:\\[^\n]|[^$\n])+?)(?<![ \t])\$(?!\d)(?!\$)');
  // One balanced parenthesised segment is accepted inside a URL. This covers
  // common links such as `/Function_(mathematics)` without swallowing prose.
  static final link =
      RegExp(r'(?<!\\)\[([^\]\r\n]+)\]\(((?:\\.|[^()\r\n]|\([^()\r\n]*\))*)\)');
  static final bareUrl = RegExp(
      r'(?<![\]\w])(https?://(?:[^\s<>()\[\]{}]*[A-Za-z0-9_~%#=/]|[^\s<>()\[\]{}]*\([^\s<>()\[\]{}]*\)))');
  static final citation = RegExp(r'\[\s*(\d+)\s*\]|【\s*(.*?)\s*】');
  static final boldItalic = RegExp(
      r'(\*\*\*(?!\s).+?(?<!\s)\*\*\*|___(?!\s).+?(?<!\s)___)',
      dotAll: true);
  static final bold =
      RegExp(r'(\*\*(?!\s).+?(?<!\s)\*\*|__(?!\s).+?(?<!\s)__)', dotAll: true);
  static final strikethrough = RegExp(r'~~(?!\s).+?(?<!\s)~~', dotAll: true);
  static final italic = RegExp(
      r'(?<![\w*_$])\*(?![\s*]).+?(?<![\s*])\*(?![\w*$])|(?<![\w_])_(?![\s_]).+?(?<![\s_])_(?![\w_])',
      dotAll: true);
  static final thinkStart = RegExp(r'<think\b[^>]*>\s*', caseSensitive: false);
  static final thinkEnd = RegExp(r'\s*</think\s*>', caseSensitive: false);

  static final blockPatterns = {
    'thinking': thinking,
    'horizontalRule': horizontalRule,
    'codeBlock': codeBlock,
    'blockquote': blockquote,
    'table': table,
    'heading': heading,
    'bulletList': bulletList,
  };

  static final inlinePatterns = {
    'inlineCode': inlineCode,
    'link': link,
    'bareUrl': bareUrl,
    'citation': citation,
    'boldItalic': boldItalic,
    'bold': bold,
    'strikethrough': strikethrough,
    'italic': italic,
    // Math must be listed display-first: at a "$$" the display alternative
    // has to win the combined alternation (inlineMath can never match at a
    // "$$" anyway — its lookarounds reject doubled dollars — but the order
    // keeps the intent explicit). Appended after the text styles so bold and
    // italic keep their existing behavior; no other pattern claims a "$"
    // start position, so there are no same-start conflicts with them.
    'displayMath': displayMath,
    'inlineMath': inlineMath,
  };

  static final combinedInlinePattern = RegExp(
      inlinePatterns.entries
          .map((entry) => '(?<${entry.key}>${entry.value.pattern})')
          .join('|'),
      dotAll: true);
}
