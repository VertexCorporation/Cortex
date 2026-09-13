// lib/chat/services/regenerate.dart

import 'dart:async';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/send.dart';
import 'package:cortex/chat/services/stop.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ScaffoldMessenger, SnackBar;
import 'package:cortex/chat/messages/messages.dart';
import '../../l10n/app_localizations.dart';

/// Service responsible for orchestrating the message regeneration logic.
class RegenerateService {
  final ConversationProvider _conversationProvider;
  final StopService _stopService;
  final SendService _sendService;
  final ScrollService _scrollService;

  RegenerateService({
    required this._conversationProvider,
    required this._stopService,
    required this._sendService,
    required this._scrollService,
  });

  /// Continues a truncated AI response: keeps the partial text, re-enters
  /// the response loop with a continuation instruction, and streams the
  /// remainder into the SAME message. Only applies to persisted `isIncomplete`
  /// AI messages — the marker is produced by the server's terminal `done`
  /// event, so local/offline answers never need it.
  Future<void> onContinue(
    int aiMessageIndex, {
    required BuildContext context,
  }) async {
    const String logPrefix = "[RegenerateService]";
    debugPrint(
        "$logPrefix: onContinue called for index: $aiMessageIndex.");
    final localizations = AppLocalizations.of(context)!;
    if (_conversationProvider.isWaitingForResponse) {
      debugPrint("$logPrefix: Operation already in progress. Aborting.");
      return;
    }
    _scrollService.hideButtonImmediately();
    try {
      final messages = _conversationProvider.messages;
      if (aiMessageIndex < 0 || aiMessageIndex >= messages.length) {
        debugPrint("$logPrefix: Invalid index ($aiMessageIndex). Aborting.");
        return;
      }
      final Message partial = messages[aiMessageIndex];
      if (partial.isUserMessage || !partial.isIncomplete) {
        debugPrint(
            "$logPrefix: Target is not a truncated AI message. Aborting.");
        return;
      }

      _conversationProvider.prepareForContinuation(aiMessageIndex);

      // Persist the marked state so a continuation that runs in the
      // background still starts from the kept text.
      final conversationID = _conversationProvider.conversationID;
      if (conversationID != null) {
        await ChatStorageService.upsertMessage(
            conversationID, aiMessageIndex,
            _conversationProvider.messages[aiMessageIndex]);
      }
      if (!context.mounted) {
        debugPrint(
            "$logPrefix: Context is no longer mounted. Aborting.");
        return;
      }

      debugPrint("$logPrefix: Delegating to SendService (continue mode).");
      await _sendService.sendMessage(
        context: context,
        localizations: localizations,
        // No new user text: the response loop appends the continuation
        // instruction itself, and the partial answer is already in context.
        messageText: '',
        isRegenerate: true,
        regenerateAiIndex: aiMessageIndex,
        // Continue with the model that produced the partial answer — even if
        // the user has since switched models — so the continuation matches
        // the voice and context of what is already on screen.
        overrideModelId: partial.model,
        isContinue: true,
      );
      debugPrint("$logPrefix: sendMessage (continue) call completed.");
    } catch (e, s) {
      debugPrint("$logPrefix: ERROR in onContinue: $e\nStack Trace: $s");
      if (_conversationProvider.isWaitingForResponse) {
        final thinkingIndex =
            _conversationProvider.messages.lastIndexWhere((m) => m.isThinking);
        if (thinkingIndex != -1) {
          _conversationProvider.finishBotResponse(thinkingIndex);
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.anErrorOccurred)),
        );
      }
    }
  }

  Future<void> onRegenerate(
    int messageIndex, {
    required BuildContext context,
    String? newModelId,
    bool isDynamicRegenerate = false,
  }) async {
    const String logPrefix = "[RegenerateService]";
    debugPrint(
        "$logPrefix: onRegenerate called for index: $messageIndex. Override model: '${newModelId ?? 'none'}'. Is Dynamic: $isDynamicRegenerate");
    final localizations = AppLocalizations.of(context)!;
    if (_conversationProvider.isWaitingForResponse) {
      debugPrint("$logPrefix: Operation already in progress. Aborting.");
      return;
    }
    _scrollService.hideButtonImmediately();
    try {
      await _stopService.stopResponse();
      if (!context.mounted) {
        debugPrint(
            "$logPrefix: Context is no longer mounted after stopResponse. Aborting.");
        return;
      }

      final messages = _conversationProvider.messages;

      if (messageIndex < 0 || messageIndex > messages.length) {
        debugPrint("$logPrefix: Invalid index ($messageIndex). Aborting.");
        return;
      }

      final int triggerUserIndex = messages
          .sublist(0, messageIndex)
          .lastIndexWhere((m) => m.isUserMessage);
      if (triggerUserIndex < 0) {
        debugPrint("$logPrefix: No preceding user message found. Aborting.");
        return;
      }
      final Message userMessageForRegeneration = messages[triggerUserIndex];

      String? modelIdForRequest;
      String modelIdForProvider;

      if (isDynamicRegenerate && newModelId == null) {
        modelIdForRequest = null;
        modelIdForProvider = userMessageForRegeneration.model ?? 'dynamic';
        debugPrint("$logPrefix: Dynamic regenerate initiated.");
      } else {
        final String resolvedModelId = newModelId ??
            (messageIndex < messages.length
                ? messages[messageIndex].model
                : userMessageForRegeneration.model)!;
        modelIdForRequest = resolvedModelId;
        modelIdForProvider = resolvedModelId;
        debugPrint(
            "$logPrefix: Standard regenerate initiated with '$resolvedModelId'.");
      }

      _conversationProvider.prepareForRegeneration(
          messageIndex, modelIdForProvider);
      _scrollService.updateButtonVisibility();

      final conversationID = _conversationProvider.conversationID;
      if (conversationID != null) {
        await ChatStorageService.saveCurrentMessages(
            conversationID, _conversationProvider.messages);
      }
      if (!context.mounted) {
        debugPrint(
            "$logPrefix: Context is no longer mounted after saving messages. Aborting.");
        return;
      }
      debugPrint("$logPrefix: Delegating to SendService.");
      final newAiIndex = _conversationProvider.messages.length - 1;

      await _sendService.sendMessage(
        context: context,
        localizations: localizations,
        messageText: userMessageForRegeneration.text,
        isRegenerate: true,
        regenerateAiIndex: newAiIndex,
        overrideModelId: modelIdForRequest,
        // LOGIC UPDATE: We don't need to explicitly pass 'photoPath' here.
        // The SendService logic will look up the last user message from the provider
        // to get its attachments if 'isRegenerate' is true.
      );
      debugPrint("$logPrefix: sendMessage call completed successfully.");
    } catch (e, s) {
      debugPrint("$logPrefix: ERROR in onRegenerate: $e\nStack Trace: $s");
      if (_conversationProvider.isWaitingForResponse) {
        final thinkingIndex =
            _conversationProvider.messages.lastIndexWhere((m) => m.isThinking);
        if (thinkingIndex != -1) {
          _conversationProvider.setErrorMessage(
              thinkingIndex, localizations.anErrorOccurred, false);
        }
      }
    }
  }
}
