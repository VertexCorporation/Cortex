// load.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../models/backend/data.dart';
import '../chat.dart';

class LoadService {
  final ChatScreenState state;

  List<ModelInfo> allModels = [];
  List<ModelInfo> filteredModels = [];
  bool modelsLoaded = false;

  LoadService(this.state);

  void initializeFromCache() {
    final modelsFromData = ModelData.getCachedModelsSync();
    if (modelsFromData.isNotEmpty) {
      debugPrint("[LoadService] Initializing from ModelData's hot cache.");
      _processAndPopulateModels(modelsFromData);
      modelsLoaded = true;
    } else {
      debugPrint("[LoadService] ModelData cache is empty. A full load will be triggered later.");
    }
  }

  bool isModelOnDisk(String? path) {
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }


  /// Asynchronously loads all available models from the central `ModelData` source.
  /// This function is now more robust by directly using the return value of
  /// `ModelData.getModels` and handling potential null/empty responses.
  Future<void> loadModels() async {
    if (!state.mounted) return;

    try {
      final langCode = Localizations.localeOf(state.context).languageCode;

      // --- THE FIX ---
      // Instead of discarding the result of getModels, we capture it.
      // This is crucial because getModels can return `null` on a failure.
      final List<Map<String, dynamic>>? allModelsData = await ModelData.getModels(langCode: langCode);

      // We now check if the fetched data is null or empty BEFORE proceeding.
      // This correctly handles initial load failures and prevents the UI from
      // showing a permanent error state when it should be loading or retrying.
      if (allModelsData == null || allModelsData.isEmpty) {
        debugPrint('Error in loadModels: ModelData.getModels() returned null or empty. Cannot proceed.');
        // By returning here, we prevent `_processAndPopulateModels` from being called
        // with invalid data, allowing the UI to maintain its `isLoading` state
        // until a successful retry.
        return;
      }

      // If we have valid data, we pass it to the processing method.
      // This avoids the race condition of calling `getCachedModelsSync()` separately.
      await _processAndPopulateModels(allModelsData);

    } catch (e, s) {
      debugPrint('Error caught in loadModels: $e\n$s');
      // The UI will remain in its loading state, which is correct.
    }
  }

  Future<void> _processAndPopulateModels(List<Map<String, dynamic>> allModelsData) async {

    final downloadedPaths = await UserModels.loadDownloadedModelPaths();

    List<ModelInfo> categorizedModels = [];
    final Set<String> addedIds = {};

    for (var modelData in allModelsData) {
      String id = modelData['id'];
      if (addedIds.contains(id)) continue;

      String type = modelData['type'] ?? 'online';
      bool isOffline = type == 'offline';

      if (!isOffline || downloadedPaths.containsKey(id)) {
        final String? finalRole = modelData['role'] as String?; // ModelData already prepares the role.
        final modalities = modelData['modalities'] as Map<String, dynamic>? ?? const {};

        categorizedModels.add(ModelInfo(
          id: id,
          title: modelData['title'] as String? ?? 'Untitled',
          imagePath: ModelData.getModelImagePath(modelData),
          producer: modelData['producer'] ?? 'Unknown',
          path: isOffline ? downloadedPaths[id] : null,
          role: finalRole,
          modalities: modalities,
          category: modelData['category'] as String? ?? type,
          extensions: modelData['extensions'],
        ));
        addedIds.add(id);
      }
    }

    // CUSTOM USER MODELS logic can stay, but it's often better to have this
    // handled within ModelData itself for a single source of truth.
    // For now, we leave it as is.
    Directory docsDir = await getApplicationDocumentsDirectory();
    List<File> ggufFiles = docsDir.listSync()
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

    const categoryOrder = {'self': 0, 'offline': 1, 'online': 2, 'roleplay': 3};
    categorizedModels.sort((a, b) {
      int categoryComparison = (categoryOrder[a.category] ?? 99).compareTo(categoryOrder[b.category] ?? 99);
      if (categoryComparison != 0) return categoryComparison;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    if (!state.mounted) return;

    state.setState(() {
      allModels = categorizedModels;
      filteredModels = List.from(allModels);
      modelsLoaded = true;
    });

  }

  Future<void> updateModelDataFromId() async {
    if (!state.mounted || state.modelId == null) return;
    final modelData = ModelData.getPreciseModelData(state.modelId!);
    if (modelData.isNotEmpty) {
      final bool hasImageModality = ModelData.hasModality(state.modelId!, 'image');

      state.setState(() {
        state.modelTitle = modelData['title']?.toString() ?? 'Unknown Model';
        state.modelDescription = modelData['description']?.toString() ?? '';
        state.modelImagePath = modelData['imagePath']?.toString() ?? 'assets/icons/self.svg';
        state.modelProducer = modelData['producer']?.toString() ?? 'Unknown';
        state.canHandleImage = hasImageModality;
      });

    }
    final String mainId = ModelData.getBaseIdFromFullId(state.modelId!);
    state.extensions.initialize(
      mainId: mainId,
      ext: state.modelId!,
      modelData: modelData,
      updateCanHandleImage: (bool value) {
        if (state.mounted) {
          state.setState(() => state.canHandleImage = value);
        }
      },
    );
  }

  Future<String> getModelFilePath(String title) async {
    Directory appSupportDir = await getApplicationDocumentsDirectory();
    String filesDirectoryPath = appSupportDir.path;
    String sanitizedTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    return path.join(filesDirectoryPath, '$sanitizedTitle.gguf');
  }

  Future<void> loadModel() async {
    if (state.modelPath == null || state.modelPath!.isEmpty) {
      if (state.mounted) {
        state.setState(() => state.isModelLoaded = false);
      }
      return;
    }
    try {
      await ChatScreenState.llamaChannel.invokeMethod('loadModel', {'path': state.modelPath});
      if (state.mounted) {
        state.setState(() => state.isModelLoaded = true);
      }
    } catch (e) {
      debugPrint('Error loading model: e');
      if (state.mounted) {
        state.setState(() => state.isModelLoaded = false);
      }
    }
  }
}