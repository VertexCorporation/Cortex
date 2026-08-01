// lib/rag/providers/rag_provider.dart
//
// UI-facing state for the RAG document library: document list, selection for
// toggle mode, and indexing progress.

import 'dart:async';
import 'package:cortex/rag/ingestion.dart';
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/storage.dart';
import 'package:flutter/foundation.dart';

class RagProvider extends ChangeNotifier {
  final RagStorageService _storage;
  final RagIngestionService _ingestion;

  List<RagDocument> _documents = [];
  final Set<String> _selectedDocumentIds = {};
  bool _isLoading = false;
  final Set<String> _indexingPaths = {};

  RagProvider({
    required RagStorageService storage,
    required RagIngestionService ingestion,
  })  : _storage = storage,
        _ingestion = ingestion;

  // ---- Getters ----------------------------------------------------------

  List<RagDocument> get documents => List.unmodifiable(_documents);

  Set<String> get selectedDocumentIds => Set.unmodifiable(_selectedDocumentIds);

  bool get isLoading => _isLoading;

  int get indexedCount => _documents
      .where((d) => d.status == RagDocumentStatus.indexed)
      .length;

  bool isIndexing(String path) => _indexingPaths.contains(path);

  // ---- Lifecycle ----------------------------------------------------------

  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();
    try {
      _documents = await _storage.getAllDocuments();
    } catch (e) {
      debugPrint('[RagProvider] loadDocuments failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RagDocument?> indexFile({
    required String filePath,
    String? title,
  }) async {
    _indexingPaths.add(filePath);
    notifyListeners();
    try {
      final doc = await _ingestion.indexFile(
        filePath: filePath,
        title: title,
      );
      await loadDocuments();
      return doc;
    } finally {
      _indexingPaths.remove(filePath);
      notifyListeners();
    }
  }

  Future<bool> removeDocument(String id) async {
    await _storage.deleteDocument(id);
    _selectedDocumentIds.remove(id);
    await loadDocuments();
    return true;
  }

  // ---- Selection (toggle mode) -------------------------------------------

  void toggleSelection(String id) {
    if (_selectedDocumentIds.contains(id)) {
      _selectedDocumentIds.remove(id);
    } else {
      _selectedDocumentIds.add(id);
    }
    notifyListeners();
  }

  void setSelection(Set<String> ids) {
    _selectedDocumentIds
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedDocumentIds.isEmpty) return;
    _selectedDocumentIds.clear();
    notifyListeners();
  }

  /// Keeps only documents that exist and are indexed.
  void pruneSelection() {
    final validIds = _documents
        .where((d) => d.status == RagDocumentStatus.indexed)
        .map((d) => d.id)
        .toSet();
    final before = _selectedDocumentIds.length;
    _selectedDocumentIds.removeWhere((id) => !validIds.contains(id));
    if (before != _selectedDocumentIds.length) {
      notifyListeners();
    }
  }
}
