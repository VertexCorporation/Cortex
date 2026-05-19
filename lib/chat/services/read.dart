// lib/chat/services/read.dart

import 'dart:async';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/background.dart';
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
  final BackgroundTaskService _backgroundTaskService;
  int _loadGeneration = 0;

  ReadService({
    required ConversationProvider conversationProvider,
    required ChatSessionProvider sessionProvider,
    required ModelService modelService,
    required BackgroundTaskService backgroundTaskService,
  })  : _conversationProvider = conversationProvider,
        _sessionProvider = sessionProvider,
        _modelService = modelService,
        _backgroundTaskService = backgroundTaskService;

  /// Loads a conversation using the provided manager.
  Future<void> loadConversation(ConversationManager manager,
      {required String languageCode}) async {
    const String logPrefix = "[ReadService.loadConversation]";
    final int loadGeneration = ++_loadGeneration;

    // CRITICAL: Clear messages and show skeleton immediately in ONE state update
    _conversationProvider.clearConversation(startLoading: true);

    // 1. Resolve the Model ID
    String resolvedModelId = manager.modelId;
    if (resolvedModelId == 'dynamic') {
      resolvedModelId = 'cortex/auto';
    }

    debugPrint(
        "$logPrefix: Loading conversation for model '$resolvedModelId'.");

    // 2. Get Precise Model Data
    ModelEntity preciseModel;
    if (resolvedModelId != 'cortex/auto' &&
        !_modelService.hasModelInCache(resolvedModelId)) {
      debugPrint(
          "$logPrefix: Model '$resolvedModelId' not in cache (likely deleted). Falling back to dynamic chat.");
      preciseModel = _modelService.getPreciseModelData('cortex/auto',
          langCode: languageCode);
    } else {
      preciseModel = _modelService.getPreciseModelData(resolvedModelId,
          langCode: languageCode);
    }

    // 3. Offline Path Check
    if (!preciseModel.isServerSide) {
      final downloadedPaths = await UserModels.loadDownloadedModelPaths();
      if (loadGeneration != _loadGeneration) return;
      final baseId = _modelService.getBaseIdFromFullId(preciseModel.id);
      final String? path = downloadedPaths[baseId];
      debugPrint("$logPrefix: Offline model detected. Path: '$path'");
    }

    // 5. Configure Session
    _sessionProvider.selectModel(preciseModel, savePreference: false);

    // 6. Set Context
    _conversationProvider.setConversationContext(
      manager.conversationID,
      manager.conversationTitle,
      persistedModelId: manager.modelId,
      persistedModelTitle: manager.modelTitle,
      persistedModelImagePath: manager.modelImagePath,
    );

    // 7. Load Messages (will set loading to false when done)
    final didLoadMessages = await _loadAndSetMessages(
      manager.conversationID,
      loadGeneration: loadGeneration,
    );
    if (!didLoadMessages || loadGeneration != _loadGeneration) return;

    // 8. BACKGROUND STREAM RECOVERY: If there's an active background task
    // for this conversation, merge the accumulated buffer and restore state.
    _restoreBackgroundStreamState(manager.conversationID);
  }

  /// Fetches a ConversationManager by its ID and then loads the full conversation.
  Future<void> loadConversationById(String conversationId,
      {required String languageCode}) async {
    _loadGeneration++;
    // CRITICAL FIX: Eagerly set loading state before manager resolution (DB fetch)
    // This prevents the empty screen flash while waiting for the database!
    // By passing startLoading: true, it clears and sets loading in ONE state update.
    _conversationProvider.clearConversation(startLoading: true);

    final manager = await ConversationManager.fromId(conversationId,
        langCode: languageCode, modelService: _modelService);

    if (manager != null) {
      await loadConversation(manager, languageCode: languageCode);
    } else {
      debugPrint(
          "[ReadService] Could not create ConversationManager for ID: $conversationId. Resetting session.");
      _sessionProvider.resetSessionState();
      _conversationProvider.clearConversation();
    }
  }

  /// Restores background stream state when re-entering a chat that has an
  /// active background stream. This merges accumulated text/media into the
  /// loaded messages and sets the appropriate waiting/shimmer state.
  void _restoreBackgroundStreamState(String convId) {
    if (!_backgroundTaskService.isActive(convId)) return;

    debugPrint('[ReadService] Restoring background stream state for: $convId');

    final messages = _conversationProvider.messages;

    // Peek at the accumulated text (don't consume — the stream is still running)
    final accumulatedText = _backgroundTaskService.peekBuffer(convId);
    final pendingMediaType = _backgroundTaskService.getPendingMediaType(convId);
    final mediaAttachments = _backgroundTaskService.getMediaAttachments(convId);
    final isWebSearchActive = _backgroundTaskService.isWebSearchActive(convId);

    if (messages.isNotEmpty) {
      final lastMsg = messages.last;

      if (!lastMsg.isUserMessage) {
        // There's already an AI message at the end. Merge background data into it.
        String mergedText = lastMsg.text;
        if (accumulatedText.isNotEmpty) {
          // The DB might have an older snapshot. The background buffer has the
          // latest tokens. Replace if the buffer has more content.
          if (accumulatedText.length > mergedText.length) {
            mergedText = accumulatedText;
          }
        }

        // Merge media attachments
        final List<String> mergedAttachments =
            List<String>.from(lastMsg.attachmentPaths);
        for (final path in mediaAttachments) {
          if (!mergedAttachments.contains(path)) {
            mergedAttachments.add(path);
          }
        }

        // Update the message with merged data and mark as thinking (streaming)
        _conversationProvider.updateMessageAtIndex(
          messages.length - 1,
          lastMsg.copyWith(
            text: mergedText,
            isThinking: true,
            attachmentPaths: mergedAttachments,
            pendingMediaType: pendingMediaType,
            isWebSearchActive: isWebSearchActive,
          ),
        );

        // Restore the waiting state so the UI shows the streaming animation
        _conversationProvider.restoreWaitingState();
        debugPrint(
            '[ReadService] Restored stream state: ${mergedText.length} chars, '
            '${mergedAttachments.length} media, pendingMedia: $pendingMediaType');
      } else {
        // Last message is user's — the AI message hasn't been persisted yet.
        // Add a thinking bubble with any accumulated content.
        final thinkingMessage = Message(
          text: accumulatedText,
          isUserMessage: false,
          isThinking: true,
          attachmentPaths: mediaAttachments,
          pendingMediaType: pendingMediaType,
          isWebSearchActive: isWebSearchActive,
          model: _sessionProvider.modelId,
        );
        _conversationProvider.appendBackgroundRestoredMessage(thinkingMessage);
        debugPrint(
            '[ReadService] Added thinking bubble from background stream.');
      }
    }
  }

  /// Loads previous messages from the local SQLite database and updates the provider.
  Future<bool> _loadAndSetMessages(String convId,
      {required int loadGeneration}) async {
    const String logPrefix = "[ReadService._loadAndSetMessages]";

    // Setting _isLoadingMessages to true immediately before awaiting the database read
    _conversationProvider.setLoadingMessages(true);

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
        // Message.fromMap handles the migration from 'photoPath' to 'attachmentPaths'
        return Message.fromMap(r);
      }).toList();

      if (loadGeneration != _loadGeneration) {
        debugPrint("$logPrefix: Ignoring stale load for $convId.");
        return false;
      }

      // Clean up empty trailing messages
      // Logic Update: Check hasAttachments instead of just photoPath
      if (loadedMessages.isNotEmpty) {
        final lastMsg = loadedMessages.last;
        if (!lastMsg.isUserMessage &&
            lastMsg.text.trim().isEmpty &&
            !lastMsg.hasAttachments) {
          loadedMessages.removeLast();
        }
      }

      _conversationProvider.loadMessages(loadedMessages);

      if (needsDbUpdate) {
        await ChatStorageService.saveCurrentMessages(convId, loadedMessages);
      }
      return true;
    } catch (e, stacktrace) {
      debugPrint("$logPrefix: Error loading messages: $e\n$stacktrace");
      if (loadGeneration != _loadGeneration) return false;
      _conversationProvider.loadMessages([]);
      return true;
    }
  }
}
