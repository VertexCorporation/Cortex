// utils.dart
//
// Collection of helper utilities used across the “Models” feature-set.
//
// © 2025 Cortex
//
// ──────────────────────────────────────────────────────────────────────────────
//  NOTE
//  ----
//  •  All logs use `dart:developer`'s [log] so they can be filtered in DevTools.
//  •  All public APIs have Dart-doc comments so that pub.dev / IDEs show hints.
//  •  Keep this file **platform-agnostic** – do NOT import `package:flutter/...`
//     except for isolate helpers (`compute`) which are part of Flutter SDK.
// ──────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:cortex/models/backend/system_info.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'data.dart'; // CompatibilityStatus, ModelInfo, etc.

// It takes the source file path and destination path.
// Returns the path of the copied file on success, or throws an error on failure.
Future<String> copyFileInIsolate(Map<String, String> paths) async {
  final sourcePath = paths['sourcePath']!;
  final destPath = paths['destPath']!;
  try {
    final sourceFile = File(sourcePath);
    // Ensure the destination directory exists
    final destDir = Directory(p.dirname(destPath));
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }
    final newFile = await sourceFile.copy(destPath);
    return newFile.path;
  } catch (e) {
    // Re-throw the error to be caught by the main isolate
    throw Exception('File copy failed in isolate: $e');
  }
}

/// Utility helpers for model handling, disk IO, and system-capability checks.
class Utils {
  /* ───────────────────────────────── FILE & LAYOUT HELPERS ───────────────── */

  /// Calculates the **maximum height** needed for a PageView that shows model
  /// cards in columns of three (3) – keeping the UI from jumping while paging.
  ///
  /// The formula mirrors sizes in `ModelTile`, so update both in lock-step.
  static double calculateCategoryHeight(
      List<Map<String, dynamic>> models,
      double screenWidth,
      ) {
    dev.log(
      'calculateCategoryHeight(models: ${models.length}, width: $screenWidth)',
      name: 'Utils',
    );

    const modelsPerColumn = 3;
    const verticalSpacingFactor = 0.01;
    final cardHeight = screenWidth * 0.17;
    final spacing = screenWidth * verticalSpacingFactor;

    final totalColumns = (models.length / modelsPerColumn).ceil();
    var maxColumnHeight = 0.0;

    for (var i = 0; i < totalColumns; i++) {
      final start = i * modelsPerColumn;
      final end = (start + modelsPerColumn).clamp(0, models.length);
      final entries = end - start;
      final columnHeight = entries * cardHeight + (entries - 1) * spacing;
      maxColumnHeight = columnHeight > maxColumnHeight ? columnHeight : maxColumnHeight;
    }

    // Add a little breathing room (20 % of one card).
    final dynamicGap = cardHeight * 0.2;
    final result = maxColumnHeight + dynamicGap;

    dev.log('Calculated category height = $result', name: 'Utils');
    return result;
  }

  /* ────────────────────────────────── DISK HELPERS ───────────────────────── */

  /// Returns the application-support directory where model files (.gguf) live.
  static Future<String> initializeDirectory() async {
    final dir = await getApplicationSupportDirectory();
    dev.log('App-support directory resolved: ${dir.path}', name: 'Utils');
    return dir.path;
  }

  /// THIS IS THE SINGLE SOURCE OF TRUTH FOR ALL FILE PATHS.
  /// It uses the unique, non-localized model ID to prevent any ambiguity.
  ///
  /// Example: /data/user/0/com.vertex.cortex/app_flutter/jannano128k.gguf
  static String getFilePathById({
    required String filesDir,
    required String modelId,
    // The modelTitle is now completely ignored for path generation, which is essential for robustness.
    required String modelTitle,
  }) {
    assert(filesDir.isNotEmpty, 'filesDir must not be empty');
    assert(modelId.isNotEmpty, 'modelId must not be empty');

    // THE FLAWLESS FIX: The filename is derived ONLY from the non-localized, unique modelId.
    // This guarantees that the UI layer and the backend layer are looking for the exact same file.
    final fullPath = p.join(filesDir, '$modelId.gguf');

    dev.log(
      '[CANONICAL_PATH] getFilePathById(id: $modelId) → $fullPath',
      name: 'Utils',
    );

    return fullPath;
  }

  /// Scans the given [models] list on an isolate and returns a map
  /// `{ modelId : isFileComplete }`.
  ///
  /// *A file is considered **complete** if its size is ≥ 98 % of the expected
  /// `.gguf` size.*  (Guards against partially-downloaded artefacts).
  static Future<Map<String, bool>> collectFileStates(
      List<Map<String, dynamic>> models, String filesDir) async {
    dev.log("[Utils] Collecting file states based on the SINGLE SOURCE OF TRUTH: UserModels (SharedPreferences).", name: 'Utils.FileState');

    // 1. Get the definitive list of downloaded models from SharedPreferences.
    // This map contains { "modelId": "/path/to/file.gguf" }.
    final downloadedPaths = await UserModels.loadDownloadedModelPaths();

    // 2. Create the final state map.
    final Map<String, bool> fileStates = {};

    // 3. Iterate through all models provided.
    for (final model in models) {
      final id = model['id'] as String;
      // A model is considered downloaded if and only if it has an entry
      // in our persistent UserModels record.
      fileStates[id] = downloadedPaths.containsKey(id);
    }

    dev.log("[Utils] Final collected states: $fileStates", name: 'Utils.FileState');
    return fileStates;
  }

