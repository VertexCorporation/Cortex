// lib/rag/storage.dart
//
// Persistent storage for the RAG index (documents + chunks) using sqflite.

import 'package:cortex/chat/services/database.dart';
import 'package:cortex/rag/models.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class RagStorageService {
  RagStorageService();

  static const String _docTable = 'rag_documents';
  static const String _chunkTable = 'rag_chunks';

  // Keep well below SQLite's common bind-parameter ceiling.
  static const int _maxIdsPerQuery = 400;

  // ---------------------------------------------------------------------
  // Documents
  // ---------------------------------------------------------------------

  Future<void> upsertDocument(RagDocument document) async {
    final db = await DbHelper().db;
    await db.insert(
      _docTable,
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDocumentStatus({
    required String id,
    required RagDocumentStatus status,
    int? chunkCount,
  }) async {
    final db = await DbHelper().db;
    await db.update(
      _docTable,
      {
        'status': status.name,
        if (chunkCount != null) 'chunkCount': chunkCount,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<RagDocument?> getDocument(String id) async {
    if (id.isEmpty) return null;
    final db = await DbHelper().db;
    final rows = await db.query(
      _docTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RagDocument.fromMap(rows.first);
  }

  Future<RagDocument?> getDocumentByPath(String filePath) async {
    if (filePath.isEmpty) return null;
    final db = await DbHelper().db;
    final rows = await db.query(
      _docTable,
      where: 'filePath = ?',
      whereArgs: [filePath],
      orderBy: 'updatedAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RagDocument.fromMap(rows.first);
  }

  Future<List<RagDocument>> getAllDocuments() async {
    final db = await DbHelper().db;
    final rows = await db.query(_docTable, orderBy: 'updatedAt DESC');
    return rows.map(RagDocument.fromMap).toList(growable: false);
  }

  Future<List<RagDocument>> getIndexedDocuments() async {
    final db = await DbHelper().db;
    final rows = await db.query(
      _docTable,
      where: 'status = ?',
      whereArgs: [RagDocumentStatus.indexed.name],
      orderBy: 'updatedAt DESC',
    );
    return rows.map(RagDocument.fromMap).toList(growable: false);
  }

  Future<List<RagDocument>> getDocumentsByIds(
    Iterable<String> documentIds,
  ) async {
    final ids = documentIds.where((id) => id.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return const <RagDocument>[];

    final db = await DbHelper().db;
    final output = <RagDocument>[];
    for (final batch in _batches(ids, _maxIdsPerQuery)) {
      final placeholders = List.filled(batch.length, '?').join(',');
      final rows = await db.query(
        _docTable,
        where: 'id IN ($placeholders)',
        whereArgs: batch,
      );
      output.addAll(rows.map(RagDocument.fromMap));
    }

    // Preserve caller order where possible. It makes retrieval tie-breaking and
    // tests deterministic without additional database ordering work.
    final order = <String, int>{
      for (var i = 0; i < ids.length; i++) ids[i]: i,
    };
    output.sort((a, b) =>
        (order[a.id] ?? 1 << 30).compareTo(order[b.id] ?? 1 << 30));
    return output;
  }

  Future<void> deleteDocument(String id) async {
    final db = await DbHelper().db;
    await db.transaction((txn) async {
      await txn.delete(_chunkTable, where: 'documentId = ?', whereArgs: [id]);
      await txn.delete(_docTable, where: 'id = ?', whereArgs: [id]);
    });
  }

  // ---------------------------------------------------------------------
  // Chunks
  // ---------------------------------------------------------------------

  Future<void> insertChunks(List<RagChunk> chunks) async {
    if (chunks.isEmpty) return;
    final db = await DbHelper().db;
    final batch = db.batch();
    for (final chunk in chunks) {
      batch.insert(_chunkTable, chunk.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<RagChunk>> getChunksForDocument(String documentId) async {
    if (documentId.isEmpty) return const <RagChunk>[];
    final db = await DbHelper().db;
    final rows = await db.query(
      _chunkTable,
      where: 'documentId = ?',
      whereArgs: [documentId],
      orderBy: 'chunkIndex ASC',
    );
    return rows.map(RagChunk.fromMap).toList(growable: false);
  }

  Future<void> deleteChunksForDocument(String documentId) async {
    final db = await DbHelper().db;
    await db
        .delete(_chunkTable, where: 'documentId = ?', whereArgs: [documentId]);
  }

  /// Loads chunks for many documents with a small number of SQL queries.
  ///
  /// The old implementation issued one query per document. Selecting ten RAG
  /// documents therefore paid ten database round trips before scoring began.
  Future<Map<String, List<RagChunk>>> getChunksByDocument(
    List<String> documentIds,
  ) async {
    final ids = documentIds.where((id) => id.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return <String, List<RagChunk>>{};

    final result = <String, List<RagChunk>>{
      for (final id in ids) id: <RagChunk>[],
    };
    final db = await DbHelper().db;

    for (final batch in _batches(ids, _maxIdsPerQuery)) {
      final placeholders = List.filled(batch.length, '?').join(',');
      final rows = await db.query(
        _chunkTable,
        where: 'documentId IN ($placeholders)',
        whereArgs: batch,
        orderBy: 'documentId ASC, chunkIndex ASC',
      );
      for (final row in rows) {
        final chunk = RagChunk.fromMap(row);
        result.putIfAbsent(chunk.documentId, () => <RagChunk>[]).add(chunk);
      }
    }
    return result;
  }

  static Iterable<List<T>> _batches<T>(List<T> input, int batchSize) sync* {
    for (var start = 0; start < input.length; start += batchSize) {
      final end = (start + batchSize < input.length)
          ? start + batchSize
          : input.length;
      yield input.sublist(start, end);
    }
  }

  static void debugLog(String message) {
    debugPrint('[RagStorage] $message');
  }
}
