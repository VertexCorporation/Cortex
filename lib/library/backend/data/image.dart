// models/backend/data/image.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelImageCache {
  static const String _prefsKey = 'model_image_cache_paths';

// Loads the map of modelId -> localImagePath
  static Future<Map<String, String>> loadPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(jsonString);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
// In case of corruption, return empty map
        return {};
      }
    }
    return {};
  }

// Saves the map
  static Future<void> savePaths(Map<String, String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(paths));
  }

// Adds a single entry and saves
  static Future<void> add(String modelId, String localPath) async {
    final paths = await loadPaths();
    paths[modelId] = localPath;
    await savePaths(paths);
  }

  static Future<void> remove(Iterable<String> modelIds) async {
    if (modelIds.isEmpty) return;
    final paths = await loadPaths();
    for (final id in modelIds) {
      final localPath = paths[id];
      if (localPath != null) {
        try {
          final file = File(localPath);
          if (await file.exists()) {
            await file.delete();
            debugPrint("[ModelImageCache] Deleted cached image: $localPath");
          }
        } catch (e) {
          debugPrint("[ModelImageCache] Error deleting file $localPath: $e");
        }
        paths.remove(id);
      }
    }
    await savePaths(paths);
  }
}