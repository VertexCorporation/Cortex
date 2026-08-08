import 'package:cortex/chat/screen/widgets/sources.dart';
import 'package:cortex/chat/screen/widgets/bottom/sources.dart';
import 'package:cortex/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'patterns.dart';
import 'utils.dart';
import 'inline.dart';
import 'blocks.dart';

final _checkEmoji = RegExp(r'(?<=\n|^)\s*[✅❌✓✗]\s*(?=\n|$)');
final _newlineGtNewline = RegExp(r'\n>\s*\n');
final _brTag = RegExp(r'<\s*br\s*/?\s*>|<\s*/\s*br\s*>', caseSensitive: false);
final _memoryOpen = RegExp(r'\s*<memory[)>]?[\s\S]*?(?:</memory[)>]?|$)\s*',
    caseSensitive: false);
final _sourceHeader = RegExp(
    r'(?:\n|^)#{1,6}\s*(?:Sources|References|Citations):?\s*$',
    caseSensitive: false,
    multiLine: true);
final _closedThink = RegExp(r'<think>([\s\S]*?)</think>', multiLine: true);
final _unclosedThink = RegExp(r'<think>([\s\S]*)$', multiLine: true);
final _cleanThinkTags = RegExp(r'</?think>', caseSensitive: false);
final _leadingColon = RegExp(r'^[\s:]+');
final _trailingNewlines = RegExp(r'^\n+|\n+$');
final _tableSeparator =
    RegExp(r'^\s*\|(?:\s*:?-+:?\s*\|)+\s*$', multiLine: true);
final _headingPrefix = RegExp(r'^#+\s*');
final _horizontalRule = RegExp(r'^---$', multiLine: true);
final _horizontalRuleAny = RegExp(r'^\s*([*\-_]){3,}\s*$', multiLine: true);
final _markdownItalic = RegExp(r'[*_](.+?)[*_]', dotAll: true);
final _emojiChars = RegExp(r'[✅❌✓✗]');
final _multiSpaces = RegExp(r'[ \t]{2,}', multiLine: true);
final _multiNewlines = RegExp(r'(\s*\n\s*){2,}');
final _blockquotePrefix = RegExp(r'^\s*>\s?');

final _functionTag = RegExp(
    r'\s*<function(?:-call)?[)>]?[\s\S]*?(?:</function(?:-call)?[)>]?|$)\s*',
    caseSensitive: false);

final _widgetBlock = RegExp(
    r'<<<WIDGET:[\s\S]*?<<<END>>>',
    caseSensitive: false);

final _usingToolLine = RegExp(
    r'\n?\*Using [^*]+\.\.\.[^*]*\*\s*[✅❌✓✗]?\s*\n?');

