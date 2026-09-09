import 'package:cortex/chat/services/processor.dart';
import 'package:cortex/library/backend/data/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const format = ChatFormat(tokens: ChatTokens(
    assistantStart: '<|assistant|>',
    stopGeneration: ['<|end|>'],
    ignoreRegex: r'^IGNORE$',
  ));
  test('split control markers preserve text and stop exactly once', () {
    var stopped = 0;
    final processor = ChatFormatProcessor(format,
        onStopTokenDetected: () => stopped++);
    final output = StringBuffer();
    for (final token in ['<|assis', 'tant|>', 'Hello', 'IGNORE',
      ' world', '<|en', 'd|>', 'discarded']) {
      output.write(processor.processToken(token) ?? '');
    }
    output.write(processor.finalize() ?? '');
    expect(output.toString(), 'Hello world');
    expect(stopped, 1);
  });
  test('invalid ignore regex does not drop subsequent content', () {
    final processor = ChatFormatProcessor(const ChatFormat(tokens: ChatTokens(
      stopGeneration: [], ignoreRegex: '[',
    )));
    expect(processor.processToken('Hello'), 'Hello');
    expect(processor.processToken(' world'), ' world');
  });
  test('unfinished marker is flushed at end of stream', () {
    final processor = ChatFormatProcessor(format);
    expect(processor.processToken('Hello'), 'Hello');
    expect(processor.processToken('<|en'), isNull);
    expect(processor.finalize(), '<|en');
  });
}
