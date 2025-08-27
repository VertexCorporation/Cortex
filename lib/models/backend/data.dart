// data.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:retry/retry.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:crypto/crypto.dart';

// --- Data Models (These classes define the structure of the data) ---

/// Represents the compatibility status of an offline model.
enum CompatibilityStatus {
  compatible,
  insufficientRAM,
  insufficientStorage,
}

/// A structured representation of a model for use within the UI.
/// This is typically created from the raw Map<String, dynamic> data.
/// A structured representation of a model for use within the UI.
/// This is typically created from the raw Map<String, dynamic> data.
class ModelInfo {
  final String id;
  final String title;
  final String imagePath;
  final String producer;
  final String? path;
  final String? role;
  final Map<String, dynamic> modalities;
  final Map<String, dynamic> outputs;
  final String? category;
  final Map<String, dynamic>? extensions;
  final String? baseModelId;
  final int? size;
  final int? ram;

  ModelInfo({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.producer,
    this.path,
    this.role,
    this.modalities = const {},
    this.outputs = const {},
    this.category,
    this.extensions,
    this.baseModelId,
    this.size,
    this.ram,
  });
}

// --- NEW: Encryption Helper Class (Add this class to data.dart) ---
// This class centralizes all cryptographic operations for the app.
class CryptoHelper {
  // Generates a secure, fixed-length key from the user's UID.
  static enc.Key _generateKey(String userId) {
    final bytes = utf8.encode(userId); // Convert UID to bytes
    final digest = sha256.convert(bytes); // Hash it with SHA-256
    return enc.Key.fromBase64(base64.encode(digest.bytes)); // Use the 32-byte hash as the key
  }

  // Encrypts a plaintext string using the user's ID as the key source.
  // Returns a combined string of "IV:Ciphertext" for easy storage.
  static String? encrypt(String plainText, String userId) {
    try {
      final key = _generateKey(userId);
      final iv = enc.IV.fromLength(16); // Generate a random 16-byte IV
      final encrypter = enc.Encrypter(enc.AES(key));

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      // Combine IV and ciphertext into a single string for storage.
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      debugPrint("[CryptoHelper] Encryption failed: $e");
      return null;
    }
  }

  // Decrypts a combined "IV:Ciphertext" string using the user's ID.
  // Returns the original plaintext, or null if decryption fails.
  static String? decrypt(String combined, String userId) {
    try {
      // Split the combined string to get the IV and the ciphertext.
      final parts = combined.split(':');
      if (parts.length != 2) throw Exception("Invalid encrypted format.");

      final iv = enc.IV.fromBase64(parts[0]);
      final encryptedText = enc.Encrypted.fromBase64(parts[1]);

      final key = _generateKey(userId);
      final encrypter = enc.Encrypter(enc.AES(key));

      final decrypted = encrypter.decrypt(encryptedText, iv: iv);
      return decrypted;
    } catch (e) {
      // This catch block is expected to fire when trying to decrypt another user's data.
      debugPrint("[CryptoHelper] Decryption failed (likely wrong user key): $e");
      return null;
    }
  }
}

