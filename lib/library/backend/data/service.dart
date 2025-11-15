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

/// The [ModelService] class is the main provider of model-related data and
/// business logic for the application.
class ModelService with ChangeNotifier {
  // --- Dependencies ---
  final ModelRepository _repository;

  // --- Constructor
  ModelService({required ModelRepository repository}) : _repository = repository;

  // --- Private State ---

  bool _isLoading = false;

  /// Returns true if the service is actively fetching/processing model data.
  bool get isLoading => _isLoading;

  /// In-memory cache for processed, type-safe [ModelEntity] objects.
  /// This is the final, sorted, and ready-to-use list for the UI.
  List<ModelEntity>? _cachedEntities;

  /// In-memory cache for resolved image paths to avoid frequent disk I/O.
  Map<String, String>? _cachedImagePaths;

  /// A map of predefined local asset paths for common models, structured by matching priority.
  /// The matching logic will check these in order:
  /// 1. Exact ID matches for specific models.
  /// 2. Partial "family" matches (e.g., 'phi' for 'phi-4').
  /// 3. General producer fallbacks (e.g., 'google' for any Google model).
  /// All keys must be lowercase for consistent matching.
  final Map<String, String> _localAssetImageMap = {
    // --- PRIORITY 1: EXACT MODEL IDS ---
    // Use this for specific models that need a unique image, overriding any family/producer rule.
    'neuro': 'assets/characters/neuro.jpg',
    'jannano128k': 'assets/models/jannano128k.jpg',
    'gptneox': 'assets/models/gptneox.jpg',
    'supernova-medius': 'assets/producers/arceeai.jpg',

    // All roleplay characters are treated as exact IDs.
    'teacher': 'assets/characters/teacher.jpg',
    'doctor': 'assets/characters/doctor.jpg',
    'animegirl': 'assets/characters/animegirl.jpg',
    'astronaut': 'assets/characters/astronaut.jpg',
    'psychologist': 'assets/characters/psychologist.jpg',
    'gamer': 'assets/characters/gamer.jpg',
    'hacker': 'assets/characters/hacker.jpg',
    'athlete': 'assets/characters/athlete.jpg',
    'trash': 'assets/characters/trash.jpg',
    'tree': 'assets/characters/tree.jpg',
    'chef': 'assets/characters/chef.jpg',
    'lawyer': 'assets/characters/lawyer.jpg',
    'engineer': 'assets/characters/engineer.jpg',
    'crazy': 'assets/characters/crazy.jpg',
    'baby': 'assets/characters/baby.jpg',
    'police': 'assets/characters/police.jpg',
    'scientist': 'assets/characters/scientist.jpg',
    'dj': 'assets/characters/dj.jpg',
    'lover': 'assets/characters/lover.jpg',
    'shaver': 'assets/characters/shaver.jpg',
    'detective': 'assets/characters/detective.jpg',
    'grandmother': 'assets/characters/grandmother.jpg',
    'miner': 'assets/characters/miner.jpg',

    // --- PRIORITY 2: MODEL FAMILIES / SERIES ---
    // These keys will match if a model's ID *contains* them. Longer keys are prioritized.
    // (e.g., 'gpt-3.5-turbo' will match 'gpt-')
    'gpt': 'assets/producers/openai.jpg', // Catches gpt-3.5, gpt-4, etc.
    'chatgpt': 'assets/producers/openai.jpg',
    'claude': 'assets/models/claude.jpg',
    'codex': 'assets/models/codex.jpg',
    'deepseek': 'assets/models/deepseek.jpg',
    'qwen': 'assets/models/qwen.png',
    'gemini': 'assets/models/gemini.png',
    'gemma': 'assets/models/gemma.jpg',
    'grok': 'assets/models/grok.jpg',
    'hermes': 'assets/models/hermes.jpg',
    'codestral': 'assets/models/codestral.jpg',
    'mai': 'assets/models/mai.jpg',
    'ministral': 'assets/models/ministral.jpg',
    'mixtral': 'assets/models/mixtral.jpg',
    'phi': 'assets/models/phi.png', // Catches phi-3, phi-4, etc.
    'wizardlm': 'assets/models/wizardlm.jpg',
    'tinyllama': 'assets/models/tinyllama.png',
    'llama': 'assets/models/llama.png',
    'command': 'assets/models/cohere.jpg',
    'nova': 'assets/models/nova.jpg', // Assuming you have an Amazon logo
    'perplexity': 'assets/models/perplexity.jpg',
    'lfm': 'assets/producers/liquidai.jpg',

    // --- PRIORITY 3: PRODUCERS (FALLBACK) ---
    // This is the last resort if no better match is found. Keys are simplified for broader matching.
    'openai': 'assets/producers/openai.jpg',
    'anthropic': 'assets/producers/anthropic.jpg',
    'amazon': 'assets/producers/amazon.jpg',
    'google': 'assets/producers/google.jpg',
    'xai': 'assets/producers/xai.jpg',
    'arcee': 'assets/producers/arceeai.jpg',
    'nousresearch': 'assets/producers/nousresearch.jpg',
    'mistral': 'assets/models/mistral.jpg',
    'microsoft': 'assets/producers/microsoft.jpg',
    'meta': 'assets/models/llama.png',
    'cohere': 'assets/models/cohere.jpg',
    'unsloth': 'assets/producers/unslothhai.jpg',
    'menlo': 'assets/producers/menloresearch.png',
    'thebloke': 'assets/producers/thebloke.jpg',
    'snowflake': 'assets/producers/snowflake.jpg',
    'secondstate': 'assets/producers/secondstate.jpg',
    'modular': 'assets/producers/modularai.jpg',
    'intel': 'assets/producers/intel.jpg',
    'ggml': 'assets/producers/ggmlorg.jpg',
    'fortytwonetwork': 'assets/producers/fortytwonetwork.jpg',
    'devquasar': 'assets/producers/devquasar.jpg',
    'defog': 'assets/producers/defogai.jpg',
    'lamapi': 'assets/producers/lamapi.jpg',
    'liquid': 'assets/producers/liquidai.jpg',
    'mazyarpanahi': 'assets/producers/mazyarpanahi.jpg',
    'neuphonic': 'assets/producers/neuphonic.jpg',
    'jetbrains': 'assets/producers/jetbrains.png',
    'zed': 'assets/producers/zed.jpg',
    'lm': 'assets/producers/lmstudiocommunity.jpg',
    'moonshot': 'assets/producers/moonshotai.jpg',
    'z.ai': 'assets/producers/z.ai.jpg',
    'ibm': 'assets/producres/ibm.jpg',
    'inclusion': 'assets/producers/inclusionai.jpg',
    'nvidia': 'assets/producers/nvidia.jpg'
  };

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

