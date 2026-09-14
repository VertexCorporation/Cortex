// lib/chat/screen/widgets/voice_orb.dart
//
// The Voice Mode V2 orb: a GPU fragment-shader visual (see
// shaders/voice_orb.frag) driven by a long-lived controller.
//
// Design constraints this file enforces:
//  * ONE cached, prewarmed FragmentProgram for the whole process — the first
//    visible transition never pays the shader compile;
//  * the controller owns a Ticker and smooths the microphone amplitude with
//    an EMA — audio levels NEVER rebuild the widget tree, they only repaint
//    this widget's own RepaintBoundary through the painter's `repaint`
//    listenable;
//  * phase, palette and transition progress live in the controller, so the
//    compact -> fullscreen transition reuses the SAME visual instance
//    (shader phase/controller/state continuity, nothing is recreated);
//  * if the shader has not finished loading for the very first frames, a
//    cheap canvas fallback keeps the orb visible.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// The visual phase the orb is in. Drives the shader's motion character.
enum VoiceOrbPhase { subdued, connecting, listening, speaking, thinking, flow }

class VoiceOrbController extends ChangeNotifier {
  VoiceOrbController({required TickerProvider vsync}) {
    _ticker = vsync.createTicker(_onTick);
    _ticker.start();
  }

  /// Process-wide program cache: compiled once, reused by every orb.
  static Future<ui.FragmentProgram>? _programFuture;

  /// Loads (and forever caches) the orb program. Call before the first
  /// visible transition — e.g. the moment the voice button is tapped — so
  /// the entry animation never waits on the shader compiler.
  static Future<ui.FragmentProgram> prewarm() {
    return _programFuture ??= ui.FragmentProgram.fromAsset(
      'shaders/voice_orb.frag',
    );
  }

  late final Ticker _ticker;
  ui.FragmentShader? _shader;

  /// True once the program is compiled and bound — [VoiceOrb] paints the
  /// canvas fallback until then.
  bool get isReady => _shader != null;

  /// Loads the cached program into this controller's shader instance. Safe
  /// to call repeatedly; only the first call compiles.
  Future<void> load() async {
    if (_shader != null) return;
    try {
      final program = await prewarm();
      if (_disposed || _shader != null) return;
      _shader = program.fragmentShader();
    } catch (e) {
      debugPrint('[VoiceOrb] Shader unavailable, using fallback: $e');
    }
    if (!_disposed) notifyListeners();
  }

  // --- Inputs --------------------------------------------------------------
  double _micTarget = 0;
  double _micSmooth = 0;
  double _outputTarget = 0;
  double _outputSmooth = 0;
  double _ttsSmooth = 0;
  VoiceOrbPhase _phase = VoiceOrbPhase.subdued;
  double _intensity = 1.0;
  double _expand = 0.0;
  double _multicolor = 0.0;
  Color _colorATarget = const Color(0xFFC9B6F2);
  Color _colorBTarget = const Color(0xFFAEC8F5);
  Color _colorCTarget = const Color(0xFFF3C3D9);
  Color _colorACurrent = const Color(0xFFC9B6F2);
  Color _colorBCurrent = const Color(0xFFAEC8F5);
  Color _colorCCurrent = const Color(0xFFF3C3D9);

  double _timeSec = 0;
  double _motionTime = 0;
  double _motionSpeed = 0.035;
  double _intensitySmooth = 1.0;
  double _phaseScale = 0.5;
  bool _disposed = false;

  /// One raw microphone level sample (0..1). Cheap: no notifyListeners —
  /// smoothing happens on the ticker and repaints only the orb's layer.
  void setMicLevel(double level) {
    _micTarget = level.clamp(0.0, 1.0);
  }

  /// Output activity from the live TTS player. This is deliberately separate
  /// from the microphone envelope: the assistant can be speaking while the
  /// recorder is quiet, and the orb must keep reacting in that state.
  void setOutputLevel(double level) {
    _outputTarget = level.clamp(0.0, 1.0);
  }

  void setPhase(VoiceOrbPhase phase) {
    if (_phase == phase) return;
    _phase = phase;
  }

  void setIntensity(double value) {
    _intensity = value.clamp(0.0, 1.0);
  }

  void setMulticolor(double value) {
    _multicolor = value.clamp(0.0, 1.0);
  }

  /// The compact -> fullscreen transition progress (0..1). Fed by the
  /// overlay's expansion controller so geometry and shader energy move on
  /// one clock.
  void setExpandProgress(double value) {
    _expand = value.clamp(0.0, 1.0);
  }

  /// Palette targets; the controller interpolates toward them every tick so
  /// active-speaker changes (Flow) glide instead of snapping.
  void setPalette({
    required Color primary,
    required Color secondary,
    Color? accent,
  }) {
    _colorATarget = primary;
    _colorBTarget = secondary;
    if (accent != null) _colorCTarget = accent;
  }

