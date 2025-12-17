// lib/library/backend/data/service.dart

//
// This file defines the ModelService class, which acts as the central point of
// access to model data for the entire application. Its primary responsibilities are
// to fetch raw data from the ModelRepository, transform it into business objects
// (ModelEntity), apply business logic (e.g., sorting), and provide a clean,
// usable API for the UI and other services.
//
// This class abstracts away the complexity of data fetching and hydration.
//

import 'dart:async';
import 'dart:io';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/image.dart';
import 'package:cortex/library/backend/data/repository.dart';
import 'package:flutter/foundation.dart';

import 'defaults.dart';

/// The [ModelService] class is the main provider of model-related data and
/// business logic for the application.
class ModelService with ChangeNotifier {
  // --- Dependencies ---
  final ModelRepository _repository;

  // --- Constructor
  ModelService({required ModelRepository repository}) : _repository = repository;

  // --- Private State ---

  bool _isLoading = false;
  bool _hasError = false;

  /// Returns true if the service is actively fetching/processing model data.
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  /// In-memory cache for processed, type-safe [ModelEntity] objects.
  /// This is the final, sorted, and ready-to-use list for the UI.
  List<ModelEntity>? _cachedEntities;

  /// In-memory cache for resolved image paths to avoid frequent disk I/O.
  Map<String, String>? _cachedImagePaths;

  // --- Public API ---

