// ================ lib/chat/messages/parser.dart ================

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../notifications/introvert.dart';
import '../../theme.dart';
import 'codeblocks.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../screen/widgets/tools.dart';
import '../screen/widgets/thinking.dart';
import '../screen/widgets/sources.dart';
import '../screen/widgets/bottom/sources.dart';

double _baseFs(BuildContext context) {
  final view = View.of(context);
  final physicalWidth = view.physicalSize.width;
  final devicePixelRatio = view.devicePixelRatio;
  return (physicalWidth / devicePixelRatio) * 0.042;
}

class SafeMathTex extends StatelessWidget {
  final String latex;
  final TextStyle textStyle;

  const SafeMathTex({required this.latex, required this.textStyle, super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          latex,
          textStyle: textStyle,
          onErrorFallback: (_) => Text(latex, style: textStyle),
        ),
      );
    } catch (_) {
      return Text(latex, style: textStyle);
    }
  }
}

void openLink(BuildContext context, String urlString) async {
  final uri = Uri.tryParse(urlString);
  if (uri == null) return;
  final l10n = AppLocalizations.of(context)!;

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        width: 1.0,
      ),
    ),
    builder: (BuildContext sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  // Changed to world.svg
                  'assets/icons/world.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted, BlendMode.srcIn),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.openLinkWarningTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor.inverted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.openLinkWarningMessage(urlString),
              style: TextStyle(
                fontSize: 14,
                color: AppColors
                    .primaryColor.inverted, // Changed to inverted per request
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(
                    l10n.openLinkCancel,
                    style: TextStyle(
                        color: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor.inverted,
                    foregroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    final success = await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                    if (!success && context.mounted) {
                      Provider.of<IntrovertNotificationService>(context,
                          listen: false)
                          .showNotification(
                        message: AppLocalizations.of(context)!.anErrorOccurred,
                        type: NotificationType.success,
                        bottomOffset: 0.22,
                      );
                    }
                  },
                  child: Text(l10n.openLinkConfirm),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// Static RegExp constants to avoid recompilation
class RegexPatterns {
  // Greedy matching for <think> tags - supports BOTH closed and unclosed (streaming) tags
  // For streaming: matches <think> followed by content until </think> OR end of string
  static final thinking =
  RegExp(r'(<think>[\s\S]*?(?:</think>|$))', multiLine: false);

  // Greedy matching for <memory> tags - supports BOTH closed and unclosed (streaming) tags
  static final memory =
  RegExp(r'(<memory>[\s\S]*?(?:</memory>|$))', multiLine: false);

  // Legacy matching for "Thinking..." headers - scattered/broken format from streaming
  // This pattern captures the quote-style thinking blocks that some models produce:
  // > *Thinking...*
  // > The user asks...
  // etc.
  static final thinkingLegacy = RegExp(
      r'(?:^|\n)\s*>\s*\*?Thinking[.\s]*\*?\s*\n?(?:\s*>[ \t]*[^\n]*\n?)*',
      multiLine: true);

  static final horizontalRule =
  RegExp(r'^\s*([*\-_]){3,}\s*$', multiLine: true);
  static final codeBlock =
  RegExp(r'^```([^\r\n]*)\r?\n([\s\S]*?)\r?\n^```$', multiLine: true);
  static final legacyUsing =
  RegExp(r'^\s*\*Using (.+?)\.\.\.\*.*$', multiLine: true);
  static final table = RegExp(
      r'(^\s*\|.+\|\s*\n\s*\|(?:\s*:?-+:?\s*\|)+\s*\n(?:\s*\|.*\|\s*\n?)+)',
      multiLine: true);
  static final widget = RegExp(
      r'<<<WIDGET:([a-zA-Z0-9_]+)>>>([\s\S]*?)<<<END>>>',
      multiLine: true);
  static final heading = RegExp(r'^#{1,6} .+?$', multiLine: true);
  static final bulletList = RegExp(r'^\s*[*\-+]\s+(.+)$', multiLine: true);

  static final inlineCode = RegExp(r'`[^`\r\n]+?`');
  static final latex = RegExp(
      r'(\$\$[\s\S]+?\$\$|\\\[[\s\S]+?\\\]|\\begin\{.+?\}[\s\S]+?\\end\{.+?\}|\\\(.+?\\\)|(?<!\$)\$[^$\r\n]+?\$(?!\$))');
  static final link = RegExp(r'\(?\s*\[([^\]]+)\]\(([^)]+)\)\s*\)?');

  // [NEW] Bare URL pattern: Matches http/https not preceded by ]( or (
  static final bareUrl = RegExp(r'(?<![\])])\b(https?://[^\s<]+)');

  // [NEW] Citation pattern: [1], [2], etc.
  static final citation = RegExp(r'\[\s*(\d+)\s*\]|【\s*(.*?)\s*】');

  static final boldItalic =
  RegExp(r'(\*\*\*.+?\*\*\*|___.+?___)', dotAll: true);
  static final bold = RegExp(r'(\*\*.+?\*\*|__.+?__)', dotAll: true);
  static final strikethrough = RegExp(r'~~.+?~~', dotAll: true);
  static final italic =
  RegExp(r'(?<![*$])\*(?!\*).+?(?<!\*)\*(?![*$])', dotAll: true);
  static final thinkStart = RegExp(r'<think>\s*');
  static final thinkEnd = RegExp(r'\s*</think>');

  // Pattern to match tool result emojis that should be hidden from display
  static final toolResultEmoji = RegExp(r'\s*[✅❌✓✗]\s*');

  // Pattern to match "*Using tool...*" lines completely
  static final usingToolLine =
  RegExp(r'\n?\*Using [^*]+\.\.\.[^*]*\*\s*[✅❌✓✗]?\s*\n?');

  static final blockPatterns = {
    'memory': memory,
    'thinking': thinking,
    'thinkingLegacy': thinkingLegacy,
    'horizontalRule': horizontalRule,
    'codeBlock': codeBlock,
    'legacyUsing': legacyUsing,
    'table': table,
    'widget': widget,
    'heading': heading,
    'bulletList': bulletList,
  };

  static final combinedInlinePattern = RegExp(
      inlinePatterns.entries.map((e) => '(?<${e.key}>${e.value.pattern})').join(
          '|'),
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

List<InlineSpan> parseText(BuildContext context, String text,
    {double? fontSize, bool isFinished = false, List<dynamic>? citations}) {
  try {
    // [FIX] Pre-clean text to remove artifacts
    // Remove "*Using tool...*" lines with optional emojis
    text = text.replaceAll(RegexPatterns.usingToolLine, '');
    // Remove standalone tool result emojis
    text = text.replaceAll(RegExp(r'(?<=\n|^)\s*[✅❌✓✗]\s*(?=\n|$)'), '');
    text = text.replaceAll(RegExp(r'\n>\s*\n'), '\n');

    // Clean up excessive whitespace around widgets
    text = text.replaceAll(RegExp(r'\n{2,}(?=<<<WIDGET)'), '\n');
    text = text.replaceAll(RegExp(r'(?<=<<<END>>>)\n{2,}'), '\n');

    // [FIX] Merge consecutive/fragmented thinking blocks
    // Sometimes streaming produces: <think>A</think>X<think>B</think>
    // where X is a small fragment that should be part of thinking
    // Merge them into a single <think>A X B</think> block
    text = _mergeFragmentedThinkingBlocks(text);

    // Strip memory blocks completely including prefix/suffix whitespace to avoid empty trailing space in UI
    text = text.replaceAll(
        RegExp(r'\s*<memory>[\s\S]*?(?:</memory>|$)\s*', caseSensitive: false),
        '');
    // Also catch incomplete streaming variants at the very tail end to prevent newline/char popping
    text = text.replaceAll(RegExp(
        r'\s*<m(?:e(?:m(?:o(?:r(?:y(?:>[\s\S]*)?)?)?)?)?)?$',
        caseSensitive: false), '');

    // Link pre-processing has been removed. Markdown links are rendered directly.

    // --- Source Extraction Logic ---
    // Detect "Sources:" at the end of the text and extract them
    List<Source> sources = [];
    final sourceHeaderRegex = RegExp(
        r'(?:\n|^)#{1,6}\s*(?:Sources|References|Citations):?\s*$',
        caseSensitive: false,
        multiLine: true);
    final match = sourceHeaderRegex.firstMatch(text);

    if (match != null) {
      int headerStart = match.start;
      String potentialSourceText = text.substring(match.end).trim();

      // Try to parse line-by-line using common formats: "1. [Title](url)" or "- [Title](url)"
      final sourceLines = potentialSourceText.split('\n');
      bool validSourcesFound = false;
      int indexCounter = 1;

      for (var line in sourceLines) {
        line = line.trim();
        if (line.isEmpty) continue;

        // Regex for: 1. [Title](Url) or - [Title](Url) or [1] Title: Url
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

        // Regex for: [1] http://...
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

      // If we successfully parsed sources, truncate the text to remove the raw list
      if (validSourcesFound && sources.isNotEmpty) {
        text = text.substring(0, headerStart).trim();
      }
    }

    text = text.trim();

    // Use locally parsed markdown sources if the stream didn't provide citations
    List<dynamic>? activeCitations = citations;
    if ((activeCitations == null || activeCitations.isEmpty) &&
        sources.isNotEmpty) {
      activeCitations = sources.map((s) => s.url).toList();
    }

    final fs = fontSize ?? _baseFs(context);
    final patterns = RegexPatterns.blockPatterns;

    final blockMatches = <_MatchRange>[];

    patterns.forEach((type, pattern) {
      for (final match in pattern.allMatches(text)) {
        blockMatches.add(_MatchRange(
            start: match.start,
            end: match.end,
            text: match.group(0)!,
            type: type));
      }
    });

    blockMatches.sort((a, b) => a.start - b.start);

    final finalBlockMatches = <_MatchRange>[];
    if (blockMatches.isNotEmpty) {
      finalBlockMatches.add(blockMatches.first);
      for (int i = 1; i < blockMatches.length; i++) {
        if (blockMatches[i].start >= finalBlockMatches.last.end) {
          finalBlockMatches.add(blockMatches[i]);
        }
      }
    }

    final urlMap = <String, int>{}; // Inject tracking map
    final inlinePatterns = RegexPatterns.inlinePatterns;

    final spans = <InlineSpan>[];
    int currentIndex = 0;

    for (final blockMatch in finalBlockMatches) {
      if (blockMatch.start > currentIndex) {
        final betweenText = text.substring(currentIndex, blockMatch.start);
        spans.addAll(_processInlineElements(
            context, betweenText, inlinePatterns, fs,
            urlMap: urlMap, citations: activeCitations));
      }

      if (blockMatch.type == 'bulletList') {
        final bulletMatch = RegExp(r'^\s*[*\-+]\s+(.+)$', multiLine: true)
            .firstMatch(blockMatch.text);
        final content = bulletMatch?.group(1) ?? '';
        final inlineSpans = _processInlineElements(
            context, content, inlinePatterns, fs,
            urlMap: urlMap, citations: activeCitations);
        spans.add(WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ',
                      style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: fs)),
                  Expanded(
                      child: RichText(text: TextSpan(children: inlineSpans))),
                ],
              ),
            )));
      } else {
        spans.add(_processBlockMatch(context, blockMatch, inlinePatterns, fs,
            isFinished: isFinished,
            urlMap: urlMap,
            citations: activeCitations));
      }

      currentIndex = blockMatch.end;
    }

    if (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);
      spans.addAll(_processInlineElements(
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
              fontSize: _baseFs(context)))
    ];
  }
}

