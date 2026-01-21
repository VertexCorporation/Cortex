// lib/chat/services/storage.dart

import 'dart:async';
import 'dart:convert';
import 'package:cortex/cache.dart';
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

  static bool isFluxMode = false;

  static Future<void> saveConversation(String id,
      String title,
      List<dynamic> _, {
        String? modelId,
        bool isStarred = false,
      }) async {
    if (isFluxMode) return;
    try {
      final db = await DbHelper().db;
      await db.insert(
        'conversations',
        {
          'id': id,
          'title': title,
          'modelId': modelId,
          'isStarred': isStarred ? 1 : 0,
          'lastMessageDate': DateTime
              .now()
              .millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      AppDataState().markUserDataAsChanged();
    } catch (e) {
      _handleDiskError(e, 'saveConversation');
    }
  }

  // --- FEATURE: Deep Search ---
  /// Searches for conversations containing messages matching the query.
  /// Returns a list of conversation IDs.
  static Future<List<String>> searchConversations(
      {required String query}) async {
    if (query
        .trim()
        .isEmpty) {
      return [];
    }

    try {
      final db = await DbHelper().db;
      final results = await db.rawQuery(
        'SELECT DISTINCT conversationId FROM messages WHERE text LIKE ?',
        ['%$query%'],
      );

      return results.map((row) => row['conversationId'] as String).toList();
    } catch (e) {
      debugPrint("[Storage] Error searching conversations: $e");
      return [];
    }
  }

  static Future<void> addRecentModel(String modelId, {
    required String langCode,
    required ModelService modelService,
  }) async {
    final String modelSeriesId =
    modelService.getBaseIdFromFullId(modelId, langCode: langCode);

    final allModels = modelService.getCachedModelsSync();
    final bool isValidSeriesId = allModels.any((m) => m.id == modelSeriesId);

    if (modelSeriesId.isEmpty || !isValidSeriesId) {
      debugPrint(
          "[Storage] FAILED to add recent model. Could not resolve a valid series ID from '$modelId'.");
      return;
    }

    try {
      final db = await DbHelper().db;
      await db.insert(
        'recent_models',
        {
          'model_id': modelSeriesId,
          'last_used': DateTime
              .now()
              .millisecondsSinceEpoch
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      CacheService.invalidate(CacheKey.recentModels);
      debugPrint("[Storage] Added/Updated '$modelSeriesId' in recent models.");
    } catch (e) {
      _handleDiskError(e, 'addRecentModel');
    }
  }

  static Future<List<String>> getRecentModelSeriesIds({
    required String langCode,
    required ModelService modelService,
  }) async {
    final db = await DbHelper().db;
    final List<Map<String, dynamic>> rows = await db.query('recent_models',
        columns: ['model_id'], orderBy: 'last_used DESC', limit: 10);

    if (rows.isEmpty) return [];

    List<ModelEntity> allAvailableModels = modelService.getCachedModelsSync();
    if (allAvailableModels.isEmpty) {
      debugPrint(
          "[Storage] Master model cache is empty. Awaiting initial load...");
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
        debugPrint(
            "[Storage] Ignoring recent model '$modelIdFromDb' because it no longer exists.");
      }
      if (recentSeriesIds.length >= 3) break;
    }

    return recentSeriesIds.toList();
  }

  static Future<void> _updateConversationTimestamp(String convId,
      Database db) async {
    if (isFluxMode) return;
    try {
      await db.update(
        'conversations',
        {'lastMessageDate': DateTime
            .now()
            .millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [convId],
      );
    } catch (e) {
      _handleDiskError(e, '_updateConversationTimestamp');
    }
  }

  static Future<void> updateConversationModelId(String id,
      String newModelId) async {
    if (isFluxMode) return;
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

  static Future<void> updateStoredMessage(String convId, Message m,
      int idx) async {
    if (isFluxMode) return;
    try {
      final db = await DbHelper().db;

      // LOGIC UPDATE: Serialize attachment paths
      String? serializedAttachments;
      if (m.attachmentPaths.isNotEmpty) {
        serializedAttachments = jsonEncode(m.attachmentPaths);
      }

      await db.update(
        'messages',
        {
          'uuid': m.id,
          'text': m.text,
          'isUser': m.isUserMessage ? 1 : 0,
          'isReported': m.isReported ? 1 : 0,
          // Store the JSON string in the existing column
          'photoPath': serializedAttachments,
          'model': m.model,
          'includeInContext': m.includeInContext ? 1 : 0,
          'ts': DateTime
              .now()
              .millisecondsSinceEpoch,
        },
        where: 'conversationId = ? AND idx = ?',
        whereArgs: [convId, idx],
      );
      await _updateConversationTimestamp(convId, db);
    } catch (e) {
      _handleDiskError(e, 'updateStoredMessage');
    }
  }

  static Future<void> saveCurrentMessages(String convId,
      List<Message> msgs) async {
    if (isFluxMode) return;
    try {
      final db = await DbHelper().db;
      final batch = db.batch();
      batch.delete(
          'messages', where: 'conversationId = ?', whereArgs: [convId]);

      for (int i = 0; i < msgs.length; i++) {
        final m = msgs[i];

        // LOGIC UPDATE: Serialize attachment paths
        String? serializedAttachments;
        if (m.attachmentPaths.isNotEmpty) {
          serializedAttachments = jsonEncode(m.attachmentPaths);
        }

        batch.insert('messages', {
          'uuid': m.id,
          'conversationId': convId,
          'idx': i,
          'isUser': m.isUserMessage ? 1 : 0,
          'text': m.text,
          'photoPath': serializedAttachments, // Store JSON here
          'isReported': m.isReported ? 1 : 0,
          'model': m.model,
          'includeInContext': m.includeInContext ? 1 : 0,
          'ts': DateTime
              .now()
              .millisecondsSinceEpoch,
        });
      }
      await batch.commit(noResult: true);

      if (msgs.isNotEmpty) {
        await _updateConversationTimestamp(convId, db);
        final lastMessage = msgs.last;

        // Helper to get a displayable path for the stream (usually just the first one or null)
        final displayPath = lastMessage.attachmentPaths.isNotEmpty
            ? lastMessage.attachmentPaths.first
            : null;

        _lastMsgController.add({
          'convId': convId,
          'text': lastMessage.text,
          'photoPath': displayPath,
          // Stream listeners might expect a single path or null
          'ts': DateTime
              .now()
              .millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      _handleDiskError(e, 'saveCurrentMessages');
    }
  }

  /* ---------- helpers ---------- */

  static Future<Map<String, dynamic>?> getLastMessage(
      String conversationID) async {
    final db = await DbHelper().db;
    final rows = await db.query(
      'messages',
      where:
      'conversationId = ? AND ((text IS NOT NULL AND TRIM(text) != \'\') OR (photoPath IS NOT NULL AND photoPath != \'\'))',
      whereArgs: [conversationID],
      orderBy: 'idx DESC',
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  static Future<List<Message>> removeEmptyMessagesForConversation(String convId,
      List<Message> inMemory) async {
    try {
      final db = await DbHelper().db;
      await db.delete('messages',
          where:
          'conversationId = ? AND text = "" AND (photoPath IS NULL OR photoPath="")',
          whereArgs: [convId]);
    } catch (e) {
      _handleDiskError(e, 'removeEmptyMessagesForConversation');
    }

    // Logic Update: Check hasAttachments
    return inMemory
        .where((m) =>
    m.text
        .trim()
        .isNotEmpty || m.hasAttachments)
        .toList();
  }

  static Future<Map<String, dynamic>?> getMessageByIdx(String convId,
      int idx) async {
    final db = await DbHelper().db;
    final rows = await db.query(
      'messages',
      where: 'conversationId = ? AND idx = ?',
      whereArgs: [convId, idx],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  static Future<void> upsertMessage(String convId, int idx, Message m) async {
    if (isFluxMode) return;
    try {
      final db = await DbHelper().db;

      String? serializedAttachments;
      if (m.attachmentPaths.isNotEmpty) {
        serializedAttachments = jsonEncode(m.attachmentPaths);
      }

      final messageData = {
        'uuid': m.id,
        'conversationId': convId,
        'idx': idx,
        'isUser': m.isUserMessage ? 1 : 0,
        'text': m.text,
        'photoPath': serializedAttachments,
        'isReported': m.isReported ? 1 : 0,
        'model': m.model,
        'includeInContext': m.includeInContext ? 1 : 0,
        'ts': DateTime
            .now()
            .millisecondsSinceEpoch,
      };

      await db.insert(
        'messages',
        messageData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await _updateConversationTimestamp(convId, db);
      final now = DateTime
          .now()
          .millisecondsSinceEpoch;

      final displayPath = m.attachmentPaths.isNotEmpty
          ? m.attachmentPaths.first
          : null;

      _lastMsgController.add({
        'convId': convId,
        'text': m.text,
        'photoPath': displayPath,
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

      CacheService.invalidateConversationCache();
      CacheService.invalidate(CacheKey.recentModels);

      AppDataState().markUserDataAsChanged();
    } catch (e) {
      _handleDiskError(e, 'deleteConversation');
    }
  }

  static Future<void> deleteConversationsForModel(String modelId) async {
    try {
      final db = await DbHelper().db;
      final List<Map<String, dynamic>> convsToDelete = await db.query(
        'conversations',
        columns: ['id'],
        where: 'modelId = ?',
        whereArgs: [modelId],
      );

      if (convsToDelete.isEmpty) {
        return;
      }

      final List<String> convIds =
      convsToDelete.map((row) => row['id'] as String).toList();

      await db.transaction((txn) async {
        final placeholders = List.filled(convIds.length, '?').join(',');
        await txn.delete(
          'messages',
          where: 'conversationId IN ($placeholders)',
          whereArgs: convIds,
        );
        await txn.delete(
          'conversations',
          where: 'id IN ($placeholders)',
          whereArgs: convIds,
        );
      });
      CacheService.invalidateConversationCache();
      CacheService.invalidate(CacheKey.recentModels);

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

      AppDataState().markUserDataAsChanged();
    } catch (e) {
      _handleDiskError(e, 'renameConversation');
    }
  }

  static Future<void> deleteAllConversations() async {
    try {
      final db = await DbHelper().db;
      debugPrint(
          "[ChatStorage] Deleting all conversations, messages, and recent models history.");

      await db.transaction((txn) async {
        await txn.delete('messages');
        await txn.delete('conversations');
        await txn.delete('recent_models');
      });

      debugPrint("[ChatStorage] All chat data successfully deleted.");

      CacheService.invalidateConversationCache();
      CacheService.invalidate(CacheKey.recentModels);

      AppDataState().markUserDataAsChanged();

      await DbHelper().optimizeDatabase();
    } catch (e) {
      _handleDiskError(e, 'deleteAllConversations');
    }
  }

  static Future<bool> hasAnyConversations() async {
    final db = await DbHelper().db;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM conversations'));
    return count != null && count > 0;
  }

  static void _handleDiskError(Object e, String operationName) {
    if (e.toString().contains("SQLITE_FULL") ||
        e.toString().contains("database or disk is full")) {
      debugPrint(
          "[ChatStorage] CRITICAL: Device storage is full. '$operationName' failed. Data was NOT saved to prevent crash.");
    } else {
      debugPrint("[ChatStorage] Unexpected error in '$operationName': $e");
      throw e;
    }
  }
}