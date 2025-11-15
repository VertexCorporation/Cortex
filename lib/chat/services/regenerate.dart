// lib/chat/services/regenerate.dart

import 'dart:async';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/send.dart';
import 'package:cortex/chat/services/stop.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:cortex/chat/messages/messages.dart';
import '../../l10n/app_localizations.dart';

/// Service responsible for orchestrating the message regeneration logic.
class RegenerateService {
  final ConversationProvider _conversationProvider;
  final StopService _stopService;
  final SendService _sendService;
  final ScrollService _scrollService;

  RegenerateService({
    required ConversationProvider conversationProvider,
    required StopService stopService,
    required SendService sendService,
    required ScrollService scrollService,
  })  : _conversationProvider = conversationProvider,
        _stopService = stopService,
        _sendService = sendService,
        _scrollService = scrollService;

  /// Handles the regeneration of an AI message, now with support for Dynamic Chat.
  ///
  /// This method is designed to be safe against async gaps. It captures necessary
  /// values from the `BuildContext` before the first `await` and checks `context.mounted`
  /// before using the context after any async operation.
  Future<void> onRegenerate(
      int messageIndex, {
        required BuildContext context,
        String? newModelId,
        bool isDynamicRegenerate = false
      }) async {
    const String logPrefix = "[RegenerateService]";
    debugPrint(
        "$logPrefix: onRegenerate called for index: $messageIndex. Override model: '${newModelId ?? 'none'}'. Is Dynamic: $isDynamicRegenerate");

    // --- LINT FIX 1: Capture values from context BEFORE the first await. ---
    final localizations = AppLocalizations.of(context)!;

    if (_conversationProvider.isWaitingForResponse) {
      debugPrint("$logPrefix: Operation already in progress. Aborting.");
      return;
    }

    _scrollService.hideButtonImmediately();

    try {
      // The first `await` is an async gap.
      await _stopService.stopResponse();

      // --- LINT FIX 2: Guard context usage after the async gap. ---
      if (!context.mounted) {
        debugPrint("$logPrefix: Context is no longer mounted after stopResponse. Aborting.");
        return;
      }

      final messages = _conversationProvider.messages;

      if (messageIndex < 0 || messageIndex > messages.length) {
        debugPrint("$logPrefix: Invalid index ($messageIndex) for message list of length (${messages.length}). Aborting.");
        return;
      }

      final int triggerUserIndex = messages.sublist(0, messageIndex).lastIndexWhere((m) => m.isUserMessage);
      if (triggerUserIndex < 0) {
        debugPrint("$logPrefix: No preceding user message found. Aborting.");
        return;
      }
      final Message userMessageForRegeneration = messages[triggerUserIndex];

      // Model selection logic remains the same as it uses no context.
      String? modelIdForRequest;
      String modelIdForProvider;

      if (isDynamicRegenerate && newModelId == null) {
        modelIdForRequest = null;
        modelIdForProvider = userMessageForRegeneration.model ?? 'dynamic';
        debugPrint("$logPrefix: Dynamic regenerate initiated. `overrideModelId` will be null.");
      } else {
        final String resolvedModelId = newModelId ??
            (messageIndex < messages.length ? messages[messageIndex].model : userMessageForRegeneration.model)!;
        modelIdForRequest = resolvedModelId;
        modelIdForProvider = resolvedModelId;
        debugPrint("$logPrefix: Standard regenerate initiated. Model forced to '$resolvedModelId'.");
      }

      _conversationProvider.prepareForRegeneration(messageIndex, modelIdForProvider);
      _scrollService.updateButtonVisibility();

      // Second async gap.
      final conversationID = _conversationProvider.conversationID;
      if (conversationID != null) {
        await ChatStorageService.saveCurrentMessages(
            conversationID, _conversationProvider.messages);
      }

      // --- LINT FIX 3: Guard context usage again before the final async call. ---
      if (!context.mounted) {
        debugPrint("$logPrefix: Context is no longer mounted after saving messages. Aborting.");
        return;
      }

      debugPrint("$logPrefix: Delegating to SendService. Using request model: '${modelIdForRequest ?? 'dynamic'}'.");

      final newAiIndex = _conversationProvider.messages.length - 1;

      // Final async call using the guarded context and pre-captured localizations.
      await _sendService.sendMessage(
        context: context, // Safe to pass now because of the mounted check
        localizations: localizations, // Using the captured value
        messageText: userMessageForRegeneration.text,
        isRegenerate: true,
        regenerateAiIndex: newAiIndex,
        regeneratePhotoPath: userMessageForRegeneration.photoPath,
        overrideModelId: modelIdForRequest,
      );
      debugPrint("$logPrefix: sendMessage call completed successfully.");

    } catch (e, s) {
      debugPrint("$logPrefix: ERROR in onRegenerate: $e\nStack Trace: $s");
      // The error handling part uses `localizations`, which we safely captured at the beginning.
      if (_conversationProvider.isWaitingForResponse) {
        final thinkingIndex = _conversationProvider.messages.lastIndexWhere((m) => m.isThinking);
        if (thinkingIndex != -1) {
          _conversationProvider.setErrorMessage(
              thinkingIndex,
              localizations.anErrorOccurred,
              false
          );
        }
      }
    }
  }
}