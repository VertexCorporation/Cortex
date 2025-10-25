// lib/chat/services/send.dart

// This file defines the SendService, responsible for the business logic of
// sending messages. It acts as an orchestrator, reading state from the dedicated
// providers (Conversation, Session, Input) and coordinating actions between
// other services (API, Offline, Context) to fulfill a send request.
// It is completely decoupled from the UI.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/api.dart';
import 'package:cortex/chat/services/context.dart';
import 'package:cortex/chat/services/moderator.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/recent.dart';
import 'package:cortex/chat/services/review.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/models/backend/data/data.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/backend/data/info.dart';
import '../messages/messages.dart';

/// Service responsible for sending messages. It orchestrates interactions between providers and other services.
class SendService {
  // Dependencies on the new, separated providers
  final ConversationProvider _conversationProvider;
  final ChatSessionProvider _sessionProvider;
  final InputProvider _inputProvider;

  // Dependencies on other services
  final ApiService _apiService;
  final ContextService _contextService;
  final ScrollService _scrollService;
  final RecentModelsManager _recentModelsManager;
  final OfflineService _offlineService;

  final Uuid _uuid = const Uuid();
  bool _isSending = false;

  /// Constructs the SendService with all its required dependencies.
  SendService({
    required ConversationProvider conversationProvider,
    required ChatSessionProvider sessionProvider,
    required InputProvider inputProvider,
    required ApiService apiService,
    required ContextService contextService,
    required ScrollService scrollService,
    required RecentModelsManager recentModelsManager,
    required OfflineService offlineService,
  })  : _conversationProvider = conversationProvider,
        _sessionProvider = sessionProvider,
        _inputProvider = inputProvider,
        _apiService = apiService,
        _contextService = contextService,
        _scrollService = scrollService,
        _recentModelsManager = recentModelsManager,
        _offlineService = offlineService;


  /// Analyzes the current state to select a suitable model in "random dynamic chat" mode.
  /// Returns a model ID on success, or null on failure.
  Future<String?> _selectAndAssignDynamicModel() {
    debugPrint("[SendService] Dynamic mode: Selecting a random model...");
    // This logic remains the same as it correctly handles the "random" selection case.
    // ... (existing code for random selection)
    final allModels = _sessionProvider.allModels;
    final hasPhoto = _inputProvider.selectedPhoto != null;

    List<ModelInfo> suitableModels = allModels.where((model) {
      final modelData = ModelData.getPreciseModelData(model.id);
      final type = modelData['type'] as String?;
      final category = modelData['category'] as String?;

      if (category == 'roleplay' || category == 'self') return false;
      if (type == 'offline') return false;
      if (hasPhoto) return ModelData.hasModality(model.id, 'image');
      return true;
    }).toList();

    debugPrint("[SendService] Online. Has photo: $hasPhoto. Found ${suitableModels.length} suitable models.");

    if (suitableModels.isEmpty) {
      debugPrint("[SendService] No suitable random models found. Returning null.");
      return Future.value(null);
    }

    final selectedModelData = suitableModels[math.Random().nextInt(suitableModels.length)];
    final selectedModelId = selectedModelData.id;

    final extensions = ModelData.getPreciseModelData(selectedModelId)['extensions'] as Map<String, dynamic>?;
    final finalApiModelId = (extensions != null && extensions.isNotEmpty) ? extensions.keys.first : selectedModelId;

    debugPrint("[SendService] Dynamically and randomly selected model ID: $finalApiModelId.");
    return Future.value(finalApiModelId);
  }

