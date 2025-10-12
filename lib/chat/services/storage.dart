// chat/services/storage.dart

import 'dart:async';
import 'package:cortex/cache.dart'; // Added for cache invalidation
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/backend/data.dart';
import 'database.dart';
import '../messages/messages.dart';

class ChatStorageService {
  /* ---------- conversation ---------- */
  static final _lastMsgController =
  StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get lastMsgStream =>
      _lastMsgController.stream;

  static Future<void> saveConversation(
      String id, String title, List<dynamic> _,
      {String? modelId, bool isStarred = false}) async {
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
  }

  /// This function is called after a successful message send to mark a model as "used".
  /// Using `ConflictAlgorithm.replace` provides an efficient "upsert" operation.
  static Future<void> addRecentModel(String modelSeriesId) async {
    final db = await DbHelper().db;
    await db.insert(
      'recent_models',
      {
        'model_id': modelSeriesId,
        'last_used': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Invalidate the cache to ensure the UI re-fetches the updated list.
    CacheService.invalidateRecentModelsCache();
    debugPrint("[Storage] Added/Updated '$modelSeriesId' in recent models.");
  }

  /// It fetches the top 3 most recently used model IDs directly from the new
  /// 'recent_models' table and validates them against the currently available models.
  static Future<List<String>> getRecentModelSeriesIds() async {
    final db = await DbHelper().db;
    // Query the new table, ordered by the last used timestamp.
    final List<Map<String, dynamic>> rows = await db.query(
      'recent_models',
      columns: ['model_id'],
      orderBy: 'last_used DESC',
      limit: 10, // Fetch a few extra to account for potentially deleted models.
    );

    final recentSeriesIds = <String>{};
    final allAvailableModels = ModelData.getCachedModelsSync();
    // Create a set of available series IDs for efficient lookup.
    final availableSeriesIds = allAvailableModels.map((m) => m['id'] as String).toSet();

    for (final row in rows) {
      final modelIdFromDb = row['model_id'] as String?;
      if (modelIdFromDb == null) continue;

      // VALIDATION: Ensure the model still exists in the master list.
      if (availableSeriesIds.contains(modelIdFromDb)) {
        recentSeriesIds.add(modelIdFromDb);
      } else {
        debugPrint("[Storage] Ignoring recent model '$modelIdFromDb' because it no longer exists.");
      }

      // Stop when we have found 3 valid recent models.
      if (recentSeriesIds.length >= 3) {
        break;
      }
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
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  /* ---------- helpers ---------- */

  static Future<Map<String, dynamic>?> getLastMessage(String conversationID) async {
    final db = await DbHelper().db;
    final rows = await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationID],
      orderBy: 'ts DESC',
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
    // --- CONSOLIDATED MAP FOR UPSERT ---
    final messageData = {
      'uuid': m.id, // --- ADD: Include the ID in the data map
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

    final updated = await db.update(
      'messages',
      messageData,
      where: 'conversationId = ? AND idx = ?',
      whereArgs: [convId, idx],
    );
    if (updated == 0) {
      await db.insert(
        'messages',
        messageData,
      );
    }
    _updateConversationTimestamp(convId, db);
    final now = DateTime.now().millisecondsSinceEpoch;
    _lastMsgController.add({
      'convId': convId,
      'text': m.text,
      'ts': now,
    });
  }

  static Future<void> deleteConversation(String id) async {
    final db = await DbHelper().db;
    await db.delete('messages', where: 'conversationId = ?', whereArgs: [id]);
    await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
    CacheService.invalidateConversationCache();
    CacheService.invalidateRecentModelsCache();
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

    final List<String> convIds = convsToDelete.map((row) => row['id'] as String).toList();

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
    CacheService.invalidateRecentModelsCache();
  }

  static Future<void> setStarred(String id, bool starred) async {
    final db = await DbHelper().db;
    await db.update('conversations', {'isStarred': starred ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> renameConversation(String id, String newTitle) async {
    final db = await DbHelper().db;
    await db.update('conversations', {'title': newTitle},
        where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes all conversations that are currently VISIBLE to the logged-in user
  /// by checking against their personal "model universe".
  static Future<void> deleteAllConversations() async {
    final db = await DbHelper().db;

    // Step 1: Create the definitive "allow list" of models for the current user.
    final allUserVisibleModels = ModelData.getCachedModelsSync();
    final Set<String> userVisibleModelIds = {};
    for (final model in allUserVisibleModels) {
      userVisibleModelIds.add(model['id'] as String);
      if (model['extensions'] is Map) {
        userVisibleModelIds.addAll((model['extensions'] as Map<String, dynamic>).keys);
      }
    }
    debugPrint("[ChatStorage] Security Gate: User can see ${userVisibleModelIds.length} total model IDs. Deleting associated conversations.");

    // Step 2: Get all conversations from the DB to filter against the allow list.
    final allConversationsInDb = await db.query('conversations', columns: ['id', 'modelId']);
    final List<String> convIdsToDelete = [];

    // Step 3: Iterate and mark for deletion only if the conversation's model is in the user's visible set.
    for (final conv in allConversationsInDb) {
      final modelId = conv['modelId'] as String? ?? '';
      final convId = conv['id'] as String;

      if (userVisibleModelIds.contains(modelId)) {
        convIdsToDelete.add(convId); // This conversation is visible, so it can be deleted.
      } else {
        // This conversation is not visible (belongs to another user), so we leave it alone.
        debugPrint("[ChatStorage] Preserving conversation '$convId' (model: '$modelId'). It is not visible to the current user.");
      }
    }

    if (convIdsToDelete.isEmpty) {
      debugPrint("[ChatStorage] No visible conversations found to delete for the current user.");
      return;
    }

    debugPrint("[ChatStorage] Identified ${convIdsToDelete.length} visible conversations to delete.");

    // Step 4: Atomically delete the marked items.
    await db.transaction((txn) async {
      final placeholders = List.filled(convIdsToDelete.length, '?').join(',');
      await txn.delete(
        'messages',
        where: 'conversationId IN ($placeholders)',
        whereArgs: convIdsToDelete,
      );
      await txn.delete(
        'conversations',
        where: 'id IN ($placeholders)',
        whereArgs: convIdsToDelete,
      );
    });

    CacheService.invalidateConversationCache();
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