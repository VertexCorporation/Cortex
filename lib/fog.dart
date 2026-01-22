// lib/fog.dart

import 'package:flutter/material.dart';

// --- VERTICAL FOG ---
class ScrollFog extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final double topFogHeight;
  final double bottomFogHeight;
  final double scrollThreshold;
  final bool showTop;
  final bool showBottom;

  const ScrollFog({
    super.key,
    required this.child,
    required this.scrollController,
    this.topFogHeight = 40.0,
    this.bottomFogHeight = 70.0,
    this.scrollThreshold = 10.0,
    this.showTop = true,
    this.showBottom = true,
  });

  @override
  State<ScrollFog> createState() => _ScrollFogState();
}

class _ScrollFogState extends State<ScrollFog> with TickerProviderStateMixin {
  late AnimationController _topController;
  late AnimationController _bottomController;
  late Animation<double> _topOpacity;
  late Animation<double> _bottomOpacity;

  bool _isTopVisible = false;
  bool _isBottomVisible = false;

  @override
  void initState() {
    super.initState();

    _topController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bottomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _topOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_topController);
    _bottomOpacity =
        Tween<double>(begin: 0.0, end: 1.0).animate(_bottomController);

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
    if (widget.showTop != oldWidget.showTop ||
        widget.showBottom != oldWidget.showBottom) {
      _updateFogVisibility();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateFogVisibility);
    _topController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  void _updateFogVisibility() {
    if (!mounted) return;
    final controller = widget.scrollController;

    if (!controller.hasClients) {
      if (_isTopVisible || _isBottomVisible) {
        _topController.reverse();
        _bottomController.reverse();
        _isTopVisible = false;
        _isBottomVisible = false;
      }
      return;
    }

    if (controller.positions.length > 1) return;

    final position = controller.position;
    final bool hasDimensions = position.hasContentDimensions;

    final bool shouldShowTop = widget.showTop &&
        hasDimensions &&
        position.pixels > widget.scrollThreshold;

    final bool shouldShowBottom = widget.showBottom &&
        hasDimensions &&
        position.maxScrollExtent > 0 &&
        position.pixels < position.maxScrollExtent - widget.scrollThreshold;

    if (shouldShowTop != _isTopVisible) {
      _isTopVisible = shouldShowTop;
      if (shouldShowTop) {
        _topController.forward(from: 0.1);
      } else {
        _topController.reverse();
      }
    }

    if (shouldShowBottom != _isBottomVisible) {
      _isBottomVisible = shouldShowBottom;
      if (shouldShowBottom) {
        _bottomController.forward(from: 0.1);
      } else {
        _bottomController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_topController, _bottomController]),
      builder: (context, child) {
        final double topVal = _topOpacity.value;
        final double bottomVal = _bottomOpacity.value;

        if (topVal == 0.0 && bottomVal == 0.0) {
          return widget.child;
        }

        return ShaderMask(
          shaderCallback: (Rect bounds) {
            // We keep the stops consistent but change the "black" color opacity effectively by using transparency in gradient?
            // Actually, ShaderMask with dstIn uses alpha channel.
            // So if we want to fade IN the masking effect (which creates transparency), it's tricky.
            // Wait, dstIn means the source (gradient) alpha defines the destination (child) alpha.
            // Transparent in gradient = Transparent in child. Black (solid) in gradient = Opaque in child.
            // To "disable" fog (child visible), we need Solid everywhere.
            // To "enable" fog (top transparent), top part of gradient is Transparent.

            // So if opacity is 0 (no fog), top should be Solid (Black).
            // If opacity is 1 (full fog), top should be Transparent.

            // Let's interpolate the "Transparent" color towards "Black" based on (1 - opacity).

            final double topStop =
                (widget.topFogHeight / bounds.height).clamp(0.0, 0.5);
            final double bottomStop =
                (1.0 - (widget.bottomFogHeight / bounds.height))
                    .clamp(0.5, 1.0);

            final Color topColor =
                Color.lerp(Colors.black, Colors.transparent, topVal)!;
            final Color bottomColor =
                Color.lerp(Colors.black, Colors.transparent, bottomVal)!;

            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                topColor,
                Colors.black,
                Colors.black,
                bottomColor,
              ],
              stops: [
                0.0,
                topStop,
                bottomStop,
                1.0,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: widget.child,
        );
      },
    );
  }
}

// --- HORIZONTAL FOG ---
class ScrollFogHorizontal extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;

  final double startFogWidth;
  final double endFogWidth;
  final double scrollThreshold;
  final bool showStart;
  final bool showEnd;

  const ScrollFogHorizontal({
    super.key,
    required this.child,
    required this.scrollController,
    this.startFogWidth = 20.0,
    this.endFogWidth = 40.0,
    this.scrollThreshold = 5.0,
    this.showStart = true,
    this.showEnd = true,
  });

  @override
  State<ScrollFogHorizontal> createState() => _ScrollFogHorizontalState();
}

class _ScrollFogHorizontalState extends State<ScrollFogHorizontal> {
  bool _showStartFog = false;
  bool _showEndFog = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateFogVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFogVisibility());
  }

  @override
  void didUpdateWidget(covariant ScrollFogHorizontal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      oldWidget.scrollController.removeListener(_updateFogVisibility);
      widget.scrollController.addListener(_updateFogVisibility);
      _updateFogVisibility();
    }
    if (widget.showStart != oldWidget.showStart ||
        widget.showEnd != oldWidget.showEnd) {
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
      if (_showStartFog || _showEndFog) {
        setState(() {
          _showStartFog = false;
          _showEndFog = false;
        });
      }
      return;
    }

    if (controller.positions.length > 1) return;

    final position = controller.position;

    final bool shouldShowStart =
        widget.showStart && position.pixels > widget.scrollThreshold;

    final bool shouldShowEnd = widget.showEnd &&
        position.maxScrollExtent > 0 &&
        position.pixels < position.maxScrollExtent - widget.scrollThreshold;

    if (shouldShowStart != _showStartFog || shouldShowEnd != _showEndFog) {
      setState(() {
        _showStartFog = shouldShowStart;
        _showEndFog = shouldShowEnd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showStartFog && !_showEndFog) {
      return widget.child;
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        final double startStop = _showStartFog
            ? (widget.startFogWidth / bounds.width).clamp(0.0, 0.5)
            : 0.0;

        final double endStop = _showEndFog
            ? (1.0 - (widget.endFogWidth / bounds.width)).clamp(0.5, 1.0)
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
          stops: [
            0.0,
            startStop,
            endStop,
            1.0,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: widget.child,
    );
  }
}
