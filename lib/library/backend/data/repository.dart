// lib/library/backend/data/repository.dart

//
// This file defines the ModelRepository class, which serves as the single source
// of truth for fetching and persisting raw model data. Its sole responsibility
// is to interact with data sources (network, database, shared preferences) and
// manage the raw data lifecycle, including synchronization and caching of raw JSON maps.
//
// This class is part of the data layer and should have no knowledge of business logic
// (like sorting) or UI-facing entities (like ModelEntity).
//

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cortex/library/backend/data/crypto.dart';
import 'package:cortex/library/backend/data/database.dart';
import 'package:cortex/library/backend/data/image.dart';
import 'package:cortex/library/backend/data/user.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:sqflite/sqflite.dart';

/// The [ModelRepository] class is responsible for all low-level data operations
/// related to AI models. It abstracts the data sources from the rest of the application.
class ModelRepository {
  // --- Private Properties ---

  /// In-memory cache for raw model data (`List<Map<String, dynamic>>`) to ensure
  /// fast access after the initial load. This cache is considered the source of truth
  /// for this repository once populated.
  List<Map<String, dynamic>>? _rawModelsCache;

  List<Map<String, dynamic>>? get rawModelsCache => _rawModelsCache;

  // Configuration constants for data synchronization.
  static const Duration _cacheStaleDuration = Duration(hours: 1);
  static const String _prefsKeyLastSync = 'model_data_last_sync_timestamp';
  static const String _prefsKeyLastSyncLang = 'model_data_last_sync_lang';
  static const String _prefsKeyPreservedStaleModelIds =
      'model_data_preserved_stale_model_ids';
  static const String _serverUrl = 'https://cortexishere.com/models';

  /// Singleton instances for database and authentication helpers.
  final Dio _dio;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  /// A completer used as a concurrency lock to prevent multiple simultaneous
  /// synchronization processes from running.
  Completer<void>? _syncCompleter;

  /// Constructor
  ModelRepository({required Dio dio}) : _dio = dio;

  // --- Public API ---

  /// Fetches all models, orchestrating caching and network synchronization.
  ///
  /// This is the main entry point for the [ModelService]. It ensures that data
  /// is loaded efficiently, either from the in-memory cache or by triggering a
  /// full initialization and sync process.
  /// Returns a list of raw model data maps, or null on a critical failure.
  Future<List<Map<String, dynamic>>?> getAllModels(
      {required String langCode,
      required Map<String, String> localAssetMap}) async {
    // If a sync process is already running, await its completion to ensure consistency.
    if (_syncCompleter != null) {
      debugPrint(
          "[ModelRepository] A sync process is already running. Awaiting its completion.");
      await _syncCompleter!.future;
      return _rawModelsCache;
    }

    // If the cache is already populated, return it immediately for performance.
    if (_rawModelsCache != null) {
      return _rawModelsCache;
    }

    // If no sync is running and the cache is empty, start a new initialization process.
    debugPrint("[ModelRepository] Starting new data initialization process.");
    _syncCompleter = Completer<void>();
    try {
      await _initializeAndSync(
          langCode: langCode, localAssetMap: localAssetMap);
      _syncCompleter!.complete();
      return _rawModelsCache;
    } catch (e, s) {
      debugPrint(
          "[ModelRepository] CRITICAL Error during initialization: $e\n$s");
      _syncCompleter!.completeError(e);
      return null; // Return null to indicate a failure to the service layer.
    } finally {
      _syncCompleter = null;
    }
  }

