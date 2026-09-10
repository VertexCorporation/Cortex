import 'package:cortex/chat/services/processor.dart';
import 'package:cortex/library/backend/data/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChatFormatProcessor processor({void Function()? onStop}) =>
      ChatFormatProcessor(
        const ChatFormat(tokens: ChatTokens(
          stopGeneration: ['<|im_end|>'],
          ignoreRegex: r'<artifact>',
        )),
        onStopTokenDetected: onStop,
      );

  test('keeps answer text around ignored artifacts in one native chunk', () {
    final filter = processor();
    expect(filter.processToken('<artifact>Merhaba<artifact> dünya'),
        'Merhaba dünya');
    expect(filter.finalize(), isNull);
  });

  test('still recognizes stop tokens in a mixed chunk', () {
    var stops = 0;
    final filter = processor(onStop: () => stops++);
    expect(filter.processToken('<artifact>Cevap<|im_end|>discard'), 'Cevap');
    expect(stops, 1);
    expect(filter.processToken('late'), isNull);
  });

  test('artifact-only chunks do not swallow the following answer', () {
    final filter = processor();
    expect(filter.processToken('<artifact>'), isNull);
    expect(filter.processToken('Merhaba'), 'Merhaba');
  });
}
