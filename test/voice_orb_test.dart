// test/voice_orb_test.dart
//
// The Voice Mode V2 orb's art-direction contracts (product spec):
//   * the canvas fallback's every gradient carries EXACTLY as many stops
//     as colors — the ui.Gradient.radial colors/colorStops contract;
//   * the border is the static, neutral AppColors.border — painted above
//     the animated interior, never state-recolored, never glowing;
//   * the widget tree carries NO glow layer — no boxShadow, no blur
//     filters, nothing that paints outside the sealed circle;
//   * the controller's palette GLIDES toward its targets (Flow
//     active-model transitions interpolate, they do not snap).

import 'package:cortex/chat/screen/widgets/voice_orb.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _OrbHost extends StatefulWidget {
  const _OrbHost({super.key});

  @override
  State<_OrbHost> createState() => _OrbHostState();
}

class _OrbHostState extends State<_OrbHost> with TickerProviderStateMixin {
  late final VoiceOrbController controller;

  @override
  void initState() {
    super.initState();
    controller = VoiceOrbController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: VoiceOrb(controller: controller, size: 64)),
      ),
    );
  }
}

double _channelDistance(Color a, Color b) =>
    (a.r - b.r).abs() + (a.g - b.g).abs() + (a.b - b.b).abs();

void main() {
  testWidgets(
    'idle breath and liquid phase continue without relayout or new controllers',
    (tester) async {
      final key = GlobalKey<_OrbHostState>();
      await tester.pumpWidget(_OrbHost(key: key));
      final controller = key.currentState!.controller;
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final initial = controller.breathingScale;
      final size = tester.getSize(find.byType(VoiceOrb));
      for (var i = 0; i < 120; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(controller.breathingScale, inInclusiveRange(0.76, 0.80));
      }
      expect(controller.motionTime, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 500));
      expect(controller.breathingScale, isNot(initial));
      final idleSpeed = controller.motionSpeed;
      controller.setPhase(VoiceOrbPhase.speaking);
      controller.setOutputLevel(1);
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(controller.motionSpeed, greaterThan(idleSpeed));
      controller.setPhase(VoiceOrbPhase.subdued);
      controller.setOutputLevel(0);
      final phase = controller.motionTime;
      for (var i = 0; i < 240; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(controller.motionTime, greaterThan(phase));
      expect(controller.motionSpeed, lessThan(0.05));
      expect(key.currentState!.controller, same(controller));
      expect(tester.getSize(find.byType(VoiceOrb)), size);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'listening and real input/output envelopes stay bounded and reactive',
    (tester) async {
      final key = GlobalKey<_OrbHostState>();
      await tester.pumpWidget(_OrbHost(key: key));
      final controller = key.currentState!.controller;
      controller.setPhase(VoiceOrbPhase.listening);
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final listening = controller.breathingScale;
      expect(listening, inInclusiveRange(1.02, 1.08));

      controller.setMicLevel(0.9);
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(controller.breathingScale, greaterThan(listening));
      expect(controller.breathingScale, lessThan(1.15));

      controller.setPhase(VoiceOrbPhase.speaking);
      controller.setMicLevel(0);
      controller.setOutputLevel(1);
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(controller.ttsSmooth, greaterThan(0));
      expect(controller.motionTime, greaterThan(0));
      expect(controller.breathingScale, lessThan(1.06));

      controller.setOutputLevel(0);
      for (var i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(controller.ttsSmooth, lessThan(0.5));
      expect(controller.breathingScale, inInclusiveRange(0.98, 1.03));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('connecting phase is half-size, quiet, and becomes listening', (
    tester,
  ) async {
    final key = GlobalKey<_OrbHostState>();
    await tester.pumpWidget(_OrbHost(key: key));
    final controller = key.currentState!.controller;

    controller.setPhase(VoiceOrbPhase.connecting);
    controller.setIntensity(0.16);
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.breathingScale, inInclusiveRange(0.49, 0.51));

    controller.setPhase(VoiceOrbPhase.listening);
    controller.setIntensity(1);
    final start = controller.breathingScale;
    await tester.pump(const Duration(milliseconds: 16));
    expect(controller.breathingScale, greaterThan(start));
    expect(controller.breathingScale, lessThan(0.65));
    for (var i = 0; i < 44; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.breathingScale, greaterThan(1.02));
    expect(controller.motionTime, greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('the fallback gradient specs keep colors and colorStops aligned', () {
    const a = Color(0xFFC9B6F2);
    const b = Color(0xFFAEC8F5);
    const c = Color(0xFFF3C3D9);
    final specs = VoiceOrbPainter.fallbackBlobSpecs(a, b, c);
    expect(specs, isNotEmpty);
    for (final spec in specs) {
      final colors = spec[2] as List<Color>;
      final stops = spec[3] as List<double>;
      expect(colors, isNotEmpty);
      expect(
        stops.length,
        colors.length,
        reason: 'colors/colorStops must match: $spec',
      );
      for (final stop in stops) {
        expect(stop, inInclusiveRange(0.0, 1.0));
      }
    }
  });

  test('the border is the static neutral AppColors.border', () {
    expect(VoiceOrbPainter.orbBorderColor, AppColors.border);
  });

  testWidgets('the orb subtree carries no glow layer', (tester) async {
    await tester.pumpWidget(const _OrbHost());
    await tester.pump(const Duration(milliseconds: 50));

    // No boxShadow anywhere in the orb's subtree — the sphere is sealed.
    // Scope every assertion to the orb's own subtree — the app shell around
    // it is irrelevant to the orb's art direction.
    final orb = find.byType(VoiceOrb);

    // No boxShadow anywhere in the orb's subtree — the sphere is sealed.
    for (final decorated in tester.widgetList<DecoratedBox>(
      find.descendant(of: orb, matching: find.byType(DecoratedBox)),
    )) {
      final decoration = decorated.decoration;
      if (decoration is BoxDecoration) {
        expect(
          decoration.boxShadow,
          isNull,
          reason: 'the sealed orb must not glow',
        );
      }
    }
    // No blur/backdrop image filters in the subtree.
    expect(
      find.descendant(of: orb, matching: find.byType(ImageFiltered)),
      findsNothing,
    );
    expect(
      find.descendant(of: orb, matching: find.byType(BackdropFilter)),
      findsNothing,
    );

    // Exactly one painter inside the orb — the animated interior is
    // clipped to the circle within it, and the widget is the orb's square.
    expect(
      find.descendant(of: orb, matching: find.byType(CustomPaint)),
      findsOneWidget,
    );
    expect(tester.getSize(orb), const Size(64, 64));
    expect(tester.takeException(), isNull);
  });

  testWidgets('palette targets glide, they do not snap', (tester) async {
    final hostKey = GlobalKey<_OrbHostState>();
    await tester.pumpWidget(_OrbHost(key: hostKey));
    final controller = hostKey.currentState!.controller;

    final before = controller.colorACurrent;
    const target = Color(0xFFEFA8A6);
    controller.setPalette(
      primary: target,
      secondary: const Color(0xFFA6B9F2),
      accent: const Color(0xFFF2DDA0),
    );
    // A handful of ticker frames: the interpolation APPROACHES the target
    // monotonically instead of snapping to it.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final after = controller.colorACurrent;
    expect(after, isNot(before));
    expect(
      _channelDistance(after, target),
      lessThan(_channelDistance(before, target)),
    );
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final settled = controller.colorACurrent;
    expect(
      _channelDistance(settled, target),
      lessThan(_channelDistance(after, target)),
      reason: 'the glide converges on the target palette',
    );
  });
}
