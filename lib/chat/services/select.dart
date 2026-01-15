// lib/chat/services/select.dart

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../main.dart';
import '../../variants.dart';

/// Service responsible for all logic related to model selection and updates.
///
/// It orchestrates state changes across `ChatSessionProvider` and `ConversationProvider`.
class SelectionService {
  final ChatSessionProvider _sessionProvider;
  final ConversationProvider _conversationProvider;
  final ModelService _modelService;

  SelectionService({
    required ChatSessionProvider sessionProvider,
    required ConversationProvider conversationProvider,
    required ModelService modelService,
  })  : _sessionProvider = sessionProvider,
        _conversationProvider = conversationProvider,
        _modelService = modelService;

  /// Selects a model to start a new chat session using a ModelEntity.
  ///
  /// It orchestrates a full reset of the chat state by:
  /// 1. Navigating to the chat tab if called from an external screen.
  /// 2. Clearing the previous conversation's state.
  /// 3. Resolving the precise model/variant to use (e.g., last used).
  /// 4. Setting the new model details in the session provider.
  Future<void> selectModel(ModelEntity aiEntity, {BuildContext? context}) async {
    const String logPrefix = "[SelectionService.selectModel]";
    debugPrint("$logPrefix: Processing selection for model series '${aiEntity.id}'.");

    // This part handles navigation from outside the chat screen (e.g., Library).
    // It now passes the ModelEntity directly to MainScreen.
    if (context != null && context.mounted) {
      Provider.of<TabProvider>(context, listen: false);
      mainScreenKey.currentState?.startChatWithModel(aiEntity);
      return;
    }

    // --- Logic for selecting a model from within the chat screen ---

    // 1. Clear any previous conversation.
    _conversationProvider.clearConversation();

    // 2. Resolve the precise model ID to use (if it's a series with variants).
    final variantsMap = aiEntity.variants;
    String finalModelId;

    if (variantsMap != null && variantsMap.isNotEmpty) {
      String lastUsedId = await Variants.getLastSelectedVariant(aiEntity.id);
      finalModelId = (lastUsedId.isNotEmpty && variantsMap.containsKey(lastUsedId))
          ? lastUsedId
          : variantsMap.keys.first;
    } else {
      finalModelId = aiEntity.id;
    }
    debugPrint("$logPrefix: Resolved final model ID to: '$finalModelId'");

    // 3. Get the precise entity for the final selected model.
    final langCode = _sessionProvider.getLocale().languageCode;
    final finalModelEntity = _modelService.getPreciseModelData(finalModelId, langCode: langCode);
    _sessionProvider.selectModel(finalModelEntity);

    // 4. Update the session provider directly with the final ModelEntity.
    _sessionProvider.selectModel(finalModelEntity);

    debugPrint("$logPrefix: Session and Conversation providers updated for new chat session.");
  }

  /// Changes the active model to a different variant within the same series.
  ///
  /// This method updates the session state without resetting the conversation,
  /// preserving the message history.
  Future<void> changeVariant(String newFullModelId) async {
    const String logPrefix = "[SelectionService.changeVariant]";
    debugPrint("$logPrefix: Changing variant to '$newFullModelId'.");

    if (_sessionProvider.modelId == newFullModelId) return;

    final langCode = _sessionProvider.getLocale().languageCode;
    final baseId = _modelService.getBaseIdFromFullId(newFullModelId, langCode: langCode);
    await Variants.setLastSelectedVariant(baseId, newFullModelId);

    // Call the specific provider method that updates the model details
    // WITHOUT clearing the message list. This is a session-level change.
    _sessionProvider.updateActiveModelVariant(newFullModelId);

    debugPrint("$logPrefix: Session provider updated with new variant details.");
  }

  /// Refreshes the active chat's model details from the latest available data.
  ///
  /// This is called after a global model data reload (e.g., language change)
  /// to ensure the UI reflects the most current information.
  void refreshActiveChatModelDetails(String activeModelId) {
    const String logPrefix = "[SelectionService.refreshActiveChatModelDetails]";
    debugPrint("$logPrefix: Refreshing details for active model '$activeModelId'.");

    // This method is identical in function to changing an variant: it updates
    // the model's metadata without resetting the chat.
    _sessionProvider.updateActiveModelVariant(activeModelId);

    debugPrint("$logPrefix: Session provider refreshed with latest model details.");
  }
}