import 'dart:math' as math;

import 'models.dart';

class Bm25Hit {
  const Bm25Hit({
    required this.document,
    required this.chunk,
    required this.score,
  });

  final RagDocument document;
  final RagChunk chunk;
  final double score;
}

class _Posting {
  const _Posting(this.chunkOffset, this.termFrequency);
  final int chunkOffset;
  final int termFrequency;
}

/// Tokenized index for one RAG document.
///
/// Chunk text is tokenized once when the document changes instead of once for
/// every user query. Each term stores a compact postings list so scoring only
/// visits chunks containing query terms.
class Bm25DocumentIndex {
  Bm25DocumentIndex._({
    required this.document,
    required this.chunks,
    required this.tokenLengths,
    required this._postings,
    required this.documentFrequency,
    required this.totalTokens,
  });

  factory Bm25DocumentIndex.build({
    required RagDocument document,
    required List<RagChunk> chunks,
    required List<String> Function(String text) tokenize,
  }) {
    final lengths = List<int>.filled(chunks.length, 0);
    final postings = <String, List<_Posting>>{};
    final df = <String, int>{};
    var totalTokens = 0;

    for (var i = 0; i < chunks.length; i++) {
      final terms = tokenize(chunks[i].text);
      lengths[i] = terms.length;
      totalTokens += terms.length;
      final tf = <String, int>{};
      for (final term in terms) {
        tf[term] = (tf[term] ?? 0) + 1;
      }
      for (final entry in tf.entries) {
        postings
            .putIfAbsent(entry.key, () => <_Posting>[])
            .add(_Posting(i, entry.value));
        df[entry.key] = (df[entry.key] ?? 0) + 1;
      }
    }

    return Bm25DocumentIndex._(
      document: document,
      chunks: List<RagChunk>.unmodifiable(chunks),
      tokenLengths: List<int>.unmodifiable(lengths),
      postings: Map<String, List<_Posting>>.unmodifiable(
        postings.map(
          (key, value) => MapEntry(key, List<_Posting>.unmodifiable(value)),
        ),
      ),
      documentFrequency: Map<String, int>.unmodifiable(df),
      totalTokens: totalTokens,
    );
  }

  final RagDocument document;
  final List<RagChunk> chunks;
  final List<int> tokenLengths;
  final Map<String, List<_Posting>> _postings;
  final Map<String, int> documentFrequency;
  final int totalTokens;

  int get chunkCount => chunks.length;
  bool get isEmpty => chunks.isEmpty;

  bool matches(RagDocument next) =>
      next.id == document.id &&
      next.updatedAt == document.updatedAt &&
      next.chunkCount == document.chunkCount;
}

class _CachedDocumentIndex {
  const _CachedDocumentIndex(this.index);
  final Bm25DocumentIndex index;
}

/// Reusable document-index cache owned by a retrieval engine.
class Bm25IndexCache {
  final Map<String, _CachedDocumentIndex> _documents =
      <String, _CachedDocumentIndex>{};

  int get documentCount => _documents.length;
  int get chunkCount => _documents.values.fold<int>(
        0,
        (sum, entry) => sum + entry.index.chunkCount,
      );

  Bm25DocumentIndex? get(String documentId) =>
      _documents[documentId]?.index;

  Bm25DocumentIndex put({
    required RagDocument document,
    required List<RagChunk> chunks,
    required List<String> Function(String text) tokenize,
  }) {
    final current = _documents[document.id]?.index;
    if (current != null && current.matches(document)) return current;
    final next = Bm25DocumentIndex.build(
      document: document,
      chunks: chunks,
      tokenize: tokenize,
    );
    _documents[document.id] = _CachedDocumentIndex(next);
    return next;
  }

  void invalidate(String documentId) {
    _documents.remove(documentId);
  }

  void clear() => _documents.clear();

  void retainOnly(Iterable<String> documentIds) {
    final keep = documentIds.toSet();
    _documents.removeWhere((id, _) => !keep.contains(id));
  }
}

