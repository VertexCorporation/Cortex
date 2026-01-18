// lib/chat/services/send.dart

// This file defines the SendService, responsible for the business logic of
// sending messages. It acts as an orchestrator, reading state from the dedicated
// providers (Conversation, Session, Input) and coordinating actions between
// other services (API, Offline, Context) to fulfill a send request.
// It is completely decoupled from the UI.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  })
      : _conversationProvider = conversationProvider,
        _inputProvider = inputProvider,
        _apiService = apiService,
        _contextService = contextService,
        _scrollService = scrollService,
        _offlineService = offlineService,
        _modelService = modelService;

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

    final inputProvider = context.read<InputProvider>();
    final sessionProvider = context.read<ChatSessionProvider>();

    final String text = messageText.trim();
    if (text.isEmpty && photo == null && regeneratePhotoPath == null) {
      return false;
    }

    _isSending = true;

    try {
      // -----------------------------------------------------------------------
      // 0. HANDLE FEATURE MODES (Hidden System Prompts)
      // -----------------------------------------------------------------------

      final activeMode = inputProvider.featureMode;

      String textForApi = text;

      if (activeMode == ChatInputMode.study) {
        textForApi = "${localizations.featureStudyMessage}\n\n$text";
      } else if (activeMode == ChatInputMode.quiz) {
        textForApi = "${localizations.featureQuizMessage}\n\n$text";
      }

      String? apiModelIdForSend;
      String errorMessage = localizations.errorNoModelsAvailable;

      final localState = context.read<ModelLocalStateProvider>();
      final langCode = Localizations
          .localeOf(context)
          .languageCode;
      final hasInternet = await InternetConnection().hasInternetAccess;

      // -----------------------------------------------------------------------
      // 1. DETERMINE INITIAL TARGET ID
      // -----------------------------------------------------------------------

      if (overrideModelId != null && overrideModelId.isNotEmpty) {
        apiModelIdForSend = overrideModelId;
      } else if (sessionProvider
          .isDynamicChat) {
        apiModelIdForSend = 'cortex/auto';
      } else {
        apiModelIdForSend =
            sessionProvider.modelId;
      }

      // -----------------------------------------------------------------------
      // 2. SMART MODEL RESOLUTION
      // -----------------------------------------------------------------------

      if (apiModelIdForSend != null && apiModelIdForSend != 'cortex/auto') {
        final ModelEntity entity = _modelService.getPreciseModelData(
            apiModelIdForSend, langCode: langCode);

        if (entity.variants != null && entity.variants!.isNotEmpty) {
          final List<dynamic> variants = entity.variants!.values.toList();
          final bool hasPhoto = photo != null || regeneratePhotoPath != null;

          List<dynamic> getPreferredCandidates(List<dynamic> sourceList) {
            final filtered = sourceList.where((v) {
              final String vid = v['id'].toString().toLowerCase();
              final String vTier = v['tier']?.toString().toLowerCase() ??
                  'free';
              final bool isGuard = vid.contains('guard');
              final bool isPremium = vTier == 'premium';
              return !isGuard && !isPremium;
            }).toList();
            return filtered.isNotEmpty ? filtered : sourceList;
          }

          final bool mustRunOffline = (entity.type == 'offline') ||
              (!hasInternet && !entity.isServerSide);

          if (mustRunOffline) {
            final downloadedVariants = variants.where((v) {
              final String vId = v['id'];
              return localState.downloadCompleted[vId] == true;
            }).toList();

            if (downloadedVariants.isEmpty) {
              errorMessage = localizations.errorNoModelsAvailable;
              apiModelIdForSend = null;
            } else {
              if (hasPhoto) {
                final visionModel = downloadedVariants.firstWhere(
                        (v) => (v['modalities']?['image'] == true),
                    orElse: () => null
                );
                apiModelIdForSend = visionModel != null
                    ? visionModel['id']
                    : getPreferredCandidates(downloadedVariants).first['id'];
              } else {
                final candidates = getPreferredCandidates(downloadedVariants);
                apiModelIdForSend = candidates.first['id'];
              }
            }
          } else {
            if (hasPhoto) {
              final visionModel = variants.firstWhere(
                      (v) => (v['modalities']?['image'] == true),
                  orElse: () => null
              );
              apiModelIdForSend = visionModel != null
                  ? visionModel['id']
                  : getPreferredCandidates(variants).first['id'];
            } else {
              final candidates = getPreferredCandidates(variants);
              apiModelIdForSend = candidates.first['id'];
            }
          }
        }
      }

      // -----------------------------------------------------------------------
      // 3. VALIDATION & PREPARATION
      // -----------------------------------------------------------------------

      final isAutoRouter = apiModelIdForSend == 'cortex/auto';

      if (apiModelIdForSend == null || apiModelIdForSend.isEmpty) {
        _handleSendError(
          ApiException(errorMessage),
          isRegenerate,
          regenerateAiIndex,
          localizations,
          failedUserText: text,
          failedPhotoPath: photo?.path ?? inputProvider.selectedPhoto?.path,
        );
        return false;
      }

      if (!isAutoRouter &&
          Utils.isServerSideModel(apiModelIdForSend, langCode: langCode,
              modelService: _modelService) &&
          !hasInternet) {
        errorMessage = localizations.checkYourInternet;
        _handleSendError(
            ApiException(errorMessage), isRegenerate, regenerateAiIndex,
            localizations,
            failedUserText: text,
            failedPhotoPath: photo?.path ?? inputProvider.selectedPhoto?.path);
        return false;
      }

      String? effectivePhotoPath;
      if (photo != null) {
        effectivePhotoPath = photo.path;
      } else if (isRegenerate) {
        final messages = _conversationProvider.messages;
        final lastUserMessage = messages.reversed.firstWhere((m) =>
        m.isUserMessage, orElse: () => Message(text: '', isUserMessage: true));

        if (regeneratePhotoPath != null) {
          effectivePhotoPath = lastUserMessage.photoPath;
        }
      }

      final userMessage = Message(
        text: text,
        isUserMessage: true,
        photoPath: effectivePhotoPath,
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

          final modelIdForStorage = (sessionProvider.isDynamicChat)
              ? (sessionProvider.modelId ?? 'dynamic')
              : apiModelIdForSend;

          _conversationProvider.startNewConversationSession(
            newConvId,
            newConvTitle,
            modelIdForStorage,
            userMessage,
          );
        } else {
          _conversationProvider.appendMessageToConversation(userMessage);
        }
        aiMessageIndex = _conversationProvider.messages.length - 1;
      }

      // Clear using the fresh provider
      inputProvider.clearSelectedPhoto();

      // Routing
      if (!isAutoRouter && !Utils.isServerSideModel(
          apiModelIdForSend, langCode: langCode, modelService: _modelService)) {
        final offlineModerator = OfflineModeratorService();
        if (offlineModerator.isPromptAcceptable(textForApi)) {
          unawaited(_sendLocalMessage(
              textForApi, userMessage.photoPath, apiModelIdForSend));
        } else {
          throw ApiException(localizations.errorPromptFlagged);
        }
      } else {
        await _sendServerSideMessage(
          textForApi,
          apiModelIdForSend,
          userMessage.photoPath,
          localizations,
          aiMessageIndex,
          langCode,
        );
        _conversationProvider.finishBotResponse(aiMessageIndex);
      }

      if (!isAutoRouter) {
        try {
          await ChatStorageService.addRecentModel(
            apiModelIdForSend,
            langCode: langCode,
            modelService: _modelService,
          );
        } catch (e) {
          debugPrint("[SendService] Failed to update recent models: $e");
        }
      }
      return true;
    } catch (e) {
      if (e is UserCancelledException) return false;
      _handleSendError(e, isRegenerate, regenerateAiIndex, localizations);
      return false;
    } finally {
      _isSending = false;
    }
  }

  /// Sends a message using a local (on-device) model via the OfflineService.
  Future<void> _sendLocalMessage(String text, String? photoPath,
      String modelId) async {
    try {
      debugPrint(
          "[SendService] Delegating local message to OfflineService for model '$modelId'.");
      await _offlineService.sendMessage(text, photoPath);
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a message using a server-side model via the ApiService.
  Future<void> _sendServerSideMessage(String text,
      String modelIdForRequest,
      String? photoPath,
      AppLocalizations localizations,
      int aiMessageIndex,
      String langCode,) async {
    final bool isAutoRouter = modelIdForRequest == 'cortex/auto';

    // If it's the Auto Router, we don't fetch local entity data because the ID doesn't exist there.
    // We treat it as a generic premium, online model.
    final ModelEntity model = _modelService.getPreciseModelData(
        modelIdForRequest, langCode: langCode);

    // Auto router generally routes to top-tier models (GPT-4, Claude 3.5), so we treat it as Premium
    // to ensure correct credit deduction logic in Cloud Functions.
    final bool isPremium = model.isPremium;

    final bool isCharacterModel =
    isAutoRouter ? false : (model.category == 'roleplay' ||
        model.category == 'self');

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
        final imageBytes = base64Decode(imageUrl
            .split(',')
            .last);
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/${_uuid.v4()}.png';
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);
      } catch (e) {
        debugPrint("[SendService] Error saving received image: $e");
        _conversationProvider.setErrorMessage(
            aiMessageIndex, localizations.errorImageLoad, false);
      }
    }

    if (isCharacterModel) {
      // Use the safe property from the entity.
      final baseModelId = model.baseModelId;
      if (baseModelId == null || baseModelId.isEmpty) {
        throw ApiException(
            "Character '$modelIdForRequest' has no valid base model configured.");
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
  void _handleSendError(Object error,
      bool isRegenerate,
      int? regenerateAiIndex,
      AppLocalizations localizations, {
        String? failedUserText,
        String? failedPhotoPath,
      }) {
    final String errorMessage = error is ApiException
        ? error.message
        : localizations.anErrorOccurred;
    final bool isContentFlagError =
        error is ApiException &&
            error.message == localizations.errorPromptFlagged;

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