// lib/chat/services/load.dart

import 'dart:io';
import 'package:cortex/chat/providers/session.dart'; // Import the new ChatSessionProvider
import 'package:cortex/chat/services/select.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../models/backend/data/data.dart';
import '../../models/backend/data/info.dart';
import '../../models/backend/data/user.dart';

/// Service responsible for fetching, processing, and providing the list of all available models.
///
/// This service is completely decoupled from the Flutter UI layer. It orchestrates
/// the entire model loading pipeline: fetching from the source, discovering local
/// user models, processing the combined list, and finally updating the central state
/// via the `ChatSessionProvider`.
class LoadService {
  final ChatSessionProvider _sessionProvider;
  final SelectionService _selectionService;

  LoadService({
    required ChatSessionProvider sessionProvider,
    required SelectionService selectionService,
  })  : _sessionProvider = sessionProvider,
        _selectionService = selectionService;

  /// Asynchronously loads all available models for a given language.
  ///
  /// This is the main entry point for this service. The process is as follows:
  /// 1. Notifies the `ChatSessionProvider` that loading has started.
  /// 2. Fetches raw model data using the provided `languageCode`.
  /// 3. Processes the raw data, discovers local models, and consolidates them.
  /// 4. Updates the `ChatSessionProvider` with the final list on success, or sets an
  ///    error state if any part of the process fails.
  Future<void> loadModels({required String languageCode}) async {
    _sessionProvider.setModelsLoading();
    debugPrint('[LoadService] Starting model load for language: $languageCode');

    try {
      final List<Map<String, dynamic>>? allModelsData =
      await ModelData.getModels(langCode: languageCode);

      if (allModelsData == null || allModelsData.isEmpty) {
        debugPrint('[LoadService] Error: ModelData.getModels() returned null or empty.');
        _sessionProvider.setModelsLoadError();
        return;
      }

      final List<ModelInfo> processedModels =
      await _processAndPopulateModels(allModelsData);

      if (processedModels.isEmpty) {
        debugPrint('[LoadService] Error: Model list is empty after processing.');
        _sessionProvider.setModelsLoadError();
        return;
      }

      // On success, update the provider with the final list of models.
      _sessionProvider.setModelsLoadSuccess(processedModels);
      debugPrint('[LoadService] Successfully loaded ${processedModels.length} models.');

      // After a successful load, check if an active chat needs its details refreshed.
      if (_sessionProvider.isChatActive && _sessionProvider.modelId != null) {
        _selectionService.refreshActiveChatModelDetails(_sessionProvider.modelId!);
      }
    } catch (e, s) {
      debugPrint('[LoadService] Critical error caught in loadModels: $e\n$s');
      _sessionProvider.setModelsLoadError();
    }
  }

  /// Processes raw model data, discovers user-downloaded models, and sorts the final list.
  ///
  /// This method consolidates models from three sources:
  /// 1. Backend/Cache Models: The list fetched from `ModelData.getModels()`.
  /// 2. Predefined Offline Models: Checks which "offline" type models have been downloaded.
  /// 3. Custom User Models: Scans the documents directory for any user-added `.gguf` files.
  Future<List<ModelInfo>> _processAndPopulateModels(
      List<Map<String, dynamic>> allModelsData) async {
    // This method's internal logic is correct and does not need to change.
    // It is a pure function that processes data without side effects.
    final downloadedPaths = await UserModels.loadDownloadedModelPaths();
    List<ModelInfo> categorizedModels = [];
    final Set<String> addedIds = {};

    for (var modelData in allModelsData) {
      String id = modelData['id'];
      if (addedIds.contains(id)) continue;

      String type = modelData['type'] ?? 'online';
      bool isOffline = type == 'offline';

      if (!isOffline || downloadedPaths.containsKey(id)) {
        categorizedModels.add(ModelInfo(
          id: id,
          title: modelData['title'] as String? ?? 'Untitled',
          imagePath: ModelData.getModelImagePath(modelData),
          producer: modelData['producer'] ?? 'Unknown',
          path: isOffline ? downloadedPaths[id] : null,
          role: modelData['role'] as String?,
          modalities: modelData['modalities'] as Map<String, dynamic>? ?? const {},
          category: modelData['category'] as String? ?? type,
          extensions: modelData['extensions'],
        ));
        addedIds.add(id);
      }
    }

    try {
      Directory docsDir = await getApplicationDocumentsDirectory();
      List<File> ggufFiles = docsDir
          .listSync()
          .whereType<File>()
          .where((file) => path.extension(file.path).toLowerCase() == '.gguf')
          .toList();

      final predefinedModelPaths = downloadedPaths.values.toSet();
      for (var file in ggufFiles) {
        if (!predefinedModelPaths.contains(file.path)) {
          String title = path.basenameWithoutExtension(file.path);
          String id = 'custom_$title';
          if (addedIds.contains(id)) continue;

          categorizedModels.add(ModelInfo(
            id: id,
            title: title,
            imagePath: 'assets/icons/self.svg',
            producer: 'User',
            path: file.path,
            modalities: const {},
            category: 'self',
          ));
          addedIds.add(id);
        }
      }
    } catch (e) {
      debugPrint("[LoadService] Error reading custom GGUF files: $e");
    }

    const categoryOrder = {'self': 0, 'offline': 1, 'online': 2, 'roleplay': 3};
    categorizedModels.sort((a, b) {
      int categoryComparison =
      (categoryOrder[a.category] ?? 99).compareTo(categoryOrder[b.category] ?? 99);
      if (categoryComparison != 0) return categoryComparison;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return categorizedModels;
  }

  /// Utility function to check if a local model file exists on disk.
  ///
  /// Returns `true` if the given [path] is not null and corresponds to an
  /// existing file, `false` otherwise.
  bool isModelOnDisk(String? path) {
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }
}