// test/rag_tokenizer_test.dart
import 'package:cortex/rag/retrieval.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RagTokenizer', () {
    final tokenizer = RagTokenizer();

    test('splits on punctuation and whitespace', () {
      expect(tokenizer.tokenize('Hello, world!'), ['hello', 'world']);
    });

    test('drops single-character tokens', () {
      expect(tokenizer.tokenize('a b c cat'), ['cat']);
    });

    test('removes English stop words', () {
      final tokens = tokenizer.tokenize('a and the cat is on the roof');
      expect(tokens, ['cat', 'roof']);
    });

    test('removes Turkish stop words', () {
      final tokens = tokenizer.tokenize('bu bir test ve çok iyi');
      expect(tokens, contains('test'));
      expect(tokens, contains('iyi'));
      expect(tokens, isNot(contains('bu')));
      expect(tokens, isNot(contains('bir')));
      expect(tokens, isNot(contains('ve')));
    });

    test('is case-insensitive', () {
      expect(tokenizer.tokenize('KELİME Kelime kelime'), ['kelime', 'kelime', 'kelime']);
    });

    test('keeps Turkish characters intact', () {
      expect(tokenizer.tokenize('şiir ışık çay'), ['şiir', 'ışık', 'çay']);
    });

    test('returns no tokens for empty or symbol-only input', () {
      expect(tokenizer.tokenize(''), isEmpty);
      expect(tokenizer.tokenize('   '), isEmpty);
      expect(tokenizer.tokenize('!!! ###'), isEmpty);
    });

    test('handles numbers as tokens', () {
      expect(tokenizer.tokenize('madde 5 ve 7 numaralı'), contains('madde'));
      expect(tokenizer.tokenize('madde 5 ve 7 numaralı'), contains('numaralı'));
    });

    test('strips combining diacritical marks following a split', () {
      // U+0308 is a combining diaeresis; after splitting it is removed and
      // the empty segment is dropped, while the surrounding runs remain.
      final tokens = tokenizer.tokenize('ku\u0308cuk');
      expect(tokens, isNotEmpty);
      expect(tokens.join(), contains('ku'));
      expect(tokens.join(), contains('cuk'));
    });
  });
}
