// lib/axon/helpers.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/app.dart';

// --- 1. ANIMATED AVATAR ---
/// A clean avatar that shows the user's first letter directly inside a circle
/// with NO inner frame. Premium users get a rainbow gradient effect on the
/// RIGHT HALF of the outer circle border.
class AxonAvatar extends StatefulWidget {
  final String initials;
  final bool isSubscribed;
  final double size;
  final double fontSize;

  const AxonAvatar({
    super.key,
    required this.initials,
    required this.isSubscribed,
    required this.size,
    required this.fontSize,
  });

  @override
  State<AxonAvatar> createState() => _AxonAvatarState();
}

class _AxonAvatarState extends State<AxonAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.isSubscribed) {
      _borderController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AxonAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSubscribed && !oldWidget.isSubscribed) {
      _borderController.repeat();
    } else if (!widget.isSubscribed && oldWidget.isSubscribed) {
      _borderController.stop();
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double totalSize = widget.size;

    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Premium rainbow ring on the RIGHT half only
          if (widget.isSubscribed)
            OverflowBox(
              maxHeight: totalSize,
              minHeight: totalSize,
              maxWidth: totalSize + 1.6,
              minWidth: totalSize + 1.6,
              child: AnimatedBuilder(
                animation: _borderController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(totalSize + 1.6, totalSize),
                    painter: _RightHalfRainbowPainter(
                      animationValue: _borderController.value * 2 * math.pi,
                    ),
                  );
                },
              ),
            ),

          // Core circle — just the letter, no inner container/frame
          Text(
            widget.initials,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor.inverted,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

// --- 2. RIGHT-HALF RAINBOW RING PAINTER ---
/// Draws a rotating rainbow gradient arc on the right half of the circle.
class _RightHalfRainbowPainter extends CustomPainter {
  final double animationValue;

  _RightHalfRainbowPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.0;
    final double radius = size.height / 2;
    // Center of the right semicircle
    final Offset center = Offset(size.width - radius, radius);

    // Rainbow gradient colors
    final List<Color> colors = [
      const Color(0xFFFF0080), // Pink
      const Color(0xFFFF4D4D), // Red
      const Color(0xFFFFAA00), // Orange
      const Color(0xFFFFDD00), // Yellow
      const Color(0xFF00CC76), // Green
      const Color(0xFF00AAFF), // Cyan
      const Color(0xFF7B61FF), // Purple
      const Color(0xFFFF0080), // Pink (loop)
    ];

    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: colors,
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(animationValue),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final double arcRadius = radius - strokeWidth / 2;

    // Start at top left (divider), go to top center, then arc to bottom center, then go to bottom left (divider)
    path.moveTo(0, strokeWidth / 2);
    path.lineTo(center.dx, strokeWidth / 2);
    path.arcTo(
      Rect.fromCircle(center: center, radius: arcRadius),
      -math.pi / 2, // start angle (top)
      math.pi, // sweep angle (right half, 180°)
      false, // connect to previous point
    );
    path.lineTo(0, size.height - strokeWidth / 2);

    // Save layer to apply fade-out mask near the divider
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    canvas.drawPath(path, paint);

    // Create a fade mask that goes from transparent at the divider (x=0) to opaque at x=center.dx
    final Paint maskPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.transparent, Colors.white],
        stops: [0.0, 0.7],
      ).createShader(Rect.fromLTWH(0, 0, center.dx, size.height))
      ..blendMode = BlendMode.dstIn;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), maskPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RightHalfRainbowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
