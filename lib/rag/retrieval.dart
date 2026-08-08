// lib/rag/retrieval.dart
//
// On-device retrieval engine (BM25) with a Turkish-aware tokenizer.
//
// The engine is deliberately behind a small interface so a semantic
// (embedding-based) engine can be swapped in later without touching callers.

import 'dart:math' as math;
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/storage.dart';
import 'package:flutter/foundation.dart';

/// Tokenizes text for retrieval scoring.
class RagTokenizer {
  /// Splits on anything that is not a letter or digit (Unicode aware).
  static final RegExp _splitPattern =
      RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  /// Combining diacritical marks (to fold decomposed accents).
  static final RegExp _combiningMarks = RegExp(r'\p{M}', unicode: true);

  static const Set<String> _stopWords = {
    // Turkish
    'bir', 'bu', 'şu', 've', 'veya', 'ile', 'için', 'gibi', 'ama', 'fakat',
    'çünkü', 'sonra', 'önce', 'de', 'da', 'daha', 'en', 'çok', 'az', 'ne',
    'kim', 'nasıl', 'neden', 'hangi', 'kadar', 'diye', 'ki', 'mi', 'mu',
    'mı', 'ben', 'sen', 'o', 'biz', 'siz', 'onlar', 'benim', 'senin',
    'onun', 'bizim', 'sizin', 'kendi', 'geldi', 'oldu', 'olan', 'olmak',
    'var', 'yok', 'ise', 'ancak', 'hatta', 'üzerine', 'altında',
    // English
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

  /// Returns normalized tokens for [text], stop words removed.
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

/// Abstract retrieval interface.
abstract class RetrievalEngine {
  Future<List<RagRetrievalResult>> query({
    required String query,
    List<String>? documentIds,
    int topK = 4,
  });

  /// Rebuilds any in-memory state (no-op for stateless engines).
  Future<void> warmup();
}

/// BM25 (Okapi) retrieval over the local chunk index.
class Bm25RetrievalEngine implements RetrievalEngine {
  final RagStorageService _storage;
  final RagTokenizer _tokenizer;

  static const double _k1 = 1.5;
  static const double _b = 0.75;

  Bm25RetrievalEngine({
    required RagStorageService storage,
    RagTokenizer? tokenizer,
  })  : _storage = storage,
        _tokenizer = tokenizer ?? RagTokenizer();

  @override
  Future<void> warmup() async {}

  @override
  Future<List<RagRetrievalResult>> query({
    required String query,
    List<String>? documentIds,
    int topK = 4,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const [];

    final allDocs = await _storage.getAllDocuments();
    final indexedDocs = allDocs
        .where((d) => d.status == RagDocumentStatus.indexed)
        .toList();
    if (indexedDocs.isEmpty) return const [];

    final Set<String> allowedIds;
    if (documentIds == null || documentIds.isEmpty) {
      allowedIds = indexedDocs.map((d) => d.id).toSet();
    } else {
      allowedIds = documentIds.toSet();
    }

    final docsById = <String, RagDocument>{
      for (final d in indexedDocs) if (allowedIds.contains(d.id)) d.id: d,
    };
    if (docsById.isEmpty) return const [];

    final chunksByDoc = await _storage.getChunksByDocument(docsById.keys.toList());

    // Flatten chunks with their documents.
    final entries = <(RagDocument, RagChunk)>[];
    for (final entry in chunksByDoc.entries) {
      final doc = docsById[entry.key];
      if (doc == null) continue;
      for (final chunk in entry.value) {
        entries.add((doc, chunk));
      }
    }
    if (entries.isEmpty) return const [];

    final scored = _score(normalizedQuery, entries);
    if (scored.isEmpty) return const [];
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(topK).toList();
  }

  /// Computes BM25 scores for every chunk against [query].
  List<RagRetrievalResult> _score(
    String query,
    List<(RagDocument, RagChunk)> entries,
  ) {
    final queryTerms = _tokenizer.tokenize(query);
    if (queryTerms.isEmpty) return const [];

    final n = entries.length;

    // Per-term document frequency and term frequencies per chunk.
    final Map<String, int> df = {};
    final List<Map<String, int>> chunkTfs = [];
    final List<int> lengths = [];

    for (final entry in entries) {
      final chunkText = entry.$2.text;
      lengths.add(chunkText.length);
      final tf = <String, int>{};
      for (final term in _tokenizer.tokenize(chunkText)) {
        tf[term] = (tf[term] ?? 0) + 1;
      }
      chunkTfs.add(tf);
      for (final term in tf.keys) {
        df[term] = (df[term] ?? 0) + 1;
      }
    }

    final avgLen =
        lengths.isEmpty ? 1 : lengths.reduce((a, b) => a + b) / n;

    final results = <RagRetrievalResult>[];
    for (var i = 0; i < n; i++) {
      final entry = entries[i];
      final tf = chunkTfs[i];
      final dl = lengths[i].toDouble();

      double score = 0;
      final uniqueTerms = queryTerms.toSet();
      for (final term in uniqueTerms) {
        final termFreq = tf[term] ?? 0;
        if (termFreq == 0) continue;

        final docFreq = df[term] ?? 1;
        final idf = math.log(
          1 + (n - docFreq + 0.5) / (docFreq + 0.5),
        );

        final denominator =
            termFreq + _k1 * (1 - _b + _b * (dl / avgLen));
        score += idf * ((termFreq * (_k1 + 1)) / denominator);
      }

      if (score > 0) {
        results.add(RagRetrievalResult(
          chunk: entry.$2,
          document: entry.$1,
          score: score,
        ));
      }
    }
    return results;
  }

  static void debugLog(String message) {
    debugPrint('[RagRetrieval] $message');
  }
}
