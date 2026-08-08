// test/rag_chunker_test.dart
import 'package:cortex/rag/chunker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentChunker', () {
    const chunker = DocumentChunker();

    test('returns empty for empty and whitespace input', () {
      expect(chunker.chunk(''), isEmpty);
      expect(chunker.chunk('   \n\t  '), isEmpty);
    });

    test('short text produces a single trimmed chunk', () {
      final chunks = chunker.chunk('Merhaba dünya. Bu kısa bir metin.');
      expect(chunks, hasLength(1));
      expect(chunks.single, 'Merhaba dünya. Bu kısa bir metin.');
    });

    test('short paragraphs are joined into a single chunk', () {
      const text =
          'Paragraf bir içeriği.\n\nParagraf iki içeriği.\n\nParagraf üç içeriği.';
      final chunks = chunker.chunk(text);
      expect(chunks, hasLength(1));
      expect(chunks.single, contains('Paragraf bir içeriği.'));
      expect(chunks.single, contains('Paragraf üç içeriği.'));
    });

    test('long text is split into multiple chunks under the size cap', () {
      final text = List.filled(
        30,
        'Bu uzun bir paragraf içerisinde tekrar eden kelimeler var ve cümleler uzun tutuluyor. ',
      ).join();
      final chunks = chunker.chunk(text);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(
          chunk.length,
          lessThanOrEqualTo(DocumentChunker.defaultChunkSize + 10),
        );
      }
    });

    test('chunks preserve the vast majority of the source text', () {
      final text = List.filled(
        40,
        'Bu paragraf dizinleme testi için uzun bir cümledir ve tekrar tekrar yazılır. ',
      ).join();
      final chunks = chunker.chunk(text);
      final joined = chunks.join(' ');
      // Overlap + trimming means we should still keep most characters.
      expect(joined.length, greaterThan(text.length * 0.6));
    });

    test('respects custom chunk size and overlap', () {
      const small = DocumentChunker(chunkSize: 60, overlapRatio: 0.2);
      final long = List.filled(
        40,
        'kelime parçacığı ekleniyor deneme metni ',
      ).join();
      final chunks = small.chunk(long);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(70));
      }
    });

    test('normalizes CRLF line endings', () {
      const text = 'İlk satır.\r\n\r\nİkinci paragraf.';
      final chunks = chunker.chunk(text);
      expect(chunks, hasLength(1));
      expect(chunks.single, 'İlk satır.\n\nİkinci paragraf.');
    });

    test('does not emit empty chunks', () {
      final text = '\n\nMerhaba\n\n\nDünya\n\n';
      final chunks = chunker.chunk(text);
      expect(chunks, hasLength(1));
      expect(chunks.single, 'Merhaba\n\nDünya');
    });

    test('handles long paragraphs via hard slicing', () {
      // A single very long paragraph (no line breaks) must still be chunked.
      final long = List.filled(
        60,
        'kesintisiz uzun tek bir paragraf kelimesi ',
      ).join();
      final chunks = chunker.chunk(long);
      expect(chunks.length, greaterThan(1));
      expect(chunks.join(), isNotEmpty);
    });
  });
}
