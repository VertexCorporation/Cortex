import 'dart:ui' as ui;
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../notifications.dart';
import '../../theme.dart';
import 'codeblocks.dart';

double _baseFs() =>
    (ui.window.physicalSize.width / ui.window.devicePixelRatio) * 0.042;

/// SafeMathTex widget: Renders LaTeX or falls back to raw text on error.
class SafeMathTex extends StatelessWidget {
  final String latex;
  final TextStyle textStyle;
  const SafeMathTex({required this.latex, required this.textStyle, Key? key})
      : super(key: key);

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
  final uri = Uri.parse(urlString);
  final success = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!success) {
    Provider.of<NotificationService>(context, listen: false).showNotification(
      message: AppLocalizations.of(context)!.anErrorOccurred,
      isSuccess: false,
      bottomOffset: 0.22,
      fontSize: 0.032,
    );
  }
}

/// parseText: Parses text for LaTeX, code blocks, tables, links, and Markdown styling.
List<InlineSpan> parseText(String text) {
  try {
    final fs = _baseFs();
    // Define patterns in order of processing priority
    final patterns = <String, RegExp>{
      'horizontalRule': RegExp(r'^---$', multiLine: true),
      'codeBlock'     : RegExp(r'```([\s\S]*?)```', dotAll: true),
      'table'         : RegExp(
        r'(^\s*\|.+\|\s*\n'
        r'\s*\|(?:\s*:?-+:?\s*\|)+\s*\n'
        r'(?:\s*\|.*\|\s*\n?)+)',
        multiLine: true,
        dotAll: true,
      ),
      'heading'   : RegExp(r'^#{1,6} .+?$', multiLine: true),
      'bulletList': RegExp(r'^\s*[\*\-\+]\s+(.+)$', multiLine: true),
    };

    // First pass: process block-level elements
    final blockMatches = <_MatchRange>[];

    // Find all block-level matches
    patterns.forEach((type, pattern) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        blockMatches.add(_MatchRange(
          start: match.start,
          end: match.end,
          text: match.group(0)!,
          type: type,
        ));
      }
    });

    // Sort block matches by start position
    blockMatches.sort((a, b) => a.start - b.start);

    // Remove overlaps in block-level matches
    final finalBlockMatches = <_MatchRange>[];
    for (final match in blockMatches) {
      bool shouldAdd = true;
      for (final existing in finalBlockMatches) {
        if (match.start < existing.end && match.end > existing.start) {
          shouldAdd = false;
          break;
        }
      }
      if (shouldAdd) finalBlockMatches.add(match);
    }

    finalBlockMatches.sort((a, b) => a.start - b.start);

    // Inline patterns
    final inlinePatterns = <String, RegExp>{
      // --- START OF CHANGE ---
      'thinkStart'    : RegExp(r'<think>\s*'), // Matches <think> and following whitespace
      'thinkEnd'      : RegExp(r'\s*</think>'),
      // --- END OF CHANGE ---
      'latex'         : RegExp(r'(\\\[.+?\\\]|\\\(.+?\\\)|\$\$.+?\$\$|\$.+?\$|\\begin\{.*?\}[\s\S]*?\\end\{.*?\})', dotAll: true),
      'inlineCode'    : RegExp(r'`[^`\r\n]+?`'),
      'link'          : RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
      'boldItalic'    : RegExp(r'(\*\*\*.+?\*\*\*|___.+?___)', dotAll: true),
      'bold'          : RegExp(r'(\*\*.+?\*\*|__.+?__)', dotAll: true),
      'italic'        : RegExp(r'(?<!\*)\*(?!\*).+?(?<!\*)\*(?!\*)|(?<!_)_(?!_).+?(?<!_)_(?!_)', dotAll: true),
      'strikethrough' : RegExp(r'~~.+?~~', dotAll: true),
    };

    final spans = <InlineSpan>[];
    int currentIndex = 0;

    for (final blockMatch in finalBlockMatches) {
      if (blockMatch.start > currentIndex) {
        final betweenText = text.substring(currentIndex, blockMatch.start);
        spans.addAll(_processInlineElements(betweenText, inlinePatterns, fs));
      }

      if (blockMatch.type == 'bulletList') {
        final bulletMatch = RegExp(r'^\s*[\*\-\+]\s+(.+)$', multiLine: true).firstMatch(blockMatch.text);
        final content = bulletMatch?.group(1) ?? '';
        final inlineSpans = _processInlineElements(content, inlinePatterns, fs);

        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ',
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: fs,
                  ),
                ),
                Expanded(child: RichText(text: TextSpan(children: inlineSpans))),
              ],
            ),
          ),
        ));
      } else {
        spans.add(_processBlockMatch(blockMatch, fs));
      }

      currentIndex = blockMatch.end;
    }

    if (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);
      spans.addAll(_processInlineElements(remainingText, inlinePatterns, fs));
    }

    return spans;
  } catch (e) {
    final fs = _baseFs();
    print('parseText unexpected error: $e');
    return [
      TextSpan(
        text: text,
        style: TextStyle(
          color: AppColors.primaryColor.inverted,
          fontSize: fs,
        ),
      )
    ];
  }
}

