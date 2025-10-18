// regenerate.dart

import 'package:cortex/chat/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';

import '../../notifications.dart';
import '../chat.dart';
import '../messages/messages.dart';

/// Service responsible for handling the message regeneration logic.
class RegenerateService {
  final ChatScreenState state;

  RegenerateService({required this.state});

  /// Handles the regeneration of an AI message at the given [modelIndex].
  ///
  /// This function has been completely re-architected to be robust and atomic,
  /// resolving UI glitches where old messages would persist during regeneration.
  ///
  /// The process is now:
  /// 1. Find the user message that prompted the AI response.
  /// 2. Atomically update the state: remove the target AI message and all
  ///    subsequent messages, and insert a new "thinking" placeholder in their place.
  ///    This is done in a single `setState` call to prevent inconsistent UI states.
  /// 3. Delegate the API call to `SendService`, which will now work with a
  ///    clean and correctly prepared message list.
  ///
  /// It also supports a "Change and Regenerate" request as a one-time operation
  /// by accepting an optional `newModelId` without permanently altering the chat's active model.
  Future<void> onRegenerate(int modelIndex, {String? newModelId}) async {
    const String logPrefix = "[RegenerateService]";
    debugPrint(
        "$logPrefix: onRegenerate called for modelIndex: $modelIndex. One-time model override requested: '${newModelId ?? 'none'}'.");

    if (!state.mounted) {
      debugPrint("$logPrefix: State is not mounted. Aborting.");
      return;
    }

    final notificationService =
    Provider.of<NotificationService>(state.context, listen: false);
    final localizations = AppLocalizations.of(state.context)!;

    if (state.isWaitingForResponse) {
      debugPrint("$logPrefix: Operation already in progress. Aborting.");
      notificationService.showNotification(
        message: localizations.regenerateInProgress,
        isSuccess: false,
        oneLine: true,
        duration: const Duration(seconds: 3),
        bottomOffset: 0.07,
      );
      return;
    }

    try {
      if (modelIndex < 0 || modelIndex >= state.messages.length) {
        debugPrint("$logPrefix: Invalid index. Aborting.");
        return;
      }

      // Ensure any previous response is fully stopped.
      await state.stopService.stopResponse();

      // Find the user message that triggered the AI response.
      final int triggerUserIndex = state.messages
          .sublist(0, modelIndex)
          .lastIndexWhere((m) => m.isUserMessage);

      if (triggerUserIndex < 0) {
        debugPrint(
            "$logPrefix: No preceding user message found for regeneration. Aborting.");
        return;
      }

      final Message userMessageForRegeneration =
      state.messages[triggerUserIndex];
      final String textForRegeneration = userMessageForRegeneration.text.trim();
      final String? photoPathForRegeneration =
          userMessageForRegeneration.photoPath;

      // Determine the model to record in the new "thinking" message for history.
      final Message messageToRegenerate = state.messages[modelIndex];
      final String modelForNewMessageRecord =
          newModelId ?? messageToRegenerate.model ?? state.modelId!;

      // --- ATOMIC STATE UPDATE ---
      // This is the critical fix. We create a new list in a single operation
      // by taking all messages *before* the target, then adding the new
      // "thinking" placeholder. Assigning a new list to `state.messages`
      // guarantees that Flutter correctly rebuilds the UI without glitches.
      if (state.mounted) {
        state.setState(() {
          // Create the new list ending right before the message to be regenerated.
          List<Message> updatedMessages =
          state.messages.sublist(0, modelIndex);

          // Add the new "thinking" placeholder.
          updatedMessages.add(Message(
            text: "",
            isUserMessage: false,
            isThinking: true,
            includeInContext: false,
            model: modelForNewMessageRecord,
          ));

          // Atomically replace the old list with the new one.
          state.messages = updatedMessages;
        });
        debugPrint(
            "$logPrefix: Atomically updated message list. Removed messages from index $modelIndex onwards and added a 'thinking' placeholder.");

        // Persist the new, shorter message list to local storage.
        if (state.conversationID != null) {
          await ChatStorageService.saveCurrentMessages(
              state.conversationID!, state.messages);
        }
      }

      // Allow the UI to update before proceeding.
      await Future.microtask(() {});
      if (!state.mounted) return;

      // Delegate to SendService. `isRegenerate` tells it not to add new
      // messages, but to use the placeholder we just created.
      debugPrint(
          "$logPrefix: Delegating to SendService. Active model: '${state.modelId}', One-time override: '$newModelId'.");

      await state.sendService.sendMessage(
        textFromButton: textForRegeneration,
        isRegenerate: true,
        regenerateAiIndex: modelIndex,
        regeneratePhotoPath: photoPathForRegeneration,
        overrideModelId: newModelId,
      );

      debugPrint("$logPrefix: sendMessage call completed successfully.");
    } catch (e, s) {
      debugPrint("$logPrefix: ERROR in onRegenerate: $e\nStack Trace: $s");
      if (state.mounted) {
        notificationService.showNotification(
            duration: const Duration(seconds: 4),
            message:
            localizations.errorOccurredDuringRegeneration(e.toString()),
            isSuccess: false);
        if (state.isWaitingForResponse) {
          state.setState(() => state.isWaitingForResponse = false);
        }
      }
    }
  }
}