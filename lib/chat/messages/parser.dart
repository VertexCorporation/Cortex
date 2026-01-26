// ================ lib/chat/messages/parser.dart ================

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../notifications/introvert.dart';
import '../../theme.dart';
import 'package:shimmer/shimmer.dart';
import 'codeblocks.dart';
import 'dart:convert';
import '../screen/widgets/tools.dart';
import '../screen/widgets/thinking.dart';
import 'package:flutter/foundation.dart';

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

void _openLink(BuildContext context, String urlString) async {
  final uri = Uri.tryParse(urlString);
  if (uri == null) return;
  final success = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!success && context.mounted) {
    Provider.of<IntrovertNotificationService>(context, listen: false)
        .showNotification(
      message: AppLocalizations.of(context)!.anErrorOccurred,
      type: NotificationType.success,
      bottomOffset: 0.22,
    );
  }
}

// Static RegExp constants to avoid recompilation
class RegexPatterns {
  static final thinking = RegExp(
      r'(<think>[\s\S]*?</think>)|((?:^> \*Thinking\.\.+\s*\n)(?:^>.*(?:\n|$))*)',
      multiLine: true);
  static final horizontalRule =
      RegExp(r'^\s*([*\-_]){3,}\s*$', multiLine: true);
  static final codeBlock =
      RegExp(r'^```([^\r\n]*)\r?\n([\s\S]*?)\r?\n^```$', multiLine: true);
  static final legacyUsing =
      RegExp(r'^\*Using (.+?)\.\.\.\*$', multiLine: true);
  static final table = RegExp(
      r'(^\s*\|.+\|\s*\n\s*\|(?:\s*:?-+:?\s*\|)+\s*\n(?:\s*\|.*\|\s*\n?)+)',
      multiLine: true);
  static final widget = RegExp(
      r'^\s*<<<WIDGET:([a-zA-Z0-9_]+)>>>([\s\S]*?)<<<END>>>\s*$',
      multiLine: true);
  static final heading = RegExp(r'^#{1,6} .+?$', multiLine: true);
  static final bulletList = RegExp(r'^\s*[*\-+]\s+(.+)$', multiLine: true);

  static final inlineCode = RegExp(r'`[^`\r\n]+?`');
  static final latex = RegExp(
      r'(\$\$[\s\S]+?\$\$|\\\[[\s\S]+?\\\]|\\begin\{.+?\}[\s\S]+?\\end\{.+?\}|\\\(.+?\\\)|(?<!\$)\$[^$\r\n]+?\$(?!\$))');
  static final link = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
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
    'legacyUsing': legacyUsing,
    'table': table,
    'widget': widget,
    'heading': heading,
    'bulletList': bulletList,
  };

  static final inlinePatterns = {
    'inlineCode': inlineCode,
    'latex': latex,
    'link': link,
    'boldItalic': boldItalic,
    'bold': bold,
    'strikethrough': strikethrough,
    'italic': italic,
    'thinkStart': thinkStart,
    'thinkEnd': thinkEnd,
  };
}

