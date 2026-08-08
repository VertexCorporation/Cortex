// lib/chat/services/storage.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cortex/cache.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import 'database.dart';
import '../messages/messages.dart';
import 'package:cortex/axon/inbox/logic/search_hit.dart';

class ChatStorageService {
  /* ---------- conversation ---------- */

  static final _titleController =
      StreamController<Map<String, String>>.broadcast();

  static Stream<Map<String, String>> get titleStream => _titleController.stream;

  static final _lastMsgController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get lastMsgStream =>
      _lastMsgController.stream;

  static final _conversationResetController =
      StreamController<void>.broadcast();

  static Stream<void> get conversationResetStream =>
      _conversationResetController.stream;

  static bool isFluxMode = false;

  static Future<void> saveConversation(
    String id,
    String title,
    List<dynamic> _, {
    String? modelId,
    String? modelTitle,
    String? modelImagePath,
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
          'modelTitle': modelTitle ?? '',
          'modelImagePath': modelImagePath ?? '',
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

  // --- FEATURE: Deep Search ---
  /// Searches for conversations containing messages matching the query.
  /// Returns a list of conversation IDs.
  static Future<List<String>> searchConversations(
      {required String query}) async {
    if (query.trim().isEmpty) {
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

  /// Deep search for messages that match the query
  static Future<List<SearchHit>> searchMessagesDeep(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final db = await DbHelper().db;
      if (query.trim().length < 2) return [];

      final results = await db.rawQuery('''
        SELECT 
          m.conversationId, 
          m.text AS snippet, 
          m.ts AS timestamp, 
          c.title 
        FROM messages m 
        JOIN conversations c ON m.conversationId = c.id 
        WHERE instr(m.text, ?) > 0 AND m.text IS NOT NULL AND m.text != ''
        ORDER BY m.ts DESC 
        LIMIT 50
      ''', [query]);

      return results.map((row) {
        return SearchHit(
          conversationId: row['conversationId'] as String,
          title: (row['title'] as String?) ?? 'Sohbet',
          snippet: row['snippet'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
              row['timestamp'] as int? ?? 0),
          query: query,
        );
      }).toList();
    } catch (e) {
      debugPrint("[Storage] Error deep searching messages: $e");
      return [];
    }
  }

  /// Optimized fetch: Gets all conversations joined with their last message details.
  /// Replaces the N+1 loop in InboxViewModel.
  static Future<List<Map<String, dynamic>>>
      getConversationsWithLastMessage() async {
    try {
      final db = await DbHelper().db;
      // We use a LEFT JOIN on the last message for each conversation.
      // Since 'conversations' table has 'lastMessageDate', we usually just need the snippet.
      // However, to be perfectly accurate with the 'lastMsg' logic usually used:
      final results = await db.rawQuery('''
        SELECT 
          c.id, 
          c.title, 
          c.modelId, 
          c.modelTitle,
          c.modelImagePath,
          c.isStarred, 
          c.starredDate, 
          c.lastMessageDate,
          m.text as lastMessageText,
          m.photoPath as lastMessagePhoto,
          m.ts as realLastMessageTs
        FROM conversations c
        LEFT JOIN messages m ON m.idx = (
            SELECT idx FROM messages 
            WHERE conversationId = c.id 
              AND ((text IS NOT NULL AND length(text) > 0) OR (photoPath IS NOT NULL AND length(photoPath) > 0))
            ORDER BY idx DESC LIMIT 1
        )
      ''');
      return results;
    } catch (e) {
      debugPrint("[Storage] Error fetching optimized conversations: $e");
      return [];
    }
  }

  static Future<void> addRecentModel(
    String modelId, {
    required String langCode,
    required ModelService modelService,
  }) async {
    // Virtual cortex models and dynamic don't have entries in the cached model list.
    // Resolve them to their known IDs for storage.
    String resolvedId = modelId;
    if (modelId == 'cortex/auto' || modelId == 'dynamic') {
      resolvedId = 'cortex/auto';
    } else if (modelId == 'cortex/roleplay') {
      resolvedId = 'cortex/roleplay';
    } else {
      final String modelSeriesId =
          modelService.getBaseIdFromFullId(modelId, langCode: langCode);
      if (modelSeriesId.isNotEmpty) {
        resolvedId = modelSeriesId;
      }
    }

    final allModels = modelService.getCachedModelsSync();
    final bool isValidSeriesId = allModels.any((m) => m.id == resolvedId) ||
        resolvedId == 'cortex/auto' ||
        resolvedId == 'cortex/roleplay' ||
        resolvedId == 'dynamic';

    if (resolvedId.isEmpty || !isValidSeriesId) {
      debugPrint(
          "[Storage] FAILED to add recent model. Could not resolve a valid series ID from '$modelId'.");
      return;
    }

    try {
      final db = await DbHelper().db;
      await db.insert(
        'recent_models',
        {
          'model_id': resolvedId,
          'last_used': DateTime.now().millisecondsSinceEpoch
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      CacheService.invalidate(CacheKey.recentModels);
      debugPrint("[Storage] Added/Updated '$resolvedId' in recent models.");
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

  static Future<void> _updateConversationTimestamp(
      String convId, Database db) async {
    if (isFluxMode) return;
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
    String id,
    String newModelId, {
    String? modelTitle,
    String? modelImagePath,
  }) async {
    if (isFluxMode) return;
    try {
      final db = await DbHelper().db;
      final updateData = <String, Object?>{'modelId': newModelId};
      if (modelTitle != null) {
        updateData['modelTitle'] = modelTitle;
      }
      if (modelImagePath != null) {
        updateData['modelImagePath'] = modelImagePath;
      }

      await db.update(
        'conversations',
        updateData,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _handleDiskError(e, 'updateConversationModelId');
    }
  }

  static Future<void> updateConversationModelSnapshot(
    String id, {
    required String modelTitle,
    required String modelImagePath,
  }) async {
    if (isFluxMode) return;
    try {
      final db = await DbHelper().db;
      await db.update(
        'conversations',
        {
          'modelTitle': modelTitle,
          'modelImagePath': modelImagePath,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _handleDiskError(e, 'updateConversationModelSnapshot');
    }
  }

  /* ---------- messages (append / update) ---------- */

  static Future<void> updateStoredMessage(
      String convId, Message m, int idx) async {
    if (isFluxMode || !m.isVisible) return;
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
    if (isFluxMode) return;
    // Filter out invisible messages from the batch save
    final visibleMsgs = msgs.where((m) => m.isVisible).toList();

    try {
      final db = await DbHelper().db;
      final batch = db.batch();
      batch
          .delete('messages', where: 'conversationId = ?', whereArgs: [convId]);

      for (int i = 0; i < visibleMsgs.length; i++) {
        final m = visibleMsgs[i];

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
          'webSearchSources': m.webSearchSources != null
              ? jsonEncode(m.webSearchSources)
              : null,
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

        // Helper to get a displayable path for the stream (usually just the first one or null)
        final displayPath = lastMessage.attachmentPaths.isNotEmpty
            ? lastMessage.attachmentPaths.first
            : null;

        _lastMsgController.add({
          'convId': convId,
          'text': lastMessage.text,
          'photoPath': displayPath,
          // Stream listeners might expect a single path or null
          'ts': DateTime.now().millisecondsSinceEpoch,
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
          'conversationId = ? AND ((text IS NOT NULL AND length(text) > 0) OR (photoPath IS NOT NULL AND length(photoPath) > 0))',
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
          where:
              'conversationId = ? AND (text IS NULL OR length(text) = 0) AND (photoPath IS NULL OR length(photoPath)=0)',
          whereArgs: [convId]);
    } catch (e) {
      _handleDiskError(e, 'removeEmptyMessagesForConversation');
    }

    // Logic Update: Check hasAttachments
    return inMemory
        .where((m) => m.text.trim().isNotEmpty || m.hasAttachments)
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

  /// Retrieves a Message object at a specific index for a conversation.
  /// Returns null if no message exists at that index.
  static Future<Message?> getMessageAtIndex(String convId, int idx) async {
    final row = await getMessageByIdx(convId, idx);
    if (row == null) return null;
    return Message.fromMap(row);
  }

  static Future<void> upsertMessage(String convId, int idx, Message m) async {
    if (isFluxMode || !m.isVisible) return;
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
        'webSearchSources':
            m.webSearchSources != null ? jsonEncode(m.webSearchSources) : null,
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

      final displayPath =
          m.attachmentPaths.isNotEmpty ? m.attachmentPaths.first : null;

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

  /// Returns all media attachment paths from all conversations.
  /// Used by the Arts gallery to display user-created content.
  static Future<List<Map<String, dynamic>>> getAllGeneratedMedia() async {
    try {
      final db = await DbHelper().db;
      // JOIN with conversations to get the modelId for each media item.
      // This allows the Arts screen to route to the correct model on edit.
      final rows = await db.rawQuery('''
        SELECT m.photoPath, m.conversationId, c.modelId
        FROM messages m
        LEFT JOIN conversations c ON c.id = m.conversationId
        WHERE m.photoPath IS NOT NULL AND length(m.photoPath) > 0 AND m.isUser = 0
      ''');
      return rows;
    } catch (e) {
      debugPrint("[ChatStorage] Error fetching all generated media: $e");
      return [];
    }
  }

  /// Returns all media attachment paths for a specific conversation.
  /// Used to clean up files from disk when a conversation is deleted.
  static Future<List<String>> getMediaPathsForConversation(
      String convId) async {
    try {
      final db = await DbHelper().db;
      final rows = await db.query(
        'messages',
        columns: ['photoPath'],
        where:
            'conversationId = ? AND photoPath IS NOT NULL AND length(photoPath) > 0',
        whereArgs: [convId],
      );
      return rows
          .map((r) => r['photoPath'] as String)
          .where((p) => p.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint(
          "[ChatStorage] Error fetching media paths for conversation: $e");
      return [];
    }
  }

  static Future<void> deleteConversation(String id) async {
    try {
      final mediaPaths = await getMediaPathsForConversation(id);
      await _deleteMediaFiles(mediaPaths);

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

      for (final cid in convIds) {
        final mediaPaths = await getMediaPathsForConversation(cid);
        await _deleteMediaFiles(mediaPaths);
      }

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
        {
          'isStarred': starred ? 1 : 0,
          'starredDate': starred
              ? DateTime.now().millisecondsSinceEpoch
              : 0 // Save date or 0
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      AppDataState().markUserDataAsChanged();
    } catch (e) {
      _handleDiskError(e, 'setStarred');
    }
  }

  static Future<bool> renameConversation(
    String id,
    String newTitle, {
    String source = 'unknown',
    String? expectedCurrentTitle,
  }) async {
    final trimmedTitle = newTitle.trim();
    if (id.trim().isEmpty || trimmedTitle.isEmpty) {
      debugPrint(
          "[ChatStorage.rename] Skipped empty rename. source=$source id='$id' titleLength=${trimmedTitle.length}");
      return false;
    }

    try {
      final db = await DbHelper().db;
      final whereArgs = expectedCurrentTitle == null
          ? <Object?>[id]
          : <Object?>[id, expectedCurrentTitle];

      final affectedRows = await db.update(
        'conversations',
        {'title': trimmedTitle},
        where: expectedCurrentTitle == null ? 'id = ?' : 'id = ? AND title = ?',
        whereArgs: whereArgs,
      );

      debugPrint(
          "[ChatStorage.rename] source=$source id=$id affectedRows=$affectedRows expected=${expectedCurrentTitle != null} title='$trimmedTitle'");

      if (affectedRows <= 0) {
        return false;
      }

      AppDataState().markUserDataAsChanged();
      _titleController.add({"id": id, "title": trimmedTitle});
      return true;
    } catch (e) {
      _handleDiskError(e, 'renameConversation');
      return false;
    }
  }

  /// Retrieves the title of a conversation by its ID.
  static Future<String?> getConversationTitle(String id) async {
    try {
      final db = await DbHelper().db;
      final results = await db.query(
        'conversations',
        columns: ['title'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isNotEmpty) {
        return results.first['title'] as String?;
      }
      return null;
    } catch (e) {
      _handleDiskError(e, 'getConversationTitle');
      return null;
    }
  }

  static Future<void> deleteAllConversations() async {
    try {
      final db = await DbHelper().db;
      debugPrint(
          "[ChatStorage] Deleting all conversations, messages, and recent models history.");

      // Delete all media files first
      final rows = await db.query(
        'messages',
        columns: ['photoPath'],
        where: 'photoPath IS NOT NULL AND length(photoPath) > 0',
      );
      final allMediaPaths = rows
          .map((r) => r['photoPath'] as String)
          .where((p) => p.isNotEmpty)
          .toList();
      await _deleteMediaFiles(allMediaPaths);

      await db.transaction((txn) async {
        await txn.delete('messages');
        await txn.delete('conversations');
        await txn.delete('recent_models');
      });

      debugPrint("[ChatStorage] All chat data successfully deleted.");

      CacheService.invalidateConversationCache();
      CacheService.invalidate(CacheKey.recentModels);

      AppDataState().markUserDataAsChanged();
      _conversationResetController.add(null);

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
    } else if (kIsWeb) {
      debugPrint(
          "[ChatStorage] Web platform ignored unsupported database write for: '$operationName'.");
    } else {
      debugPrint("[ChatStorage] Unexpected error in '$operationName': $e");
      throw e;
    }
  }

  static Future<void> _deleteMediaFiles(List<String> rawPaths) async {
    for (final raw in rawPaths) {
      if (raw.isEmpty) continue;

      List<String> paths;
      if (raw.startsWith('[')) {
        try {
          paths = (jsonDecode(raw) as List).cast<String>();
        } catch (_) {
          paths = [raw];
        }
      } else {
        paths = [raw];
      }

      for (final path in paths) {
        if (path.isEmpty || path.startsWith('http')) continue;
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint("[ChatStorage] Error deleting media file: $e");
        }
      }
    }
  }
}
