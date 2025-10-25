// lib/chat/services/stop.dart

import 'dart:async';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/api.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:flutter/foundation.dart';

/// Manages the logic for forcefully stopping a response generation from the AI.
class StopService {
  final ConversationProvider _conversationProvider;
  final ChatSessionProvider _sessionProvider;
  final ApiService _apiService;
  final OfflineService _offlineService;

  /// Constructs the StopService with its required dependencies.
  StopService({
    required ConversationProvider conversationProvider,
    required ChatSessionProvider sessionProvider,
    required ApiService apiService,
    required OfflineService offlineService,
  })  : _conversationProvider = conversationProvider,
        _sessionProvider = sessionProvider,
        _apiService = apiService,
        _offlineService = offlineService;

  /// Initiates the process to stop the AI's response generation.
  Future<void> stopResponse() async {
    if (!_conversationProvider.isWaitingForResponse) {
      debugPrint("[StopService] Not waiting for a response, nothing to stop.");
      return;
    }
    debugPrint("[StopService] Stop request initiated.");

    final currentModelId = _sessionProvider.modelId;
    if (currentModelId != null && Utils.isLocalModel(currentModelId)) {
      _offlineService.stopGeneration();
      debugPrint("[StopService] Cancellation signal sent to OfflineService.");
    } else {
      _apiService.cancelRequests();
      debugPrint("[StopService] Cancellation signal sent to ApiService.");
    }

    final messages = _conversationProvider.messages;
    final int lastMessageIndex = messages.lastIndexWhere((m) => !m.isUserMessage && m.isThinking);

    if (lastMessageIndex == -1) {
      debugPrint("[StopService] No 'thinking' AI message found. Finalizing state just in case.");
      _conversationProvider.finishBotResponse(-1);
      return;
    }

    final aiMessage = messages[lastMessageIndex];
    final bool wasJustThinking = aiMessage.text.trim().isEmpty && (aiMessage.photoPath ?? '').isEmpty;

    if (wasJustThinking) {
      debugPrint("[StopService] Stopped in 'thinking' state. Fading out bubble at index $lastMessageIndex.");
      _conversationProvider.fadeOutMessage(lastMessageIndex);
    } else {
      debugPrint("[StopService] Stopped in 'writing' state. Finalizing message at index $lastMessageIndex.");
      _conversationProvider.finishBotResponse(lastMessageIndex);
      final conversationID = _conversationProvider.conversationID;
      if (conversationID != null) {
        debugPrint("[StopService] Saving partially generated message to DB.");
        await ChatStorageService.saveCurrentMessages(
            conversationID, _conversationProvider.messages);
      }
    }
    debugPrint("[StopService] Response stop process completed.");
  }
}