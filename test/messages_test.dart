// test/messages_test.dart
import 'package:cortex/chat/messages/messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Message Logic Tests', () {
    test('User Message Creation', () {
      final msg = Message.user(text: 'Hello', model: 'gpt-4');

      expect(msg.isUserMessage, true);
      expect(msg.text, 'Hello');
      expect(msg.model, 'gpt-4');
      expect(msg.id, isNotNull);
      expect(msg.hasAttachments, false);
    });

    test('copyWith Updates Fields', () {
      final msg = Message.user(text: 'Old');
      final newMsg = msg.copyWith(text: 'New', isThinking: true);

      expect(newMsg.text, 'New');
      expect(newMsg.isThinking, true);
      expect(newMsg.id, msg.id); // ID Preserved
    });

    test('copyWith Force New ID', () {
      final msg = Message.user(text: 'Old');
      final newMsg = msg.copyWith(forceNewId: true);

      expect(newMsg.id, isNot(msg.id));
    });

    test('Notifier reuse optimization', () {
      final msg = Message.user(text: 'Text');

      final sameTextMsg = msg.copyWith(text: 'Text');
      // If text is same, it might reuse notifier instance (implementation detail check)
      expect(sameTextMsg.notifier, msg.notifier);

      final diffTextMsg = msg.copyWith(text: 'New Text');
      expect(diffTextMsg.notifier, isNot(msg.notifier));
      expect(diffTextMsg.notifier.value, 'New Text');
    });

    test('Serialization: fromMap legacy photoPath', () {
      final map = {
        'uuid': '123',
        'text': 'Legacy',
        'isUser': 1,
        'photoPath': '/path/to/photo.jpg'
      };

      final msg = Message.fromMap(map);
      expect(msg.attachmentPaths.length, 1);
      expect(msg.attachmentPaths.first, '/path/to/photo.jpg');
    });

    test('Serialization: fromMap new attachmentPaths', () {
      final map = {
        'uuid': '123',
        'text': 'Modern',
        'isUser': 1,
        'attachmentPaths': ['/p1.jpg', '/p2.pdf']
      };

      final msg = Message.fromMap(map);
      expect(msg.attachmentPaths.length, 2);
      expect(msg.attachmentPaths[1], '/p2.pdf');
    });

    test('Logic: hasAttachments', () {
      final msgEmpty = Message.user(text: 'Empty');
      expect(msgEmpty.hasAttachments, false);

      final msgFilled = Message.user(text: 'Filled', attachmentPaths: ['/a']);
      expect(msgFilled.hasAttachments, true);
    });

    test('Serialization: toolSteps round-trip through toMap/fromMap', () {
      final msg = Message(
        id: 'rt-1',
        text: 'Checked the weather.',
        isUserMessage: false,
        toolSteps: const ['get_weather', 'render_chart'],
      );

      final map = msg.toMap();
      // The storage layer persists toolSteps as a JSON string array.
      expect(map['toolSteps'], isNotNull);

      final restored = Message.fromMap({
        ...map,
        'isUser': 0,
      });
      expect(restored.toolSteps, ['get_weather', 'render_chart']);
    });

    test('Serialization: isIncomplete round-trip through toMap/fromMap', () {
      final truncated = Message(
        id: 'rt-2',
        text: 'Cut short mid-sentence...',
        isUserMessage: false,
        isIncomplete: true,
      );
      final restored = Message.fromMap({...truncated.toMap(), 'isUser': 0});
      expect(restored.isIncomplete, true);

      final complete = Message(
        id: 'rt-3',
        text: 'Full answer.',
        isUserMessage: false,
      );
      final restoredComplete =
          Message.fromMap({...complete.toMap(), 'isUser': 0});
      expect(restoredComplete.isIncomplete, false);
    });

    test('Serialization: legacy rows without toolSteps/isIncomplete columns',
        () {
      final msg = Message.fromMap({
        'uuid': 'legacy-1',
        'text': 'Old row',
        'isUser': 0,
      });
      expect(msg.toolSteps, isEmpty);
      expect(msg.isIncomplete, false);
    });

    test('Serialization: corrupt toolSteps JSON does not crash the chat', () {
      final msg = Message.fromMap({
        'uuid': 'corrupt-1',
        'text': 'Row with bad JSON',
        'isUser': 0,
        'toolSteps': '{"broken":',
      });
      expect(msg.toolSteps, isEmpty);
    });

    test('copyWith preserves toolSteps and isIncomplete (finalize path)', () {
      // finishBotResponse finalizes with copyWith(toolActivity: '') — the
      // durable tool trace and the truncation marker must survive it.
      final msg = Message(
        text: 'Partial',
        isUserMessage: false,
        isThinking: true,
        toolActivity: 'get_weather',
        toolSteps: const ['get_weather'],
        isIncomplete: true,
      );

      final finalized = msg.copyWith(
        isThinking: false,
        includeInContext: true,
        toolActivity: '',
      );
      expect(finalized.toolSteps, ['get_weather']);
      expect(finalized.isIncomplete, true);
      expect(finalized.toolActivity, isEmpty);
    });

    test('copyWithText preserves toolSteps and isIncomplete (stream path)', () {
      // appendToLastBotMessage rebuilds the message with copyWithText on
      // every chunk — steps and marker must ride along.
      final msg = Message(
        text: 'Partial',
        isUserMessage: false,
        toolSteps: const ['calculate'],
        isIncomplete: true,
      );

      final streamed = msg.copyWithText('Partial text grows');
      expect(streamed.toolSteps, ['calculate']);
      expect(streamed.isIncomplete, true);
      expect(streamed.text, 'Partial text grows');
    });
  });
}