/// Scores a selected set of already-tokenized document indexes.
class Bm25Scorer {
  const Bm25Scorer({
    this.k1 = 1.5,
    this.b = 0.75,
  });

  final double k1;
  final double b;

  List<Bm25Hit> score({
    required List<String> queryTerms,
    required List<Bm25DocumentIndex> documents,
    required int topK,
  }) {
    if (queryTerms.isEmpty || documents.isEmpty || topK <= 0) {
      return const <Bm25Hit>[];
    }

    final usable = documents.where((d) => !d.isEmpty).toList(growable: false);
    if (usable.isEmpty) return const <Bm25Hit>[];

    var totalChunks = 0;
    var totalTokens = 0;
    for (final document in usable) {
      totalChunks += document.chunkCount;
      totalTokens += document.totalTokens;
    }
    if (totalChunks == 0) return const <Bm25Hit>[];

    final averageLength = totalTokens == 0 ? 1.0 : totalTokens / totalChunks;
    final uniqueTerms = queryTerms.toSet();
    final df = <String, int>{};
    for (final term in uniqueTerms) {
      var count = 0;
      for (final document in usable) {
        count += document.documentFrequency[term] ?? 0;
      }
      if (count > 0) df[term] = count;
    }
    if (df.isEmpty) return const <Bm25Hit>[];

    final scores = <_ChunkKey, double>{};
    final refs = <_ChunkKey, (RagDocument, RagChunk)>{};

    for (final term in uniqueTerms) {
      final frequency = df[term];
      if (frequency == null || frequency <= 0) continue;
      final idf = math.log(
        1 + (totalChunks - frequency + 0.5) / (frequency + 0.5),
      );

      for (final document in usable) {
        final termPostings = document._postings[term];
        if (termPostings == null) continue;
        for (final posting in termPostings) {
          final dl = document.tokenLengths[posting.chunkOffset].toDouble();
          final tf = posting.termFrequency.toDouble();
          final denominator = tf + k1 * (1 - b + b * (dl / averageLength));
          final contribution = idf * ((tf * (k1 + 1)) / denominator);
          final key = _ChunkKey(document.document.id, posting.chunkOffset);
          scores[key] = (scores[key] ?? 0) + contribution;
          refs.putIfAbsent(
            key,
            () => (document.document, document.chunks[posting.chunkOffset]),
          );
        }
      }
    }

    if (scores.isEmpty) return const <Bm25Hit>[];

    // Keeping only topK while scoring would reduce sort work further, but RAG
    // corpora are usually modest. Sorting only matched chunks already avoids
    // the old full-corpus sort and keeps deterministic tie behavior simple.
    final ordered = scores.entries.toList(growable: false)
      ..sort((a, b) {
        final scoreOrder = b.value.compareTo(a.value);
        if (scoreOrder != 0) return scoreOrder;
        final aRef = refs[a.key]!;
        final bRef = refs[b.key]!;
        final docOrder = aRef.$1.id.compareTo(bRef.$1.id);
        if (docOrder != 0) return docOrder;
        return aRef.$2.chunkIndex.compareTo(bRef.$2.chunkIndex);
      });

    final count = topK < ordered.length ? topK : ordered.length;
    final hits = <Bm25Hit>[];
    for (var i = 0; i < count; i++) {
      final entry = ordered[i];
      final ref = refs[entry.key]!;
      hits.add(Bm25Hit(
        document: ref.$1,
        chunk: ref.$2,
        score: entry.value,
      ));
    }
    return hits;
  }
}

class _ChunkKey {
  const _ChunkKey(this.documentId, this.chunkOffset);
  final String documentId;
  final int chunkOffset;

  @override
  bool operator ==(Object other) =>
      other is _ChunkKey &&
      other.documentId == documentId &&
      other.chunkOffset == chunkOffset;

  @override
  int get hashCode => Object.hash(documentId, chunkOffset);
}
