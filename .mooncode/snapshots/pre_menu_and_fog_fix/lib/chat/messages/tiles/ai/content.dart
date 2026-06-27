part of '../ai.dart';

class _AiBodyContent extends StatelessWidget {
  final Message message;
  final Widget? embeddedMedia;
  final bool mediaAboveText;
  final String stableText;
  final String animatingText;
  final AnimationController textAnimCtl;
  final double scale;
  final Map<String, List<InlineSpan>> parseCache;

  const _AiBodyContent({
    required this.message,
    this.embeddedMedia,
    required this.mediaAboveText,
    required this.stableText,
    required this.animatingText,
    required this.textAnimCtl,
    required this.scale,
    required this.parseCache,
  });

  @override
  Widget build(BuildContext context) {
    String fullText = stableText + animatingText;
    String thinkContent = '';
    
    final thinkRegex = RegExp(r'<think>(.*?)(?:</think>|$)', dotAll: true);
    final thinkMatch = thinkRegex.firstMatch(fullText);
    
    String mainStable = stableText;
    String mainAnimating = animatingText;

    if (thinkMatch != null) {
      thinkContent = thinkMatch.group(1)?.trim() ?? '';
      final matchedStr = thinkMatch.group(0)!;
      
      if (mainStable.contains(matchedStr)) {
         mainStable = mainStable.replaceFirst(matchedStr, '').trimLeft();
      } else if (fullText.startsWith(matchedStr)) {
         int splitIndex = stableText.length;
         if (matchedStr.length <= splitIndex) {
            mainStable = mainStable.substring(matchedStr.length).trimLeft();
         } else {
            mainStable = '';
            int animCut = matchedStr.length - splitIndex;
            if (animCut < mainAnimating.length) {
                mainAnimating = mainAnimating.substring(animCut).trimLeft();
            } else {
                mainAnimating = '';
            }
         }
      } else {
         mainStable = mainStable.replaceAll(thinkRegex, '').trimLeft();
         mainAnimating = mainAnimating.replaceAll(thinkRegex, '');
      }
    }

    final bool hasMainText = mainStable.isNotEmpty || mainAnimating.isNotEmpty;
    final bool hasThink = thinkContent.isNotEmpty;
    final bool hasMedia = embeddedMedia != null;

    if (!hasMainText && !hasMedia && !hasThink) {
      return const SizedBox.shrink();
    }

    final thinkBlock = hasThink
        ? Padding(
            padding: EdgeInsets.only(top: 8 * scale, left: 2.0 * scale, bottom: 4 * scale),
            child: ThoughtProcessWidget(thinkContent: thinkContent, scale: scale),
          )
        : const SizedBox.shrink();

    final mediaBlock = hasMedia
        ? Padding(
            padding: EdgeInsets.only(
                top: 8 * scale, left: 2.0 * scale, right: 2.0 * scale),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: embeddedMedia!,
            ),
          )
        : const SizedBox.shrink();