List<InlineSpan> _processInlineElements(BuildContext context, String text,
    Map<String, RegExp> patterns, double fs,
    {Map<String, int>? urlMap, List<dynamic>? citations}) {
  if (text.isEmpty) {
    return [];
  }

  final spans = <InlineSpan>[];
  int currentIndex = 0;

  for (final match in RegexPatterns.combinedInlinePattern.allMatches(text)) {
    if (match.start > currentIndex) {
      spans.add(TextSpan(
        text: text.substring(currentIndex, match.start),
        style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: fs),
      ));
    }

    String? matchType;
    for (final key in patterns.keys) {
      if (match.namedGroup(key) != null) {
        matchType = key;
        break;
      }
    }

    if (matchType != null) {
      final inlineMatch = _MatchRange(
          start: match.start,
          end: match.end,
          text: match.group(0)!,
          type: matchType);
      spans.add(_processInlineMatch(context, inlineMatch, patterns, fs,
          urlMap: urlMap, citations: citations));
    }
    currentIndex = match.end;
  }

  if (currentIndex < text.length) {
    spans.add(TextSpan(
      text: text.substring(currentIndex),
      style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: fs),
    ));
  }
  return spans;
}

InlineSpan _processBlockMatch(BuildContext context, _MatchRange match,
    Map<String, RegExp> inlinePatterns, double fs,
    {bool isFinished = false,
      Map<String, int>? urlMap,
      List<dynamic>? citations}) {
  try {
    final matchText = match.text;
    switch (match.type) {
      case 'memory':
      // Hide memory blocks completely from the UI
        return const WidgetSpan(child: SizedBox.shrink());
      case 'thinkingLegacy':
      case 'thinking':
        String content = matchText;

        // Detect if this is an unclosed/streaming think block
        // The thinking is "finished" when we have a closing tag, regardless of message state
        final bool hasCloseTag = matchText.contains('</think>');
        // isThinkingFinished: true if the block is closed OR the entire message is finished
        final bool isThinkingFinished = hasCloseTag || isFinished;

        // 1. Remove <think> tags wrapper (outer tags only)
        content =
            content.replaceAll(RegExp(r'(^<think>\s*)|(\s*</think>$)'), '');

        // 2. CRITICAL: Remove ALL nested <think> tags inside the content
        // This happens when offline models produce their own thinking format
        // e.g., "<think>Okay...<think>I need to...</think>...</think>"
        // or when the model outputs "<think>" as plain text in its reasoning
        content =
            content.replaceAll(RegExp(r'</?think>', caseSensitive: false), '');

        // 3. Aggressively clean up ANY repetitive headers or quote markers
        // We use the verified regex logic from tests.

        // Remove "Scattered Thinking" lines and merge broken words
        // Eats preceding/following newlines to merge words, eats > marker, eats ONE space (quote sep).
        content = content.replaceAll(
            RegExp(r'(?:^|[\r\n]+)[ \t]*>?\s*\*Thinking\.\.\.\*[\r\n]*>?[ \t]?',
                caseSensitive: false),
            '');

        // Remove leading/hanging "> " artifacts from scattered streams
        content = content.replaceAll(RegExp(r'(?<=^|\n)>\s?'), '');

        // Remove standard "Thinking..." header that might be left at the start
        content = content.replaceAll(
            RegExp(r'^[*]*Thinking[.*]*\s*', caseSensitive: false), '');

        // [ADDED] Remove specific "Thinking..." artifacts that might adhere to words
        // e.g. "JanuaryThinking... 25" -> "January 25"
        content = content.replaceAll(
            RegExp(r'\*?Thinking\.\.\.\*?', caseSensitive: false), '');

        // [FIX] Merge scattered/fragmented text:
        // When streaming produces word-by-word on separate lines, merge them.
        // This handles patterns like:
        // "The\n user\n asks" -> "The user asks"
        // Preserve double newlines as paragraph breaks
        content = content.replaceAll(
            RegExp(r'\n{3,}'), '\n\n'); // Normalize multiple newlines
        content = content.replaceAll(
            RegExp(r'(?<!\n)\n(?!\n)'), ' '); // Single newline -> space
        content = content.replaceAll(
            RegExp(r' {2,}'), ' '); // Normalize multiple spaces

        content = content.trim();

        // Use a stable key so the widget state persists across content updates
        // The key is constant so the same widget instance is reused
        const widgetKey = ValueKey('thinking_block_main');

        if (content.isEmpty) {
          // If empty (e.g. just started thinking), show empty widget with active state
          return WidgetSpan(
            child: ThinkingWidget(
              key: widgetKey,
              content: "",
              isFinished: isThinkingFinished,
            ),
          );
        }

        return WidgetSpan(
          child: ThinkingWidget(
            key: widgetKey,
            content: content,
            isFinished: isThinkingFinished,
          ),
        );
      case 'horizontalRule':
// ...
        return WidgetSpan(
            child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Divider(color: AppColors.border, thickness: 1)));
      case 'widget':
        try {
          // Format is <<<WIDGET:type>>>{json}<<<END>>>
          // The regex capture groups are: 1=type, 2=json
          // We need to re-match here because blockMatch.group(1) isn't directly available in _MatchRange structure easily without re-parsing or storing it.
          // But wait, the block match text is the WHOLE string.
          final widgetMatch = RegExp(
              r'<<<WIDGET:([a-zA-Z0-9_]+)>>>([\s\S]*?)<<<END>>>',
              multiLine: true)
              .firstMatch(matchText);
          if (widgetMatch != null) {
            final type = widgetMatch.group(1)!;
            final jsonStr = widgetMatch.group(2)!;
            final data = jsonDecode(jsonStr) as Map<String, dynamic>;
            return WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ToolWidgetFactory.build(type, data),
              ),
            );
          }
          return TextSpan(
              text: matchText,
              style: TextStyle(
                  color: AppColors.primaryColor.inverted, fontSize: fs));
        } catch (e) {
          return TextSpan(
              text: "Error loading widget: $e",
              style: TextStyle(color: Colors.red, fontSize: fs));
        }
      case 'legacyUsing':
      // User requested to REMOVE legacy tool calling text completely.
        return const WidgetSpan(child: SizedBox.shrink());
      case 'codeBlock':
        final codeMatch = RegExp(r'^(```+)([^\r\n]*)\r?\n([\s\S]*?)\r?\n^\1$',
            multiLine: true)
            .firstMatch(matchText);
        if (codeMatch != null) {
          final language = codeMatch.group(2)?.trim() ?? '';
          final content = codeMatch.group(3)?.trim() ?? '';
          return WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CodeBlockWidget(
                    code: content,
                    language: language.isEmpty ? null : language),
              ));
        }
        return TextSpan(
            text: matchText,
            style: TextStyle(
                color: AppColors.primaryColor.inverted, fontSize: fs));
      case 'table':
        final lines = matchText.trim().split('\n');
        if (lines.length < 2) {
          return TextSpan(
              text: matchText,
              style: TextStyle(
                  color: AppColors.primaryColor.inverted, fontSize: fs));
        }
        List<String> splitRow(String row) {
          var trimmedRow = row.trim();
          if (trimmedRow.startsWith('|')) {
            trimmedRow = trimmedRow.substring(1);
          }
          if (trimmedRow.endsWith('|')) {
            trimmedRow = trimmedRow.substring(0, trimmedRow.length - 1);
          }
          return trimmedRow.split('|').map((s) => s.trim()).toList();
        }
        final headerCells = splitRow(lines[0]);
        if (headerCells.isEmpty) {
          return TextSpan(
              text: matchText,
              style: TextStyle(
                  color: AppColors.primaryColor.inverted, fontSize: fs));
        }
        final colCount = headerCells.length;
        final List<TableRow> tableRows = [];
        Widget buildCell(String text, {bool isHeader = false}) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: RichText(
              text: TextSpan(
                children: _processInlineElements(
                    context, text, inlinePatterns, fs,
                    citations: citations),
                style: TextStyle(
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.primaryColor.inverted),
              ),
            ),
          );
        }
        tableRows.add(TableRow(
            children: headerCells
                .map((cell) => buildCell(cell, isHeader: true))
                .toList()));
        if (lines.length > 2) {
          for (final rowString in lines.sublist(2)) {
            if (rowString
                .trim()
                .isEmpty) {
              continue;
            }
            final rowCells = splitRow(rowString);
            final paddedCells = List<String>.from(rowCells);
            while (paddedCells.length < colCount) {
              paddedCells.add('');
            }
            tableRows.add(TableRow(
                children: paddedCells
                    .take(colCount)
                    .map((cell) => buildCell(cell))
                    .toList()));
          }
        }
        if (tableRows.isEmpty) {
          return TextSpan(
              text: matchText,
              style: TextStyle(
                  color: AppColors.primaryColor.inverted, fontSize: fs));
        }
        return WidgetSpan(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(color: AppColors.border),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: tableRows,
                  ),
                )));
      case 'heading':
        final level = matchText.indexOf(' ');
        if (level > 0 && level <= 6) {
          final content = matchText.substring(level + 1);
          final headingSize = fs * (1 + (6 - level) * 0.15);
          return TextSpan(
              text: '$content\n',
              style: TextStyle(
                  color: AppColors.primaryColor.inverted,
                  fontSize: headingSize,
                  fontWeight: FontWeight.bold));
        }
        return TextSpan(
            text: matchText,
            style: TextStyle(
                color: AppColors.primaryColor.inverted, fontSize: fs));
      default:
        return TextSpan(
            text: matchText,
            style: TextStyle(
                color: AppColors.primaryColor.inverted, fontSize: fs));
    }
  } catch (e, s) {
    if (kDebugMode) {
      print('Error processing block match: ${match.text}, Error: $e\n$s');
    }
    return TextSpan(
        text: match.text,
        style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: fs));
  }
}

