import 'dart:math' as math;

import 'package:cortex/rag/bm25_index.dart';
import 'package:cortex/rag/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'bounded selection matches independent full BM25 sort including ties',
    () {
      final random = math.Random(42);
      final indexes = <Bm25DocumentIndex>[];
      final all = <(RagDocument, RagChunk, List<String>)>[];
      for (var d = 0; d < 5; d++) {
        final document = RagDocument(
          id: 'doc$d',
          title: 'Document',
          filePath: '',
          sizeBytes: 0,
          mimeType: 'text/plain',
          status: RagDocumentStatus.indexed,
          chunkCount: 60,
          createdAt: 1,
          updatedAt: 1,
        );
        final chunks = List.generate(60, (i) {
          final terms = List.generate(
            1 + random.nextInt(15),
            (_) => 't${random.nextInt(8)}',
          );
          final chunk = RagChunk(
            id: i,
            documentId: document.id,
            chunkIndex: i,
            text: terms.join(' '),
            charStart: 0,
            charEnd: 1,
          );
          all.add((document, chunk, terms));
          return chunk;
        });
        indexes.add(
          Bm25DocumentIndex.build(
            document: document,
            chunks: chunks,
            tokenize: (text) => text.split(' '),
          ),
        );
      }
      for (final query in [
        ['t1', 't1', 't3'],
        ['t0'],
        ['missing'],
      ]) {
        final average =
            all.fold<int>(0, (s, c) => s + c.$3.length) / all.length;
        final expected = <Bm25Hit>[];
        for (final row in all) {
          var score = 0.0;
          for (final term in query.toSet()) {
            final tf = row.$3.where((t) => t == term).length;
            if (tf == 0) continue;
            final df = all.where((c) => c.$3.contains(term)).length;
            final idf = math.log(1 + (all.length - df + 0.5) / (df + 0.5));
            score +=
                idf *
                ((tf * 2.5) /
                    (tf + 1.5 * (0.25 + 0.75 * (row.$3.length / average))));
          }
          if (score > 0)
            expected.add(
              Bm25Hit(document: row.$1, chunk: row.$2, score: score),
            );
        }
        expected.sort((a, b) {
          final score = b.score.compareTo(a.score);
          if (score != 0) return score;
          final doc = a.document.id.compareTo(b.document.id);
          return doc != 0
              ? doc
              : a.chunk.chunkIndex.compareTo(b.chunk.chunkIndex);
        });
        for (final k in [0, 1, 4, 25, 300, 500]) {
          final actual = const Bm25Scorer().score(
            queryTerms: query,
            documents: indexes,
            topK: k,
          );
          final selected = expected.take(k).toList();
          expect(
            actual.map((h) => '${h.document.id}:${h.chunk.chunkIndex}'),
            selected.map((h) => '${h.document.id}:${h.chunk.chunkIndex}'),
          );
          for (var i = 0; i < actual.length; i++) {
            expect(actual[i].score, closeTo(selected[i].score, 1e-12));
          }
        }
      }
    },
  );
}
