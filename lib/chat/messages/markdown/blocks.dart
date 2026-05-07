import 'package:cortex/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'dart:convert';
import 'package:cortex/chat/screen/widgets/tools.dart';
import 'package:cortex/chat/screen/widgets/thinking.dart';
import 'package:cortex/chat/messages/codeblocks.dart';
import 'inline.dart';
import 'utils.dart';

InlineSpan processBlockMatch(BuildContext context, MatchRange match,
    Map<String, RegExp> inlinePatterns, double fs,
    {bool isFinished = false,
    Map<String, int>? urlMap,
    List<dynamic>? citations}) {
  try {
    final matchText = match.text;
    switch (match.type) {
      case 'memory':
        return const WidgetSpan(child: SizedBox.shrink());
      case 'thinkingLegacy':
      case 'thinking':
        String content = matchText;
        final bool hasCloseTag = matchText.contains('</think>');
        final bool isThinkingFinished = hasCloseTag || isFinished;

        content = content.replaceAll(RegExp(r'(^<think>\s*)|(\s*</think>$)'), '');
        content = content.replaceAll(RegExp(r'</?think>', caseSensitive: false), '');
        content = content.replaceAll(
            RegExp(r'(?:^|[\r\n]+)[ \t]*>?\s*\*Thinking\.\.\.\*[\r\n]*>?[ \t]?',
                caseSensitive: false),
            '');
        content = content.replaceAll(RegExp(r'(?<=^|\n)>\s?'), '');
        content = content.replaceAll(
            RegExp(r'^[*]*Thinking[.*]*\s*', caseSensitive: false), '');
        content = content.replaceAll(
            RegExp(r'\*?Thinking\.\.\.\*?', caseSensitive: false), '');

        content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');
        content = content.replaceAll(RegExp(r'(?<!\n)\n(?!\n)'), ' ');
        content = content.replaceAll(RegExp(r' {2,}'), ' ');
        content = content.trim();

        const widgetKey = ValueKey('thinking_block_main');

        if (content.isEmpty) {
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
        return WidgetSpan(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Divider(color: AppColors.border, thickness: 1)));
      case 'widget':
        try {
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
                children: processInlineElements(
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
