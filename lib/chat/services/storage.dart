// chat/services/storage.dart

import 'dart:async';
import 'package:cortex/cache.dart'; // Added for cache invalidation
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import 'database.dart';
import '../messages/messages.dart';

class ChatStorageService {
  /* ---------- conversation ---------- */
  static final _lastMsgController =
  StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get lastMsgStream =>
      _lastMsgController.stream;

  static Future<void> saveConversation(
      String id,
      String title,
      List<dynamic> _,
      {String? modelId, bool isStarred = false}
      ) async {
    final db = await DbHelper().db;
    await db.insert(
      'conversations',
      {
        'id': id,
        'title': title,
        'modelId': modelId,
        'isStarred': isStarred ? 1 : 0,
        'lastMessageDate': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    AppDataState().markUserDataAsChanged();
  }

  /// This function is called after a successful message send to mark a model as "used".
  /// It now intelligently ensures that only a valid MODEL SERIES ID is saved,
  /// preventing producer names or full variant IDs from being stored.
  static Future<void> addRecentModel(
      String modelId, {
        required String langCode,
        required ModelService modelService,
      }) async {
    final String modelSeriesId = modelService.getBaseIdFromFullId(modelId, langCode: langCode);

    final allModels = modelService.getCachedModelsSync();
    final bool isValidSeriesId = allModels.any((m) => m.id == modelSeriesId);

    if (modelSeriesId.isEmpty || !isValidSeriesId) {
      debugPrint("[Storage] FAILED to add recent model. Could not resolve a valid series ID from '$modelId'.");
      return;
    }

    final db = await DbHelper().db;
    await db.insert(
      'recent_models',
      {'model_id': modelSeriesId, 'last_used': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    CacheService.invalidate(CacheKey.recentModels);
    debugPrint("[Storage] Added/Updated '$modelSeriesId' in recent models.");
  }

  /// It fetches the top 10 most recently used model IDs and validates them
  /// against the currently available models to ensure they still exist.
  /// CRITICAL FIX: This function is now async and ensures the master model list
  /// from ModelService() is loaded before attempting validation. This prevents a race
  /// condition at startup where recent models would be incorrectly filtered out.
  static Future<List<String>> getRecentModelSeriesIds({
    required String langCode,
    required ModelService modelService,
  }) async {
    final db = await DbHelper().db;
    final List<Map<String, dynamic>> rows = await db.query(
        'recent_models', columns: ['model_id'], orderBy: 'last_used DESC', limit: 10);

    if (rows.isEmpty) return [];

    // Use the provided modelService instance.
    List<ModelEntity> allAvailableModels = modelService.getCachedModelsSync();
    if (allAvailableModels.isEmpty) {
      debugPrint("[Storage] Master model cache is empty. Awaiting initial load...");
      final loadedModels = await modelService.getModels(langCode: langCode);
      allAvailableModels = loadedModels ?? [];
    }

    final recentSeriesIds = <String>{};
    final availableSeriesIds = allAvailableModels.map((m) => m.id).toSet();

    for (final row in rows) {
      final modelIdFromDb = row['model_id'] as String?;
      if (modelIdFromDb == null) continue;

      if (availableSeriesIds.contains(modelIdFromDb)) {
        recentSeriesIds.add(modelIdFromDb);
      } else {
        debugPrint("[Storage] Ignoring recent model '$modelIdFromDb' because it no longer exists.");
      }
      if (recentSeriesIds.length >= 3) break;
    }

    return recentSeriesIds.toList();
  }

  static Future<void> _updateConversationTimestamp(String convId, Database db) async {
    await db.update(
      'conversations',
      {'lastMessageDate': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [convId],
    );
  }

  static Future<void> updateConversationModelId(
      String id, String newModelId) async {
    final db = await DbHelper().db;
    await db.update(
      'conversations',
      {'modelId': newModelId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /* ---------- messages (append / update) ---------- */

  static Future<void> updateStoredMessage(
      String convId, Message m, int idx) async {
    final db = await DbHelper().db;
    await db.update(
      'messages',
      {
        'uuid': m.id,
        'text': m.text,
        'isUser': m.isUserMessage ? 1 : 0,
        'isReported': m.isReported ? 1 : 0,
        'photoPath': m.photoPath,
        'model': m.model,
        'includeInContext': m.includeInContext ? 1 : 0,
        'ts': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'conversationId = ? AND idx = ?',
      whereArgs: [convId, idx],
    );
    await _updateConversationTimestamp(convId, db);
  }

  static Future<void> saveCurrentMessages(
      String convId, List<Message> msgs) async {
    final db = await DbHelper().db;
    final batch = db.batch();
    batch.delete('messages', where: 'conversationId = ?', whereArgs: [convId]);
    for (int i = 0; i < msgs.length; i++) {
      final m = msgs[i];
      batch.insert('messages', {
        'uuid': m.id,
        'conversationId': convId,
        'idx': i,
        'isUser': m.isUserMessage ? 1 : 0,
        'text': m.text,
        'photoPath': m.photoPath,
        'isReported': m.isReported ? 1 : 0,
        'model': m.model,
        'includeInContext': m.includeInContext ? 1 : 0,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
    }
    await batch.commit(noResult: true);
    if (msgs.isNotEmpty) {
      await _updateConversationTimestamp(convId, db);

      final lastMessage = msgs.last;

      _lastMsgController.add({
        'convId': convId,
        'text': lastMessage.text,
        'photoPath': lastMessage.photoPath,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  /* ---------- helpers ---------- */

  static Future<Map<String, dynamic>?> getLastMessage(String conversationID) async {
    final db = await DbHelper().db;
    final rows = await db.query(
      'messages',
      where: 'conversationId = ? AND ((text IS NOT NULL AND TRIM(text) != \'\') OR (photoPath IS NOT NULL AND photoPath != \'\'))',
      whereArgs: [conversationID],
      orderBy: 'idx DESC',
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  static Future<List<Message>> removeEmptyMessagesForConversation(
      String convId, List<Message> inMemory) async {
    final db = await DbHelper().db;
    await db.delete('messages',
        where: 'conversationId = ? AND text = "" AND (photoPath IS NULL OR photoPath="")',
        whereArgs: [convId]);
    return inMemory
        .where((m) =>
    m.text.trim().isNotEmpty ||
        (m.photoPath != null && m.photoPath!.trim().isNotEmpty))
        .toList();
  }

  /// Removes a specific model ID from the 'recent_models' table.
  /// This is called when a model is deleted or uninstalled to keep the list consistent.
  static Future<void> removeRecentModel(String modelId) async {
    final db = await DbHelper().db;
    await db.delete(
      'recent_models',
      where: 'model_id = ?',
      whereArgs: [modelId],
    );
    CacheService.invalidate(CacheKey.recentModels);
    debugPrint("[Storage] Removed '$modelId' from recent models.");
  }

  static Future<Map<String, dynamic>?> getMessageByIdx(
      String convId, int idx) async {
    final db = await DbHelper().db;
    final rows = await db.query(
      'messages',
      where: 'conversationId = ? AND idx = ?',
      whereArgs: [convId, idx],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  static Future<void> upsertMessage(
      String convId, int idx, Message m) async {
    final db = await DbHelper().db;
    final messageData = {
      'uuid': m.id,
      'conversationId': convId,
      'idx': idx,
      'isUser': m.isUserMessage ? 1 : 0,
      'text': m.text,
      'photoPath': m.photoPath,
      'isReported': m.isReported ? 1 : 0,
      'model': m.model,
      'includeInContext': m.includeInContext ? 1 : 0,
      'ts': DateTime.now().millisecondsSinceEpoch,
    };

    await db.insert(
      'messages',
      messageData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _updateConversationTimestamp(convId, db); // Await this operation
    final now = DateTime.now().millisecondsSinceEpoch;

    _lastMsgController.add({
      'convId': convId,
      'text': m.text,
      'photoPath': m.photoPath,
      'ts': now,
    });
  }

  static Future<void> deleteConversation(String id) async {
    final db = await DbHelper().db;
    await db.delete('messages', where: 'conversationId = ?', whereArgs: [id]);
    await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
    // This helper invalidates all conversation-related cache entries at once.
    CacheService.invalidateConversationCache();
    // Also invalidate recent models, as a deleted conversation might affect this list.
    CacheService.invalidate(CacheKey.recentModels);

    // Notify that the conversation list has structurally changed.
    AppDataState().markUserDataAsChanged();
  }


  /// Atomically deletes all conversations (and their messages) associated with a specific model ID.
  /// This is used when a model is uninstalled or deleted by the user.
  static Future<void> deleteConversationsForModel(String modelId) async {
    final db = await DbHelper().db;
    // Step 1: Find all conversation IDs that use this model.
    final List<Map<String, dynamic>> convsToDelete = await db.query(
      'conversations',
      columns: ['id'],
      where: 'modelId = ?',
      whereArgs: [modelId],
    );

    if (convsToDelete.isEmpty) {
      return; // Nothing to do.
    }

    final List<String> convIds =
    convsToDelete.map((row) => row['id'] as String).toList();

    // Step 2: Use a transaction to ensure both deletions succeed or fail together.
    await db.transaction((txn) async {
      final placeholders = List.filled(convIds.length, '?').join(',');
      // Delete all messages belonging to these conversations.
      await txn.delete(
        'messages',
        where: 'conversationId IN ($placeholders)',
        whereArgs: convIds,
      );
      // Delete the conversations themselves.
      await txn.delete(
        'conversations',
        where: 'id IN ($placeholders)',
        whereArgs: convIds,
      );
    });
    // After deletion, invalidate the caches to force a UI refresh.
    CacheService.invalidateConversationCache();
    CacheService.invalidate(CacheKey.recentModels);

    // Let the rest of the app know that the conversation list changed.
    AppDataState().markUserDataAsChanged();
  }

  static Future<void> setStarred(String id, bool starred) async {
    final db = await DbHelper().db;
    await db.update(
      'conversations',
      {'isStarred': starred ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    // Star/unstar should be reflected in the inbox immediately.
    AppDataState().markUserDataAsChanged();
  }

  static Future<void> renameConversation(String id, String newTitle) async {
    final db = await DbHelper().db;
    await db.update(
      'conversations',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [id],
    );

    // This also affects inbox data; mark it as changed.
    AppDataState().markUserDataAsChanged();
  }

  /// Atomically deletes ALL conversations and their associated messages from the local database.
  /// This provides a clean slate for the user, matching their expectation of the "Delete All" action.
  static Future<void> deleteAllConversations() async {
    final db = await DbHelper().db;
    debugPrint("[ChatStorage] Deleting all conversations and messages from the database.");

    // Use a transaction to ensure both tables are cleared atomically.
    // If one deletion fails, the other is rolled back.
    await db.transaction((txn) async {
      await txn.delete('messages');       // Deletes all rows from the messages table
      await txn.delete('conversations');  // Deletes all rows from the conversations table
    });

    debugPrint("[ChatStorage] All conversations successfully deleted.");

    // Invalidate caches to force a full UI refresh.
    CacheService.invalidateConversationCache();

    AppDataState().markUserDataAsChanged();
  }

  /// Checks if there are any conversations stored locally using sqflite.
  static Future<bool> hasAnyConversations() async {
    final db = await DbHelper().db;
    // Use Sqflite.firstIntValue to get a single integer result, which is more efficient.
    // This query counts the number of rows in the 'conversations' table.
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM conversations')
    );
    // If the count is null or 0, there are no conversations.
    return count != null && count > 0;
  }
}