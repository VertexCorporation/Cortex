part of '../ai.dart';

class _AiBodyContent extends StatelessWidget {
  static final _leadingColons = RegExp(r'^[\s:]+');
  static final _thinkStart = RegExp(r'<think\b[^>]*>', caseSensitive: false);
  static final _thinkEnd = RegExp(r'</think\s*>', caseSensitive: false);

  final Message message;
  final Widget? embeddedMedia;
  final bool mediaAboveText;
  final RevealTimeline reveal;
  final double scale;
  final Map<String, List<InlineSpan>> parseCache;

  const _AiBodyContent({
    required this.message,
    this.embeddedMedia,
    required this.mediaAboveText,
    required this.reveal,
    required this.scale,
    required this.parseCache,
  });

  @override
  Widget build(BuildContext context) {
    String fullText = reveal.visibleText;
    String thinkContent = '';

    String mainText = fullText;

    final thinkStartMatch = _thinkStart.firstMatch(fullText);
    if (thinkStartMatch != null) {
      final contentStart = thinkStartMatch.end;
      final thinkEndMatch =
          _thinkEnd.firstMatch(fullText.substring(contentStart));
      final thinkEnd =
          thinkEndMatch == null ? -1 : contentStart + thinkEndMatch.start;
      final contentEnd = thinkEnd != -1 ? thinkEnd : fullText.length;

      thinkContent = fullText.substring(contentStart, contentEnd).trim();

      mainText =
          _withoutThinkingBlocks(fullText).replaceFirst(_leadingColons, '');
    }

    final bool hasMainText = mainText.isNotEmpty;
    final bool hasThink = thinkContent.isNotEmpty;
    final bool hasMedia = embeddedMedia != null;
    final bool hasToolActivity =
        message.toolActivity.isNotEmpty || message.toolSteps.isNotEmpty;

    if (!hasMainText && !hasMedia && !hasThink && !hasToolActivity) {
      return const SizedBox.shrink();
    }

    final thinkBlock = hasThink
        ? Padding(
            padding: EdgeInsets.only(
                top: 8 * scale, left: 2.0 * scale, bottom: 4 * scale),
            child:
                ThoughtProcessWidget(thinkContent: thinkContent, scale: scale),
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

    final toolBlock = hasToolActivity
        ? Padding(
            padding: EdgeInsets.only(
                top: 4 * scale, left: 2.0 * scale, bottom: 2 * scale),
            child: ToolActivityWidget(
              activeTool: message.toolActivity,
              steps: message.toolSteps,
            ),
          )
        : const SizedBox.shrink();

    final textBlock = hasMainText
        ? SizedBox(
            // Keep the paragraph's horizontal constraint stable while its
            // reveal grows. Without this, short prefixes repeatedly change
            // their intrinsic width and the message tile appears to wobble.
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(top: 3 * scale, left: 2.0 * scale),
              child: _buildContent(context, scale, mainText),
            ),
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasThink) thinkBlock,
        if (hasToolActivity) toolBlock,
        if (hasMedia && mediaAboveText) mediaBlock,
        if (hasMainText) textBlock,
        if (hasMedia && !mediaAboveText) mediaBlock,
      ],
    );
  }

  String _withoutThinkingBlocks(String text) {
    final result = StringBuffer();
    var cursor = 0;
    while (cursor < text.length) {
      final start = _thinkStart.firstMatch(text.substring(cursor));
      if (start == null) {
        result.write(text.substring(cursor));
        break;
      }

      final startOffset = cursor + start.start;
      result.write(text.substring(cursor, startOffset));
      final contentStart = cursor + start.end;
      final end = _thinkEnd.firstMatch(text.substring(contentStart));
      if (end == null) break;
      cursor = contentStart + end.end;
    }
    return result.toString();
  }

  Widget _buildContent(BuildContext context, double s, String text) {
    final baseStyle = TextStyle(
        fontSize: 17 * s, height: 1.38, color: AppColors.primaryColor.inverted);
    // Parsing runs only when the visible source changes. Fade-only ticks are
    // listened to by the glyph painter and never rebuild this tree.
    final spans = _getParsedSpans(context, text, s);
    return RepaintBoundary(
      child: SelectionArea(
        child: RevealText(
          timeline: reveal,
          text: TextSpan(style: baseStyle, children: spans),
        ),
      ),
    );
  }

  List<InlineSpan> _getParsedSpans(
      BuildContext context, String text, double s) {
    if (text.isEmpty) return [];
    final colorKey = AppColors.primaryColor.inverted.toARGB32();
    final citationKey = message.webSearchSources.toString();
    final cacheKey = '$text:${reveal.visualComplete}:$citationKey:$s:$colorKey';
    if (parseCache.containsKey(cacheKey)) return parseCache[cacheKey]!;

    final spans = parseText(context, text,
        fontSize: 17 * s,
        isFinished: reveal.visualComplete,
        citations: message.webSearchSources);

    parseCache[cacheKey] = spans;
    if (parseCache.length > 8) {
      final key = parseCache.keys.first;
      parseCache.remove(key);
    }
    return spans;
  }
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

class _ThoughtProcessWidgetState extends State<ThoughtProcessWidget>
    with TickerProviderStateMixin {
  bool _isExpanded = false;

  late AnimationController _arrowController;
  late Animation<double> _arrowTurns;

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _arrowTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _contentFade =
        Tween<double>(begin: 0.0, end: 1.0).animate(_contentController);
    _contentSlide =
        Tween<Offset>(begin: const Offset(0.0, -0.1), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutQuad));
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (widget.thinkContent.trim().isEmpty) {
      return;
    }
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _arrowController.forward();
        _contentController.forward();
      } else {
        _arrowController.reverse();
        _contentController.reverse();
      }
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
            color: AppColors.primaryColor.inverted.withValues(alpha: 0.3),
            width: 3 * widget.scale,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpand,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 12 * widget.scale,
                    top: 4 * widget.scale,
                    bottom: 2 * widget.scale,
                    right: 4 * widget.scale),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizations?.thought ?? 'Thought',
                      style: TextStyle(
                        fontSize: 13 * widget.scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    RotationTransition(
                      turns: _arrowTurns,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: CortexDesign.icon,
                        color: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: _contentController,
              curve: Curves.easeInOut,
            ),
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 12 * widget.scale,
                      right: 4 * widget.scale,
                      bottom: 4 * widget.scale),
                  child: SelectionArea(
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 14 * widget.scale,
                        color: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
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