  /// Central orchestration method for sending new messages.
  Future<bool> sendMessage({
    required BuildContext context,
    required AppLocalizations localizations,
    required String messageText,
    File? photo,
    bool isRegenerate = false,
    int? regenerateAiIndex,
    String? regeneratePhotoPath,
    String? overrideModelId,
  }) async {
    if (_isSending) return false;

    final String text = messageText.trim();
    if (text.isEmpty && photo == null && regeneratePhotoPath == null) return false;

    _isSending = true;

    try {
      String? apiModelIdForSend;
      String errorMessage = localizations.errorNoModelsAvailable;

      // =======================================================================
      // SECTION 1: DETERMINE THE MODEL TO USE (THE CORE FIX)
      // =======================================================================
      final hasInternet = await InternetConnection().hasInternetAccess;

      if (overrideModelId != null && overrideModelId.isNotEmpty) {
        // Priority 1: An override model ID is provided (e.g., for regeneration with a new model).
        apiModelIdForSend = overrideModelId;
        debugPrint("[SendService] Using override model ID: $apiModelIdForSend");
      } else if (_sessionProvider.isDynamicChat) {
        // Priority 2: We are in Dynamic Chat mode. Now we must check if an assistant is pinned.
        final pinnedAssistantId = _sessionProvider.modelId;
        if (pinnedAssistantId != null && pinnedAssistantId.isNotEmpty) {
          // A specific assistant is pinned. Use it directly.
          apiModelIdForSend = pinnedAssistantId;
          debugPrint("[SendService] Dynamic Chat with pinned assistant: $apiModelIdForSend");
        } else {
          // No assistant is pinned. Fall back to the random selection logic.
          apiModelIdForSend = await _selectAndAssignDynamicModel();
          debugPrint("[SendService] Dynamic Chat with random selection. Chose: $apiModelIdForSend");
        }
      } else {
        // Priority 3: This is a standard chat with a pre-selected model.
        apiModelIdForSend = _sessionProvider.modelId;
        debugPrint("[SendService] Standard chat with model: $apiModelIdForSend");
      }
      // =======================================================================
      // END OF FIX
      // =======================================================================


      // --- 2. Validate the Selected Model ---
      if (apiModelIdForSend == null || apiModelIdForSend.isEmpty) {
        errorMessage = localizations.errorNoModelsAvailable;
        apiModelIdForSend = null;
      } else if (Utils.isServerSideModel(apiModelIdForSend) && !hasInternet) {
        errorMessage = localizations.checkYourInternet;
        apiModelIdForSend = null;
      }

      if (apiModelIdForSend == null) {
        _handleSendError(ApiException(errorMessage), isRegenerate, regenerateAiIndex, localizations);
        return false;
      }

      // --- 3. Prepare the User Message and Update State ---
      final userMessage = Message(
        text: text,
        isUserMessage: true,
        photoPath: photo?.path ?? regeneratePhotoPath,
        isPhotoUploading: photo != null,
        model: apiModelIdForSend,
      );

      int aiMessageIndex;
      if (isRegenerate && regenerateAiIndex != null) {
        aiMessageIndex = regenerateAiIndex;
      } else {
        if (_conversationProvider.conversationID == null) {
          final newConvId = _uuid.v4();
          final newConvTitle = (text.isEmpty && userMessage.photoPath != null)
              ? "🖼️"
              : (text.length > 28 ? text.substring(0, 28) : text);

          // For storage, if a pinned assistant is used, we store its ID. Otherwise, 'dynamic'.
          final modelIdForStorage = (_sessionProvider.isDynamicChat && _sessionProvider.modelId != null)
              ? _sessionProvider.modelId!
              : (_sessionProvider.isDynamicChat ? 'dynamic' : apiModelIdForSend);

          _conversationProvider.startNewConversationSession(newConvId, newConvTitle, modelIdForStorage, userMessage);
        } else {
          _conversationProvider.appendMessageToConversation(userMessage);
        }
        aiMessageIndex = _conversationProvider.messages.length - 1;
      }

      _inputProvider.clearSelectedPhoto();

      // --- 4. Delegate to the Appropriate Sending Logic ---
      if (!Utils.isServerSideModel(apiModelIdForSend)) {
        final offlineModerator = OfflineModeratorService();
        if (offlineModerator.isPromptAcceptable(text)) {
          unawaited(_sendLocalMessage(text, userMessage.photoPath, apiModelIdForSend));
        } else {
          throw ApiException(localizations.errorPromptFlagged);
        }
      } else {
        await _sendServerSideMessage(
          text,
          apiModelIdForSend,
          userMessage.photoPath,
          localizations,
          aiMessageIndex,
        );
        _conversationProvider.finishBotResponse(aiMessageIndex);
      }

      // --- 5. Perform Post-Send Cleanup ---
      try {
        final parentId = ModelData.getBaseIdFromFullId(apiModelIdForSend);
        final modelIdToStore = parentId.isNotEmpty ? parentId : apiModelIdForSend;
        await ChatStorageService.addRecentModel(modelIdToStore);
        unawaited(_recentModelsManager.refresh());
      } catch (e) {
        debugPrint("[SendService] Could not update recent models for '$apiModelIdForSend'. Error: $e");
      }

      if (context.mounted) {
        unawaited(ReviewService().triggerReviewPromptIfNeeded(context));
      }

      return true;

    } catch (e) {
      if (e is UserCancelledException) {
        debugPrint("[SendService] Caught UserCancelledException. This is an expected outcome of a user stop action. Suppressing any further error UI.");
        return false; // Exit without calling _handleSendError.
      }

      // For ANY OTHER type of exception, we proceed with the original error handling logic.
      debugPrint("[SendService] Caught an unhandled exception: $e");
      _handleSendError(e, isRegenerate, regenerateAiIndex, localizations);
      return false;
    } finally {
      _isSending = false;
    }
  }

