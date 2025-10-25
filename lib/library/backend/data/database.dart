// models/backend/data/database.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'crypto.dart';

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
