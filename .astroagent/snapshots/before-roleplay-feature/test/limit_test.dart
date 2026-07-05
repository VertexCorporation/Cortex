// test/limit_test.dart
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/services/limit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatLimitManager Tests', () {
    test('calculateTotalCharacters with text only', () {
      final manager = ChatLimitManager(cortexSubscription: 0);
      final messages = [
        Message(isUserMessage: true, text: 'Hello'), // 5 chars
        Message(isUserMessage: false, text: 'World'), // 5 chars
      ];

      expect(manager.calculateTotalCharacters(messages), 10);
    });

    test('calculateTotalCharacters with attachments', () {
      final manager = ChatLimitManager(cortexSubscription: 0);
      final messages = [
        Message(
          isUserMessage: true,
          text: 'Check this', // 10 chars
          attachmentPaths: ['path/to/image1.jpg'], // 1000 chars
        ),
      ];

      // 10 + 1000 = 1010
      expect(manager.calculateTotalCharacters(messages), 1010);
    });

    test('calculateTotalCharacters with multiple attachments', () {
      final manager = ChatLimitManager(cortexSubscription: 0);
      final messages = [
        Message(
          isUserMessage: true,
          text: '',
          attachmentPaths: ['1.jpg', '2.jpg'], // 2000 chars
        ),
      ];

      expect(manager.calculateTotalCharacters(messages), 2000);
    });

    test('calculateTotalCharacters mixed', () {
      final manager = ChatLimitManager(cortexSubscription: 0);
      final messages = [
        Message(
            isUserMessage: true,
            text: 'A',
            attachmentPaths: ['1.jpg']), // 1 + 1000
        Message(isUserMessage: false, text: 'B'), // 1
      ];

      expect(manager.calculateTotalCharacters(messages), 1002);
    });
  });
}
