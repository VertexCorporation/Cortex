// lib/chat/screen/widgets/cortex_image_loader.dart

import 'dart:math' as math;

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';

/// A from-scratch, Cortex-branded loading animation shown while an image is
/// being generated. It features the Cortex logo with a pulsing glow and an
/// orbiting sweep-gradient ring drawn in the app's brand colors.
///
/// This replaces the previous generic shimmer + dot-grid placeholder so the
/// generation state reads as uniquely Cortex.
class CortexImageLoader extends StatefulWidget {
  final double size;
  final double borderRadius;

  const CortexImageLoader({
    super.key,
    required this.size,
    this.borderRadius = 24.0,
  });

  @override
  State<CortexImageLoader> createState() => _CortexImageLoaderState();
}

class _CortexImageLoaderState extends State<CortexImageLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String logoAsset =
        isDark ? 'assets/cortex/white.png' : 'assets/cortex/black.png';

    final Color ringColor = AppColors.senaryColor;
    final Color accentColor = AppColors.premium;

    return Container(
      width: widget.size,
      height: widget.size,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: AppColors.tertiaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Görsel oluşturuluyor",
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Center(
            child: SizedBox(
              width: widget.size * 0.5,
              height: widget.size * 0.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size.square(widget.size * 0.5),
                        painter: _OrbitRingPainter(
                          progress: _controller.value,
                          color: ringColor,
                          accentColor: accentColor,
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final t = _controller.value;
                      final wave = (0.5 - (t - 0.5).abs()) * 2; // 0..1..0
                      return Transform.scale(
                        scale: 0.9 + 0.1 * wave,
                        child: Opacity(
                          opacity: 0.8 + 0.2 * wave,
                          child: Image.asset(
                            logoAsset,
                            width: widget.size * 0.28,
                            height: widget.size * 0.28,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Draws a faint base ring plus an orbiting sweep-gradient arc in brand colors.
class _OrbitRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color accentColor;

  _OrbitRingPainter({
    required this.progress,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 2, basePaint);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.0),
          accentColor,
          color,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final startAngle = progress * 2 * math.pi;
    const sweep = math.pi / 1.5; // ~120° arc
    canvas.drawArc(rect, startAngle, sweep, false, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.accentColor != accentColor;
}
