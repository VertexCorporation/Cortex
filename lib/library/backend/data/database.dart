// lib/library/backend/data/database.dart

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
  /// Handles SQLITE_FULL errors gracefully.
  Future<int> insert(String table, Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
    String? userId, // <-- User ID for encryption
  }) async {
    try {
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
          debugPrint("[DatabaseHelper] CRITICAL: Failed to encrypt data for model '$modelId'");
          // We might choose to throw here, or proceed unencrypted (risky). Throwing is safer.
          throw Exception("Encryption failed for model $modelId");
        }
      }

      return await db.insert(
        table,
        values,
        conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (e.toString().contains("SQLITE_FULL") || e.toString().contains("database or disk is full")) {
        debugPrint("[DatabaseHelper] CRITICAL: Disk full during insert. Data NOT saved.");
        return -1; // Return -1 to indicate failure
      }
      rethrow;
    }
  }

  /// Updates rows in the database.
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs}) async {
    try {
      final db = await instance.database;
      return await db.update(table, values, where: where, whereArgs: whereArgs);
    } catch (e) {
      if (e.toString().contains("SQLITE_FULL") || e.toString().contains("database or disk is full")) {
        debugPrint("[DatabaseHelper] CRITICAL: Disk full during update. Data NOT saved.");
        return -1;
      }
      rethrow;
    }
  }

  /// Queries rows from the database.
  /// This wrapper is needed because `Repository` calls `db.query`.
  Future<List<Map<String, dynamic>>> query(String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await instance.database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Deletes any models from the local DB that are not present in the provided set of IDs.
  Future<void> deleteModelsNotIn(Set<String> validIds) async {
    if (validIds.isEmpty) return;
    try {
      final db = await instance.database;
      final placeholders = List.filled(validIds.length, '?').join(',');
      await db.delete(
        'models',
        where: 'id NOT IN ($placeholders)',
        whereArgs: validIds.toList(),
      );
    } catch (e) {
      if (e.toString().contains("SQLITE_FULL")) return; // Ignore disk full on delete
      rethrow;
    }
  }

  /// Deletes all user-created models from the local database.
  Future<void> deleteUserCreatedModels() async {
    try {
      final db = await instance.database;
      final count = await db.delete(
        'models',
        where: "id LIKE 'self_%' OR id LIKE 'local_%'",
      );
      debugPrint("[DatabaseHelper] Logout cleanup: Deleted $count user-created models to protect privacy.");
    } catch (e) {
      if (e.toString().contains("SQLITE_FULL")) return;
      rethrow;
    }
  }

  /// Deletes rows from the specified table based on a 'where' clause.
  Future<int> delete(String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final db = await database;
      final count = await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      debugPrint("[DatabaseHelper] Deleted $count rows from '$table' where: $where");
      return count;
    } catch (e) {
      if (e.toString().contains("SQLITE_FULL") || e.toString().contains("database or disk is full")) {
        debugPrint("[DatabaseHelper] Disk full error during delete (journal write failed). Ignoring.");
        return 0;
      }
      rethrow;
    }
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

  /// Call this method occasionally (e.g., after sync).
  Future<void> optimizeDatabase() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
      debugPrint("[DatabaseHelper] Database vacuumed and optimized (Disk Space Reclaimed).");
    } catch (e) {
      debugPrint("[DatabaseHelper] Optimization failed (likely disk full or locked): $e");
    }
  }
}