// lib/rag/providers/rag_provider.dart

import 'dart:async';

import 'package:cortex/performance/async_coalescer.dart';
import 'package:cortex/performance/stable_fingerprint.dart';
import 'package:cortex/rag/ingestion.dart';
import 'package:cortex/rag/models.dart';
import 'package:cortex/rag/storage.dart';
import 'package:flutter/foundation.dart';

class RagProvider extends ChangeNotifier {
  final RagStorageService _storage;
  final RagIngestionService _ingestion;
  final AsyncCoalescer<List<RagDocument>> _loadCoalescer =
      AsyncCoalescer<List<RagDocument>>();
  final FingerprintGuard _documentsFingerprint = FingerprintGuard();

  List<RagDocument> _documents = [];
  final Set<String> _selectedDocumentIds = {};
  bool _isLoading = false;
  final Set<String> _indexingPaths = {};
  bool _disposed = false;

  RagProvider({
    required RagStorageService storage,
    required RagIngestionService ingestion,
  })  : _storage = storage,
        _ingestion = ingestion;

  List<RagDocument> get documents => List.unmodifiable(_documents);
  Set<String> get selectedDocumentIds => Set.unmodifiable(_selectedDocumentIds);
  bool get isLoading => _isLoading;

  int get indexedCount =>
      _documents.where((d) => d.status == RagDocumentStatus.indexed).length;

  bool isIndexing(String path) => _indexingPaths.contains(path);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    _notify();
  }

  bool _acceptDocuments(List<RagDocument> documents) {
    final fingerprint = documents.map((d) => d.toMap()).toList(growable: false);
    if (!_documentsFingerprint.changed(fingerprint)) return false;
    _documents = List<RagDocument>.unmodifiable(documents);
    return true;
  }

  Future<void> loadDocuments() async {
    final ownedLoadingTransition = !_loadCoalescer.isBusy;
    if (ownedLoadingTransition) _setLoading(true);

    try {
      final documents = await _loadCoalescer.run(_storage.getAllDocuments);
      if (_disposed) return;
      if (_acceptDocuments(documents)) _notify();
    } catch (e) {
      debugPrint('[RagProvider] loadDocuments failed: $e');
    } finally {
      if (ownedLoadingTransition) _setLoading(false);
    }
  }

  Future<RagDocument?> indexFile({
    required String filePath,
    String? title,
  }) async {
    final added = _indexingPaths.add(filePath);
    if (added) _notify();
    try {
      final doc = await _ingestion.indexFile(
        filePath: filePath,
        title: title,
      );
      await loadDocuments();
      return doc;
    } finally {
      if (_indexingPaths.remove(filePath)) _notify();
    }
  }

  Future<bool> removeDocument(String id) async {
    await _storage.deleteDocument(id);
    final selectionChanged = _selectedDocumentIds.remove(id);
    await loadDocuments();
    if (selectionChanged) _notify();
    return true;
  }

  void toggleSelection(String id) {
    if (_selectedDocumentIds.contains(id)) {
      _selectedDocumentIds.remove(id);
    } else {
      _selectedDocumentIds.add(id);
    }
    _notify();
  }

  void setSelection(Set<String> ids) {
    if (setEquals(_selectedDocumentIds, ids)) return;
    _selectedDocumentIds
      ..clear()
      ..addAll(ids);
    _notify();
  }

  void clearSelection() {
    if (_selectedDocumentIds.isEmpty) return;
    _selectedDocumentIds.clear();
    _notify();
  }

  void pruneSelection() {
    final validIds = _documents
        .where((d) => d.status == RagDocumentStatus.indexed)
        .map((d) => d.id)
        .toSet();
    final before = _selectedDocumentIds.length;
    _selectedDocumentIds.removeWhere((id) => !validIds.contains(id));
    if (before != _selectedDocumentIds.length) _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _loadCoalescer.forget();
    super.dispose();
  }
}
