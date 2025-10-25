// lib/chat/services/select.dart

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/backend/data/data.dart';
import '../../extensions.dart';
import '../../models/backend/data/info.dart';

/// Service responsible for all logic related to model selection and updates.
///
/// It orchestrates state changes across `ChatSessionProvider` and `ConversationProvider`.
class SelectionService {
  final ChatSessionProvider _sessionProvider;
  final ConversationProvider _conversationProvider;

  SelectionService({
    required ChatSessionProvider sessionProvider,
    required ConversationProvider conversationProvider,
  })  : _sessionProvider = sessionProvider,
        _conversationProvider = conversationProvider;

  /// Selects a model series to start a new chat session.
  ///
  /// It orchestrates a full reset of the chat state:
  /// 1. Sets the "previous tab index" in MainScreenState if context is provided.
  /// 2. Switches to the chat tab (index 0).
  /// 3. Clears the previous conversation.
  /// 4. Sets the new model details in the session.
  Future<void> selectModel(ModelInfo modelSeriesInfo, {BuildContext? context}) async {
    const String logPrefix = "[SelectionService.selectModel]";
    debugPrint("$logPrefix: Processing selection for model series '${modelSeriesInfo.id}'.");

    if (context != null && context.mounted) {
      Provider.of<TabProvider>(context, listen: false);
      mainScreenKey.currentState?.startChatWithModel(modelSeriesInfo);
      return;
    }

    // 1. Clear any previous conversation and input state.
    _conversationProvider.clearConversation();

    // 2. Resolve the precise model ID to use.
    final Map<String, dynamic> seriesData = ModelData.getPreciseModelData(modelSeriesInfo.id);
    final extensionsMap = seriesData['extensions'] as Map<String, dynamic>?;

    String finalModelId;
    if (extensionsMap != null && extensionsMap.isNotEmpty) {
      String lastUsedId = await Extensions.getLastSelectedExtension(modelSeriesInfo.id);
      finalModelId = (lastUsedId.isNotEmpty && extensionsMap.containsKey(lastUsedId))
          ? lastUsedId
          : extensionsMap.keys.first;
    } else {
      finalModelId = modelSeriesInfo.id;
    }
    debugPrint("$logPrefix: Resolved final model ID to: '$finalModelId'");

    final Map<String, dynamic> preciseModelData = ModelData.getPreciseModelData(finalModelId);

    // 3. Construct the full ModelInfo object for the session.
    final finalModelInfo = ModelInfo(
      id: finalModelId,
      title: seriesData['title'] as String? ?? modelSeriesInfo.title,
      imagePath: ModelData.getModelImagePath(seriesData),
      producer: seriesData['producer'] as String? ?? modelSeriesInfo.producer,
      category: seriesData['category'] as String?,
      extensions: extensionsMap,
    );

    // 4. Update the session provider with the new model details.
    _sessionProvider.selectModel(finalModelInfo, preciseData: preciseModelData);

    debugPrint("$logPrefix: Session and Conversation providers updated for new chat session.");
  }

  // ... (changeExtension ve refreshActiveChatModelDetails metotları aynı kalır)
  /// Changes the active model to a different extension within the same series.
  ///
  /// This method updates the session state without resetting the conversation,
  /// preserving the message history.
  Future<void> changeExtension(String newFullModelId) async {
    const String logPrefix = "[SelectionService.changeExtension]";
    debugPrint("$logPrefix: Changing extension to '$newFullModelId'.");

    if (_sessionProvider.modelId == newFullModelId) return;

    final baseId = ModelData.getBaseIdFromFullId(newFullModelId);
    await Extensions.setLastSelectedExtension(baseId, newFullModelId);

    // Call the specific provider method that updates the model details
    // WITHOUT clearing the message list. This is a session-level change.
    _sessionProvider.updateActiveModelExtension(newFullModelId);

    debugPrint("$logPrefix: Session provider updated with new extension details.");
  }

  /// Refreshes the active chat's model details from the latest available data.
  ///
  /// This is called after a global model data reload (e.g., language change)
  /// to ensure the UI reflects the most current information.
  void refreshActiveChatModelDetails(String activeModelId) {
    const String logPrefix = "[SelectionService.refreshActiveChatModelDetails]";
    debugPrint("$logPrefix: Refreshing details for active model '$activeModelId'.");

    // This method is identical in function to changing an extension: it updates
    // the model's metadata without resetting the chat.
    _sessionProvider.updateActiveModelExtension(activeModelId);

    debugPrint("$logPrefix: Session provider refreshed with latest model details.");
  }
}