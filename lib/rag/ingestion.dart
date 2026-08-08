// lib/rag/ingestion.dart
//
// Orchestrates document ingestion: text extraction → chunking → storage.
// Provides a server-side fallback parser (read_document backend) for legacy
// binary formats that cannot be parsed on-device.

import 'dart:convert';
import 'dart:io';
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

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  RagIngestionService({
    required RagStorageService storage,
    DocTextExtractor? extractor,
    DocumentChunker? chunker,
  })  : _storage = storage,
        _extractor = extractor ?? DocTextExtractor(),
        _chunker = chunker ?? const DocumentChunker();

  /// Returns true if [path] can be indexed (exists, size ok, supported ext).
  Future<bool> isIndexable(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      final size = await file.length();
      if (size > maxFileSizeBytes) return false;
      final extension = path.split('.').last.toLowerCase();
      return DocTextExtractor.supportsOnDevice(extension) ||
          DocTextExtractor.serverFallbackExtensions.contains(extension);
    } catch (_) {
      return false;
    }
  }

  /// Indexes [path] and returns the created/updated document, or `null` on
  /// failure. Re-indexes the file if [path] already has a document record.
  Future<RagDocument?> indexFile({
    required String filePath,
    String? title,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final fileName = filePath.split('/').last;
    final sizeBytes = await file.length();

    // Reuse the existing record when re-indexing the same path.
    final existing = await _storage.getAllDocuments();
    final prior = existing.where((d) => d.filePath == filePath).firstOrNull;

    final documentId = prior?.id ?? _uuid.v4();
    final displayTitle = title ?? _stripExtension(fileName);

    final doc = RagDocument(
      id: documentId,
      title: displayTitle,
      filePath: filePath,
      sizeBytes: sizeBytes,
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

      final chunkEntities = <RagChunk>[];
      var charStart = 0;
      for (var i = 0; i < chunks.length; i++) {
        final chunkText = chunks[i];
        chunkEntities.add(RagChunk(
          id: 0, // autoincrement
          documentId: documentId,
          chunkIndex: i,
          text: chunkText,
          charStart: charStart,
          charEnd: charStart + chunkText.length,
        ));
        charStart += chunkText.length + 1;
      }

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
        updatedAt: now,
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

  /// Server-side fallback that reuses the existing `read_document` backend
  /// to parse legacy binary formats (.doc, .xls, .odt, ...).
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
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(minutes: 2),
      ));

      final response = await dio.post(
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
        // The server sometimes wraps plain text in JSON; try to unwrap.
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
      final parts = data
          .whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .toList();
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
