// lib/chat/services/send.dart

// This file defines the SendService, responsible for the business logic of
// sending messages. It acts as an orchestrator, reading state from the dedicated
// providers (Conversation, Session, Input) and coordinating actions between
// other services (API, Offline, Context) to fulfill a send request.
// It is completely decoupled from the UI.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/api.dart';
import 'package:cortex/chat/services/context.dart';
import 'package:cortex/chat/services/moderator.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../library/providers/local.dart';
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
  final OfflineService _offlineService;
  final Uuid _uuid = const Uuid();
  bool _isSending = false;
  final ModelService _modelService;

  /// Constructs the SendService with all its required dependencies.
  SendService({
    required ConversationProvider conversationProvider,
    required ChatSessionProvider sessionProvider,
    required InputProvider inputProvider,
    required ApiService apiService,
    required ContextService contextService,
    required ScrollService scrollService,
    required OfflineService offlineService,
    required ModelService modelService,
  })  : _conversationProvider = conversationProvider,
        _sessionProvider = sessionProvider,
        _inputProvider = inputProvider,
        _apiService = apiService,
        _contextService = contextService,
        _scrollService = scrollService,
        _offlineService = offlineService,
        _modelService = modelService;

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

    debugPrint(
      "[SendService] sendMessage called → "
          "isRegenerate=$isRegenerate, "
          "regenerateAiIndex=$regenerateAiIndex, "
          "incomingPhotoParam=${photo?.path}, "
          "regeneratePhotoPathParam=$regeneratePhotoPath, "
          "currentMessages=${_conversationProvider.messages.length}",
    );

    _isSending = true;

    try {
      String? apiModelIdForSend;
      String errorMessage = localizations.errorNoModelsAvailable;
      final localState = context.read<ModelLocalStateProvider>();

      // --- Get langCode once at the beginning to pass to all helpers ---
      final langCode = Localizations.localeOf(context).languageCode;

      final hasInternet = await InternetConnection().hasInternetAccess;

      if (overrideModelId != null && overrideModelId.isNotEmpty) {
        apiModelIdForSend = overrideModelId;
        debugPrint("[SendService] Using overrideModelId: $overrideModelId");
      } else if (_sessionProvider.isDynamicChat) {
        // --- DYNAMIC CHAT LOGIC ---
        if (hasInternet) {
          // 1. ONLINE: Use Pinned Model OR Auto Router
          final pinnedAssistantId = _sessionProvider.modelId;
          if (pinnedAssistantId != null && pinnedAssistantId.isNotEmpty) {
            apiModelIdForSend = pinnedAssistantId;
            debugPrint("[SendService] Dynamic chat (Online) pinned model: $apiModelIdForSend");
          } else {
            apiModelIdForSend = 'cortex/auto';
            debugPrint("[SendService] Dynamic chat (Online) using Auto Router: $apiModelIdForSend");
          }
        } else {
          // 2. OFFLINE: Fallback to Local Models
          debugPrint("[SendService] Dynamic chat (Offline): Attempting to find a suitable local model.");

          final downloadedStates = localState.downloadCompleted;
          final allCachedModels = _modelService.getCachedModelsSync();

          // Filter: Must be offline type AND marked as downloaded in local state
          final offlineModels = allCachedModels.where((m) {
            return !m.isServerSide && (downloadedStates[m.id] == true);
          }).toList();

          if (offlineModels.isEmpty) {
            errorMessage = localizations.errorNoModelsAvailable;
            apiModelIdForSend = null;
            debugPrint("[SendService] Dynamic chat (Offline): No downloaded models found.");
          } else if (offlineModels.length == 1) {
            // Only one option, use it.
            final model = offlineModels.first;
            apiModelIdForSend = model.id;
            debugPrint("[SendService] Dynamic chat (Offline): Single model available. Selected: ${model.id}");

            // Check vision support
            final bool supportsImage = model.modalities['image'] == true;
            if ((photo != null || regeneratePhotoPath != null) && !supportsImage) {
              debugPrint("[SendService] Warning: Model ${model.id} does not support vision. Discarding photo.");
              photo = null;
              regeneratePhotoPath = null;
            }
          } else {
            // Multiple options: Smart Selection
            final hasPhoto = photo != null || regeneratePhotoPath != null;
            final random = Random();

            if (hasPhoto) {
              // Try to find ANY model that supports images
              final visionModels = offlineModels.where((m) => m.modalities['image'] == true).toList();

              if (visionModels.isNotEmpty) {
                // Pick a random one among those who support vision
                final selectedModel = visionModels[random.nextInt(visionModels.length)];
                apiModelIdForSend = selectedModel.id;
                debugPrint("[SendService] Dynamic chat (Offline): Selected vision-capable model: ${selectedModel.id}");
              } else {
                // No vision model installed. Pick a random text model and discard photo.
                debugPrint("[SendService] Dynamic chat (Offline): No vision model found for photo. Discarding photo.");
                photo = null;
                regeneratePhotoPath = null;
                final selectedModel = offlineModels[random.nextInt(offlineModels.length)];
                apiModelIdForSend = selectedModel.id;
              }
            } else {
              // No photo: Pick a completely random offline model
              final selectedModel = offlineModels[random.nextInt(offlineModels.length)];
              apiModelIdForSend = selectedModel.id;
              debugPrint("[SendService] Dynamic chat (Offline): Randomly selected text model: $apiModelIdForSend");
            }
          }
        }
      } else {
        // --- STATIC CHAT LOGIC ---
        apiModelIdForSend = _sessionProvider.modelId;
        debugPrint("[SendService] Static chat using session model: $apiModelIdForSend");
      }

      // --- 2. Validate the Selected Model ---
      // We check if it is 'auto' specifically to skip standard validation
      final isAutoRouter = apiModelIdForSend == 'cortex/auto';

      if (apiModelIdForSend == null || apiModelIdForSend.isEmpty) {
        // Error message is already set above for specific cases, fallback to default if needed.
        if (apiModelIdForSend == null && errorMessage == localizations.errorNoModelsAvailable) {
          // Keep existing error message
        } else {
          errorMessage = localizations.errorNoModelsAvailable;
        }
        apiModelIdForSend = null;
        debugPrint("[SendService] Model validation failed: No model selected.");
      } else if (!isAutoRouter &&
          Utils.isServerSideModel(apiModelIdForSend, langCode: langCode, modelService: _modelService) &&
          !hasInternet) {
        // Standard server-side models require internet
        errorMessage = localizations.checkYourInternet;
        apiModelIdForSend = null;
        debugPrint("[SendService] Model validation failed: Server-side model but no internet.");
      } else if (isAutoRouter && !hasInternet) {
        // Auto router is strictly server-side
        errorMessage = localizations.checkYourInternet;
        apiModelIdForSend = null;
        debugPrint("[SendService] Model validation failed: Auto Router requires internet.");
      }

      if (apiModelIdForSend == null) {
        _handleSendError(
          ApiException(errorMessage),
          isRegenerate,
          regenerateAiIndex,
          localizations,
          failedUserText: text,
          failedPhotoPath: photo?.path,
        );
        return false;
      }

      // --- 3. Prepare the User Message and Update State ---

      debugPrint("[SendService] Resolving effectivePhotoPath...");

      // Compute the effective photo path. In regenerate flow we ALWAYS trust
      // the latest user message in the conversation (so edits are respected).
      String? effectivePhotoPath;

      if (photo != null) {
        effectivePhotoPath = photo.path;
        debugPrint("[SendService] Using DIRECT photo from parameter: $effectivePhotoPath");
      } else if (isRegenerate) {
        final messages = _conversationProvider.messages;
        Message? lastUserMessage;
        int lastUserIndex = -1;

        for (int i = messages.length - 1; i >= 0; i--) {
          if (messages[i].isUserMessage) {
            lastUserMessage = messages[i];
            lastUserIndex = i;
            break;
          }
        }

        if (lastUserMessage != null) {
          // If we discarded the photo earlier (because model didn't support it), effectivePhotoPath stays null.
          if (regeneratePhotoPath != null || photo != null) {
            effectivePhotoPath = lastUserMessage.photoPath;
          } else {
            // If logic above set photo/regeneratePhotoPath to null, we respect that.
            effectivePhotoPath = null;
          }

          debugPrint(
            "[SendService] Regenerate flow: using lastUserMessage at index "
                "$lastUserIndex with photoPath=${lastUserMessage.photoPath}. Effective: $effectivePhotoPath",
          );
        } else {
          effectivePhotoPath = null;
          debugPrint("[SendService] Regenerate flow: no user message found → photoPath=null");
        }
      } else {
        effectivePhotoPath = null;
        debugPrint("[SendService] Normal send without photo. photoPath=null");
      }

      debugPrint("[SendService] Final effectivePhotoPath=$effectivePhotoPath");

      final userMessage = Message(
        text: text,
        isUserMessage: true,
        photoPath: effectivePhotoPath,
        isPhotoUploading: photo != null,
        model: apiModelIdForSend,
      );

      debugPrint(
        "[SendService] Creating userMessage → "
            "text='${text.substring(0, text.length.clamp(0, 50))}', "
            "photoPath=${userMessage.photoPath}, "
            "model=$apiModelIdForSend, "
            "isRegenerate=$isRegenerate",
      );

      int aiMessageIndex;
      if (isRegenerate && regenerateAiIndex != null) {
        aiMessageIndex = regenerateAiIndex;
        debugPrint("[SendService] Regenerate mode: Reusing aiMessageIndex=$aiMessageIndex");
      } else {
        if (_conversationProvider.conversationID == null) {
          final newConvId = _uuid.v4();
          final newConvTitle = (text.isEmpty && userMessage.photoPath != null)
              ? "🖼️"
              : (text.length > 28 ? text.substring(0, 28) : text);
          final modelIdForStorage =
          (_sessionProvider.isDynamicChat && _sessionProvider.modelId != null)
              ? _sessionProvider.modelId!
              : (_sessionProvider.isDynamicChat ? 'dynamic' : apiModelIdForSend);
          debugPrint(
            "[SendService] Starting new conversation → "
                "id=$newConvId, title='$newConvTitle', modelIdForStorage=$modelIdForStorage",
          );
          _conversationProvider.startNewConversationSession(
            newConvId,
            newConvTitle,
            modelIdForStorage,
            userMessage,
          );
        } else {
          debugPrint("[SendService] Appending user message to existing conversation.");
          _conversationProvider.appendMessageToConversation(userMessage);
        }
        aiMessageIndex = _conversationProvider.messages.length - 1;
        debugPrint("[SendService] AI message will be at index $aiMessageIndex");
      }

      _inputProvider.clearSelectedPhoto();
      debugPrint("[SendService] InputProvider selectedPhoto cleared after send.");

      // --- 4. Delegate to the Appropriate Sending Logic ---
      // If it is 'auto', we skip the local model check because it is definitely server-side.
      if (!isAutoRouter &&
          !Utils.isServerSideModel(apiModelIdForSend, langCode: langCode, modelService: _modelService)) {
        final offlineModerator = OfflineModeratorService();
        if (offlineModerator.isPromptAcceptable(text)) {
          debugPrint("[SendService] Routing message to OfflineService (local model).");
          unawaited(_sendLocalMessage(text, userMessage.photoPath, apiModelIdForSend));
        } else {
          debugPrint("[SendService] Prompt rejected by OfflineModerator.");
          throw ApiException(localizations.errorPromptFlagged);
        }
      } else {
        debugPrint("[SendService] Routing message to ApiService (server-side).");
        await _sendServerSideMessage(
          text,
          apiModelIdForSend,
          userMessage.photoPath,
          localizations,
          aiMessageIndex,
          langCode,
        );
        _conversationProvider.finishBotResponse(aiMessageIndex);
      }

      // --- 5. Perform Post-Send Cleanup ---
      // We don't save 'auto' to recent models to avoid cluttering the UI with internal IDs.
      if (!isAutoRouter) {
        try {
          await ChatStorageService.addRecentModel(
            apiModelIdForSend,
            langCode: langCode,
            modelService: _modelService,
          );
        } catch (e) {
          debugPrint("[SendService] Could not update recent models for '$apiModelIdForSend'. Error: $e");
        }
      }
      return true;
    } catch (e) {
      if (e is UserCancelledException) {
        debugPrint("[SendService] Caught UserCancelledException. Suppressing error UI.");
        return false;
      }
      debugPrint("[SendService] Caught an unhandled exception: $e");
      _handleSendError(e, isRegenerate, regenerateAiIndex, localizations);
      return false;
    } finally {
      _isSending = false;
      debugPrint("[SendService] sendMessage completed. isRegenerate=$isRegenerate");
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
      String langCode,
      ) async {
    final bool isAutoRouter = modelIdForRequest == 'cortex/auto';

    // If it's the Auto Router, we don't fetch local entity data because the ID doesn't exist there.
    // We treat it as a generic premium, online model.
    final ModelEntity model = _modelService.getPreciseModelData(modelIdForRequest, langCode: langCode);

    // Auto router generally routes to top-tier models (GPT-4, Claude 3.5), so we treat it as Premium
    // to ensure correct credit deduction logic in Cloud Functions.
    final bool isPremium = model.isPremium;

    final bool isCharacterModel =
    isAutoRouter ? false : (model.category == 'roleplay' || model.category == 'self');

    debugPrint(
      "[SendService] Sending server request for model '$modelIdForRequest'. "
          "Is Auto: $isAutoRouter, Is Premium: $isPremium",
    );

    final memory = await _contextService.buildContextMessages(
      includeLastUser: false,
      targetModelId: modelIdForRequest,
      langCode: langCode, // Pass langCode down to the context service.
    );

    // This helper function is called for each piece of text streamed from the API.
    void onTextChunk(String textChunk) {
      if (_conversationProvider.wasResponseStopped) return;
      _conversationProvider.appendToLastBotMessage(textChunk);
      if (_scrollService.isUserAtBottom()) {
        _scrollService.scrollToBottom();
      }
    }

    // This helper function is called when the API generates and returns an image.
    Future<void> onImageReceived(String imageUrl) async {
      if (_conversationProvider.wasResponseStopped) return;
      try {
        final imageBytes = base64Decode(imageUrl.split(',').last);
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/${_uuid.v4()}.png';
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);
      } catch (e) {
        debugPrint("[SendService] Error saving received image: $e");
        _conversationProvider.setErrorMessage(aiMessageIndex, localizations.errorImageLoad, false);
      }
    }

    if (isCharacterModel) {
      // Use the safe property from the entity.
      final baseModelId = model.baseModelId;
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
  void _handleSendError(
      Object error,
      bool isRegenerate,
      int? regenerateAiIndex,
      AppLocalizations localizations, {
        String? failedUserText,
        String? failedPhotoPath,
      }) {
    final String errorMessage = error is ApiException ? error.message : localizations.anErrorOccurred;
    final bool isContentFlagError =
        error is ApiException && error.message == localizations.errorPromptFlagged;

    if (isRegenerate && regenerateAiIndex != null) {
      _conversationProvider.setErrorMessage(
        regenerateAiIndex,
        errorMessage,
        isContentFlagError,
      );
    } else {
      final userMessagePlaceholder = Message(
        text: failedUserText ?? "",
        isUserMessage: true,
        photoPath: failedPhotoPath ?? _inputProvider.selectedPhoto?.path,
        includeInContext: !isContentFlagError,
      );

      _conversationProvider.showSendError(
        userMessagePlaceholder,
        errorMessage,
        isContentFlagError,
      );
    }
  }
}