  /// Updates the `baseModelId` for a specific model in the database.
  ///
  /// This method handles both encrypted (user-created) and unencrypted (public)
  /// model data by decrypting, updating, and re-encrypting if necessary.
  /// Returns `true` on success, `false` on failure.
  Future<bool> updateBaseModel(String modelId, String newBaseModelId) async {
    const String logPrefix = "[ModelRepository.updateBaseModel]";
    try {
      final db = await _dbHelper.database;
      if (db == null) return false;

      final results =
          await db.query('models', where: 'id = ?', whereArgs: [modelId]);

      if (results.isEmpty) {
        debugPrint(
            "$logPrefix: Model with ID '$modelId' not found in the database.");
        return false;
      }

      final rawJsonString = results.first['raw_json'] as String;
      final isCustomModel =
          modelId.startsWith('self_') || modelId.startsWith('local_');

      Map<String, dynamic> updatedJsonData;
      String? finalJsonToSave;

      if (isCustomModel) {
        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          throw Exception("User not authenticated for encrypted operation.");
        }

        final decryptedJson =
            CryptoHelper.decrypt(rawJsonString, currentUser.uid);
        if (decryptedJson == null) {
          throw Exception("Failed to decrypt model data for '$modelId'.");
        }

        updatedJsonData = json.decode(decryptedJson);
        updatedJsonData['baseModelId'] = newBaseModelId;
        finalJsonToSave =
            CryptoHelper.encrypt(json.encode(updatedJsonData), currentUser.uid);
      } else {
        updatedJsonData = json.decode(rawJsonString);
        updatedJsonData['baseModelId'] = newBaseModelId;
        finalJsonToSave = json.encode(updatedJsonData);
      }

      await db.update('models', {'raw_json': finalJsonToSave},
          where: 'id = ?', whereArgs: [modelId]);

      // Update the in-memory raw cache to reflect the change immediately.
      if (_rawModelsCache != null) {
        final index = _rawModelsCache!.indexWhere((m) => m['id'] == modelId);
        if (index != -1) {
          _rawModelsCache![index] = updatedJsonData;
          debugPrint(
              "$logPrefix: Hot-patched raw in-memory cache for model '$modelId'.");
        }
      }

      debugPrint(
          "$logPrefix: Successfully updated baseModelId for '$modelId'.");
      return true;
    } catch (e) {
      if (e.toString().contains("SQLITE_FULL")) {
        debugPrint("$logPrefix: DISK FULL. Could not update base model.");
        return false;
      }
      debugPrint("$logPrefix: CRITICAL ERROR updating base model: $e");
      return false;
    }
  }

  /// Clears the in-memory cache of raw models.
  void clearRawCache() {
    _rawModelsCache = null;
    debugPrint("[ModelRepository] In-memory raw model cache cleared.");
  }

  // --- Private Core Logic ---

  /// Orchestrates the entire data initialization and synchronization pipeline.
  Future<void> _initializeAndSync(
      {required String langCode,
      required Map<String, String> localAssetMap}) async {
    final prefs = await SharedPreferences.getInstance();
    await _cleanupPreservedStaleModelsThatAreNoLongerDownloaded(prefs);

    final lastSyncTimeString = prefs.getString(_prefsKeyLastSync);
    final lastSyncTime = lastSyncTimeString != null
        ? DateTime.tryParse(lastSyncTimeString)
        : null;
    final lastSyncLangCode = prefs.getString(_prefsKeyLastSyncLang);

    final initialDbMaps =
        await _dbHelper.getAllModels(userId: _auth.currentUser?.uid);

    final isDbEmpty = initialDbMaps.isEmpty;
    final isCacheStale = lastSyncTime == null ||
        DateTime.now().difference(lastSyncTime) > _cacheStaleDuration;
    final hasInternet = await InternetConnection().hasInternetAccess;
    final isLangChanged =
        lastSyncLangCode != null && lastSyncLangCode != langCode;

    if (hasInternet && (isDbEmpty || isCacheStale || isLangChanged)) {
      debugPrint(
          "[ModelRepository] Sync required. DB Empty: $isDbEmpty, Stale: $isCacheStale, Lang Changed: $isLangChanged");
      await _syncWithServer(langCode);
    } else {
      debugPrint("[ModelRepository] Sync not required. Loading from local DB.");
    }

    final mapsFromDb =
        await _dbHelper.getAllModels(userId: _auth.currentUser?.uid);
    _rawModelsCache = mapsFromDb;
    debugPrint(
        "[ModelRepository] Raw cache initialized with ${_rawModelsCache?.length ?? 0} models from database.");

    if (hasInternet && _rawModelsCache != null) {
      await _syncModelImages(_rawModelsCache!, localAssetMap);

      // After image sync is complete, invalidate the in-memory cache of image paths.
      // This forces the ModelService to re-load the fresh data from persistent storage
      // instead of using a stale in-memory version.
      ModelImageCache.invalidateInMemoryCache();
      debugPrint(
          "[ModelRepository] Invalidated image path cache to force a fresh read.");
    }
  }

  /// Manages the full server synchronization flow.
  Future<void> _syncWithServer(String langCode) async {
    debugPrint("[ModelRepository] Starting full model sync with server...");
    try {
      final validPublicIds = await _fetchAndStorePublicModels(langCode);
      debugPrint(
          "[ModelRepository] Public model sync complete. Found ${validPublicIds.length} valid IDs.");

      await _cleanupStaleModels(validPublicIds);

      await _updateLastSyncState(langCode);
      debugPrint("[ModelRepository] Sync process fully complete.");
    } catch (e, s) {
      debugPrint(
          "[ModelRepository] CRITICAL ERROR during sync orchestration: $e\n$s");
      throw Exception("Sync with server failed.");
    }
  }

  /// Fetches the public model list from the remote server.
  ///
  /// OPTIMIZATION NOTES FOR LOW-END DEVICES (ANR Prevention):
  /// 1. **Isolate Parsing**: JSON parsing is moved to a background isolate via `compute`.
  ///    This prevents the CPU from blocking the main thread during data processing.
  /// 2. **Chunked Inserts**: Database writes are split into batches of 50.
  /// 3. **UI Yielding**: After each batch commit, we `await Future.delayed(Duration.zero)`.
  ///    This gives the UI thread a chance to render frames and handle events, preventing
  ///    "Application Not Responding" errors on slow storage devices.
  /// 4. **Deferred Vacuum**: Database optimization is performed only after all writes are done
  ///    and after a brief cooling period.
  Future<Set<String>> _fetchAndStorePublicModels(String langCode) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _serverUrl,
        options: Options(
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode != 200) {
        debugPrint(
            "[ModelRepository] Server returned status ${response.statusCode}. Skipping sync.");
        return <String>{};
      }

      if (response.data == null) {
        debugPrint("[ModelRepository] Server returned empty data.");
        return <String>{};
      }

      final rawServerData = response.data!;

      // 1. Offload heavy JSON parsing to a background isolate.
      debugPrint(
          "[ModelRepository] Parsing server data in background isolate...");
      final parsedServerModels = await compute(
        _parseServerDataIsolate,
        {'data': rawServerData, 'langCode': langCode},
      );

      final parsedFallbackModels = await compute(
        _parseServerDataIsolate,
        {
          'data': {'producers': rawServerData['fallback'] ?? {}},
          'langCode': langCode
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fallback', json.encode(parsedFallbackModels));

      final validServerIds =
          parsedServerModels.map((m) => m['id'] as String).toSet();

      // Filter out local/custom models just in case the server sent something weird.
      final modelsToInsert = parsedServerModels.where((modelData) {
        return !modelData['id'].startsWith('self_') &&
            !modelData['id'].startsWith('local_');
      }).toList();

      if (modelsToInsert.isNotEmpty) {
        final db = await _dbHelper.database;
        if (db != null) {
          const int batchSize = 50; // Optimal chunk size to prevent locking

          for (var i = 0; i < modelsToInsert.length; i += batchSize) {
            final end = (i + batchSize < modelsToInsert.length)
                ? i + batchSize
                : modelsToInsert.length;
            final currentBatch = modelsToInsert.sublist(i, end);

            final batch = db.batch();

            for (var modelData in currentBatch) {
              batch.insert(
                  'models',
                  {
                    'id': modelData['id'],
                    'producer': modelData['producer'] ?? 'Unknown',
                    'title': modelData['title'] ?? modelData['id'],
                    'is_server_side': (modelData['type'] != 'offline') ? 1 : 0,
                    'type': modelData['type'] ?? 'online',
                    'raw_json': json.encode(modelData),
                  },
                  conflictAlgorithm: ConflictAlgorithm.replace);
            }

            try {
              await batch.commit(noResult: true);

              // 2. Yield to the UI thread to prevent ANRs on slow devices.
              await Future.delayed(Duration.zero);
            } catch (e) {
              if (e.toString().contains("SQLITE_FULL")) {
                debugPrint(
                    "[ModelRepository] DISK FULL. Aborting model sync save.");
                break;
              } else {
                rethrow;
              }
            }
          }
        }
      }

      // 3. Allow UI to breathe before the heavy VACUUM operation.
      await Future.delayed(const Duration(milliseconds: 100));

      // 4. Perform database optimization.
      await _dbHelper.optimizeDatabase();

      return validServerIds;
    } on DioException catch (e, s) {
      if (e.response?.statusCode == 500) {
        debugPrint(
            "[ModelRepository] Server Error (500). Using local cache instead.");
        FirebaseCrashlytics.instance
            .log("Server 500 error on model sync. Skipping.");
        return <String>{};
      }

      final errorString = e.toString();
      if (errorString.contains("CERTIFICATE_VERIFY_FAILED") ||
          errorString.contains("HandshakeException")) {
        debugPrint(
            "[ModelRepository] SSL/Certificate Error detected (Likely user network issue). Using local cache.");
        return <String>{};
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        debugPrint(
            "[ModelRepository] Network timeout or connection error (${e.type}). Using local cache.");
        return <String>{};
      }

      debugPrint("[ModelRepository] Unexpected DioException: $e");
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'Failed to sync public models');
      return <String>{};
    } catch (e, s) {
      debugPrint("[ModelRepository] Generic error: $e");
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'Unexpected failure in public model sync');
      return <String>{};
    }
  }

  /// Removes models from the local database that are no longer present on the server.
  Future<void> _cleanupStaleModels(Set<String> validPublicIds) async {
    if (validPublicIds.isEmpty) return;

    try {
      final db = await _dbHelper.database;
      if (db == null) return;

      final downloadedModelIds =
          (await UserModels.loadDownloadedModelPaths()).keys.toSet();
      final placeholders = List.filled(validPublicIds.length, '?').join(',');

      final allStaleModels = await db.query(
        'models',
        columns: ['id', 'raw_json'],
        where:
            "id NOT IN ($placeholders) AND id NOT LIKE 'self_%' AND id NOT LIKE 'local_%'",
        whereArgs: validPublicIds.toList(),
      );

      if (allStaleModels.isNotEmpty) {
        final staleModelsToDelete = <Map<String, dynamic>>[];
        final preservedStaleIds = <String>{};

        for (final model in allStaleModels) {
          final id = model['id'] as String;
          if (downloadedModelIds.contains(id)) {
            preservedStaleIds.add(id);
          } else {
            staleModelsToDelete.add(model);
          }
        }

        await _savePreservedStaleModelIds(preservedStaleIds);

        if (staleModelsToDelete.isEmpty) {
          return;
        }

        debugPrint(
            "[ModelRepository] Found ${staleModelsToDelete.length} stale public models to clean up.");
        final staleModelIds =
            staleModelsToDelete.map((m) => m['id'] as String).toList();

        // Concurrently delete associated images from cache.
        await _deleteStaleImages(staleModelsToDelete);

        final count = await db.delete(
          'models',
          where: "id IN (${List.filled(staleModelIds.length, '?').join(',')})",
          whereArgs: staleModelIds,
        );
        debugPrint(
            "[ModelRepository] Cleaned up $count stale models from database.");
      }
    } catch (e) {
      if (e.toString().contains("SQLITE_FULL")) {
        debugPrint(
            "[ModelRepository] Disk full during cleanup. Skipping delete operation.");
        return;
      }
      debugPrint("[ModelRepository] Error during cleanup: $e");
    }
  }

  Future<void> _savePreservedStaleModelIds(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKeyPreservedStaleModelIds, ids.toList());
    } catch (e) {
      debugPrint(
          "[ModelRepository] Failed to persist preserved stale model IDs: $e");
    }
  }

  Future<void> _cleanupPreservedStaleModelsThatAreNoLongerDownloaded(
      SharedPreferences prefs) async {
    final preservedIds =
        prefs.getStringList(_prefsKeyPreservedStaleModelIds) ?? [];
    if (preservedIds.isEmpty) return;

    try {
      final downloadedModelIds =
          (await UserModels.loadDownloadedModelPaths()).keys.toSet();
      final idsToDelete =
          preservedIds.where((id) => !downloadedModelIds.contains(id)).toList();

      if (idsToDelete.isEmpty) return;

      final db = await _dbHelper.database;
      if (db == null) return;

      final placeholders = List.filled(idsToDelete.length, '?').join(',');
      final staleModels = await db.query(
        'models',
        columns: ['id', 'raw_json'],
        where: "id IN ($placeholders)",
        whereArgs: idsToDelete,
      );

      if (staleModels.isNotEmpty) {
        await _deleteStaleImages(staleModels);
        await db.delete(
          'models',
          where: "id IN ($placeholders)",
          whereArgs: idsToDelete,
        );
      }

      final remainingIds =
          preservedIds.where((id) => downloadedModelIds.contains(id)).toList();
      await prefs.setStringList(_prefsKeyPreservedStaleModelIds, remainingIds);
    } catch (e) {
      debugPrint(
          "[ModelRepository] Error while cleaning preserved stale models: $e");
    }
  }

  /// Deletes cached images associated with a list of stale models.
  Future<void> _deleteStaleImages(
      List<Map<String, dynamic>> staleModels) async {
    final cachedPaths = await ModelImageCache.loadPaths();
    final List<String> idsToRemoveFromImageCache = [];

    for (final modelMap in staleModels) {
      final modelId = modelMap['id'] as String;
      final rawJson = json.decode(modelMap['raw_json'] as String);
      final imagePath = rawJson['imagePath'] as String?;

      if (imagePath != null && !imagePath.startsWith('assets/')) {
        final fileToDeletePath = cachedPaths[modelId];
        if (fileToDeletePath != null) {
          final file = File(fileToDeletePath);
          if (await file.exists()) {
            try {
              if (await file.exists()) {
                await file.delete();
              }
            } catch (e) {
              debugPrint(
                  "[ModelRepository] Error deleting stale image file: $e");
            }
          }
        }
        idsToRemoveFromImageCache.add(modelId);
      }
    }

    if (idsToRemoveFromImageCache.isNotEmpty) {
      await ModelImageCache.remove(idsToRemoveFromImageCache);
    }
  }

  /// Downloads and caches model images from Firebase Storage.
  Future<void> _syncModelImages(List<Map<String, dynamic>> allModels,
      Map<String, String> localAssetMap) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final imageCacheDir = Directory(p.join(docsDir.path, 'model_images'));
    if (!await imageCacheDir.exists()) {
      await imageCacheDir.create(recursive: true);
    }

    final cachedImagePaths = await ModelImageCache.loadPaths();

    for (final modelData in allModels) {
      final modelId = modelData['id'] as String;
      final serverImagePath = modelData['imagePath'] as String?;
      final producer = modelData['producer'] as String? ?? '';
      final isCustomModel =
          modelId.startsWith('self_') || modelId.startsWith('local_');

      if (isCustomModel ||
          serverImagePath == null ||
          serverImagePath.startsWith('assets/')) {
        continue;
      }

      bool hasLocalAsset = false;
      final modelIdLower = modelId.toLowerCase();

      if (localAssetMap.containsKey(modelIdLower)) {
        hasLocalAsset = true;
      } else if (_findBestAssetMatch(modelId, localAssetMap) != null) {
        hasLocalAsset = true;
      } else if (_findBestAssetMatch(producer, localAssetMap) != null) {
        hasLocalAsset = true;
      }

      final bool needsDownload =
          !cachedImagePaths.containsKey(modelId) && !hasLocalAsset;

      if (needsDownload) {
        try {
          debugPrint(
              "[ModelRepository] Attempting to download image for '$modelId' from path: '$serverImagePath'");
          final result = await _functions
              .httpsCallable('getCoverDownloadUrl')
              .call({'filePath': serverImagePath});

          final signedUrl = result.data?['signedUrl'] as String?;
          if (signedUrl == null || signedUrl.isEmpty) {
            throw Exception(
                'Cloud Function returned null or empty signedUrl for $serverImagePath');
          }

          final response = await _dio.get<List<int>>(
            signedUrl,
            options: Options(responseType: ResponseType.bytes),
          );

          if (response.statusCode == 200 && response.data != null) {
            final fileName = p.basename(serverImagePath);
            final localFile = File(p.join(imageCacheDir.path, fileName));
            await localFile.writeAsBytes(response.data!);
            await ModelImageCache.add(modelId, localFile.path);
            debugPrint(
                "[ModelRepository] Successfully downloaded and cached image for '$modelId'.");
          } else {
            throw DioException(
              requestOptions: response.requestOptions,
              response: response,
              error:
                  'Failed image download for $signedUrl with status: ${response.statusCode}',
            );
          }
        } on FirebaseFunctionsException catch (e, s) {
          if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
            debugPrint(
                "[ModelRepository] A predictable network error ('${e.code}') occurred during image sync for '$modelId'. This is not a bug. Error: ${e.message}");
          } else {
            debugPrint(
                "[ModelRepository] An unexpected FirebaseFunctionsException occurred for '$modelId': ${e.code} - ${e.message}");
            FirebaseCrashlytics.instance.recordError(e, s,
                reason:
                    'Unexpected Firebase Functions error in image sync for $modelId');
          }
        } on DioException catch (e, s) {
          if (e.type == DioExceptionType.connectionError ||
              e.error is SocketException) {
            debugPrint(
                "[ModelRepository] A predictable network error occurred during image download for '$modelId'. This is not a bug. Error: $e");
          } else {
            debugPrint(
                "[ModelRepository] CRITICAL: Dio download failed for model '$modelId' image. Error: $e");
            FirebaseCrashlytics.instance.recordError(e, s,
                reason: 'Failed to download model image for $modelId with Dio');
          }
        } catch (e, s) {
          debugPrint(
              "[ModelRepository] An unexpected generic error occurred during image sync for '$modelId': $e");
          FirebaseCrashlytics.instance.recordError(e, s,
              reason: 'Unexpected generic failure in image sync for $modelId');
        }
      }
    }
  }

  // --- STATIC PARSING HELPERS (ISOLATE-READY) ---

  /// Static entry point for the isolate to parse server data.
  static List<Map<String, dynamic>> _parseServerDataIsolate(
      Map<String, dynamic> params) {
    final rawData = params['data'] as Map<String, dynamic>;
    final langCode = params['langCode'] as String;
    return _staticParseAndGroupServerModels(rawData, langCode);
  }

  static List<Map<String, dynamic>> _staticParseAndGroupServerModels(
      Map<String, dynamic> rawData, String langCode) {
    final List<Map<String, dynamic>> finalList = [];
    final producers = rawData['producers'] != null
        ? Map<String, dynamic>.from(rawData['producers'] as Map)
        : <String, dynamic>{};

    producers.forEach((producerName, seriesData) {
      if (seriesData is! Map) return;
      final seriesDataMap = Map<String, dynamic>.from(seriesData);
      seriesDataMap.forEach((seriesName, seriesValue) {
        if (seriesValue is! Map) return;
        final seriesValueMap = Map<String, dynamic>.from(seriesValue);

        final cleanSeriesValue = _staticSanitizeRawData(seriesValueMap);

        final variantsMap = Map<String, dynamic>.from(cleanSeriesValue)
          ..remove('series_description');
        if (variantsMap.isEmpty) return;

        final model =
            (variantsMap.length == 1 && variantsMap.containsKey('Default'))
                ? _staticParseSingleVariantModel(
                    seriesName, producerName, variantsMap['Default'], langCode)
                : _staticParseMultiVariantSeries(
                    seriesName, producerName, cleanSeriesValue, langCode);

        if (model != null) finalList.add(model);
      });
    });
    return finalList;
  }

  static Map<String, dynamic>? _staticParseSingleVariantModel(String seriesName,
      String producerName, Map<String, dynamic> variantData, String langCode) {
    final cleanVariantData = _staticSanitizeRawData(variantData);

    final modelId = cleanVariantData['id'] as String? ?? seriesName;
    final details = _safeStringKeyMap(cleanVariantData['details']);
    final englishDetails = _safeStringKeyMap(details['en']);

    String modelCategory = cleanVariantData['category']?.toString() ??
        cleanVariantData['type']?.toString() ??
        'online';

    final outputs = cleanVariantData['outputs'] as Map<String, dynamic>? ?? {};
    if (outputs['video'] == true) {
      modelCategory = 'video';
    } else if (outputs['image'] == true) {
      modelCategory = 'image';
    } else if (outputs['audio'] == true) {
      modelCategory = 'audio';
    }

    final bool isLocalized = (_normalizedLangCode(langCode) == 'en') ||
        (_hasLocalizedDetail(details, langCode, 'title') &&
            _hasLocalizedDetail(details, langCode, 'summary') &&
            _hasLocalizedDetail(details, langCode, 'description') &&
            _hasLocalizedDetail(details, langCode, 'role'));

    // Check if the single variant is Lyria, instead of Google
    String finalSeriesName = seriesName;
    String finalTitle = _localizedDetail(details, langCode, 'title') ??
        englishDetails['title']?.toString() ??
        seriesName;

    if (modelId.toLowerCase().contains('lyria')) {
      finalSeriesName = 'Lyria';
      if (!finalTitle.toLowerCase().contains('lyria')) {
        finalTitle = 'Lyria';
      }
    }

    return {
      ...cleanVariantData,
      'id': modelId,
      'series': finalSeriesName,
      'title': finalTitle,
      'producer': producerName,
      'type': cleanVariantData['type'] ?? 'online',
      'size': cleanVariantData['size'],
      'ram': cleanVariantData['ram'],
      'category': modelCategory,
      'summary': _localizedDetail(details, langCode, 'summary') ??
          englishDetails['summary']?.toString() ??
          '',
      'description': _localizedDetail(details, langCode, 'description') ??
          englishDetails['description']?.toString() ??
          '',
      'role': _localizedDetail(details, langCode, 'role') ??
          englishDetails['role']?.toString(),
      'isFullyLocalized': isLocalized,
    };
  }

  static Map<String, dynamic>? _staticParseMultiVariantSeries(String seriesName,
      String producerName, Map<String, dynamic> seriesValue, String langCode) {
    final cleanSeriesValue = _staticSanitizeRawData(seriesValue);

    final seriesDetails =
        _safeStringKeyMap(cleanSeriesValue['series_description']);

    final localizedSeriesSummary =
        _localizedString(seriesDetails, langCode) ?? '';

    final bool isSeriesLocalized = (_normalizedLangCode(langCode) == 'en') ||
        _hasLocalizedString(seriesDetails, langCode);

    final variantsMap = Map<String, dynamic>.from(cleanSeriesValue)
      ..remove('series_description')
      ..remove('featureReasoning');
    if (variantsMap.isEmpty) return null;

    final variants = <String, dynamic>{};
    variantsMap.forEach((variantKey, variantData) {
      if (variantData is! Map<String, dynamic>) return;

      final cleanVariantData = _staticSanitizeRawData(variantData);

      final descriptionMap = _safeStringKeyMap(cleanVariantData['description']);

      final localizedVariantDescription =
          _localizedString(descriptionMap, langCode) ?? '';

      final bool isVariantLocalized = (_normalizedLangCode(langCode) == 'en') ||
          _hasLocalizedString(descriptionMap, langCode);

      variants[cleanVariantData['id'] as String] = {
        ...cleanVariantData,
        'id': cleanVariantData['id'],
        'title': cleanVariantData['title'] ?? variantKey,
        'summary': localizedSeriesSummary,
        'description': localizedVariantDescription,
        'isFullyLocalized': isVariantLocalized,
      };
    });

    if (variants.isEmpty) return null;

    // Check if any variant indicates this is actually the Lyria series
    // instead of the general Google series.
    String finalSeriesName = seriesName;
    String finalTitle = cleanSeriesValue['title'] ?? seriesName;

    if (variants.keys.any((id) => id.toLowerCase().contains('lyria'))) {
      finalSeriesName = 'Lyria';
      finalTitle = 'Lyria';
    }

    final firstVariant = variants.values.first as Map<String, dynamic>;
    final inferredType =
        cleanSeriesValue['type'] ?? firstVariant['type'] ?? 'online';

    String inferredCategory = cleanSeriesValue['category'] ??
        firstVariant['category'] ??
        inferredType;
    final outputs = firstVariant['outputs'] as Map<String, dynamic>? ?? {};

    if (outputs['video'] == true) {
      inferredCategory = 'video';
    } else if (outputs['image'] == true) {
      inferredCategory = 'image';
    } else if (outputs['audio'] == true) {
      inferredCategory = 'audio';
    }

    return {
      ...cleanSeriesValue,
      'id': finalSeriesName.toLowerCase().replaceAll(' ', '-'),
      'series': finalSeriesName,
      'title': finalTitle,
      'producer': producerName,
      'type': inferredType,
      'size': firstVariant['size'],
      'ram': firstVariant['ram'],
      'category': inferredCategory,
      'summary': localizedSeriesSummary,
      'description': localizedSeriesSummary,
      'variants': variants,
      'isFullyLocalized': isSeriesLocalized,
    };
  }

  static Map<String, dynamic> _staticSanitizeRawData(
      Map<String, dynamic> source) {
    final Map<String, dynamic> cleanMap = Map<String, dynamic>.from(source);

    cleanMap.remove('processing_status');
    cleanMap.remove('last_syncer_run');
    cleanMap.remove('cumulativeFailureCount');

    cleanMap.removeWhere(
        (key, value) => key.endsWith('_source_hash') || key.endsWith('_audit'));

    for (final key in cleanMap.keys.toList()) {
      final value = cleanMap[key];
      if (value is Map) {
        cleanMap[key] =
            _staticSanitizeRawData(Map<String, dynamic>.from(value));
      }
    }

    return cleanMap;
  }

  static String _normalizedLangCode(String langCode) =>
      langCode.split(RegExp(r'[-_]')).first.toLowerCase();

  static List<String> _languageFallbackKeys(String langCode) {
    final normalized = _normalizedLangCode(langCode);
    final keys = <String>[
      normalized,
      if (normalized == 'zh') 'cn',
      if (normalized == 'cn') 'zh',
      'en',
    ];
    return keys.toSet().toList();
  }

  static Map<String, dynamic> _safeStringKeyMap(dynamic value) {
    if (value is! Map) return {};
    return Map<String, dynamic>.from(value);
  }

  static String? _localizedDetail(
    Map<String, dynamic> details,
    String langCode,
    String field,
  ) {
    for (final key in _languageFallbackKeys(langCode)) {
      final localizedDetails = _safeStringKeyMap(details[key]);
      final value = localizedDetails[field]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static bool _hasLocalizedDetail(
    Map<String, dynamic> details,
    String langCode,
    String field,
  ) {
    final normalized = _normalizedLangCode(langCode);
    final keys = <String>[
      normalized,
      if (normalized == 'zh') 'cn',
      if (normalized == 'cn') 'zh',
    ];

    for (final key in keys.toSet()) {
      final localizedDetails = _safeStringKeyMap(details[key]);
      final value = localizedDetails[field]?.toString().trim();
      if (value != null && value.isNotEmpty) return true;
    }
    return false;
  }

  static String? _localizedString(
    Map<String, dynamic> localizedContainer,
    String langCode,
  ) {
    for (final key in _languageFallbackKeys(langCode)) {
      final value = localizedContainer[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static bool _hasLocalizedString(
    Map<String, dynamic> localizedContainer,
    String langCode,
  ) {
    final normalized = _normalizedLangCode(langCode);
    final keys = <String>[
      normalized,
      if (normalized == 'zh') 'cn',
      if (normalized == 'cn') 'zh',
    ];

    for (final key in keys.toSet()) {
      final value = localizedContainer[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return true;
    }
    return false;
  }

  // --- PERSISTENCE HELPERS ---

  /// Finds the best possible asset path by checking if a model identifier contains
  /// any of the keys from the asset map. It prioritizes longer matches.
  String? _findBestAssetMatch(
      String modelIdentifier, Map<String, String> localAssetMap) {
    String? bestMatchKey;
    final identifier = modelIdentifier.toLowerCase();

    // Loop through all keys in our asset map.
    for (final assetKey in localAssetMap.keys) {
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
    return bestMatchKey != null ? localAssetMap[bestMatchKey] : null;
  }

  Future<void> _updateLastSyncState(String langCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _prefsKeyLastSync, DateTime.now().toIso8601String());
      await prefs.setString(_prefsKeyLastSyncLang, langCode);
    } catch (e) {
      debugPrint("[ModelRepository] Error saving sync state: $e");
    }
  }
}
