// lib/chat/services/recent.dart

// This file defines the RecentModelsManager class, which encapsulates all logic
// for fetching, caching, and providing the list of recently used models.
// It uses a ValueNotifier to allow the UI to reactively update when the list changes.

import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/models/backend/data/data.dart';
import 'package:flutter/foundation.dart';
import '../../cache.dart';
import '../../models/backend/data/info.dart';

/// Manages the state and logic for recently used models.
///
/// This class is responsible for:
/// - Owning the list of recent models.
/// - Providing the list to the UI via a [ValueNotifier].
/// - Loading models from the fast cache or persistent storage.
/// - Handling the logic to refresh the list when needed.
class RecentModelsManager {
  /// A notifier that holds the list of recent models.
  /// The UI can listen to this to rebuild automatically when the data changes.
  final ValueNotifier<List<ModelInfo>> recentModelsNotifier =
  ValueNotifier<List<ModelInfo>>([]);

  /// A public getter to easily access the current list of models without listening.
  List<ModelInfo> get recentModels => recentModelsNotifier.value;

  /// Initializes the manager by loading models from the fastest available source.
  ///
  /// It first checks the in-memory cache. If the cache is empty, it triggers
  /// a full refresh from persistent storage.
  Future<void> initialize() async {
    debugPrint("[RecentModelsManager] Initializing...");
    final cachedModels = CacheService.get<List<ModelInfo>>(CacheKey.recentModels);

    if (cachedModels != null) {
      debugPrint("[RecentModelsManager] Loading recent models from fast cache.");
      recentModelsNotifier.value = cachedModels;
    } else {
      debugPrint("[RecentModelsManager] Fast cache is empty. Performing a full refresh.");
      await refresh();
    }
  }

  /// Fetches the most recent model series IDs from storage, maps them to full
  /// [ModelInfo] objects, updates the cache, and notifies listeners.
  ///
  /// This is the single source of truth for reloading recent models.
  Future<void> refresh() async {
    debugPrint("[RecentModelsManager] Refreshing recent models from storage.");
    // This function now safely waits for the master list to be loaded
    // and returns a list of GUARANTEED valid model series IDs.
    final recentIds = await ChatStorageService.getRecentModelSeriesIds();
    final loadedRecentModels = <ModelInfo>[];

    // Get the definitive, populated list of all models from the central source.
    final allModels = ModelData.getCachedModelsSync();

    for (final id in recentIds) {
      try {
        // Search in the definitive list.
        final modelData = allModels.firstWhere((m) => m['id'] == id);

        // Convert the raw map to a ModelInfo object.
        loadedRecentModels.add(ModelInfo(
          id: modelData['id'],
          title: modelData['title'],
          imagePath: ModelData.getModelImagePath(modelData),
          producer: modelData['producer'],
        ));
      } catch (e) {
        debugPrint("[RecentModelsManager] CRITICAL: Could not map a validated recent ID ('$id') to a model. This should not happen. Error: $e");
      }
    }

    // Update the fast cache.
    CacheService.set(CacheKey.recentModels, loadedRecentModels);

    // Notify all listeners (like the UI) about the new list.
    recentModelsNotifier.value = loadedRecentModels;
    debugPrint("[RecentModelsManager] Refresh complete. Found ${loadedRecentModels.length} recent models.");
  }

  /// Cleans up resources, specifically the [ValueNotifier].
  /// This should be called in the `dispose` method of the owning widget.
  void dispose() {
    recentModelsNotifier.dispose();
  }
}