InlineSpan _processInlineMatch(BuildContext context, _MatchRange match,
    Map<String, RegExp> inlinePatterns, double fs,
    {Map<String, int>? urlMap, List<dynamic>? citations}) {
  try {
    final matchText = match.text;
    final baseStyle = TextStyle(
      color: AppColors.primaryColor.inverted,
      fontSize: fs,
    );
    switch (match.type) {
      case 'latex':
        String content = matchText;
        if (content.startsWith(r'$$') && content.endsWith(r'$$')) {
          content = content.substring(2, content.length - 2);
        } else if (content.startsWith(r'\[') && content.endsWith(r'\]')) {
          content = content.substring(2, content.length - 2);
        } else if (content.startsWith(r'\(') && content.endsWith(r'\)')) {
          content = content.substring(2, content.length - 2);
        } else if (content.startsWith(r'$') && content.endsWith(r'$')) {
          content = content.substring(1, content.length - 1);
        }
        return WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SafeMathTex(latex: content, textStyle: baseStyle));
      case 'inlineCode':
        final content = matchText.substring(1, matchText.length - 1);
        return WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(4)),
                child: Text(content,
                    style: baseStyle.copyWith(
                        fontSize: fs * 0.9, fontFamily: 'monospace'))));
      case 'link':
        final m = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').firstMatch(matchText);
        if (m == null) return TextSpan(text: matchText, style: baseStyle);

        final title = m.group(1)!;
        final url = m.group(2)!;

        int urlIndex = 0;
        if (urlMap != null) {
          if (!urlMap.containsKey(url)) {
            urlMap[url] = urlMap.length + 1;
          }
          urlIndex = urlMap[url]!;
        }

        String displayTitle = title;
        if (displayTitle.length > 30) {
          try {
            displayTitle = Uri
                .parse(url)
                .host
                .replaceAll('www.', '');
          } catch (_) {}
        }

        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () => openLink(context, url),
            child: Padding(
              padding:
              const EdgeInsets.only(left: 4.0, right: 2.0, bottom: 2.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.quaternaryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.primaryColor.inverted, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (urlIndex > 0) ...[
                      Text(
                        urlIndex.toString(),
                        style: TextStyle(
                          fontSize: fs * 0.70,
                          color: AppColors.primaryColor.inverted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        displayTitle,
                        style: TextStyle(
                          fontSize: fs * 0.70,
                          color: AppColors.primaryColor.inverted
                              .withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case 'bareUrl':
      // matchText is the URL itself (mostly)
      // Regex group 1 is the url.
      // Actually our regex is: r'(?<![\]\)])\b(https?:\/\/[^\s<]+)'
      // so group 1 is the url.
      // But matchText comes from match.group(0), so we might need to re-extract or just use matchText if valid.
        final url = matchText.trim();
        return WidgetSpan(
            child: GestureDetector(
                onTap: () => openLink(context, url),
                child: Text(url,
                    style: baseStyle.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline))));
      case 'citation':
        final citationIndexStr = matchText.replaceAll(
            RegExp(r'[\[\]【】\s]'), '');
        final citationIndex = int.tryParse(citationIndexStr) ?? 0;

        String? citationUrl;
        if (citations != null) {
          if (citationIndex > 0 && citationIndex <= citations.length) {
            final source = citations[citationIndex - 1];
            if (source is String) {
              citationUrl = source;
            } else if (source is Map && source['url'] != null) {
              citationUrl = source['url'].toString();
            } else if (source is Map && source['link'] != null) {
              citationUrl = source['link'].toString();
            } else {
              try {
                citationUrl = (source as dynamic).url;
              } catch (e) {
                /*empty catch block preventer*/
              }
            }
          } else if (citationIndexStr.isNotEmpty && citationIndex == 0) {
            for (final source in citations) {
              String url = '';
              if (source is String) {
                url = source;
              } else if (source is Map) {
                url = source['url']?.toString() ??
                    source['link']?.toString() ??
                    '';
              } else {
                try {
                  url = (source as dynamic).url;
                } catch (e) {
                  /*empty catch block preventer*/
                }
              }

              if (url.contains(citationIndexStr)) {
                citationUrl = url;
                break;
              }
            }
            if (citationUrl == null && citationIndexStr.contains('.')) {
              citationUrl = citationIndexStr.startsWith('http')
                  ? citationIndexStr
                  : 'https://$citationIndexStr';
            }
          }
        }

        String displayIndex =
        citationIndex > 0 ? citationIndex.toString() : '*';

        Widget childWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: citationUrl != null
                ? AppColors.quaternaryColor
                : AppColors.secondaryColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color: citationUrl != null
                    ? AppColors.primaryColor.inverted.withValues(alpha: 0.3)
                    : AppColors.border.withValues(alpha: 0.5),
                width: 0.5),
          ),
          child: Text(
            displayIndex,
            style: TextStyle(
              fontSize: fs * 0.7,
              color: citationUrl != null
                  ? AppColors.primaryColor.inverted
                  : AppColors.primaryColor.inverted.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        if (citationUrl != null) {
          childWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              openLink(context, citationUrl!);
            },
            child: MouseRegion(
                cursor: SystemMouseCursors.click, child: childWidget),
          );
        }

        return WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Padding(
            padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 4.0),
            child: childWidget,
          ),
        );

      case 'boldItalic':
        final content = matchText.substring(3, matchText.length - 3);
        return TextSpan(
            children: _processInlineElements(
                context, content, inlinePatterns, fs,
                urlMap: urlMap, citations: citations),
            style: baseStyle.copyWith(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic));
      case 'bold':
        final content = matchText.substring(2, matchText.length - 2);
        return TextSpan(
            children: _processInlineElements(
                context, content, inlinePatterns, fs,
                urlMap: urlMap, citations: citations),
            style: baseStyle.copyWith(fontWeight: FontWeight.bold));
      case 'italic':
        final content = matchText.substring(1, matchText.length - 1);
        return TextSpan(
            children: _processInlineElements(
                context, content, inlinePatterns, fs,
                urlMap: urlMap, citations: citations),
            style: baseStyle.copyWith(fontStyle: FontStyle.italic));
      case 'strikethrough':
        final content = matchText.substring(2, matchText.length - 2);
        return TextSpan(
            children: _processInlineElements(
                context, content, inlinePatterns, fs,
                urlMap: urlMap, citations: citations),
            style: baseStyle.copyWith(decoration: TextDecoration.lineThrough));
      default:
        return TextSpan(text: matchText, style: baseStyle);
    }
  } catch (e, s) {
    if (kDebugMode) {
      print('Error processing inline match: ${match.text}, Error: $e\n$s');
    }
    return TextSpan(
        text: match.text,
        style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: fs));
  }
}

