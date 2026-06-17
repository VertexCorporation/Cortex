import 'dart:math' as math;
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart'; // [NEW]
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import for Ticker
import 'package:provider/provider.dart';

import '../../../app.dart';

enum WaveOrigin { right, center }

class WaveformVisualizer extends StatefulWidget {
  final Color? color;
  final WaveOrigin origin; // [NEW] Control origin
  final bool simulatePlaying;

  const WaveformVisualizer({
    super.key,
    this.color,
    this.origin = WaveOrigin.right, // Default to old behavior (Right)
    this.simulatePlaying = false,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformNotifier extends ChangeNotifier {
  void update() => notifyListeners();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<double> _history = [];
  static const int _historySize = 60;
  double _animationValue = 0.0;
  final _WaveformNotifier _notifier = _WaveformNotifier();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)
      ..start();
    for (int i = 0; i < _historySize; i++) {
      _history.add(0.0);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _notifier.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    _animationValue = (elapsed.inMilliseconds % 2000) / 2000.0;
    _updateHistory();
    _notifier.update();
  }

  void _updateHistory() {
    final speechService = context.read<SpeechService>();
    final voiceService = context.read<VoiceService>();

    double rawLevel = 0.0;
    
    if (widget.simulatePlaying) {
      final double time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final double sine = math.sin(time * 15.0).abs();
      final double noise = math.Random().nextDouble();
      rawLevel = 0.2 + (sine * 0.4) + (noise * 0.2);
    } else {

      if (voiceService.state == VoiceState.speaking ||
          voiceService.state == VoiceState.processing) {
        final double time = DateTime
            .now()
            .millisecondsSinceEpoch / 1000.0;
        final double sine = math.sin(time * 15.0).abs();
        final double noise = math.Random().nextDouble();

        if (voiceService.state == VoiceState.processing) {
          // [FIX] Lower idle amplitude
          rawLevel = 0.05 + (math.sin(time * 3.0).abs() * 0.05);
        } else {
          rawLevel = 0.2 + (sine * 0.4) + (noise * 0.2);
        }
      } else {
        // [FIX] Ensure we handle low levels gracefully
        rawLevel = (speechService.soundLevel * 15.0).clamp(0.0, 1.0);
      }
    }

    if (_history.length >= _historySize) {
      _history.removeAt(0);
    }
    _history.add(rawLevel);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: CustomPaint(
        repaint: _notifier,
        painter: _ModernWavePainter(
          history: _history,
          animationValue: _animationValue,
          color: widget.color ?? AppColors.primaryColor.inverted,
          origin: widget.origin,
        ),
      ),
    );
  }
}

class _ModernWavePainter extends CustomPainter {
  final List<double> history;
  final double animationValue;
  final Color color;
  final WaveOrigin origin;

  _ModernWavePainter({
    required this.history,
    required this.animationValue,
    required this.color,
    required this.origin,
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

    path1.moveTo(0, midY);
    path2.moveTo(0, midY);
    path3.moveTo(0, midY);

    // We process points.
    // If Center: We create a symmetric wave.
    // To do this, we map history[0] to Center, and history[N] to Edges?
    // OR history[N] (Newest) to Center, and history[0] to Edges.
    // "Spread from Center" -> Newest at Center.

    // If Right: Newest at Right Edge. (Current Behavior)

    // Standard loop computes AMPLITUDE from history[i].
    // We just need to determine X per i.

    // Actually, drawing Path requires sequential MoveTo/LineTo.
    // So we iterate Pixels/Steps from 0 to Width (Left to Right).
    // And for each X, we fetch Amplitude from History.

    // Case Right: X=0 maps to history[0], X=Width maps to history[Last].

    // Case Center:
    // Center=Width/2.
    // X=Center maps to history[Last] (Peak/Newest).
    // X=0 and X=Width map to history[0] (Oldest).
    // distance = abs(X - Center).
    // normalizedDist = distance / (Width/2). (0 at Center, 1 at Edge).
    // historyIndex = Last * (1 - normalizedDist).

    // Let's iterate X from 0 to Width with granular steps.
    int steps = 100; // Resolution
    double stepSize = width / steps;

    path1.reset();
    path2.reset();
    path3.reset();
    path1.moveTo(0, midY);
    path2.moveTo(0, midY);
    path3.moveTo(0, midY);

    for (int s = 0; s <= steps; s++) {
      double x = s * stepSize;
      double historyIndexFloat;

      if (origin == WaveOrigin.center) {
        // Center Origin logic
        double centerX = width / 2;
        double dist = (x - centerX).abs(); // 0 to Width/2
        double norm = 1.0 - (dist / (width / 2)); // 1.0 at center, 0.0 at edge
        if (norm < 0) norm = 0;
        historyIndexFloat = (history.length - 1) * norm;
      } else {
        // Right Origin logic (Standard)
        // 0 -> 0, Width -> Last
        double norm = s / steps;
        historyIndexFloat = (history.length - 1) * norm;
      }

      // Interpolate history value
      int idxLow = historyIndexFloat.floor().clamp(0, history.length - 1);
      int idxHigh = (idxLow + 1).clamp(0, history.length - 1);
      double t = historyIndexFloat - idxLow;
      double amplitude = history[idxLow] * (1 - t) + history[idxHigh] * t;

      // Rest of the math (Damping etc)
      // [Adjusted] Damping needs to handle Center case (dampen at edges).

      double minAmplitude = 0.02; // [FIX] Reduced floor
      double effectiveAmplitude = math.max(amplitude, minAmplitude);
      double smoothAmp = 0.1 + (effectiveAmplitude * 0.9);
      double maxDy = (height / 2) * 0.8;

      // Apply Edge Damping
      // If Center: Dampen ends (x=0, x=width).
      // If Right: Dampen Left? No, current logic dampened Right edge to 0?
      // Wait, original logic:
      // "normalizedPos = i / length... if > 0.8 -> rightDamp"
      // "Force last point to 0".
      // This forces the wave to pinch at the "Source" (Right)?
      // Or pinch at the leading edge?
      // Usually wave pinch is at the old tail (Left).
      // But code pinched Right.
      // Let's pinch BOTH ends for safety.

      double edgeDamp = 1.0;
      double progress = s / steps; // 0..1

      // Dampen near 0
      if (progress < 0.1) edgeDamp *= (progress / 0.1);
      // Dampen near 1
      if (progress > 0.9) edgeDamp *= ((1.0 - progress) / 0.1);

      smoothAmp *= edgeDamp;

      double angle1 = (s * 0.2) - (animationValue * 2 * math.pi);
      double y1 = midY + math.sin(angle1) * maxDy * smoothAmp;

      double angle2 = (s * 0.4) - (animationValue * 4 * math.pi) + 1.0;
      double y2 = midY + math.sin(angle2) * (maxDy * 0.7) * smoothAmp;

      double angle3 = (s * 0.1) + (animationValue * 2 * math.pi) + 2.0;
      double y3 = midY + math.sin(angle3) * (maxDy * 0.5) * smoothAmp;

      if (s == 0) {
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