    try {
      if (_cachedEntities != null) {
        return _cachedEntities;
      }

      _cachedImagePaths = null;
      debugPrint("$logPrefix: Invalidated in-memory image path cache to prepare for full refresh.");

      debugPrint("$logPrefix: Fetching raw models from repository.");
      final rawModels = await _repository.getAllModels(
        langCode: langCode,
        localAssetMap: _localAssetImageMap,
      );

      if (rawModels == null) {
        debugPrint("$logPrefix: Repository returned null. Data fetching failed.");
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

      _cachedEntities = finalEntities;
      debugPrint("$logPrefix: Caching ${finalEntities.length} ENRICHED model entities.");
      unawaited(_validateAndAssignDefaultBaseModels());

      return _cachedEntities;

    } finally {
      _isLoading = false;
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
  /// 2. If no downloaded image exists, fall back to the local asset map (`_localAssetImageMap`), checking in this order:
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
    if (_localAssetImageMap.containsKey(modelIdLower)) {
      return _localAssetImageMap[modelIdLower]!;
    }
    if (_localAssetImageMap.containsKey(baseIdLower)) {
      return _localAssetImageMap[baseIdLower]!;
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
    for (final assetKey in _localAssetImageMap.keys) {
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
    return bestMatchKey != null ? _localAssetImageMap[bestMatchKey] : null;
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