    final textBlock = hasMainText
        ? Padding(
            padding: EdgeInsets.only(top: 8 * scale, left: 2.0 * scale),
            child: _buildContent(context, scale, mainStable, mainAnimating),
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasThink) thinkBlock,
        if (hasMedia && mediaAboveText) mediaBlock,
        if (hasMainText) textBlock,
        if (hasMedia && !mediaAboveText) mediaBlock,
      ],
    );
  }

  Widget _buildContent(BuildContext context, double s, String stableText, String animatingText) {
    final baseStyle = TextStyle(
        fontSize: 17 * s, height: 1.38, color: AppColors.primaryColor.inverted);

    if (stableText.isEmpty && animatingText.isEmpty) {
      if (message.isWebSearchActive && message.isThinking) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4 * s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16 * s,
                height: 16 * s,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0 * s,
                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(width: 9 * s),
              Text(
                "Aranıyor...",
                style: TextStyle(
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    if (!textAnimCtl.isAnimating && animatingText.isEmpty) {
      return SelectionArea(
        child: Text.rich(
          TextSpan(
            children: _getParsedSpans(context, stableText, s),
            style: baseStyle,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: textAnimCtl,
      builder: (context, child) {
        final markdownText =
            _rebalanceMarkdownBoundary(stableText, animatingText);
        final animValue = textAnimCtl.value;
        final opacity = animValue.clamp(0.0, 1.0);
        final sigma = (1.0 - opacity) * 2.0;

        return SelectionArea(
          child: Text.rich(
            TextSpan(
              style: baseStyle,
              children: [
                ..._getParsedSpans(context, markdownText.stable, s),
                if (markdownText.animating.isNotEmpty)
                  ..._getParsedSpans(context, markdownText.animating, s)
                      .map((span) => _applyOpacity(span, opacity, sigma)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<InlineSpan> _getParsedSpans(
      BuildContext context, String text, double s) {
    if (text.isEmpty) return [];
    final cacheKey =
        '$text:${message.isThinking}:${message.webSearchSources?.length ?? 0}:$s:${AppColors.primaryColor.inverted.toARGB32()}';
    if (parseCache.containsKey(cacheKey)) return parseCache[cacheKey]!;

    final spans = parseText(context, text,
        fontSize: 17 * s,
        isFinished: !message.isThinking,
        citations: message.webSearchSources);

    if (text.length < 1000) parseCache[cacheKey] = spans;
    return spans;
  }

  InlineSpan _applyOpacity(InlineSpan span, double opacity, double sigma) {
    if (span is TextSpan) {
      final baseColor = span.style?.color ?? AppColors.primaryColor.inverted;

      return TextSpan(
        text: span.text,
        children: span.children
            ?.map((child) => _applyOpacity(child, opacity, sigma))
            .toList(),
        style: span.style?.copyWith(
              color: baseColor.withValues(alpha: opacity),
              foreground: null,
            ) ??
            TextStyle(color: baseColor.withValues(alpha: opacity)),
      );
    } else if (span is WidgetSpan) {
      return WidgetSpan(
          alignment: span.alignment,
          baseline: span.baseline,
          child: Opacity(opacity: opacity, child: span.child));
    }
    return span;
  }

  _MarkdownTextParts _rebalanceMarkdownBoundary(
    String stable,
    String animating,
  ) {
    if (stable.isEmpty || animating.isEmpty) {
      return _MarkdownTextParts(stable: stable, animating: animating);
    }

    final delimiterStart = _lastUnclosedDelimiterStart(stable);
    if (delimiterStart == null) {
      return _MarkdownTextParts(stable: stable, animating: animating);
    }

    final lineStart = stable.lastIndexOf('\n', delimiterStart);
    final splitIndex = lineStart < 0 ? 0 : lineStart + 1;

    return _MarkdownTextParts(
      stable: stable.substring(0, splitIndex),
      animating: stable.substring(splitIndex) + animating,
    );
  }

  int? _lastUnclosedDelimiterStart(String text) {
    int? latest;
    for (final delimiter in const ['**', '__', '`']) {
      if (_unescapedDelimiterCount(text, delimiter).isOdd) {
        final index = _lastUnescapedDelimiterIndex(text, delimiter);
        if (index != null && (latest == null || index > latest)) {
          latest = index;
        }
      }
    }
    return latest;
  }

  int _unescapedDelimiterCount(String text, String delimiter) {
    var count = 0;
    var index = 0;
    while (index < text.length) {
      final next = text.indexOf(delimiter, index);
      if (next < 0) break;
      if (!_isEscaped(text, next)) count++;
      index = next + delimiter.length;
    }
    return count;
  }

  int? _lastUnescapedDelimiterIndex(String text, String delimiter) {
    var index = text.length;
    while (index > 0) {
      final next = text.lastIndexOf(delimiter, index - 1);
      if (next < 0) return null;
      if (!_isEscaped(text, next)) return next;
      index = next;
    }
    return null;
  }

  bool _isEscaped(String text, int index) {
    var slashCount = 0;
    var cursor = index - 1;
    while (cursor >= 0 && text.codeUnitAt(cursor) == 0x5c) {
      slashCount++;
      cursor--;
    }
    return slashCount.isOdd;
  }
}

class _MarkdownTextParts {
  final String stable;
  final String animating;

  const _MarkdownTextParts({
    required this.stable,
    required this.animating,
  });
}

class ThoughtProcessWidget extends StatefulWidget {
  final String thinkContent;
  final double scale;

  const ThoughtProcessWidget({
    super.key,
    required this.thinkContent,
    required this.scale,
  });

  @override
  State<ThoughtProcessWidget> createState() => _ThoughtProcessWidgetState();
}

class _ThoughtProcessWidgetState extends State<ThoughtProcessWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.thinkContent.trim().isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.only(bottom: 12 * widget.scale),
      padding: EdgeInsets.only(left: 12 * widget.scale, top: 4 * widget.scale, bottom: 4 * widget.scale),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primaryColor.inverted.withValues(alpha: 0.3),
            width: 3 * widget.scale,
          ),
        ),
      ),
      child: SelectionArea(
        child: Text(
          widget.thinkContent,
          style: TextStyle(
            fontSize: 14 * widget.scale,
            color: AppColors.primaryColor.inverted.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
