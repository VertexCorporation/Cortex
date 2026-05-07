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
    final bool hasText = stableText.isNotEmpty || animatingText.isNotEmpty;
    final bool hasMedia = embeddedMedia != null;

    if (!hasText && !hasMedia) {
      return const SizedBox.shrink();
    }

    final mediaBlock = hasMedia
        ? Padding(
            padding: EdgeInsets.only(
                top: 8 * scale, left: 2.0 * scale, right: 2.0 * scale),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color:
                      AppColors.primaryColor.inverted.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
                child: embeddedMedia!,
              ),
            ),
          )
        : const SizedBox.shrink();

    final textBlock = hasText
        ? Padding(
            padding: EdgeInsets.only(top: 8 * scale, left: 2.0 * scale),
            child: _buildContent(context, scale),
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasMedia && mediaAboveText) mediaBlock,
        if (hasText) textBlock,
        if (hasMedia && !mediaAboveText) mediaBlock,
      ],
    );
  }

  Widget _buildContent(BuildContext context, double s) {
    final baseStyle = TextStyle(
        fontSize: 16 * s, height: 1.35, color: AppColors.primaryColor.inverted);

    if (stableText.isEmpty && animatingText.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!textAnimCtl.isAnimating && animatingText.isEmpty) {
      return SelectionArea(
        child: Text.rich(
          TextSpan(
            children: _getParsedSpans(context, stableText),
            style: baseStyle,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: textAnimCtl,
      builder: (context, child) {
        final animValue = textAnimCtl.value;
        final opacity = animValue.clamp(0.0, 1.0);
        final sigma = (1.0 - opacity) * 2.0;

        return SelectionArea(
          child: Text.rich(
            TextSpan(
              style: baseStyle,
              children: [
                ..._getParsedSpans(context, stableText),
                if (animatingText.isNotEmpty)
                  ..._getParsedSpans(context, animatingText)
                      .map((span) => _applyOpacity(span, opacity, sigma)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<InlineSpan> _getParsedSpans(BuildContext context, String text) {
    if (text.isEmpty) return [];
    final cacheKey =
        '$text:${message.isThinking}:${message.webSearchSources?.length ?? 0}';
    if (parseCache.containsKey(cacheKey)) return parseCache[cacheKey]!;

    final spans = parseText(context, text,
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
}
