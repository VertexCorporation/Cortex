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
    try {
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
    } catch (e) {
      _handleDiskError(e, 'saveConversation');
    }
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

    try {
      final db = await DbHelper().db;
      await db.insert(
        'recent_models',
        {'model_id': modelSeriesId, 'last_used': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      CacheService.invalidate(CacheKey.recentModels);
      debugPrint("[Storage] Added/Updated '$modelSeriesId' in recent models.");
    } catch (e) {
      _handleDiskError(e, 'addRecentModel');
    }
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
    try {
      await db.update(
        'conversations',
        {'lastMessageDate': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [convId],
      );
    } catch (e) {
      _handleDiskError(e, '_updateConversationTimestamp');
    }
  }

  static Future<void> updateConversationModelId(
      String id, String newModelId) async {
    try {
      final db = await DbHelper().db;
      await db.update(
        'conversations',
        {'modelId': newModelId},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _handleDiskError(e, 'updateConversationModelId');
    }
  }

  /* ---------- messages (append / update) ---------- */

  static Future<void> updateStoredMessage(
      String convId, Message m, int idx) async {
    try {
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
    } catch (e) {
      _handleDiskError(e, 'updateStoredMessage');
    }
  }

  static Future<void> saveCurrentMessages(
      String convId, List<Message> msgs) async {
    try {
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
    } catch (e) {
      _handleDiskError(e, 'saveCurrentMessages');
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
    try {
      final db = await DbHelper().db;
      await db.delete('messages',
          where: 'conversationId = ? AND text = "" AND (photoPath IS NULL OR photoPath="")',
          whereArgs: [convId]);
    } catch (e) {
      _handleDiskError(e, 'removeEmptyMessagesForConversation');
    }

    return inMemory
        .where((m) =>
    m.text.trim().isNotEmpty ||
        (m.photoPath != null && m.photoPath!.trim().isNotEmpty))
        .toList();
  }

  /// Removes a specific model ID from the 'recent_models' table.
  /// This is called when a model is deleted or uninstalled to keep the list consistent.
  static Future<void> removeRecentModel(String modelId) async {
    try {
      final db = await DbHelper().db;
      await db.delete(
        'recent_models',
        where: 'model_id = ?',
        whereArgs: [modelId],
      );
      CacheService.invalidate(CacheKey.recentModels);
      debugPrint("[Storage] Removed '$modelId' from recent models.");
    } catch (e) {
      _handleDiskError(e, 'removeRecentModel');
    }
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
    try {
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

      await _updateConversationTimestamp(convId, db);
      final now = DateTime.now().millisecondsSinceEpoch;

      _lastMsgController.add({
        'convId': convId,
        'text': m.text,
        'photoPath': m.photoPath,
        'ts': now,
      });
    } catch (e) {
      _handleDiskError(e, 'upsertMessage');
    }
  }

  static Future<void> deleteConversation(String id) async {
    try {
      final db = await DbHelper().db;
      await db.delete('messages', where: 'conversationId = ?', whereArgs: [id]);
      await db.delete('conversations', where: 'id = ?', whereArgs: [id]);

      // This helper invalidates all conversation-related cache entries at once.
      CacheService.invalidateConversationCache();
      // Also invalidate recent models, as a deleted conversation might affect this list.
      CacheService.invalidate(CacheKey.recentModels);

      // Notify that the conversation list has structurally changed.
      AppDataState().markUserDataAsChanged();
    } catch (e) {
      _handleDiskError(e, 'deleteConversation');
    }
  }


  /// Atomically deletes all conversations (and their messages) associated with a specific model ID.
  /// This is used when a model is uninstalled or deleted by the user.
  static Future<void> deleteConversationsForModel(String modelId) async {
    try {
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
    } catch (e) {
      _handleDiskError(e, 'deleteConversationsForModel');
    }
  }

  static Future<void> setStarred(String id, bool starred) async {
    try {
      final db = await DbHelper().db;
      await db.update(
        'conversations',
        {'isStarred': starred ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );

      // Star/unstar should be reflected in the inbox immediately.
      AppDataState().markUserDataAsChanged();
    } catch (e) {
      _handleDiskError(e, 'setStarred');
    }
  }

  static Future<void> renameConversation(String id, String newTitle) async {
    try {
      final db = await DbHelper().db;
      await db.update(
        'conversations',
        {'title': newTitle},
        where: 'id = ?',
        whereArgs: [id],
      );

      // This also affects inbox data; mark it as changed.
      AppDataState().markUserDataAsChanged();
    } catch (e) {
      _handleDiskError(e, 'renameConversation');
    }
  }

  /// Atomically deletes ALL conversations, their associated messages, AND recent models history.
  /// This provides a complete clean slate for the user.
  static Future<void> deleteAllConversations() async {
    try {
      final db = await DbHelper().db;
      debugPrint("[ChatStorage] Deleting all conversations, messages, and recent models history.");

      // Use a transaction to ensure all tables are cleared atomically.
      // If one deletion fails, everything rolls back.
      await db.transaction((txn) async {
        await txn.delete('messages');       // Delete messages
        await txn.delete('conversations');  // Delete conversations
        await txn.delete('recent_models');  // Delete recent model history
      });

      debugPrint("[ChatStorage] All chat data successfully deleted.");

      // Invalidate caches to force a full UI refresh.
      CacheService.invalidateConversationCache();
      CacheService.invalidate(CacheKey.recentModels);

      AppDataState().markUserDataAsChanged();

      // Trigger VACUUM to reclaim disk space after bulk delete
      await DbHelper().optimizeDatabase();

    } catch (e) {
      _handleDiskError(e, 'deleteAllConversations');
    }
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

  /// Centralized error handler for database write operations.
  /// If the error is SQLITE_FULL, it logs a critical warning but prevents the app from crashing.
  static void _handleDiskError(Object e, String operationName) {
    if (e.toString().contains("SQLITE_FULL") || e.toString().contains("database or disk is full")) {
      debugPrint("[ChatStorage] CRITICAL: Device storage is full. '$operationName' failed. Data was NOT saved to prevent crash.");
      // In a real-world app, you might want to show a toast to the user here,
      // but keeping the service UI-agnostic is generally better practice.
    } else {
      debugPrint("[ChatStorage] Unexpected error in '$operationName': $e");
      // Rethrow other errors (syntax, schema issues) so they can be fixed during dev
      throw e;
    }
  }
}