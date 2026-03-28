// lib/chat/services/database.dart

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _i = DbHelper._internal();
  factory DbHelper() => _i;
  DbHelper._internal();

  Database? _db;
  static const int _latestVersion = 7; // Define the latest version here

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'chat.sqlite');
    _db = await openDatabase(
      path,
      version: _latestVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  // This function is called ONLY when the database is created for the very first time.
  // It should contain the schema for the LATEST version.
  Future<void> _onCreate(Database d, int v) async {
    debugPrint("[Database] onCreate: Creating new database with version $v");
    await d.execute('''
      CREATE TABLE conversations (
        id              TEXT PRIMARY KEY,
        title           TEXT,
        modelId         TEXT,
        isStarred       INTEGER DEFAULT 0,
        starredDate     INTEGER DEFAULT 0,
        lastMessageDate INTEGER DEFAULT 0
      );
    ''');
    await d.execute('''
      CREATE TABLE messages (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid              TEXT,
        conversationId    TEXT,
        idx               INTEGER,
        text              TEXT,
        isUser            INTEGER,
        photoPath         TEXT,
        isReported        INTEGER,
        model             TEXT,
        includeInContext  INTEGER,
        ts                INTEGER,
        webSearchSources  TEXT
      );
    ''');
    await d.execute('''
      CREATE UNIQUE INDEX messages_conv_idx
      ON messages(conversationId, idx);
    ''');
    await d.execute('''
      CREATE TABLE recent_models (
        model_id    TEXT PRIMARY KEY,
        last_used   INTEGER
      );
    ''');
  }

  // This function is called when a user with an OLDER database version opens the app.
  // It applies all necessary changes step-by-step.
  Future<void> _onUpgrade(Database d, int oldV, int newV) async {
    debugPrint("[Database] onUpgrade: Upgrading from version $oldV to $newV");
    var batch = d.batch();

    for (var i = oldV; i < newV; i++) {
      debugPrint("[Database] Applying migration for version ${i + 1}");
      switch (i + 1) {
        case 2:
          batch.execute(
              'ALTER TABLE conversations ADD COLUMN isStarred INTEGER DEFAULT 0;');
          batch.execute('''
            CREATE UNIQUE INDEX IF NOT EXISTS messages_conv_idx
            ON messages(conversationId, idx);
          ''');
          break;
        case 3:
          batch.execute(
              'ALTER TABLE conversations ADD COLUMN lastMessageDate INTEGER DEFAULT 0;');
          break;
        case 4:
          batch.execute('ALTER TABLE messages ADD COLUMN uuid TEXT;');
          break;
        case 5:
          batch.execute('''
            CREATE TABLE recent_models (
              model_id    TEXT PRIMARY KEY,
              last_used   INTEGER
            );
          ''');
          break;
        case 6:
          batch.execute(
              'ALTER TABLE conversations ADD COLUMN starredDate INTEGER DEFAULT 0;');
          break;
        case 7:
          batch.execute('ALTER TABLE messages ADD COLUMN webSearchSources TEXT;');
          break;
      }
    }
    await batch.commit();
    debugPrint("[Database] onUpgrade: All migrations successfully applied.");
  }

  /// Compresses the database and cleans up unused space (Disk Saver).
  /// Call this method occasionally (e.g., after heavy deletions or sync).
  Future<void> optimizeDatabase() async {
    try {
      // Ensure the database is initialized
      if (_db == null) await db;

      await _db!.execute('VACUUM');
      debugPrint(
          "[DatabaseHelper] Database vacuumed and optimized (Disk Space Reclaimed).");
    } catch (e) {
      debugPrint(
          "[DatabaseHelper] Optimization failed (likely disk full or locked): $e");
    }
  }
}
