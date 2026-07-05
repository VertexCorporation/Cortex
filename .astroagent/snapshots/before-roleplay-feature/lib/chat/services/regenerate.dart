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
  })
      : _conversationProvider = conversationProvider,
        _stopService = stopService,
        _sendService = sendService,
        _scrollService = scrollService;

  Future<void> onRegenerate(int messageIndex, {
    required BuildContext context,
    String? newModelId,
    bool isDynamicRegenerate = false,
  }) async {
    const String logPrefix = "[RegenerateService]";
    debugPrint(
        "$logPrefix: onRegenerate called for index: $messageIndex. Override model: '${newModelId ??
            'none'}'. Is Dynamic: $isDynamicRegenerate");
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

      final int triggerUserIndex =
      messages.sublist(0, messageIndex).lastIndexWhere((m) => m.isUserMessage);
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

      // Final Call
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