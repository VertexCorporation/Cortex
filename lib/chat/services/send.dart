// lib/chat/services/send.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:cortex/analytics/service.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/api.dart';
import 'package:cortex/chat/services/background.dart';
import 'package:cortex/chat/services/context.dart';
import 'package:cortex/chat/services/moderator.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/notifications/extrovert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Message;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../library/providers/local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cortex/chat/screen/widgets/bottom/guest.dart';
import '../messages/messages.dart';
import 'package:cortex/chat/providers/memory.dart';
import 'package:cortex/chat/services/memory_store.dart';
import 'tools.dart';

enum _MediaIntent {
  none,
  understand,
  editImage,
  editVideo,
  editAudio,
  generateImage,
  generateVideo,
  generateAudio,
}

/// Service responsible for sending messages. It orchestrates interactions between providers and other services.
class SendService {
  final ConversationProvider _conversationProvider;
  final InputProvider _inputProvider;
  final ApiService _apiService;
  final ContextService _contextService;
  final ScrollService _scrollService;
  final OfflineService _offlineService;
  final Uuid _uuid = const Uuid();
  final ModelService _modelService;
  final VoiceService _voiceService;
  final UserMemoryProvider _userMemoryProvider;
  final BackgroundTaskService _backgroundTaskService;

  /// Track which conversations are currently sending.
  /// Replaces the old single boolean `_isSending`.
  final Set<String> _activeSendConversations = {};

