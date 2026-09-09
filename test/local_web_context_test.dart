import 'package:cortex/chat/services/local_web_context.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uncited or empty summary preserves original local prompt', () {
    expect(LocalWebContext('summary', []).augment('question'), 'question');
    expect(LocalWebContext('', ['https://example.org']).augment('question'),
        'question');
  });

  test('rejects unsafe citations and deduplicates valid sources', () {
    final result = LocalWebContext('facts', [
      'javascript:alert(1)', 'file:///private',
      'https://example.org', {'url': 'https://example.org'},
    ]);
    expect(result.sources, hasLength(1));
    expect(result.augment('question'), contains('https://example.org'));
    expect(result.augment('question'), endsWith('User request:\nquestion'));
  });

  test('bounds the supplemental summary and source count', () {
    final result = LocalWebContext('a' * 5000,
        List.generate(10, (i) => 'https://example.org/$i'));
    expect(result.summary.length, 3000);
    expect(result.sources, hasLength(4));
  });
}
