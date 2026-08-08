// lib/rag/chat.dart
//
// Shared helper that ties retrieval + injection together for a single chat
// message. Used by both the online (SendService) and offline
// (OfflineService) send paths.

import 'package:cortex/rag/ingestion.dart';
import 'package:cortex/rag/injector.dart';
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/retrieval.dart';
import 'package:cortex/rag/storage.dart';
import 'package:flutter/foundation.dart';

/// File extensions that participate in RAG indexing.
const Set<String> kRagDocumentExtensions = {
  'txt', 'md', 'rtf', 'json', 'xml', 'csv', 'tsv',
  'html', 'htm', 'css', 'js', 'ts', 'jsx', 'tsx', 'py', 'dart',
  'java', 'c', 'cpp', 'h', 'hpp', 'swift', 'kt', 'go', 'rs', 'rb',
  'php', 'sh', 'bash', 'ps1', 'sql', 'r', 'scala', 'lua', 'pl', 'pm',
  'yaml', 'yml', 'toml', 'ini', 'cfg', 'conf', 'env', 'log',
  'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
  'odt', 'ods', 'odp',
};

class RagChatService {
  final RetrievalEngine _retrievalEngine;
  final RagIngestionService _ingestion;
  final RagStorageService _storage;
  final RagContextInjector _injector;

  RagChatService({
    required RetrievalEngine retrievalEngine,
    required RagIngestionService ingestion,
    required RagStorageService storage,
    RagContextInjector? injector,
  })
      : _retrievalEngine = retrievalEngine,
        _ingestion = ingestion,
        _storage = storage,
        _injector = injector ?? const RagContextInjector();

  static bool isDocumentFile(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return false;
    return kRagDocumentExtensions
        .contains(path.substring(dot + 1).toLowerCase());
  }

  /// Builds the RAG context block for a message, or returns `null` when RAG
  /// is not active or nothing relevant was found.
  ///
  /// - [toggleEnabled]: user turned on toggle mode.
  /// - [toggleDocumentIds]: documents selected for toggle mode.
  /// - [attachmentPaths]: files attached to the current message.
  Future<String?> buildContext({
    required String queryText,
    required bool toggleEnabled,
    required List<String> toggleDocumentIds,
    required List<String> attachmentPaths,
  }) async {
    final documentIds = <String>{};

    // Toggle mode: query against the user-selected library documents.
    if (toggleEnabled) {
      documentIds.addAll(toggleDocumentIds);
    }

    // Message attachment mode: ensure attached documents are indexed and
    // included in the query scope.
    final attachedIds = <String>{};
    for (final path in attachmentPaths) {
      if (!isDocumentFile(path)) continue;
      final doc = await _ensureIndexed(path);
      if (doc != null) attachedIds.add(doc.id);
    }
    documentIds.addAll(attachedIds);

    if (documentIds.isEmpty) return null;

    final String query = queryText.trim();
    final int topK = query.length < 40 ? 2 : 4;

    List<RagRetrievalResult> results = query.isNotEmpty
        ? await _retrievalEngine.query(
      query: query,
      documentIds: documentIds.toList(),
      topK: topK,
    )
        : const [];

    // Fallback: the query matched nothing but documents are attached — feed
    // the model the first chunks so it can still read the file.
    if (results.isEmpty && attachedIds.isNotEmpty) {
      results = await _firstChunks(attachedIds, topK);
    }

    if (results.isEmpty) return null;

    final context = _injector.buildContext(results);
    if (context.isEmpty) return null;
    return _injector.buildSystemInstruction(context);
  }

  Future<RagDocument?> _ensureIndexed(String path) async {
    try {
      final existing = await _storage.getAllDocuments();
      final prior = existing
          .where((d) => d.filePath == path)
          .firstOrNull;
      if (prior != null && prior.status == RagDocumentStatus.indexed) {
        return prior;
      }
      return await _ingestion.indexFile(filePath: path);
    } catch (e) {
      debugPrint('[RagChatService] ensureIndexed failed for $path: $e');
      return null;
    }
  }

  Future<List<RagRetrievalResult>> _firstChunks(Set<String> documentIds,
      int topK,) async {
    final chunksByDoc =
    await _storage.getChunksByDocument(documentIds.toList());
    final results = <RagRetrievalResult>[];
    for (final entry in chunksByDoc.entries) {
      final doc = await _storage.getDocument(entry.key);
      if (doc == null) continue;
      for (final chunk in entry.value.take(topK)) {
        results.add(RagRetrievalResult(
          chunk: chunk,
          document: doc,
          score: 0,
        ));
      }
    }
    return results;
  }
}
