// lib/rag/chat.dart
//
// Shared helper that ties retrieval + injection together for a single chat
// message. Used by both online and offline send paths.

import 'package:cortex/performance/bounded_pool.dart';
import 'package:cortex/rag/ingestion.dart';
import 'package:cortex/rag/injector.dart';
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/offline_pdf.dart';
import 'package:cortex/rag/offline_pdf_guard.dart';
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
    required this._retrievalEngine,
    required this._ingestion,
    required this._storage,
    RagContextInjector? injector,
    OfflinePdfContextService? offlinePdfContext,
  })  : _injector = injector ?? const RagContextInjector(),
        _offlinePdfContext = offlinePdfContext ?? OfflinePdfContextService();

  final RetrievalEngine _retrievalEngine;
  final RagIngestionService _ingestion;
  final RagStorageService _storage;
  final RagContextInjector _injector;
  final OfflinePdfContextService _offlinePdfContext;

  // Extraction/indexing can be CPU and storage heavy. Two concurrent files
  // gives attachment batches useful overlap without saturating a mobile device.
  static const BoundedPool _attachmentPool = BoundedPool(concurrency: 2);

  static bool isDocumentFile(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return false;
    return kRagDocumentExtensions
        .contains(path.substring(dot + 1).toLowerCase());
  }

  static bool _isPdf(String path) => path.toLowerCase().endsWith('.pdf');

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

    // Direct PDF attachments use a dedicated tiny-model-safe path: page
    // identity, layout-noise cleanup, a persistent canonical index and only a
    // handful of high-value excerpts. Parsing/indexing never invokes an LLM.
    final pdfAttachments =
        uniqueAttachments.where(_isPdf).toList(growable: false);
    final nonPdfAttachments =
        uniqueAttachments.where((path) => !_isPdf(path)).toList(growable: false);

    String? compactPdfContext;
    if (pdfAttachments.isNotEmpty) {
      try {
        // The final page guard understands natural Turkish inflections such as
        // "3. sayfada" / "3. sayfayı". Append canonical `page N` selectors
        // only for retrieval so the page-aware engine locks onto the same
        // metadata even though its internal parser intentionally stays simple.
        final retrievalQuery =
            OfflinePdfPageGuard.normalizeForRetrieval(queryText);
        final rawPdfContext = await _offlinePdfContext.buildContext(
          queryText: retrievalQuery,
          pdfPaths: pdfAttachments,
          // Conservative default on this shared RAG surface. The PDF engine
          // itself supports explicit 600M/1B/2B profiles; the offline-only
          // caller can later pass the selected model size without reindexing.
          modelSize: 1500,
        );
        if (rawPdfContext != null && rawPdfContext.isNotEmpty) {
          compactPdfContext = OfflinePdfPageGuard.apply(
            queryText: queryText,
            context: rawPdfContext,
          );
        }
      } catch (e) {
        debugPrint('[RagChatService] compact PDF context failed: $e');
      }
    }

    final attachedIds = <String>{};
    if (nonPdfAttachments.isNotEmpty) {
      final indexed = await _attachmentPool.mapSettled<String, RagDocument?>(
        nonPdfAttachments,
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

    String? regularContext;
    if (documentIds.isNotEmpty) {
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

      if (results.isNotEmpty) {
        final context = _injector.buildContext(results);
        if (context.isNotEmpty) {
          regularContext = _injector.buildSystemInstruction(context);
        }
      }
    }

    if ((compactPdfContext == null || compactPdfContext.isEmpty) &&
        (regularContext == null || regularContext.isEmpty)) {
      return null;
    }
    if (compactPdfContext == null || compactPdfContext.isEmpty) {
      return regularContext;
    }
    if (regularContext == null || regularContext.isEmpty) {
      return compactPdfContext;
    }

    // Highest-value bounded PDF evidence comes first. Generic library/non-PDF
    // RAG follows only when both are active.
    return '$compactPdfContext\n\n$regularContext';
  }

  Future<RagDocument?> _ensureIndexed(String path) async {
    try {
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
        results.add(
          RagRetrievalResult(
            chunk: chunk,
            document: doc,
            score: 0,
          ),
        );
        if (results.length >= topK) return results;
      }
    }
    return results;
  }
}
