// lib/chat/services/read.dart

import 'dart:async';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/database.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../axon/inbox/logic/manager.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../library/backend/data/user.dart';
import '../messages/messages.dart';

/// Service responsible for reading conversation and message data from the local database
/// and orchestrating the state update via the dedicated providers.
class ReadService {
  final ConversationProvider _conversationProvider;
  final ChatSessionProvider _sessionProvider;
  final ModelService _modelService;

  ReadService({
    required ConversationProvider conversationProvider,
    required ChatSessionProvider sessionProvider,
    required ModelService modelService,
  })
      : _conversationProvider = conversationProvider,
        _sessionProvider = sessionProvider,
        _modelService = modelService;

  /// Loads a conversation using the provided manager.
  /// This is the single entry point for loading ANY conversation type.
  Future<void> loadConversation(ConversationManager manager,
      {required String languageCode}) async {
    const String logPrefix = "[ReadService.loadConversation]";

    // 1. Resolve the Model ID
    // If it's a legacy 'dynamic' chat, we map it to 'cortex/auto'.
    // Otherwise, we use the model ID directly from the manager.
    String resolvedModelId = manager.modelId;
    if (resolvedModelId == 'dynamic') {
      resolvedModelId = 'cortex/auto';
    }

    debugPrint(
        "$logPrefix: Loading conversation for model '$resolvedModelId'.");

    // 2. Get Precise Model Data
    // We fetch the fresh entity data using the resolved ID.
    final ModelEntity preciseModel = _modelService.getPreciseModelData(
      resolvedModelId,
      langCode: languageCode,
    );

    // 3. Offline Path Check (Optional logging / setup)
    if (!preciseModel.isServerSide) {
      final downloadedPaths = await UserModels.loadDownloadedModelPaths();
      final baseId = _modelService.getBaseIdFromFullId(preciseModel.id);
      final String? path = downloadedPaths[baseId];
      debugPrint("$logPrefix: Offline model detected. Path: '$path'");
    }

    // 5. Configure Session
    // We use selectModel directly.
    // savePreference: false ensures opening an old chat doesn't change the default for NEW chats.
    _sessionProvider.selectModel(preciseModel, savePreference: false);

    // 6. Set Context
    _conversationProvider.setConversationContext(
      manager.conversationID,
      manager.conversationTitle,
    );

    // 7. Load Messages
    await _loadAndSetMessages(manager.conversationID);
  }

  /// Fetches a ConversationManager by its ID and then loads the full conversation.
  Future<void> loadConversationById(String conversationId,
      {required String languageCode}) async {
    final manager = await ConversationManager.fromId(
        conversationId, langCode: languageCode, modelService: _modelService);

    if (manager != null) {
      await loadConversation(manager, languageCode: languageCode);
    } else {
      debugPrint(
          "[ReadService] Could not create ConversationManager for ID: $conversationId. Resetting session.");
      _sessionProvider.resetSessionState();
      _conversationProvider.clearConversation();
    }
  }

  /// Loads previous messages from the local SQLite database and updates the provider.
  Future<void> _loadAndSetMessages(String convId) async {
    const String logPrefix = "[ReadService._loadAndSetMessages]";

    try {
      final db = await DbHelper().db;

      // Retry logic for potential database locks.
      const retries = 5;
      const wait = Duration(milliseconds: 100);
      List<Map<String, Object?>> rows = [];
      for (var i = 0; i < retries; i++) {
        try {
          rows = await db.query(
            'messages',
            where: 'conversationId = ?',
            whereArgs: [convId],
            orderBy: 'idx ASC',
          );
          break;
        } on DatabaseException catch (e) {
          if (e.toString().toLowerCase().contains('database is locked')) {
            await Future.delayed(wait);
            continue;
          }
          rethrow;
        }
      }

      bool needsDbUpdate = false;
      final List<Message> loadedMessages = rows.map((r) {
        if (r['uuid'] == null) needsDbUpdate = true;
        return Message.fromMap(r);
      }).toList();

      // Clean up empty trailing messages
      if (loadedMessages.isNotEmpty &&
          !loadedMessages.last.isUserMessage &&
          loadedMessages.last.text
              .trim()
              .isEmpty &&
          (loadedMessages.last.photoPath ?? '').isEmpty) {
        loadedMessages.removeLast();
      }

      _conversationProvider.loadMessages(loadedMessages);

      if (needsDbUpdate) {
        await ChatStorageService.saveCurrentMessages(convId, loadedMessages);
      }
    } catch (e, stacktrace) {
      debugPrint("$logPrefix: Error loading messages: $e\n$stacktrace");
      _conversationProvider.loadMessages([]);
    }
  }
}