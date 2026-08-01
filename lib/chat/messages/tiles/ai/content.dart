part of '../ai.dart';

class _AiBodyContent extends StatelessWidget {
  static final _thinkTag = 'think';
  static final _leadingColons = RegExp(r'^[\s:]+');

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

    String mainStable = stableText;
    String mainAnimating = animatingText;

    final thinkStart = fullText.indexOf('<$_thinkTag>');
    if (thinkStart != -1) {
      final contentStart = thinkStart + '<$_thinkTag>'.length;
      final thinkEnd = fullText.indexOf('</$_thinkTag>', contentStart);
      final contentEnd = thinkEnd != -1 ? thinkEnd : fullText.length;
      thinkContent = fullText.substring(contentStart, contentEnd).trim();
      final blockEnd = thinkEnd != -1 ? thinkEnd + '</$_thinkTag>'.length : fullText.length;
      final beforeThink = fullText.substring(0, thinkStart);
      final afterThink = fullText.substring(blockEnd);
      final remaining = beforeThink + afterThink;
      if (remaining.length <= stableText.length) {
        mainStable = remaining;
        mainAnimating = '';
      } else {
        mainStable = remaining.substring(0, stableText.length);
        mainAnimating = remaining.substring(stableText.length);
      }
      mainStable = mainStable.replaceFirst(_leadingColons, '');
      if (mainStable.isEmpty) mainAnimating = mainAnimating.replaceFirst(_leadingColons, '');
    }

    final bool hasMainText = mainStable.isNotEmpty || mainAnimating.isNotEmpty;
    final bool hasThink = thinkContent.isNotEmpty;
    final bool hasMedia = embeddedMedia != null;

    if (!hasMainText && !hasMedia && !hasThink) return const SizedBox.shrink();

    final thinkBlock = hasThink
        ? Padding(
            padding: EdgeInsets.only(top: 8 * scale, left: 2.0 * scale, bottom: 4 * scale),
            child: ThoughtProcessWidget(thinkContent: thinkContent, scale: scale))
        : const SizedBox.shrink();