/// Merges fragmented/consecutive thinking blocks into a single block.
///
/// During streaming, the model sometimes sends complex think tags.
/// This function extracts ALL thinking content and consolidates it into
/// a single think block at the beginning.
String _mergeFragmentedThinkingBlocks(String text) {
  // Step 1: Find ALL closed <think>...</think> blocks
  final closedThinkPattern =
  RegExp(r'<think>([\s\S]*?)</think>', multiLine: true);
  final closedMatches = closedThinkPattern.allMatches(text).toList();

  // Step 2: Check for unclosed <think> block at the end (streaming)
  final unclosedThinkPattern = RegExp(r'<think>([\s\S]*)$', multiLine: true);
  String? unclosedContent;
  bool hasUnclosedBlock = false;

  // Remove all closed blocks first to check for unclosed
  String textWithoutClosed = text.replaceAll(closedThinkPattern, '');
  final unclosedMatch = unclosedThinkPattern.firstMatch(textWithoutClosed);
  if (unclosedMatch != null) {
    unclosedContent = unclosedMatch.group(1)?.trim();
    hasUnclosedBlock = unclosedContent?.isNotEmpty ?? false;
  }

  // If no thinking blocks at all, return as-is
  if (closedMatches.isEmpty && !hasUnclosedBlock) {
    return text;
  }

  // Step 3: Extract all thinking contents
  final List<String> thinkingContents = [];

  // Helper function to clean nested think tags from content
  String cleanNestedThinkTags(String content) {
    // Remove any nested <think> or </think> tags inside the content
    // This handles offline models that produce their own thinking format
    return content.replaceAll(RegExp(r'</?think>', caseSensitive: false), '');
  }

  // Add closed blocks content
  for (final match in closedMatches) {
    var content = match.group(1)?.trim() ?? '';
    content = cleanNestedThinkTags(content);
    if (content.isNotEmpty) {
      thinkingContents.add(content);
    }
  }

  // Add unclosed block content (if any)
  if (hasUnclosedBlock &&
      unclosedContent != null &&
      unclosedContent.isNotEmpty) {
    unclosedContent = cleanNestedThinkTags(unclosedContent);
    thinkingContents.add(unclosedContent);
  }

  if (thinkingContents.isEmpty) {
    return text; // All thinking blocks were empty
  }

  // Step 4: Remove all think blocks from text
  String cleanedText = text;
  // Remove closed think blocks
  cleanedText = cleanedText.replaceAll(closedThinkPattern, '');
  // Remove unclosed think blocks (streaming)
  cleanedText = cleanedText.replaceAll(unclosedThinkPattern, '');

  // Step 5: Merge all thinking contents with paragraph breaks
  final mergedThinking = thinkingContents.join('\n\n');

  // Step 6: Create the single merged thinking block
  final thinkTag = hasUnclosedBlock
      ? '<think>$mergedThinking' // Keep unclosed for streaming
      : '<think>$mergedThinking</think>'; // Close it

  // Step 7: Clean up the remaining text
  cleanedText = cleanedText.trim();
  // Remove any leading/trailing newlines from cleaned text
  cleanedText = cleanedText.replaceAll(RegExp(r'^\n+|\n+$'), '');

  // Add a single newline separator if there's content after thinking
  final separator = cleanedText.isNotEmpty ? '\n' : '';

  return '$thinkTag$separator$cleanedText';
}

