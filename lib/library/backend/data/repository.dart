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
import 'defaults.dart';
import 'package:cortex/library/backend/data/crypto.dart';
import 'package:cortex/library/backend/data/database.dart';
import 'package:cortex/library/backend/data/image.dart';
import 'package:cortex/library/backend/data/user.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:sqflite/sqflite.dart';
import '../security.dart';

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

  // Transient-failure backoff for automatic catalog sync attempts.
  //
  // The catalog GET itself is the only authoritative reachability signal, so
  // when the host is unreachable every warranted sync must actually try the
  // fetch. To keep an empty database (or a stale cache) from hammering the
  // endpoint on every pipeline run, automatic attempts back off
  // exponentially starting at [_syncRetryBackoffBase] and capped at
  // [_syncRetryBackoffCap]. The explicit user Retry action bypasses the
  // backoff entirely (see [forceSyncOnNextLoad]). The state is deliberately
  // session-scoped: a fresh app session always gets one immediate attempt,
  // and any success resets it, so a temporary failure can never permanently
  // prevent future synchronization.
  static const Duration _syncRetryBackoffBase = Duration(seconds: 30);
  static const Duration _syncRetryBackoffCap = Duration(minutes: 10);

  /// Timestamp of the last failed catalog fetch attempt, if any.
  DateTime? _lastSyncFailureAt;

  /// Consecutive failed catalog fetches since the last success.
  int _consecutiveSyncFailures = 0;

  /// Set by the explicit user Retry action so the next initialization pass
  /// bypasses the transient backoff and attempts the real catalog fetch
  /// immediately.
  bool _forceNextSyncAttempt = false;

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
  ModelRepository({required this._dio});

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
      try {
        await _syncCompleter!.future;
      } catch (_) {
        return _rawModelsCache;
      }
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
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'ModelRepository initialization failure in _syncCompleter',
      );
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

      final rawJsonString = results.first['raw_json']?.toString() ?? '';
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

        try {
          updatedJsonData = json.decode(decryptedJson);
        } catch (_) {
          throw Exception("Failed to parse decrypted JSON for '$modelId'.");
        }
        updatedJsonData['baseModelId'] = newBaseModelId;
        finalJsonToSave =
            CryptoHelper.encrypt(json.encode(updatedJsonData), currentUser.uid);
      } else {
        try {
          updatedJsonData = json.decode(rawJsonString);
        } catch (_) {
          throw Exception("Failed to parse raw JSON for '$modelId'.");
        }
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

  /// Marks the next initialization pass to bypass the transient-failure
  /// backoff. Used by the explicit user Retry action on the library error
  /// screen: a user pressing Retry should always get a real catalog fetch
  /// attempt, regardless of how recently an automatic attempt failed.
  void forceSyncOnNextLoad() {
    _forceNextSyncAttempt = true;
    debugPrint(
        "[ModelRepository] Next sync attempt will bypass the transient backoff (explicit retry).");
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
    final isLangChanged =
        lastSyncLangCode != null && lastSyncLangCode != langCode;

    // The catalog GET itself is the only authoritative reachability signal.
    // HEAD probes and generic third-party host checks (one.one.one.one,
    // icanhazip.com...) can both succeed while the real fetch fails — WAFs,
    // proxies and carrier networks frequently treat HEAD and GET
    // differently — and a passing probe proves nothing about the subsequent
    // fetch. So when a sync is warranted we simply attempt the real fetch
    // directly and classify its actual failure (DNS, timeout, TLS, HTTP
    // status, parsing). A transient backoff keeps an unreachable endpoint
    // from being hammered by repeated pipeline runs; the explicit user Retry
    // action bypasses it (see [forceSyncOnNextLoad]).
    final syncRequired = isSyncRequired(
      isDbEmpty: isDbEmpty,
      isCacheStale: isCacheStale,
      isLangChanged: isLangChanged,
    );

    final bool forced = _forceNextSyncAttempt;
    _forceNextSyncAttempt = false;

    bool syncSucceeded = false;
    bool attemptedSync = false;
    if (syncRequired) {
      final bool backoffElapsed = isBackoffElapsed(
        lastFailureAt: _lastSyncFailureAt,
        consecutiveFailures: _consecutiveSyncFailures,
        now: DateTime.now(),
      );

      if (forced || backoffElapsed) {
        if (forced) {
          debugPrint(
              "[ModelRepository] Explicit retry: bypassing transient backoff after $_consecutiveSyncFailures consecutive failure(s).");
        }
        attemptedSync = true;
        debugPrint(
            "[ModelRepository] Sync required (DB empty: $isDbEmpty, stale: $isCacheStale, lang changed: $isLangChanged). Attempting the real catalog fetch.");
        syncSucceeded = await _syncWithServer(langCode, isCritical: isDbEmpty);

        if (syncSucceeded) {
          _lastSyncFailureAt = null;
          _consecutiveSyncFailures = 0;
        } else {
          _lastSyncFailureAt = DateTime.now();
          _consecutiveSyncFailures++;
          final backoff =
              syncRetryBackoff(consecutiveFailures: _consecutiveSyncFailures);
          debugPrint(
              "[ModelRepository] Catalog fetch failed ($_consecutiveSyncFailures consecutive failure(s)). Backing off for $backoff before the next automatic attempt.");
        }
      } else {
        debugPrint(
            "[ModelRepository] Sync required, but the catalog host failed recently ($_consecutiveSyncFailures consecutive failure(s)) and the transient backoff has not elapsed. Serving local data; the next automatic attempt retries after the backoff window.");
      }
    } else {
      debugPrint("[ModelRepository] Sync not required. Loading from local DB.");
    }

    final mapsFromDb =
        await _dbHelper.getAllModels(userId: _auth.currentUser?.uid);

    // A failed sync with an empty database must NOT be memoized as an empty
    // raw cache: `[]` would make every subsequent [getAllModels] call return
    // the empty list instantly without any network attempt, leaving the
    // library stuck on the error screen until a call path that happens to
    // clear the cache runs. Keeping the cache unset lets the next call
    // (retry button, tab revisit, language change, chat flow) re-run the
    // pipeline and recover as soon as the catalog is reachable.
    if (shouldMemoizeRawCache(dbHasModels: mapsFromDb.isNotEmpty)) {
      _rawModelsCache = mapsFromDb;
      debugPrint(
          "[ModelRepository] Raw cache initialized with ${_rawModelsCache?.length ?? 0} models from database.");
    } else {
      _rawModelsCache = null;
      debugPrint(
          "[ModelRepository] Database is empty (sync completed: $syncSucceeded). Raw cache left unset so the next attempt can retry.");
    }

    // Image sync only does meaningful network work when it is likely to
    // succeed: right after a successful catalog fetch (network proven) or
    // when no fetch was attempted at all (fresh local data; missing images
    // are rare and each download is individually guarded). Directly after a
    // failed fetch the network is probably unavailable, so the extra image
    // requests are skipped instead of stalling the pipeline.
    if (_rawModelsCache != null && (syncSucceeded || !attemptedSync)) {
      await _syncModelImages(_rawModelsCache!, localAssetMap);

      // After image sync is complete, invalidate the in-memory cache of image paths.
      // This forces the ModelService to re-load the fresh data from persistent storage
      // instead of using a stale in-memory version.
      ModelImageCache.invalidateInMemoryCache();
      debugPrint(
          "[ModelRepository] Invalidated image path cache to force a fresh read.");
    }
  }

  /// Pure decision rule for whether a network sync is warranted.
  ///
  /// Deliberately free of any connectivity-probe input: reachability is
  /// determined by attempting the real catalog fetch — probe results (HEAD
  /// requests or third-party hosts) do not predict whether the GET will
  /// succeed. A sync is warranted when the catalog is absent (empty DB),
  /// stale, or the display language changed; whether the warranted attempt
  /// actually reaches the network is then a matter of the transient backoff
  /// (see [isBackoffElapsed]).
  @visibleForTesting
  static bool isSyncRequired({
    required bool isDbEmpty,
    required bool isCacheStale,
    required bool isLangChanged,
  }) =>
      isDbEmpty || isCacheStale || isLangChanged;

  /// Exponential backoff applied to automatic catalog fetch attempts after
  /// [consecutiveFailures] consecutive failures. Starts at 30 seconds,
  /// doubles per failure and is capped at 10 minutes, so an unreachable
  /// catalog host is retried at a bounded rate while recovery stays fast.
  /// The explicit user Retry action bypasses this schedule entirely.
  @visibleForTesting
  static Duration syncRetryBackoff({required int consecutiveFailures}) {
    if (consecutiveFailures <= 0) return Duration.zero;
    // base * 2^(n-1): 30s, 1m, 2m, 4m, 8m, then capped at 10m. The shift is
    // clamped so a large failure counter can never overflow.
    final int exp = consecutiveFailures - 1;
    if (exp > 4) return _syncRetryBackoffCap;
    final Duration backoff = _syncRetryBackoffBase * (1 << exp);
    return backoff > _syncRetryBackoffCap ? _syncRetryBackoffCap : backoff;
  }

  /// Pure decision rule for whether the transient backoff still blocks a
  /// new automatic fetch attempt. True (attempt allowed) when no failure is
  /// recorded or the backoff window has fully elapsed.
  @visibleForTesting
  static bool isBackoffElapsed({
    required DateTime? lastFailureAt,
    required int consecutiveFailures,
    required DateTime now,
  }) {
    if (lastFailureAt == null || consecutiveFailures <= 0) return true;
    return now.difference(lastFailureAt) >=
        syncRetryBackoff(consecutiveFailures: consecutiveFailures);
  }

  /// Pure decision rule preventing an empty database result from being
  /// memoized as the session's raw cache. Memoizing `[]` (after a failed or
  /// pathologically empty sync) makes every subsequent [getAllModels] call
  /// return the empty list instantly without any network attempt, leaving
  /// the library dead-ended on the error screen. Only a populated database
  /// may be memoized.
  @visibleForTesting
  static bool shouldMemoizeRawCache({required bool dbHasModels}) =>
      dbHasModels;

  /// Manages the full server synchronization flow.
  ///
  /// Returns true only when the catalog was fetched, validated and stored
  /// completely. Returns false when the fetch was rejected or failed, letting
  /// the caller decide how to treat a possibly-empty database. Never throws:
  /// an orchestration failure must not turn a usable local catalog into a
  /// dead-end error screen.
  Future<bool> _syncWithServer(String langCode,
      {required bool isCritical}) async {
    debugPrint("[ModelRepository] Starting full model sync with server...");
    try {
      final validPublicIds = await _fetchAndStorePublicModels(langCode,
          isCritical: isCritical);
      if (validPublicIds == null) {
        debugPrint(
            "[ModelRepository] Server sync was rejected or incomplete. Preserving local catalog and last-sync state.");
        return false;
      }

      debugPrint(
          "[ModelRepository] Public model sync complete. Found ${validPublicIds.length} valid IDs.");

      await _cleanupStaleModels(validPublicIds);

      await _updateLastSyncState(langCode);
      debugPrint("[ModelRepository] Sync process fully complete.");
      return true;
    } catch (e, s) {
      debugPrint(
          "[ModelRepository] CRITICAL ERROR during sync orchestration: $e\n$s");
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'ModelRepository sync orchestration failure');
      return false;
    }
  }

  /// Central diagnostics for catalog sync failures.
  ///
  /// Every failure mode leaves a Crashlytics breadcrumb, and when the failure
  /// is critical (the local database is empty, so the user is stuck on the
  /// "could not load" screen) a non-fatal error is recorded with a precise,
  /// machine-readable mode. This makes device/network-specific catalog
  /// failures (carrier filtering, DNS quirks, TLS interception, WAF
  /// challenges, captive portals...) visible in production instead of only
  /// in debugPrint.
  void _reportSyncFailure(String mode,
      {Object? error,
      StackTrace? stack,
      required bool critical,
      bool alwaysRecord = false}) {
    final description = error == null ? mode : '$mode ($error)';
    debugPrint("[ModelRepository] Model sync failure: $description");
    FirebaseCrashlytics.instance.log('ModelCatalogSync failed: $description');
    if (critical || alwaysRecord) {
      FirebaseCrashlytics.instance.recordError(
        error ?? Exception('ModelCatalogSyncFailed:$mode'),
        stack ?? StackTrace.current,
        reason: 'ModelCatalogSyncFailed:$mode',
        fatal: false,
      );
    }
  }

  /// Fetches the public model list from the remote server.
  ///
  /// Returns null when the remote response cannot be trusted as a complete,
  /// successful catalog. Null prevents stale cleanup and prevents the client from
  /// advancing its last-successful-sync timestamp.
  ///
  /// [isCritical] marks that the local database is empty, meaning the caller
  /// has nothing to fall back on and the user would see the library error
  /// screen; such failures are reported to Crashlytics with their exact mode.
  Future<Set<String>?> _fetchAndStorePublicModels(String langCode,
      {required bool isCritical}) async {
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
        _reportSyncFailure('http_${response.statusCode}', critical: isCritical);
        return null;
      }

      if (response.data == null) {
        debugPrint("[ModelRepository] Server returned empty data.");
        _reportSyncFailure('empty_body', critical: isCritical);
        return null;
      }

      final rawServerData = response.data!;

      debugPrint(
          "[ModelRepository] Parsing server data into per-variant rows in background isolate...");
      final parsedServerRows = await compute(
        _parseServerDataIsolate,
        {'data': rawServerData, 'langCode': langCode},
      );

      if (parsedServerRows.isEmpty) {
        debugPrint(
            "[ModelRepository] Parsed catalog is empty. Treating response as incomplete.");
        _reportSyncFailure('empty_catalog', critical: isCritical);
        return null;
      }

      final parsedFallbackRows = await compute(
        _parseServerDataIsolate,
        {
          'data': {'producers': rawServerData['fallback'] ?? {}},
          'langCode': langCode
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fallback', json.encode(parsedFallbackRows));

      // Filter out local/custom IDs and malformed entries. A remote catalog must
      // never impersonate user-created/local model namespaces.
      final modelsToInsert = parsedServerRows.where((modelData) {
        final id = modelData['id']?.toString().trim() ?? '';
        return id.isNotEmpty &&
            !id.startsWith('self_') &&
            !id.startsWith('local_');
      }).toList();

      if (modelsToInsert.isEmpty) {
        debugPrint(
            "[ModelRepository] No valid public models remained after validation.");
        _reportSyncFailure('no_valid_public_models', critical: isCritical);
        return null;
      }

      final currentModels =
          await _dbHelper.getAllModels(userId: _auth.currentUser?.uid);
      final existingPublicCount = currentModels.where((model) {
        final id = model['id']?.toString() ?? '';
        return id.isNotEmpty &&
            !id.startsWith('self_') &&
            !id.startsWith('local_');
      }).length;

      if (!ModelSecurity.isPlausibleCatalogReplacement(
        existingCount: existingPublicCount,
        incomingCount: modelsToInsert.length,
      )) {
        debugPrint(
            "[ModelRepository] Catalog shrink guard rejected ${modelsToInsert.length} incoming models against $existingPublicCount existing public models.");
        _reportSyncFailure('catalog_shrink_guard', critical: isCritical);
        return null;
      }

      final validServerIds = modelsToInsert
          .map((model) => model['id']?.toString().trim() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      var writeFailed = false;
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
            await Future.delayed(Duration.zero);
          } catch (e) {
            if (e.toString().contains("SQLITE_FULL")) {
              debugPrint(
                  "[ModelRepository] DISK FULL. Aborting model sync save without advancing sync state.");
              writeFailed = true;
              break;
            } else {
              rethrow;
            }
          }
        }
      }

      if (writeFailed) {
        _reportSyncFailure('disk_full', critical: isCritical);
        return null;
      }

      await Future.delayed(const Duration(milliseconds: 100));
      await _dbHelper.optimizeDatabase();

      return validServerIds;
    } on DioException catch (e, s) {
      // Server-side failures (5xx). validateStatus lets these throw while
      // non-5xx responses pass through to the status check above, so every
      // rejected-by-server outcome lands here or in the 200-only check.
      final status = e.response?.statusCode;
      if (status != null && status >= 500) {
        if (status == 500) {
          debugPrint(
              "[ModelRepository] Server Error (500). Using local cache instead.");
          _reportSyncFailure('server_500', error: e, critical: isCritical);
        } else {
          debugPrint(
              "[ModelRepository] Server Error ($status). Using local cache instead.");
          _reportSyncFailure('http_$status', error: e, critical: isCritical);
        }
        return null;
      }

      final errorString = e.toString();
      if (errorString.contains("CERTIFICATE_VERIFY_FAILED") ||
          errorString.contains("HandshakeException")) {
        debugPrint(
            "[ModelRepository] SSL/Certificate Error detected (Likely user network issue). Using local cache.");
        _reportSyncFailure('tls_certificate',
            error: e.error ?? e.message, stack: s, critical: isCritical);
        return null;
      }

      // Fine-grained network classification so production Crashlytics
      // records pinpoint the exact layer that failed on device-specific
      // networks: timeouts, DNS resolution, low-level socket errors, and
      // generic connection failures.
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint(
            "[ModelRepository] Network timeout (${e.type}). Using local cache.");
        _reportSyncFailure('network_timeout',
            error: e.error ?? e.message, stack: s, critical: isCritical);
        return null;
      }

      if (e.error is SocketException) {
        final socketMessage = (e.error as SocketException).toString();
        if (socketMessage.contains('Failed host lookup')) {
          debugPrint(
              "[ModelRepository] DNS lookup for the catalog host failed. Using local cache.");
          _reportSyncFailure('dns_lookup_failed',
              error: e.error, stack: s, critical: isCritical);
        } else {
          debugPrint(
              "[ModelRepository] Socket error during catalog fetch. Using local cache.");
          _reportSyncFailure('network_socket_error',
              error: e.error, stack: s, critical: isCritical);
        }
        return null;
      }

      if (e.type == DioExceptionType.connectionError) {
        debugPrint(
            "[ModelRepository] Connection error during catalog fetch. Using local cache.");
        _reportSyncFailure('network_connection_error',
            error: e.error ?? e.message, stack: s, critical: isCritical);
        return null;
      }

      debugPrint("[ModelRepository] Unexpected DioException: $e");
      _reportSyncFailure('unexpected_dio_${e.type.name}',
          error: e, stack: s, critical: isCritical, alwaysRecord: true);
      return null;
    } catch (e, s) {
      debugPrint("[ModelRepository] Generic error: $e");
      // Captures malformed responses (e.g. a captive portal answering with
      // an HTML page), type errors and any other non-network failure.
      _reportSyncFailure('parse_or_unexpected',
          error: e, stack: s, critical: isCritical, alwaysRecord: true);
      return null;
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

      // SQLite host implementations cap bind-variable counts (999 on the
      // system SQLite shipped with older Android releases), so the valid-ID
      // list is applied in chunks.
      const int idChunkSize = 500;
      final validIds = validPublicIds.toList();

      final candidateIds = <String>{};
      for (var i = 0; i < validIds.length; i += idChunkSize) {
        final end = (i + idChunkSize < validIds.length)
            ? i + idChunkSize
            : validIds.length;
        final chunk = validIds.sublist(i, end);
        final placeholders = List.filled(chunk.length, '?').join(',');

        final chunkRows = await db.query(
          'models',
          columns: ['id'],
          where:
              "id NOT IN ($placeholders) AND id NOT LIKE 'self_%' AND id NOT LIKE 'local_%'",
          whereArgs: chunk,
        );
        for (final row in chunkRows) {
          candidateIds.add(row['id'] as String);
        }
      }

      // A row that is part of a later chunk's valid-ID list is not stale;
      // the per-chunk NOT IN query cannot know that by itself.
      final staleIds =
          candidateIds.where((id) => !validPublicIds.contains(id)).toList();
      if (staleIds.isEmpty) return;

      final allStaleModels = <Map<String, dynamic>>[];
      for (var i = 0; i < staleIds.length; i += idChunkSize) {
        final end = (i + idChunkSize < staleIds.length)
            ? i + idChunkSize
            : staleIds.length;
        final chunk = staleIds.sublist(i, end);
        final placeholders = List.filled(chunk.length, '?').join(',');
        allStaleModels.addAll(await db.query(
          'models',
          columns: ['id', 'raw_json'],
          where: "id IN ($placeholders)",
          whereArgs: chunk,
        ));
      }

      if (allStaleModels.isEmpty) return;

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

      var deletedCount = 0;
      for (var i = 0; i < staleModelIds.length; i += idChunkSize) {
        final end = (i + idChunkSize < staleModelIds.length)
            ? i + idChunkSize
            : staleModelIds.length;
        final chunk = staleModelIds.sublist(i, end);
        final placeholders = List.filled(chunk.length, '?').join(',');
        deletedCount += await db.delete(
          'models',
          where: "id IN ($placeholders)",
          whereArgs: chunk,
        );
      }
      debugPrint(
          "[ModelRepository] Cleaned up $deletedCount stale models from database.");
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
      Map<String, dynamic> rawJson;
      try {
        rawJson = json.decode(modelMap['raw_json'] as String);
      } catch (_) {
        continue;
      }
      final imagePath = rawJson['imagePath'] as String?;

      if (imagePath != null && !imagePath.startsWith('assets/')) {
        final fileToDeletePath = cachedPaths[modelId];
        if (fileToDeletePath != null) {
          final file = File(fileToDeletePath);
          if (await file.exists()) {
            try {
              await file.delete();
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
  ///
  /// Returns the flat per-variant records that are persisted. Family
  /// presentation containers are rebuilt at read time by
  /// [ModelDefaults.normalizeModelFamilies]; persisting the containers
  /// themselves produced rows far larger than Android's 2 MB CursorWindow.
  static List<Map<String, dynamic>> _parseServerDataIsolate(
      Map<String, dynamic> params) {
    final rawData = params['data'] as Map<String, dynamic>;
    final langCode = params['langCode'] as String;
    return parseServerModelRows(rawData, langCode);
  }

  /// Parses the wire catalog into the family containers the UI consumes.
  ///
  /// Composition of [parseServerModelRows] plus the two presentation-only
  /// steps: family grouping and duplicate-ID disambiguation. This is the
  /// wire-contract surface used by tests; persistence stores the rows.
  @visibleForTesting
  static List<Map<String, dynamic>> parseServerModels(
          Map<String, dynamic> rawData, String langCode) =>
      ModelSecurity.disambiguateDuplicateModelIds(
        ModelDefaults.normalizeModelFamilies(
          parseServerModelRows(rawData, langCode),
        ),
      );

  /// Parses the wire catalog into flat records, one per variant entry.
  ///
  /// The wire format nests variant entries under
  /// `producers -> producer -> series -> variant`, and each series carries
  /// shared presentation metadata. A record merges that series-level
  /// metadata (scalars only — sibling variant maps are never duplicated
  /// into records) with one parsed variant entry.
  ///
  /// Records are what gets persisted: each stays a few KB no matter how
  /// many variants a family spans, so a query can never return a row too
  /// big for Android's 2 MB CursorWindow, while read-time normalization
  /// rebuilds exactly the same family containers the UI expects.
  @visibleForTesting
  static List<Map<String, dynamic>> parseServerModelRows(
      Map<String, dynamic> rawData, String langCode) {
    final rows = <Map<String, dynamic>>[];
    final producers = rawData['producers'] != null
        ? Map<String, dynamic>.from(rawData['producers'] as Map)
        : <String, dynamic>{};

    for (final producerEntry in producers.entries) {
      final producerName = producerEntry.key;
      final seriesData = producerEntry.value;
      if (seriesData is! Map) continue;
      final seriesDataMap = Map<String, dynamic>.from(seriesData);
      for (final seriesEntry in seriesDataMap.entries) {
        final seriesName = seriesEntry.key;
        final seriesValue = seriesEntry.value;
        if (seriesValue is! Map) continue;
        final seriesValueMap = Map<String, dynamic>.from(seriesValue);

        final cleanSeriesValue = _staticSanitizeRawData(seriesValueMap);

        final variantsMap = Map<String, dynamic>.from(cleanSeriesValue)
          ..remove('series_description');
        if (variantsMap.isEmpty) continue;

        if (variantsMap.length == 1 && variantsMap.containsKey('Default')) {
          final model = _staticParseSingleVariantModel(
              seriesName, producerName, variantsMap['Default'], langCode);
          if (model != null) rows.add(model);
        } else {
          rows.addAll(_staticParseSeriesVariantRows(
              seriesName, producerName, cleanSeriesValue, langCode));
        }
      }
    }
    return rows;
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

  /// Builds one record per variant of a multi-variant series.
  ///
  /// Every record shares the series' scalar metadata (so read-time family
  /// grouping still sees `series`, `producer`, `url`, ...) and carries one
  /// fully parsed variant. Map-valued series keys are sibling variant
  /// entries (or series descriptions) and are deliberately excluded —
  /// duplicating them into every record is what made legacy family rows
  /// grow quadratically with the variant count.
  static List<Map<String, dynamic>> _staticParseSeriesVariantRows(
      String seriesName,
      String producerName,
      Map<String, dynamic> cleanSeriesValue,
      String langCode) {
    final variantsMap = Map<String, dynamic>.from(cleanSeriesValue)
      ..remove('series_description')
      ..remove('featureReasoning');

    final seriesDetails =
        _safeStringKeyMap(cleanSeriesValue['series_description']);
    final localizedSeriesSummary =
        _localizedString(seriesDetails, langCode) ?? '';

    final parsedVariants = <Map<String, dynamic>>[];
    for (final variantEntry in variantsMap.entries) {
      final variantKey = variantEntry.key;
      final variantData = variantEntry.value;
      if (variantData is! Map<String, dynamic>) continue;

      final cleanVariantData = _staticSanitizeRawData(variantData);
      final variantId = cleanVariantData['id']?.toString().trim() ?? '';
      if (variantId.isEmpty) continue;

      final descriptionMap = _safeStringKeyMap(cleanVariantData['description']);
      final localizedVariantDescription =
          _localizedString(descriptionMap, langCode) ?? '';
      final bool isVariantLocalized = (_normalizedLangCode(langCode) == 'en') ||
          _hasLocalizedString(descriptionMap, langCode);

      parsedVariants.add({
        ...cleanVariantData,
        'id': variantId,
        'title': cleanVariantData['title'] ?? variantKey,
        'summary': localizedSeriesSummary,
        'description': localizedVariantDescription,
        'isFullyLocalized': isVariantLocalized,
      });
    }

    if (parsedVariants.isEmpty) return const [];

    // Check if any variant indicates this is actually the Lyria series
    // instead of the general Google series.
    final isLyriaSeries =
        parsedVariants.any((v) => '${v['id']}'.toLowerCase().contains('lyria'));

    final seriesMeta = <String, dynamic>{
      for (final entry in cleanSeriesValue.entries)
        if (entry.value is! Map) entry.key: entry.value,
      'series': isLyriaSeries ? 'Lyria' : seriesName,
      'producer': producerName,
    };

    return [
      for (final variant in parsedVariants)
        {...seriesMeta, ...variant}..remove('variants'),
    ];
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
    final seen = <String>{};
    final result = <String>[
      if (seen.add(normalized)) normalized,
      if (normalized == 'zh' && seen.add('cn')) 'cn',
      if (normalized == 'cn' && seen.add('zh')) 'zh',
      if (seen.add('en')) 'en',
    ];
    return result;
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