  void _onTick(Duration elapsed) {
    final nextTime = elapsed.inMicroseconds / 1e6;
    final dt = (nextTime - _timeSec).clamp(0.0, 0.1);
    _timeSec = nextTime;
    final output = _outputTarget;
    final outputK = 1 - math.exp(-dt / (output > _outputSmooth ? 0.06 : 0.24));
    _outputSmooth += (output - _outputSmooth) * outputK;
    _ttsSmooth = _outputSmooth;
    final activity = math.max(_micSmooth, _outputSmooth);
    final speedTarget = _phase == VoiceOrbPhase.connecting
        ? 0.012 + 0.012 * activity
        : 0.035 +
              0.08 * activity +
              (_phase == VoiceOrbPhase.speaking
                  ? 0.16 + 0.36 * _outputSmooth
                  : 0) +
              (_phase == VoiceOrbPhase.flow ? 0.02 : 0.0);
    _motionSpeed += (speedTarget - _motionSpeed) * (1 - math.exp(-dt / 0.7));
    _motionTime += dt * _motionSpeed;
    _intensitySmooth +=
        (_intensity - _intensitySmooth) * (1 - math.exp(-dt / 0.7));

    final phaseScaleTarget = switch (_phase) {
      VoiceOrbPhase.connecting => 0.5,
      VoiceOrbPhase.listening ||
      VoiceOrbPhase.thinking ||
      VoiceOrbPhase.flow => 1.04,
      VoiceOrbPhase.speaking => 1.0,
      VoiceOrbPhase.subdued => 0.78,
    };
    // Readiness should feel like the orb waking up rather than a size jump.
    final phaseScaleRate = phaseScaleTarget > _phaseScale ? 0.14 : 0.08;
    _phaseScale +=
        (phaseScaleTarget - _phaseScale) * (1 - math.exp(-dt / phaseScaleRate));

    // EMA smoothing: fast attack (a syllable starts), slower release.
    final target = _micTarget;
    final k = 1 - math.exp(-dt / (target > _micSmooth ? 0.045 : 0.25));
    _micSmooth += (target - _micSmooth) * k;
    if (_micSmooth < 0.001) _micSmooth = 0;

    // Palette glide (Flow active-speaker changes interpolate smoothly).
    final paletteStep = 1 - math.exp(-dt / 1.2);
    _colorACurrent = Color.lerp(_colorACurrent, _colorATarget, paletteStep)!;
    _colorBCurrent = Color.lerp(_colorBCurrent, _colorBTarget, paletteStep)!;
    _colorCCurrent = Color.lerp(_colorCCurrent, _colorCTarget, paletteStep)!;

    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker.dispose();
    _shader?.dispose();
    super.dispose();
  }

  // --- Read by the painter --------------------------------------------------
  double get timeSec => _timeSec;
  double get motionTime => _motionTime;
  double get motionSpeed => _motionSpeed;

  // Six-second breath, confined to paint bounds. Audio blends into the same
  // phase, never starts/stops a second controller or changes layout size.
  double get breathingScale {
    return _phaseScale +
        0.009 * math.sin(_timeSec * math.pi / 3) +
        0.10 *
            _micSmooth.clamp(0.0, 1.0) *
            (_phase == VoiceOrbPhase.speaking ? 0.45 : 1.0);
  }

  double get micSmooth => _micSmooth;
  double get ttsSmooth => _ttsSmooth;
  VoiceOrbPhase get phase => _phase;

  /// The live interpolated palette (glides toward [setPalette]'s targets
  /// every tick). Read by the painter; exposed for tests.
  @visibleForTesting
  Color get colorACurrent => _colorACurrent;
  @visibleForTesting
  Color get colorBCurrent => _colorBCurrent;
  @visibleForTesting
  Color get colorCCurrent => _colorCCurrent;

  int get phaseCode {
    switch (_phase) {
      case VoiceOrbPhase.subdued:
        return 0;
      case VoiceOrbPhase.connecting:
        return 5;
      case VoiceOrbPhase.listening:
        return 1;
      case VoiceOrbPhase.speaking:
        return 2;
      case VoiceOrbPhase.thinking:
        return 3;
      case VoiceOrbPhase.flow:
        return 4;
    }
  }
}

class VoiceOrbPainter extends CustomPainter {
  VoiceOrbPainter(this.controller) : super(repaint: controller);

  final VoiceOrbController controller;

  /// The static, neutral seal: thin, crisp, AppColors.border — never
  /// animated, never recolored by state, never glowing.
  @visibleForTesting
  static Color get orbBorderColor => AppColors.border;

  static const double _borderWidth = 1.2;

