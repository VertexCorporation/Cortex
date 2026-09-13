import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cortex/startup/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Shape shown before transition k of the canonical cycle.
  int shape(int transitionIndex) => SplashTimeline.states[transitionIndex % 7];

  // A boundary only registers on a frame STRICTLY past segmentDuration: the
  // controller's simulation reports done only after — not at — the full
  // segment, so every boundary step pumps one frame beyond it.
  final oneFramePastSegment =
      SplashTimeline.segmentDuration + const Duration(milliseconds: 16);

  test('every transition is a full 360° turn; directions strictly alternate', () {
    expect(SplashTimeline.states, [4, 5, 6, 7, 8, 9, 10, 4]);
    for (var k = 0; k < 21; k++) {
      final direction = SplashTimeline.directionFor(k);
      // +1, -1, +1, -1 … held across loop seams and through the final exit.
      expect(direction, k.isEven ? 1 : -1);
      expect(SplashTimeline.rotation(0, direction), 0);
      expect(
        SplashTimeline.rotation(.5, direction),
        closeTo(direction * math.pi, 1e-10),
      );
      expect(
        SplashTimeline.rotation(1, direction),
        closeTo(direction * 2 * math.pi, 1e-10),
      );
      // Out-of-range inputs are clamped, never wrapped: no partial extra turn.
      expect(
        SplashTimeline.rotation(2, direction),
        closeTo(direction * 2 * math.pi, 1e-10),
      );
      expect(SplashTimeline.rotation(-1, direction), 0);
    }
    // The loop seam specifically: decagon → Cortex ran clockwise, so the next
    // Cortex → pentagon transition must run counter-clockwise.
    expect(SplashTimeline.directionFor(6), 1);
    expect(SplashTimeline.directionFor(7), -1);
    expect(SplashTimeline.nextShape(10), 4);
    expect(SplashTimeline.nextShape(4), 5);
  });

  Future<ui.Image> render(
    SplashFrame frame,
    double value, {
    Color foreground = Colors.black,
    int scale = 1,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(scale.toDouble());
    CortexSplashPainter(
      progress: AlwaysStoppedAnimation(value),
      geometry: SplashGeometry(),
      frame: frame,
      foreground: foreground,
    ).paint(canvas, const Size.square(288));
    final picture = recorder.endRecording();
    final image = await picture.toImage(288 * scale, 288 * scale);
    picture.dispose();
    return image;
  }

  test(
    'initial and final frames are identical, including rounded hole',
    () async {
      final first = await render(SplashFrame(from: 4, to: 5, direction: 1), 0);
      final last = await render(SplashFrame(from: 10, to: 4, direction: 1), 1);
      final a = (await first.toByteData())!.buffer.asUint8List();
      final b = (await last.toByteData())!.buffer.asUint8List();
      expect(a, b);
      // Transparent hole, opaque ring, 128 logical pixel outside diameter.
      int alpha(int x, int y) => a[(y * 288 + x) * 4 + 3];
      expect(alpha(144, 144), 0);
      expect(alpha(144, 90), greaterThan(240));
      expect(alpha(144, 75), 0);
      first.dispose();
      last.dispose();
    },
  );

  test('no visible jumps at any boundary, including both loop seams', () async {
    for (var k = 0; k < 14; k++) {
      final before = await render(
        SplashFrame(
          from: shape(k),
          to: shape(k + 1),
          direction: SplashTimeline.directionFor(k),
        ),
        1 - 1e-7,
      );
      final after = await render(
        SplashFrame(
          from: shape(k + 1),
          to: shape(k + 2),
          direction: SplashTimeline.directionFor(k + 1),
        ),
        0,
      );
      final a = (await before.toByteData())!.buffer.asUint8List();
      final b = (await after.toByteData())!.buffer.asUint8List();
      var total = 0;
      for (var p = 0; p < a.length; p++) {
        total += (a[p] - b[p]).abs();
      }
      expect(total / a.length, lessThan(.02), reason: 'boundary $k');
      before.dispose();
      after.dispose();
    }
  });

  test('ring samples are lazily built and cached', () {
    final geometry = SplashGeometry();
    final cortex = geometry.ring(4);
    expect(identical(geometry.ring(4), cortex), isTrue);
    expect(cortex.length, 2);
    expect(cortex[0].length, SplashGeometry.samples * 2);
  });

  testWidgets('loops the pre-final cycle while startup is not ready', (
    tester,
  ) async {
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(home: CortexStartupSplash(onComplete: () => completions++)),
    );
    await tester.pump();
    // Two full passes of the polygon cycle: still looping, never completing,
    // never idle, never holding the final Cortex. Each boundary step pumps one
    // frame past the segment and lands exactly on the next transition's start.
    for (var k = 0; k < 14; k++) {
      await tester.pump(oneFramePastSegment);
    }
    expect(completions, 0);
    expect(tester.binding.transientCallbackCount, 1);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets(
    'readiness mid-loop exits at the next boundary, completing once',
    (tester) async {
      var completions = 0;
      await tester.pumpWidget(
        MaterialApp(home: CortexStartupSplash(onComplete: () => completions++)),
      );
      await tester.pump();
      for (var k = 0; k < 3; k++) {
        await tester.pump(oneFramePastSegment);
      }
      await tester.pump(const Duration(milliseconds: 200));
      // Startup becomes ready half-way through transition 3.
      await tester.pumpWidget(
        MaterialApp(
          home: CortexStartupSplash(
            onComplete: () => completions++,
            ready: true,
          ),
        ),
      );
      // The current morph keeps running instead of jumping to Cortex.
      expect(tester.binding.transientCallbackCount, 1);
      await tester.pump(const Duration(milliseconds: 100));
      expect(completions, 0);
      // The next boundary morphs into Cortex…
      await tester.pump(oneFramePastSegment);
      expect(completions, 0);
      // …then finishes, holds briefly, and completes exactly once.
      await tester.pump(oneFramePastSegment);
      await tester.pump(
        SplashTimeline.finalHold + const Duration(milliseconds: 16),
      );
      expect(completions, 1);
      expect(tester.binding.transientCallbackCount, 0);
      await tester.pump(const Duration(seconds: 30));
      expect(completions, 1);
    },
  );

  testWidgets('already-ready startup exits after one polygon pass', (
    tester,
  ) async {
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CortexStartupSplash(onComplete: () => completions++, ready: true),
      ),
    );
    await tester.pump();
    await tester.pump(oneFramePastSegment);
    // 4→5 finished; the exit morph into Cortex is running.
    expect(completions, 0);
    expect(tester.binding.transientCallbackCount, 1);
    await tester.pump(oneFramePastSegment);
    await tester.pump(
      SplashTimeline.finalHold + const Duration(milliseconds: 16),
    );
    expect(completions, 1);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pump(const Duration(seconds: 30));
    expect(completions, 1);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('reduced motion completes without rotation', (tester) async {
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: CortexStartupSplash(onComplete: () => completions++),
        ),
      ),
    );
    await tester.pump();
    expect(completions, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });

  test('static native asset export and visual review frames', () async {
    if (!const bool.fromEnvironment('EXPORT_SPLASH')) return;
    final directory = Directory('/tmp/cortex-splash-review')
      ..createSync(recursive: true);
    // One full loop pass of review frames with the true alternating rotation.
    for (var i = 0; i <= 28; i++) {
      final k = i ~/ 4; // one transition spans 4 review frames
      final frame = SplashFrame(
        from: shape(k),
        to: shape(k + 1),
        direction: SplashTimeline.directionFor(k),
      );
      final image = await render(frame, (i % 4) / 4, scale: 2);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!
          .buffer
          .asUint8List();
      File('${directory.path}/frame-$i.png').writeAsBytesSync(bytes);
      image.dispose();
    }
    // Native launch images are static only. The animation never reads these.
    for (final dark in [false, true]) {
      for (var scale = 1; scale <= 4; scale++) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder)
          ..scale(scale.toDouble())
          ..translate(-80, -80);
        CortexSplashPainter(
          progress: const AlwaysStoppedAnimation(0),
          geometry: SplashGeometry(),
          frame: SplashFrame(),
          foreground: dark ? Colors.white : Colors.black,
        ).paint(canvas, const Size.square(288));
        final picture = recorder.endRecording();
        final image = await picture.toImage(128 * scale, 128 * scale);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
        final suffix = scale == 1 ? '' : '@${scale}x';
        if (scale <= 3) {
          File(
            'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage${dark ? 'Dark' : ''}$suffix.png',
          ).writeAsBytesSync(bytes);
        } else {
          Directory('assets/startup').createSync(recursive: true);
          File('assets/startup/${dark ? 'white' : 'black'}.png')
              .writeAsBytesSync(bytes);
        }
        picture.dispose();
        image.dispose();
      }
      final image = await render(
        SplashFrame(),
        0,
        foreground: dark ? Colors.white : Colors.black,
        scale: 4,
      );
      File('assets/startup/android12-${dark ? 'white' : 'black'}.png')
          .writeAsBytesSync(
            (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer
                .asUint8List(),
          );
      image.dispose();
    }
  });
}
