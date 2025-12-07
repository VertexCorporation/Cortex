// lib/fog.dart
// A flexible widget that listens to a ScrollController to dynamically add
// top, bottom, or both fog effects over any scrollable content.

import 'package:flutter/material.dart';

class ScrollFog extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final Color fogColor;
  final double topFogHeight;
  final double bottomFogHeight;
  final double scrollThreshold;

  /// Determines if the top fog effect should be enabled. Defaults to true.
  final bool showTop;

  /// Determines if the bottom fog effect should be enabled. Defaults to true.
  final bool showBottom;

  const ScrollFog({
    super.key,
    required this.child,
    required this.scrollController,
    this.fogColor = Colors.black,
    this.topFogHeight = 40.0,
    this.bottomFogHeight = 70.0,
    this.scrollThreshold = 10.0,
    this.showTop = true,
    this.showBottom = true,
  });

  @override
  State<ScrollFog> createState() => _ScrollFogState();
}

class _ScrollFogState extends State<ScrollFog> {
  bool _showTopFog = false;
  bool _showBottomFog = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateFogVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFogVisibility());
  }

  @override
  void didUpdateWidget(covariant ScrollFog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      oldWidget.scrollController.removeListener(_updateFogVisibility);
      widget.scrollController.addListener(_updateFogVisibility);
      _updateFogVisibility();
    }
    // Also re-check visibility if the showTop/showBottom props change.
    if (widget.showTop != oldWidget.showTop || widget.showBottom != oldWidget.showBottom) {
      _updateFogVisibility();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateFogVisibility);
    super.dispose();
  }

  void _updateFogVisibility() {
    if (!mounted) return;
    final controller = widget.scrollController;

    if (!controller.hasClients) {
      if (_showBottomFog || _showTopFog) {
        setState(() {
          _showBottomFog = false;
          _showTopFog = false;
        });
      }
      return;
    }

    // --- FIX: Handle multiple attached positions ---
    // If attached to multiple views (e.g. during animations), try to use the most relevant one.
    // Usually, `controller.position` throws if multiple exist.
    // We safely grab the last attached position which is typically the active one.

    ScrollPosition position;
    try {
      position = controller.position;
    } catch (_) {
      // If multiple positions are attached, use the last one (most likely the visible one).
      if (controller.positions.isNotEmpty) {
        position = controller.positions.last;
      } else {
        return; // Should not happen if hasClients is true
      }
    }

    final bool shouldShowTop = widget.showTop && position.pixels > widget.scrollThreshold;
    final bool shouldShowBottom = widget.showBottom &&
        position.maxScrollExtent > 0 &&
        position.pixels < position.maxScrollExtent - widget.scrollThreshold;

    if (shouldShowTop != _showTopFog || shouldShowBottom != _showBottomFog) {
      setState(() {
        _showTopFog = shouldShowTop;
        _showBottomFog = shouldShowBottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Top fog effect.
        if (widget.showTop)
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _showTopFog ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  height: widget.topFogHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [widget.fogColor.withValues(alpha:0.0), widget.fogColor],
                      stops: const [0.0, 0.9],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Bottom fog effect.
        if (widget.showBottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _showBottomFog ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  height: widget.bottomFogHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [widget.fogColor.withValues(alpha:0.0), widget.fogColor],
                      stops: const [0.0, 0.9],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}