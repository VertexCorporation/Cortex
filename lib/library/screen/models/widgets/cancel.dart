// cancel.dart

import 'package:flutter/material.dart';

class AnimatedCancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final Color borderColor;
  final String text;
  final double fontSize;
  final double strokeFactor;

  const AnimatedCancelButton({
    super.key,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.borderColor,
    required this.text,
    required this.fontSize,
    this.strokeFactor = 0.01,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = width == double.infinity ? constraints.maxWidth : width;
        final dynamicStrokeWidth = effectiveWidth * strokeFactor;
        return SizedBox(
          width: width,
          height: height,
          child: AnimatedBorder(
            borderColor: borderColor,
            strokeWidth: dynamicStrokeWidth,
            borderRadius: borderRadius,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: EdgeInsets.zero,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedBorder extends StatefulWidget {
  final Widget child;
  final Color borderColor;
  final double strokeWidth;
  final double borderRadius;
  final Duration duration;

  const AnimatedBorder({
    super.key,
    required this.child,
    required this.borderColor,
    required this.strokeWidth,
    required this.borderRadius,
    this.duration = const Duration(seconds: 2),
  });

  @override
  AnimatedBorderState createState() => AnimatedBorderState();
}

class AnimatedBorderState extends State<AnimatedBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: RotatingBorderPainter(
        animation: _controller,
        borderColor: widget.borderColor,
        strokeWidth: widget.strokeWidth,
        borderRadius: widget.borderRadius,
      ),
      child: widget.child,
    );
  }
}

class RotatingBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final Color borderColor;
  final double strokeWidth;
  final double borderRadius;

  RotatingBorderPainter({
    required this.animation,
    required this.borderColor,
    required this.strokeWidth,
    required this.borderRadius,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rrect);

    // Calculate total border length and dash segment length (40% of total)
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final totalLength = metrics.fold<double>(0, (prev, metric) => prev + metric.length);
    final dashLength = totalLength * 0.4;
    final offset = animation.value * totalLength;

    double remaining = dashLength;
    double currentOffset = offset % totalLength;
    final dashedPath = Path();

    // Iterate through each metric to extract the dash segment.
    for (final metric in metrics) {
      if (currentOffset > metric.length) {
        currentOffset -= metric.length;
        continue;
      }
      final double extractLength = (currentOffset + remaining <= metric.length)
          ? remaining
          : metric.length - currentOffset;
      dashedPath.addPath(metric.extractPath(currentOffset, currentOffset + extractLength), Offset.zero);
      remaining -= extractLength;
      if (remaining <= 0) break;
      currentOffset = 0;
    }
    // Wrap-around: if part of the dash spills over, extract from the start.
    if (remaining > 0 && metrics.isNotEmpty) {
      final firstMetric = metrics.first;
      final double extractLength = remaining.clamp(0, firstMetric.length).toDouble();
      dashedPath.addPath(firstMetric.extractPath(0.0, extractLength), Offset.zero);
    }

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant RotatingBorderPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}