  /// The main entry point to get all available models for the application.
  ///
  /// This function orchestrates the entire data loading pipeline:
  /// 1. It checks for a valid in-memory cache (`_cachedEntities`) for immediate returns.
  /// 2. If the cache is empty, it triggers a full data refresh.
  /// 3. As part of the refresh, it invalidates its own in-memory image path cache
  ///    to ensure it fetches fresh data after the repository's sync operations.
  /// 4. It fetches raw model data from the `ModelRepository`.
  /// 5. It performs a critical "enrichment" step, where it resolves the definitive
  ///    image path for EVERY model and creates final, display-ready `ModelEntity` objects.
  /// 6. It applies business logic, such as sorting specific models to the top.
  /// 7. It caches the final, enriched list and notifies listeners to update the UI.
  ///
  /// Returns a list of [ModelEntity] objects, or null on a critical failure.
  Future<List<ModelEntity>?> getModels({required String langCode}) async {
    const String logPrefix = "[ModelService.getModels]";

    _isLoading = true;
    _hasError = false; // Reset error state on new attempt
    notifyListeners(); // Notify UI that loading started

    try {
      if (_cachedEntities != null && _cachedEntities!.isNotEmpty) {
        return _cachedEntities;
      }

      _cachedImagePaths = null;
      debugPrint("$logPrefix: Invalidated in-memory image path cache to prepare for full refresh.");

      debugPrint("$logPrefix: Fetching raw models from repository.");
      final rawModels = await _repository.getAllModels(
        langCode: langCode,
        localAssetMap: ModelDefaults.localAssetImageMap,
      );

      // --- Handle Empty List as Error ---
      if (rawModels == null || rawModels.isEmpty) {
        debugPrint("$logPrefix: Repository returned null or empty list. Marking as Error.");
        _hasError = true;
        return null;
      }

      var finalEntities = rawModels.map((rawMap) {
        final tempEntity = ModelEntity.fromMap(rawMap, langCode);
        final resolvedPath = getModelImagePath(tempEntity);
        return tempEntity.copyWith(imagePath: resolvedPath);
      }).toList();

      final offlineModels = finalEntities.where((m) => m.type == 'offline').toList();
      final otherModels = finalEntities.where((m) => m.type != 'offline').toList();
      otherModels.sort((a, b) => a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase()));
      offlineModels.sort((a, b) {
        final ramA = a.ram ?? 99999;
        final ramB = b.ram ?? 99999;
        final ramComparison = ramA.compareTo(ramB);
        if (ramComparison != 0) return ramComparison;
        final sizeA = a.size ?? 99999;
        final sizeB = b.size ?? 99999;
        return sizeA.compareTo(sizeB);
      });
      finalEntities = [...otherModels, ...offlineModels];
      final neuroIndex = finalEntities.indexWhere((model) => model.id == 'neuro');
      if (neuroIndex != -1) {
        final neuroModel = finalEntities.removeAt(neuroIndex);
        finalEntities.insert(0, neuroModel);
      }

      // Final check: if processing resulted in 0 entities, flag error.
      if (finalEntities.isEmpty) {
        _hasError = true;
        return null;
      }

      _cachedEntities = finalEntities;
      debugPrint("$logPrefix: Caching ${finalEntities.length} ENRICHED model entities.");
      unawaited(_validateAndAssignDefaultBaseModels());

      return _cachedEntities;

    } catch (e, s) {
      debugPrint("$logPrefix: Exception caught: $e\n$s");
      _hasError = true; // Mark error on exception
      return null;
    } finally {
      _isLoading = false;
      notifyListeners(); // Ensure UI rebuilds to show either list or error
    }
  }

  /// Validates that character models have a valid `baseModelId` and assigns a
  /// default if one is missing or invalid. This is now part of the business logic.
  Future<void> _validateAndAssignDefaultBaseModels() async {
    final allModelsInCache = _cachedEntities?.map((e) => e.toMap()).toList();
    if (allModelsInCache == null || allModelsInCache.isEmpty) return;

    final defaultBaseModelId = findDefaultBaseModel(allModelsInCache);
    if (defaultBaseModelId == null) {
      debugPrint("[ModelService] CRITICAL: No suitable default online model found. Aborting base model validation.");
      return;
    }

    final allOnlineVariantIds = <String>{};
    final allModels = getCachedModelsSync();
    allModels.where((m) => m.type == 'online').forEach((model) {
      if (model.extensions != null && model.extensions!.isNotEmpty) {
        allOnlineVariantIds.addAll(model.extensions!.keys);
      } else {
        allOnlineVariantIds.add(model.id);
      }
    });

    for (final model in allModels) {
      if (model.category == 'roleplay' || model.category == 'self') {
        String? currentBaseId = model.baseModelId;
        bool requiresRepair = (currentBaseId == null || currentBaseId.isEmpty || !allOnlineVariantIds.contains(currentBaseId));

        if (requiresRepair) {
          debugPrint("[ModelService] Repairing base model for '${model.id}' to '$defaultBaseModelId'.");
          await updateBaseModel(model.id, defaultBaseModelId);
        }
      }
    }
  }

  /// Finds a suitable default online model from a list of raw model maps.
  /// PRIORITIZES Gemini series models first.
  String? findDefaultBaseModel(List<Map<String, dynamic>> modelsAsMaps) {
    if (modelsAsMaps.isEmpty) {
      debugPrint("[ModelRepository] findDefaultBaseModel called with an empty list.");
      return null;
    }

    // This helper function finds the best text-only, non-pro variant within a series.
    String? findBestSafeVariant(Map<String, dynamic>? extensions) {
      if (extensions == null || extensions.isEmpty) return null;

      final textOnlyVariants = Map.fromEntries(
        extensions.entries.where((entry) {
          final variantData = entry.value;
          if (variantData is Map<String, dynamic>) {
            final outputs = variantData['outputs'] as Map<String, dynamic>?;
            return !(outputs != null && outputs['image'] == true);
          }
          return false;
        }),
      );

      if (textOnlyVariants.isNotEmpty) {
        // Prefer a non-"pro" model if available, otherwise take the first text-only one.
        final nonProEntry = textOnlyVariants.entries.firstWhere(
              (e) => e.value['title'] is String && !(e.value['title'] as String).toLowerCase().contains('pro'),
          orElse: () => textOnlyVariants.entries.first,
        );
        return nonProEntry.key;
      }
      return null;
    }

    String? defaultBaseModelId;

    // --- STEP 1: Prioritize Gemini ---
    // Try to find the Gemini model series first.
    final geminiModel = modelsAsMaps.firstWhere((m) => m['id'] == 'gemini', orElse: () => {});
    if (geminiModel.isNotEmpty) {
      debugPrint("[ModelRepository] Attempt 1: Searching for a safe variant within the Gemini series.");
      defaultBaseModelId = findBestSafeVariant(geminiModel['extensions'] as Map<String, dynamic>?);
    }

    // --- STEP 2: Fallback to other online models if Gemini is not found or has no suitable variant ---
    if (defaultBaseModelId == null) {
      debugPrint("[ModelRepository] Attempt 1 Failed. Attempt 2: Searching other online series.");
      final otherOnlineSeries = modelsAsMaps.where((m) => m['type'] == 'online' && m['id'] != 'gemini');

      for (final model in otherOnlineSeries) {
        defaultBaseModelId = findBestSafeVariant(model['extensions'] as Map<String, dynamic>?);
        if (defaultBaseModelId != null) {
          // Found a suitable model, stop searching.
          break;
        }
      }
    }

    if (defaultBaseModelId != null) {
      debugPrint("[ModelRepository] Selected '$defaultBaseModelId' as the final default base model.");
    } else {
      debugPrint("[ModelRepository] CRITICAL: Could not find any suitable text-only variant in any series.");
    }

    return defaultBaseModelId;
  }

  /// Returns the cached list of [ModelEntity] objects synchronously.
  ///
  /// This should only be called after [getModels] has successfully completed at least once.
  /// It provides immediate access to the data without any async operations.
  List<ModelEntity> getCachedModelsSync() {
    return _cachedEntities ?? [];
  }

  /// Clears all in-memory caches for both raw data (in repository) and processed entities.
  /// This will force a full network/database reload on the next call to [getModels].
  void clearAllCache() {
    _repository.clearRawCache();
    _cachedEntities = null;
    _cachedImagePaths = null;
    debugPrint("[ModelService] All model caches cleared.");
  }

  /// Adds a new model to the in-memory entity cache.
  void addModelToEntityCache(ModelEntity newModel) {
    if (_cachedEntities == null) return;
    _cachedEntities!.removeWhere((m) => m.id == newModel.id);
    _cachedEntities!.add(newModel);
    notifyListeners();
  }

  /// Removes a model from the in-memory entity cache by its ID.
  void removeModelFromEntityCache(String modelId) {
    if (_cachedEntities == null) return;
    final int originalLength = _cachedEntities!.length;
    _cachedEntities!.removeWhere((m) => m.id == modelId);
    if (_cachedEntities!.length < originalLength) {
      notifyListeners();
    }
  }

  /// Hot-patches a single model entity in the cache without triggering a full reload.
  void updateCachedEntity(ModelEntity updatedEntity) {
    if (_cachedEntities == null) return;
    final index = _cachedEntities!.indexWhere((m) => m.id == updatedEntity.id);
    if (index != -1) {
      _cachedEntities![index] = updatedEntity;
    }
  }

  // --- UTILITY METHODS ---

  /// Finds the parent series ID (e.g., 'chatgpt') from a specific variant ID (e.g., 'openai/gpt-4o').
  String getBaseIdFromFullId(String? fullId, {String? langCode}) {
    if (fullId == null || fullId.isEmpty) return '';

    final allModels = getCachedModelsSync();
    if (allModels.isEmpty) {
      return fullId.contains('/') ? fullId.split('/').first : fullId;
    }
    if (allModels.any((model) => model.id == fullId)) return fullId;
    for (final modelSeries in allModels) {
      if (modelSeries.extensions?.containsKey(fullId) ?? false) {
        return modelSeries.id;
      }
    }
    return fullId;
  }

  /// Retrieves a precise [ModelEntity] for a given ID, which can be a base ID or a variant ID.
  /// It intelligently merges series data with variant data if necessary.
  ModelEntity getPreciseModelData(String modelId, {required String langCode}) {
    final allModels = getCachedModelsSync();
    if (allModels.isEmpty) {
      debugPrint("[ModelService] CRITICAL WARNING: getPreciseModelData called when entity cache is empty.");
      return _createFallbackEntity(modelId, langCode: langCode);
    }

    if (modelId == 'cortex/auto') {
      return ModelEntity.fromMap(ModelDefaults.cortexDynamicChatData, langCode);
    }

    // Search 1: Exact match in top-level models.
    try {
      return allModels.firstWhere((model) => model.id == modelId);
    } catch (_) {
      // Not found, proceed to search in extensions.
    }

    // Search 2: Match within a series' extensions.
    for (final modelSeries in allModels) {
      if (modelSeries.extensions?.containsKey(modelId) ?? false) {
        final variantData = modelSeries.extensions![modelId] as Map<String, dynamic>;
        // Merge series data with variant-specific data.
        final mergedMap = {
          ...modelSeries.toMap(),
          ...variantData,
          'id': variantData['id'] ?? modelId,
          'title': variantData['title'],
          'imagePath': modelSeries.imagePath,
        };
        mergedMap.remove('extensions');
        return ModelEntity.fromMap(mergedMap, langCode);
      }
    }

    debugPrint("[ModelService] WARN: Model '$modelId' not found in cache. Creating fallback.");
    return _createFallbackEntity(modelId, langCode: langCode);
  }

  /// Determines the definitive image path for a model synchronously based on a clear, performance-first priority list.
  ///
  /// Priority Order:
  /// 1. A specific, downloaded and cached image for this model ID. This is the highest priority.
  /// 2. If no downloaded image exists, fall back to the local asset map (`ModelDefaults.localAssetImageMap`), checking in this order:
  ///    a. An exact match for the model ID or its base series ID.
  ///    b. The best partial "family" match (e.g., 'phi-4' matching 'phi').
  ///    c. A match for the model's producer name (e.g., 'xai' for a Grok model).
  /// 3. If no cached image exists, it checks for a direct 'assets/...' path provided in the model's server data (a rare case).
  /// 4. As a final fallback, it returns a default icon.
  String getModelImagePath(ModelEntity model) {
    _cachedImagePaths ??= ModelImageCache.getPathsSync();

    if (_cachedImagePaths!.containsKey(model.id)) {
      final localPath = _cachedImagePaths![model.id]!;
      if (File(localPath).existsSync()) {
        return localPath;
      }
    }

    final baseId = getBaseIdFromFullId(model.id);
    final modelIdLower = model.id.toLowerCase();
    final baseIdLower = baseId.toLowerCase();
    final producerLower = model.producer.toLowerCase();

    // 2a. Exact ID or Base ID match
    if (ModelDefaults.localAssetImageMap.containsKey(modelIdLower)) {
      return ModelDefaults.localAssetImageMap[modelIdLower]!;
    }
    if (ModelDefaults.localAssetImageMap.containsKey(baseIdLower)) {
      return ModelDefaults.localAssetImageMap[baseIdLower]!;
    }

    // 2b. Best "series" or "family" match
    final seriesMatch = _findBestAssetMatch(model.id);
    if (seriesMatch != null) {
      return seriesMatch;
    }

    // 2c. Producer name match
    final producerMatch = _findBestAssetMatch(producerLower);
    if (producerMatch != null) {
      return producerMatch;
    }

    if (model.imagePath != null && model.imagePath!.startsWith('assets/')) {
      return model.imagePath!;
    }

    return 'assets/icons/self.svg';
  }

  /// Finds the best possible asset path by checking if a model identifier contains
  /// any of the keys from the asset map. It prioritizes longer matches.
  /// For example, if the map has keys 'phi' and 'phi-4', an identifier of
  /// 'phi-4-mini' will correctly match with 'phi-4'.
  String? _findBestAssetMatch(String modelIdentifier) {
    String? bestMatchKey;
    final identifier = modelIdentifier.toLowerCase();

    // Loop through all keys in our asset map.
    for (final assetKey in ModelDefaults.localAssetImageMap.keys) {
      // If the model's ID contains one of the map keys...
      if (identifier.contains(assetKey)) {
        // ...and if this is the first match we've found, or if this key is longer
        // (more specific) than the previous best match...
        if (bestMatchKey == null || assetKey.length > bestMatchKey.length) {
          // ...then save this as our new best match.
          bestMatchKey = assetKey;
        }
      }
    }

    // If we found a best match, return its corresponding path from the map.
    return bestMatchKey != null ? ModelDefaults.localAssetImageMap[bestMatchKey] : null;
  }

  /// Checks if a model or its underlying base model supports a specific modality.
  bool hasModality(String modelId, {required String langCode, String? modality}) {
    final model = getPreciseModelData(modelId, langCode: langCode);

    bool check(Map<String, dynamic> modalitiesMap) {
      return modality == null ? modalitiesMap.isNotEmpty : modalitiesMap[modality] == true;
    }
    if (check(model.modalities)) return true;

    final isCharacter = model.category == 'roleplay' || model.category == 'self';
    final baseModelId = model.baseModelId;
    if (isCharacter && baseModelId != null && baseModelId.isNotEmpty) {
      final baseModel = getPreciseModelData(baseModelId, langCode: langCode);
      return check(baseModel.modalities);
    }
    return false;
  }

  /// Passes the request to update a model's base ID down to the repository.
  Future<bool> updateBaseModel(String modelId, String newBaseModelId) async {
    final success = await _repository.updateBaseModel(modelId, newBaseModelId);
    if (success) {
      // If the DB was updated, we need to reflect this in our entity cache.
      // A simple way is to find and update the entity.
      final entity = getPreciseModelData(modelId, langCode: 'en'); // langCode might need to be dynamic
      final updatedEntity = entity.copyWith(baseModelId: newBaseModelId);
      updateCachedEntity(updatedEntity);
      notifyListeners();
    }
    return success;
  }

  // --- PRIVATE HELPERS ---

  ModelEntity _createFallbackEntity(String modelId, {required String langCode}) {
    return ModelEntity.fromMap({
      'id': modelId,
      'title': 'Unknown Model',
      'producer': 'Unknown',
      'type': 'online',
      'tier': 'free',
      'modalities': <String, dynamic>{},
      'outputs': <String, dynamic>{},
    }, langCode);
  }
}