  /// Sends a message using a local (on-device) model via the OfflineService.
  Future<void> _sendLocalMessage(String text, String? photoPath, String modelId) async {
    try {
      debugPrint("[SendService] Delegating local message to OfflineService for model '$modelId'.");
      await _offlineService.sendMessage(text, photoPath);
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a message using a server-side model via the ApiService.
  Future<void> _sendServerSideMessage(
      String text,
      String modelIdForRequest,
      String? photoPath,
      AppLocalizations localizations,
      int aiMessageIndex,
      ) async {
    final modelData = ModelData.getPreciseModelData(modelIdForRequest);
    final bool isPremium = (modelData['tier'] as String? ?? 'free') == 'premium';
    final bool isCharacterModel = (modelData['category'] as String?) == 'roleplay' || (modelData['category'] as String?) == 'self';

    debugPrint("[SendService] Sending server request for model '$modelIdForRequest'. Is Premium: $isPremium");

    final memory = await _contextService.buildContextMessages(
      includeLastUser: false,
      targetModelId: modelIdForRequest,
    );

    Null onTextChunk(String textChunk) {
      if (_conversationProvider.wasResponseStopped) return;
      _conversationProvider.appendToLastBotMessage(textChunk);
      if (_scrollService.isUserAtBottom()) {
        _scrollService.scrollToBottom();
      }
    }

    Future<Null> onImageReceived(String imageUrl) async {
      if (_conversationProvider.wasResponseStopped) return;
      try {
        final imageBytes = base64Decode(imageUrl.split(',').last);
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/${_uuid.v4()}.png';
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);
        // This functionality needs to be added to ConversationProvider if desired.
        // _conversationProvider.updateBotMessageWithImage(aiMessageIndex, filePath);
      } catch (e) {
        debugPrint("[SendService] Error saving received image: $e");
        _conversationProvider.setErrorMessage(aiMessageIndex, localizations.errorImageLoad, false);
      }
    }

    if (isCharacterModel) {
      final baseModelId = modelData['baseModelId'] as String?;
      if (baseModelId == null || baseModelId.isEmpty) {
        throw ApiException("Character '$modelIdForRequest' has no valid base model configured.");
      }
      await _apiService.getCharacterResponse(
        userInput: text,
        context: memory,
        characterId: modelIdForRequest,
        baseModelId: baseModelId,
        isPremium: isPremium,
        photoPath: photoPath,
        onTextChunk: onTextChunk,
        onImageReceived: onImageReceived,
        localizations: localizations,
      );
    } else {
      await _apiService.getOnlineModelResponse(
        modelId: modelIdForRequest,
        userInput: text,
        context: memory,
        isPremium: isPremium,
        photoPath: photoPath,
        onTextChunk: onTextChunk,
        onImageReceived: onImageReceived,
        localizations: localizations,
      );
    }
  }

  /// Handles send errors by updating the ConversationProvider with an error state.
  void _handleSendError(Object error, bool isRegenerate, int? regenerateAiIndex, AppLocalizations localizations) {
    final String errorMessage = error is ApiException ? error.message : localizations.anErrorOccurred;
    final bool isContentFlagError = error is ApiException && error.message == localizations.errorPromptFlagged;

    if (isRegenerate && regenerateAiIndex != null) {
      _conversationProvider.setErrorMessage(regenerateAiIndex, errorMessage, isContentFlagError);
    } else {
      final userMessagePlaceholder = Message(
          text: "",
          isUserMessage: true,
          photoPath: _inputProvider.selectedPhoto?.path,
          includeInContext: !isContentFlagError
      );
      _conversationProvider.showSendError(userMessagePlaceholder, errorMessage, isContentFlagError);
    }
  }
}