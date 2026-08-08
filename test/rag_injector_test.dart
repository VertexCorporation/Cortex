// test/rag_injector_test.dart
import 'package:cortex/rag/injector.dart';
import 'package:cortex/rag/models.dart';
import 'package:flutter_test/flutter_test.dart';

RagRetrievalResult _result(String title, String text) {
  return RagRetrievalResult(
    chunk: RagChunk(
      id: 1,
      documentId: 'd',
      chunkIndex: 0,
      text: text,
      charStart: 0,
      charEnd: text.length,
    ),
    document: RagDocument(
      id: 'd',
      title: title,
      filePath: '/tmp/$title.txt',
      sizeBytes: 50,
      mimeType: 'text/plain',
      status: RagDocumentStatus.indexed,
      chunkCount: 1,
      createdAt: 0,
      updatedAt: 0,
    ),
    score: 1.0,
  );
}

void main() {
  group('RagContextInjector', () {
    const injector = RagContextInjector();

    test('empty results produce empty context', () {
      expect(injector.buildContext(const []), isEmpty);
    });

    test('wraps content with a document header and quotes', () {
      final context =
          injector.buildContext([_result('Rapor', 'Bu bir özet metindir.')]);
      expect(context, contains('[Belge: Rapor]'));
      expect(context, contains('"Bu bir özet metindir."'));
    });

    test('multiple results are concatenated', () {
      final context = injector.buildContext([
        _result('Rapor', 'Birinci içerik.'),
        _result('Not', 'İkinci içerik.'),
      ]);
      expect(context, contains('[Belge: Rapor]'));
      expect(context, contains('[Belge: Not]'));
      expect(context, contains('Birinci içerik.'));
      expect(context, contains('İkinci içerik.'));
    });

    test('truncates oversized content within the character budget', () {
      final long = List.filled(5000, 'x').join();
      final context = injector.buildContext([_result('Uzun', long)]);
      expect(
        context.length,
        lessThanOrEqualTo(RagContextInjector.defaultCharBudget + 100),
      );
      expect(context, contains('…'));
    });

    test('skips chunks after the budget is exhausted', () {
      final long = List.filled(5000, 'y').join();
      final context = injector.buildContext([
        _result('Uzun1', long),
        _result('Uzun2', long),
      ]);
      // The second document must not appear once the budget is spent.
      expect(context, contains('[Belge: Uzun1]'));
      expect(context, isNot(contains('[Belge: Uzun2]')));
    });

    test('buildSystemInstruction returns empty for empty context', () {
      expect(injector.buildSystemInstruction(''), isEmpty);
    });

    test('buildSystemInstruction wraps the context', () {
      final wrapped = injector.buildSystemInstruction('parça');
      expect(wrapped, contains('[Referans belgeler]'));
      expect(wrapped, contains('parça'));
    });
  });
}
