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
///
/// This service is completely decoupled from the UI layer. It acts as a pure
/// business logic component that coordinates loading a full conversation session
/// into the central state.
class ReadService {
  final ConversationProvider _conversationProvider;
  final ChatSessionProvider _sessionProvider;
  final ModelService _modelService;

  ReadService({
    required ConversationProvider conversationProvider,
    required ChatSessionProvider sessionProvider,
    required ModelService modelService,
  })  : _conversationProvider = conversationProvider,
        _sessionProvider = sessionProvider,
        _modelService = modelService;

  /// Acts as a router, delegating the conversation loading to the appropriate handler.
  ///
  /// The [languageCode] is required to ensure that model data can be fetched
  /// in the correct locale if it's not already cached.
  Future<void> loadConversation(ConversationManager manager, {required String languageCode}) async {
    final String conversationModelId = manager.modelId;

    if (conversationModelId == 'dynamic') {
      await _loadDynamicConversation(manager);
    } else {
      await _loadStandardConversation(manager, languageCode: languageCode);
    }
  }

  /// Fetches a ConversationManager by its ID and then loads the full conversation.
  Future<void> loadConversationById(String conversationId, {required String languageCode}) async {
    // Pass the required langCode to the factory constructor.
    final manager = await ConversationManager.fromId(conversationId, langCode: languageCode, modelService: _modelService);

    if (manager != null) {
      await loadConversation(manager, languageCode: languageCode);
    } else {
      debugPrint("[ReadService] Could not create ConversationManager for ID: $conversationId. Resetting session.");
      _sessionProvider.resetSessionState();
      _conversationProvider.clearConversation();
    }
  }

  /// Handles the specific logic for loading a "dynamic" conversation session.
  Future<void> _loadDynamicConversation(ConversationManager manager) async {
    debugPrint("[ReadService] Loading dynamic conversation: ${manager.conversationID}");
    await _sessionProvider.startDynamicConversation();
    _conversationProvider.setConversationContext(
      manager.conversationID,
      manager.conversationTitle,
    );
    await _loadAndSetMessages(manager.conversationID);
  }

  /// Handles the logic for loading a standard, model-specific conversation.
  Future<void> _loadStandardConversation(ConversationManager manager, {required String languageCode}) async {
    const String logPrefix = "[ReadService._loadStandardConversation]";
    debugPrint("$logPrefix: Loading conversation for model '${manager.modelId}'.");

    // The manager already holds the precise ModelEntity.
    final ModelEntity preciseModel = manager.model;

    // 2. Determine all necessary model properties from the entity.
    String? finalModelPath;
    if (!preciseModel.isServerSide) {
      final downloadedPaths = await UserModels.loadDownloadedModelPaths();
      final baseId = _modelService.getBaseIdFromFullId(preciseModel.id);
      finalModelPath = downloadedPaths[baseId];
      debugPrint("$logPrefix: Offline model detected. Path: '$finalModelPath'");
    }

    final bool isPremium = _isModelPremium(preciseModel, langCode: languageCode);

    // 3. Configure the session provider with all gathered model data.
    _sessionProvider.configureForStandardChat(
      model: preciseModel,
      isPremium: isPremium,
    );

    // 4. Set the specific conversation ID and title.
    _conversationProvider.setConversationContext(
      manager.conversationID,
      manager.conversationTitle,
    );

    // 5. Load the message history for this conversation.
    await _loadAndSetMessages(manager.conversationID);
  }

  /// Determines if a model is premium, correctly handling character models that use a base model.
  bool _isModelPremium(ModelEntity model, {required String langCode}) {
    if (model.category == 'self' || model.category == 'roleplay') {
      final String? baseModelId = model.baseModelId;
      if (baseModelId != null && baseModelId.isNotEmpty) {
        final ModelEntity baseModel = _modelService.getPreciseModelData(baseModelId, langCode: langCode);
        return baseModel.isPremium;
      }
    }
    return model.isPremium;
  }

  /// Loads previous messages from the local SQLite database and updates the provider.
  Future<void> _loadAndSetMessages(String convId) async {
    const String logPrefix = "[ReadService._loadAndSetMessages]";
    debugPrint("$logPrefix: Loading messages for convId: '$convId'");

    try {
      final db = await DbHelper().db;

      // Retry logic for potential database locks remains a good practice.
      const retries = 5;
      const wait = Duration(milliseconds: 100);
      List<Map<String, Object?>> rows = [];
      for (var i = 0; i < retries; i++) {
        try {
          rows = await db.query(
            'messages',
            where: 'conversationId = ?',
            whereArgs: [convId],
            orderBy: 'idx ASC', // Simple ordering is sufficient
          );
          break; // Success
        } on DatabaseException catch (e) {
          if (e.toString().toLowerCase().contains('database is locked')) {
            debugPrint("$logPrefix: Database locked on attempt ${i + 1}. Retrying...");
            await Future.delayed(wait);
            continue;
          }
          rethrow; // It's a different database error, don't retry.
        }
      }

      bool needsDbUpdate = false;
      final List<Message> loadedMessages = rows.map((r) {
        if (r['uuid'] == null) needsDbUpdate = true;
        return Message.fromMap(r);
      }).toList();

      // Business logic: Remove a trailing empty/thinking AI message from loaded history.
      if (loadedMessages.isNotEmpty &&
          !loadedMessages.last.isUserMessage &&
          loadedMessages.last.text.trim().isEmpty &&
          (loadedMessages.last.photoPath ?? '').isEmpty) {
        loadedMessages.removeLast();
      }

      // Deliver the final, clean message list to the provider.
      _conversationProvider.loadMessages(loadedMessages);

      if (needsDbUpdate) {
        debugPrint("$logPrefix: Performing lazy migration to update UUIDs for convId '$convId'.");
        await ChatStorageService.saveCurrentMessages(convId, loadedMessages);
      }
      debugPrint("$logPrefix: Successfully loaded ${loadedMessages.length} messages.");
    } catch (e, stacktrace) {
      debugPrint("$logPrefix: Error loading messages: $e\n$stacktrace");
      _conversationProvider.loadMessages([]); // On error, provide an empty list for a stable state.
    }
  }
}