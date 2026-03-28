// lib/ui/overflow.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

/// A private utility function to sanitize a string.
String _sanitizeText(String text) {
  return text.replaceAll('\uFFFD', '');
}

/// A versatile text widget that can either:
/// 1. Gracefully truncate text with a fade-out effect (default).
/// 2. Provide a scrollable text area with fog effects on edges (scrollable: true).
class OverflowText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines; // Only applies if scrollable is false

  // --- Fade Mode Params ---
  final int fadeLength;
  final Animation<double>? animation;

  // --- Scroll Mode Params ---
  /// If true, the text will scroll horizontally instead of truncating.
  final bool scrollable;

  /// The width of the fog effect in scrollable mode.
  final double fogWidth;

  const OverflowText({
    super.key,
    required this.text,
    this.style,
    this.maxLines = 1,
    this.fadeLength = 6,
    this.animation,
    this.scrollable = false, // Default to old behavior
    this.fogWidth = 20.0,
  });

  @override
  State<OverflowText> createState() => _OverflowTextState();
}

class _OverflowTextState extends State<OverflowText> {
  // Scroll Controller & Fog State
  late ScrollController _scrollController;
  bool _showStartFog = false;
  bool _showEndFog = false;
  bool _canUseShader = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Only add listener if we are in scrollable mode
    if (widget.scrollable) {
      _scrollController.addListener(_updateFogVisibility);
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          _updateFogVisibility());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.scrollable) {
      _canUseShader = true;
      return;
    }

    final route = ModalRoute.of(context);
    if (route?.animation != null) {
      if (route!.animation!.isCompleted) {
        if (!_canUseShader) {
          setState(() { _canUseShader = true; });
        }
      } else {
        void listener(AnimationStatus status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() { _canUseShader = true; });
            route.animation?.removeStatusListener(listener);
          }
        }
        route.animation!.addStatusListener(listener);
      }
    } else {
      _canUseShader = true;
    }
  }

  @override
  void didUpdateWidget(covariant OverflowText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollable) {
      if (!oldWidget.scrollable) {
        // Switched to scrollable
        _scrollController.addListener(_updateFogVisibility);
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            _updateFogVisibility());
      }
      _updateFogVisibility();
    } else {
      if (oldWidget.scrollable) {
        // Switched off scrollable
        _scrollController.removeListener(_updateFogVisibility);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFogVisibility() {
    if (!mounted || !widget.scrollable) return;
    if (!_scrollController.hasClients) return;

    // Prevent errors during layout/animation changes
    if (_scrollController.positions.length > 1) return;

    final position = _scrollController.position;
    final double threshold = 5.0;

    final bool shouldShowStart = position.pixels > threshold;
    final bool shouldShowEnd = position.maxScrollExtent > 0 &&
        position.pixels < position.maxScrollExtent - threshold;

    if (shouldShowStart != _showStartFog || shouldShowEnd != _showEndFog) {
      setState(() {
        _showStartFog = shouldShowStart;
        _showEndFog = shouldShowEnd;
      });
    }
  }

  // --- Helper: Calculate Fitting Length (Original Logic) ---
  int _findFittingTextLength(String textToMeasure, TextStyle? style,
      BoxConstraints constraints, BuildContext context) {
    final sanitizedText = _sanitizeText(textToMeasure);
    if (sanitizedText.isEmpty) return 0;

    final TextStyle effectiveStyle = style ?? DefaultTextStyle
        .of(context)
        .style;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: sanitizedText, style: effectiveStyle),
      maxLines: widget.maxLines,
      textDirection: ui.TextDirection.ltr,
    );

    final double maxWidth = constraints.maxWidth > 0
        ? constraints.maxWidth
        : double.infinity;
    textPainter.layout(maxWidth: maxWidth);

    if (!textPainter.didExceedMaxLines && textPainter.width <= maxWidth) {
      return sanitizedText.runes.length;
    }

    final runes = sanitizedText.runes.toList();
    int low = 0;
    int high = runes.length;
    int fittingRuneCount = 0;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      if (mid == 0) {
        low = mid + 1;
        continue;
      }
      final testText = String.fromCharCodes(runes.sublist(0, mid));
      final testPainter = TextPainter(
        text: TextSpan(text: testText, style: effectiveStyle),
        maxLines: widget.maxLines,
        textDirection: ui.TextDirection.ltr,
      );
      testPainter.layout(maxWidth: maxWidth);

      if (testPainter.didExceedMaxLines || testPainter.width > maxWidth) {
        high = mid - 1;
      } else {
        fittingRuneCount = mid;
        low = mid + 1;
      }
    }
    return fittingRuneCount;
  }

  @override
  Widget build(BuildContext context) {
    final sanitizedText = _sanitizeText(widget.text);
    final TextStyle effectiveStyle = widget.style ?? DefaultTextStyle
        .of(context)
        .style;

    return LayoutBuilder(
      builder: (context, constraints) {
        // ----------------------------------------------------------
        // MODE 1: SCROLLABLE TEXT (New Logic)
        // ----------------------------------------------------------
        if (widget.scrollable) {
          // Measure text to see if it even needs scrolling
          final TextPainter textPainter = TextPainter(
            text: TextSpan(text: sanitizedText, style: effectiveStyle),
            maxLines: 1,
            textDirection: ui.TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
          )
            ..layout(maxWidth: double.infinity);

          final bool needsScrolling = textPainter.width > constraints.maxWidth;

          // If text fits, just return simple text
          if (!needsScrolling) {
            return Text(
              sanitizedText,
              style: effectiveStyle,
              softWrap: false,
              overflow: TextOverflow.visible,
              maxLines: 1,
            );
          }

          // If text overflows, return the Scrollable + Fog + ShaderMask logic
          // Defer shader masks during sheet transitions
          if (!_canUseShader) {
            return SizedBox(
              height: textPainter.height,
              width: constraints.maxWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  sanitizedText,
                  style: effectiveStyle,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                ),
              ),
            );
          }

          // Use SizedBox with calculated height to prevent jumping alignment issues
          return SizedBox(
            height: textPainter.height,
            width: constraints.maxWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  final double startStop = _showStartFog
                      ? (widget.fogWidth / bounds.width).clamp(0.0, 0.5)
                      : 0.0;
                  final double endStop = _showEndFog
                      ? (1.0 - (widget.fogWidth / bounds.width)).clamp(0.5, 1.0)
                      : 1.0;

                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, startStop, endStop, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Text(
                      sanitizedText,
                      style: effectiveStyle,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // ----------------------------------------------------------
        // MODE 2: TRUNCATE & FADE (Old Logic)
        // ----------------------------------------------------------
        final fittingRuneLength = _findFittingTextLength(
            sanitizedText, widget.style, constraints, context);

        if (fittingRuneLength == 0) {
          return const SizedBox.shrink();
        }

        final totalRunes = sanitizedText.runes.length;

        if (fittingRuneLength >= totalRunes) {
          return Text(
            sanitizedText,
            style: widget.style,
            maxLines: widget.maxLines,
            overflow: TextOverflow.clip,
          );
        }

        // Construct Faded RichText
        final String displayText = String.fromCharCodes(
            sanitizedText.runes.take(fittingRuneLength));
        final int displayRunesLength = displayText.runes.length;
        final int actualCharsToFade = math.min(
            displayRunesLength, widget.fadeLength);

        if (actualCharsToFade <= 0) {
          return Text(
            displayText,
            style: widget.style,
            maxLines: widget.maxLines,
            overflow: TextOverflow.clip,
          );
        }

        final int solidPartRuneLength = displayRunesLength - actualCharsToFade;
        final String solidText = String.fromCharCodes(
            displayText.runes.take(solidPartRuneLength));
        final String fadingText = String.fromCharCodes(
            displayText.runes.skip(solidPartRuneLength));

        final List<InlineSpan> spans = [];
        if (solidText.isNotEmpty) {
          spans.add(TextSpan(text: solidText, style: widget.style));
        }

        final Color defaultColor = DefaultTextStyle
            .of(context)
            .style
            .color ?? Colors.black;
        final Color effectiveColor = widget.style?.color ?? defaultColor;
        final Color baseColorForFade = effectiveColor.withAlpha(255);
        // ignore: deprecated_member_use
        final double originalStyleAlpha = effectiveColor.alpha / 255.0;
        const double fadeTargetMinRelativeOpacity = 0.2;

        final fadingRunes = fadingText.runes.toList();
        for (int i = 0; i < fadingRunes.length; i++) {
          final double relativeFadeProgress = (actualCharsToFade <= 1)
              ? 1.0
              : i / (actualCharsToFade - 1);

          final double charOpacity = originalStyleAlpha * (1.0 -
              relativeFadeProgress * (1.0 - fadeTargetMinRelativeOpacity));
          final double animatedOpacity = (widget.animation?.value ?? 1.0) *
              charOpacity;

          final int newAlpha = (animatedOpacity * 255).round().clamp(0, 255);

          final TextStyle? charStyle = widget.style?.copyWith(
            color: baseColorForFade.withAlpha(newAlpha),
          );

          spans.add(TextSpan(
            text: String.fromCharCode(fadingRunes[i]),
            style: charStyle,
          ));
        }

        return RichText(
          text: TextSpan(children: spans),
          maxLines: widget.maxLines,
          overflow: TextOverflow.clip,
        );
      },
    );
  }
}