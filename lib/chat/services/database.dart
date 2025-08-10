// database.dart (or wherever DbHelper is defined)

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _i = DbHelper._internal();
  factory DbHelper() => _i;
  DbHelper._internal();

  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'chat.sqlite');
    _db = await openDatabase(
      path,
      // UPDATED: Increment the version from 2 to 3.
      // This is crucial to trigger the onUpgrade for existing users.
      version: 3,
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE conversations (
            id       TEXT PRIMARY KEY,
            title    TEXT,
            modelId  TEXT,
            isStarred INTEGER DEFAULT 0,
            -- NEW: Add the sorting column for new installations.
            lastMessageDate INTEGER DEFAULT 0
          );
        ''');
        await d.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversationId TEXT,
            idx INTEGER,
            text TEXT,
            isUser INTEGER,
            photoPath TEXT,
            isReported INTEGER,
            model TEXT,
            includeInContext INTEGER,
            ts INTEGER
          );
        ''');
        await d.execute('''
          CREATE UNIQUE INDEX messages_conv_idx
          ON messages(conversationId, idx);
        ''');
      },
      onUpgrade: (d, oldV, newV) async {
        // This block handles upgrades for existing users.
        if (oldV < 2) {
          // This migration has already run for version 2 users, but we keep it for safety.
          await d.execute('ALTER TABLE conversations ADD COLUMN isStarred INTEGER DEFAULT 0;');
        }
        if (oldV < 3) {
          // NEW: This is our new migration. It will run for users on version 1 and 2.
          // It adds the lastMessageDate column to the existing conversations table.
          await d.execute('ALTER TABLE conversations ADD COLUMN lastMessageDate INTEGER DEFAULT 0;');
        }
        // The index creation was part of a previous migration. No need to change it.
        // It was originally under oldV < 3, which is now our new migration block. Let's keep it safe.
        if (oldV < 2) { // Assuming index was also part of v2 migration logic
          await d.execute('''
                CREATE UNIQUE INDEX IF NOT EXISTS messages_conv_idx
                ON messages(conversationId, idx);
              ''');
        }
      },
    );
    return _db!;
  }
}