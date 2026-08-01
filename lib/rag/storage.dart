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

  Future<List<RagDocument>> getAllDocuments() async {
    final db = await DbHelper().db;
    final rows = await db.query(_docTable, orderBy: 'updatedAt DESC');
    return rows.map(RagDocument.fromMap).toList();
  }

  Future<void> deleteDocument(String id) async {
    final db = await DbHelper().db;
    await db.delete(_chunkTable, where: 'documentId = ?', whereArgs: [id]);
    await db.delete(_docTable, where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------
  // Chunks
  // ---------------------------------------------------------------------

  Future<void> insertChunks(List<RagChunk> chunks) async {
    final db = await DbHelper().db;
    final batch = db.batch();
    for (final chunk in chunks) {
      batch.insert(_chunkTable, chunk.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<RagChunk>> getChunksForDocument(String documentId) async {
    final db = await DbHelper().db;
    final rows = await db.query(
      _chunkTable,
      where: 'documentId = ?',
      whereArgs: [documentId],
      orderBy: 'chunkIndex ASC',
    );
    return rows.map(RagChunk.fromMap).toList();
  }

  Future<void> deleteChunksForDocument(String documentId) async {
    final db = await DbHelper().db;
    await db.delete(_chunkTable, where: 'documentId = ?', whereArgs: [documentId]);
  }

  /// Loads chunks for [documentIds] and groups them by document.
  Future<Map<String, List<RagChunk>>> getChunksByDocument(
    List<String> documentIds,
  ) async {
    final result = <String, List<RagChunk>>{};
    for (final id in documentIds) {
      result[id] = await getChunksForDocument(id);
    }
    return result;
  }

  static void debugLog(String message) {
    debugPrint('[RagStorage] $message');
  }
}