// --------------------------------------------------------------------------
// --- 1. LOCAL DATABASE HELPER (The App's Persistent Memory) ---
// --- Uses sqflite to persist the model list fetched from the server. ---
// --------------------------------------------------------------------------

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = p.join(await getDatabasesPath(), 'cortex_models_v2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  /// Creates the database table.
  /// Storing the raw JSON is a robust strategy. It makes the database schema
  /// resilient to future changes in the server's model data structure,
  /// preventing app crashes if the server adds new fields.
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE models (
        id TEXT PRIMARY KEY,        -- The unique series/model ID
        producer TEXT,              -- For filtering/sorting
        title TEXT,                 -- For display and sorting
        is_server_side INTEGER,     -- 0 for local/offline, 1 for online
        type TEXT,                  -- 'online', 'offline', 'roleplay'
        raw_json TEXT NOT NULL      -- Store the entire model object as JSON
      )
    ''');
  }

  /// REFACTORED: Inserts a new model, automatically encrypting user-created data.
  /// It now accepts an optional `userId` to perform encryption.
  Future<void> insert(String table, Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
    String? userId, // <-- NEW: User ID for encryption
  }) async {
    final db = await instance.database;
    final modelId = values['id'] as String?;
    final rawJson = values['raw_json'] as String?;

    // --- ENCRYPTION LOGIC ---
    // If it's a user-created model and we have a user ID, encrypt the data.
    if (userId != null && rawJson != null && (modelId?.startsWith('self_') == true || modelId?.startsWith('local_') == true)) {
      final encryptedJson = CryptoHelper.encrypt(rawJson, userId);
      if (encryptedJson != null) {
        values['raw_json'] = encryptedJson; // Replace raw JSON with encrypted data
        debugPrint("[DatabaseHelper] Encrypted data for model '$modelId'");
      } else {
        // Handle encryption failure if necessary, maybe throw an error
        debugPrint("[DatabaseHelper] CRITICAL: Failed to encrypt data for model '$modelId'");
        throw Exception("Encryption failed for model $modelId");
      }
    }

    await db.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
  }

  /// Deletes any models from the local DB that are not present in the provided set of IDs.
  Future<void> deleteModelsNotIn(Set<String> validIds) async {
    // (This function remains unchanged)
    if (validIds.isEmpty) return;
    final db = await instance.database;
    final placeholders = List.filled(validIds.length, '?').join(',');
    await db.delete(
      'models',
      where: 'id NOT IN ($placeholders)',
      whereArgs: validIds.toList(),
    );
  }

  /// Deletes all user-created models from the local database.
  Future<void> deleteUserCreatedModels() async {
    // (This function remains unchanged, though it's no longer our primary security method)
    final db = await instance.database;
    final count = await db.delete(
      'models',
      where: "id LIKE 'self_%' OR id LIKE 'local_%'",
    );
    debugPrint("[DatabaseHelper] Logout cleanup: Deleted $count user-created models to protect privacy.");
  }

  /// Deletes rows from the specified table based on a 'where' clause.
  Future<int> delete(String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    final count = await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
    debugPrint("[DatabaseHelper] Deleted $count rows from '$table' where: $where");
    return count;
  }

  /// REFACTORED: Retrieves all models, decrypting user-specific data.
  /// It now requires a `userId` to attempt decryption.
  Future<List<Map<String, dynamic>>> getAllModels({String? userId}) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps =
    await db.query('models', orderBy: 'title ASC');
    if (maps.isEmpty) return [];

    final List<Map<String, dynamic>> decodedModels = [];

    for (final map in maps) {
      final modelId = map['id'] as String;
      final rawJsonString = map['raw_json'] as String;

      // --- DECRYPTION LOGIC ---
      if (userId != null && (modelId.startsWith('self_') || modelId.startsWith('local_'))) {
        // This is a user-created model. Attempt to decrypt it.
        final decryptedJson = CryptoHelper.decrypt(rawJsonString, userId);
        if (decryptedJson != null) {
          // Success! This model belongs to the current user.
          decodedModels.add(json.decode(decryptedJson) as Map<String, dynamic>);
        } else {
          // Decryption failed. This model belongs to another user. Skip it.
          debugPrint("[DatabaseHelper] Skipped model '$modelId' as it belongs to another user.");
        }
      } else {
        // This is a public model. Decode it directly.
        decodedModels.add(json.decode(rawJsonString) as Map<String, dynamic>);
      }
    }

    return decodedModels;
  }
}

// --------------------------------------------------------------------------
// --- 2. USER STATE MANAGEMENT (For Downloaded Models) ---
// --- Uses SharedPreferences for simple key-value storage of user-specific data. ---
// --------------------------------------------------------------------------

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

// This keeps the logic clean and separate.
class _ModelImageCache {
  static const String _prefsKey = 'model_image_cache_paths';

// Loads the map of modelId -> localImagePath
  static Future<Map<String, String>> _loadPaths() async {
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
  static Future<void> _savePaths(Map<String, String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(paths));
  }

// Adds a single entry and saves
  static Future<void> add(String modelId, String localPath) async {
    final paths = await _loadPaths();
    paths[modelId] = localPath;
    await _savePaths(paths);
  }

  static Future<void> remove(Iterable<String> modelIds) async {
    if (modelIds.isEmpty) return;
    final paths = await _loadPaths();
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
    await _savePaths(paths);
  }
}

// --------------------------------------------------------------------------
// --- 3. MAIN DATA ORCHESTRATOR (The Brain of Data Handling) ---
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// --- 3. MAIN DATA ORCHESTRATOR (The Brain of Data Handling) ---
// --------------------------------------------------------------------------

class ModelData {
  // In-memory cache for the image paths to avoid frequent disk reads.
  static Map<String, String>? _cachedImagePaths;

  // In-memory cache for instant access after the first load.
  static List<Map<String, dynamic>>? _cachedModels;

  // Tracks the last successful sync time to decide when to refresh.
  static DateTime? _lastSyncTime;

  // --- FIX 1: Add a variable to track the language of the last sync ---
  static String? _lastSyncLangCode;

  // Configuration constants.
  static const Duration _cacheStaleDuration = Duration(hours: 1);
  static const String _prefsKeyLastSync = 'model_data_last_sync_timestamp';

  // --- FIX 2: Add a persistence key for the last sync language ---
  static const String _prefsKeyLastSyncLang = 'model_data_last_sync_lang';
  static const String _serverUrl =
      'https://syncer.mustawtfa.workers.dev/models.json';

  // This will ensure the synchronization logic runs only once, even if getModels is called multiple times.
  static Completer<void>? _syncCompleter;

  // Service singletons.
  static final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  static final Map<String, String> _localAssetImageMap = {
    // Offline
    'tinyllama': 'assets/models/offline/tinyllama.png',
    'gptneox': 'assets/models/offline/gptneox.jpg',
    'deepseekr1xqwen': 'assets/models/both/deepseek.jpg',
    // Online/Both
    'gemini': 'assets/models/online/gemini.png',
    'llama': 'assets/models/online/llama.png',
    'chatgpt': 'assets/models/online/chatgpt.jpg',
    'claude': 'assets/models/online/claude.jpg',
    'arcee-ai': 'assets/models/online/arcee.jpg',
    'cohere': 'assets/models/online/cohere.jpg',
    'codestral': 'assets/models/online/codestral.jpg',
    'ministral': 'assets/models/online/ministral.jpg',
    'mixtral': 'assets/models/online/mixtral.jpg',
    'hermes': 'assets/models/online/hermes.jpg',
    'grok': 'assets/models/online/grok.jpeg',
    'perplexity': 'assets/models/online/perplexity.jpg',
    'nova': 'assets/models/online/ministral.jpg',
    'wizardlm': 'assets/models/online/wizardlm.jpg',
    'mai': 'assets/models/online/mai.jpg',
    'codex': 'assets/models/online/codex.png',
    'deepseek': 'assets/models/both/deepseek.jpg',
    'mistral': 'assets/models/both/mistral.jpg',
    'phi': 'assets/models/both/phi.png',
    'jannano128k': 'assets/models/offline/jannano128k.jpg',
    'phi-4': 'assets/models/both/phi.png',
    'gemma': 'assets/models/both/gemma.jpg',
    'command': 'assets/models/online/cohere.jpg',
    'qwen': 'assets/models/both/qwen.png',
    // Roleplay
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
    'detective': 'assets/characters/detective.jpg'
  };

  static final List<VoidCallback> _listeners = [];

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
    debugPrint("[ModelData] Listener added. Total listeners: ${_listeners.length}");
  }

  static void _notifyListeners() {
    debugPrint("[ModelData] Notifying ${_listeners.length} listeners of a data change.");

    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    debugPrint("[ModelData] Listener removed. Total listeners: ${_listeners.length}");
  }

  static void clearCache() {
    _cachedModels = null;
    debugPrint("[ModelData] In-memory model cache cleared.");
    _notifyListeners();
  }

  /// PUBLIC: Adds a new model directly to the in-memory cache.
  /// This is much safer and more performant than clearing the entire cache.
  static void addModelToCache(Map<String, dynamic> newModelData) {
    // If the cache isn't initialized, do nothing.
    // The next full load will pick the model up from the DB.
    if (_cachedModels == null) {
      debugPrint("[ModelData] Cache not initialized. Skipping adding model to cache.");
      return;
    }

    // To prevent duplicates, first remove any existing model with the same id.
    _cachedModels!.removeWhere((m) => m['id'] == newModelData['id']);

    // Add the new model to the list.
    _cachedModels!.add(newModelData);
    debugPrint("[ModelData] Added model '${newModelData['id']}' to in-memory cache.");

    _notifyListeners();
  }

  static String getBaseIdFromFullId(String? fullId) {
    if (fullId == null || fullId.isEmpty) {
      return '';
    }
    // The base ID is everything before the first '/'.
    // e.g., "arcee-ai/caller-large" -> "arcee-ai"
    // e.g., "llama-3-8b" (which is a base ID) -> "llama-3-8b"
    if (fullId.contains('/')) {
      return fullId
          .split('/')
          .first;
    }
    return fullId;
  }

  /// PUBLIC: Main entry point for the UI to get the model list.
  /// Returns a list of models, or NULL if a critical error occurs.
  static Future<List<Map<String, dynamic>>?> getModels(
      {required String langCode}) async {
    if (_syncCompleter != null) {
      debugPrint(
          "[ModelData.getModels] A sync process is already running. Awaiting its completion.");
      await _syncCompleter!.future;
      return _cachedModels ?? [];
    }

    if (_cachedModels != null && _cachedModels!.isNotEmpty) {
      return _cachedModels!;
    }

    debugPrint(
        "[ModelData.getModels] No sync process running or cache is empty. Starting a new one.");
    _syncCompleter = Completer<void>();

    try {
      await _initializeModelCache(langCode: langCode);
      _syncCompleter!.complete();
      return _cachedModels;
    } catch (e, s) {
      debugPrint(
          "[ModelData.getModels] CRITICAL Error during initialization: $e\n$s");
      _syncCompleter!.completeError(e);
      return null;
    } finally {
      _syncCompleter = null;
    }
  }

  /// Central logic for initializing and refreshing the model cache.
  static Future<void> _initializeModelCache({required String langCode}) async {
    await _loadLastSyncStateFromPrefs();

    // --- MODIFICATION: Pass the current user's ID to getAllModels ---
    final currentUser = FirebaseAuth.instance.currentUser;
    final allDbModels = await _dbHelper.getAllModels(userId: currentUser?.uid);
    // --- END OF MODIFICATION ---

    final bool isDbEmpty = allDbModels.isEmpty;
    final bool isCacheStale = _lastSyncTime == null ||
        DateTime.now().difference(_lastSyncTime!) > _cacheStaleDuration;
    final bool hasInternet = await InternetConnection().hasInternetAccess;
    final bool isLangChanged = _lastSyncLangCode != null &&
        _lastSyncLangCode != langCode;

    if (hasInternet && (isDbEmpty || isCacheStale || isLangChanged)) {
      debugPrint(
          "[ModelData] Sync required. DB Empty: $isDbEmpty, Cache Stale: $isCacheStale, Language Changed: $isLangChanged");
      await _syncWithServer(langCode);
    } else {
      debugPrint(
          "[ModelData] Sync not required. Loading from local DB. DB Empty: $isDbEmpty, Cache Stale: $isCacheStale, Language Changed: $isLangChanged");
    }

    // --- MODIFICATION: Pass the current user's ID again after sync ---
    _cachedModels = await _dbHelper.getAllModels(userId: currentUser?.uid);
    // --- END OF MODIFICATION ---

    if (hasInternet) {
      _syncModelImages();
    }
  }

  static Future<void> _loadLastSyncStateFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_prefsKeyLastSync);
      if (timestampString != null) {
        _lastSyncTime = DateTime.tryParse(timestampString);
      }
      _lastSyncLangCode =
          prefs.getString(_prefsKeyLastSyncLang); // Load language
    } catch (e) {
      debugPrint("[ModelData] Error loading sync state: $e");
    }
  }

  static Future<void> _updateLastSyncState(String langCode) async {
    _lastSyncTime = DateTime.now();
    _lastSyncLangCode = langCode; // Update in-memory state
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _prefsKeyLastSync, _lastSyncTime!.toIso8601String());
      await prefs.setString(_prefsKeyLastSyncLang, langCode); // Save language
      debugPrint(
          "[ModelData] Saved sync state for lang '$langCode' at $_lastSyncTime");
    } catch (e) {
      debugPrint("[ModelData] Error saving sync state: $e");
    }
  }

  /// PUBLIC: Directly updates a single model's data in the in-memory cache.
  /// This is used for "hot-patching" the cache after an update on a detail
  /// screen, ensuring that subsequent synchronous calls (like starting a chat)
  /// have access to the fresh data without a full asynchronous reload.
  static void updateCachedModel(Map<String, dynamic> updatedModelData) {
    // If the cache isn't even populated, there's nothing to update.
    if (_cachedModels == null) {
      debugPrint("[ModelData.updateCachedModel] Cache is null, cannot update.");
      return;
    }

    final modelIdToUpdate = updatedModelData['id'];
    if (modelIdToUpdate == null) {
      debugPrint(
          "[ModelData.updateCachedModel] Provided data has no 'id' field. Aborting.");
      return;
    }

    // Find the index of the old model data in the cache.
    final index = _cachedModels!.indexWhere((m) => m['id'] == modelIdToUpdate);

    if (index != -1) {
      // Replace the old data with the new data.
      _cachedModels![index] = updatedModelData;
      debugPrint("[ModelData] Hot-patched cache for model '$modelIdToUpdate'.");
    } else {
      // This might happen if the model was newly created and the cache is stale.
      // In most cases, it indicates a logic issue, but for now we just log it.
      debugPrint(
          "[ModelData.updateCachedModel] Model '$modelIdToUpdate' not found in cache. No update performed.");
    }
  }

  /// Synchronizes the local database with the remote server and validates data integrity.
  /// This is the main orchestrator that now uses the improved validation function.
  static Future<void> _syncWithServer(String langCode) async {
    debugPrint("[ModelData] Starting full model sync and validation process...");
    try {
      // Step 1: Fetch public models from the server and get their valid IDs.
      final Set<String> validPublicIds = await _syncPublicModels(langCode);
      debugPrint("[ModelData] Step 1/4: Public model sync complete. Found ${validPublicIds.length} valid public IDs.");


      // Step 2: Clean up old public models from the local DB.
      if (validPublicIds.isNotEmpty) {
        final db = await _dbHelper.database;
        final placeholders = List.filled(validPublicIds.length, '?').join(',');
        final count = await db.delete(
          'models',
          // IMPORTANT: Do NOT delete user-created models
          where: "id NOT IN ($placeholders) AND id NOT LIKE 'self_%' AND id NOT LIKE 'local_%'",
          whereArgs: validPublicIds.toList(),
        );
        if (count > 0) {
          debugPrint("[ModelData] Step 2/4: Cleaned up $count stale public models from local DB.");
        } else {
          debugPrint("[ModelData] Step 2/4: No stale public models to clean up.");
        }
      }

      // Step 3: Run the validation. This now happens *after* the sync is complete.
      // We get ALL models from the DB, including newly synced public ones and existing user-created ones.
      final currentUser = FirebaseAuth.instance.currentUser;
      final allCurrentModelsInDb = await _dbHelper.getAllModels(userId: currentUser?.uid);
      debugPrint("[ModelData] Step 3/4: Starting base model validation for ${allCurrentModelsInDb.length} total models.");
      await _validateAndAssignDefaultBaseModels(allCurrentModelsInDb);
      debugPrint("[ModelData] Step 3/4: Base model validation finished.");

      // Step 4: Update the sync timestamp. The process is now complete.
      await _updateLastSyncState(langCode);
      debugPrint("[ModelData] Step 4/4: Sync process fully complete. Last sync time updated.");

    } catch (e, s) {
      debugPrint("[ModelData] CRITICAL ERROR during sync orchestration: $e\n$s");
    }
  }

  static Future<Set<String>> _syncPublicModels(String langCode) async {
    final response = await http.get(Uri.parse(_serverUrl));
    if (response.statusCode != 200) {
      throw Exception('Public models server error: ${response.statusCode}');
    }

    final Map<String, dynamic> rawServerData = json.decode(
        utf8.decode(response.bodyBytes));
    final List<
        Map<String, dynamic>> parsedServerModels = _parseAndGroupServerModels(
        rawServerData, langCode);
    final Set<String> validServerIds = parsedServerModels.map((
        m) => m['id'] as String).toSet();

    for (var modelData in parsedServerModels) {
      if (!modelData['id'].startsWith('self_') &&
          !modelData['id'].startsWith('local_')) {
        await _dbHelper.insert('models', {
          'id': modelData['id'],
          'producer': modelData['producer'] ?? 'Unknown',
          'title': modelData['title'] ?? modelData['id'],
          'is_server_side': (modelData['type'] != 'offline') ? 1 : 0,
          'type': modelData['type'] ?? 'online',
          'raw_json': json.encode(modelData),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    return validServerIds;
  }

  /// PUBLIC: Returns the cached models synchronously.
  /// Use this only after `getModels` has been awaited at least once.
  static List<Map<String, dynamic>> getCachedModelsSync() {
    return _cachedModels ?? [];
  }

  /// Parses the raw server data into a structured and unified list of models.
  static List<Map<String, dynamic>> _parseAndGroupServerModels(
      Map<String, dynamic> rawData, String langCode) {
    final List<Map<String, dynamic>> finalList = [];
    final producers = rawData['producers'] as Map<String, dynamic>? ?? {};

    final String currentLangCode = langCode;

    producers.forEach((producerName, seriesData) {
      if (seriesData is! Map<String, dynamic>) return;
      seriesData.forEach((seriesName, seriesValue) {
        if (seriesValue is! Map<String, dynamic>) return;

        final variantsMap = Map<String, dynamic>.from(seriesValue)
          ..removeWhere((key, value) =>
          key == 'series_description' || key == 'reasoning');
        if (variantsMap.isEmpty) return;

        if (variantsMap.length == 1 && variantsMap.containsKey('Default')) {
          final model = _parseSingleVariantModel(
            seriesName: seriesName,
            producerName: producerName,
            variantData: variantsMap['Default'],
            langCode: currentLangCode,
            defaultBaseModelId: null,
          );
          if (model != null) finalList.add(model);
        } else {
          final model = _parseMultiVariantSeries(
            seriesName: seriesName,
            producerName: producerName,
            seriesValue: seriesValue,
            langCode: currentLangCode,
          );
          if (model != null) finalList.add(model);
        }
      });
    });

    return finalList;
  }


  /// Parses single-variant models (like Roleplay, Offline) by correctly
  /// extracting localized data, including the 'role', from the nested 'details' object.
  static Map<String, dynamic>? _parseSingleVariantModel({
    required String seriesName,
    required String producerName,
    required Map<String, dynamic> variantData,
    required String langCode,
    String? defaultBaseModelId,
  }) {
    final String serverLangKey = (langCode == 'zh') ? 'cn' : langCode;
    final String modelId = variantData['id'] as String? ?? seriesName;
    final Map<String, dynamic> modalities = variantData['modalities'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> outputs = variantData['outputs'] as Map<String, dynamic>? ?? {};
    // 1. Get the main 'details' object.
    final details = variantData['details'] as Map<String, dynamic>? ?? {};
    if (details.isEmpty) {
      debugPrint("[_parseSingleVariantModel] LOG: Model '$modelId' has no 'details' object. Cannot extract role.");
    }

    // 2. Determine the correct language maps to use, with English as the ultimate fallback.
    final Map<String, dynamic> localizedDetails = (details[serverLangKey] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> englishDetails = (details['en'] as Map<String, dynamic>?) ?? {};

    // 3. Extract each piece of data, prioritizing the current language then falling back to English.
    final String title = localizedDetails['title'] as String?
        ?? englishDetails['title'] as String?
        ?? modelId;

    final String summary = localizedDetails['summary'] as String?
        ?? englishDetails['summary'] as String?
        ?? '';

    final String description = localizedDetails['description'] as String?
        ?? englishDetails['description'] as String?
        ?? '';

    // --- THIS IS THE CRITICAL FIX for client-side parsing ---
    // Extract the 'role' (system prompt) as a STRING using the localized fallback logic.
    final String? role = localizedDetails['role'] as String?
        ?? englishDetails['role'] as String?;

    if (role != null) {
      debugPrint("[_parseSingleVariantModel] LOG: Successfully extracted role for '$modelId' as a String: '${role.substring(0, (role.length > 50) ? 50 : role.length)}...'");
    } else {
      debugPrint("[_parseSingleVariantModel] LOG: Could not find a 'role' for '$modelId' in either '$serverLangKey' or 'en' details.");
    }
    // --- END OF CRITICAL FIX ---

    // (The rest of the function is the same as before)
    final bool isFullyLocalized = (langCode == 'en') ||
        (localizedDetails['title'] != null &&
            localizedDetails['summary'] != null &&
            localizedDetails['description'] != null &&
            localizedDetails['role'] != null);

    final modelCategory = variantData['category']?.toString() ??
        variantData['type']?.toString() ?? 'online';
    final bool isCharacterType = modelCategory == 'roleplay' ||
        modelCategory == 'self';

    String? finalBaseModelId = variantData['baseModelId'] as String?;
    if (isCharacterType &&
        (finalBaseModelId == null || finalBaseModelId.isEmpty)) {
      finalBaseModelId = defaultBaseModelId;
    }

    return {
      'id': modelId,
      'title': title,
      'producer': producerName,
      'type': variantData['type'] ?? 'online',
      'category': modelCategory,
      'role': role, // The role is now a simple String.
      'summary': summary,
      'description': description,
      'baseModelId': finalBaseModelId,
      'imagePath': variantData['imagePath'],
      'modalities': modalities,
      'outputs': outputs,
      'extensions': null,
      'size': variantData['size'],
      'ram': variantData['ram'],
      'isFullyLocalized': isFullyLocalized,
      ...variantData,
    };
  }

  /// --- NEW HELPER: Parses multi-variant models (Online series like Gemini) ---
  static Map<String, dynamic>? _parseMultiVariantSeries({
    required String seriesName,
    required String producerName,
    required Map<String, dynamic> seriesValue,
    required String langCode,
  }) {
    // Map Flutter's language code ('zh') to the server's key ('cn')
    final String serverLangKey = (langCode == 'zh') ? 'cn' : langCode;

    final variantsMap = Map<String, dynamic>.from(seriesValue)
      ..removeWhere((key, value) =>
      key == 'series_description' || key == 'reasoning');
    if (variantsMap.isEmpty) return null;

    // --- FIX: Step 1 ---
    // Extract the series-level summary first, so it can be used for all variants.
    final seriesDetails = seriesValue['series_description'] as Map<
        String,
        dynamic>? ?? {};
    final String localizedSeriesSummary = seriesDetails[serverLangKey] as String? ??
        seriesDetails['en'] as String? ?? '';


    final Map<String, dynamic> extensions = {};
    bool areAllVariantsLocalized = true;

    variantsMap.forEach((variantKey, variantData) {
      if (variantData is! Map<String, dynamic>) return;

      final descriptionMap = variantData['description'] as Map<String,
          dynamic>? ?? {};
      final Map<String, dynamic> modalities = variantData['modalities'] as Map<String, dynamic>? ?? {};
      final Map<String, dynamic> outputs = variantData['outputs'] as Map<String, dynamic>? ?? {};

      // Get the specific, detailed description for this variant.
      final String localizedVariantDesc = descriptionMap[serverLangKey] as String? ??
          descriptionMap['en'] as String? ?? '';

      // Check if the variant's detailed description is localized.
      if (langCode != 'en' &&
          (descriptionMap[serverLangKey] as String?)?.isEmpty == true) {
        areAllVariantsLocalized = false;
      }

      extensions[variantData['id'] as String] = {
        'id': variantData['id'],
        'title': variantData['title'] ?? variantKey,
        'summary': localizedSeriesSummary,
        'description': localizedVariantDesc,
        'modalities': modalities,
        'outputs': outputs,
        'reasoning': variantData['reasoning'] ?? false,
        'webSearch': variantData['webSearch'] ?? false,
        ...variantData,
      };
    });

    if (extensions.isEmpty) return null;

    // The localization check uses the original 'langCode'
    final bool isSeriesLocalized = (langCode == 'en') ||
        (seriesDetails[serverLangKey] != null);
    final bool finalIsFullyLocalized = isSeriesLocalized &&
        areAllVariantsLocalized;

    // The parent series object uses the series summary for both its summary and description.
    // This is correct as it acts as a container. The main fix was for the variants in 'extensions'.
    return {
      'id': seriesName.toLowerCase().replaceAll(' ', '-'),
      'title': seriesValue['title'] as String? ?? seriesName,
      'producer': producerName,
      'type': 'online',
      'category': seriesValue['category'] ?? 'online',
      'summary': localizedSeriesSummary,
      'description': localizedSeriesSummary,
      // It's acceptable for the container to have the same summary/description.
      'imagePath': seriesValue['imagePath'],
      'extensions': extensions,
      'isFullyLocalized': finalIsFullyLocalized,
    };
  }

  /// --- THE DEFINITIVE, ROBUST LOCALIZATION HELPER --- ///
  static String getLocalizedText(Map<String, dynamic>? data, String field,
      String langCode) {
    if (data == null) return '';

    // --- FIX: Map Flutter's language code ('zh') to the server's key ('cn') ---
    final String serverLangKey = (langCode == 'zh') ? 'cn' : langCode;

    // --- CASE 1: The data itself contains language keys (e.g., detailsMap) ---
    if (data.containsKey(serverLangKey) && data[serverLangKey] is Map) {
      final langMap = data[serverLangKey] as Map<String, dynamic>;
      if (langMap.containsKey(field) && langMap[field] is String) {
        return langMap[field];
      }
    }
    // Fallback for Case 1: Try English if the requested language is not found.
    if (data.containsKey('en') && data['en'] is Map) {
      final langMap = data['en'] as Map<String, dynamic>;
      if (langMap.containsKey(field) && langMap[field] is String) {
        return langMap[field];
      }
    }

    // --- CASE 2: The field itself contains language keys (e.g., descriptionMap) ---
    if (data.containsKey(field) && data[field] is Map) {
      final textMap = data[field] as Map<String, dynamic>;
      if (textMap.containsKey(serverLangKey) &&
          textMap[serverLangKey] is String) {
        return textMap[serverLangKey];
      }
      // Fallback for Case 2
      if (textMap.containsKey('en') && textMap['en'] is String) {
        // --- THIS IS THE FIX: Changed 'en' from a variable to a string literal ---
        return textMap['en'];
      }
    }

    // --- CASE 3: The field is just a simple string (non-localized fallback) ---
    if (data.containsKey(field) && data[field] is String) {
      return data[field];
    }

    // If nothing is found, return an empty string.
    return '';
  }

  /// Downloads and caches images for models that are defined on the server
  /// but not yet cached locally AND do not have a built-in local asset.
  static Future<void> _syncModelImages() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final allModels = await _dbHelper.getAllModels(userId: currentUser?.uid);
    final cachedImagePaths = await _ModelImageCache._loadPaths();
    final docsDir = await getApplicationDocumentsDirectory();
    final imageCacheDir = Directory(p.join(docsDir.path, 'model_images'));

    if (!await imageCacheDir.exists()) {
      await imageCacheDir.create(recursive: true);
    }

    final retryOptions = const RetryOptions(
      maxAttempts: 3,
      delayFactor: Duration(seconds: 1),
      maxDelay: Duration(seconds: 5),
    );

    for (final model in allModels) {
      final modelId = model['id'] as String;

      if (modelId.startsWith('self_') || modelId.startsWith('local_')) {
        continue;
      }

      final serverImagePath = model['imagePath'] as String?;

      final bool needsDownload = serverImagePath != null &&
          !serverImagePath.startsWith('assets/') &&
          !cachedImagePaths.containsKey(modelId) &&
          !_localAssetImageMap.containsKey(modelId.toLowerCase());

      if (needsDownload) {
        debugPrint(
            "[ModelData] No local asset for '$modelId', download needed: $serverImagePath");
        await retryOptions.retry(
              () async {
            final callable =
            FirebaseFunctions.instanceFor(region: 'europe-west1')
                .httpsCallable('getCoverDownloadUrl');
            final result = await callable
                .call<Map<String, dynamic>>({'filePath': serverImagePath});
            final signedUrl = result.data['signedUrl'] as String;

            final response = await http.get(Uri.parse(signedUrl));
            if (response.statusCode == 200) {
              final fileName = p.basename(serverImagePath);
              final localFile = File(p.join(imageCacheDir.path, fileName));
              await localFile.writeAsBytes(response.bodyBytes);

              await _ModelImageCache.add(modelId, localFile.path);
              debugPrint(
                  "[ModelData] Successfully cached image: '$modelId' -> ${localFile
                      .path}");
            } else {
              throw HttpException(
                  'Failed to download image for $modelId. Status: ${response
                      .statusCode}');
            }
          },
          retryIf: (e) =>
          e is SocketException ||
              e is TimeoutException ||
              e is HttpException,
          onRetry: (e) =>
              debugPrint(
                  "[ModelData] Retrying image download for '$modelId': $e"),
        ).catchError((e, s) {
          debugPrint(
              "[ModelData] ERROR: All image download attempts failed for '$modelId': $e\n$s");
        });
      }
    }
    // Refresh the in-memory cache after all downloads are attempted.
    _cachedImagePaths = await _ModelImageCache._loadPaths();
  }

  /// Finds the best default online model from a GIVEN LIST of models.
  /// THIS IS THE FINAL, CORRECTED VERSION. It is now a pure function
  /// that no longer depends on the potentially stale global cache.
  static String? findDefaultBaseModel(List<Map<String, dynamic>> models) {
    if (models.isEmpty) {
      debugPrint(
          "[ModelData] findDefaultBaseModel called with an empty list. Cannot find a default.");
      return null;
    }

    // Priority 1: Find the 'gemini' model series.
    final geminiModel = models.firstWhere((m) => m['id'] == 'gemini',
        orElse: () => {});
    if (geminiModel.isNotEmpty && geminiModel['extensions'] is Map) {
      final extensions = geminiModel['extensions'] as Map<String, dynamic>;
      // Find the first variant that is NOT a Pro model, preferring Flash or others.
      final nonProVariant = extensions.entries.firstWhere(
              (e) =>
          e.value['title'] is String &&
              !(e.value['title'] as String).toLowerCase().contains('pro'),
          orElse: () =>
          extensions.entries
              .first // Fallback to the very first variant if none match
      );
      return nonProVariant.key;
    }

    // Priority 2 (Fallback): Find the first available online model with any extensions.
    final firstOnlineModel = models.firstWhere((m) =>
    m['type'] == 'online' && m['extensions'] is Map &&
        (m['extensions'] as Map).isNotEmpty, orElse: () => {});
    if (firstOnlineModel.isNotEmpty) {
      return (firstOnlineModel['extensions'] as Map<String, dynamic>).keys
          .first;
    }

    debugPrint("[ModelData] Could not find any suitable default base model.");
    return null;
  }

  /// It is now a self-contained utility that updates the database directly
  /// and returns a boolean indicating if any changes were made. It NO LONGER
  /// triggers a UI reload, preventing the race condition identified in the logs.
  static Future<bool> _validateAndAssignDefaultBaseModels(
      List<Map<String, dynamic>> allModelsInDb) async {
    debugPrint("[ModelData] Starting validation of base models for all characters.");

    if (allModelsInDb.isEmpty) {
      debugPrint("[ModelData] Validation skipped: The provided model list is empty.");
      return false;
    }

    // --- STEP 1: Find a reliable default model BEFORE attempting any repairs. ---
    // This is the most critical input for the entire repair process.
    final defaultBaseModelId = findDefaultBaseModel(allModelsInDb);

    // --- STEP 2: The First Safety Lock ---
    // If no default base model can be found (e.g., due to a failed sync where no online models are present),
    // we must abort the entire repair process. Proceeding would risk corrupting data.
    if (defaultBaseModelId == null) {
      debugPrint("[ModelData] CRITICAL: Aborting repair process. No suitable default online model was found to use as a fallback. Data will remain untouched.");
      return false;
    }
    debugPrint("[ModelData] Found default base model for assignment: '$defaultBaseModelId'");


    // --- STEP 3: Create a definitive set of ALL valid online model IDs ---
    // This set is the "source of truth" for what constitutes a valid base model.
    final allOnlineVariantIds = <String>{};
    allModelsInDb.where((m) => m['type'] == 'online').forEach((model) {
      if (model['extensions'] is Map && (model['extensions'] as Map).isNotEmpty) {
        final extensions = model['extensions'] as Map<String, dynamic>;
        allOnlineVariantIds.addAll(extensions.keys);
      } else {
        allOnlineVariantIds.add(model['id']);
      }
    });
    debugPrint("[ModelData] Found ${allOnlineVariantIds.length} unique online model variants to validate against.");


    final db = await _dbHelper.database;
    bool needsUpdate = false;

    // --- STEP 4: Iterate through models and apply the DEFENSIVE repair logic. ---
    for (final modelMap in allModelsInDb) {
      final modelCategory = modelMap['category']?.toString() ?? '';

      // Target only character models ('roleplay' or 'self').
      if (modelCategory == 'roleplay' || modelCategory == 'self') {
        final modelId = modelMap['id'] as String;
        String? currentBaseId = modelMap['baseModelId'] as String?;
        bool requiresRepair = false;

        // Condition 1: The model is missing a base model.
        if (currentBaseId == null || currentBaseId.isEmpty) {
          debugPrint("[ModelData] REPAIR REQUIRED for '$modelId': Base model was missing.");
          requiresRepair = true;
        }
        // Condition 2: The assigned base model is no longer valid.
        else if (!allOnlineVariantIds.contains(currentBaseId)) {
          debugPrint("[ModelData] REPAIR REQUIRED for '$modelId': Previous base '$currentBaseId' is no longer valid.");
          requiresRepair = true;
        }

        // --- THE FINAL SAFETY LOCK ---
        // Only proceed with the database update if the model requires repair AND we have a valid fix.
        if (requiresRepair) {
          // This check is implicitly handled by the master check at the top (Step 2),
          // but re-asserting it here makes the logic crystal clear and self-contained.
          // We already confirmed `defaultBaseModelId` is not null.

          needsUpdate = true; // Mark that at least one update is happening.
          modelMap['baseModelId'] = defaultBaseModelId; // Update the map in memory

          debugPrint("[ModelData] Safe Repair: Updating character '$modelId' to use new base model '$defaultBaseModelId'.");

          // Write the entire updated model object back to the database.
          await db.update(
              'models',
              {'raw_json': json.encode(modelMap)},
              where: 'id = ?',
              whereArgs: [modelId]
          );
        }
      }
    }

    if (needsUpdate) {
      debugPrint("[ModelData] Validation complete. One or more character base models were successfully updated in the database.");
    } else {
      debugPrint("[ModelData] Validation complete. All character base models are already valid.");
    }

    // Return true if the database was modified, false otherwise.
    return needsUpdate;
  }

  /// Helper to remove cached images.
  /// This requires the function signature from the previous response.
  static Future<void> remove(Iterable<String> modelIds) async {
    // This function body is from a previous response and should be correct.
    if (modelIds.isEmpty) return;
    final paths = await _ModelImageCache._loadPaths();
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
    await _ModelImageCache._savePaths(paths);
  }

  /// PUBLIC: Removes a single model from the in-memory cache.
  /// This is much safer than clearing the entire cache.
  static void removeModelFromCache(String modelId) {
    if (_cachedModels == null) return;
    final originalLength = _cachedModels!.length;
    _cachedModels!.removeWhere((model) => model['id'] == modelId);
    if (_cachedModels!.length < originalLength) {
      debugPrint("[ModelData] Removed model '$modelId' from in-memory cache.");
      _notifyListeners();
    }
  }

  /// Determines the correct image path for a model with a smart, prioritized fallback system.
  /// This is now the single source of truth for model images in the app.
  ///
  /// This function is designed to be completely foolproof. It handles all possible scenarios
  /// for a model's image and guarantees a valid, displayable asset path is always returned.
  ///
  /// Priority Order:
  /// 1.  **Absolute File Path (User-Created Models)**: Checks if the `imagePath`
  ///     field from the model data points to an existing file on the device. This is
  ///     the primary method for displaying images for custom-created "self" and "local" models.
  /// 2.  **Downloaded/Cached Image**: Checks if an image has been downloaded from the server
  ///     for a public model and is available in the local cache.
  /// 3.  **Direct Asset Path**: Uses the `imagePath` field if it points directly to an
  ///     asset bundled with the app (i.e., starts with 'assets/').
  /// 4.  **Local Asset Map (Robust Lookup)**: Intelligently searches a built-in map of
  ///     local assets using the model's ID, base ID, or title as keys. This is a
  ///     powerful fallback for known public models.
  /// 5.  **Ultimate Fallback Icon**: If all other checks fail (e.g., path is null, empty,
  ///     or file is missing), it returns the path to the default 'self.svg' icon.
  static String getModelImagePath(Map<String, dynamic> model) {
    final modelId = model['id']?.toString() ?? '';
    final baseId = getBaseIdFromFullId(modelId);
    final modelTitle = model['title']?.toString() ?? '';
    final directPath = model['imagePath'] as String?;

    // --- CRITICAL FIX & SIMPLIFICATION ---
    // Handle null, empty, or non-existent paths right at the start.
    // This is the core of your excellent suggestion.
    if (directPath == null || directPath.isEmpty) {
      // If there's no path, we can immediately try the local asset map as a last resort
      // before giving the final fallback.
      final potentialKeys = [ modelId, baseId, modelTitle ].map((s) => s.toLowerCase()).toSet().toList();
      for (final mapKey in _localAssetImageMap.keys) {
        for (final potentialKey in potentialKeys) {
          if (potentialKey.isNotEmpty && potentialKey.contains(mapKey)) {
            return _localAssetImageMap[mapKey]!;
          }
        }
      }
      // If even the map lookup fails, return the default SVG.
      return 'assets/icons/self.svg';
    }

    // --- PRIORITY 1: Check for an absolute local file path. ---
    // If the path is not an asset path, we assume it's a local file.
    if (!directPath.startsWith('assets/')) {
      final file = File(directPath);
      if (file.existsSync()) {
        return directPath; // The file exists, return its path.
      }
      // If the file does NOT exist, we fall through to the other checks.
      // The path might be a broken link to a deleted user image.
    }

    // --- PRIORITY 2: Check for a downloaded & cached image from the server. ---
    if (_cachedImagePaths != null && _cachedImagePaths!.containsKey(modelId)) {
      final localPath = _cachedImagePaths![modelId]!;
      if (File(localPath).existsSync()) {
        return localPath;
      }
    }

    // --- PRIORITY 3: Use the direct path if it's a valid bundled asset. ---
    if (directPath.startsWith('assets/')) {
      // Here, we trust the path is correct. If the asset is missing, the
      // Image widget's `errorBuilder` will handle it.
      return directPath;
    }

    // --- PRIORITY 4: Smart Local Asset Map Lookup (also a fallback). ---
    final potentialKeys = [ modelId, baseId, modelTitle ].map((s) => s.toLowerCase()).toSet().toList();
    for (final mapKey in _localAssetImageMap.keys) {
      for (final potentialKey in potentialKeys) {
        if (potentialKey.isNotEmpty && potentialKey.contains(mapKey)) {
          return _localAssetImageMap[mapKey]!;
        }
      }
    }

    // --- FINAL, ULTIMATE FALLBACK ---
    // If we've reached this point, it means no valid image could be found anywhere.
    return 'assets/icons/self.svg';
  }

  /// This function is now more flexible.
  ///
  /// - If called with one argument `hasModality(modelId)`:
  ///   Returns `true` if the model has ANY special modalities (i.e., the modalities map is not empty).
  ///
  /// - If called with two arguments `hasModality(modelId, 'image')`:
  ///   Returns `true` only if the model has the SPECIFIC 'image' modality.
  ///
  /// For character/self models, it intelligently checks the base model's capabilities as a fallback.
  static bool hasModality(String modelId, [String? modality]) {
    final modelData = getPreciseModelData(modelId);
    final modelModalities = modelData['modalities'] as Map<String, dynamic>? ?? {};

    // A helper function to perform the actual check.
    // This avoids code duplication for the fallback logic.
    bool check(Map<String, dynamic> modalitiesMap) {
      if (modality == null) {
        // Case 1: No specific modality was requested.
        // Check if the map is not empty.
        return modalitiesMap.isNotEmpty;
      } else {
        // Case 2: A specific modality was requested.
        // Check for that specific key.
        return modalitiesMap[modality] == true;
      }
    }

    // 1. Check the model directly.
    if (check(modelModalities)) {
      return true;
    }

    // 2. If it's a character, check its base model as a fallback.
    final category = modelData['category'] as String?;
    final isCharacter = category == 'roleplay' || category == 'self';
    final baseModelId = modelData['baseModelId'] as String?;

    if (isCharacter && baseModelId != null && baseModelId.isNotEmpty) {
      // The capability comes from its base model.
      final baseModelData = getPreciseModelData(baseModelId);
      final baseModalities = baseModelData['modalities'] as Map<String, dynamic>? ?? {};

      final bool baseHasModality = check(baseModalities);

      // Only print debug info if we're checking for a specific modality.
      if (modality != null) {
        debugPrint(
            "[ModelData] Checking base model '$baseModelId' for '$modality' handling: $baseHasModality");
      }

      return baseHasModality;
    }

    // Otherwise, the model does not have this capability.
    return false;
  }

  /// - If called with one argument `canProduce(modelId)`:
  ///   Returns `true` if the model can produce ANYTHING other than the default (i.e., the outputs map is not empty).
  ///
  /// - If called with two arguments `canProduce(modelId, 'image')`:
  ///   Returns `true` only if the model has the SPECIFIC 'image' output capability.
  ///
  /// For character/self models, it intelligently checks the base model's capabilities.
  static bool canProduce(String modelId, [String? outputType]) {
    final modelData = getPreciseModelData(modelId);
    final modelOutputs = modelData['outputs'] as Map<String, dynamic>? ?? {};

    // Helper function to perform the actual check.
    bool check(Map<String, dynamic> outputsMap) {
      if (outputType == null) {
        // Case 1: No specific output type requested. Check if the map is not empty.
        return outputsMap.isNotEmpty;
      } else {
        // Case 2: A specific output type was requested. Check for that key.
        return outputsMap[outputType] == true;
      }
    }

    // 1. Check the model directly.
    if (check(modelOutputs)) {
      return true;
    }

    // 2. If it's a character, check its base model as a fallback.
    final category = modelData['category'] as String?;
    final isCharacter = category == 'roleplay' || category == 'self';
    final baseModelId = modelData['baseModelId'] as String?;

    if (isCharacter && baseModelId != null && baseModelId.isNotEmpty) {
      final baseModelData = getPreciseModelData(baseModelId);
      final baseOutputs = baseModelData['outputs'] as Map<String, dynamic>? ?? {};
      return check(baseOutputs);
    }

    // Otherwise, the model does not have this capability.
    return false;
  }

  /// PUBLIC: Removes cached images for the given model IDs.
  /// This is the correct way to expose the functionality of the private _ModelImageCache.
  static Future<void> removeCachedImages(Iterable<String> modelIds) async {
    // This public method safely calls the private implementation.
    await _ModelImageCache.remove(modelIds);
  }

  /// PUBLIC: The new single source of truth for retrieving precise model data.
  /// Given a full model ID (which could be a base ID or a variant ID), this function
  /// returns a complete, merged map of that model's data.
  /// It correctly combines base series data with specific variant data.
  static Map<String, dynamic> getPreciseModelData(String modelId) {
    final allModels = getCachedModelsSync();

    // 👉 BULLETPROOF FIX: Add a loud, clear warning for developers if this is called
    // before the model cache is populated. This is the root cause of "Unknown Model" issues.
    if (allModels.isEmpty) {
      if (kDebugMode) {
        debugPrint("="*80);
        debugPrint("‼️ CRITICAL WARNING: getPreciseModelData was called for '$modelId' but the model cache is EMPTY.");
        debugPrint("This almost always means ModelData.getModels(context) was not awaited before this point.");
        debugPrint("The app will now return a fallback object to prevent a crash, but UI will show 'Unknown Model'.");
        debugPrint("="*80);
      }
      return _createFallbackModelData(modelId);
    }

    // --- STEP 1: PRIORITIZED SEARCH FOR AN EXACT ID MATCH ---
    final directMatch = allModels.firstWhere((m) => m['id'] == modelId, orElse: () => {});
    if (directMatch.isNotEmpty) {
      final finalData = Map<String, dynamic>.from(directMatch);
      finalData['imagePath'] = getModelImagePath(finalData);
      return finalData;
    }

    // --- STEP 2: SEARCH FOR A VARIANT ID WITHIN A SERIES' EXTENSIONS ---
    for (final modelSeries in allModels) {
      if (modelSeries['extensions'] is Map<String, dynamic>) {
        final extensionsMap = modelSeries['extensions'] as Map<String, dynamic>;
        if (extensionsMap.containsKey(modelId)) {
          final variantData = extensionsMap[modelId] as Map<String, dynamic>;

          final Map<String, dynamic> mergedData = {
            ...modelSeries,
            ...variantData,
            'id': variantData['id'] ?? modelId,
            'title': variantData['title'] ?? modelSeries['title'],
            'imagePath': getModelImagePath(modelSeries),
          };
          mergedData.remove('extensions');
          return mergedData;
        }
      }
    }

    // --- STEP 3: If no match is found anywhere, return a safe fallback. ---
    debugPrint("[ModelData.getPreciseModelData] WARN: Model '$modelId' not found in cache. Creating fallback.");
    return _createFallbackModelData(modelId);
  }

  /// Helper to create a consistent fallback model object.
  static Map<String, dynamic> _createFallbackModelData(String modelId) {
    return {
      'id': modelId,
      'title': 'Unknown Model',
      'producer': 'Unknown',
      'imagePath': 'assets/icons/self.svg', // Always use the SVG for fallbacks
      'type': 'online',
      'modalities': {},
      'outputs': {},
      'extensions': null,
    };
  }
}