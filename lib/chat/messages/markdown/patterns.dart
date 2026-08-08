class RegexPatterns {
  static final thinking =
      RegExp(r'(<think>[\s\S]*?(?:</think>|$))', multiLine: false);
  static final horizontalRule =
      RegExp(r'^[ \t]*(?:[-*_][ \t]*){3,}\s*$', multiLine: true);
  static final codeBlock =
      RegExp(r'^```([^\r\n]*)\r?\n([\s\S]*?)\r?\n^```$', multiLine: true);
  static final blockquote = RegExp(r'^(?:\s*>\s?.+(?:\n|$))+', multiLine: true);
  static final table = RegExp(
      r'(^\s*\|.+\|\s*\n\s*\|(?:\s*:?-+:?\s*\|)+\s*\n(?:\s*\|.*\|\s*\n?)+)',
      multiLine: true);
  static final heading = RegExp(r'^#{1,6}\s+.+$', multiLine: true);
  static final bulletList = RegExp(r'^\s*[*\-+]\s+(.+)$', multiLine: true);

  static final inlineCode = RegExp(r'`[^`\r\n]+?`');
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

  static final blockPatterns = {
    'thinking': thinking,
    'horizontalRule': horizontalRule,
    'codeBlock': codeBlock,
    'blockquote': blockquote,
    'table': table,
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
    'link': link,
    'bareUrl': bareUrl,
    'citation': citation,
    'boldItalic': boldItalic,
    'bold': bold,
    'strikethrough': strikethrough,
    'italic': italic,
  };
}
