// lib/rag/retrieval.dart
//
// On-device BM25 retrieval with a Turkish-aware tokenizer and a reusable
// in-memory postings index. Documents are tokenized only when their indexed
// revision changes; normal queries score postings for query terms only.

import 'package:cortex/performance/perf_trace.dart';
import 'package:cortex/rag/bm25_index.dart';
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/storage.dart';
import 'package:flutter/foundation.dart';

class RagTokenizer {
  static final RegExp _splitPattern = RegExp(r'[^\p{L}\p{N}]+', unicode: true);
  static final RegExp _combiningMarks = RegExp(r'\p{M}', unicode: true);

  static const Set<String> _stopWords = {
    'bir', 'bu', 'şu', 've', 'veya', 'ile', 'için', 'gibi', 'ama', 'fakat',
    'çünkü', 'sonra', 'önce', 'de', 'da', 'daha', 'en', 'çok', 'az', 'ne',
    'kim', 'nasıl', 'neden', 'hangi', 'kadar', 'diye', 'ki', 'mi', 'mu',
    'mı', 'ben', 'sen', 'o', 'biz', 'siz', 'onlar', 'benim', 'senin',
    'onun', 'bizim', 'sizin', 'kendi', 'geldi', 'oldu', 'olan', 'olmak',
    'var', 'yok', 'ise', 'ancak', 'hatta', 'üzerine', 'altında',
    'a', 'an', 'the', 'and', 'or', 'but', 'for', 'with', 'from', 'that',
    'this', 'these', 'those', 'are', 'was', 'were', 'been', 'being', 'is',
    'be', 'to', 'of', 'in', 'on', 'at', 'by', 'as', 'it', 'its', 'we',
    'you', 'your', 'they', 'their', 'he', 'she', 'his', 'her', 'him',
    'not', 'no', 'yes', 'have', 'has', 'had', 'do', 'does', 'did', 'will',
    'would', 'can', 'could', 'should', 'may', 'might', 'about', 'into',
    'over', 'after', 'before', 'up', 'down', 'out', 'off', 'then', 'than',
    'so', 'if', 'because', 'while', 'who', 'whom', 'which', 'when', 'where',
    'why', 'how', 'all', 'some', 'any', 'each', 'every', 'both', 'more',
    'most', 'other', 'only', 'own', 'such', 'too', 'very', 'just',
  };

  List<String> tokenize(String text) {
    final tokens = <String>[];
    for (final part in text.toLowerCase().split(_splitPattern)) {
      final token = part.replaceAll(_combiningMarks, '');
      if (token.isEmpty || token.length < 2) continue;
      if (_stopWords.contains(token)) continue;
      tokens.add(token);
    }
    return tokens;
  }
}

abstract class RetrievalEngine {
  Future<List<RagRetrievalResult>> query({
    required String query,
    List<String>? documentIds,
    int topK = 4,
  });

  Future<void> warmup();
}

class Bm25RetrievalEngine implements RetrievalEngine {
  Bm25RetrievalEngine({
    required RagStorageService storage,
    RagTokenizer? tokenizer,
  })  : _storage = storage,
        _tokenizer = tokenizer ?? RagTokenizer();

  final RagStorageService _storage;
  final RagTokenizer _tokenizer;
  final Bm25IndexCache _indexCache = Bm25IndexCache();
  final Bm25Scorer _scorer = const Bm25Scorer();
  Future<void>? _warmupFuture;

  int get cachedDocumentCount => _indexCache.documentCount;
  int get cachedChunkCount => _indexCache.chunkCount;

  @override
  Future<void> warmup() {
    final existing = _warmupFuture;
    if (existing != null) return existing;
    late Future<void> future;
    future = PerfTrace.measureAsync('rag.warmup', () async {
      final documents = await _storage.getIndexedDocuments();
      await _ensureIndexes(documents);
      _indexCache.retainOnly(documents.map((document) => document.id));
    }).whenComplete(() {
      if (identical(_warmupFuture, future)) _warmupFuture = null;
    });
    _warmupFuture = future;
    return future;
  }

  @override
  Future<List<RagRetrievalResult>> query({
    required String query,
    List<String>? documentIds,
    int topK = 4,
  }) {
    return PerfTrace.measureAsync(
      'rag.query',
      () => _queryInternal(
        query: query,
        documentIds: documentIds,
        topK: topK,
      ),
      metadata: {
        'queryChars': query.length,
        'selectedDocuments': documentIds?.length ?? -1,
        'topK': topK,
      },
    );
  }

  Future<List<RagRetrievalResult>> _queryInternal({
    required String query,
    List<String>? documentIds,
    required int topK,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty || topK <= 0) return const [];

    final List<RagDocument> documents;
    if (documentIds == null || documentIds.isEmpty) {
      documents = await _storage.getIndexedDocuments();
    } else {
      documents = (await _storage.getDocumentsByIds(documentIds))
          .where((document) => document.status == RagDocumentStatus.indexed)
          .toList(growable: false);
    }
    if (documents.isEmpty) return const [];

    await _ensureIndexes(documents);

    final indexes = <Bm25DocumentIndex>[];
    for (final document in documents) {
      final index = _indexCache.get(document.id);
      if (index != null && index.matches(document) && !index.isEmpty) {
        indexes.add(index);
      }
    }
    if (indexes.isEmpty) return const [];

    final queryTerms = _tokenizer.tokenize(normalizedQuery);
    if (queryTerms.isEmpty) return const [];

    final hits = _scorer.score(
      queryTerms: queryTerms,
      documents: indexes,
      topK: topK,
    );
    return hits
        .map(
          (hit) => RagRetrievalResult(
            chunk: hit.chunk,
            document: hit.document,
            score: hit.score,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _ensureIndexes(List<RagDocument> documents) async {
    final stale = <RagDocument>[];
    for (final document in documents) {
      final current = _indexCache.get(document.id);
      if (current == null || !current.matches(document)) stale.add(document);
    }
    if (stale.isEmpty) return;

    final chunksByDocument =
        await _storage.getChunksByDocument(stale.map((d) => d.id).toList());
    for (final document in stale) {
      _indexCache.put(
        document: document,
        chunks: chunksByDocument[document.id] ?? const <RagChunk>[],
        tokenize: _tokenizer.tokenize,
      );
    }
  }

  void invalidateDocument(String documentId) {
    _indexCache.invalidate(documentId);
  }

  void clearIndex() {
    _indexCache.clear();
  }

  static void debugLog(String message) {
    debugPrint('[RagRetrieval] $message');
  }
}