List<InlineSpan> _processInlineElements(
    String text,
    Map<String, RegExp> patterns,
    double fs,
    ) {
  if (text.trim().isEmpty) {
    return [
      TextSpan(
        text: text,
        style: TextStyle(
          color: AppColors.primaryColor.inverted,
          fontSize: fs,
        ),
      )
    ];
  }

  final matchedRanges = <_MatchRange>[];

  patterns.forEach((type, pattern) {
    final matches = pattern.allMatches(text);
    for (final match in matches) {
      matchedRanges.add(_MatchRange(
        start: match.start,
        end: match.end,
        text: match.group(0)!,
        type: type,
      ));
    }
  });

  matchedRanges.sort((a, b) => a.start - b.start);

  final finalMatches = <_MatchRange>[];
  for (final match in matchedRanges) {
    bool shouldAdd = true;
    for (final existing in finalMatches) {
      if (match.start < existing.end && match.end > existing.start) {
        shouldAdd = false;
        break;
      }
    }
    if (shouldAdd) finalMatches.add(match);
  }

  finalMatches.sort((a, b) => a.start - b.start);

  final spans = <InlineSpan>[];
  int currentIndex = 0;
  bool isThinking = false; // State to track if we are inside <think> tags

  for (final match in finalMatches) {
    if (match.start > currentIndex) {
      // Process text between matches
      final subText = text.substring(currentIndex, match.start);
      spans.add(TextSpan(
        text: subText,
        style: TextStyle(
          color: AppColors.primaryColor.inverted,
          fontSize: fs,
          fontStyle: isThinking ? FontStyle.italic : FontStyle.normal,
        ),
      ));
    }

    // Process the match itself
    if (match.type == 'thinkStart') {
      isThinking = true;
      // The tag is hidden by not adding any visible span for it.
    } else if (match.type == 'thinkEnd') {
      isThinking = false;
      // The tag is hidden.
    } else {
      // For other markdown, process it normally but pass the current thinking state.
      spans.add(_processInlineMatch(match, fs, isThinking: isThinking));
    }

    currentIndex = match.end;
  }

  if (currentIndex < text.length) {
    // Process any remaining text after the last match
    spans.add(TextSpan(
      text: text.substring(currentIndex),
      style: TextStyle(
        color: AppColors.primaryColor.inverted,
        fontSize: fs,
        fontStyle: isThinking ? FontStyle.italic : FontStyle.normal,
      ),
    ));
  }

  return spans;
}

InlineSpan _processBlockMatch(_MatchRange match, double fs) {
  final matchText = match.text;

  switch (match.type) {
    case 'horizontalRule':
      return WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
          child: Divider(color: Colors.grey, thickness: 1),
        ),
      );

    case 'codeBlock':
      if (matchText.length >= 6) {
        final content = matchText.substring(3, matchText.length - 3).trim();
        return WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CodeBlockWidget(code: content),
          ),
        );
      }
      return TextSpan(
        text: matchText,
        style: TextStyle(
          color: AppColors.primaryColor.inverted,
          fontSize: fs,
        ),
      );

    case 'table':
      final lines = matchText.trimRight().split(RegExp(r'\r?\n'));
      if (lines.length < 3) {
        return TextSpan(
          text: matchText,
          style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: fs),
        );
      }

      List<String> _splitRow(String row) => row
          .split('|')
          .where((c) => c.trim().isNotEmpty)
          .map((c) => c.trim())
          .toList();

      final header      = _splitRow(lines.first);
      final dataRowsRaw = lines.skip(2);
      final dataRows    = dataRowsRaw.map(_splitRow).toList();

      final colCount = header.length;                    // ⬅️ referans uzunluk
        List<Widget> _padStr(List<String> cells, Widget Function(String) builder) {
            final padded = [...cells];
            while (padded.length < colCount) padded.add('');                    // ⬅️ eksikler boş
            return padded.map(builder).toList();
          }

      Widget _th(String txt) =>
          Padding(padding: const EdgeInsets.all(8), child: Text(txt, style: const TextStyle(fontWeight: FontWeight.bold)));
      Widget _td(String txt) =>
          Padding(padding: const EdgeInsets.all(8), child: Text(txt));

      return WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Table(
            border: TableBorder.all(color: Colors.grey),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: _padStr(header, _th)),
              for (final row in dataRows) TableRow(children: _padStr(row, _td)),
            ],
          ),
        ),
      );

    case 'heading':
      final level = matchText.indexOf(' ');
      if (level > 0 && level <= 6) {
        final content = matchText.substring(level + 1);
        final headingSize = fs * (1 + (6 - level) * 0.15);
        return TextSpan(
          text: content + '\n',
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: headingSize,
            fontWeight: FontWeight.bold,
          ),
        );
      }
      return TextSpan(
        text: matchText,
        style: TextStyle(
          color: AppColors.primaryColor.inverted,
          fontSize: fs,
        ),
      );

    default:
      return TextSpan(
        text: matchText,
        style: TextStyle(
          color: AppColors.primaryColor.inverted,
          fontSize: fs,
        ),
      );
  }
}

