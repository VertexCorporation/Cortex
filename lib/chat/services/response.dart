// response.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cortex/chat/chat.dart';
import 'package:cortex/chat/services/storage.dart';

class ResponseService {
  final ChatScreenState state;

  ResponseService(this.state);

  /// Called for each token received from the native Llama service.
  void onMessageResponse(String token) {
    // 1. Ignore tokens if the stream has been manually stopped by the user.
    if (state.responseStopped) {
      debugPrint("[ResponseService] Ignored token because response was stopped.");
      return;
    }

    // 2. Critical Guard: Ensure we are in a state to receive a response.
    if (!state.isWaitingForResponse || state.messages.isEmpty || state.messages.last.isUserMessage) {
      debugPrint("[ResponseService] Ignored token because state is not 'waiting for response'.");
      return;
    }

    // 3. Perform a single, atomic state update.
    if (!state.mounted) return;
    state.setState(() {
      // On the very first token, transition the UI from "thinking" to "responding".
      if (state.messages.last.isThinking) {
        state.messages.last.isThinking = false;
      }
      // Append the new token to the last message in the chat.
      state.messages.last.text += token;
    });

    // 4. Auto-scroll if the user is at the bottom of the list.
    // Use a post-frame callback to ensure the layout has been updated.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.scrollService.isUserAtBottom()) {
        state.scrollService.scrollToBottom();
      }
    });
  }

  /// --- THE ROBUST FIX for the "thinking" bug ---
  /// This is the single source of truth for finalizing a response.
  /// It is called ONLY when the `onMessageComplete` event is received from the native code.
  void finalizeResponse() {
    if (!state.mounted) return;

    // Only finalize if we were actually waiting for a response.
    if (state.isWaitingForResponse) {
      debugPrint("[ResponseService] Finalizing response. Was waiting: true.");
      state.setState(() {
        state.isWaitingForResponse = false;
        // The 'responseStopped' flag is now managed by the StopService.
        // This function just handles the successful completion.

        if (state.messages.isNotEmpty && !state.messages.last.isUserMessage) {
          final lastMessage = state.messages.last;
          // Ensure the final state is clean.
          lastMessage.isThinking = false;
          lastMessage.includeInContext = true;

          // Persist the final, complete message to storage.
          if (state.conversationID != null) {
            ChatStorageService.upsertMessage(
              state.conversationID!,
              state.messages.length - 1,
              lastMessage,
            );
            debugPrint("[ResponseService] Final message saved to storage.");
          }
        }
      });
    } else {
      debugPrint("[ResponseService] Finalize called, but state was not 'waiting'. No action taken.");
    }
  }
}