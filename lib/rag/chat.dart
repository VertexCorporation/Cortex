// lib/rag/chat.dart
//
// Shared helper that ties retrieval + injection together for a single chat
// message. Used by both online and offline send paths.

import 'package:cortex/performance/bounded_pool.dart';
import 'package:cortex/rag/ingestion.dart';
import 'package:cortex/rag/injector.dart';
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/retrieval.dart';
import 'package:cortex/rag/storage.dart';
import 'package:flutter/foundation.dart';

const Set<String> kRagDocumentExtensions = {
  'txt', 'md', 'rtf', 'json', 'xml', 'csv', 'tsv', 'html', 'htm', 'css',
  'js', 'ts', 'jsx', 'tsx', 'py', 'dart', 'java', 'c', 'cpp', 'h', 'hpp',
  'swift', 'kt', 'go', 'rs', 'rb', 'php', 'sh', 'bash', 'ps1', 'sql', 'r',
  'scala', 'lua', 'pl', 'pm', 'yaml', 'yml', 'toml', 'ini', 'cfg', 'conf',
  'env', 'log', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'odt',
  'ods', 'odp',
};

class RagChatService {
  RagChatService({
    required RetrievalEngine retrievalEngine,
    required RagIngestionService ingestion,
    required RagStorageService storage,
    RagContextInjector? injector,
  })  : _retrievalEngine = retrievalEngine,
        _ingestion = ingestion,
        _storage = storage,
        _injector = injector ?? const RagContextInjector();

  final RetrievalEngine _retrievalEngine;
  final RagIngestionService _ingestion;
  final RagStorageService _storage;
  final RagContextInjector _injector;

  // Extraction/indexing can be CPU and storage heavy. Two concurrent files
  // gives attachment batches useful overlap without saturating a mobile device.
  static const BoundedPool _attachmentPool = BoundedPool(concurrency: 2);

  static bool isDocumentFile(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return false;
    return kRagDocumentExtensions
        .contains(path.substring(dot + 1).toLowerCase());
  }

  Future<String?> buildContext({
    required String queryText,
    required bool toggleEnabled,
    required List<String> toggleDocumentIds,
    required List<String> attachmentPaths,
  }) async {
    final documentIds = <String>{};
    if (toggleEnabled) documentIds.addAll(toggleDocumentIds);

    final uniqueAttachments = attachmentPaths
        .where(isDocumentFile)
        .toSet()
        .toList(growable: false);

    final attachedIds = <String>{};
    if (uniqueAttachments.isNotEmpty) {
      final indexed = await _attachmentPool.mapSettled<String, RagDocument?>(
        uniqueAttachments,
        (path, _) => _ensureIndexed(path),
      );
      for (final document in indexed.values.whereType<RagDocument>()) {
        attachedIds.add(document.id);
      }
      if (indexed.hasErrors) {
        debugPrint(
          '[RagChatService] ${indexed.errors.length} attachment indexing '
          'operation(s) failed; continuing with usable documents.',
        );
      }
    }
    documentIds.addAll(attachedIds);

    if (documentIds.isEmpty) return null;

    final query = queryText.trim();
    final topK = query.length < 40 ? 2 : 4;

    List<RagRetrievalResult> results = query.isNotEmpty
        ? await _retrievalEngine.query(
            query: query,
            documentIds: documentIds.toList(growable: false),
            topK: topK,
          )
        : const <RagRetrievalResult>[];

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
      // Use the path index directly rather than loading the entire document
      // table once per attachment.
      final prior = await _storage.getDocumentByPath(path);
      if (prior != null && prior.status == RagDocumentStatus.indexed) {
        return prior;
      }
      return await _ingestion.indexFile(filePath: path);
    } catch (e) {
      debugPrint('[RagChatService] ensureIndexed failed for $path: $e');
      return null;
    }
  }

  Future<List<RagRetrievalResult>> _firstChunks(
    Set<String> documentIds,
    int topK,
  ) async {
    final ids = documentIds.toList(growable: false);
    final results = <RagRetrievalResult>[];

    // Two bulk reads replace getDocument() for each document plus individual
    // chunk queries. This matters when several library documents are selected.
    final documents = await _storage.getDocumentsByIds(ids);
    final docsById = <String, RagDocument>{
      for (final document in documents) document.id: document,
    };
    final chunksByDoc = await _storage.getChunksByDocument(ids);

    for (final id in ids) {
      final doc = docsById[id];
      if (doc == null) continue;
      final chunks = chunksByDoc[id] ?? const <RagChunk>[];
      for (final chunk in chunks.take(topK)) {
        results.add(RagRetrievalResult(
          chunk: chunk,
          document: doc,
          score: 0,
        ));
        if (results.length >= topK) return results;
      }
    }
    return results;
  }
}