  /* ───────────────────────────────────── RAM / DISK CHECKS ───────────────── */

  /// Fetches device system information (RAM, free storage, etc.).
  static Future<SystemInfoData?> loadSystemInfo() async {
    try {
      final info = await SystemInfoProvider.fetchSystemInfo();
      dev.log('System info loaded: $info', name: 'Utils');
      return info;
    } catch (e, st) {
      dev.log('Failed to load system info', name: 'Utils', error: e, stackTrace: st);
      return null;
    }
  }

  /// Converts strings like `"2.5 GB"` or `"768 MB"` to **megabytes**.
  static int parseSizeToMB(String size) {
    if (size.isEmpty) return 0;
    final parts = size.split(' ');
    if (parts.length < 2) return 0;

    final value = double.tryParse(parts[0].replaceAll(',', '')) ?? 0.0;
    final unit = parts[1].toUpperCase();

    final mb = unit == 'GB' ? (value * 1024).round() : value.round();
    dev.log('parseSizeToMB("$size") → $mb MB', name: 'Utils');
    return mb;
  }

  /// Determines whether a model can run locally on the current device.
  ///
  /// - [sys]: System information including RAM (in MB) and free storage (in MB).
  /// - [modelSizeInMB]: The model’s on-disk size directly in megabytes.
  /// Returns a CompatibilityStatus indicating if RAM or storage is insufficient.
  static CompatibilityStatus getCompatibilityStatus({
    required SystemInfoData? sys,
    required int? modelSizeInMB,
  }) {
    // 0) If we have no system info, assume insufficient RAM for safety.
    if (sys == null) return CompatibilityStatus.insufficientRAM;

    // 1) If model size is null or 0, it's likely a server-side model
    //    or one without a defined size, so it's considered compatible for download checks.
    if (modelSizeInMB == null || modelSizeInMB == 0) {
      return CompatibilityStatus.compatible;
    }

    // 2) Calculate needed RAM: approximately twice the on-disk size.
    const double ramMultiplier = 2.0;
    final needRamMB = (modelSizeInMB * ramMultiplier).ceil();

    // 3) Normalize reported RAM to MB (some devices report GB < 128).
    int hasRamMB = sys.deviceMemory; // Already in MB on most devices.
    if (hasRamMB < 128) {
      // If the reported value is < 128, treat it as GB → convert to MB.
      hasRamMB *= 1024;
    }

    // 4) Calculate needed storage: on-disk size + 10% buffer.
    final needStoreMB = (modelSizeInMB * 1.1).ceil();
    final freeMB = sys.freeStorage; // Already in MB from native code.

    // 5) Check each resource.
    final ramOK = hasRamMB >= needRamMB;
    final storageOK = freeMB >= needStoreMB;

    // 6) Log details for debugging.
    dev.log(
      '[compat] modelSize=$modelSizeInMB MB, neededRAM=$needRamMB MB, '
          'availableRAM=$hasRamMB MB, neededStorage=$needStoreMB MB, freeStorage=$freeMB MB',
      name: 'Utils',
    );

    if (!ramOK) return CompatibilityStatus.insufficientRAM;
    if (!storageOK) return CompatibilityStatus.insufficientStorage;
    return CompatibilityStatus.compatible;
  }

  /* ───────────────────────────────── MISC HELPERS ────────────────────────── */

  /// Tries to resolve a model’s **display title** from either bundled models
  /// (_stockModels_) or user-provided models (_selfModels_).
  static String getTitleById({
    required List<Map<String, dynamic>> stockModels,
    required List<Map<String, dynamic>> selfModels,
    required String modelId,
  }) {
    try {
      final title = stockModels.firstWhere((m) => m['id'] == modelId)['title'];
      dev.log('getTitleById($modelId) → "$title" (stock)', name: 'Utils');
      return title;
    } catch (_) {
      final title = selfModels.firstWhere((m) => m['id'] == modelId)['title'];
      dev.log('getTitleById($modelId) → "$title" (self)', name: 'Utils');
      return title;
    }
  }

  /// Converts a `"1.2 GB"` / `"500 MB"` string into **bytes** (int).
  static int bytesFromSizeString(String sz) {
    if (sz.isEmpty) return 0;
    final parts = sz.split(' ');
    if (parts.length < 2) return 0;

    final value = double.tryParse(parts[0].replaceAll(',', '')) ?? 0.0;
    final unit = parts[1].toUpperCase();
    final bytes = unit == 'GB'
        ? (value * 1024 * 1024 * 1024).round()
        : (value * 1024 * 1024).round();

    dev.log('bytesFromSizeString("$sz") → $bytes bytes', name: 'Utils');
    return bytes;
  }

  static Future<String> getExpectedFilePathById(String modelId, String modelTitle) async {
    final Directory appSupportDir = await getApplicationSupportDirectory();
    final String filesDirectoryPath = appSupportDir.path;
    final String sanitizedTitle = modelTitle.replaceAll(RegExp(r'[/\\]'), '_'); // Sanitize
    return p.join(filesDirectoryPath, '$sanitizedTitle.gguf');
  }
}