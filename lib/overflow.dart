// lib/ui/overflow.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _updateFogVisibility());
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
          setState(() {
            _canUseShader = true;
          });
        }
      } else {
        void listener(AnimationStatus status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() {
              _canUseShader = true;
            });
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
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _updateFogVisibility());
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

  @override
  Widget build(BuildContext context) {
    final sanitizedText = _sanitizeText(widget.text);
    final TextStyle effectiveStyle =
        widget.style ?? DefaultTextStyle.of(context).style;

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
          )..layout(maxWidth: double.infinity);

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
        // MODE 2: TRUNCATE & FADE (GPU-Accelerated ShaderMask)
        // ----------------------------------------------------------
        // PERFORMANCE: Replaced CPU-heavy binary search TextPainter
        // measurement (O(log n) TextPainter allocations per tile) with
        // a GPU-accelerated ShaderMask fade. This eliminates ~7
        // TextPainter.layout() calls per sidebar tile.

        // First, check if text even overflows
        final TextStyle effectiveStyleForMeasure =
            widget.style ?? DefaultTextStyle.of(context).style;
        final TextPainter measurePainter = TextPainter(
          text: TextSpan(text: sanitizedText, style: effectiveStyleForMeasure),
          maxLines: widget.maxLines,
          textDirection: ui.TextDirection.ltr,
        );
        measurePainter.layout(
            maxWidth: constraints.maxWidth > 0
                ? constraints.maxWidth
                : double.infinity);

        // If text fits without overflow, render simply
        if (!measurePainter.didExceedMaxLines &&
            measurePainter.width <= constraints.maxWidth) {
          return Text(
            sanitizedText,
            style: widget.style,
            maxLines: widget.maxLines,
            overflow: TextOverflow.clip,
          );
        }

        // Text overflows — use ShaderMask for GPU-accelerated fade
        // Calculate fade fraction: fadeLength chars worth of fade at the end
        final double fadeWidthFraction = widget.fadeLength > 0
            ? (widget.fadeLength *
                    (effectiveStyleForMeasure.fontSize ?? 14.0) *
                    0.6 /
                    constraints.maxWidth)
                .clamp(0.05, 0.3)
            : 0.15;

        final double animMultiplier = widget.animation?.value ?? 1.0;
        final double fadeStop = (1.0 - fadeWidthFraction).clamp(0.5, 1.0);

        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black,
                Colors.black,
                Colors.black.withAlpha((255 * 0.2 * animMultiplier).round()),
              ],
              stops: [0.0, fadeStop, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Text(
            sanitizedText,
            style: widget.style,
            maxLines: widget.maxLines,
            overflow: TextOverflow.clip,
            softWrap: widget.maxLines > 1,
          ),
        );
      },
    );
  }
}
