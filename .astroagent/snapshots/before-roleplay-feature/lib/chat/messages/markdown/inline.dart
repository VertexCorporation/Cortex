import 'package:cortex/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'patterns.dart';
import 'utils.dart';

final _linkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
final _citationBracketClean = RegExp(r'[\[\]【】\s]');

List<InlineSpan> processInlineElements(
    BuildContext context, String text, Map<String, RegExp> patterns, double fs,
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
      final inlineMatch = MatchRange(
          start: match.start,
          end: match.end,
          text: match.group(0)!,
          type: matchType);
      spans.add(processInlineMatch(context, inlineMatch, patterns, fs,
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

InlineSpan processInlineMatch(BuildContext context, MatchRange match,
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
            child: SafeMathTex(
                latex: content,
                textStyle: baseStyle.copyWith(fontSize: fs * 0.85)));
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
        final m = _linkPattern.firstMatch(matchText);
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
            displayTitle = Uri.parse(url).host.replaceAll('www.', '');
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
                  color: AppColors.background,
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
        final url = matchText.trim();
        return WidgetSpan(
            child: GestureDetector(
                onTap: () => openLink(context, url),
                child: Text(url,
                    style: baseStyle.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline))));
      case 'citation':
        final citationIndexStr =
            matchText.replaceAll(_citationBracketClean, '');
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
                // ignore
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
                  // ignore
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
                ? AppColors.background
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
            children: processInlineElements(
                context, content, inlinePatterns, fs,
                urlMap: urlMap, citations: citations),
            style: baseStyle.copyWith(
                fontWeight: FontWeight.bold, fontStyle: FontStyle.italic));
      case 'bold':
        final content = matchText.substring(2, matchText.length - 2);
        return TextSpan(
            children: processInlineElements(
                context, content, inlinePatterns, fs,
                urlMap: urlMap, citations: citations),
            style: baseStyle.copyWith(fontWeight: FontWeight.bold));
      case 'italic':
        final content = matchText.substring(1, matchText.length - 1);
        return TextSpan(
            children: processInlineElements(
                context, content, inlinePatterns, fs,
                urlMap: urlMap, citations: citations),
            style: baseStyle.copyWith(fontStyle: FontStyle.italic));
      case 'strikethrough':
        final content = matchText.substring(2, matchText.length - 2);
        return TextSpan(
            children: processInlineElements(
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
