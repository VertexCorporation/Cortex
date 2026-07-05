// models/backend/data/user.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModels {
  static const String _key = 'user_downloaded_models';

  /// Loads a map of `modelId` to `filePath` for downloaded models.
  static Future<Map<String, String>> loadDownloadedModelPaths() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_key);
      if (jsonString != null) {
        Map<String, dynamic> decodedMap = json.decode(jsonString);
        return decodedMap.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      debugPrint("Error decoding downloaded model paths: $e");
    }
    return {};
  }

  /// Saves the map of downloaded models.
  static Future<void> saveDownloadedModelPaths(
      Map<String, String> models) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, json.encode(models));
    } catch (e) {
      debugPrint("Error encoding downloaded model paths: $e");
    }
  }

  /// Adds or updates a single downloaded model's path.
  static Future<void> addDownloadedModel(
      String modelId, String filePath) async {
    final models = await loadDownloadedModelPaths();
    models[modelId] = filePath;
    await saveDownloadedModelPaths(models);
  }

  /// Removes a downloaded model entry.
  static Future<void> removeDownloadedModel(String modelId) async {
    final models = await loadDownloadedModelPaths();
    models.remove(modelId);
    await saveDownloadedModelPaths(models);
  }
}
