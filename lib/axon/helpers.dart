// lib/axon/widgets/helpers.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import '../app.dart';

// --- 1. ANIMATED AVATAR ---
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
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _borderAnimation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_borderController);

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
    Widget core = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.quaternaryColor,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.initials,
        style: TextStyle(
          fontSize: widget.fontSize * 1.0,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor.inverted,
        ),
      ),
    );

    if (widget.isSubscribed) {
      return AnimatedBuilder(
        animation: _borderAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter:
            AnimatedBorderPainter(animationValue: _borderAnimation.value),
            child: Padding(
              padding: const EdgeInsets.all(3.0), // Space for border
              child: child,
            ),
          );
        },
        child: core,
      );
    }

    return core;
  }
}

// --- 2. ANIMATED BORDER PAINTER ---
class AnimatedBorderPainter extends CustomPainter {
  final double animationValue;

  AnimatedBorderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.0;
    final Rect rect = Offset.zero & size;
    final double radius = size.width / 2;

    // Gradient colors
    final List<Color> colors = [
      Colors.cyanAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.cyanAccent,
    ];

    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: colors,
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(animationValue),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(Offset(radius, radius), radius - strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}