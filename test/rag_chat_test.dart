// test/rag_chat_test.dart
import 'package:cortex/rag/chat.dart';
import 'package:cortex/rag/ingestion.dart';
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/retrieval.dart';
import 'package:cortex/rag/storage.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRagStorage extends RagStorageService {
  final List<RagDocument> docs;
  final Map<String, List<RagChunk>> chunksByDoc;

  FakeRagStorage(this.docs, this.chunksByDoc);

  @override
  Future<List<RagDocument>> getAllDocuments() async => docs;

  @override
  Future<RagDocument?> getDocument(String id) async {
    for (final doc in docs) {
      if (doc.id == id) return doc;
    }
    return null;
  }

  @override
  Future<Map<String, List<RagChunk>>> getChunksByDocument(
    List<String> documentIds,
  ) async {
    return {
      for (final id in documentIds)
        if (chunksByDoc[id] != null) id: chunksByDoc[id]!,
    };
  }
}

class FakeRagIngestion extends RagIngestionService {
  FakeRagIngestion(RagStorageService storage) : super(storage: storage);

  int indexCalls = 0;

  @override
  Future<RagDocument?> indexFile({
    required String filePath,
    String? title,
  }) async {
    indexCalls++;
    return _doc('doc-yeni', title ?? 'Yeni', filePath);
  }
}

class FakeRetrievalEngine implements RetrievalEngine {
  List<RagRetrievalResult> results = [];
  List<String>? lastDocumentIds;

  @override
  Future<List<RagRetrievalResult>> query({
    required String query,
    List<String>? documentIds,
    int topK = 4,
  }) async {
    lastDocumentIds = documentIds;
    return results;
  }

  @override
  Future<void> warmup() async {}
}

RagDocument _doc(String id, String title, String filePath) {
  return RagDocument(
    id: id,
    title: title,
    filePath: filePath,
    sizeBytes: 100,
    mimeType: 'text/plain',
    status: RagDocumentStatus.indexed,
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
  group('RagChatService', () {
    test('isDocumentFile detects supported extensions only', () {
      expect(RagChatService.isDocumentFile('belge.pdf'), isTrue);
      expect(RagChatService.isDocumentFile('veri.xlsx'), isTrue);
      expect(RagChatService.isDocumentFile('notlar.txt'), isTrue);
      expect(RagChatService.isDocumentFile('foto.png'), isFalse);
      expect(RagChatService.isDocumentFile('dosya'), isFalse);
    });

    test('returns null when neither toggle nor attachments are active', () async {
      final storage = FakeRagStorage([], {});
      final service = RagChatService(
        retrievalEngine: FakeRetrievalEngine(),
        ingestion: FakeRagIngestion(storage),
        storage: storage,
      );
      final out = await service.buildContext(
        queryText: 'soru',
        toggleEnabled: false,
        toggleDocumentIds: const [],
        attachmentPaths: const [],
      );
      expect(out, isNull);
    });

    test('queries selected documents in toggle mode', () async {
      final storage = FakeRagStorage([], {});
      final retrieval = FakeRetrievalEngine()
        ..results = [
          RagRetrievalResult(
            chunk: _chunk(1, 'doc1', 'şifre doğrulama sistemi'),
            document: _doc('doc1', 'Rapor', '/tmp/rapor.txt'),
            score: 2.0,
          ),
        ];
      final service = RagChatService(
        retrievalEngine: retrieval,
        ingestion: FakeRagIngestion(storage),
        storage: storage,
      );

      final out = await service.buildContext(
        queryText: 'şifre',
        toggleEnabled: true,
        toggleDocumentIds: const ['doc1', 'doc2'],
        attachmentPaths: const [],
      );

      expect(retrieval.lastDocumentIds, containsAll(['doc1', 'doc2']));
      expect(out, contains('[Referans belgeler]'));
      expect(out, contains('[Belge: Rapor]'));
      expect(out, contains('şifre doğrulama sistemi'));
    });

    test('falls back to first chunks for attached documents', () async {
      final storage = FakeRagStorage(
        [_doc('doc-ek', 'Ek', '/tmp/ek.txt')],
        {
          'doc-ek': [_chunk(1, 'doc-ek', 'ek dosyanın uzun içeriği burada')],
        },
      );
      final retrieval = FakeRetrievalEngine(); // returns empty results
      final ingestion = FakeRagIngestion(storage);
      final service = RagChatService(
        retrievalEngine: retrieval,
        ingestion: ingestion,
        storage: storage,
      );

      final out = await service.buildContext(
        queryText: 'bu dosyada ne yazıyor',
        toggleEnabled: false,
        toggleDocumentIds: const [],
        attachmentPaths: const ['/tmp/ek.txt'],
      );

      // Attached document is already indexed, so ingestion is not invoked.
      expect(ingestion.indexCalls, 0);
      expect(out, contains('ek dosyanın uzun içeriği burada'));
      expect(out, contains('[Belge: Ek]'));
    });

    test('indexes attached documents that are not yet in the library', () async {
      final storage = FakeRagStorage([], {});
      final retrieval = FakeRetrievalEngine()
        ..results = [
          RagRetrievalResult(
            chunk: _chunk(1, 'doc-yeni', 'yeni dosya içeriği'),
            document: _doc('doc-yeni', 'Yeni', '/tmp/yeni.docx'),
            score: 1.0,
          ),
        ];
      final ingestion = FakeRagIngestion(storage);
      final service = RagChatService(
        retrievalEngine: retrieval,
        ingestion: ingestion,
        storage: storage,
      );

      final out = await service.buildContext(
        queryText: 'soru',
        toggleEnabled: false,
        toggleDocumentIds: const [],
        attachmentPaths: const ['/tmp/yeni.docx'],
      );

      // Not in the library yet → ingestion must have been invoked.
      expect(ingestion.indexCalls, 1);
      expect(out, contains('[Referans belgeler]'));
    });

    test('ignores non-document attachments', () async {
      final storage = FakeRagStorage([], {});
      final retrieval = FakeRetrievalEngine();
      final service = RagChatService(
        retrievalEngine: retrieval,
        ingestion: FakeRagIngestion(storage),
        storage: storage,
      );

      final out = await service.buildContext(
        queryText: 'soru',
        toggleEnabled: false,
        toggleDocumentIds: const [],
        attachmentPaths: const ['/tmp/foto.png'],
      );

      expect(out, isNull);
    });
  });
}
