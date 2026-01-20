import 'dart:math' as math;
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app.dart';

class WaveformVisualizer extends StatefulWidget {
  const WaveformVisualizer({super.key});

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _history = [];
  static const int _historySize = 60;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to speech service for sound level updates
    final speechService = context.watch<SpeechService>();
    final double level = speechService.soundLevel.clamp(0.0, 1.0);

    // Maintain a history for the traveling wave effect
    if (_history.length >= _historySize) {
      _history.removeAt(0);
    }
    _history.add(level);

    // If history isn't full yet (start), pad it
    while (_history.length < _historySize) {
      _history.insert(0, 0.0);
    }

    return SizedBox(
      height: 50,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ModernWavePainter(
              history: _history,
              animationValue: _controller.value,
              color: AppColors.primaryColor.inverted,
            ),
          );
        },
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

    // We want the wave to flow from Right to Left.
    // The history contains the *newest* samples at the END.
    // So the last element of history is "now" -> should be at the Right edge (width).
    // The first element of history is "oldest" -> should be at the Left edge (0).

    final stepX = width / (history.length - 1);

    path1.moveTo(0, midY);
    path2.moveTo(0, midY);
    path3.moveTo(0, midY);

    for (int i = 0; i < history.length; i++) {
        final double x = i * stepX;
        final double amplitude = history[i];

        // Silence check: explicit 0.0 means straight line
        // But we want a tiny organic movement even in silence to show it's "alive"
        // User requested: "dümdüz çizgi olacak... hiç ses algılanmıyorsa"
        // Let's implement strict straight line if amplitude is near zero
        
        bool isSilent = amplitude < 0.05; // Threshold

        double y1 = midY;
        double y2 = midY;
        double y3 = midY;
        
        if (!isSilent) {
           // Standard wave logic
           // Smooth the amplitude
           double smoothAmp = 0.1 + (amplitude * 0.9);
           double maxDy = (height / 2) * 0.8;

           // Calculate phases (adjusted for right-to-left visual flow preference if needed, 
           // but mapped X is time, so moving left means history shifts left?
           // Actually, history shifts: we add new item to end, remove from start.
           // So index 0 (left) was index 1 previously. So visual data moves LEFT.
           // That matches "Right-to-Left" flow.
           
           double angle1 = (i * 0.2) - (animationValue * 2 * math.pi); // (-) for flow direction
           y1 = midY + math.sin(angle1) * maxDy * smoothAmp;

           double angle2 = (i * 0.4) - (animationValue * 4 * math.pi) + 1.0;
           y2 = midY + math.sin(angle2) * (maxDy * 0.7) * smoothAmp;

           double angle3 = (i * 0.1) + (animationValue * 2 * math.pi) + 2.0;
           y3 = midY + math.sin(angle3) * (maxDy * 0.5) * smoothAmp;
        }

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