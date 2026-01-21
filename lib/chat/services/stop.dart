// lib/chat/services/stop.dart

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/api.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:flutter/foundation.dart';
import '../../library/backend/data/service.dart';

/// Manages the logic for forcefully stopping a response generation from the AI.
class StopService {
  final ConversationProvider _conversationProvider;
  final ChatSessionProvider _sessionProvider;
  final ApiService _apiService;
  final OfflineService _offlineService;
  final ModelService _modelService;

  StopService({
    required ConversationProvider conversationProvider,
    required ChatSessionProvider sessionProvider,
    required ApiService apiService,
    required OfflineService offlineService,
    required ModelService modelService,
  })
      : _conversationProvider = conversationProvider,
        _sessionProvider = sessionProvider,
        _apiService = apiService,
        _offlineService = offlineService,
        _modelService = modelService;

  /// Initiates the process to stop the AI's response generation.
  Future<void> stopResponse() async {
    if (!_conversationProvider.isWaitingForResponse) {
      debugPrint("[StopService] Not waiting for a response, nothing to stop.");
      return;
    }
    debugPrint("[StopService] Stop request initiated.");

    final langCode = _sessionProvider
        .getLocale()
        .languageCode;
    final currentModelId = _sessionProvider.modelId;

    if (currentModelId != null &&
        Utils.isLocalModel(
            currentModelId, langCode: langCode, modelService: _modelService)) {
      _offlineService.stopGeneration();
      debugPrint("[StopService] Cancellation signal sent to OfflineService.");
    } else {
      _apiService.cancelRequests();
      debugPrint("[StopService] Cancellation signal sent to ApiService.");
    }

    final messages = _conversationProvider.messages;
    final int lastMessageIndex =
    messages.lastIndexWhere((m) => !m.isUserMessage && m.isThinking);

    if (lastMessageIndex == -1) {
      debugPrint(
          "[StopService] No 'thinking' AI message found. Finalizing state.");
      _conversationProvider.finishBotResponse(-1);
      return;
    }

    final aiMessage = messages[lastMessageIndex];

    // LOGIC UPDATE: Check hasAttachments instead of photoPath
    final bool wasJustThinking = aiMessage.text
        .trim()
        .isEmpty && !aiMessage.hasAttachments;

    if (wasJustThinking) {
      debugPrint(
        "[StopService] Stopped in 'thinking' state with EMPTY content. "
            "Fading out AI bubble at index $lastMessageIndex, then removing.",
      );

      _conversationProvider.fadeOutMessage(lastMessageIndex);

      await Future.delayed(const Duration(milliseconds: 220));

      final conversationID = _conversationProvider.conversationID;
      final prunedMessages = List.of(_conversationProvider.messages)
        ..removeWhere(
              (m) =>
          !m.isUserMessage &&
              m.text
                  .trim()
                  .isEmpty &&
              !m.hasAttachments, // Updated check
        );

      _conversationProvider.loadMessages(prunedMessages);

      if (conversationID != null) {
        debugPrint("[StopService] Persisting pruned messages list.");
        await ChatStorageService.saveCurrentMessages(
          conversationID,
          prunedMessages,
        );
      }

      _conversationProvider.finishBotResponse(-1);
    } else {
      debugPrint(
        "[StopService] Stopped in 'writing' state. Finalizing message at index $lastMessageIndex.",
      );
      _conversationProvider.finishBotResponse(lastMessageIndex);
      final conversationID = _conversationProvider.conversationID;
      if (conversationID != null) {
        debugPrint("[StopService] Saving partially generated message to DB.");
        await ChatStorageService.saveCurrentMessages(
          conversationID,
          _conversationProvider.messages,
        );
      }
    }
    debugPrint("[StopService] Response stop process completed.");
  }
}