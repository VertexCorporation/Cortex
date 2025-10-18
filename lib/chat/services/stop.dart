// StopService.dart

import 'dart:async';
import 'package:cortex/chat/services/storage.dart';
import 'package:flutter/cupertino.dart';
import '../chat.dart';

class StopService {
  final ChatScreenState state;

  StopService(this.state);

  Future<void> stopResponse() async {
    if (state.responseStopped || !state.isWaitingForResponse) return;

    state.setState(() {
      state.responseStopped = true;
    });

    // This tells the ApiService to close its http.Client, which aborts
    // the connection to our proxy server, preventing further processing or responses.
    state.apiService.cancelRequests();
    debugPrint("[StopService] Sent cancellation signal to ApiService.");

    // If the model is a local one, also send a signal to the native layer.
    if (state.isLocalModel(state.modelId)) {
      try {
        debugPrint("[StopService] Sending 'stopGeneration' signal to native layer for local model.");
        await ChatScreenState.llamaChannel.invokeMethod('stopGeneration');
      } catch (e) {
        debugPrint("[StopService] Failed to send stop signal to native: $e");
      }
    }

    // --- The rest of the UI cleanup logic remains the same ---
    state.chunkTimer?.cancel();
    state.chunkTimer = null;
    state.responseChunksQueue.clear();

    if (!state.mounted) return;
    state.setState(() {
      state.isWaitingForResponse = false;
    });

    int lastAiIndex = state.messages.lastIndexWhere((m) => !m.isUserMessage);
    if (lastAiIndex == -1) {
      state.sendService.abortSend();
      return;
    }

    final aiMessage = state.messages[lastAiIndex];
    // If the AI message was still "thinking" or empty, just remove it.
    if (aiMessage.isThinking || aiMessage.text.trim().isEmpty) {
      state.setState(() {
        state.messages[lastAiIndex].opacity = 0;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (state.mounted && lastAiIndex < state.messages.length) {
          // Check if the message is still the one we intended to remove
          if(state.messages[lastAiIndex].isThinking || state.messages[lastAiIndex].text.trim().isEmpty) {
            state.setState(() {
              state.messages.removeAt(lastAiIndex);
            });
          }
        }
      });
    } else {
      // If the AI message has content, it should be saved.
      // This part of the logic is likely correct as it handles partial responses.
      if (aiMessage.text.trim().isNotEmpty) {
        state.setState(() {
          // Ensure the thinking spinner is off
          aiMessage.isThinking = false;
        });
        await ChatStorageService.upsertMessage(
          state.conversationID!,
          lastAiIndex,
          aiMessage,
        );
      }
    }
    state.sendService.abortSend();
  }
}