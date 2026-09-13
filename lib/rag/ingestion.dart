// lib/rag/ingestion.dart
//
// Orchestrates document ingestion: text extraction -> chunking -> storage.
// Concurrent requests for the same path share one indexing operation.

import 'dart:convert';
import 'dart:io';

import 'package:cortex/performance/adaptive_batcher.dart';
import 'package:cortex/performance/async_coalescer.dart';
import 'package:cortex/performance/perf_trace.dart';
import 'package:cortex/rag/chunker.dart';
import 'package:cortex/rag/extractors.dart';
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/storage.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

class RagIngestionService {
  final RagStorageService _storage;
  final DocTextExtractor _extractor;
  final DocumentChunker _chunker;
  final Uuid _uuid = const Uuid();
  final AsyncKeyedCoalescer<String, RagDocument?> _indexCoalescer =
      AsyncKeyedCoalescer<String, RagDocument?>();

  static const int maxFileSizeBytes = 10 * 1024 * 1024;
  static const AdaptiveBatcher _entityBatcher = AdaptiveBatcher(
    targetSlice: Duration(milliseconds: 3),
    initialBatchSize: 32,
    minBatchSize: 8,
    maxBatchSize: 256,
  );

  static final Dio _fallbackDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(minutes: 2),
    ),
  );

  RagIngestionService({
    required this._storage,
    DocTextExtractor? extractor,
    DocumentChunker? chunker,
  })  : _extractor = extractor ?? DocTextExtractor(),
        _chunker = chunker ?? const DocumentChunker();

  Future<bool> isIndexable(String path) async {
    try {
      final stat = await File(path).stat();
      if (stat.type != FileSystemEntityType.file) return false;
      if (stat.size > maxFileSizeBytes) return false;
      final extension = path.split('.').last.toLowerCase();
      return DocTextExtractor.supportsOnDevice(extension) ||
          DocTextExtractor.serverFallbackExtensions.contains(extension);
    } catch (_) {
      return false;
    }
  }

  Future<RagDocument?> indexFile({
    required String filePath,
    String? title,
  }) {
    return _indexCoalescer.run(
      filePath,
      () => PerfTrace.measureAsync(
        'rag.index_file',
        () => _indexFileInternal(filePath: filePath, title: title),
        metadata: {'extension': filePath.split('.').last.toLowerCase()},
      ),
    );
  }

  Future<RagDocument?> _indexFileInternal({
    required String filePath,
    String? title,
  }) async {
    final file = File(filePath);
    final FileStat stat;
    try {
      stat = await file.stat();
    } catch (_) {
      return null;
    }
    if (stat.type != FileSystemEntityType.file ||
        stat.size > maxFileSizeBytes) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final fileName = filePath.split('/').last;
    final prior = await _storage.getDocumentByPath(filePath);
    final documentId = prior?.id ?? _uuid.v4();
    final displayTitle = title ?? _stripExtension(fileName);

    final doc = RagDocument(
      id: documentId,
      title: displayTitle,
      filePath: filePath,
      sizeBytes: stat.size,
      mimeType: lookupMimeType(filePath) ?? 'application/octet-stream',
      status: RagDocumentStatus.pending,
      chunkCount: 0,
      createdAt: prior?.createdAt ?? now,
      updatedAt: now,
    );

    await _storage.deleteChunksForDocument(documentId);
    await _storage.upsertDocument(doc);

    try {
      final text = await _extractor.extractText(
        filePath,
        serverFallback: _parseViaServer,
      );

      if (text == null || text.trim().isEmpty) {
        await _storage.updateDocumentStatus(
          id: documentId,
          status: RagDocumentStatus.failed,
        );
        return null;
      }

      final chunks = _chunker.chunk(text);
      if (chunks.isEmpty) {
        await _storage.updateDocumentStatus(
          id: documentId,
          status: RagDocumentStatus.failed,
        );
        return null;
      }

      var charStart = 0;
      final chunkEntities = await _entityBatcher.map<String, RagChunk>(
        chunks,
        (chunkText, index) {
          final start = charStart;
          charStart += chunkText.length + 1;
          return RagChunk(
            id: 0,
            documentId: documentId,
            chunkIndex: index,
            text: chunkText,
            charStart: start,
            charEnd: start + chunkText.length,
          );
        },
      );

      await _storage.insertChunks(chunkEntities);
      await _storage.updateDocumentStatus(
        id: documentId,
        status: RagDocumentStatus.indexed,
        chunkCount: chunkEntities.length,
      );

      debugLog('Indexed "$displayTitle" (${chunkEntities.length} chunks).');
      return doc.copyWith(
        status: RagDocumentStatus.indexed,
        chunkCount: chunkEntities.length,
      );
    } catch (e) {
      debugLog('Indexing failed for $filePath: $e');
      await _storage.updateDocumentStatus(
        id: documentId,
        status: RagDocumentStatus.failed,
      );
      return null;
    }
  }

  Future<String?> _parseViaServer(String filePath) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken();
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final mimeType = lookupMimeType(filePath, headerBytes: bytes) ??
          'application/octet-stream';

      const url = 'https://executetool-o5h7dmtija-ew.a.run.app';
      final response = await _fallbackDio.post(
        url,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
        data: {
          'name': 'read_document',
          'args': {'document_index': 0},
          'documents': [
            {
              'data': base64Encode(bytes),
              'media_type': mimeType,
              'fileName': filePath.split('/').last,
              'extension': filePath.split('.').last.toLowerCase(),
            }
          ],
        },
      );

      if (response.statusCode != 200) return null;
      final data = response.data;
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          return _stringifyServerResponse(decoded);
        } catch (_) {
          return data.trim().isNotEmpty ? data : null;
        }
      }
      return _stringifyServerResponse(data);
    } catch (e) {
      debugLog('Server parse fallback failed: $e');
      return null;
    }
  }

  String? _stringifyServerResponse(dynamic data) {
    if (data is String) return data.trim().isNotEmpty ? data : null;
    if (data is Map) {
      for (final key in const ['text', 'content', 'result', 'output', 'data']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
      final text = jsonEncode(data);
      return text.length > 8 ? text : null;
    }
    if (data is List) {
      final parts =
          data.whereType<String>().where((s) => s.trim().isNotEmpty).toList();
      return parts.isEmpty ? null : parts.join('\n');
    }
    return null;
  }

  String _stripExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }

  static void debugLog(String message) {
    debugPrint('[RagIngestion] $message');
  }
}
