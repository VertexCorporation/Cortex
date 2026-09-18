import 'package:cortex/chat/services/scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class CountingScrollController extends ScrollController {
  int animations = 0;
  @override
  Future<void> animateTo(
    double offset, {
    required Duration duration,
    required Curve curve,
  }) async {
    animations++;
  }
}

void main() {
  testWidgets(
    'token burst starts one scroll per frame; later frames still scroll',
    (tester) async {
      final controller = CountingScrollController();
      final service = ScrollService()..setController(controller);
      await tester.pumpWidget(
        MaterialApp(
          home: ListView(
            controller: controller,
            children: const [SizedBox(height: 4000)],
          ),
        ),
      );
      final requests = List.generate(50, (_) => service.scrollToBottom());
      expect(requests.every((r) => identical(r, requests.first)), isTrue);
      await tester.pump();
      await Future.wait(requests);
      expect(controller.animations, 1);
      final next = service.scrollToBottom();
      await tester.pump();
      await next;
      expect(controller.animations, 2);
      service.reset();
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets(
    'pending scroll cannot follow a replacement conversation controller',
    (tester) async {
      final first = CountingScrollController();
      final replacement = CountingScrollController();
      final service = ScrollService()..setController(first);
      await tester.pumpWidget(
        MaterialApp(
          home: ListView(
            controller: first,
            children: const [SizedBox(height: 4000)],
          ),
        ),
      );
      final request = service.scrollToBottom();
      service.setController(replacement);
      await tester.pumpWidget(
        MaterialApp(
          home: ListView(
            controller: replacement,
            children: const [SizedBox(height: 4000)],
          ),
        ),
      );
      await request;
      expect(first.animations, 0);
      expect(replacement.animations, 0);
      service.reset();
      await tester.pumpWidget(const SizedBox());
      first.dispose();
      replacement.dispose();
    },
  );
}
