import 'dart:convert';
import 'package:cortex/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/chat/screen/widgets/thinking.dart';
import 'package:cortex/chat/messages/codeblocks.dart';
import 'package:cortex/chat/screen/widgets/tools.dart';
import 'inline.dart';
import 'patterns.dart';
import 'utils.dart';

final _thinkingClean = RegExp(
  r'(^<think\b[^>]*>\s*)|(\s*</think\s*>$)|</?think\b[^>]*>|'
  r'\*?Thinking\.\.\.\*?',
  caseSensitive: false,
);
final _excessNewlines = RegExp(r'\n{3,}');
final _singleNewline = RegExp(r'(?<!\n)\n(?!\n)');
final _excessSpaces = RegExp(r' {2,}');
final _blockquotePrefix = RegExp(r'^\s*>\s?');
final _codeBlockPattern = RegExp(
    r'^[ \t]*(```+)([^\r\n]*)\r?\n([\s\S]*?)\r?\n^[ \t]*\1[ \t]*$',
    multiLine: true);
final _widgetMarker = RegExp(
    r'<<<WIDGET:([A-Za-z0-9_-]+)>>>([\s\S]*?)<<<END>>>',
    caseSensitive: false);

InlineSpan processBlockMatch(BuildContext context, MatchRange match,
    Map<String, RegExp> inlinePatterns, double fs,
    {bool isFinished = false,
    Map<String, int>? urlMap,
    List<dynamic>? citations}) {
  try {
    final matchText = match.text;
    switch (match.type) {
      case 'toolWidget':
        final widgetMatch = _widgetMarker.firstMatch(matchText);
        if (widgetMatch == null) {
          return const WidgetSpan(child: SizedBox.shrink());
        }
        final type = widgetMatch.group(1) ?? '';
        try {
          final decoded = jsonDecode(widgetMatch.group(2) ?? '{}');
          final data = decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : <String, dynamic>{};
          return WidgetSpan(
            child: ToolWidgetFactory.build(type, data),
          );
        } catch (_) {
          return const WidgetSpan(child: SizedBox.shrink());
        }
      case 'thinking':
        String content = matchText;
        final bool hasCloseTag = RegexPatterns.thinkEnd.hasMatch(matchText);
        final bool isThinkingFinished = hasCloseTag || isFinished;

        content = content.replaceAll(_thinkingClean, '');
        content = content.replaceAll(_excessNewlines, '\n\n');
        content = content.replaceAll(_singleNewline, ' ');
        content = content.replaceAll(_excessSpaces, ' ');
        content = content.trim();

        const widgetKey = ValueKey('thinking_block_main');

        return WidgetSpan(
          child: ThinkingWidget(
            key: widgetKey,
            content: content,
            isFinished: isThinkingFinished,
          ),
        );
      case 'horizontalRule':
        return WidgetSpan(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Divider(color: AppColors.border, thickness: 1)));
      case 'blockquote':
        final content = matchText
            .trimRight()
            .split('\n')
            .map((line) => line.replaceFirst(_blockquotePrefix, ''))
            .join('\n')
            .trim();

        if (content.isEmpty) {
          return const WidgetSpan(child: SizedBox.shrink());
        }

        return WidgetSpan(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color:
                        AppColors.primaryColor.inverted.withValues(alpha: 0.28),
                    width: 3,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(left: 10),
              child: RichText(
                text: TextSpan(
                  children: processInlineElements(
                    context,
                    content,
                    inlinePatterns,
                    fs,
                    urlMap: urlMap,
                    citations: citations,
                  ),
                  style: TextStyle(
                    color:
                        AppColors.primaryColor.inverted.withValues(alpha: 0.86),
                    fontSize: fs,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ),
        );
      case 'codeBlock':
        final codeMatch = _codeBlockPattern.firstMatch(matchText);
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
      case 'displayMathBracket':
        // \[…\] — the TeX display-equation block. Re-match to pull the
        // captured body between the delimiters; malformed LaTeX degrades to
        // literal source text via SafeMathTex's fallback, never a crash.
        final mathMatch =
            RegexPatterns.displayMathBracket.firstMatch(matchText);
        final latex = mathMatch?.group(1)?.trim() ?? matchText;
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SafeMathTex(
            latex: latex,
            textStyle: TextStyle(
                color: AppColors.primaryColor.inverted, fontSize: fs),
            display: true,
          ),
        );
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
        Widget buildCell(String text,
            {bool isHeader = false, double? maxWidth}) {
          return Container(
            constraints: maxWidth != null
                ? BoxConstraints(maxWidth: maxWidth)
                : const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            child: RichText(
              softWrap: true,
              text: TextSpan(
                children: processInlineElements(
                    context, text, inlinePatterns, fs,
                    urlMap: urlMap, citations: citations),
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
                padding: const EdgeInsets.only(top: 2, bottom: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    if (colCount > 6) {
                      const minColWidth = 120.0;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: availableWidth,
                              maxWidth: (minColWidth * colCount)
                                  .clamp(availableWidth, double.infinity),
                            ),
                            child: Table(
                              border: TableBorder.all(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              defaultColumnWidth: const FlexColumnWidth(),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: tableRows,
                            ),
                          ),
                        ),
                      );
                    }

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Table(
                        border: TableBorder.all(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        defaultColumnWidth: const FlexColumnWidth(),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: tableRows,
                      ),
                    );
                  },
                )));
      case 'heading':
        final level = matchText.indexOf(' ');
        if (level > 0 && level <= 6) {
          final content = matchText.substring(level + 1);
          final headingSize = fs * (1 + (6 - level) * 0.15);
          return TextSpan(
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: headingSize,
              fontWeight: FontWeight.bold,
            ),
            children: [
              ...processInlineElements(
                context,
                content,
                inlinePatterns,
                headingSize,
                urlMap: urlMap,
                citations: citations,
              ),
            ],
          );
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
