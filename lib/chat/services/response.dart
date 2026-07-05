// lib/chat/services/response.dart

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:flutter/foundation.dart';
import 'package:cortex/chat/services/metrics.dart';

/// Manages the processing of incoming AI responses, both streaming and final.
///
/// This service acts as a bridge between raw response data (e.g., tokens from an
/// API or native code) and the central conversation state. It translates this data
/// into meaningful state changes within the `ConversationProvider` and orchestrates
/// related side-effects like auto-scrolling.
class ResponseService {
  final ConversationProvider _conversationProvider;
  final ScrollService _scrollService;

  /// Creates an instance of ResponseService.
  ///
  /// It requires:
  /// - [conversationProvider] to update the central message list and state.
  /// - [scrollService] to trigger UI side-effects like auto-scrolling.
  ResponseService({
    required ConversationProvider conversationProvider,
    required ScrollService scrollService,
  })  : _conversationProvider = conversationProvider,
        _scrollService = scrollService;

  /// Called for each token received from a streaming source (API or native Llama).
  ///
  /// It appends the token to the current "thinking" message in the `ConversationProvider`
  /// and triggers an auto-scroll if the user is at the bottom of the chat.
  void onMessageResponse(String token) {
    MetricsTracker().onTokenReceived();
    // Critical Guard: Ensure we are in a state to receive a response.
    if (!_conversationProvider.isWaitingForResponse ||
        _conversationProvider.wasResponseStopped) {
      debugPrint(
          "[ResponseService] Ignored token: state is not 'waiting' or response was stopped.");
      return;
    }

    // This is a safety net. In a correct flow, a "thinking"
    // message should always be the last one when a response is being received.
    _conversationProvider.appendToLastBotMessage(token);

    // After the state is updated, delegate the auto-scrolling logic.
    if (_scrollService.isUserAtBottom()) {
      _scrollService.scrollToBottom();
    }
  }

  /// Finalizes a response upon receiving a completion signal from a source.
  ///
  /// This method is the single source of truth for transitioning the conversation
  /// from a "waiting" state to an "idle" state and persisting the final message.
  void finalizeResponse() {
    MetricsTracker().stopTracking();
    // Guard clause: If we're not expecting a response, there's nothing to finalize.
    if (!_conversationProvider.isWaitingForResponse) {
      debugPrint(
          "[ResponseService] Finalize called, but state was not 'waiting'. No action taken.");
      return;
    }

    debugPrint("[ResponseService] Finalizing response...");

    final messages = _conversationProvider.messages;

    // Find the specific message that needs to be finalized. It should be the last
    // AI message that is still marked as "thinking".
    final int targetIndex =
        messages.lastIndexWhere((m) => m.isThinking && !m.isUserMessage);

    if (targetIndex != -1) {
      // The `finishBotResponse` method within the provider handles all necessary state changes:
      // 1. Sets `isThinking` to `false`.
      // 2. Sets `includeInContext` to `true`.
      // 3. Persists the final message to the database.
      // 4. Sets the global `isWaitingForResponse` to `false`.
      // 5. Notifies all listeners of the state change.
      _conversationProvider.finishBotResponse(targetIndex);
      debugPrint(
          "[ResponseService] Finalized message at index $targetIndex via provider.");
    } else {
      // Fallback: If no "thinking" message was found, we still need to
      // exit the "waiting" state to unlock the UI.
      _conversationProvider.finishBotResponse(-1);
      debugPrint(
          "[ResponseService] Could not find a 'thinking' message. Forcing state cleanup via finishBotResponse(-1).");
    }
  }
}