InlineSpan _processInlineMatch(_MatchRange match, double fs, {bool isThinking = false}) {
  final matchText = match.text;

  // This base style will be used for text that should inherit the thinking state (italic)
  final baseStyle = TextStyle(
    color: AppColors.primaryColor.inverted,
    fontSize: fs,
    fontStyle: isThinking ? FontStyle.italic : FontStyle.normal,
  );

  switch (match.type) {
  // The 'think' case is removed as it's now handled by the state machine above.

    case 'latex':
      String latex = matchText;
      if (latex.startsWith('\\begin{') && latex.endsWith('\\end{')) {
        latex = latex.trim();
      } else if ((latex.startsWith(r'$$') && latex.endsWith(r'$$')) ||
          (latex.startsWith('\\[') && latex.endsWith('\\]'))) {
        latex = latex.substring(2, latex.length - 2).trim();
      } else if ((latex.startsWith(r'$') && latex.endsWith(r'$')) ||
          (latex.startsWith('\\(') && latex.endsWith('\\)'))) {
        latex = latex.substring(1, latex.length - 1).trim();
      }

      // If the stripped content is empty (e.g., from "$$"), or otherwise invalid,
      // fall back to rendering it as plain text to prevent crashes.
      if (latex.isEmpty) {
        return TextSpan(
          text: matchText,
          style: baseStyle,
        );
      }

      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: SafeMathTex(
          latex: latex,
          textStyle: TextStyle( // LaTeX has its own style, doesn't become italic
            color: AppColors.primaryColor.inverted,
            fontSize: fs,
          ),
        ),
      );

    case 'inlineCode':
      final content = matchText.substring(1, matchText.length - 1);
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              content,
              style: TextStyle( // Code has its own style
                color: AppColors.primaryColor.inverted,
                fontSize: fs * 0.9,
                fontFamily: 'monospace',
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      );

    case 'link':
      final m = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').firstMatch(matchText)!;
      final label = m.group(1)!;
      final url = m.group(2)!;
      return WidgetSpan(
        child: Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => _openLink(ctx, url),
            child: Text(
              label,
              style: baseStyle.copyWith( // Link inherits base style (like italic) but color is blue
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      );

    case 'boldItalic':
      final content = matchText.substring(3, matchText.length - 3).trim();
      return TextSpan(
        text: content,
        style: baseStyle.copyWith( // Merges with base style
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      );

    case 'bold':
      final content = matchText.substring(2, matchText.length - 2).trim();
      return TextSpan(
        text: content,
        style: baseStyle.copyWith( // Merges with base style
          fontWeight: FontWeight.bold,
        ),
      );

    case 'italic':
      final content = matchText.substring(1, matchText.length - 1).trim();
      return TextSpan(
        text: content,
        style: baseStyle.copyWith( // Merges with base style
          fontStyle: FontStyle.italic,
        ),
      );

    case 'strikethrough':
      final content = matchText.substring(2, matchText.length - 2).trim();
      return TextSpan(
        text: content,
        style: baseStyle.copyWith( // Merges with base style
          decoration: TextDecoration.lineThrough,
        ),
      );

    default:
      return TextSpan(
        text: matchText,
        style: baseStyle,
      );
  }
}

/// Class to track matched text ranges for pattern processing
class _MatchRange {
  final int start;
  final int end;
  final String text;
  final String type;

  _MatchRange({
    required this.start,
    required this.end,
    required this.text,
    required this.type,
  });
}

/// _FittingLatexWidget: Measures rendered LaTeX width and scales down if overflowing.
class _FittingLatexWidget extends StatefulWidget {
  final String latex;
  final bool isDarkTheme;

  const _FittingLatexWidget({
    Key? key,
    required this.latex,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  State<_FittingLatexWidget> createState() => _FittingLatexWidgetState();
}

class _FittingLatexWidgetState extends State<_FittingLatexWidget> {
  final GlobalKey _renderKey = GlobalKey();
  double _scale = 1.0;

  @override
  void didUpdateWidget(covariant _FittingLatexWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latex != widget.latex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureWidth());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureWidth());
  }

  void _measureWidth() {
    final renderBox = _renderKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final childWidth = renderBox.size.width;
    final availableWidth = renderBox.constraints.maxWidth;

    setState(() {
      _scale = (childWidth > availableWidth && availableWidth > 0)
          ? availableWidth / childWidth
          : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fs = _baseFs();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Transform.scale(
          scale: _scale,
          alignment: Alignment.topLeft,
          child: Container(
            key: _renderKey,
            child: Math.tex(
              widget.latex,
              textStyle: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontSize: fs,
              ),
            ),
          ),
        );
      },
    );
  }
}