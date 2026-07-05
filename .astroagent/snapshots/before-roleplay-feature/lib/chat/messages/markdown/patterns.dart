class RegexPatterns {
  static final thinking =
      RegExp(r'(<think>[\s\S]*?(?:</think>|$))', multiLine: false);
  static final memory =
      RegExp(r'(<memory>[\s\S]*?(?:</memory>|$))', multiLine: false);
  static final thinkingLegacy = RegExp(
      r'(?:^|\n)\s*>\s*\*?Thinking[.\s]*\*?\s*\n?(?:\s*>[ \t]*[^\n]*\n?)*',
      multiLine: true);
  static final horizontalRule =
      RegExp(r'^[ \t]*(?:[-*_][ \t]*){3,}\s*$', multiLine: true);
  static final codeBlock =
      RegExp(r'^```([^\r\n]*)\r?\n([\s\S]*?)\r?\n^```$', multiLine: true);
  static final legacyUsing =
      RegExp(r'^\s*\*Using (.+?)\.\.\.\*.*$', multiLine: true);
  static final blockquote = RegExp(r'^(?:\s*>\s?.+(?:\n|$))+', multiLine: true);
  static final table = RegExp(
      r'(^\s*\|.+\|\s*\n\s*\|(?:\s*:?-+:?\s*\|)+\s*\n(?:\s*\|.*\|\s*\n?)+)',
      multiLine: true);
  static final widget = RegExp(
      r'<<<WIDGET:([a-zA-Z0-9_]+)>>>([\s\S]*?)<<<END>>>',
      multiLine: true);
  static final orderedBoldHeading =
      RegExp(r'^\s*(\d+)[.)]\s+(\*\*|__)([^\r\n]+?)\2\s*$', multiLine: true);
  static final heading = RegExp(r'^#{1,6} .+?$', multiLine: true);
  static final bulletList = RegExp(r'^\s*[*\-+]\s+(.+)$', multiLine: true);

  static final inlineCode = RegExp(r'`[^`\r\n]+?`');
  static final latex = RegExp(
      r'(\$\$[\s\S]+?\$\$|\\\[[\s\S]+?\\\]|\\begin\{.+?\}[\s\S]+?\\end\{.+?\}|\\\(.+?\\\)|(?<!\$)\$[^$\r\n]+?\$(?!\$))');
  static final link = RegExp(r'\(?\s*\[([^\]]+)\]\(([^)]+)\)\s*\)?');
  static final bareUrl = RegExp(r'(?<![\])])\b(https?://[^\s<]+)');
  static final citation = RegExp(r'\[\s*(\d+)\s*\]|【\s*(.*?)\s*】');
  static final boldItalic =
      RegExp(r'(\*\*\*.+?\*\*\*|___.+?___)', dotAll: true);
  static final bold = RegExp(r'(\*\*.+?\*\*|__.+?__)', dotAll: true);
  static final strikethrough = RegExp(r'~~.+?~~', dotAll: true);
  static final italic =
      RegExp(r'(?<![*$])\*(?!\*).+?(?<!\*)\*(?![*$])', dotAll: true);
  static final thinkStart = RegExp(r'<think>\s*');
  static final thinkEnd = RegExp(r'\s*</think>');
  static final toolResultEmoji = RegExp(r'\s*[✅❌✓✗]\s*');
  static final usingToolLine =
      RegExp(r'\n?\*Using [^*]+\.\.\.[^*]*\*\s*[✅❌✓✗]?\s*\n?');

  static final blockPatterns = {
    'memory': memory,
    'thinking': thinking,
    'thinkingLegacy': thinkingLegacy,
    'horizontalRule': horizontalRule,
    'codeBlock': codeBlock,
    'legacyUsing': legacyUsing,
    'blockquote': blockquote,
    'table': table,
    'widget': widget,
    'orderedBoldHeading': orderedBoldHeading,
    'heading': heading,
    'bulletList': bulletList,
  };

  static final combinedInlinePattern = RegExp(
      inlinePatterns.entries
          .map((e) => '(?<${e.key}>${e.value.pattern})')
          .join('|'),
      dotAll: true);

  static final inlinePatterns = {
    'inlineCode': inlineCode,
    'latex': latex,
    'link': link,
    'bareUrl': bareUrl,
    'citation': citation,
    'boldItalic': boldItalic,
    'bold': bold,
    'strikethrough': strikethrough,
    'italic': italic,
  };
}