List<InlineSpan> parseText(BuildContext context, String text,
    {double? fontSize}) {
  try {
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

    final inlinePatterns = RegexPatterns.inlinePatterns;

    final spans = <InlineSpan>[];
    int currentIndex = 0;

    for (final blockMatch in finalBlockMatches) {
      if (blockMatch.start > currentIndex) {
        final betweenText = text.substring(currentIndex, blockMatch.start);
        spans.addAll(
            _processInlineElements(context, betweenText, inlinePatterns, fs));
      }

      if (blockMatch.type == 'bulletList') {
        final bulletMatch = RegExp(r'^\s*[*\-+]\s+(.+)$', multiLine: true)
            .firstMatch(blockMatch.text);
        final content = bulletMatch?.group(1) ?? '';
        final inlineSpans =
            _processInlineElements(context, content, inlinePatterns, fs);
        spans.add(WidgetSpan(
            child: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ',
                  style: TextStyle(
                      color: AppColors.primaryColor.inverted, fontSize: fs)),
              Expanded(child: RichText(text: TextSpan(children: inlineSpans))),
            ],
          ),
        )));
      } else {
        spans.add(_processBlockMatch(context, blockMatch, inlinePatterns, fs));
      }

      currentIndex = blockMatch.end;
    }

    if (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);
      spans.addAll(
          _processInlineElements(context, remainingText, inlinePatterns, fs));
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
    Map<String, RegExp> patterns, double fs) {
  if (text.isEmpty) {
    return [];
  }

  final combinedPattern = RegExp(
    patterns.entries.map((e) => '(?<${e.key}>${e.value.pattern})').join('|'),
    dotAll: true,
  );

  final spans = <InlineSpan>[];
  int currentIndex = 0;
  bool isThinking = false;

  for (final match in combinedPattern.allMatches(text)) {
    if (match.start > currentIndex) {
      spans.add(TextSpan(
        text: text.substring(currentIndex, match.start),
        style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: fs,
            fontStyle: isThinking ? FontStyle.italic : FontStyle.normal),
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
      if (matchType == 'thinkStart') {
        isThinking = true;
      } else if (matchType == 'thinkEnd') {
        isThinking = false;
      } else {
        final inlineMatch = _MatchRange(
            start: match.start,
            end: match.end,
            text: match.group(0)!,
            type: matchType);
        spans.add(_processInlineMatch(context, inlineMatch, patterns, fs,
            isThinking: isThinking));
      }
    }
    currentIndex = match.end;
  }

  if (currentIndex < text.length) {
    spans.add(TextSpan(
      text: text.substring(currentIndex),
      style: TextStyle(
          color: AppColors.primaryColor.inverted,
          fontSize: fs,
          fontStyle: isThinking ? FontStyle.italic : FontStyle.normal),
    ));
  }
  return spans;
}

InlineSpan _processBlockMatch(BuildContext context, _MatchRange match,
    Map<String, RegExp> inlinePatterns, double fs) {
  try {
    final matchText = match.text;
    switch (match.type) {
      case 'thinking':
        String content = matchText;
        bool isLegacyQuote = content.trim().startsWith('>');

        if (isLegacyQuote) {
          // Handle > *Thinking...* blocks
          final lines = content.split('\n');
          // Filter out lines that are just the header or empty/whitespace
          final filteredLines = lines.where((l) {
            final trimmed = l.trim();
            return !trimmed.startsWith('> *Thinking') && trimmed != '>';
          }).toList();

          // Clean up the remaining lines (remove '> ' or '>')
          content = filteredLines.map((l) {
            var line = l.trim();
            if (line.startsWith('> ')) return line.substring(2);
            if (line.startsWith('>')) return line.substring(1);
            return line;
          }).join('\n');
        } else {
          // Handle <think> tags
          content =
              content.replaceAll(RegExp(r'(^<think>\s*)|(\s*</think>$)'), '');
        }

        if (content.trim().isEmpty) {
          return WidgetSpan(child: SizedBox.shrink());
        }

        return WidgetSpan(
          child: ThinkingWidget(content: content.trim()),
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
                  r'^\s*<<<WIDGET:([a-zA-Z0-9_]+)>>>([\s\S]*?)<<<END>>>\s*$',
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
        return WidgetSpan(
          child: Shimmer.fromColors(
            baseColor: AppColors.tertiaryColor,
            highlightColor: AppColors.primaryColor.withValues(alpha:0.5),
            period: const Duration(milliseconds: 2000),
            child: Text(
              AppLocalizations.of(context)?.workInProgress ??
                  'Work In Progress',
              style: TextStyle(
                fontSize: fs * 0.9,
                fontWeight: FontWeight.w600,
                color: AppColors.tertiaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
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
                code: content, language: language.isEmpty ? null : language),
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
                children:
                    _processInlineElements(context, text, inlinePatterns, fs),
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
            if (rowString.trim().isEmpty) {
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
    {bool isThinking = false}) {
  try {
    final matchText = match.text;
    final baseStyle = TextStyle(
      color: AppColors.primaryColor.inverted,
      fontSize: fs,
      fontStyle: isThinking ? FontStyle.italic : FontStyle.normal,
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
        final m = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').firstMatch(matchText)!;
        return WidgetSpan(
            child: GestureDetector(
                onTap: () => _openLink(context, m.group(2)!),
                child: Text(m.group(1)!,
                    style: baseStyle.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline))));

      case 'boldItalic':
        final content = matchText.substring(3, matchText.length - 3);
        return TextSpan(
            children:
                _processInlineElements(context, content, inlinePatterns, fs),
            style: baseStyle.copyWith(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic));
      case 'bold':
        final content = matchText.substring(2, matchText.length - 2);
        return TextSpan(
            children:
                _processInlineElements(context, content, inlinePatterns, fs),
            style: baseStyle.copyWith(fontWeight: FontWeight.bold));
      case 'italic':
        final content = matchText.substring(1, matchText.length - 1);
        return TextSpan(
            children:
                _processInlineElements(context, content, inlinePatterns, fs),
            style: baseStyle.copyWith(fontStyle: FontStyle.italic));
      case 'strikethrough':
        final content = matchText.substring(2, matchText.length - 2);
        return TextSpan(
            children:
                _processInlineElements(context, content, inlinePatterns, fs),
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
        style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: fs,
            fontStyle: isThinking ? FontStyle.italic : FontStyle.normal));
  }
}

class _MatchRange {
  final int start, end;
  final String text, type;

  _MatchRange(
      {required this.start,
      required this.end,
      required this.text,
      required this.type});
}

/// Intelligently converts a string with complex Markdown and LaTeX into a highly
/// readable, clean, plain text version using UTF-8 symbols where possible.
String stripMarkup(String text) {
  // --- Stage 1: Handle block-level elements for clean separation ---
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
  text = text.replaceAll(RegExp(r'<think>|</think>'), '');
  text = text.replaceAll(RegExp(r'[ \t]{2,}', multiLine: true), ' ');
  text = text.replaceAll(RegExp(r'(\s*\n\s*){2,}'), '\n\n');

  return text.trim();
}