List<InlineSpan> parseText(BuildContext context, String text,
    {double? fontSize, bool isFinished = false, List<dynamic>? citations}) {
  try {
    text = text.replaceAll(_usingToolLine, '');
    text = text.replaceAll(_checkEmoji, '');
    text = text.replaceAll(_newlineGtNewline, '\n');
    text = text.replaceAllMapped(_brTag, (_) => '\n');
    text = text.replaceAll(_widgetBlock, '');
    text = text.replaceAll(_memoryOpen, '');

    text = mergeFragmentedThinkingBlocks(text);
    text = text.replaceAllMapped(_functionTag, (_) => '');
    text = text.replaceAll(_tableSeparator, '');
    text = _stripTrailingHorizontalRule(text);

    List<Source> sources = [];
    final match = _sourceHeader.firstMatch(text);

    if (match != null) {
      int headerStart = match.start;
      String potentialSourceText = text.substring(match.end).trim();

      final sourceLines = potentialSourceText.split('\n');
      bool validSourcesFound = false;
      int indexCounter = 1;

      for (var line in sourceLines) {
        line = line.trim();
        if (line.isEmpty) continue;

        final linkMatch =
            RegExp(r'(?:^\d+\.?\s*|^-\s*)?\[([^\]]+)\]\(([^)]+)\)')
                .firstMatch(line);
        if (linkMatch != null) {
          sources.add(Source(
              index: indexCounter++,
              title: linkMatch.group(1)!,
              url: linkMatch.group(2)!));
          validSourcesFound = true;
          continue;
        }

        final bareUrlMatch =
            RegExp(r'\[(\d+)\]\s*(https?://\S+)').firstMatch(line);
        if (bareUrlMatch != null) {
          sources.add(Source(
              index: int.tryParse(bareUrlMatch.group(1)!) ?? indexCounter++,
              title: "Source ${bareUrlMatch.group(1)}",
              url: bareUrlMatch.group(2)!));
          validSourcesFound = true;
          continue;
        }
      }

      if (validSourcesFound && sources.isNotEmpty) {
        text = text.substring(0, headerStart).trim();
      }
    }

    text = text.trim();

    List<dynamic>? activeCitations = citations;
    if ((activeCitations == null || activeCitations.isEmpty) &&
        sources.isNotEmpty) {
      activeCitations = sources.map((s) => s.url).toList();
    }

    final fs = fontSize ?? baseFs(context);
    final patterns = RegexPatterns.blockPatterns;

    final blockMatches = <MatchRange>[];

    for (final entry in patterns.entries) {
      for (final match in entry.value.allMatches(text)) {
        blockMatches.add(MatchRange(
            start: match.start,
            end: match.end,
            text: match.group(0)!,
            type: entry.key));
      }
    }

    blockMatches.sort((a, b) => a.start - b.start);

    final finalBlockMatches = <MatchRange>[];
    if (blockMatches.isNotEmpty) {
      finalBlockMatches.add(blockMatches.first);
      for (int i = 1; i < blockMatches.length; i++) {
        if (blockMatches[i].start >= finalBlockMatches.last.end) {
          finalBlockMatches.add(blockMatches[i]);
        }
      }
    }

    final urlMap = <String, int>{};
    final inlinePatterns = RegexPatterns.inlinePatterns;

    final spans = <InlineSpan>[];
    int currentIndex = 0;

    for (final blockMatch in finalBlockMatches) {
      if (blockMatch.start > currentIndex) {
        final betweenText = text.substring(currentIndex, blockMatch.start);
        spans.addAll(processInlineElements(
            context, betweenText, inlinePatterns, fs,
            urlMap: urlMap, citations: activeCitations));
      }

      if (blockMatch.type == 'bulletList') {
        final content =
            RegexPatterns.bulletList.firstMatch(blockMatch.text)?.group(1) ??
                '';
        final inlineSpans = processInlineElements(
            context, content, inlinePatterns, fs,
            urlMap: urlMap, citations: activeCitations);

        spans.add(TextSpan(
          text: '•  ',
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: fs,
            height: 1.5,
          ),
        ));
        spans.addAll(inlineSpans);
      } else {
        spans.add(processBlockMatch(context, blockMatch, inlinePatterns, fs,
            isFinished: isFinished,
            urlMap: urlMap,
            citations: activeCitations));
      }

      currentIndex = blockMatch.end;
    }

    if (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);
      spans.addAll(processInlineElements(
          context, remainingText, inlinePatterns, fs,
          urlMap: urlMap, citations: activeCitations));
    }

    if (isFinished && activeCitations != null && activeCitations.isNotEmpty) {
      spans.add(WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: WebSearchSourcesWidget(scale: 1.0, sources: activeCitations),
        ),
      ));
    }

    return spans;
  } catch (e, s) {
    if (kDebugMode) {
      print('parseText unexpected error: $e\n$s');
    }
    return [
      TextSpan(
          text: text,
          style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: baseFs(context)))
    ];
  }
}

