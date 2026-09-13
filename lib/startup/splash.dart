// lib/startup/splash.dart
//
// The animated Cortex startup splash and its startup-readiness state machine:
//
//   native launch screen
//     → first Flutter frame: static, native-matching Cortex diamond
//     → morph animation starts immediately (single ticker, one controller)
//     → startup not ready?  the pre-final polygon cycle loops seamlessly
//     → startup becomes ready mid-loop: the CURRENT transition finishes
//       naturally, then the NEXT transition morphs into the final Cortex
//     → Cortex is held very briefly → onComplete (gatekeeper crossfades out)
//
// Invariants:
// - The final Cortex icon is only ever held once startup is actually ready.
// - Loop exits happen exclusively at transition boundaries; no morph is ever
//   interrupted, no frame ever jumps, and completion fires exactly once.
// - Every transition is a full 360° turn; directions strictly alternate.
// - One controller, lazily cached geometry, no per-frame widget rebuilds.

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pure timeline math for one morph transition. Shape ids are polygon side
/// counts; 4 is the rounded Cortex logo.
class SplashTimeline {
  /// Canonical cycle: Cortex → pentagon → … → decagon → Cortex.
  static const states = [4, 5, 6, 7, 8, 9, 10, 4];

  static const firstShape = 4;
  static const lastShape = 10;

  /// One transition: the approved 2940ms timeline / 7 equal segments.
  static const segmentDuration = Duration(milliseconds: 420);

  /// One full pass of the polygon cycle.
  static const loopDuration = Duration(milliseconds: 420 * 7);

  /// Brief rest on the final Cortex icon before completion is reported.
  static const finalHold = Duration(milliseconds: 360);

  /// Quintic ease-in-out of the approved animation. Velocity is zero at both
  /// ends, so every boundary — including loop seams — is continuous.
  static double eased(double local) => local < .5
      ? 16 * math.pow(local, 5).toDouble()
      : 1 - math.pow(-2 * local + 2, 5).toDouble() / 2;

  /// Every transition is a complete 360° turn; only the sign varies. Inputs
  /// outside a single transition are clamped, never wrapped.
  static double rotation(double local, double direction) {
    final t = local < 0 ? 0.0 : (local > 1 ? 1.0 : local);
    return direction * math.pi * 2 * eased(t);
  }

  /// Canonical successor inside the cycle (decagon folds back to Cortex).
  static int nextShape(int shape) =>
      shape < lastShape ? shape + 1 : firstShape;

  /// Strictly alternating rotation: clockwise → counter-clockwise → …
  /// The running transition index never resets — not even when the polygon
  /// cycle loops — so alternation holds across loop seams and through the
  /// final exit transition.
  static double directionFor(int transitionIndex) =>
      transitionIndex.isEven ? 1 : -1;
}

/// The live transition source shared between the splash state and the
/// painter. The state mutates it exactly at controller boundaries and
/// restarts the ticker in the same synchronous turn, so the painter renders
/// every frame straight from the ticker without widget rebuilds. The last
/// frame of a transition and the first frame of the next one are
/// pixel-identical: same shape, rotation 2π ≡ 0, pulse faded out.
class SplashFrame {
  SplashFrame({
    this.from = SplashTimeline.firstShape,
    this.to = SplashTimeline.firstShape + 1,
    this.direction = 1,
  });

  int from;
  int to;
  double direction;
}

class CortexStartupSplash extends StatefulWidget {
  const CortexStartupSplash({
    super.key,
    required this.onComplete,
    this.ready = false,
  });

  /// Fires exactly once, when the final Cortex icon has been reached and the
  /// brief hold is over. Remove the splash from the widget tree on it.
  final VoidCallback onComplete;

  /// Startup readiness. A rising edge requests a graceful loop exit: the
  /// current transition finishes naturally, then the NEXT transition morphs
  /// into the final Cortex icon. Cortex is never held before this is true.
  final bool ready;

  @override
  State<CortexStartupSplash> createState() => _CortexStartupSplashState();
}

