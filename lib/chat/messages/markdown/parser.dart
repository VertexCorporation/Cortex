import 'package:cortex/chat/screen/widgets/sources.dart';
import 'package:cortex/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/chat/screen/widgets/bottom/sources.dart';
import 'patterns.dart';
import 'utils.dart';
import 'inline.dart';
import 'blocks.dart';

List<InlineSpan> parseText(BuildContext context, String text,
    {double? fontSize, bool isFinished = false, List<dynamic>? citations}) {
  try {
    text = text.replaceAll(RegexPatterns.usingToolLine, '');
    text = text.replaceAll(RegExp(r'(?<=\n|^)\s*[✅❌✓✗]\s*(?=\n|$)'), '');
    text = text.replaceAll(RegExp(r'\n>\s*\n'), '\n');

    text = text.replaceAll(RegExp(r'\n{2,}(?=<<<WIDGET)'), '\n');
    text = text.replaceAll(RegExp(r'(?<=<<<END>>>)\n{2,}'), '\n');

    text = mergeFragmentedThinkingBlocks(text);

    text = text.replaceAll(
        RegExp(r'\s*<memory[)>]?[\s\S]*?(?:</memory[)>]?|$)\s*', caseSensitive: false),
        '');
    text = text.replaceAll(
        RegExp(r'\s*<m(?:e(?:m(?:o(?:r(?:y(?:[)>][\s\S]*)?)?)?)?)?)?$',
            caseSensitive: false),
        '');

    List<Source> sources = [];
    final sourceHeaderRegex = RegExp(
        r'(?:\n|^)#{1,6}\s*(?:Sources|References|Citations):?\s*$',
        caseSensitive: false,
        multiLine: true);
    final match = sourceHeaderRegex.firstMatch(text);

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

    patterns.forEach((type, pattern) {
      for (final match in pattern.allMatches(text)) {
        blockMatches.add(MatchRange(
            start: match.start,
            end: match.end,
            text: match.group(0)!,
            type: type));
      }
    });

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
        final bulletMatch = RegExp(r'^\s*[*\-+]\s+(.+)$', multiLine: true)
            .firstMatch(blockMatch.text);
        final content = bulletMatch?.group(1) ?? '';
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
  final closedThinkPattern =
      RegExp(r'<think>([\s\S]*?)</think>', multiLine: true);
  final closedMatches = closedThinkPattern.allMatches(text).toList();

  final unclosedThinkPattern = RegExp(r'<think>([\s\S]*)$', multiLine: true);
  String? unclosedContent;
  bool hasUnclosedBlock = false;

  String textWithoutClosed = text.replaceAll(closedThinkPattern, '');
  final unclosedMatch = unclosedThinkPattern.firstMatch(textWithoutClosed);
  if (unclosedMatch != null) {
    unclosedContent = unclosedMatch.group(1)?.trim();
    hasUnclosedBlock = unclosedContent?.isNotEmpty ?? false;
  }

  if (closedMatches.isEmpty && !hasUnclosedBlock) {
    return text;
  }

  final List<String> thinkingContents = [];

  String cleanNestedThinkTags(String content) {
    return content.replaceAll(RegExp(r'</?think>', caseSensitive: false), '');
  }

  for (final match in closedMatches) {
    var content = match.group(1)?.trim() ?? '';
    content = cleanNestedThinkTags(content);
    if (content.isNotEmpty) {
      thinkingContents.add(content);
    }
  }

  if (hasUnclosedBlock &&
      unclosedContent != null &&
      unclosedContent.isNotEmpty) {
    unclosedContent = cleanNestedThinkTags(unclosedContent);
    thinkingContents.add(unclosedContent);
  }

  if (thinkingContents.isEmpty) {
    return text;
  }

  String cleanedText = text;
  cleanedText = cleanedText.replaceAll(closedThinkPattern, '');
  cleanedText = cleanedText.replaceAll(unclosedThinkPattern, '');

  final mergedThinking = thinkingContents.join('\n\n');

  final thinkTag = hasUnclosedBlock
      ? '<think>$mergedThinking'
      : '<think>$mergedThinking</think>';

  cleanedText = cleanedText.trim();
  cleanedText = cleanedText.replaceAll(RegExp(r'^\n+|\n+$'), '');

  final separator = cleanedText.isNotEmpty ? '\n' : '';

  return '$thinkTag$separator$cleanedText';
}

String stripMarkup(String text) {
  text = text.replaceAll(RegexPatterns.widget, '');
  text = text.replaceAllMapped(RegexPatterns.codeBlock, (m) => '\n');
  text = text.replaceAll(
      RegExp(r'^\s*\|(?:\s*:?-+:?\s*\|)+\s*$', multiLine: true), '');
  text = text.replaceAll('|', '  ');
  text = text.replaceAllMapped(RegexPatterns.heading,
      (m) => '${m.group(0)!.replaceFirst(RegExp(r"^#+\s*"), "")}\n');
  text =
      text.replaceAllMapped(RegexPatterns.bulletList, (m) => '${m.group(1)}\n');
  text = text.replaceAll(RegExp(r'^---$', multiLine: true), '');

  text = text.replaceAll(RegExp(r'(\$\$|\\\[|\\\]|\\\(|\\\))'), '');
  text = text.replaceAll(r'$', '');

  text = text.replaceAllMapped(RegExp(r'\\text\{(.+?)\}'), (m) => m.group(1)!);

  text = text.replaceAllMapped(RegExp(r'\\frac\{(.+?)\}\{(.+?)\}'),
      (m) => '(${m.group(1)}/${m.group(2)})');
  text = text.replaceAllMapped(RegExp(r'\\sqrt\[(.+?)\]\{(.+?)\}'),
      (m) => '(${m.group(1)})√(${m.group(2)})');
  text = text.replaceAllMapped(
      RegExp(r'\\sqrt\{(.+?)\}'), (m) => '√(${m.group(1)})');

  text = text.replaceAllMapped(
      RegExp(r'\\(mathbf|mathbb|mathcal)\{(.+?)\}'), (m) => m.group(2)!);

  text = text.replaceAll(RegExp(r'[{}]'), '');
  text =
      text.replaceAll(RegExp(r'\\([a-zA-Z]+)'), '');

  text = text.replaceAllMapped(RegexPatterns.link, (m) => m.group(1) ?? '');
  text =
      text.replaceAllMapped(RegexPatterns.boldItalic, (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(RegexPatterns.bold, (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(RegExp(r'[*_](.+?)[*_]', dotAll: true),
      (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(
      RegexPatterns.strikethrough, (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(
      RegexPatterns.inlineCode, (m) => m.group(0)!.replaceAll('`', ''));

  text = text.replaceAll(RegexPatterns.thinking, '');
  text = text.replaceAll(RegexPatterns.usingToolLine, '');
  text = text.replaceAll(RegExp(r'[✅❌✓✗]'), '');
  text = text.replaceAll(RegExp(r'[ \t]{2,}', multiLine: true), ' ');
  text = text.replaceAll(RegExp(r'(\s*\n\s*){2,}'), '\n\n');

  return text.trim();
}
