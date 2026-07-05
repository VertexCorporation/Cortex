import 'package:flutter/material.dart';

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final Gradient gradient;
  final Duration animationDuration;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 2.0,
    this.borderRadius = 8.0,
    this.gradient = const SweepGradient(
      colors: [
        Colors.transparent,
        Colors.transparent,
        Colors.white30,
        Colors.white,
        Colors.white30,
        Colors.transparent,
        Colors.transparent,
      ],
      stops: [0.0, 0.4, 0.45, 0.5, 0.55, 0.6, 1.0],
    ),
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(widget.borderWidth),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(widget.borderRadius + widget.borderWidth),
            gradient: SweepGradient(
              transform: GradientRotation(_controller.value * 2 * 3.1415926535),
              colors: widget.gradient.colors,
              stops: widget.gradient.stops,
            ),
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
