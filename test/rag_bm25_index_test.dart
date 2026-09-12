import 'package:cortex/rag/bm25_index.dart';
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/retrieval.dart';
import 'package:flutter_test/flutter_test.dart';

RagDocument doc(String id, {int updatedAt = 1, int chunkCount = 2}) {
  return RagDocument(
    id: id,
    title: id,
    filePath: '/tmp/$id.txt',
    sizeBytes: 100,
    mimeType: 'text/plain',
    status: RagDocumentStatus.indexed,
    chunkCount: chunkCount,
    createdAt: 1,
    updatedAt: updatedAt,
  );
}

RagChunk chunk(String documentId, int index, String text) {
  return RagChunk(
    id: index + 1,
    documentId: documentId,
    chunkIndex: index,
    text: text,
    charStart: 0,
    charEnd: text.length,
  );
}

void main() {
  final tokenizer = RagTokenizer();

  test('index cache reuses unchanged document revision', () {
    final cache = Bm25IndexCache();
    final document = doc('a');
    final chunks = [
      chunk('a', 0, 'flutter mobile performance'),
      chunk('a', 1, 'unrelated text'),
    ];

    final first = cache.put(
      document: document,
      chunks: chunks,
      tokenize: tokenizer.tokenize,
    );
    final second = cache.put(
      document: document,
      chunks: chunks,
      tokenize: tokenizer.tokenize,
    );

    expect(identical(first, second), isTrue);
    expect(cache.documentCount, 1);
  });

  test('changed document revision replaces cached index', () {
    final cache = Bm25IndexCache();
    final firstDoc = doc('a', updatedAt: 1);
    final secondDoc = doc('a', updatedAt: 2);
    final chunks = [chunk('a', 0, 'hello world')];

    final first = cache.put(
      document: firstDoc,
      chunks: chunks,
      tokenize: tokenizer.tokenize,
    );
    final second = cache.put(
      document: secondDoc,
      chunks: chunks,
      tokenize: tokenizer.tokenize,
    );

    expect(identical(first, second), isFalse);
    expect(second.matches(secondDoc), isTrue);
  });

  test('BM25 scorer returns only chunks matching query postings', () {
    final cache = Bm25IndexCache();
    final a = doc('a', chunkCount: 2);
    final b = doc('b', chunkCount: 2);

    final indexA = cache.put(
      document: a,
      chunks: [
        chunk('a', 0, 'dart flutter mobile fast fast fast'),
        chunk('a', 1, 'cooking recipe vegetables'),
      ],
      tokenize: tokenizer.tokenize,
    );
    final indexB = cache.put(
      document: b,
      chunks: [
        chunk('b', 0, 'flutter rendering frame cache'),
        chunk('b', 1, 'history literature poetry'),
      ],
      tokenize: tokenizer.tokenize,
    );

    const scorer = Bm25Scorer();
    final hits = scorer.score(
      queryTerms: tokenizer.tokenize('flutter fast'),
      documents: [indexA, indexB],
      topK: 4,
    );

    expect(hits, hasLength(2));
    expect(hits.first.document.id, 'a');
    expect(hits.first.chunk.chunkIndex, 0);
    expect(hits.every((hit) => hit.score > 0), isTrue);
  });

  test('topK caps result set deterministically', () {
    final cache = Bm25IndexCache();
    final document = doc('a', chunkCount: 3);
    final index = cache.put(
      document: document,
      chunks: [
        chunk('a', 0, 'alpha alpha'),
        chunk('a', 1, 'alpha'),
        chunk('a', 2, 'alpha beta'),
      ],
      tokenize: tokenizer.tokenize,
    );

    const scorer = Bm25Scorer();
    final hits = scorer.score(
      queryTerms: ['alpha'],
      documents: [index],
      topK: 2,
    );
    expect(hits, hasLength(2));
    expect(hits.first.score, greaterThanOrEqualTo(hits.last.score));
  });

  test('cache retains only selected documents', () {
    final cache = Bm25IndexCache();
    for (final id in ['a', 'b', 'c']) {
      cache.put(
        document: doc(id, chunkCount: 1),
        chunks: [chunk(id, 0, 'shared term')],
        tokenize: tokenizer.tokenize,
      );
    }

    cache.retainOnly(['b']);
    expect(cache.documentCount, 1);
    expect(cache.get('a'), isNull);
    expect(cache.get('b'), isNotNull);
    expect(cache.get('c'), isNull);
  });
}
