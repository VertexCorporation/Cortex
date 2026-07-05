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
import 'dart:math' as math;
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
  ModelService({required ModelRepository repository})
      : _repository = repository;

  // --- Private State ---

  bool _isLoading = false;
  bool _hasError = false;

  /// Returns true if the service is actively fetching/processing model data.
  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  /// In-memory cache for processed, type-safe [ModelEntity] objects.
  /// This is the final, sorted, and ready-to-use list for the UI.
  List<ModelEntity>? _cachedEntities;
  String? _cachedEntitiesLangCode;
  Future<List<ModelEntity>?>? _pendingFetch;

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
  Future<List<ModelEntity>?> getModels({required String langCode}) {
    if (_pendingFetch != null) return _pendingFetch!;
    _pendingFetch = _getModelsInternal(langCode: langCode).whenComplete(() {
      _pendingFetch = null;
    });
    return _pendingFetch!;
  }

  Future<List<ModelEntity>?> _getModelsInternal(
      {required String langCode}) async {
    const String logPrefix = "[ModelService.getModels]";
    final normalizedLangCode = _normalizeLangCode(langCode);

    _isLoading = true;
    _hasError = false; // Reset error state on new attempt
    notifyListeners(); // Notify UI that loading started

    try {
      if (_cachedEntities != null &&
          _cachedEntities!.isNotEmpty &&
          _cachedEntitiesLangCode == normalizedLangCode) {
        return _cachedEntities;
      }

      debugPrint(
          "$logPrefix: Invalidated in-memory image path cache to prepare for full refresh.");

      debugPrint("$logPrefix: Fetching raw models from repository.");
      final rawModels = await _repository.getAllModels(
        langCode: langCode,
        localAssetMap: ModelDefaults.localAssetImageMap,
      );

      // --- Handle Empty List as Error ---
      if (rawModels == null || rawModels.isEmpty) {
        debugPrint(
            "$logPrefix: Repository returned null or empty list. Marking as Error.");
        _hasError = true;
        return null;
      }

      final finalEntities =
          await _buildEntitiesFromRawAsync(rawModels, normalizedLangCode);

      // Final check: if processing resulted in 0 entities, flag error.
      if (finalEntities.isEmpty) {
        _hasError = true;
        return null;
      }

      _cachedEntities = finalEntities;
      _cachedEntitiesLangCode = normalizedLangCode;
      debugPrint(
          "$logPrefix: Caching ${finalEntities.length} ENRICHED model entities.");
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
      debugPrint(
          "[ModelService] CRITICAL: No suitable default online model found. Aborting base model validation.");
      return;
    }

    final allOnlineVariantIds = <String>{};
    final allModels = List<ModelEntity>.from(getCachedModelsSync());
    for (final model in allModels.where((m) => m.type == 'online')) {
      if (model.variants != null && model.variants!.isNotEmpty) {
        allOnlineVariantIds.addAll(model.variants!.keys);
      } else {
        allOnlineVariantIds.add(model.id);
      }
    }
    allOnlineVariantIds.add('cortex/auto');

    for (final model in allModels) {
      if (model.category == 'roleplay' || model.category == 'self') {
        String? currentBaseId = model.baseModelId;
        bool requiresRepair = (currentBaseId == null ||
            currentBaseId.isEmpty ||
            !allOnlineVariantIds.contains(currentBaseId));

        if (requiresRepair) {
          debugPrint(
              "[ModelService] Repairing base model for '${model.id}' to '$defaultBaseModelId'.");
          await updateBaseModel(model.id, defaultBaseModelId);
        }
      }
    }
  }

  /// Finds a suitable default online model from a list of raw model maps.
  /// PRIORITIZES 'cortex/auto' (Always Best) as the default.
  String? findDefaultBaseModel(List<Map<String, dynamic>> modelsAsMaps) {
    if (modelsAsMaps.isEmpty) {
      debugPrint(
          "[ModelRepository] findDefaultBaseModel called with an empty list.");
      return null;
    }

    // Always prefer 'cortex/auto' as the default.
    return 'cortex/auto';
  }

  /// Returns the cached list of [ModelEntity] objects synchronously.
  ///
  /// This should only be called after [getModels] has successfully completed at least once.
  /// It provides immediate access to the data without any async operations.
  List<ModelEntity> getCachedModelsSync() {
    return _cachedEntities ?? [];
  }

  String _normalizeLangCode(String langCode) =>
      langCode.split(RegExp(r'[-_]')).first.toLowerCase();

  Future<List<ModelEntity>> _buildEntitiesFromRawAsync(
    List<Map<String, dynamic>> rawModels,
    String langCode,
  ) async {
    var finalEntities = <ModelEntity>[];
    for (int i = 0; i < rawModels.length; i++) {
      final rawMap = rawModels[i];
      final tempEntity = ModelEntity.fromMap(rawMap, langCode);
      final resolvedPath = getModelImagePath(tempEntity);
      finalEntities.add(tempEntity.copyWith(imagePath: resolvedPath));

      // Inject cortexRoleplayData
      if (i == 0) {
        final roleplayEntity =
            ModelEntity.fromMap(ModelDefaults.cortexRoleplayData, langCode);
        final roleplayPath = getModelImagePath(roleplayEntity);
        finalEntities.add(roleplayEntity.copyWith(imagePath: roleplayPath));
      }

      // Yield to the event loop frequently to completely eliminate UI stutter
      // during heavy synchronous filesystem checks.
      if (i % 5 == 0) {
        await Future.delayed(Duration.zero);
      }
    }

    const int minOfflineSizeMb = 300;
    const int maxOfflineRamMb = 32000;
    const int maxOfflineSizeMb = 1024 * 1024; // 1 TB in MB

    finalEntities = finalEntities
        .map((model) => normalizeOfflineModelForCatalog(
              model,
              minOfflineSizeMb: minOfflineSizeMb,
              maxOfflineRamMb: maxOfflineRamMb,
              maxOfflineSizeMb: maxOfflineSizeMb,
            ))
        .whereType<ModelEntity>()
        .toList();

    final offlineModels =
        finalEntities.where((m) => m.type == 'offline').toList();
    final otherModels =
        finalEntities.where((m) => m.type != 'offline').toList();
    otherModels.sort((a, b) =>
        a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase()));
    offlineModels.sort((a, b) {
      final sizeA = a.size ?? 99999;
      final sizeB = b.size ?? 99999;
      final sizeComparison = sizeA.compareTo(sizeB);
      if (sizeComparison != 0) return sizeComparison;
      final ramA = a.ram ?? 99999;
      final ramB = b.ram ?? 99999;
      final ramComparison = ramA.compareTo(ramB);
      if (ramComparison != 0) return ramComparison;
      return a.displayTitle
          .toLowerCase()
          .compareTo(b.displayTitle.toLowerCase());
    });
    finalEntities = [...otherModels, ...offlineModels];
    final neuroIndex = finalEntities.indexWhere((model) => model.id == 'neuro');
    if (neuroIndex != -1) {
      final neuroModel = finalEntities.removeAt(neuroIndex);
      finalEntities.insert(0, neuroModel);
    }

    return finalEntities;
  }

  List<ModelEntity> _buildEntitiesFromRaw(
    List<Map<String, dynamic>> rawModels,
    String langCode,
  ) {
    var finalEntities = rawModels.map((rawMap) {
      final tempEntity = ModelEntity.fromMap(rawMap, langCode);
      final resolvedPath = getModelImagePath(tempEntity);
      return tempEntity.copyWith(imagePath: resolvedPath);
    }).toList();

    const int minOfflineSizeMb = 300;
    const int maxOfflineRamMb = 32000;
    const int maxOfflineSizeMb = 1024 * 1024; // 1 TB in MB

    finalEntities = finalEntities
        .map((model) => normalizeOfflineModelForCatalog(
              model,
              minOfflineSizeMb: minOfflineSizeMb,
              maxOfflineRamMb: maxOfflineRamMb,
              maxOfflineSizeMb: maxOfflineSizeMb,
            ))
        .whereType<ModelEntity>()
        .toList();

    final offlineModels =
        finalEntities.where((m) => m.type == 'offline').toList();
    final otherModels =
        finalEntities.where((m) => m.type != 'offline').toList();
    otherModels.sort((a, b) =>
        a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase()));
    offlineModels.sort((a, b) {
      final sizeA = a.size ?? 99999;
      final sizeB = b.size ?? 99999;
      final sizeComparison = sizeA.compareTo(sizeB);
      if (sizeComparison != 0) return sizeComparison;
      final ramA = a.ram ?? 99999;
      final ramB = b.ram ?? 99999;
      final ramComparison = ramA.compareTo(ramB);
      if (ramComparison != 0) return ramComparison;
      return a.displayTitle
          .toLowerCase()
          .compareTo(b.displayTitle.toLowerCase());
    });
    finalEntities = [...otherModels, ...offlineModels];
    final neuroIndex = finalEntities.indexWhere((model) => model.id == 'neuro');
    if (neuroIndex != -1) {
      final neuroModel = finalEntities.removeAt(neuroIndex);
      finalEntities.insert(0, neuroModel);
    }

    return finalEntities;
  }

  void _ensureCachedLanguage(String langCode) {
    final normalizedLangCode = _normalizeLangCode(langCode);
    if (_cachedEntitiesLangCode == normalizedLangCode) return;

    final rawModels = _repository.rawModelsCache;
    if (rawModels == null || rawModels.isEmpty) return;

    _cachedEntities = _buildEntitiesFromRaw(rawModels, normalizedLangCode);
    _cachedEntitiesLangCode = normalizedLangCode;
  }

  @visibleForTesting
  static ModelEntity? normalizeOfflineModelForCatalog(
    ModelEntity model, {
    required int minOfflineSizeMb,
    required int maxOfflineRamMb,
    required int maxOfflineSizeMb,
  }) {
    if (model.type != 'offline') return model;

    final imagePath = (model.imagePath ?? '').toLowerCase();
    final hasSelfPlaceholder = imagePath.endsWith('/self.svg') ||
        imagePath.endsWith('assets/icons/self.svg');
    if (hasSelfPlaceholder) return null;

    final ram = model.ram;
    if (ram != null && ram > maxOfflineRamMb) return null;

    Map<String, dynamic>? filteredVariants;
    int? effectiveSize = model.size;

    final variants = model.variants;
    if (variants != null && variants.isNotEmpty) {
      filteredVariants = <String, dynamic>{};
      final keptVariantSizes = <int>[];

      for (final entry in variants.entries) {
        final variantData = entry.value;
        if (variantData is! Map) continue;

        final variantMap = Map<String, dynamic>.from(variantData);
        final variantSize = _tryParseInt(variantMap['size']);
        final variantRam = _tryParseInt(variantMap['ram']);

        if (variantRam != null && variantRam > maxOfflineRamMb) {
          continue;
        }
        if (variantSize != null && variantSize > maxOfflineSizeMb) {
          continue;
        }
        if (variantSize != null && variantSize < minOfflineSizeMb) {
          continue;
        }

        filteredVariants[entry.key] = variantMap;
        if (variantSize != null) {
          keptVariantSizes.add(variantSize);
        }
      }

      if (filteredVariants.isEmpty) return null;

      if (keptVariantSizes.isNotEmpty) {
        effectiveSize = keptVariantSizes.reduce(math.min);
      }
    } else {
      if (effectiveSize != null && effectiveSize < minOfflineSizeMb) {
        return null;
      }
    }

    if (effectiveSize != null && effectiveSize > maxOfflineSizeMb) return null;
    if (effectiveSize != null && effectiveSize < minOfflineSizeMb) return null;

    return model.copyWith(
      size: effectiveSize,
      variants: filteredVariants ?? model.variants,
    );
  }

  static int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// Returns true if the given ID exists in cache as a series ID or variant ID.
  bool hasModelInCache(String modelId) {
    if (modelId == 'cortex/auto' || modelId == 'dynamic') {
      return true;
    }

    final allModels = getCachedModelsSync();
    if (allModels.isEmpty) return false;

    if (allModels.any((model) => model.id == modelId)) {
      return true;
    }

    for (final modelSeries in allModels) {
      if (modelSeries.variants?.containsKey(modelId) ?? false) {
        return true;
      }
    }

    return false;
  }

  /// Clears all in-memory caches for both raw data (in repository) and processed entities.
  /// This will force a full network/database reload on the next call to [getModels].
  void clearAllCache() {
    _repository.clearRawCache();
    _cachedEntities = null;
    _cachedEntitiesLangCode = null;

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
      if (modelSeries.variants?.containsKey(fullId) ?? false) {
        return modelSeries.id;
      }
    }
    return fullId;
  }

  /// Retrieves a precise [ModelEntity] for a given ID, which can be a base ID or a variant ID.
  /// It intelligently merges series data with variant data if necessary.
  /// Retrieves a precise [ModelEntity] for a given ID, which can be a base ID or a variant ID.
  ModelEntity getPreciseModelData(String modelId, {required String langCode}) {
    _ensureCachedLanguage(langCode);

    if (modelId.isEmpty) {
      return _createFallbackEntity(modelId, langCode: langCode);
    }

    if (modelId == 'cortex/auto' || modelId == 'dynamic') {
      var entity =
          ModelEntity.fromMap(ModelDefaults.cortexDynamicChatData, langCode);
      return entity.copyWith(imagePath: getModelImagePath(entity));
    }
    if (modelId == 'cortex/roleplay') {
      var entity =
          ModelEntity.fromMap(ModelDefaults.cortexRoleplayData, langCode);
      return entity.copyWith(imagePath: getModelImagePath(entity));
    }

    final allModels = getCachedModelsSync();
    if (allModels.isEmpty) {
      debugPrint(
          "[ModelService] CRITICAL WARNING: getPreciseModelData called when entity cache is empty.");
      if (modelId == 'cortex/auto' || modelId == 'dynamic') {
        var entity =
            ModelEntity.fromMap(ModelDefaults.cortexDynamicChatData, langCode);
        return entity.copyWith(imagePath: getModelImagePath(entity));
      }
      if (modelId == 'cortex/roleplay') {
        var entity =
            ModelEntity.fromMap(ModelDefaults.cortexRoleplayData, langCode);
        return entity.copyWith(imagePath: getModelImagePath(entity));
      }
      return _createFallbackEntity(modelId, langCode: langCode);
    }

    // Search 1: Exact match
    try {
      return allModels.firstWhere((model) => model.id == modelId);
    } catch (_) {
      // Not found, proceed.
    }

    // Search 2: Match within variants
    for (final modelSeries in allModels) {
      if (modelSeries.variants?.containsKey(modelId) ?? false) {
        final variantData =
            modelSeries.variants![modelId] as Map<String, dynamic>;
        final mergedMap = {
          ...modelSeries.toMap(),
          ...variantData,
          'id': variantData['id'] ?? modelId,
          'title': variantData['title'],
          'imagePath': modelSeries.imagePath,
        };
        mergedMap.remove('variants');
        return ModelEntity.fromMap(mergedMap, langCode);
      }
    }

    debugPrint(
        "[ModelService] WARN: Model '$modelId' not found in cache. Creating fallback.");
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
  /// Determines the definitive image path for a model.
  String getModelImagePath(ModelEntity model) {
    final cachedImagePaths = ModelImageCache.getPathsSync();

    if (cachedImagePaths.containsKey(model.id)) {
      final localPath = cachedImagePaths[model.id]!;
      if (File(localPath).existsSync()) {
        return localPath;
      }
    }

    if (model.id == 'cortex/auto' || model.id == 'dynamic') {
      return 'assets/cortex.svg';
    }

    final baseId = getBaseIdFromFullId(model.id);
    final modelIdLower = model.id.toLowerCase();
    final baseIdLower = baseId.toLowerCase();
    final producerLower = model.producer.toLowerCase();

    if (ModelDefaults.localAssetImageMap.containsKey(modelIdLower)) {
      return ModelDefaults.localAssetImageMap[modelIdLower]!;
    }
    if (ModelDefaults.localAssetImageMap.containsKey(baseIdLower)) {
      return ModelDefaults.localAssetImageMap[baseIdLower]!;
    }

    final seriesMatch = _findBestAssetMatch(model.id);
    if (seriesMatch != null) return seriesMatch;

    final producerMatch = _findBestAssetMatch(producerLower);
    if (producerMatch != null) return producerMatch;

    if (model.imagePath != null &&
        (model.imagePath!.startsWith('assets/') ||
            model.imagePath!.startsWith('http'))) {
      return model.imagePath!;
    }

    if (model.imagePath != null && File(model.imagePath!).existsSync()) {
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
    return bestMatchKey != null
        ? ModelDefaults.localAssetImageMap[bestMatchKey]
        : null;
  }

  /// Checks if a model or its underlying base model supports a specific modality.
  bool hasModality(String modelId,
      {required String langCode, String? modality}) {
    final model = getPreciseModelData(modelId, langCode: langCode);

    bool check(Map<String, dynamic> modalitiesMap) {
      return modality == null
          ? modalitiesMap.isNotEmpty
          : modalitiesMap[modality] == true;
    }

    if (check(model.modalities)) return true;

    final isCharacter =
        model.category == 'roleplay' || model.category == 'self';
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
      final entity = getPreciseModelData(modelId,
          langCode: 'en'); // langCode might need to be dynamic
      final updatedEntity = entity.copyWith(baseModelId: newBaseModelId);
      updateCachedEntity(updatedEntity);
      notifyListeners();
    }
    return success;
  }

  // --- PRIVATE HELPERS ---

  ModelEntity _createFallbackEntity(String modelId,
      {required String langCode}) {
    return ModelEntity.fromMap({
      'id': modelId,
      'title': 'Unknown Model',
      'producer': 'Unknown',
      'type': 'online',
      'tier': 'free',
      'modalities': <String, dynamic>{},
      'outputs': <String, dynamic>{},
      'chatFormat': ModelDefaults.getFallbackFormat(modelId),
    }, langCode);
  }
}
