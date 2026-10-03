import 'package:cortex/chat/services/scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ScrollService service;
  late ScrollController controller;
  late StateSetter rebuild;
  late int count;

  Future<void> mount(WidgetTester tester) async {
    service = ScrollService();
    controller = ScrollController();
    service.setController(controller);
    count = 50;
    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(builder: (context, setState) {
        rebuild = setState;
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            service.handleScrollNotification(notification);
            return false;
          },
          child: ListView.builder(
            controller: controller,
            itemExtent: 60,
            itemCount: count,
            itemBuilder: (_, index) => Text('Message $index'),
          ),
        );
      }),
    ));
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
  }

  Future<void> grow(WidgetTester tester) async {
    rebuild(() => count++);
    await tester.pump();
    service.maintainScrollAtBottom(threshold: 120);
    await tester.pump();
  }

  testWidgets('reveal and token updates do not interrupt a small upward drag',
      (tester) async {
    await mount(tester);
    final gesture = await tester.startGesture(tester.getCenter(find.byType(ListView)));
    await gesture.moveBy(const Offset(0, 50));
    await tester.pump();
    final offset = controller.offset;
    expect(controller.position.extentAfter, lessThan(120));
    await grow(tester);
    service.scrollToBottom();
    await tester.pump();
    expect(controller.offset, offset);
    await gesture.up();
    await tester.pumpAndSettle();
    final releasedOffset = controller.offset;
    await grow(tester);
    expect(controller.offset, releasedOffset);
  });

  testWidgets('a queued follow is cancelled by upward user input', (tester) async {
    await mount(tester);
    rebuild(() => count++);
    await tester.pump();
    final offset = controller.offset;
    final pending = service.scrollToBottom();
    service.handleScrollNotification(UserScrollNotification(
      metrics: controller.position,
      context: tester.element(find.byType(ListView)),
      direction: ScrollDirection.forward,
    ));
    await tester.pump();
    await pending;
    expect(controller.offset, offset);
  });

  testWidgets('following continues as streaming content grows at the bottom',
      (tester) async {
    await mount(tester);
    for (var i = 0; i < 4; i++) {
      await grow(tester);
      expect(controller.position.extentAfter, 0);
    }
  });

  testWidgets('explicit bottom action resumes following', (tester) async {
    await mount(tester);
    await tester.drag(find.byType(ListView), const Offset(0, 200));
    await tester.pumpAndSettle();
    final pending = service.scrollToBottom(force: true);
    await tester.pump();
    await tester.pumpAndSettle();
    await pending;
    expect(controller.position.extentAfter, 0);
    await grow(tester);
    expect(controller.position.extentAfter, 0);
  });

  testWidgets('new conversation discards paused follow and old callbacks',
      (tester) async {
    await mount(tester);
    await tester.drag(find.byType(ListView), const Offset(0, 200));
    await tester.pumpAndSettle();
    service.beginConversation();
    service.jumpToBottom();
    await tester.pump();
    expect(controller.position.extentAfter, 0);
    await grow(tester);
    expect(controller.position.extentAfter, 0);
  });

  testWidgets('returning manually to the bottom resumes following', (tester) async {
    await mount(tester);
    await tester.drag(find.byType(ListView), const Offset(0, 200));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(controller.position.extentAfter, 0);
    await grow(tester);
    expect(controller.position.extentAfter, 0);
  });
}