class _MatchRange {
  final int start, end;
  final String text, type;

  _MatchRange({required this.start,
    required this.end,
    required this.text,
    required this.type});
}

/// Intelligently converts a string with complex Markdown and LaTeX into a highly
/// readable, clean, plain text version using UTF-8 symbols where possible.
String stripMarkup(String text) {
  // --- Stage 1: Handle block-level elements for clean separation ---
  text = text.replaceAll(RegexPatterns.widget, ''); // Remove raw widget data
  text = text.replaceAllMapped(RegexPatterns.codeBlock, (m) => '\n');
  text = text.replaceAll(
      RegExp(r'^\s*\|(?:\s*:?-+:?\s*\|)+\s*$', multiLine: true), '');
  text = text.replaceAll('|', '  ');
  text = text.replaceAllMapped(RegexPatterns.heading,
          (m) => '${m.group(0)!.replaceFirst(RegExp(r"^#+\s*"), "")}\n');
  text =
      text.replaceAllMapped(RegexPatterns.bulletList, (m) => '${m.group(1)}\n');
  text = text.replaceAll(RegExp(r'^---$', multiLine: true), '');

  // --- Stage 2: Intelligently convert LaTeX to UTF-8 symbols and readable text ---
  text = text.replaceAll(RegExp(r'(\$\$|\\\[|\\\]|\\\(|\\\))'), '');
  text = text.replaceAll(r'$', '');

  // Protect text inside \text{...}
  text = text.replaceAllMapped(RegExp(r'\\text\{(.+?)\}'), (m) => m.group(1)!);

  // Handle complex structures first.
  text = text.replaceAllMapped(RegExp(r'\\frac\{(.+?)\}\{(.+?)\}'),
          (m) => '(${m.group(1)}/${m.group(2)})');
  text = text.replaceAllMapped(RegExp(r'\\sqrt\[(.+?)\]\{(.+?)\}'),
          (m) => '(${m.group(1)})√(${m.group(2)})');
  text = text.replaceAllMapped(
      RegExp(r'\\sqrt\{(.+?)\}'), (m) => '√(${m.group(1)})');

  // Handle styling commands by just extracting their content.
  text = text.replaceAllMapped(
      RegExp(r'\\(mathbf|mathbb|mathcal)\{(.+?)\}'), (m) => m.group(2)!);

  // ... (latexToUtf map remains same)

  // Clean up any remaining braces and backslashes.
  text = text.replaceAll(RegExp(r'[{}]'), '');
  text =
      text.replaceAll(RegExp(r'\\([a-zA-Z]+)'), ''); // Remove unknown commands

  // --- Stage 3: Handle remaining inline Markdown elements ---
  text = text.replaceAllMapped(RegexPatterns.link, (m) => m.group(1) ?? '');
  text =
      text.replaceAllMapped(RegexPatterns.boldItalic, (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(RegexPatterns.bold, (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(RegExp(r'[*_](.+?)[*_]', dotAll: true),
          (m) => m.group(1) ?? ''); // Italic simple
  text = text.replaceAllMapped(
      RegexPatterns.strikethrough, (m) => m.group(1) ?? '');
  text = text.replaceAllMapped(
      RegexPatterns.inlineCode, (m) => m.group(0)!.replaceAll('`', ''));

  // --- Stage 4: Final cleanup ---
  text = text.replaceAll(RegexPatterns.thinking, '');
  // Remove tool result emojis and "*Using...*" lines from copied text
  text = text.replaceAll(RegexPatterns.usingToolLine, '');
  text = text.replaceAll(RegExp(r'[✅❌✓✗]'), '');
  text = text.replaceAll(RegExp(r'[ \t]{2,}', multiLine: true), ' ');
  text = text.replaceAll(RegExp(r'(\s*\n\s*){2,}'), '\n\n');

  return text.trim();
}
