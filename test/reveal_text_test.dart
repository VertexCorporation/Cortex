import 'dart:io';
import 'dart:ui' as ui;
import 'package:cortex/chat/messages/markdown/parser.dart';
import 'package:cortex/chat/messages/tiles/ai/reveal_text.dart';
import 'package:cortex/chat/messages/tiles/ai/reveal_timeline.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'vertical mask composes with horizontal fade and vanishes at rest',
      (tester) async {
    final reveal = RevealTimeline()..reset('word ' * 120, complete: true);
    final boundary = GlobalKey();
    var shownText = '';
    Future<void> build(bool vertical) => tester.pumpWidget(MaterialApp(
          home: Center(
              child: RepaintBoundary(
                  key: boundary,
                  child: SizedBox(
                    width: 240,
                    child: RevealText(
                        timeline: reveal,
                        enableVerticalReveal: vertical,
                        text: TextSpan(
                      text: shownText,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white))),
                  ))),
        ));
    Future<List<int>> pixels() async => (await tester.runAsync(() async {
          final image = await (boundary.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
          final bytes =
              await image.toByteData(format: ui.ImageByteFormat.rawRgba);
          final result = bytes!.buffer.asUint8List().toList();
          image.dispose();
          return result;
        }))!;
    reveal.advance(const Duration(milliseconds: 100));
    shownText = reveal.visibleText;
    expect(reveal.verticalReveal, true);
    await build(false);
    reveal.advance(const Duration(milliseconds: 70));
    await tester.pump();
    final horizontal = await pixels();
    final size = tester.getSize(find.byType(RevealText));
    await build(true);
    final combined = await pixels();
    expect(combined, isNot(horizontal));
    expect(tester.getSize(find.byType(RevealText)), size);
    reveal.flush();
    await build(true);
    final settled = await pixels();
    await build(false);
    expect(await pixels(), settled);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    reveal.dispose();
  });

  testWidgets('fades overlap, layout stays fixed and fade ticks do not rebuild',
      (tester) async {
    final reveal = RevealTimeline()
      ..reset('Akış geldikçe karakter karakter.', complete: true);
    final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (font.existsSync()) {
      final loader = FontLoader('RevealTest');
      loader
          .addFont(Future.value(ByteData.sublistView(font.readAsBytesSync())));
      await loader.load();
    }
    var builds = 0;
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
      child: RepaintBoundary(
          key: key,
          child: Container(
            width: 340,
            height: 130,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SelectionArea(
              child: AnimatedBuilder(
                  animation: reveal,
                  builder: (context, child) {
                    builds++;
                    return RevealText(
                        timeline: reveal,
                        text: TextSpan(
                            text: reveal.visibleText,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                height: 1.5,
                                fontFamily: 'RevealTest')));
                  }),
            ),
          )),
    ))));
    for (var i = 0; i < 16; i++) {
      reveal.advance(const Duration(milliseconds: 16));
      await tester.pump();
    }
    final paragraph = tester.renderObject<RenderParagraph>(find.descendant(
        of: find.byType(RevealText), matching: find.byType(RichText)));
    final bounds = paragraph.size;
    await tester.runAsync(() async {
      final snapshot = await (key.currentContext!.findRenderObject()
              as RenderRepaintBoundary)
          .toImage(pixelRatio: 2);
      final bytes = await snapshot.toByteData(format: ui.ImageByteFormat.png);
      await File('/private/tmp/cortex-reveal-overlap.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      snapshot.dispose();
    });
    while (reveal.pendingLength > 0) {
      reveal.advance(const Duration(milliseconds: 16));
      await tester.pump();
    }
    final tailBuilds = builds;
    reveal.advance(const Duration(milliseconds: 50));
    await tester.pump();
    expect(builds, tailBuilds); // only paint, no parsing/build/layout for fades
    final fullSize = paragraph.size;
    reveal.advance(const Duration(milliseconds: 100));
    reveal.advance(const Duration(milliseconds: 100));
    reveal.advance(const Duration(milliseconds: 30));
    await tester.pump();
    expect(paragraph.size, fullSize);
    expect(bounds.width, fullSize.width);
    expect(reveal.visualComplete, true);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    reveal.dispose();
  });

  testWidgets('real Markdown parser stays intact through every visible prefix',
      (tester) async {
    final reveal = RevealTimeline();
    const source =
        'İyi  günler\n**kalın** ve `kod`\n- madde\n[link](https://example.com)\n```dart\nprint(1);\n```';
    reveal.reset(source, complete: true);
    late List<InlineSpan> finalSpans;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
      width: 360,
      child: SelectionArea(
          child: Builder(
              builder: (context) => AnimatedBuilder(
                    animation: reveal,
                    builder: (context, child) {
                      finalSpans = parseText(context, reveal.visibleText,
                          fontSize: 17, isFinished: reveal.visualComplete);
                      return RevealText(
                          timeline: reveal,
                          text: TextSpan(
                              children: finalSpans,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 17)));
                    },
                  ))),
    ))));
    while (reveal.needsFrames) {
      reveal.advance(const Duration(milliseconds: 16));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
    final output = TextSpan(children: finalSpans).toPlainText();
    expect(output, contains('İyi  günler'));
    expect(output, contains('kalın'));
    expect(output, isNot(contains('**')));
    expect(finalSpans.any((s) => s is WidgetSpan), true);
    await tester.pumpWidget(const SizedBox.shrink());
    reveal.dispose();
  });

  testWidgets('reveal keeps the horizontal message constraint stable',
      (tester) async {
    final reveal = RevealTimeline()
      ..reset('A short response that wraps.', complete: false);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 340,
          child: AnimatedBuilder(
            animation: reveal,
            builder: (context, child) => SizedBox(
              width: double.infinity,
              child: RevealText(
                timeline: reveal,
                text: TextSpan(
                  text: reveal.visibleText,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    final stableWidth = tester.getSize(find.byType(SizedBox).last).width;
    for (var i = 0; i < 12; i++) {
      reveal.advance(const Duration(milliseconds: 16));
      await tester.pump();
      expect(tester.getSize(find.byType(SizedBox).last).width, stableWidth);
    }
    reveal.dispose();
  });

  testWidgets('recognizers survive revealing and flushing', (tester) async {
    var taps = 0;
    final tap = TapGestureRecognizer()..onTap = () => taps++;
    final reveal = RevealTimeline()..reset('Link', complete: true);
    reveal.advance(const Duration(milliseconds: 16));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
      child: RevealText(
          timeline: reveal,
          text: TextSpan(
              text: 'Link',
              recognizer: tap,
              style: const TextStyle(fontSize: 24, color: Colors.blue))),
    ))));
    await tester.tap(find.byType(RevealText));
    expect(taps, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    reveal.dispose();
    tap.dispose();
  });
}
