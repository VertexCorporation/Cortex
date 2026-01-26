import 'dart:math' as math;
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import for Ticker
import 'package:provider/provider.dart';

import '../../../app.dart';

class WaveformVisualizer extends StatefulWidget {
  final Color? color;
  const WaveformVisualizer({super.key, this.color});

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<double> _history = [];
  static const int _historySize = 60;

  // Animation state for the continuous flow
  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    // Use Ticker to drive the animation loop ~60fps
    _ticker = createTicker(_onTick)..start();

    // Pre-fill history with zeros
    for (int i = 0; i < _historySize; i++) {
      _history.add(0.0);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    // Update animation value for phase shifting
    // 2PI every 2 seconds roughly
    _animationValue = (elapsed.inMilliseconds % 2000) / 2000.0;

    // Update history
    _updateHistory();

    // Trigger repaint
    setState(() {});
  }

  void _updateHistory() {
    // Get current sound level from provider
    final speechService = context.read<SpeechService>();
    final double rawLevel = speechService.soundLevel.clamp(0.0, 1.0);

    // Shift history
    if (_history.length >= _historySize) {
      _history.removeAt(0); // Remove oldest (Left)
    }
    _history.add(rawLevel); // Add newest (Right)
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: CustomPaint(
        painter: _ModernWavePainter(
          history: _history,
          animationValue: _animationValue,
          color: widget.color ?? AppColors.primaryColor.inverted,
        ),
      ),
    );
  }
}

class _ModernWavePainter extends CustomPainter {
  final List<double> history;
  final double animationValue;
  final Color color;

  _ModernWavePainter({
    required this.history,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    final path2 = Path();
    final path3 = Path();

    final width = size.width;
    final height = size.height;
    final midY = height / 2;

    final stepX = width / (history.length - 1);

    path1.moveTo(0, midY);
    path2.moveTo(0, midY);
    path3.moveTo(0, midY);

    for (int i = 0; i < history.length; i++) {
      final double x = i * stepX;
      final double amplitude = history[i];

      // Always animate, even if silent (Idle state)
      // Base amplitude for "breathing" effect
      double minAmplitude = 0.05;
      double effectiveAmplitude = math.max(amplitude, minAmplitude);

      double y1 = midY;
      double y2 = midY;
      double y3 = midY;

      double smoothAmp = 0.1 + (effectiveAmplitude * 0.9);
      double maxDy = (height / 2) * 0.8;

      // Apply dampening to the right side (where index is near length)
      // normalizedPos = i / (length - 1). 0(Left)..1(Right).
      double normalizedPos = i / (history.length - 1);
      double rightDamp = 1.0;

      // Linear fade out for the last 20% of points to ensure perfect connection
      // at the right edge
      if (normalizedPos > 0.8) {
        rightDamp = (1.0 - normalizedPos) / 0.2;
      }

      // Force the very last point to be exactly 0 (or close enough)
      if (i == history.length - 1) rightDamp = 0.0;

      smoothAmp *= rightDamp;

      double angle1 = (i * 0.2) - (animationValue * 2 * math.pi);
      y1 = midY + math.sin(angle1) * maxDy * smoothAmp;

      double angle2 = (i * 0.4) - (animationValue * 4 * math.pi) + 1.0;
      y2 = midY + math.sin(angle2) * (maxDy * 0.7) * smoothAmp;

      double angle3 = (i * 0.1) + (animationValue * 2 * math.pi) + 2.0;
      y3 = midY + math.sin(angle3) * (maxDy * 0.5) * smoothAmp;

      if (i == 0) {
        path1.moveTo(x, y1);
        path2.moveTo(x, y2);
        path3.moveTo(x, y3);
      } else {
        path1.lineTo(x, y1);
        path2.lineTo(x, y2);
        path3.lineTo(x, y3);
      }
    }

    paint.color = color.withValues(alpha: 0.8);
    canvas.drawPath(path1, paint);

    paint.color = color.withValues(alpha: 0.5);
    paint.strokeWidth = 1.5;
    canvas.drawPath(path2, paint);

    paint.color = color.withValues(alpha: 0.3);
    paint.strokeWidth = 1.0;
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(_ModernWavePainter oldDelegate) => true;
}
