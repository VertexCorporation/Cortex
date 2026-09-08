import 'package:cortex/chat/services/web_sources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts gateway citations envelope and preserves title', () {
    expect(mergeWebSources([], {'citations': [
      {'url': 'https://example.org/news', 'title': 'News'},
    ]}), [{'url': 'https://example.org/news', 'title': 'News'}]);
  });

  test('accepts bare URL lists with a display title', () {
    expect(mergeWebSources([], ['https://example.org']).single['title'],
        'example.org');
  });

  test('rejects malformed payloads and unsafe URI schemes', () {
    for (final payload in [null, 42, {}, {'citations': 'wrong type'}]) {
      expect(mergeWebSources([], payload), isEmpty);
    }
    expect(mergeWebSources([], [
      null, 42, {}, {'url': 3}, 'javascript:alert(1)',
      'file:///etc/passwd', 'data:text/html,test', '/relative',
      'https://name:password@example.org', 'https://',
    ]), isEmpty);
  });

  test('merges cumulative events by URL in stable order', () {
    final first = mergeWebSources([], ['https://example.org/a']);
    expect(mergeWebSources(first, [
      {'url': 'https://example.org/a', 'title': 'Duplicate'},
      {'url': 'https://example.org/b', 'title': 'Second'},
    ]).map((e) => e['url']), [
      'https://example.org/a', 'https://example.org/b',
    ]);
  });
}
