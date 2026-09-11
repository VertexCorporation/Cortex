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
  final VoidCallback? onContinue;

  const _AiBodyContent({
    required this.message,
    this.embeddedMedia,
    required this.mediaAboveText,
    required this.reveal,
    required this.scale,
    required this.parseCache,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    String fullText = reveal.visibleText;
    String thinkContent = '';

    String mainText = fullText;

    // Whether the reasoning stream has actually closed (the `</think>` tag
    // has been revealed) — the true reasoning lifecycle, independent of the
    // block's expand/collapse state below.
    bool thinkClosed = false;

    final thinkStartMatch = _thinkStart.firstMatch(fullText);
    if (thinkStartMatch != null) {
      final contentStart = thinkStartMatch.end;
      final thinkEndMatch =
          _thinkEnd.firstMatch(fullText.substring(contentStart));
      final thinkEnd =
          thinkEndMatch == null ? -1 : contentStart + thinkEndMatch.start;
      final contentEnd = thinkEnd != -1 ? thinkEnd : fullText.length;

      thinkContent = fullText.substring(contentStart, contentEnd).trim();
      thinkClosed = thinkEnd != -1;

      mainText =
          _withoutThinkingBlocks(fullText).replaceFirst(_leadingColons, '');
    }

    final bool hasMainText = mainText.isNotEmpty;
    final bool hasThink = thinkContent.isNotEmpty;
    final bool hasMedia = embeddedMedia != null;
    final bool hasToolActivity =
        message.toolActivity.isNotEmpty || message.toolSteps.isNotEmpty;
    final bool hasIncompleteNotice =
        message.isIncomplete && !message.isThinking && !message.isError;

    if (!hasMainText &&
        !hasMedia &&
        !hasThink &&
        !hasToolActivity &&
        !hasIncompleteNotice) {
      return const SizedBox.shrink();
    }

    final thinkBlock = hasThink
        ? Padding(
            padding: EdgeInsets.only(
                top: 8 * scale, left: 2.0 * scale, bottom: 4 * scale),
            // The SAME presentation pipeline the markdown think blocks use
            // (ThinkingWidget), driven here by the reasoning stream's real
            // lifecycle: `isFinished` is true only once the `</think>` tag
            // has been revealed (or the message itself finalized), so the
            // label shimmers "Thinking" exactly while tokens are still
            // arriving and then cross-fades to "Thought". Passing the tile's
            // shared [reveal] timeline makes the reasoning text run through
            // the same RevealText glyph animation as the main answer.
            child: ThinkingWidget(
              content: thinkContent,
              isFinished: thinkClosed || !message.isThinking,
              scale: scale,
              reveal: reveal,
            ),
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
        if (hasIncompleteNotice)
          Padding(
            padding: EdgeInsets.only(top: 6 * scale, left: 2.0 * scale),
            child: _TruncationNotice(
              scale: scale,
              onContinue: onContinue,
            ),
          ),
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

/// Compact inline notice shown when the server explicitly reported that the
/// response was cut short (`finish_reason: "length"` / `"content_filter"` or
/// a stream that ended without a finish chunk). Rendered from the persisted
/// `isIncomplete` marker, so the truncation stays visible after the chat is
/// reopened instead of a partial answer masquerading as a complete one.
/// When [onContinue] is provided, the notice carries a "Continue generating"
/// action that resumes the response exactly where the model stopped.
class _TruncationNotice extends StatelessWidget {
  final double scale;
  final VoidCallback? onContinue;

  const _TruncationNotice({required this.scale, this.onContinue});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.content_cut,
              size: 13 * scale,
              color: AppColors.tertiaryColor,
            ),
            SizedBox(width: 5 * scale),
            Flexible(
              child: Text(
                localizations.responseTruncatedNotice,
                style: TextStyle(
                  color: AppColors.tertiaryColor,
                  fontSize: 13 * scale,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        if (onContinue != null)
          Padding(
            padding: EdgeInsets.only(top: 2 * scale, left: 2.0 * scale),
            child: SizedBox(
              height: 26 * scale,
              child: TextButton.icon(
                onPressed: onContinue,
                icon: Icon(
                  Icons.play_arrow,
                  size: 14 * scale,
                  color: AppColors.tertiaryColor,
                ),
                label: Text(
                  localizations.continueGenerating,
                  style: TextStyle(
                    color: AppColors.tertiaryColor,
                    fontSize: 13 * scale,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.symmetric(
                      horizontal: 6 * scale, vertical: 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
