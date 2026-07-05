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
  });
}