String mergeFragmentedThinkingBlocks(String text) {
  final closedMatches = _closedThink.allMatches(text).toList();
  if (closedMatches.isEmpty) {
    final unclosedMatch = _unclosedThink.firstMatch(text);
    if (unclosedMatch == null) return text;
    final content = unclosedMatch.group(1)?.trim() ?? '';
    if (content.isEmpty) return text;
    final cleaned = content.replaceAll(_cleanThinkTags, '');
    final cleanedText = text.replaceFirst(_unclosedThink, '');
    return '<think>$cleaned\n$cleanedText';
  }

  final buf = StringBuffer();
  bool hasUnclosed = false;
  int lastEnd = 0;

  for (final match in closedMatches) {
    final content = match.group(1)?.trim() ?? '';
    final cleaned = content.replaceAll(_cleanThinkTags, '');
    if (cleaned.isNotEmpty) {
      buf.write(cleaned);
      buf.write('\n\n');
    }
    lastEnd = match.end;
  }

  String remaining = text.substring(lastEnd);
  final unclosedMatch = _unclosedThink.firstMatch(remaining);
  if (unclosedMatch != null) {
    final content = unclosedMatch.group(1)?.trim() ?? '';
    if (content.isNotEmpty) {
      final cleaned = content.replaceAll(_cleanThinkTags, '');
      buf.write(cleaned);
      hasUnclosed = true;
    }
    remaining = remaining.replaceFirst(_unclosedThink, '');
  }

  final merged = buf.toString().trim();
  if (merged.isEmpty) return text;

  remaining = remaining.replaceFirst(_leadingColon, '');
  remaining = remaining.trim();
  remaining = remaining.replaceFirst(_trailingNewlines, '');

  final tag = hasUnclosed ? '<think>$merged' : '<think>$merged</think>';
  final sep = remaining.isNotEmpty ? '\n' : '';
  return '$tag$sep$remaining';
}

String stripMarkup(String text) {
  text = text.replaceAll(_widgetBlock, '');
  text = text.replaceAllMapped(RegexPatterns.codeBlock, (m) => '\n');
  text = text.replaceAll(_tableSeparator, '');
  text = text.replaceAll('|', '  ');
  text = text.replaceAllMapped(RegexPatterns.heading,
      (m) => '${m.group(0)!.replaceFirst(_headingPrefix, "")}\n');
  text =
      text.replaceAllMapped(RegexPatterns.bulletList, (m) => '${m.group(1)}\n');
  text = text.replaceAllMapped(RegexPatterns.blockquote,
      (m) => '${_stripBlockquotePrefix(m.group(0) ?? '')}\n');
  text = text.replaceAll(_horizontalRule, '');
  text = text.replaceAll(_horizontalRuleAny, '');

  text = text.replaceAllMapped(RegexPatterns.link, (m) => m.group(1) ?? '');
  text =
      text.replaceAllMapped(RegexPatterns.boldItalic, (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(RegexPatterns.bold, (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(_markdownItalic, (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(
      RegexPatterns.strikethrough, (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(
      RegexPatterns.inlineCode, (m) => m.group(0)!.replaceAll('`', ''));

  text = text.replaceAll(RegexPatterns.thinking, '');
  text = text.replaceAll(_usingToolLine, '');
  text = text.replaceAll(_emojiChars, '');
  text = text.replaceAll(_multiSpaces, ' ');
  text = text.replaceAll(_multiNewlines, '\n\n');

  return text.trim();
}

String _stripBlockquotePrefix(String text) {
  return text
      .trimRight()
      .split('\n')
      .map((line) => line.replaceFirst(_blockquotePrefix, ''))
      .join('\n');
}

String _stripTrailingHorizontalRule(String text) {
  final m = RegExp(r'(?:^|\n)[ \t]*([*\-_]){3,}[ \t]*$').firstMatch(text);
  if (m != null) {
    return text.substring(0, m.start).trimRight();
  }
  return text;
}
