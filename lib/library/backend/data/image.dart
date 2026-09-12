// lib/library/backend/data/image.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:typed_data';

import 'package:cortex/performance/write_behind.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent model-image path cache with an in-memory fast path.
///
/// Path mutations are replaceable cache writes, not financial/user data. A
/// short write-behind window therefore safely folds bursts of image downloads
/// into one SharedPreferences serialization/write instead of rewriting the
/// whole map after every downloaded cover.
class ModelImageCache {
  static const String _prefsKey = 'model_image_cache_paths';
  static const Duration _writeBehindDelay = Duration(milliseconds: 750);

  static Map<String, String>? _inMemoryCache;
  static Map<String, String>? _pendingSnapshot;
  static Future<Map<String, String>>? _loadFuture;

  static final LatestWriteQueue<Map<String, String>> _writeQueue =
      LatestWriteQueue<Map<String, String>>(
    delay: _writeBehindDelay,
    writer: (paths) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, json.encode(paths));
      // Clear only when this exact pending state was persisted. A newer
      // snapshot may have arrived while SharedPreferences was writing.
      if (mapEquals(_pendingSnapshot, paths)) {
        _pendingSnapshot = null;
      }
    },
    onError: (error, stack) {
      debugPrint('[ModelImageCache] deferred cache write failed: $error');
    },
  );

  static Future<Map<String, String>> loadPaths() {
    final memory = _inMemoryCache;
    if (memory != null) return Future.value(memory);

    // invalidateInMemoryCache may run while a deferred persistence write is
    // pending. The newest snapshot is still authoritative and avoids a stale
    // disk read/redownload window.
    final pending = _pendingSnapshot;
    if (pending != null) {
      _inMemoryCache = Map<String, String>.from(pending);
      return Future.value(_inMemoryCache!);
    }

    final existing = _loadFuture;
    if (existing != null) return existing;

    late Future<Map<String, String>> future;
    future = _loadPathsFromDisk().whenComplete(() {
      if (identical(_loadFuture, future)) _loadFuture = null;
    });
    _loadFuture = future;
    return future;
  }

  static Future<Map<String, String>> _loadPathsFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null || jsonString.isEmpty) {
      _inMemoryCache = <String, String>{};
      return _inMemoryCache!;
    }

    try {
      final decoded = json.decode(jsonString);
      if (decoded is! Map) throw const FormatException('cache is not a map');
      final paths = <String, String>{};
      for (final entry in decoded.entries) {
        final key = entry.key.toString();
        final value = entry.value?.toString();
        if (key.isEmpty || value == null || value.isEmpty) continue;
        paths[key] = value;
      }
      _inMemoryCache = paths;
      return paths;
    } catch (e) {
      debugPrint('[ModelImageCache] Error decoding cached paths: $e');
      _inMemoryCache = <String, String>{};
      return _inMemoryCache!;
    }
  }

  static bool _syncWarningShown = false;

  static Map<String, String> getPathsSync() {
    final memory = _inMemoryCache;
    if (memory != null) return memory;

    final pending = _pendingSnapshot;
    if (pending != null) {
      _inMemoryCache = Map<String, String>.from(pending);
      return _inMemoryCache!;
    }

    if (!_syncWarningShown) {
      debugPrint(
        '[ModelImageCache] WARNING: getPathsSync() called before cache '
        'initialization. Returning an empty map.',
      );
      _syncWarningShown = true;
    }
    return const <String, String>{};
  }

  static void invalidateInMemoryCache() {
    _inMemoryCache = null;
    debugPrint('[ModelImageCache] In-memory cache invalidated.');
  }

  /// Persists a complete snapshot before returning. Use this for destructive
  /// mutations where callers require durable completion.
  static Future<void> savePaths(Map<String, String> paths) async {
    final snapshot = Map<String, String>.from(paths);
    _inMemoryCache = snapshot;
    _pendingSnapshot = snapshot;
    _writeQueue.add(snapshot);
    await _writeQueue.flush();
  }

  /// Adds one path to memory immediately and schedules durable persistence.
  /// Multiple downloads inside the write-behind window collapse to one write.
  static Future<void> add(String modelId, String localPath) async {
    if (modelId.isEmpty || localPath.isEmpty) return;
    final paths = Map<String, String>.from(await loadPaths());
    if (paths[modelId] == localPath) return;
    paths[modelId] = localPath;
    _inMemoryCache = paths;
    _pendingSnapshot = Map<String, String>.from(paths);
    _writeQueue.add(_pendingSnapshot!);
  }

  /// Applies a whole download batch with one persistence snapshot.
  static Future<void> addAll(Map<String, String> entries,
      {bool flush = false}) async {
    if (entries.isEmpty) return;
    final paths = Map<String, String>.from(await loadPaths());
    var changed = false;
    for (final entry in entries.entries) {
      if (entry.key.isEmpty || entry.value.isEmpty) continue;
      if (paths[entry.key] == entry.value) continue;
      paths[entry.key] = entry.value;
      changed = true;
    }
    if (!changed) return;

    _inMemoryCache = paths;
    _pendingSnapshot = Map<String, String>.from(paths);
    _writeQueue.add(_pendingSnapshot!);
    if (flush) await _writeQueue.flush();
  }

  static Future<void> flushPendingWrites() => _writeQueue.flush();

  static Future<void> remove(Iterable<String> modelIds) async {
    final ids = modelIds.where((id) => id.isNotEmpty).toSet();
    if (ids.isEmpty) return;

    final paths = Map<String, String>.from(await loadPaths());
    var wasModified = false;

    for (final id in ids) {
      final localPath = paths[id];
      if (localPath == null) continue;
      try {
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('[ModelImageCache] Deleted cached image file: $localPath');
        }
      } catch (e) {
        debugPrint('[ModelImageCache] Error deleting file $localPath: $e');
      }
      paths.remove(id);
      wasModified = true;
    }

    if (wasModified) await savePaths(paths);
  }
}
