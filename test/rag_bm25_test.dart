// test/rag_bm25_test.dart
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/retrieval.dart';
import 'package:cortex/rag/storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory storage double so BM25 can run without a real sqflite database.
class FakeRagStorage extends RagStorageService {
  final List<RagDocument> docs;
  final Map<String, List<RagChunk>> chunksByDoc;

  FakeRagStorage(this.docs, this.chunksByDoc);

  @override
  Future<List<RagDocument>> getAllDocuments() async => docs;

  @override
  Future<Map<String, List<RagChunk>>> getChunksByDocument(
    List<String> documentIds,
  ) async {
    return {
      for (final id in documentIds)
        if (chunksByDoc[id] != null) id: chunksByDoc[id]!,
    };
  }

  @override
  Future<RagDocument?> getDocument(String id) async {
    for (final doc in docs) {
      if (doc.id == id) return doc;
    }
    return null;
  }
}

RagDocument _doc(String id, String title,
    {RagDocumentStatus status = RagDocumentStatus.indexed}) {
  return RagDocument(
    id: id,
    title: title,
    filePath: '/tmp/$title.txt',
    sizeBytes: 120,
    mimeType: 'text/plain',
    status: status,
    chunkCount: 1,
    createdAt: 0,
    updatedAt: 0,
  );
}

RagChunk _chunk(int id, String docId, String text) {
  return RagChunk(
    id: id,
    documentId: docId,
    chunkIndex: 0,
    text: text,
    charStart: 0,
    charEnd: text.length,
  );
}

void main() {
  late FakeRagStorage storage;
  late Bm25RetrievalEngine engine;

  final doc1 = _doc('doc1', 'Şifre Raporu');
  final doc2 = _doc('doc2', 'Güvenlik Notları');
  final doc3 = _doc('doc3', 'Analiz Raporu');
  final doc4 = _doc('doc4', 'Gizli Belge',
      status: RagDocumentStatus.pending);

  setUp(() {
    storage = FakeRagStorage(
      [doc1, doc2, doc3, doc4],
      {
        'doc1': [_chunk(1, 'doc1', 'şifre şifre doğrulama sistemini açıklar')],
        'doc2': [_chunk(2, 'doc2', 'şifre yönetimi güvenlik ile ilgilidir')],
        'doc3': [_chunk(3, 'doc3', 'analiz raporu hazırlandı ve yayınlandı')],
        'doc4': [_chunk(4, 'doc4', 'şifre gizli bilgi içerir')],
      },
    );
    engine = Bm25RetrievalEngine(storage: storage);
  });

  test('returns no results for an empty query', () async {
    expect(await engine.query(query: ''), isEmpty);
    expect(await engine.query(query: '   '), isEmpty);
  });

  test('returns no results when nothing matches', () async {
    final results = await engine.query(query: 'yoklamayapanyok');
    expect(results, isEmpty);
  });

  test('ranks higher term frequency first', () async {
    final results = await engine.query(query: 'şifre');
    expect(results, isNotEmpty);
    // doc1 has şifre twice, doc2 once.
    expect(results.first.document.id, 'doc1');
    expect(results.map((r) => r.document.id), containsAll(['doc1', 'doc2']));
  });

  test('excludes documents that are not indexed', () async {
    final results = await engine.query(query: 'şifre');
    for (final result in results) {
      expect(result.document.status, RagDocumentStatus.indexed);
    }
    expect(results.map((r) => r.document.id), isNot(contains('doc4')));
  });

  test('respects the topK limit', () async {
    final results = await engine.query(query: 'şifre', topK: 1);
    expect(results, hasLength(1));
    expect(results.single.document.id, 'doc1');
  });

  test('only queries the allowed document ids', () async {
    final results = await engine.query(query: 'şifre', documentIds: ['doc3']);
    expect(results, isEmpty);
  });

  test('matches multiple query terms across documents', () async {
    final results = await engine.query(query: 'şifre analiz');
    final ids = results.map((r) => r.document.id).toSet();
    expect(ids, containsAll(['doc1', 'doc2', 'doc3']));
  });

  test('querying when no documents exist returns empty', () async {
    final empty = Bm25RetrievalEngine(storage: FakeRagStorage([], {}));
    expect(await empty.query(query: 'şifre'), isEmpty);
  });
}