  /// One soft color field of the canvas fallback: a blob center (as a
  /// factor of the paint size), a radius factor, and its gradient with
  /// EXPLICIT stops — the ui.Gradient.radial colors/colorStops contract
  /// (stops.length == colors.length) is asserted where the blob is painted
  /// and pinned from here by the widget test.
  @visibleForTesting
  static List<List<Object>> fallbackBlobSpecs(Color a, Color b, Color c) {
    return [
      [
        const Offset(0.38, 0.30),
        0.78,
        [b.withValues(alpha: 0.9), b.withValues(alpha: 0.0)],
        const [0.0, 1.0],
      ],
      [
        const Offset(0.68, 0.64),
        0.72,
        [c.withValues(alpha: 0.85), c.withValues(alpha: 0.0)],
        const [0.0, 1.0],
      ],
      [
        const Offset(0.32, 0.72),
        0.80,
        [a.withValues(alpha: 0.75), a.withValues(alpha: 0.0)],
        const [0.0, 1.0],
      ],
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final orbRadius = size.shortestSide / 2;
    final breath = controller.breathingScale;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(breath);
    canvas.translate(-center.dx, -center.dy);

    // The animated interior is clipped STRICTLY to the circle — no halo,
    // glow, blur or aura can ever exist outside the sealed sphere, shader
    // or fallback alike.
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    final shader = controller._shader;
    if (shader != null) {
      final a = controller._colorACurrent;
      final b = controller._colorBCurrent;
      final c = controller._colorCCurrent;
      shader.setFloat(0, size.width);
      shader.setFloat(1, size.height);
      shader.setFloat(2, controller._motionTime);
      shader.setFloat(3, controller._micSmooth);
      shader.setFloat(4, controller._ttsSmooth);
      shader.setFloat(5, controller.phaseCode.toDouble());
      shader.setFloat(6, controller._expand);
      shader.setFloat(7, controller._intensitySmooth);
      shader.setFloat(8, a.r);
      shader.setFloat(9, a.g);
      shader.setFloat(10, a.b);
      shader.setFloat(11, b.r);
      shader.setFloat(12, b.g);
      shader.setFloat(13, b.b);
      shader.setFloat(14, controller._multicolor);
      shader.setFloat(15, c.r);
      shader.setFloat(16, c.g);
      shader.setFloat(17, c.b);
      canvas.drawRect(rect, Paint()..shader = shader);
    } else {
      _paintFallback(canvas, size);
    }
    canvas.restore();

    // The border is painted LAST, ABOVE the animated interior: the seal.
    canvas.drawCircle(
      center,
      orbRadius - _borderWidth / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _borderWidth / breath
        ..color = orbBorderColor,
    );
    canvas.restore();
  }

  /// Canvas fallback (shader not yet compiled): the SAME art direction —
  /// contained internal pastel gradients inside the clipped circle, static
  /// border on top, nothing outside it.
  void _paintFallback(Canvas canvas, Size size) {
    final a = controller._colorACurrent;
    final b = controller._colorBCurrent;
    final c = controller._colorCCurrent;

    // Soft vertical wash of the two base pastels.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, size.height * 0.08),
          Offset(0, size.height * 0.92),
          [a, b],
          const [0.0, 1.0],
        ),
    );

    // Broad soft color fields — every gradient carries explicit stops with
    // exactly as many entries as colors (the colors/colorStops contract).
    for (final spec in fallbackBlobSpecs(a, b, c)) {
      final Offset at = spec[0] as Offset;
      final double radiusFactor = spec[1] as double;
      final List<Color> colors = spec[2] as List<Color>;
      final List<double> stops = spec[3] as List<double>;
      assert(
        stops.length == colors.length,
        'fallback gradient colors/colorStops must match',
      );
      final drift = controller.motionTime;
      final outputMotion = controller.ttsSmooth;
      final blobCenter = Offset(
        (at.dx +
                (0.035 + 0.025 * outputMotion) *
                    math.sin(drift * (1 + outputMotion) + at.dy * 6)) *
            size.width,
        (at.dy +
                (0.035 + 0.025 * outputMotion) *
                    math.cos(drift * (1 + outputMotion) + at.dx * 6)) *
            size.height,
      );
      final blobRadius =
          radiusFactor * size.shortestSide * (1 + 0.025 * outputMotion);
      canvas.drawCircle(
        blobCenter,
        blobRadius,
        Paint()
          ..shader = ui.Gradient.radial(blobCenter, blobRadius, colors, stops),
      );
    }
  }

  @override
  bool shouldRepaint(VoiceOrbPainter oldDelegate) => true;
}

/// The orb widget. Isolated in its own RepaintBoundary: amplitude ticks
/// repaint this layer only, never the chat.
class VoiceOrb extends StatefulWidget {
  const VoiceOrb({
    super.key,
    required this.controller,
    required this.size,
    this.onTap,
  });

  final VoiceOrbController controller;
  final double size;
  final VoidCallback? onTap;

  @override
  State<VoiceOrb> createState() => _VoiceOrbState();
}

class _VoiceOrbState extends State<VoiceOrb> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(painter: VoiceOrbPainter(widget.controller)),
        ),
      ),
    );
  }
}
