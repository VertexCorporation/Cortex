import 'package:cortex/chat/services/web_search_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ordinary local requests do not incur a search', () {
    for (final query in ['selam', 'Osmanlı tarihini anlat', '2 + 2 kaç?',
      'Python döngü örneği yaz', 'Hello', 'Bugün kelimesini İngilizceye çevir',
      'Write a story about today']) {
      expect(WebSearchPolicy.shouldSearch(query, enabled: true), isFalse,
          reason: query);
    }
  });
  test('current facts and explicit source requests may search', () {
    for (final query in ['Bugün hava durumu nasıl?', 'Dolar kaç TL?',
      'GÜNCEL haberleri anlat', 'Osmanlı tarihini internette araştır',
      'Search the web for Flutter releases', 'latest news']) {
      expect(WebSearchPolicy.shouldSearch(query, enabled: true), isTrue,
          reason: query);
    }
  });
  test('disabled toggle and explicit opt out always win', () {
    expect(WebSearchPolicy.shouldSearch('latest news', enabled: false), isFalse);
    expect(WebSearchPolicy.shouldSearch(
        'Bugün için internette arama', enabled: true), isFalse);
    expect(WebSearchPolicy.shouldSearch(
        'Do not search the web for current news', enabled: true), isFalse);
  });
}
