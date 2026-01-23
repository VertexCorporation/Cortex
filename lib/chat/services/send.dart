// lib/chat/services/send.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
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
import 'package:cortex/chat/services/voice.dart';
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
  final ConversationProvider _conversationProvider;
  final InputProvider _inputProvider;
  final ApiService _apiService;
  final ContextService _contextService;
  final ScrollService _scrollService;
  final OfflineService _offlineService;
  final Uuid _uuid = const Uuid();
  bool _isSending = false;
  final ModelService _modelService;
  final VoiceService _voiceService;

  SendService({
    required ConversationProvider conversationProvider,
    required ChatSessionProvider sessionProvider,
    required InputProvider inputProvider,
    required ApiService apiService,
    required ContextService contextService,
    required ScrollService scrollService,
    required OfflineService offlineService,
    required ModelService modelService,
    required VoiceService voiceService,
  })  : _conversationProvider = conversationProvider,
        _inputProvider = inputProvider,
        _apiService = apiService,
        _contextService = contextService,
        _scrollService = scrollService,
        _offlineService = offlineService,
        _modelService = modelService,
        _voiceService = voiceService;

  Future<bool> sendMessage({
    required BuildContext context,
    required AppLocalizations localizations,
    required String messageText,
    // REMOVED: File? photo (replaced by provider access)
    bool isRegenerate = false,
    int? regenerateAiIndex,
    // REMOVED: String? regeneratePhotoPath (replaced by message lookup)
    String? overrideModelId,
  }) async {
    if (_isSending) {
      debugPrint("SendService: Already sending. Ignored.");
      return false;
    }

    final inputProvider = context.read<InputProvider>();
    final sessionProvider = context.read<ChatSessionProvider>();

    // -----------------------------------------------------------------------
    // 1. PREPARE CONTENT (TEXT & ATTACHMENTS)
    // -----------------------------------------------------------------------

    final String text = messageText.trim();
    List<String> currentAttachmentPaths = [];

    // Logic: If regenerating, get attachments from the last user message.
    // If new message, get from InputProvider.
    if (isRegenerate) {
      final messages = _conversationProvider.messages;
      final lastUserMessage = messages.reversed.firstWhere(
        (m) => m.isUserMessage,
        orElse: () => Message(text: '', isUserMessage: true),
      );
      currentAttachmentPaths = List.from(lastUserMessage.attachmentPaths);
    } else {
      currentAttachmentPaths =
          inputProvider.attachments.map((a) => a.file.path).toList();
    }

    debugPrint(
        "SendService: Preparing to send. Text: '$text', Attachments: ${currentAttachmentPaths.length}");

    // Validation: Must have either text OR attachments
    if (text.isEmpty && currentAttachmentPaths.isEmpty) {
      debugPrint("SendService: Aborting. No text and no attachments.");
      return false;
    }

    _isSending = true;

    try {
      // -----------------------------------------------------------------------
      // 2. HANDLE FEATURE MODES (Hidden System Prompts)
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
      final langCode = Localizations.localeOf(context).languageCode;
      final hasInternet = await InternetConnection().hasInternetAccess;

      // -----------------------------------------------------------------------
      // 3. DETERMINE INITIAL TARGET ID
      // -----------------------------------------------------------------------

      if (overrideModelId != null && overrideModelId.isNotEmpty) {
        apiModelIdForSend = overrideModelId;
      } else if (sessionProvider.isDynamicChat) {
        apiModelIdForSend = 'cortex/auto';
      } else {
        apiModelIdForSend = sessionProvider.modelId;
      }

      // -----------------------------------------------------------------------
      // 4. SMART MODEL RESOLUTION (Updated for List<File>)
      // -----------------------------------------------------------------------

      if (apiModelIdForSend != null && apiModelIdForSend != 'cortex/auto') {
        final ModelEntity entity = _modelService
            .getPreciseModelData(apiModelIdForSend, langCode: langCode);

        if (entity.variants != null && entity.variants!.isNotEmpty) {
          final List<dynamic> variants = entity.variants!.values.toList();

          // Logic Update: Check if ANY attachment is an image
          final bool hasVisualContent =
              currentAttachmentPaths.any((path) => _isImageFile(path));

          List<dynamic> getPreferredCandidates(List<dynamic> sourceList) {
            final filtered = sourceList.where((v) {
              final String vid = v['id'].toString().toLowerCase();
              final String vTier =
                  v['tier']?.toString().toLowerCase() ?? 'free';
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
              if (hasVisualContent) {
                // Prioritize vision-capable offline models if images exist
                final visionModel = downloadedVariants.firstWhere(
                  (v) => (v['modalities']?['image'] == true),
                  orElse: () => null,
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
            if (hasVisualContent) {
              final visionModel = variants.firstWhere(
                (v) => (v['modalities']?['image'] == true),
                orElse: () => null,
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
      // 5. VALIDATION & PREPARATION
      // -----------------------------------------------------------------------

      final isAutoRouter = apiModelIdForSend == 'cortex/auto';

      if (apiModelIdForSend == null || apiModelIdForSend.isEmpty) {
        _handleSendError(
          ApiException(errorMessage),
          isRegenerate,
          regenerateAiIndex,
          localizations,
          failedUserText: text,
          failedAttachmentPaths: currentAttachmentPaths,
        );
        return false;
      }

      if (!isAutoRouter &&
          Utils.isServerSideModel(apiModelIdForSend,
              langCode: langCode, modelService: _modelService) &&
          !hasInternet) {
        errorMessage = localizations.checkYourInternet;
        _handleSendError(ApiException(errorMessage), isRegenerate,
            regenerateAiIndex, localizations,
            failedUserText: text,
            failedAttachmentPaths: currentAttachmentPaths);
        return false;
      }

      // Construct the User Message object
      final userMessage = Message(
        text: text,
        isUserMessage: true,
        attachmentPaths: currentAttachmentPaths,
        isAttachmentUploading: currentAttachmentPaths.isNotEmpty,
        model: apiModelIdForSend,
      );

      int aiMessageIndex;
      if (isRegenerate && regenerateAiIndex != null) {
        aiMessageIndex = regenerateAiIndex;
      } else {
        if (_conversationProvider.conversationID == null) {
          final newConvId = _uuid.v4();
          final newConvTitle =
              (text.isEmpty && currentAttachmentPaths.isNotEmpty)
                  ? "📁"
                  : (text.length > 32 ? text.substring(0, 32) : text);

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

      // Clear the input attachments from the provider
      inputProvider.clearAttachments();

      // Routing
      if (!isAutoRouter &&
          !Utils.isServerSideModel(apiModelIdForSend,
              langCode: langCode, modelService: _modelService)) {
        // Offline Flow
        final offlineModerator = OfflineModeratorService();
        if (offlineModerator.isPromptAcceptable(textForApi)) {
          unawaited(_sendLocalMessage(
              textForApi, currentAttachmentPaths, apiModelIdForSend));
        } else {
          throw ApiException(localizations.errorPromptFlagged);
        }
      } else {
        // Server Flow
        await _sendServerSideMessage(
          textForApi,
          apiModelIdForSend,
          currentAttachmentPaths,
          localizations,
          aiMessageIndex,
          langCode,
        );
        _conversationProvider.finishBotResponse(aiMessageIndex);

        if (inputProvider.isVoiceModeActive) {
          _voiceService.onAiResponseFinished();
        }
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
  Future<void> _sendLocalMessage(
      String text, List<String> attachmentPaths, String modelId) async {
    try {
      debugPrint(
          "[SendService] Delegating local message to OfflineService for model '$modelId'.");

      // Note: OfflineService needs to be updated to accept List<String>.
      // For now, passing the first path if available to maintain signature if not yet refactored.
      // Ideally: await _offlineService.sendMessage(text, attachmentPaths);
      await _offlineService.sendMessage(
          text, attachmentPaths.isNotEmpty ? attachmentPaths.first : null);
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a message using a server-side model via the ApiService.
  Future<void> _sendServerSideMessage(
    String text,
    String modelIdForRequest,
    List<String> attachmentPaths,
    AppLocalizations localizations,
    int aiMessageIndex,
    String langCode,
  ) async {
    final bool isAutoRouter = modelIdForRequest == 'cortex/auto';
    final ModelEntity model = _modelService
        .getPreciseModelData(modelIdForRequest, langCode: langCode);
    final bool isPremium = model.isPremium;
    final bool isCharacterModel = isAutoRouter
        ? false
        : (model.category == 'roleplay' || model.category == 'self');

    debugPrint(
      "[SendService] Sending server request for model '$modelIdForRequest'. "
      "Is Auto: $isAutoRouter, Is Premium: $isPremium",
    );

    // Build context history
    final memory = await _contextService.buildContextMessages(
      includeLastUser: false,
      targetModelId: modelIdForRequest,
      langCode: langCode,
    );

    // Stream Handlers
    void onTextChunk(String textChunk) {
      if (_conversationProvider.wasResponseStopped) return;
      _conversationProvider.appendToLastBotMessage(textChunk);

      if (_inputProvider.isVoiceModeActive) {
        _voiceService.onAiStreamCallback(textChunk);
      }

      if (_scrollService.isUserAtBottom()) {
        _scrollService.scrollToBottom();
      }
    }

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
        _conversationProvider.setErrorMessage(
            aiMessageIndex, localizations.errorImageLoad, false);
      }
    }

    // Call API
    if (isCharacterModel) {
      var baseModelId = model.baseModelId;

      if (baseModelId == 'dynamic') {
        baseModelId = 'cortex/auto';
      }

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
        attachmentPaths: attachmentPaths,
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
        attachmentPaths: attachmentPaths,
        onTextChunk: onTextChunk,
        onImageReceived: onImageReceived,
        localizations: localizations,
      );
    }
  }

  void _handleSendError(
    Object error,
    bool isRegenerate,
    int? regenerateAiIndex,
    AppLocalizations localizations, {
    String? failedUserText,
    List<String>? failedAttachmentPaths,
  }) {
    final String errorMessage =
        error is ApiException ? error.message : localizations.anErrorOccurred;
    final bool isContentFlagError = error is ApiException &&
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
        attachmentPaths: failedAttachmentPaths ??
            _inputProvider.attachments.map((a) => a.file.path).toList(),
        includeInContext: !isContentFlagError,
      );

      _conversationProvider.showSendError(
        userMessagePlaceholder,
        errorMessage,
        isContentFlagError,
      );
    }
  }

  bool _isImageFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
  }
}
