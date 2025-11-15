// lib/chat/services/recent.dart

import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter/foundation.dart';
import '../../cache.dart';
import '../../library/backend/data/entity.dart';

/// Manages the state and logic for recently used models.
/// This class now exclusively uses and provides [ModelEntity] objects.
class RecentModelsManager {
  /// A notifier that holds the list of recent models as [ModelEntity].
  final ValueNotifier<List<ModelEntity>> recentModelsNotifier =
  ValueNotifier<List<ModelEntity>>([]);
  final ModelService _modelService;

  RecentModelsManager({required ModelService modelService})
      : _modelService = modelService;

  /// A public getter to access the current list of [ModelEntity] objects.
  List<ModelEntity> get recentModels => recentModelsNotifier.value;

  /// Initializes the manager by loading models from the fastest available source.
  Future<void> initialize({required String langCode}) async {
    debugPrint("[RecentModelsManager] Initializing...");

    // The cache now stores raw maps, which we hydrate into entities.
    final cachedModelMaps = CacheService.get<List<Map<String, dynamic>>>(CacheKey.recentModels);

    if (cachedModelMaps != null) {
      debugPrint("[RecentModelsManager] Loading recent models from fast cache.");
      // Hydrate the raw maps from cache into ModelEntity objects.
      recentModelsNotifier.value = cachedModelMaps
          .map((map) => ModelEntity.fromMap(map, langCode))
          .toList();
    } else {
      debugPrint("[RecentModelsManager] Fast cache is empty. Performing a full refresh.");
      await refresh(langCode: langCode);
    }
  }

  /// Fetches the most recent model IDs, finds the corresponding [ModelEntity] objects,
  /// updates the cache, and notifies listeners.
  Future<void> refresh({required String langCode}) async {
    debugPrint("[RecentModelsManager] Refreshing recent models from storage.");

    final recentIds = await ChatStorageService.getRecentModelSeriesIds(langCode: langCode, modelService: _modelService);
    final loadedRecentModels = <ModelEntity>[];
    final List<ModelEntity> allModels = _modelService.getCachedModelsSync();

    for (final id in recentIds) {
      try {
        // Find the full ModelEntity from the master list.
        final model = allModels.firstWhere((m) => m.id == id);
        // Add the entity directly to the list, no conversion needed.
        loadedRecentModels.add(model);
      } catch (e) {
        debugPrint("[RecentModelsManager] Could not map recent ID ('$id') to a model. It may have been removed.");
      }
    }

    // REFACTORED: When caching, serialize the entities back to raw maps.
    CacheService.set(CacheKey.recentModels, loadedRecentModels.map((e) => e.toMap()).toList());

    // Notify all listeners with the new list of entities.
    recentModelsNotifier.value = loadedRecentModels;
    debugPrint("[RecentModelsManager] Refresh complete. Found ${loadedRecentModels.length} recent models.");
  }

  /// Cleans up resources.
  void dispose() {
    recentModelsNotifier.dispose();
  }
}