  // PERF: Stateless moderator — create once, reuse on every offline send.
  final OfflineModeratorService _offlineModerator = OfflineModeratorService();

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
    required UserMemoryProvider userMemoryProvider,
    required BackgroundTaskService backgroundTaskService,
  })  : _conversationProvider = conversationProvider,
        _inputProvider = inputProvider,
        _apiService = apiService,
        _contextService = contextService,
        _scrollService = scrollService,
        _offlineService = offlineService,
        _modelService = modelService,
        _voiceService = voiceService,
        _userMemoryProvider = userMemoryProvider,
        _backgroundTaskService = backgroundTaskService;

  /// Returns true if the given conversation is the one currently being viewed.
  bool _isConversationActive(String convId) {
    return _conversationProvider.conversationID == convId;
  }

  bool _isCurrentAiMessageForModel(
    String convId,
    int aiMessageIndex,
    String modelId,
  ) {
    if (!_isConversationActive(convId)) return true;

    final messages = _conversationProvider.messages;
    if (aiMessageIndex < 0 || aiMessageIndex >= messages.length) return false;

    final messageModelId = messages[aiMessageIndex].model;
    return messageModelId == null || messageModelId == modelId;
  }

  void _clearPendingMediaState(String convId, int aiMessageIndex) {
    _backgroundTaskService.setPendingMediaType(
        convId, MediaGenerationType.none);

    if (!_isConversationActive(convId)) return;

    final messages = _conversationProvider.messages;
    if (aiMessageIndex < 0 || aiMessageIndex >= messages.length) return;

    final message = messages[aiMessageIndex];
    if (message.pendingMediaType == MediaGenerationType.none) return;

    _conversationProvider.updateMessageAtIndex(
      aiMessageIndex,
      message.copyWith(pendingMediaType: MediaGenerationType.none),
    );
  }

  bool _isMemoryWorthy(String text) {
    if (text.length < 4 || text.length > 500) return false;
    final lower = text.toLowerCase();
    
    // English indicators
    if (lower.contains("i am") || lower.contains("i'm") || lower.contains("i like") || 
        lower.contains("i love") || lower.contains("i hate") || lower.contains("my name") || 
        lower.contains("my favorite") || lower.contains("call me") || lower.contains("i prefer") ||
        lower.contains("i have") || lower.contains("my ") || lower.contains("about me")) {
      return true;
    }
    
    // Turkish indicators
    if (lower.contains("benim") || lower.contains(" adım") || lower.contains("bana ") || 
        lower.contains("severim") || lower.contains("nefret") || lower.contains("favori") || 
        lower.contains("yaşındayım") || lower.contains("hoşlanırım") || lower.contains("ben ") ||
        lower.contains("yapmayı") || lower.contains("olmayı")) {
      return true;
    }
    
    return false;
  }

  bool _isCharacterModel(ModelEntity model, String modelId) {
    return (model.category == 'roleplay' || model.category == 'self') &&
        modelId != 'cortex/auto';
  }

  bool _isGroqOrDynamicBase(ModelEntity model) {
    final id = model.id.toLowerCase();
    final source = model.source.toLowerCase();
    return id == 'cortex/auto' ||
        id == 'dynamic' ||
        source == 'groq' ||
        source == 'manual';
  }

  bool _isUsableCharacterBase(ModelEntity model) {
    final category = model.category.toLowerCase();
    return model.isServerSide &&
        model.source.toLowerCase() == 'openrouter' &&
        category != 'roleplay' &&
        category != 'self' &&
        category != 'image' &&
        category != 'video' &&
        category != 'audio' &&
        model.outputs['text'] == true;
  }

  ModelEntity? _findOpenRouterCharacterBase(String langCode) {
    final allModels = _modelService.getCachedModelsSync();

    for (final model in allModels) {
      if (model.variants?.isNotEmpty ?? false) {
        for (final entry in model.variants!.entries) {
          final variantData = entry.value;
          if (variantData is! Map<String, dynamic>) continue;

          final variantId = variantData['id']?.toString() ?? entry.key;
          if (variantId.toLowerCase().contains('guard')) continue;

          final tier = variantData['tier']?.toString().toLowerCase() ?? 'free';
          if (tier == 'premium' || tier == 'plus' || tier == 'pro') continue;

          final source = variantData['source']?.toString().toLowerCase() ??
              model.source.toLowerCase();
          if (source != 'openrouter') continue;

          final outputs = Map<String, dynamic>.from(
              variantData['outputs'] as Map? ?? model.outputs);
          if (outputs['text'] != true) continue;

          final precise =
              _modelService.getPreciseModelData(variantId, langCode: langCode);
          if (_isUsableCharacterBase(precise)) return precise;
        }
        continue;
      }

      if (_isUsableCharacterBase(model) &&
          !model.id.toLowerCase().contains('guard')) {
        final tier = model.tier.toLowerCase();
        if (tier == 'premium' || tier == 'plus' || tier == 'pro') continue;
        return model;
      }
    }

    for (final model in allModels) {
      if (_isUsableCharacterBase(model)) return model;
    }

    return null;
  }

  ModelEntity _resolveCharacterBaseModel({
    required ModelEntity characterModel,
    required String langCode,
  }) {
    var baseModelId = characterModel.baseModelId;
    if (baseModelId == null ||
        baseModelId.isEmpty ||
        baseModelId == 'dynamic') {
      baseModelId = 'cortex/auto';
    }

    final baseModel =
        _modelService.getPreciseModelData(baseModelId, langCode: langCode);

    if (!_isGroqOrDynamicBase(baseModel)) {
      return baseModel;
    }

    final openRouterBase = _findOpenRouterCharacterBase(langCode);
    if (openRouterBase != null) {
      debugPrint(
          "[SendService] Character base '${baseModel.id}' uses ${baseModel.source}. Routing character request through OpenRouter model '${openRouterBase.id}'.");
      return openRouterBase;
    }

    return baseModel.copyWith(source: 'openrouter');
  }

  /// Main entry point to send a message.
  Future<bool> sendMessage({
    required BuildContext context,
    required AppLocalizations localizations,
    required String messageText,
    bool isRegenerate = false,
    int? regenerateAiIndex,
    String? overrideModelId,
    bool isHidden = false,
    String? voiceSystemPrompt,
  }) async {
    final sessionProvider = context.read<ChatSessionProvider>();

    // -----------------------------------------------------------------------
    // 1. PREPARE CONTENT
    // -----------------------------------------------------------------------

    final String text = messageText.trim();
    List<String> currentAttachmentPaths = [];

    if (isRegenerate) {
      final messages = _conversationProvider.messages;
      final lastUserMessage = messages.reversed.firstWhere(
        (m) => m.isUserMessage,
        orElse: () => Message(text: '', isUserMessage: true),
      );
      currentAttachmentPaths = List.from(lastUserMessage.attachmentPaths);
    } else {
      // Use the class member _inputProvider or the local one.
      // Since we injected it, _inputProvider is safe.
      currentAttachmentPaths =
          _inputProvider.attachments.map((a) => a.file.path).toList();
    }

    if (text.isEmpty && currentAttachmentPaths.isEmpty) {
      return false;
    }

    // _isSending guard replaced by per-conversation tracking below.

    // Declare target state outside try so catch/finally can clean up the
    // exact conversation that launched this request.
    String? targetConvId;
    int? targetAiMessageIndex;
    String? targetModelIdForSend;
    bool targetIsServerSide = false;

    try {
      // -----------------------------------------------------------------------
      // 2. FEATURE MODES (Study, Quiz, etc.)
      // -----------------------------------------------------------------------
      final activeMode = _inputProvider.featureMode;
      final bool enableThinkingMode =
          activeMode == ChatInputMode.featureReasoning;
      String textForApi = text;

      // Apply voice system prompt to API text only (not shown to user)
      if (voiceSystemPrompt != null && voiceSystemPrompt.isNotEmpty) {
        textForApi = "$voiceSystemPrompt\n\n$textForApi";
      }

      if (activeMode == ChatInputMode.study) {
        textForApi = "${localizations.featureStudyMessage}\n\n$text";
      } else if (activeMode == ChatInputMode.quiz) {
        textForApi = "${localizations.featureQuizMessage}\n\n$text";
      }

      // -----------------------------------------------------------------------
      // 3. MODEL RESOLUTION
      // -----------------------------------------------------------------------
      String? apiModelIdForSend;
      String errorMessage = localizations.errorNoModelsAvailable;

      final localState = context.read<ModelLocalStateProvider>();
      final langCode = Localizations.localeOf(context).languageCode;
      final hasInternet = await InternetConnection().hasInternetAccess;

      final originalUiModelId = overrideModelId ??
          (sessionProvider.isDynamicChat ? 'cortex/auto' : sessionProvider.modelId) ??
          'cortex/auto';

      if (overrideModelId != null && overrideModelId.isNotEmpty) {
        apiModelIdForSend = overrideModelId;
      } else if (sessionProvider.isDynamicChat) {
        apiModelIdForSend = 'cortex/auto';
      } else {
        apiModelIdForSend = sessionProvider.modelId;
      }

      final intentResolvedModelId = _resolveAttachmentIntentModelId(
        currentModelId: apiModelIdForSend ?? 'cortex/auto',
        text: text,
        attachments: currentAttachmentPaths,
        langCode: langCode,
        isUserSubscribed: sessionProvider.isUserSubscribed,
      );
      if (intentResolvedModelId != null) {
        apiModelIdForSend = intentResolvedModelId;
      }

      // Smart Selection Logic
      if (apiModelIdForSend != null && apiModelIdForSend != 'cortex/auto') {
        final ModelEntity entity = _modelService
            .getPreciseModelData(apiModelIdForSend, langCode: langCode);

        if (entity.variants != null && entity.variants!.isNotEmpty) {
          final List<dynamic> variants = entity.variants!.values.toList();
          final bool hasVisualContent =
              currentAttachmentPaths.any((path) => _isImageFile(path));

          List<dynamic> getPreferredCandidates(List<dynamic> sourceList) {
            final filtered = sourceList.where((v) {
              final String vid = v['id'].toString().toLowerCase();
              final String vTier =
                  v['tier']?.toString().toLowerCase() ?? 'free';
              return !vid.contains('guard') && vTier != 'premium';
            }).toList();
            return filtered.isNotEmpty ? filtered : sourceList;
          }

          final bool mustRunOffline = (entity.type == 'offline') ||
              (!hasInternet && !entity.isServerSide);

          if (mustRunOffline) {
            final downloadedVariants = variants
                .where((v) => localState.downloadCompleted[v['id']] == true)
                .toList();

            if (downloadedVariants.isEmpty) {
              errorMessage = localizations.errorNoModelsAvailable;
              apiModelIdForSend = null;
            } else {
              if (hasVisualContent) {
                final visionModel = downloadedVariants.firstWhere(
                  (v) => (v['modalities']?['image'] == true),
                  orElse: () => null,
                );
                apiModelIdForSend = visionModel != null
                    ? visionModel['id']
                    : getPreferredCandidates(downloadedVariants).first['id'];
              } else {
                apiModelIdForSend =
                    getPreferredCandidates(downloadedVariants).first['id'];
              }
            }
          } else {
            // Online Variants
            if (hasVisualContent) {
              final visionModel = variants.firstWhere(
                (v) => (v['modalities']?['image'] == true),
                orElse: () => null,
              );
              apiModelIdForSend = visionModel != null
                  ? visionModel['id']
                  : getPreferredCandidates(variants).first['id'];
            } else {
              apiModelIdForSend = getPreferredCandidates(variants).first['id'];
            }
          }
        }
      }

      // =======================================================================
      // INTERCEPT MEDIA EDITING BOTS WITH MISSING MEDIA
      // =======================================================================
      if (apiModelIdForSend != null && apiModelIdForSend != 'cortex/auto') {
        final ModelEntity entity = _modelService
            .getPreciseModelData(apiModelIdForSend, langCode: langCode);
        final String cat = entity.category;

        final bool demandsImage =
            cat == 'image' && entity.modalities['image'] == true;
        final bool demandsVideo =
            cat == 'video' && entity.modalities['video'] == true;
        final bool demandsAudio =
            cat == 'audio' && entity.modalities['audio'] == true;

        if ((demandsImage || demandsVideo || demandsAudio) &&
            currentAttachmentPaths.isEmpty) {
          String mType = demandsImage
              ? localizations.mediaTypeImage
              : (demandsVideo
                  ? localizations.mediaTypeVideo
                  : localizations.mediaTypeAudio);

          voiceSystemPrompt = localizations.systemPromptMissingMedia(
              mType, entity.displayTitle);

          // Route the prompt gracefully back to a text LLM so it can answer properly
          apiModelIdForSend = "cortex/auto";
        }
      }

      if (apiModelIdForSend == null) {
        throw ApiException(errorMessage);
      }
      
      if (apiModelIdForSend == 'dynamic') {
        apiModelIdForSend = 'cortex/auto';
      }
      
      targetModelIdForSend = apiModelIdForSend;

      final isAutoRouter = apiModelIdForSend == 'cortex/auto';
      final isServerSide = isAutoRouter ||
          Utils.isServerSideModel(apiModelIdForSend,
              langCode: langCode, modelService: _modelService);
      targetIsServerSide = isServerSide;

      final selectedModelForSnapshot = _modelService
          .getPreciseModelData(originalUiModelId, langCode: langCode);
      final modelTitleForStorage = selectedModelForSnapshot.displayTitle;
      final modelImagePathForStorage =
          _modelService.getModelImagePath(selectedModelForSnapshot);

      if (isServerSide && !hasInternet) {
        throw ApiException(localizations.checkYourInternet);
      }

      // Optimistic UI Message
      final userMessage = Message(
        text: text,
        isUserMessage: true,
        attachmentPaths: currentAttachmentPaths,
        isAttachmentUploading: currentAttachmentPaths.isNotEmpty,
        model: originalUiModelId,
        isVisible: !isHidden,
      );

      // Determine conversation ID for this send operation.
      // This is critical for background task tracking.
      targetConvId = _conversationProvider.conversationID;

      int aiMessageIndex;
      if (isRegenerate && regenerateAiIndex != null) {
        aiMessageIndex = regenerateAiIndex;
      } else {
        if (targetConvId == null) {
          final newConvId = _uuid.v4();
          targetConvId = newConvId;
          final defaultTitle =
              (text.isEmpty && currentAttachmentPaths.isNotEmpty)
                  ? "📁"
                  : (text.length > 32 ? text.substring(0, 32) : text);

          final modelForStorage = originalUiModelId;

          if (isHidden) {
            _conversationProvider.startEphemeralSession(
                newConvId, modelForStorage, userMessage,
                title: isHidden ? localizations.flowMode : null);
          } else {
            _conversationProvider.startNewConversationSession(
              newConvId,
              defaultTitle,
              modelForStorage,
              userMessage,
              modelTitleForStorage: modelTitleForStorage,
              modelImagePathForStorage: modelImagePathForStorage,
            );

            // 🚀 ASYNC AI CHAT TITLE GENERATION
            if (isServerSide && text.isNotEmpty) {
              debugPrint("🚀 Triggering TitleGen for new chat...");
              _apiService
                  .generateChatTitle(text, localizations.chatTitlePrompt,
                      localizations.chatTitleCriticalInstruction)
                  .then((aiTitle) async {
                if (aiTitle != null && aiTitle.trim().isNotEmpty) {
                  final rawTitle =
                      aiTitle.length > 40 ? aiTitle.substring(0, 40) : aiTitle;

                  // Title Case: capitalize the first letter of every word
                  final cleanTitle = rawTitle
                      .split(' ')
                      .map((word) => word.isEmpty
                          ? word
                          : '${word[0].toUpperCase()}${word.substring(1)}')
                      .join(' ');

                  // Update current UI if we are still on this chat
                  // Only replace the temporary first-message title. If the
                  // user manually renamed the chat while TitleGen was running,
                  // the WHERE guard below prevents the generated title from
                  // silently overwriting their choice.
                  final didRename = await ChatStorageService.renameConversation(
                    newConvId,
                    cleanTitle,
                    source: 'titlegen',
                    expectedCurrentTitle: defaultTitle,
                  );

                  if (!didRename) {
                    debugPrint(
                        "[TitleGen] Skipped applying generated title for $newConvId because the title changed before completion.");
                    return;
                  }

                  if (_conversationProvider.conversationID == newConvId) {
                    _conversationProvider.updateConversationTitle(cleanTitle);
                  }
                }
              }).catchError((e) {
                debugPrint("TitleGen error: $e");
              });
            }
          }
        } else {
          _conversationProvider.appendMessageToConversation(userMessage);
        }
        aiMessageIndex = _conversationProvider.messages.length - 1;
      }
      targetAiMessageIndex = aiMessageIndex;

      // Guard: prevent duplicate sends for the same conversation.
      if (targetConvId != null &&
          _activeSendConversations.contains(targetConvId)) {
        debugPrint("SendService: Already sending for $targetConvId. Ignored.");
        return false;
      }
      if (targetConvId != null) _activeSendConversations.add(targetConvId);
      if (targetConvId != null && isServerSide) {
        _backgroundTaskService.markActive(targetConvId);
      }

      _inputProvider.clearAttachments();

      // 🚀 ASYNC AI MEMORY EXTRACTION
      if (isServerSide && text.isNotEmpty && !isHidden && _isMemoryWorthy(text)) {
        debugPrint("🚀 Triggering Memory Extraction...");
        _apiService.extractUserMemory(text, langCode).then((facts) async {
          if (facts != null && facts.isNotEmpty) {
            bool memoryAdded = false;
            for (final fact in facts) {
              if (!_userMemoryProvider.memoryList.contains(fact)) {
                await _userMemoryProvider.addMemory(fact);
                memoryAdded = true;
              }
            }
            if (memoryAdded && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    langCode == 'tr' ? "Hafıza güncellendi" : "Memory updated",
                    style: TextStyle(
                      color: Color(0xFF131314).withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: Color(0xFFF1F3F4),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        }).catchError((e) {
          debugPrint("MemoryExtraction error: $e");
        });
      }

      // -----------------------------------------------------------------------
      // 5. EXECUTION ROUTING
      // -----------------------------------------------------------------------

      if (!isServerSide) {
        // Offline Flow
        if (_offlineModerator.isPromptAcceptable(textForApi)) {
          await _offlineService.sendMessage(
              textForApi, currentAttachmentPaths.firstOrNull);
        } else {
          throw ApiException(localizations.errorPromptFlagged);
        }
      } else {
        // Server Flow (with Tool Loop & featureReasoning)
        final String convId = targetConvId!;
        int attempt = 0;
        bool success = false;
        String? dynamicFallbackNotice;
        bool hasTriedDynamicServerFallback =
            apiModelIdForSend == 'cortex/auto' ||
                apiModelIdForSend == 'dynamic';
        final triedMediaFallbackIds = <String>{apiModelIdForSend};

        Future<void> switchToDynamicFallback({
          String? notice,
          Object? reason,
        }) async {
          debugPrint(
              "SendService: Server fallback triggered. Model '${apiModelIdForSend ?? 'unknown'}' failed${reason == null ? '' : ' ($reason)'}. Retrying with dynamic chat...");

          dynamicFallbackNotice = notice;
          apiModelIdForSend = 'cortex/auto';
          targetModelIdForSend = apiModelIdForSend;
          attempt = 0;
          hasTriedDynamicServerFallback = true;

          _backgroundTaskService.resetBuffer(convId);
          _clearPendingMediaState(convId, aiMessageIndex);

          if (_isConversationActive(convId)) {
            _conversationProvider.fadeOutMessage(aiMessageIndex);
            await Future.delayed(const Duration(milliseconds: 300));
            _conversationProvider.prepareForRegeneration(
                aiMessageIndex, 'cortex/auto');
          }
          await Future.delayed(const Duration(milliseconds: 100));
        }

        while (attempt < 3 && !success) {
          attempt++;
          try {
            final requestText = dynamicFallbackNotice == null
                ? textForApi
                : "$dynamicFallbackNotice\n\n$textForApi";
            await _sendServerSideMessageWithLoop(
              initialText: requestText,
              modelId: apiModelIdForSend!,
              attachments: currentAttachmentPaths,
              localizations: localizations,
              aiMessageIndex: aiMessageIndex,
              langCode: langCode,
              enableThinkingMode: enableThinkingMode,
              targetConvId: convId,
            );
            success = true;
          } catch (e) {
            if (e is ApiException && e.code == 'EMPTY_RESPONSE') {
              if (attempt >= 3) {
                if (!hasTriedDynamicServerFallback &&
                    _shouldFallbackServerErrorToDynamic(e, apiModelIdForSend)) {
                  await switchToDynamicFallback(reason: e);
                  continue;
                }
                rethrow;
              }
              debugPrint(
                  "SendService: Empty response detected, retrying attempt $attempt...");
              // Reset every live copy before retrying. The background buffer is
              // the source of truth even while the chat is foregrounded.
              _backgroundTaskService.resetBuffer(convId);
              if (_isConversationActive(convId)) {
                final currentMsg =
                    _conversationProvider.messages[aiMessageIndex];
                _conversationProvider.updateMessageAtIndex(
                    aiMessageIndex, currentMsg.copyWith(text: ""));
              }
              await Future.delayed(const Duration(milliseconds: 500));
            } else if (e is ApiException && (e.code ?? '').startsWith('FAL_')) {
              final failedModelId = apiModelIdForSend ?? 'cortex/auto';
              final failedModel = _modelService.getPreciseModelData(
                failedModelId,
                langCode: langCode,
              );
              final hasImageAttachment =
                  currentAttachmentPaths.any(_isImageFile);
              final canRetryImageToImage = hasImageAttachment &&
                  _isFalMediaModel(failedModel, 'image') &&
                  failedModel.modalities['image'] != true;
              final imageToImageFallback = canRetryImageToImage
                  ? _findFalMediaModel(
                      langCode: langCode,
                      isUserSubscribed: sessionProvider.isUserSubscribed,
                      outputType: 'image',
                      requiredInputType: 'image',
                      excludeIds: triedMediaFallbackIds,
                    )
                  : null;

              if (imageToImageFallback != null) {
                debugPrint(
                    "SendService: FAL text-to-image failed (${e.code}). Retrying with image-to-image model '${imageToImageFallback.id}'.");

                apiModelIdForSend = imageToImageFallback.id;
                targetModelIdForSend = apiModelIdForSend;
                triedMediaFallbackIds.add(imageToImageFallback.id);
                attempt = 0;
                dynamicFallbackNotice = null;

                _backgroundTaskService.resetBuffer(convId);
                _clearPendingMediaState(convId, aiMessageIndex);

                if (_isConversationActive(convId)) {
                  _conversationProvider.fadeOutMessage(aiMessageIndex);
                  await Future.delayed(const Duration(milliseconds: 300));
                  _conversationProvider.prepareForRegeneration(
                      aiMessageIndex, imageToImageFallback.id);
                }
                await Future.delayed(const Duration(milliseconds: 100));
                continue;
              }

              if (hasTriedDynamicServerFallback &&
                  (apiModelIdForSend == 'cortex/auto' ||
                      apiModelIdForSend == 'dynamic')) {
                rethrow;
              }

              debugPrint(
                  "SendService: FAL error detected (${e.code}). Falling back to dynamic chat with localized notice...");

              await switchToDynamicFallback(
                notice: _localizedFalFallbackMessage(e, localizations),
                reason: e,
              );
              continue;
            } else if (!hasTriedDynamicServerFallback &&
                _shouldFallbackServerErrorToDynamic(e, apiModelIdForSend)) {
              await switchToDynamicFallback(reason: e);
              continue;
            } else {
              rethrow;
            }
          }
        }

        // Only update UI provider if user is still on this conversation.
        if (_isConversationActive(convId)) {
          _syncActiveMessageFromBackgroundBuffer(
              convId, aiMessageIndex, apiModelIdForSend!);
          _conversationProvider.finishBotResponse(aiMessageIndex);
        } else {
          // Background: persist the final message to DB.
          await _persistBackgroundCompletion(
              convId, aiMessageIndex, apiModelIdForSend!);
          if (_isConversationActive(convId)) {
            _syncActiveMessageFromBackgroundBuffer(
                convId, aiMessageIndex, apiModelIdForSend!);
            _conversationProvider.finishBotResponse(aiMessageIndex);
          }
        }

        // -------------------------------------------------------------------
        // IMAGE TAG INTERCEPT: If the model responded with only "<image>"
        // (or variants like "<image>prompt</image>"), it means the text model
        // tried to delegate to image generation but can't do it itself.
        // We intercept this, hide the tag, and re-route to an actual
        // image-generating model.
        // -------------------------------------------------------------------
        if (_isConversationActive(convId)) {
          final messages = _conversationProvider.messages;
          if (aiMessageIndex >= 0 && aiMessageIndex < messages.length) {
            final botText = messages[aiMessageIndex].text.trim();
            // Match patterns: <image>, <image>some prompt</image>, <image />
            final imageTagRegex = RegExp(
              r'^\s*<image\s*/?\s*>.*$|^\s*<image>(.*?)</image>\s*$',
              caseSensitive: false,
              dotAll: true,
            );
            if (imageTagRegex.hasMatch(botText)) {
              debugPrint(
                  "[SendService] <image> tag intercepted. Re-routing to image model...");

              // Extract prompt from tag if present, otherwise use original user text
              final tagMatch = RegExp(r'<image>(.*?)</image>',
                      caseSensitive: false, dotAll: true)
                  .firstMatch(botText);
              final imagePrompt =
                  (tagMatch != null && tagMatch.group(1)!.trim().isNotEmpty)
                      ? tagMatch.group(1)!.trim()
                      : text; // fall back to original user prompt

              // Clear the bot's <image> tag text
              _conversationProvider.updateMessageAtIndex(
                aiMessageIndex,
                messages[aiMessageIndex].copyWith(text: ""),
              );

              // Find the first available image generation model (non-premium first)
              final allModels = _modelService.getCachedModelsSync();
              final imageModels = allModels
                  .where((m) =>
                      m.category == 'image' &&
                      m.outputs['image'] == true &&
                      m.type == 'online')
                  .toList();

              if (imageModels.isNotEmpty) {
                // Prefer free models, then premium
                final freeImageModels =
                    imageModels.where((m) => !m.isPremium).toList();
                final chosenModel = freeImageModels.isNotEmpty
                    ? freeImageModels.first
                    : imageModels.first;

                debugPrint(
                    "[SendService] Re-routing to image model: ${chosenModel.id}");

                if (!context.mounted) return false;

                // Re-send using the image model (recursive call with override)
                await sendMessage(
                  messageText: imagePrompt,
                  context: context,
                  localizations: localizations,
                  overrideModelId: chosenModel.id,
                  isRegenerate: false,
                );
                return true; // Exit early — the re-routed call handles everything
              } else {
                debugPrint(
                    "[SendService] No image generation models available. Showing fallback text.");
                _conversationProvider.updateMessageAtIndex(
                  aiMessageIndex,
                  messages[aiMessageIndex]
                      .copyWith(text: localizations.errorNoModelsAvailable),
                );
              }
            }
          }
        }

        if (_inputProvider.isVoiceModeActive && _isConversationActive(convId)) {
          _voiceService.onAiResponseFinished();
        }
      }

      // -----------------------------------------------------------------------
      // 6. ANALYTICS & HISTORY
      // -----------------------------------------------------------------------
      if (!isAutoRouter) {
        ChatStorageService.addRecentModel(apiModelIdForSend!,
                langCode: langCode, modelService: _modelService)
            .ignore();
      }

      AnalyticsService().logMessageSent(
        modelType: !isServerSide ? 'offline' : 'online',
        hasAttachments: currentAttachmentPaths.isNotEmpty,
      );

      if (!isRegenerate && !isHidden && context.mounted) {
        try {
          context
              .read<ExtrovertNotificationService>()
              .recordSentMessageAndMaybeRequestPermission()
              .ignore();
        } catch (e) {
          debugPrint(
              '[SendService] Notification permission prompt scheduling skipped: $e');
        }
      }

      // Mark background task complete and send notification if needed.
      if (targetConvId != null &&
          targetIsServerSide &&
          (!_isConversationActive(targetConvId) || _isAppInBackground()) &&
          _backgroundTaskService.isActive(targetConvId)) {
        final chatTitle = await _getChatTitleForNotification(targetConvId);
        _backgroundTaskService.markComplete(targetConvId);
        _sendBackgroundCompletionNotification(
            targetConvId, chatTitle, localizations);
      }

      return true;
    } catch (e) {
      if (e is UserCancelledException) return false;

      // CRITICAL: Only show error in UI if the user is still on this chat.
      // Otherwise the error message would corrupt a completely different chat!
      if (targetConvId == null || _isConversationActive(targetConvId)) {
        _handleSendError(e, isRegenerate, regenerateAiIndex, localizations);
      } else {
        if (targetAiMessageIndex != null) {
          await _persistBackgroundError(
            targetConvId,
            targetAiMessageIndex,
            targetModelIdForSend,
            e,
            localizations,
          );
        }
        debugPrint(
            '[SendService] Background error for $targetConvId (suppressed): $e');
      }
      return false;
    } finally {
      if (targetConvId != null) {
        _activeSendConversations.remove(targetConvId);
        _backgroundTaskService.markComplete(targetConvId);
      }
    }
  }

  /// Manages the full conversation loop:
  /// 1. Sends Request
  /// 2. Streams Text/featureReasoning
  /// 3. Captures Tool Calls
  /// 4. Executes Tools
  /// 5. Loops back to step 1 if tools were used.
  Future<void> _sendServerSideMessageWithLoop({
    required String initialText,
    required String modelId,
    required List<String> attachments,
    required AppLocalizations localizations,
    required int aiMessageIndex,
    required String langCode,
    required bool enableThinkingMode,
    required String targetConvId,
  }) async {
    final ModelEntity modelData =
        _modelService.getPreciseModelData(modelId, langCode: langCode);
    final bool isPremium = modelData.isPremium;

    final bool isCharacterModel = _isCharacterModel(modelData, modelId);

    // Use the enableThinkingMode passed from sendMessage (captured before clearAllInput)
    final bool enablefeatureReasoning = enableThinkingMode;

    // 1. Build Base Context (History)
    List<Map<String, dynamic>> contextMessages =
        await _contextService.buildContextMessages(
      includeLastUser: false,
      targetModelId: modelId,
      langCode: langCode,
      enableThinkingMode: enablefeatureReasoning,
      localizations: localizations,
      isCharacterModel: isCharacterModel,
      customInstruction: _userMemoryProvider.customInstruction,
      userMemory: _userMemoryProvider.memory,
    );

    // 2. Add Current User Message to Context (Manual Construction)
    // We do this manually because attachments need to be processed into base64 blocks
    final List<Map<String, dynamic>> userContent = [];
    if (initialText.isNotEmpty) {
      userContent.add({"type": "text", "text": initialText});
    }
    for (var path in attachments) {
      final block = await Utils.processAttachment(path);
      if (block != null) userContent.add(block);
    }

    // Extract documents for tool processing (PDF, XLSX, etc.)
    final documents = Utils.extractDocuments(userContent);
    if (documents.isNotEmpty) {
      ToolRegistry.setDocumentsContext(documents);
    }

    // Clean content blocks before sending to API (remove internal _document fields)
    final cleanedUserContent = Utils.cleanContentBlocks(userContent);

    if (cleanedUserContent.isNotEmpty) {
      contextMessages.add({"role": "user", "content": cleanedUserContent});
    }

    // Loop Variables
    bool shouldContinue = true;
    int loopCount = 0;
    const int maxLoops = 5; // Safety break

    // State for managing featureReasoning block - OUTSIDE loop to persist across iterations
    // enablefeatureReasoning is already defined above when building context
    bool isfeatureReasoningBlockActive = false;
    bool hasEverHadfeatureReasoning =
        false; // Track if we've seen any featureReasoning

    void setWebSearchActive(bool active) {
      _backgroundTaskService.setWebSearchActive(targetConvId, active);
      if (!_isConversationActive(targetConvId)) return;

      final messages = _conversationProvider.messages;
      if (aiMessageIndex < 0 || aiMessageIndex >= messages.length) return;

      final message = messages[aiMessageIndex];
      if (message.isWebSearchActive == active) return;

      _conversationProvider.updateMessageAtIndex(
        aiMessageIndex,
        message.copyWith(isWebSearchActive: active),
      );
    }

    void appendStreamChunk(
      String chunk, {
      bool sendToVoice = false,
      bool scrollIfNeeded = false,
      bool flushImmediately = false,
    }) {
      if (chunk.isEmpty) return;
      if (sendToVoice) {
        setWebSearchActive(false);
      }

      // Keep the background buffer as the complete source of truth even while
      // this conversation is foregrounded. If the user leaves at any point,
      // final persistence still has the whole response, not only later chunks.
      _backgroundTaskService.appendChunk(targetConvId, chunk);

      if (_isConversationActive(targetConvId)) {
        _conversationProvider.appendToLastBotMessage(chunk);
        if (flushImmediately) {
          _conversationProvider.flushStreamUpdates();
        }
        if (sendToVoice && _inputProvider.isVoiceModeActive) {
          _voiceService.onAiStreamCallback(chunk);
        }
        if (scrollIfNeeded && _scrollService.isUserAtBottom()) {
          _scrollService.scrollToBottom(
              duration: const Duration(milliseconds: 50));
        }
      }
    }

    // --- THE LOOP ---
    while (shouldContinue && loopCount < maxLoops) {
      shouldContinue = false; // Stop unless tools are called
      loopCount++;

      List<dynamic> turnToolCalls = [];

      // Handler Functions (defined here to capture scope)

      void onfeatureReasoning(String featureReasoningText) {
        if (_conversationProvider.wasResponseStopped &&
            _isConversationActive(targetConvId)) {
          return;
        }

        // If this is the START of a featureReasoning block, open the tag
        if (!isfeatureReasoningBlockActive) {
          // If we had featureReasoning before and closed it, we're continuing - add separator
          if (hasEverHadfeatureReasoning) {
            appendStreamChunk("\n\n");
          }
          appendStreamChunk("<think>");
          isfeatureReasoningBlockActive = true;
          hasEverHadfeatureReasoning = true;
        }

        // Ensure we don't double-append headers or newlines. Just the raw text.
        appendStreamChunk(featureReasoningText);
      }

      void onTextChunk(String text) {
        if (_conversationProvider.wasResponseStopped &&
            _isConversationActive(targetConvId)) {
          return;
        }
        if (text.isEmpty) return; // Ignore empty keep-alive chunks

        // If we were reasoning and now switched to actual content, close the tag.
        if (isfeatureReasoningBlockActive) {
          appendStreamChunk("</think>");
          isfeatureReasoningBlockActive = false;
        }

        _clearPendingMediaState(targetConvId, aiMessageIndex);

        appendStreamChunk(
          text,
          sendToVoice: true,
          scrollIfNeeded: true,
        );
      }

      Future<void> onImageReceived(String url) async {
        // Block media in voice/flow mode — can't speak images
        if (_inputProvider.isVoiceModeActive || _voiceService.isFlowActive) {
          debugPrint('[SendService] Image blocked: voice/flow mode active.');
          return;
        }
        if (_conversationProvider.wasResponseStopped &&
            _isConversationActive(targetConvId)) {
          return;
        }
        if (!_isCurrentAiMessageForModel(
            targetConvId, aiMessageIndex, modelId)) {
          return;
        }
        try {
          final finalPath = await _persistGeneratedMedia(
            url: url,
            dataPrefix: 'data:image',
            allowedExtensions: const [
              'png',
              'jpg',
              'jpeg',
              'webp',
              'gif',
              'bmp',
              'heic'
            ],
            fallbackExtension: 'png',
          );
          await _attachGeneratedMediaToAiMessage(
            aiMessageIndex: aiMessageIndex,
            mediaPath: finalPath,
            targetConvId: targetConvId,
          );
        } catch (e) {
          debugPrint("Image parse/save error: $e");
        }
      }

      Future<void> onAudioReceived(String url) async {
        // Block media in voice/flow mode
        if (_inputProvider.isVoiceModeActive || _voiceService.isFlowActive) {
          debugPrint('[SendService] Audio blocked: voice/flow mode active.');
          return;
        }
        if (_conversationProvider.wasResponseStopped &&
            _isConversationActive(targetConvId)) {
          return;
        }
        if (!_isCurrentAiMessageForModel(
            targetConvId, aiMessageIndex, modelId)) {
          return;
        }
        try {
          final finalPath = await _persistGeneratedMedia(
            url: url,
            dataPrefix: 'data:audio',
            allowedExtensions: const [
              'mp3',
              'wav',
              'm4a',
              'aac',
              'ogg',
              'flac'
            ],
            fallbackExtension: 'mp3',
          );
          await _attachGeneratedMediaToAiMessage(
            aiMessageIndex: aiMessageIndex,
            mediaPath: finalPath,
            targetConvId: targetConvId,
          );
        } catch (e) {
          debugPrint("Audio parse/save error: $e");
        }
      }

      Future<void> onVideoReceived(String url) async {
        // Block media in voice/flow mode — can't speak video
        if (_inputProvider.isVoiceModeActive || _voiceService.isFlowActive) {
          debugPrint('[SendService] Video blocked: voice/flow mode active.');
          return;
        }
        if (_conversationProvider.wasResponseStopped &&
            _isConversationActive(targetConvId)) {
          return;
        }
        if (!_isCurrentAiMessageForModel(
            targetConvId, aiMessageIndex, modelId)) {
          return;
        }
        try {
          final finalPath = await _persistGeneratedMedia(
            url: url,
            dataPrefix: 'data:video',
            allowedExtensions: const ['mp4', 'webm', 'mov', 'mkv', 'm4v'],
            fallbackExtension: 'mp4',
          );
          await _attachGeneratedMediaToAiMessage(
            aiMessageIndex: aiMessageIndex,
            mediaPath: finalPath,
            targetConvId: targetConvId,
          );
        } catch (e) {
          debugPrint("Video parse/save error: $e");
        }
      }

      // Handler for media generation started signal (shimmer state)
      void onMediaGenerating(String type) {
        // Block media generation indicator in voice/flow mode
        if (_inputProvider.isVoiceModeActive || _voiceService.isFlowActive) {
          return;
        }
        if (_conversationProvider.wasResponseStopped &&
            _isConversationActive(targetConvId)) {
          return;
        }
        final mediaType = switch (type) {
          'audio' => MediaGenerationType.audio,
          'image' => MediaGenerationType.image,
          'video' => MediaGenerationType.video,
          _ => MediaGenerationType.none,
        };
        if (mediaType == MediaGenerationType.none) return;
        if (!_isCurrentAiMessageForModel(
            targetConvId, aiMessageIndex, modelId)) {
          return;
        }

        // Track this in the background state regardless of the current screen,
        // so re-entering the chat can restore the shimmer immediately.
        _backgroundTaskService.setPendingMediaType(targetConvId, mediaType);

        if (_isConversationActive(targetConvId)) {
          final messages = _conversationProvider.messages;
          if (aiMessageIndex >= 0 && aiMessageIndex < messages.length) {
            final msg = messages[aiMessageIndex];
            _conversationProvider.updateMessageAtIndex(
              aiMessageIndex,
              msg.copyWith(pendingMediaType: mediaType),
            );
            if (_scrollService.isUserAtBottom()) {
              _scrollService.scrollToBottom(
                  duration: const Duration(milliseconds: 100));
            }
          }
        }
      }

      // MOCK TEST FOR AUDIO AND IMAGE (REMOVE BEFORE PRODUCTION)
      if (initialText.toLowerCase().trim() == "test image") {
        onMediaGenerating('image');
        await Future.delayed(const Duration(seconds: 2));
        await onImageReceived(
            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png");
        _conversationProvider.finishBotResponse(aiMessageIndex);
        return;
      }

      if (initialText.toLowerCase().trim() == "test audio") {
        onMediaGenerating('audio');
        await Future.delayed(const Duration(seconds: 2));
        await onAudioReceived(
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3");
        _conversationProvider.finishBotResponse(aiMessageIndex);
        return;
      }

      if (initialText.toLowerCase().trim() == "test video") {
        onMediaGenerating('video');
        await Future.delayed(const Duration(seconds: 2));
        await onVideoReceived("https://www.w3schools.com/html/mov_bbb.mp4");
        _conversationProvider.finishBotResponse(aiMessageIndex);
        return;
      }

      // Execute Request
      if (isCharacterModel) {
        // Characters typically don't use tools in this architecture yet
        final characterBaseModel = _resolveCharacterBaseModel(
          characterModel: modelData,
          langCode: langCode,
        );

        await _apiService.getCharacterResponse(
          userInput: "",
          // Already in context
          context: contextMessages,
          characterId: modelId,
          baseModelId: characterBaseModel.id,
          source: characterBaseModel.source,
          isPremium: isPremium,
          enablefeatureReasoning: enablefeatureReasoning,
          localizations: localizations,
          onTextChunk: onTextChunk,
          onfeatureReasoning: onfeatureReasoning,
          onImageReceived: onImageReceived,
          onVideoReceived: onVideoReceived,
          onAudioReceived: onAudioReceived,
          onMediaGenerating: onMediaGenerating,
        );
        // Characters exit loop immediately
        shouldContinue = false;
      } else {
        // Standard Models (Support Tools)
        final isMediaModel = modelData.category == 'image' ||
            modelData.category == 'video' ||
            modelData.category == 'audio';
        final enableWebSearch = !isMediaModel && _inputProvider.enableWebSearch;
        if (enableWebSearch) {
          setWebSearchActive(true);
        }
        await _apiService.getOnlineModelResponse(
          modelId: modelId,
          isPremium: isPremium,
          userInput: "",
          // Already in context
          context: contextMessages,
          source: modelData.source,
          localizations: localizations,
          langCode: langCode,
          enablefeatureReasoning: enablefeatureReasoning,
          enableWebSearch: enableWebSearch,
          useTools: !isMediaModel && !_voiceService.isFlowActive,
          // Disable tools in Flow Mode
          onTextChunk: onTextChunk,
          onfeatureReasoning: onfeatureReasoning,
          onImageReceived: onImageReceived,
          onVideoReceived: onVideoReceived,
          onAudioReceived: onAudioReceived,
          onMediaGenerating: onMediaGenerating,
          // Capture Tools
          onToolCall: (tools) {
            turnToolCalls = tools;
          },
          onCitations: (citations) {
            setWebSearchActive(false);
            if (_isConversationActive(targetConvId)) {
              _conversationProvider.updateLastBotMessageSources(citations);
            }
          },
          onWebSearchActive: setWebSearchActive,
        );
      }

      // Post-Response: Check for Tools
      if (turnToolCalls.isNotEmpty) {
        shouldContinue = true; // We need to loop again to send results

        // Close reasoning block before tool execution if it's still open.
        if (isfeatureReasoningBlockActive) {
          appendStreamChunk("</think>");
          isfeatureReasoningBlockActive = false;
        }

        // 1. Add Assistant Request to History
        contextMessages.add({
          "role": "assistant",
          "content": "", // Usually empty when calling tools
          "tool_calls": turnToolCalls
        });

        // 2. Execute Tools & Add Results
        for (var call in turnToolCalls) {
          final String callId = call['id'];
          final String name = call['function']['name'];
          final String argsStr = call['function']['arguments'];

          String result;
          final tool = ToolRegistry.getTool(name);

          // Variables for structured output
          String? widgetType;
          Map<String, dynamic>? widgetData;
          String summaryForContext = "";

          if (tool != null) {
            try {
              final args = jsonDecode(argsStr);
              // Execute tool
              result = await tool.function(args);

              // CHECK FOR STRUCTURED WIDGET RESPONSE
              try {
                if (result.trim().startsWith('{')) {
                  final jsonResult = jsonDecode(result);
                  if (jsonResult is Map && jsonResult.containsKey('widget')) {
                    widgetType = jsonResult['widget'];
                    widgetData = jsonResult['data'];
                    summaryForContext = jsonResult['summary'].toString();
                  }
                }
              } catch (_) {
                // Not a widget json, proceed as normal
              }

              if (widgetType != null) {
                // Inject Widget Marker (no extra newlines to avoid spacing issues)
                // The UI (parser) will detect this pattern and render the card
                final widgetMarker =
                    "<<<WIDGET:$widgetType>>>${jsonEncode(widgetData)}<<<END>>>";
                appendStreamChunk(widgetMarker, flushImmediately: true);

                // Use the summary for the LLM context so it doesn't get confused by raw JSON
                result = summaryForContext;
              }
            } catch (e) {
              result = "Error executing tool '$name': $e";
            }
          } else {
            result = "Tool not found.";
          }

          // Add Tool Result to History
          contextMessages.add({
            "role": "tool",
            "tool_call_id": callId,
            "name": name,
            "content": result
          });
        }
      }
    }

    // Ensure reasoning block is closed at the end of all iterations.
    if (isfeatureReasoningBlockActive) {
      appendStreamChunk("</think>");
      isfeatureReasoningBlockActive = false;
    }

    // Clear documents context after processing
    ToolRegistry.clearDocumentsContext();
    setWebSearchActive(false);

    // CRITICAL: The background buffer mirrors every chunk, including chunks
    // that arrived while this chat was foregrounded. This prevents a late tab
    // switch from making a completed response look empty and triggering retries.
    final bufferedResponseText =
        _backgroundTaskService.peekBuffer(targetConvId);
    String finalResponseText = bufferedResponseText;
    bool hasGeneratedMedia =
        _backgroundTaskService.getMediaAttachments(targetConvId).isNotEmpty;

    if (finalResponseText.isEmpty && _isConversationActive(targetConvId)) {
      final messages = _conversationProvider.messages;
      finalResponseText = messages.isNotEmpty ? messages.last.text : "";
      hasGeneratedMedia =
          messages.isNotEmpty && messages.last.attachmentPaths.isNotEmpty;
    }

    // Extract memory updates if any
  final memoryExp = RegExp(r'<memory[)>]?([\s\S]*?)(?:</memory[)>]?|$)',
      caseSensitive: false);
  final memoryMatch = memoryExp.firstMatch(finalResponseText);
  if (memoryMatch != null) {
    final newMemory = memoryMatch.group(1)?.trim();
    if (newMemory != null && newMemory.isNotEmpty) {
      final lines = newMemory.split('\n').where((s) => s.trim().isNotEmpty);
      for (final line in lines) {
        await _userMemoryProvider.addMemory(line);
      }
      try {
        final semanticMemService = SemanticMemoryService();
        await semanticMemService.saveFromMemoryBlock(newMemory);
        debugPrint('[Memory] Saved memory block to SQLite semantic memory.');
      } catch (e) {
        debugPrint('[Memory] Error saving to SQLite semantic memory: $e');
      }
      debugPrint(
          '[Memory] Successfully extracted and updated memory from response.');
    }
  }

 // CHECK FOR EMPTY RESPONSE
    final cleanResponse = finalResponseText.replaceAll(memoryExp, '').trim();
    if (cleanResponse.isEmpty && !hasGeneratedMedia) {
      throw ApiException(localizations.errorServer, code: 'EMPTY_RESPONSE');
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

  Future<void> _attachGeneratedMediaToAiMessage({
    required int aiMessageIndex,
    required String mediaPath,
    required String targetConvId,
  }) async {
    _backgroundTaskService.addMediaAttachment(targetConvId, mediaPath);
    _backgroundTaskService.setPendingMediaType(
        targetConvId, MediaGenerationType.none);

    if (_isConversationActive(targetConvId)) {
      // FOREGROUND: Attach to the live UI message.
      final messages = _conversationProvider.messages;
      if (aiMessageIndex < 0 || aiMessageIndex >= messages.length) return;

      final Message currentAiMessage = messages[aiMessageIndex];
      final updatedAttachments =
          List<String>.from(currentAiMessage.attachmentPaths);
      if (!updatedAttachments.contains(mediaPath)) {
        updatedAttachments.add(mediaPath);
      }

      final updatedMessage = currentAiMessage.copyWith(
        attachmentPaths: updatedAttachments,
        pendingMediaType: MediaGenerationType.none,
      );

      _conversationProvider.updateMessageAtIndex(
          aiMessageIndex, updatedMessage);
      if (_conversationProvider.conversationID != null) {
        await ChatStorageService.upsertMessage(
            _conversationProvider.conversationID!,
            aiMessageIndex,
            updatedMessage);
      }
      if (_scrollService.isUserAtBottom()) {
        _scrollService.scrollToBottom(
            duration: const Duration(milliseconds: 100));
      }
    } else {
      // BACKGROUND: User has left this chat. Persist media directly to DB
      // and track in background task service so it can be merged on re-entry.
      // Persist directly to the database.
      try {
        final existingMsg = await ChatStorageService.getMessageAtIndex(
            targetConvId, aiMessageIndex);
        if (existingMsg != null) {
          final updatedAttachments =
              List<String>.from(existingMsg.attachmentPaths);
          if (!updatedAttachments.contains(mediaPath)) {
            updatedAttachments.add(mediaPath);
          }
          final updatedMessage = existingMsg.copyWith(
            attachmentPaths: updatedAttachments,
            pendingMediaType: MediaGenerationType.none,
          );
          await ChatStorageService.upsertMessage(
              targetConvId, aiMessageIndex, updatedMessage);
        } else {
          // No existing message yet — create a minimal one with the media.
          final mediaMessage = Message(
            text: '',
            isUserMessage: false,
            attachmentPaths: [mediaPath],
            isThinking: false,
            includeInContext: true,
          );
          await ChatStorageService.upsertMessage(
              targetConvId, aiMessageIndex, mediaMessage);
        }
        debugPrint(
            '[SendService] Background media persisted for $targetConvId: $mediaPath');
      } catch (e) {
        debugPrint('[SendService] Error persisting background media: $e');
      }
    }
  }

  Future<String> _persistGeneratedMedia({
    required String url,
    required String dataPrefix,
    required List<String> allowedExtensions,
    required String fallbackExtension,
  }) async {
    final ext = _inferMediaExtension(
      url: url,
      allowedExtensions: allowedExtensions,
      fallbackExtension: fallbackExtension,
    );
    final dir = await getApplicationDocumentsDirectory();
    final localPath = '${dir.path}/${_uuid.v4()}.$ext';

    if (url.startsWith(dataPrefix)) {
      try {
        final commaIndex = url.indexOf(',');
        if (commaIndex <= 0 || commaIndex >= url.length - 1) return url;
        final encoded = url.substring(commaIndex + 1);
        final bytes = base64Decode(encoded);
        await File(localPath).writeAsBytes(bytes);
        return localPath;
      } catch (e) {
        debugPrint("Media data URI decode failed. Falling back to raw URL: $e");
        return url;
      }
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      try {
        final request = await HttpClient().getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException(
            'Unexpected HTTP status: ${response.statusCode}',
            uri: Uri.parse(url),
          );
        }
        final bytes = await consolidateHttpClientResponseBytes(response);
        await File(localPath).writeAsBytes(bytes);
        return localPath;
      } catch (e) {
        debugPrint("Media download failed. Falling back to remote URL: $e");
        return url;
      }
    }

    return url;
  }

  String _inferMediaExtension({
    required String url,
    required List<String> allowedExtensions,
    required String fallbackExtension,
  }) {
    final mimeMatch =
        RegExp(r'^data:([^;]+);base64,', caseSensitive: false).firstMatch(url);
    if (mimeMatch != null) {
      final mime = (mimeMatch.group(1) ?? '').toLowerCase();
      final slashIndex = mime.indexOf('/');
      if (slashIndex != -1 && slashIndex < mime.length - 1) {
        final mimeExt = mime.substring(slashIndex + 1);
        if (allowedExtensions.contains(mimeExt)) {
          return mimeExt;
        }
      }
    }

    final ext =
        p.extension(url.split('?').first).toLowerCase().replaceAll('.', '');
    if (allowedExtensions.contains(ext)) {
      return ext;
    }

    return fallbackExtension;
  }

  bool _isImageFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
  }

  bool _isVideoFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['mp4', 'mov', 'm4v', 'webm', 'mkv', 'avi'].contains(ext);
  }

  bool _isAudioFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', 'opus'].contains(ext);
  }

  String _normalizeIntentText(String text) {
    return text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  bool _containsAny(String value, Iterable<String> needles) {
    return needles.any((needle) => value.contains(needle));
  }

  _MediaIntent _inferMediaIntentFromText({
    required String text,
    required bool hasImage,
    required bool hasVideo,
    required bool hasAudio,
  }) {
    final normalized = _normalizeIntentText(text);
    if (normalized.trim().isEmpty) return _MediaIntent.none;

    const editTerms = [
      'edit',
      'modify',
      'change',
      'replace',
      'remove',
      'erase',
      'add ',
      'upscale',
      'enhance',
      'restore',
      'colorize',
      'background',
      'better',
      'beautify',
      'prettier',
      'style',
      'stylize',
      'turn into',
      'make it',
      'duzenle',
      'degistir',
      'sil',
      'kaldir',
      'ekle',
      'iyilestir',
      'netlestir',
      'renklendir',
      'arka plan',
      'fon',
      'restor',
      'stille',
      'stilize',
      'tarz',
      'tarzi',
      'guzel',
      'daha iyi',
      'daha kaliteli',
      'kaliteli yap',
      'canlandir',
      'kirp',
      'dondur',
      'buyut',
      'kucult',
    ];
    const imageTerms = [
      'image',
      'picture',
      'photo',
      'gorsel',
      'resim',
      'fotograf',
      'foto',
    ];
    const videoTerms = [
      'video',
      'clip',
      'animation',
      'animate',
      'motion',
      'animasyon',
      'hareket',
      'hareketlendir',
      'canlandir',
    ];
    const audioTerms = ['audio', 'voice', 'sound', 'music', 'ses', 'muzik'];
    const generateTerms = [
      'generate',
      'create',
      'draw',
      'make',
      'produce',
      'olustur',
      'uret',
      'ciz',
      'yap',
    ];
    const understandTerms = [
      'what',
      'describe',
      'explain',
      'analyze',
      'read',
      'transcribe',
      'summarize',
      'ne',
      'nedir',
      'acikla',
      'anlat',
      'analiz',
      'oku',
      'cevir',
      'ozetle',
      'yaziyor',
      'kim',
      'nerede',
    ];

    final edits = _containsAny(normalized, editTerms);
    final generates = _containsAny(normalized, generateTerms);
    final mentionsImage = _containsAny(normalized, imageTerms);
    final mentionsVideo = _containsAny(normalized, videoTerms);
    final mentionsAudio = _containsAny(normalized, audioTerms);

    if (hasImage && !hasVideo && mentionsVideo && (edits || generates)) {
      return _MediaIntent.generateVideo;
    }
    if (hasImage &&
        (edits ||
            (generates &&
                (mentionsImage || !mentionsVideo && !mentionsAudio)))) {
      return _MediaIntent.editImage;
    }
    if (hasVideo && (edits || (generates && mentionsVideo))) {
      return _MediaIntent.editVideo;
    }
    if (hasAudio && (edits || (generates && mentionsAudio))) {
      return _MediaIntent.editAudio;
    }
    if (generates && mentionsImage) return _MediaIntent.generateImage;
    if (generates && mentionsVideo) return _MediaIntent.generateVideo;
    if (generates && mentionsAudio) return _MediaIntent.generateAudio;
    if (_containsAny(normalized, understandTerms)) {
      return _MediaIntent.understand;
    }

    return _MediaIntent.understand;
  }

  Iterable<ModelEntity> _iterPreciseModels(String langCode) sync* {
    final seen = <String>{};
    for (final model in _modelService.getCachedModelsSync()) {
      if (seen.add(model.id)) {
        yield _modelService.getPreciseModelData(model.id, langCode: langCode);
      }
      final variants = model.variants;
      if (variants == null) continue;
      for (final entry in variants.entries) {
        final variantId = entry.key;
        if (seen.add(variantId)) {
          yield _modelService.getPreciseModelData(variantId,
              langCode: langCode);
        }
      }
    }
  }

  ModelEntity? _pickModel(
    String langCode,
    bool isUserSubscribed,
    bool Function(ModelEntity model) predicate,
  ) {
    final candidates = _iterPreciseModels(langCode).where((model) {
      if (!model.isServerSide) return false;
      if (!isUserSubscribed && model.isPremium) return false;
      final id = model.id.toLowerCase();
      if (id.contains('guard')) return false;
      return predicate(model);
    }).toList();

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      int score(ModelEntity model) {
        var value = 0;
        if (!model.isPremium) value += 100;
        if (model.source.toLowerCase() == 'openrouter') value += 20;
        if (model.source.toLowerCase() == 'fal') value += 20;
        if (model.tier.toLowerCase() == 'free') value += 10;
        return value;
      }

      return score(b).compareTo(score(a));
    });
    return candidates.first;
  }

  ModelEntity? _findFalMediaModel({
    required String langCode,
    required bool isUserSubscribed,
    required String outputType,
    String? requiredInputType,
    Set<String> excludeIds = const {},
  }) {
    return _pickModel(
      langCode,
      isUserSubscribed,
      (model) {
        if (excludeIds.contains(model.id)) return false;
        if (model.source.toLowerCase() != 'fal') return false;
        if (model.outputs[outputType] != true && model.category != outputType) {
          return false;
        }
        if (requiredInputType != null &&
            model.modalities[requiredInputType] != true) {
          return false;
        }
        return true;
      },
    );
  }

  ModelEntity? _findAttachmentUnderstandingModel({
    required String langCode,
    required bool isUserSubscribed,
    required bool hasImage,
    required bool hasVideo,
    required bool hasAudio,
  }) {
    return _pickModel(
      langCode,
      isUserSubscribed,
      (model) {
        final category = model.category.toLowerCase();
        if (category == 'image' || category == 'video' || category == 'audio') {
          return false;
        }
        if (model.source.toLowerCase() == 'fal') return false;
        if (hasImage && model.modalities['image'] != true) return false;
        if (hasVideo && model.modalities['video'] != true) return false;
        if (hasAudio && model.modalities['audio'] != true) return false;
        return model.outputs['text'] == true || model.outputs.isEmpty;
      },
    );
  }

  String? _resolveAttachmentIntentModelId({
    required String currentModelId,
    required String text,
    required List<String> attachments,
    required String langCode,
    required bool isUserSubscribed,
  }) {
    if (attachments.isEmpty || text.trim().isEmpty) return null;
    if (currentModelId != 'cortex/auto' && currentModelId != 'dynamic') {
      return null;
    }

    final hasImage = attachments.any(_isImageFile);
    final hasVideo = attachments.any(_isVideoFile);
    final hasAudio = attachments.any(_isAudioFile);
    if (!hasImage && !hasVideo && !hasAudio) return null;

    final intent = _inferMediaIntentFromText(
      text: text,
      hasImage: hasImage,
      hasVideo: hasVideo,
      hasAudio: hasAudio,
    );

    ModelEntity? routed;
    switch (intent) {
      case _MediaIntent.editImage:
        routed = _findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'image',
          requiredInputType: 'image',
        );
        break;
      case _MediaIntent.editVideo:
        routed = _findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'video',
          requiredInputType: hasVideo ? 'video' : null,
        );
        break;
      case _MediaIntent.editAudio:
        routed = _findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'audio',
          requiredInputType: hasAudio ? 'audio' : null,
        );
        break;
      case _MediaIntent.generateImage:
        routed = _findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'image',
          requiredInputType: hasImage ? 'image' : null,
        );
        break;
      case _MediaIntent.generateVideo:
        routed = _findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'video',
          requiredInputType: hasVideo
              ? 'video'
              : hasImage
                  ? 'image'
                  : null,
        );
        break;
      case _MediaIntent.generateAudio:
        routed = _findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'audio',
          requiredInputType: hasAudio ? 'audio' : null,
        );
        break;
      case _MediaIntent.understand:
      case _MediaIntent.none:
        routed = _findAttachmentUnderstandingModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          hasImage: hasImage,
          hasVideo: hasVideo,
          hasAudio: hasAudio,
        );
        break;
    }

    if (routed == null) return null;
    debugPrint(
        "[SendService] Attachment intent '$intent' routed dynamic chat to '${routed.id}'.");
    return routed.id;
  }

  bool _isFalMediaModel(ModelEntity model, String outputType) {
    return model.source.toLowerCase() == 'fal' &&
        (model.outputs[outputType] == true || model.category == outputType);
  }

  String _localizedFalFallbackMessage(
    ApiException error,
    AppLocalizations localizations,
  ) {
    switch (error.code) {
      case 'FAL_IMAGE_REQUIRED':
        return localizations.falErrorImageRequired;
      case 'FAL_AUDIO_REQUIRED':
        return localizations.falErrorAudioRequired;
      case 'FAL_VIDEO_REQUIRED':
        return localizations.falErrorVideoRequired;
      case 'FAL_IMAGE_CORRUPTED':
        return localizations.falErrorImageCorrupted;
      case 'FAL_SCHEMA_INVALID':
        return localizations.falErrorSchemaInvalid;
      case 'FAL_SCHEMA_REJECTED':
        return localizations.falErrorSchemaRejected;
      default:
        return error.message;
    }
  }

  bool _shouldFallbackServerErrorToDynamic(Object error, String? modelId) {
    final normalizedModelId = (modelId ?? '').toLowerCase();
    if (normalizedModelId == 'cortex/auto' || normalizedModelId == 'dynamic') {
      return false;
    }

    if (error is! ApiException) return true;

    final code = error.code?.toUpperCase();
    if (code == null || code.isEmpty) return true;

    const userFacingCodes = <String>{
      'NO_USER',
      'CONTENT_FLAGGED',
      'PREMIUM_TRIAL_EXHAUSTED',
      'PREDIT_EXHAUSTED',
      'DREDIT_EXHAUSTED',
      'INSUFFICIENT_USER_CREDITS',
      'LIMIT_IMAGE_INSUFFICIENT',
      'LIMIT_VIDEO_INSUFFICIENT',
      'LIMIT_AUDIO_INSUFFICIENT',
      'LIMIT_MEDIA_INSUFFICIENT',
      'VIDEO_ULTRA_ONLY',
    };

    if (userFacingCodes.contains(code)) return false;

    // Provider-side/runtime failures should not leak as raw model failures.
    // Give Cortex dynamic chat one clean chance; if that also fails, the
    // caller will surface the localized error.
    return true;
  }

  String _cleanFinalResponseText(String text) {
    return text.replaceAll(RegExp(r'\n---\s*$'), '').trimRight();
  }

  bool _isAppInBackground() {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;
  }

  void _syncActiveMessageFromBackgroundBuffer(
    String convId,
    int aiMessageIndex,
    String modelId,
  ) {
    if (!_isConversationActive(convId)) return;

    final messages = _conversationProvider.messages;
    if (aiMessageIndex < 0 || aiMessageIndex >= messages.length) return;

    final currentMessage = messages[aiMessageIndex];
    if (currentMessage.isUserMessage) return;

    final bufferedText = _backgroundTaskService.peekBuffer(convId);
    final backgroundAttachments =
        _backgroundTaskService.getMediaAttachments(convId);
    final mergedAttachments = List<String>.from(currentMessage.attachmentPaths);
    for (final path in backgroundAttachments) {
      if (!mergedAttachments.contains(path)) {
        mergedAttachments.add(path);
      }
    }

    var updatedMessage = currentMessage;
    if (bufferedText.isNotEmpty &&
        bufferedText != currentMessage.text &&
        bufferedText.length >= currentMessage.text.length) {
      updatedMessage = updatedMessage.copyWith(text: bufferedText);
    }
    if (mergedAttachments.length != currentMessage.attachmentPaths.length) {
      updatedMessage =
          updatedMessage.copyWith(attachmentPaths: mergedAttachments);
    }
    if (updatedMessage.model == null) {
      updatedMessage = updatedMessage.copyWith(model: modelId);
    }

    if (updatedMessage != currentMessage) {
      _conversationProvider.updateMessageAtIndex(
          aiMessageIndex, updatedMessage);
      _conversationProvider.flushStreamUpdates();
    }
  }

  /// Checks the daily guest limit and returns true if the user can send a message.
  /// If the user is blocked, it shows the bottom sheet and returns false.
  Future<bool> checkGuestLimit(
      BuildContext context, AppLocalizations localizations) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    final String lastDate = prefs.getString('guest_message_date') ?? '';
    int guestMessageCount = prefs.getInt('guest_message_count') ?? 0;

    if (lastDate != today) {
      guestMessageCount = 0;
      await prefs.setString('guest_message_date', today);
    }

    guestMessageCount++;
    await prefs.setInt('guest_message_count', guestMessageCount);

    // Guest limit check is now performed before this method is called.
    if ([5, 10, 25, 50, 100].contains(guestMessageCount)) {
      if (context.mounted) {
        showGuestLimitSheet(context, localizations);
      }
      return false; // Blocked this time
    }

    return true; // Allowed
  }

  /// Persists the accumulated background buffer to the database as the AI message.
  Future<void> _persistBackgroundCompletion(
      String convId, int aiMessageIndex, String modelId) async {
    try {
      final accumulatedText = _backgroundTaskService.consumeBuffer(convId);
      final mediaAttachments =
          _backgroundTaskService.getMediaAttachments(convId);

      if (accumulatedText.isEmpty && mediaAttachments.isEmpty) return;

      // Check if there's already a message in the DB (e.g. from background
      // media persistence) and merge with it.
      Message? existingMsg;
      try {
        existingMsg =
            await ChatStorageService.getMessageAtIndex(convId, aiMessageIndex);
      } catch (_) {}

      final List<String> mergedAttachments = [];
      if (existingMsg != null) {
        mergedAttachments.addAll(existingMsg.attachmentPaths);
      }
      for (final path in mediaAttachments) {
        if (!mergedAttachments.contains(path)) {
          mergedAttachments.add(path);
        }
      }

      // Build a finalized AI message from the accumulated text + media.
      final rawFinalText = existingMsg != null && accumulatedText.isEmpty
          ? existingMsg.text
          : accumulatedText;
      final String finalText = _cleanFinalResponseText(rawFinalText);

      final finalMessage = Message(
        id: existingMsg?.id,
        text: finalText,
        isUserMessage: false,
        isThinking: false,
        includeInContext: true,
        attachmentPaths: mergedAttachments,
        model: existingMsg?.model ?? modelId,
        webSearchSources: existingMsg?.webSearchSources,
      );

      await ChatStorageService.upsertMessage(
          convId, aiMessageIndex, finalMessage);
      debugPrint('[SendService] Background completion persisted for $convId '
          '(${finalText.length} chars, ${mergedAttachments.length} media).');
    } catch (e) {
      debugPrint('[SendService] Error persisting background completion: $e');
    }
  }

  Future<void> _persistBackgroundError(
    String convId,
    int aiMessageIndex,
    String? modelId,
    Object error,
    AppLocalizations localizations,
  ) async {
    try {
      final bufferedText = _backgroundTaskService.peekBuffer(convId);
      final mediaAttachments =
          _backgroundTaskService.getMediaAttachments(convId);

      if (bufferedText.trim().isNotEmpty || mediaAttachments.isNotEmpty) {
        await _persistBackgroundCompletion(
            convId, aiMessageIndex, modelId ?? 'cortex/auto');
        return;
      }

      Message? existingMsg;
      try {
        existingMsg =
            await ChatStorageService.getMessageAtIndex(convId, aiMessageIndex);
      } catch (_) {}

      final errorText =
          error is ApiException ? error.message : localizations.anErrorOccurred;
      final mergedAttachments = <String>[
        if (existingMsg != null) ...existingMsg.attachmentPaths,
      ];
      for (final path in mediaAttachments) {
        if (!mergedAttachments.contains(path)) {
          mergedAttachments.add(path);
        }
      }

      final errorMessage = Message(
        id: existingMsg?.id,
        text: errorText,
        isUserMessage: false,
        isThinking: false,
        isError: true,
        includeInContext: false,
        attachmentPaths: mergedAttachments,
        model: existingMsg?.model ?? modelId,
      );

      await ChatStorageService.upsertMessage(
          convId, aiMessageIndex, errorMessage);
    } catch (persistError) {
      debugPrint(
          '[SendService] Error persisting background failure for $convId: $persistError');
    }
  }

  /// Gets the conversation title for the notification.
  Future<String> _getChatTitleForNotification(String convId) async {
    try {
      final db = await ChatStorageService.getConversationTitle(convId);
      return db ?? 'Chat';
    } catch (_) {
      return 'Chat';
    }
  }

  /// Sends a local push notification when a background chat finishes.
  void _sendBackgroundCompletionNotification(
      String convId, String chatTitle, AppLocalizations localizations) {
    try {
      final plugin = FlutterLocalNotificationsPlugin();

      final title = chatTitle;
      final body = localizations.backgroundChatNotificationTitle;

      const androidDetails = AndroidNotificationDetails(
        'background_chat',
        'Background Chats',
        channelDescription:
            'Notifications when background chats finish generating.',
        importance: Importance.high,
        priority: Priority.high,
      );

      const platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      plugin.show(
        DateTime.now().millisecondsSinceEpoch.toSigned(31),
        title,
        body,
        platformDetails,
        payload: jsonEncode({
          'type': 'background_chat',
          'screen': 'chat',
          'conversation_id': convId,
        }),
      );

      debugPrint('[SendService] Background notification sent for: $chatTitle');
    } catch (e) {
      debugPrint('[SendService] Failed to send background notification: $e');
    }
  }
}
