// lib/fog.dart

import 'package:cortex/theme.dart';
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
  late final AnimationController _topController;
  late final AnimationController _bottomController;
  late final Animation<double> _topOpacity;
  late final Animation<double> _bottomOpacity;

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

    _topOpacity =
        CurvedAnimation(parent: _topController, curve: Curves.easeOut);
    _bottomOpacity =
        CurvedAnimation(parent: _bottomController, curve: Curves.easeOut);

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
      if (_isTopVisible) {
        _isTopVisible = false;
        _topController.reverse();
      }
      if (_isBottomVisible) {
        _isBottomVisible = false;
        _bottomController.reverse();
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

    if (_isTopVisible != shouldShowTop) {
      _isTopVisible = shouldShowTop;
      if (shouldShowTop) {
        // Start from 0.1 to give immediate feedback, then fade to 1.0
        _topController.forward(from: 0.1);
      } else {
        _topController.reverse();
      }
    }

    if (_isBottomVisible != shouldShowBottom) {
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
    return Stack(
      children: [
        // 1. Content stays at the bottom, untouched
        Positioned.fill(child: widget.child),

        // 2. Top Fog Overlay
        if (widget.showTop)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: widget.topFogHeight,
            child: AnimatedBuilder(
              animation: _topOpacity,
              builder: (context, child) {
                // If opacity is effectively zero, don't paint
                if (_topOpacity.value <= 0.01) return const SizedBox.shrink();
                return Opacity(
                  opacity: _topOpacity.value,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    // Non-linear gradient for smoother "fog" feel
                    stops: const [0.0, 0.4, 1.0],
                    colors: [
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0.8),
                      AppColors.background.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 3. Bottom Fog Overlay
        if (widget.showBottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: widget.bottomFogHeight,
            child: AnimatedBuilder(
              animation: _bottomOpacity,
              builder: (context, child) {
                if (_bottomOpacity.value <= 0.01) {
                  return const SizedBox.shrink();
                }
                return Opacity(
                  opacity: _bottomOpacity.value,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.4, 1.0],
                    colors: [
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0.8),
                      AppColors.background.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
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

class _ScrollFogHorizontalState extends State<ScrollFogHorizontal>
    with TickerProviderStateMixin {
  late final AnimationController _startController;
  late final AnimationController _endController;
  late final Animation<double> _startOpacity;
  late final Animation<double> _endOpacity;

  bool _isStartVisible = false;
  bool _isEndVisible = false;

  @override
  void initState() {
    super.initState();
    _startController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _endController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _startOpacity =
        CurvedAnimation(parent: _startController, curve: Curves.easeOut);
    _endOpacity =
        CurvedAnimation(parent: _endController, curve: Curves.easeOut);

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
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _updateFogVisibility() {
    if (!mounted) return;
    final controller = widget.scrollController;

    if (!controller.hasClients) {
      if (_isStartVisible) {
        _isStartVisible = false;
        _startController.reverse();
      }
      if (_isEndVisible) {
        _isEndVisible = false;
        _endController.reverse();
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

    if (_isStartVisible != shouldShowStart) {
      _isStartVisible = shouldShowStart;
      if (shouldShowStart) {
        _startController.forward(from: 0.1);
      } else {
        _startController.reverse();
      }
    }

    if (_isEndVisible != shouldShowEnd) {
      _isEndVisible = shouldShowEnd;
      if (shouldShowEnd) {
        _endController.forward(from: 0.1);
      } else {
        _endController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: widget.child),
        if (widget.showStart)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: widget.startFogWidth,
            child: AnimatedBuilder(
              animation: _startOpacity,
              builder: (context, child) {
                if (_startOpacity.value <= 0.01) return const SizedBox.shrink();
                return Opacity(
                  opacity: _startOpacity.value,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.4, 1.0],
                    colors: [
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0.8),
                      AppColors.background.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (widget.showEnd)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: widget.endFogWidth,
            child: AnimatedBuilder(
              animation: _endOpacity,
              builder: (context, child) {
                if (_endOpacity.value <= 0.01) return const SizedBox.shrink();
                return Opacity(
                  opacity: _endOpacity.value,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    stops: const [0.0, 0.4, 1.0],
                    colors: [
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0.8),
                      AppColors.background.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
