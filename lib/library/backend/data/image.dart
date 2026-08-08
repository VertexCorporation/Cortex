// lib/library/backend/data/image.dart

import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Changed from cupertino to foundation for debugPrint
import 'package:shared_preferences/shared_preferences.dart';

class ModelImageCache {
  static const String _prefsKey = 'model_image_cache_paths';

  /// In-memory cache for fast, synchronous access after the initial load.
  static Map<String, String>? _inMemoryCache;

  /// Asynchronously loads the map of modelId -> localImagePath from persistent storage.
  ///
  /// This method should be called at least once during the app's startup phase
  /// to populate the in-memory cache, making subsequent calls to `getPathsSync()` safe.
  static Future<Map<String, String>> loadPaths() async {
    // If the in-memory cache is already populated, return it to avoid redundant disk reads.
    if (_inMemoryCache != null) {
      return _inMemoryCache!;
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(jsonString);
        final paths =
            decoded.map((key, value) => MapEntry(key, value.toString()));
        _inMemoryCache = paths; // Populate the in-memory cache
        return paths;
      } catch (e) {
        debugPrint("[ModelImageCache] Error decoding cached paths: $e");
        _inMemoryCache = {}; // Initialize as empty on error
        return {};
      }
    }
    _inMemoryCache = {}; // Initialize as empty if no data exists
    return {};
  }

  static bool _syncWarningShown = false;

  /// Synchronously returns the cached image paths from the in-memory store.
  ///
  /// IMPORTANT: This method relies on `loadPaths()` having been called and completed
  /// at least once. If called before initialization, it will return an empty map.
  static Map<String, String> getPathsSync() {
    if (_inMemoryCache == null) {
      if (!_syncWarningShown) {
        debugPrint(
            "[ModelImageCache] WARNING: getPathsSync() called before cache was initialized. Returning empty map.");
        _syncWarningShown = true;
      }
      return {};
    }
    return _inMemoryCache!;
  }

  /// Clears the in-memory cache, forcing a fresh read from storage on the next `loadPaths()` call.
  /// This is crucial for ensuring the cache is up-to-date after background operations like image downloads.
  static void invalidateInMemoryCache() {
    _inMemoryCache = null;
    debugPrint("[ModelImageCache] In-memory cache invalidated.");
  }

  /// Saves the given map of paths to persistent storage.
  static Future<void> savePaths(Map<String, String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(paths));
    _inMemoryCache = paths; // Keep the in-memory cache in sync
  }

  /// Adds a single entry to the cache and saves it to persistent storage.
  static Future<void> add(String modelId, String localPath) async {
    // Ensure the cache is loaded before modifying it.
    final paths = await loadPaths();
    paths[modelId] = localPath;
    await savePaths(paths);
  }

  /// Removes a list of model IDs and their associated image files and paths.
  static Future<void> remove(Iterable<String> modelIds) async {
    if (modelIds.isEmpty) return;

    // Ensure the cache is loaded before modifying it.
    final paths = await loadPaths();
    bool wasModified = false;

    for (final id in modelIds) {
      final localPath = paths[id];
      if (localPath != null) {
        try {
          final file = File(localPath);
          if (await file.exists()) {
            await file.delete();
            debugPrint(
                "[ModelImageCache] Deleted cached image file: $localPath");
          }
        } catch (e) {
          debugPrint("[ModelImageCache] Error deleting file $localPath: $e");
        }
        paths.remove(id);
        wasModified = true;
      }
    }

    if (wasModified) {
      await savePaths(paths);
    }
  }
}
