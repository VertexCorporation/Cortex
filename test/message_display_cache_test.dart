import 'package:cortex/chat/messages/messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cached display text preserves existing memory-tag filtering', () {
    final partial = RegExp(
        r'\s*<m(?:e(?:m(?:o(?:r(?:y(?:>[\s\S]*)?)?)?)?)?)?$',
        caseSensitive: false);
    final complete = RegExp(r'\s*<memory>[\s\S]*?(?:</memory>|$)\s*',
        caseSensitive: false);
    for (final text in [
      '', 'Normal response', 'Merhaba 🌍', 'A <memory>private</memory> B',
      'Answer <mem', 'Answer <MEMORY>pending',
      'First\n<memory>line one\nline two</memory>\nLast',
    ]) {
      final message = Message(text: text, isUserMessage: false);
      final expected = text.replaceAll(partial, '').replaceAll(complete, '');
      expect(message.displayableText, expected);
      expect(message.displayableText, expected);
    }
  });

  test('streaming copy computes from its own updated text', () {
    final original = Message(text: 'First', isUserMessage: false);
    expect(original.displayableText, 'First');
    final next = original.copyWith(text: 'Second <memory>hidden</memory>');
    expect(next.displayableText, 'Second');
    expect(original.displayableText, 'First');
  });
}
