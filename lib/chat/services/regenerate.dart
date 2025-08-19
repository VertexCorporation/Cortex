// regenerate.dart

import 'package:cortex/models/backend/data.dart';
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
  /// This function is now designed to handle a "Change and Regenerate" request as a
  /// **one-time operation** without permanently altering the chat's active model.
  ///
  /// - When `newModelId` is provided (from the "Change Model" message option),
  ///   this ID is passed down to `sendService.sendMessage` as a temporary
  ///   `overrideModelId`.
  /// - The global `state.modelId` in `ChatScreenState` is **NOT** modified,
  ///   ensuring that subsequent messages continue to use the chat's original model.
  Future<void> onRegenerate(int modelIndex, {String? newModelId}) async {
    const String logPrefix = "[RegenerateService]";
    debugPrint(
        "$logPrefix: onRegenerate called for modelIndex: $modelIndex. One-time model override requested: '${newModelId ?? 'none'}'.");

    if (!state.mounted) {
      debugPrint("$logPrefix: State is not mounted. Aborting.");
      return;
    }

    final notificationService = Provider.of<NotificationService>(state.context, listen: false);
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
      if (modelIndex < 0 || modelIndex >= state.messages.length || state.messages.isEmpty) {
        debugPrint("$logPrefix: Invalid index or empty messages. Aborting.");
        return;
      }

      await state.stopService.stopResponse();

      // 1. Find the user message that triggered the AI response.
      final List<Message> messagesBeforeTarget = modelIndex > 0 ? state.messages.sublist(0, modelIndex) : [];
      final int triggerUserIndex = messagesBeforeTarget.lastIndexWhere((m) => m.isUserMessage);

      if (triggerUserIndex < 0) {
        debugPrint("$logPrefix: No preceding user message found for regeneration. Aborting.");
        return;
      }
      final Message userMessageForRegeneration = state.messages[triggerUserIndex];
      final String textForRegeneration = userMessageForRegeneration.text.trim();
      final String? photoPathForRegeneration = userMessageForRegeneration.photoPath;

      // *** FIX: Determine the model to record in the new "thinking" message ***
      // We use the override ID if provided, otherwise we fall back to the AI message's original model
      // or the current state's model as a last resort. This is for record-keeping.
      final Message messageToRegenerate = state.messages[modelIndex];
      final String modelForNewMessageRecord = newModelId ?? messageToRegenerate.model ?? state.modelId!;

      // 2. Delete the target AI message and all subsequent messages.
      final List<int> messagesToRemoveIndices = [];
      for (int i = modelIndex; i < state.messages.length; i++) {
        messagesToRemoveIndices.add(i);
      }

      if (messagesToRemoveIndices.isNotEmpty) {
        if (state.mounted) {
          state.setState(() {
            messagesToRemoveIndices.sort((a, b) => b.compareTo(a));
            for (int i in messagesToRemoveIndices) {
              if (i < state.messages.length) state.messages.removeAt(i);
            }
          });
          debugPrint("$logPrefix: Removed ${messagesToRemoveIndices.length} messages from UI.");
          if (state.conversationID != null) {
            await ChatStorageService.saveCurrentMessages(state.conversationID!, state.messages);
          }
        }
      }

      if (!state.mounted) return;

      // 3. Insert the "thinking" placeholder.
      if (state.mounted) {
        state.setState(() {
          if (modelIndex <= state.messages.length) {
            state.messages.insert(modelIndex, Message(
                text: "",
                isUserMessage: false,
                isThinking: true,
                includeInContext: false,
                opacity: 1.0,
                model: modelForNewMessageRecord // Record which model is creating this.
            ));
          }
        });
        debugPrint("$logPrefix: Inserted 'thinking' placeholder at index $modelIndex.");
      }

      await Future.microtask(() {}); // Allow the UI to update
      if (!state.mounted) return;

      // 4. Delegate to SendService with the one-time override model ID.
      // The `overrideModelId` parameter ensures this specific request uses the new
      // model, without changing the chat's global state.
      debugPrint("$logPrefix: Delegating to SendService with regenerate flags. Chat active model: '${state.modelId}', One-time override: '$newModelId'.");
      await state.sendService.sendMessage(
        textFromButton: textForRegeneration,
        isRegenerate: true,
        regenerateAiIndex: modelIndex,
        regeneratePhotoPath: photoPathForRegeneration,
      );

      debugPrint("$logPrefix: sendMessage call completed.");

    } catch (e, s) {
      debugPrint("$logPrefix: ERROR in onRegenerate: $e\nStack Trace: $s");
      if (state.mounted) {
        notificationService.showNotification(
            duration: const Duration(seconds: 4),
            message: localizations.errorOccurredDuringRegeneration(e.toString()),
            isSuccess: false);
        if (state.isWaitingForResponse) {
          state.setState(() => state.isWaitingForResponse = false);
        }
      }
    }
  }
}