    final mediaBlock = hasMedia
        ? Padding(
            padding: EdgeInsets.only(top: 8 * scale, left: 2.0 * scale, right: 2.0 * scale),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: embeddedMedia!,
            ))
        : const SizedBox.shrink();

    final textBlock = hasMainText
        ? Padding(
            padding: EdgeInsets.only(top: 8 * scale, left: 2.0 * scale),
            child: _buildContent(context, scale, mainStable, mainAnimating))
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
                width: 16 * s, height: 16 * s,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0 * s,
                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(width: 9 * s),
              Text(
                AppLocalizations.of(context)?.searching ?? "Searching...",
                style: TextStyle(fontSize: 15 * s, fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor.inverted.withValues(alpha: 0.5)),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    if (!textAnimCtl.isAnimating && animatingText.isEmpty) {
      return RepaintBoundary(
        child: SelectionArea(
          child: Text.rich(
            TextSpan(children: _getParsedSpans(context, stableText, s), style: baseStyle),
          ),
        ),
      );
    }

    final md = _rebalanceMarkdownBoundary(stableText, animatingText);
    return RepaintBoundary(
      child: SelectionArea(
        child: AnimatedBuilder(
          animation: textAnimCtl,
          builder: (context, child) {
            final animValue = textAnimCtl.value;
            final opacity = animValue.clamp(0.0, 1.0);

            return Text.rich(
              TextSpan(
                style: baseStyle,
                children: [
                  ..._getParsedSpans(context, md.stable, s),
                  if (md.animating.isNotEmpty)
                    ..._getAnimatingSpans(context, md.animating, s, opacity),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<InlineSpan> _getAnimatingSpans(
      BuildContext context, String text, double s, double opacity) {
    if (text.isEmpty) return [];
    final spans = _getParsedSpans(context, text, s);
    return spans.map((span) => _applyOpacity(span, opacity)).toList(growable: false);
  }

  List<InlineSpan> _getParsedSpans(BuildContext context, String text, double s) {
    if (text.isEmpty) return [];
    final colorKey = AppColors.primaryColor.inverted.toARGB32();
    final citationKey = message.webSearchSources?.length ?? 0;
    final cacheKey = '$text:${message.isThinking}:$citationKey:$s:$colorKey';
    if (parseCache.containsKey(cacheKey)) return parseCache[cacheKey]!;
    final spans = parseText(context, text,
        fontSize: 17 * s, isFinished: !message.isThinking,
        citations: message.webSearchSources);
    parseCache[cacheKey] = spans;
    if (parseCache.length > 500) {
      parseCache.remove(parseCache.keys.first);
    }
    return spans;
  }

  InlineSpan _applyOpacity(InlineSpan span, double opacity) {
    if (span is TextSpan) {
      final baseColor = span.style?.color ?? AppColors.primaryColor.inverted;
      return TextSpan(
        text: span.text,
        children: span.children?.map((c) => _applyOpacity(c, opacity)).toList(growable: false),
        style: span.style?.copyWith(color: baseColor.withValues(alpha: opacity), foreground: null) ??
            TextStyle(color: baseColor.withValues(alpha: opacity)),
      );
    } else if (span is WidgetSpan) {
      return WidgetSpan(alignment: span.alignment, baseline: span.baseline,
          child: Opacity(opacity: opacity, child: span.child));
    }
    return span;
  }

  _MarkdownTextParts _rebalanceMarkdownBoundary(String stable, String animating) {
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
        if (index != null && (latest == null || index > latest)) latest = index;
      }
    }
    return latest;
  }

  int _unescapedDelimiterCount(String text, String delimiter) {
    var count = 0, index = 0;
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
    var slashCount = 0, cursor = index - 1;
    while (cursor >= 0 && text.codeUnitAt(cursor) == 0x5c) { slashCount++; cursor--; }
    return slashCount.isOdd;
  }
}

class _MarkdownTextParts {
  final String stable;
  final String animating;
  const _MarkdownTextParts({required this.stable, required this.animating});
}

class ThoughtProcessWidget extends StatefulWidget {
  final String thinkContent;
  final double scale;
  const ThoughtProcessWidget({super.key, required this.thinkContent, required this.scale});

  @override
  State<ThoughtProcessWidget> createState() => _ThoughtProcessWidgetState();
}

class _ThoughtProcessWidgetState extends State<ThoughtProcessWidget> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animCtl;
  late Animation<double> _arrowTurns;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _animCtl = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _arrowTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animCtl, curve: Curves.easeInOut));
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _contentSlide = Tween<Offset>(begin: const Offset(0.0, -0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtl, curve: Curves.easeOutQuad));
  }

  @override
  void dispose() { _animCtl.dispose(); super.dispose(); }

  void _toggleExpand() {
    if (widget.thinkContent.trim().isEmpty) return;
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) _animCtl.forward(); else _animCtl.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.thinkContent.trim();
    if (content.isEmpty) return const SizedBox.shrink();
    final localizations = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12 * widget.scale),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primaryColor.inverted.withValues(alpha: 0.3), width: 3 * widget.scale),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpand, borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.only(left: 12 * widget.scale, top: 4 * widget.scale,
                    bottom: 2 * widget.scale, right: 4 * widget.scale),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(localizations?.thought ?? 'Thought',
                      style: TextStyle(fontSize: 13 * widget.scale, fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor.inverted.withValues(alpha: 0.5))),
                    const SizedBox(width: 6),
                    RotationTransition(turns: _arrowTurns,
                      child: Icon(Icons.keyboard_arrow_down, size: 18 * widget.scale,
                          color: AppColors.primaryColor.inverted.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: CurvedAnimation(parent: _animCtl, curve: Curves.easeInOut),
            alignment: Alignment.centerLeft,
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Padding(
                  padding: EdgeInsets.only(left: 12 * widget.scale, right: 4 * widget.scale, bottom: 4 * widget.scale),
                  child: SelectionArea(
                    child: Text(content,
                      style: TextStyle(fontSize: 14 * widget.scale,
                          color: AppColors.primaryColor.inverted.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic, height: 1.5)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