class _CortexStartupSplashState extends State<CortexStartupSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: SplashTimeline.segmentDuration)
        ..addStatusListener(_onTransitionStatus);
  late final SplashGeometry _geometry = SplashGeometry();
  final SplashFrame _frame = SplashFrame();

  int _transitionIndex = 0;
  bool _started = false;
  bool _ready = false;
  bool _exitPending = false;
  bool _finalTransition = false;
  bool _reducedMotion = false;
  bool _completed = false;
  Timer? _holdTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // First submitted Flutter frame is the static native-matching diamond.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reducedMotion = MediaQuery.disableAnimationsOf(context);
      if (_reducedMotion) {
        // Accessibility: skip straight to the static final Cortex icon.
        _exitPending = true;
        _frame
          ..from = SplashTimeline.lastShape
          ..to = SplashTimeline.firstShape
          ..direction = SplashTimeline.directionFor(0);
        _finalTransition = true;
        _controller.value = 1;
        return;
      }
      if (widget.ready) _exitPending = true;
      _beginTransition(
        from: SplashTimeline.firstShape,
        to: SplashTimeline.nextShape(SplashTimeline.firstShape),
        isFinal: false,
      );
    });
  }

  @override
  void didUpdateWidget(covariant CortexStartupSplash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ready || !widget.ready) return;
    // Startup became ready: request a graceful exit from the loop. The
    // current transition is never interrupted; the next boundary takes it.
    _ready = true;
    if (!_completed) _exitPending = true;
  }

  void _onTransitionStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _completed) return;
    if (_finalTransition ||
        (_exitPending && _frame.to == SplashTimeline.firstShape)) {
      // The current transition just landed on the final Cortex icon.
      _holdFinal();
      return;
    }
    // Advance the loop — only ever at a boundary, never mid-morph.
    _transitionIndex++;
    final from = _frame.to;
    final exitNow = _exitPending;
    _beginTransition(
      from: from,
      to: exitNow ? SplashTimeline.firstShape : SplashTimeline.nextShape(from),
      isFinal: exitNow,
    );
  }

  void _beginTransition({
    required int from,
    required int to,
    required bool isFinal,
  }) {
    _frame
      ..from = from
      ..to = to
      ..direction = SplashTimeline.directionFor(_transitionIndex);
    _finalTransition = isFinal;
    // Restarting at 0 renders pixels identical to the frame the controller
    // just completed, so boundaries and loop seams are invisible.
    _controller.forward(from: 0);
  }

  void _holdFinal() {
    if (_completed) return;
    if (_reducedMotion) {
      _complete();
      return;
    }
    _holdTimer?.cancel();
    _holdTimer = Timer(SplashTimeline.finalHold, _complete);
  }

  void _complete() {
    if (_completed) return;
    _completed = true;
    _holdTimer?.cancel();
    _holdTimer = null;
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Native launch screens use system brightness, before saved preferences load.
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: dark ? Colors.black : Colors.white,
        child: Center(
          child: RepaintBoundary(
            child: SizedBox.square(
              dimension: 288,
              child: CustomPaint(
                painter: CortexSplashPainter(
                  progress: _controller,
                  geometry: _geometry,
                  frame: _frame,
                  foreground: dark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paths are in the real assets/cortex.svg 16-unit coordinate system.
/// Ring samples are built once per shape, on first use, and cached, so the
/// first frame only pays for the native-matching Cortex shape instead of the
/// whole polygon family. All vertex, metric and sample allocations happen
/// once, outside paint.
class SplashGeometry {
  static const samples = 560;
  final List<List<Float64List>?> _rings = List.filled(7, null);

  List<Float64List> ring(int sides) => _rings[sides - 4] ??= [
    _sample(sides == 4 ? cortexOuter() : regularPolygon(sides, 8, .65)),
    _sample(sides == 4 ? cortexInner() : regularPolygon(sides, 4.2, .45)),
  ];

  static Path cortexOuter() => Path()
    ..moveTo(8, 0)
    ..lineTo(9.02, 0)
    ..cubicTo(9.44, 0, 9.84, .17, 10.14, .46)
    ..lineTo(15.53, 5.85)
    ..cubicTo(15.83, 6.15, 15.99, 6.55, 15.99, 6.97)
    ..lineTo(15.99, 9.02)
    ..cubicTo(15.99, 9.44, 15.83, 9.84, 15.53, 10.14)
    ..lineTo(10.14, 15.53)
    ..cubicTo(9.84, 15.83, 9.44, 15.99, 9.02, 15.99)
    ..lineTo(6.97, 15.99)
    ..cubicTo(6.55, 15.99, 6.15, 15.83, 5.85, 15.53)
    ..lineTo(.46, 10.14)
    ..cubicTo(.17, 9.84, 0, 9.44, 0, 9.02)
    ..lineTo(0, 6.97)
    ..cubicTo(0, 6.55, .17, 6.15, .46, 5.85)
    ..lineTo(5.85, .46)
    ..cubicTo(6.15, .17, 6.55, 0, 6.97, 0)
    ..close();

  static Path cortexInner() => Path()
    ..moveTo(8, 3.815)
    ..cubicTo(8.405, 3.815, 8.81, 3.97, 9.12, 4.28)
    ..lineTo(11.71, 6.88)
    ..cubicTo(12.33, 7.50, 12.33, 8.50, 11.71, 9.12)
    ..lineTo(9.12, 11.71)
    ..cubicTo(8.50, 12.33, 7.50, 12.33, 6.88, 11.71)
    ..lineTo(4.28, 9.12)
    ..cubicTo(3.66, 8.50, 3.66, 7.50, 4.28, 6.88)
    ..lineTo(6.88, 4.28)
    ..cubicTo(7.19, 3.97, 7.595, 3.815, 8, 3.815)
    ..close();

  static Path regularPolygon(int sides, double radius, double rounding) {
    final vertices = List.generate(sides, (i) {
      final angle = -math.pi / 2 + i * 2 * math.pi / sides;
      return Offset(8 + math.cos(angle) * radius, 8 + math.sin(angle) * radius);
    });
    final path = Path();
    // Begin at the middle of the rounded top corner to align perimeter phases.
    final top = vertices.first;
    final before =
        top + (vertices.last - top) * rounding / (vertices.last - top).distance;
    final after =
        top + (vertices[1] - top) * rounding / (vertices[1] - top).distance;
    final midpoint = (before + top * 2 + after) / 4;
    path.moveTo(midpoint.dx, midpoint.dy);
    final control = (top + after) / 2;
    path.quadraticBezierTo(control.dx, control.dy, after.dx, after.dy);
    for (var i = 1; i < sides; i++) {
      final v = vertices[i];
      final previous = vertices[i - 1];
      final next = vertices[(i + 1) % sides];
      final enter = v + (previous - v) * rounding / (previous - v).distance;
      final leave = v + (next - v) * rounding / (next - v).distance;
      path.lineTo(enter.dx, enter.dy);
      path.quadraticBezierTo(v.dx, v.dy, leave.dx, leave.dy);
    }
    path.lineTo(before.dx, before.dy);
    final lastControl = (before + top) / 2;
    path.quadraticBezierTo(
      lastControl.dx,
      lastControl.dy,
      midpoint.dx,
      midpoint.dy,
    );
    return path..close();
  }

  static Float64List _sample(Path path) {
    final metric = path.computeMetrics().first;
    final points = Float64List(samples * 2);
    for (var i = 0; i < samples; i++) {
      final p = metric
          .getTangentForOffset(metric.length * i / samples)!
          .position;
      points[i * 2] = p.dx - 8;
      points[i * 2 + 1] = p.dy - 8;
    }
    return points;
  }
}

class CortexSplashPainter extends CustomPainter {
  CortexSplashPainter({
    required this.progress,
    required this.geometry,
    required this.frame,
    required this.foreground,
  }) : super(repaint: progress) {
    _glow.shader = ui.Gradient.radial(
      Offset.zero,
      1,
      [foreground.withValues(alpha: .065), foreground.withValues(alpha: 0)],
      [0, 1],
    );
  }
  final Animation<double> progress;
  final SplashGeometry geometry;
  final SplashFrame frame;
  final Color foreground;
  final Path _ring = Path();
  final Paint _fill = Paint();
  final Paint _pulse = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.15;
  final Paint _glow = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final raw = progress.value;
    final t = raw < 0 ? 0.0 : (raw > 1 ? 1.0 : raw);
    final wave = math.sin(math.pi * t);
    final morph = SplashTimeline.eased(t);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    if (t > 0 && t < 1) {
      final radius = 52 * (1.08 + .44 * Curves.easeOutCubic.transform(t));
      canvas.save();
      canvas.scale(radius * 1.3);
      _glow.color = Colors.white.withValues(alpha: wave);
      canvas.drawCircle(Offset.zero, 1, _glow);
      canvas.restore();
      _pulse.color = foreground.withValues(alpha: wave * .11);
      canvas.drawCircle(Offset.zero, radius, _pulse);
      // The orbiting dot is intentionally gone; the expanding ring and soft
      // glow keep their exact style and timing.
    }
    canvas.rotate(SplashTimeline.rotation(t, frame.direction));
    // 16 source units × 8 = 128 logical pixels, shared with native launch assets.
    final scale = 8 * (1 + wave * .038);
    canvas.scale(scale);
    _ring.reset();
    _ring.fillType = PathFillType.evenOdd;
    final a = geometry.ring(frame.from);
    // At t == 0 nothing of the target shape is visible yet, so the static
    // first frame only builds the geometry it actually shows.
    final b = t == 0 ? a : geometry.ring(frame.to);
    for (var contour = 0; contour < 2; contour++) {
      final from = a[contour];
      final to = b[contour];
      for (var i = 0; i < from.length; i += 2) {
        final x = from[i] + (to[i] - from[i]) * morph;
        final y = from[i + 1] + (to[i + 1] - from[i + 1]) * morph;
        if (i == 0) {
          _ring.moveTo(x, y);
        } else {
          _ring.lineTo(x, y);
        }
      }
      _ring.close();
    }
    _fill.color = foreground;
    canvas.drawPath(_ring, _fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CortexSplashPainter oldDelegate) =>
      oldDelegate.foreground != foreground ||
      oldDelegate.progress != progress ||
      !identical(oldDelegate.frame, frame);
}
