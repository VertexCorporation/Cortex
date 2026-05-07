// lib/chat/services/send.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import 'package:flutter/widgets.dart';
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
import 'tools.dart';

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
  })
      : _conversationProvider = conversationProvider,
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

    // Declare targetConvId outside try so the finally block can access it.
    String? targetConvId;

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
      final langCode = Localizations
          .localeOf(context)
          .languageCode;
      final hasInternet = await InternetConnection().hasInternetAccess;

      if (overrideModelId != null && overrideModelId.isNotEmpty) {
        apiModelIdForSend = overrideModelId;
      } else if (sessionProvider.isDynamicChat) {
        apiModelIdForSend = 'cortex/auto';
      } else {
        apiModelIdForSend = sessionProvider.modelId;
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

      final isAutoRouter = apiModelIdForSend == 'cortex/auto';
      final isServerSide = isAutoRouter ||
          Utils.isServerSideModel(apiModelIdForSend,
              langCode: langCode, modelService: _modelService);

      final selectedModelForSnapshot = _modelService
          .getPreciseModelData(apiModelIdForSend, langCode: langCode);
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
        model: apiModelIdForSend,
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

          final modelForStorage = apiModelIdForSend;

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
                  .then((aiTitle) {
                if (aiTitle != null && aiTitle
                    .trim()
                    .isNotEmpty) {
                  final cleanTitle =
                  aiTitle.length > 40 ? aiTitle.substring(0, 40) : aiTitle;

                  // Update current UI if we are still on this chat
                  if (_conversationProvider.conversationID == newConvId) {
                    _conversationProvider.updateConversationTitle(cleanTitle);
                    // Also set it in DB and broadcast via storage stream so Axon Inbox sees it
                    ChatStorageService.renameConversation(
                        newConvId, cleanTitle);
                  } else {
                    // Update local storage in the background
                    ChatStorageService.renameConversation(
                        newConvId, cleanTitle);
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

      // Guard: prevent duplicate sends for the same conversation.
      if (targetConvId != null &&
          _activeSendConversations.contains(targetConvId)) {
        debugPrint("SendService: Already sending for $targetConvId. Ignored.");
        return false;
      }
      if (targetConvId != null) _activeSendConversations.add(targetConvId);

      _inputProvider.clearAttachments();

      // -----------------------------------------------------------------------
      // 5. EXECUTION ROUTING
      // -----------------------------------------------------------------------

      if (!isServerSide) {
        // Offline Flow
        final offlineModerator = OfflineModeratorService();
        if (offlineModerator.isPromptAcceptable(textForApi)) {
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
        
        while (attempt < 3 && !success) {
          attempt++;
          try {
            await _sendServerSideMessageWithLoop(
              initialText: textForApi,
              modelId: apiModelIdForSend,
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
                rethrow;
              }
              debugPrint("SendService: Empty response detected, retrying attempt $attempt...");
              // Reset the message text before retrying
              if (_isConversationActive(convId)) {
                final currentMsg = _conversationProvider.messages[aiMessageIndex];
                _conversationProvider.updateMessageAtIndex(aiMessageIndex, currentMsg.copyWith(text: ""));
              } else {
                _backgroundTaskService.resetBuffer(convId);
              }
              await Future.delayed(const Duration(milliseconds: 500));
            } else {
              rethrow;
            }
          }
        }

        // Only update UI provider if user is still on this conversation.
        if (_isConversationActive(convId)) {
          _conversationProvider.finishBotResponse(aiMessageIndex);
        } else {
          // Background: persist the final message to DB.
          await _persistBackgroundCompletion(convId, aiMessageIndex);
        }

        if (_inputProvider.isVoiceModeActive && _isConversationActive(convId)) {
          _voiceService.onAiResponseFinished();
        }
      }

      // -----------------------------------------------------------------------
      // 6. ANALYTICS & HISTORY
      // -----------------------------------------------------------------------
      if (!isAutoRouter) {
        ChatStorageService.addRecentModel(apiModelIdForSend,
            langCode: langCode, modelService: _modelService)
            .ignore();
      }

      AnalyticsService().logMessageSent(
        modelType: !isServerSide ? 'offline' : 'online',
        hasAttachments: currentAttachmentPaths.isNotEmpty,
      );

      // Mark background task complete and send notification if needed.
      if (targetConvId != null &&
          _backgroundTaskService.isActive(targetConvId)) {
        final chatTitle = await _getChatTitleForNotification(targetConvId);
        _backgroundTaskService.markComplete(targetConvId);
        _sendBackgroundCompletionNotification(chatTitle, localizations);
      }

      return true;
    } catch (e) {
      if (e is UserCancelledException) return false;
      _handleSendError(e, isRegenerate, regenerateAiIndex, localizations);
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

    final bool isCharacterModel =
        (modelData.category == 'roleplay' || modelData.category == 'self') &&
            modelId != 'cortex/auto';

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

    // --- THE LOOP ---
    while (shouldContinue && loopCount < maxLoops) {
      shouldContinue = false; // Stop unless tools are called
      loopCount++;

      List<dynamic> turnToolCalls = [];

      // Handler Functions (defined here to capture scope)

      void onfeatureReasoning(String featureReasoningText) {
        // Skip featureReasoning if disabled
        if (!enablefeatureReasoning) return;
        if (_conversationProvider.wasResponseStopped &&
            _isConversationActive(targetConvId)) {
          return;
        }

        // If this is the START of a featureReasoning block, open the tag
        if (!isfeatureReasoningBlockActive) {
          // If we had featureReasoning before and closed it, we're continuing - add separator
          if (hasEverHadfeatureReasoning) {
            if (_isConversationActive(targetConvId)) {
              _conversationProvider.appendToLastBotMessage("\n\n");
            } else {
              _backgroundTaskService.appendChunk(targetConvId, "\n\n");
            }
          }
          if (_isConversationActive(targetConvId)) {
            _conversationProvider.appendToLastBotMessage("<think>");
          } else {
            _backgroundTaskService.markActive(targetConvId);
            _backgroundTaskService.appendChunk(targetConvId, "<think>");
          }
          isfeatureReasoningBlockActive = true;
          hasEverHadfeatureReasoning = true;
        }

        // Ensure we don't double-append headers or newlines. Just the raw text.
        if (_isConversationActive(targetConvId)) {
          _conversationProvider.appendToLastBotMessage(featureReasoningText);
        } else {
          _backgroundTaskService.appendChunk(
              targetConvId, featureReasoningText);
        }
      }

      void onTextChunk(String text) {
        if (_conversationProvider.wasResponseStopped &&
            _isConversationActive(targetConvId)) {
          return;
        }
        if (text.isEmpty) return; // Ignore empty keep-alive chunks

        // If we were featureReasoning and now switched to ACTUAL content, close the featureReasoning tag
        if (enablefeatureReasoning && isfeatureReasoningBlockActive) {
          if (_isConversationActive(targetConvId)) {
            _conversationProvider.appendToLastBotMessage("</think>");
          } else {
            _backgroundTaskService.appendChunk(targetConvId, "</think>");
          }
          isfeatureReasoningBlockActive = false;
        }

        if (_isConversationActive(targetConvId)) {
          _conversationProvider.appendToLastBotMessage(text);
          if (_inputProvider.isVoiceModeActive) {
            _voiceService.onAiStreamCallback(text);
          }
          if (_scrollService.isUserAtBottom()) {
            _scrollService.scrollToBottom(
                duration: const Duration(milliseconds: 50));
          }
        } else {
          // BACKGROUND MODE: accumulate in the background buffer.
          _backgroundTaskService.markActive(targetConvId);
          _backgroundTaskService.appendChunk(targetConvId, text);
        }
      }

      Future<void> onImageReceived(String url) async {
        if (_conversationProvider.wasResponseStopped) return;
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
          );
        } catch (e) {
          debugPrint("Image parse/save error: $e");
        }
      }

      Future<void> onAudioReceived(String url) async {
        if (_conversationProvider.wasResponseStopped) return;
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
          );
        } catch (e) {
          debugPrint("Audio parse/save error: $e");
        }
      }

      Future<void> onVideoReceived(String url) async {
        if (_conversationProvider.wasResponseStopped) return;
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
          );
        } catch (e) {
          debugPrint("Video parse/save error: $e");
        }
      }

      // Handler for media generation started signal (shimmer state)
      void onMediaGenerating(String type) {
        if (_conversationProvider.wasResponseStopped) return;
        final mediaType = switch (type) {
          'audio' => MediaGenerationType.audio,
          'image' => MediaGenerationType.image,
          'video' => MediaGenerationType.video,
          _ => MediaGenerationType.none,
        };
        if (mediaType == MediaGenerationType.none) return;
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
        var baseModelId = modelData.baseModelId;
        if (baseModelId == 'dynamic') baseModelId = 'cortex/auto';

        await _apiService.getCharacterResponse(
          userInput: "",
          // Already in context
          context: contextMessages,
          characterId: modelId,
          baseModelId: baseModelId ?? 'cortex/auto',
          source: modelData.source,
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
            _conversationProvider.updateLastBotMessageSources(citations);
          },
        );
      }

      // Post-Response: Check for Tools
      if (turnToolCalls.isNotEmpty) {
        shouldContinue = true; // We need to loop again to send results

        // Close featureReasoning block before tool execution if it's still open
        if (enablefeatureReasoning && isfeatureReasoningBlockActive) {
          if (_isConversationActive(targetConvId)) {
            _conversationProvider.appendToLastBotMessage("</think>");
          } else {
            _backgroundTaskService.appendChunk(targetConvId, "</think>");
          }
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
                final widgetMarker = "<<<WIDGET:$widgetType>>>${jsonEncode(
                    widgetData)}<<<END>>>";
                if (_isConversationActive(targetConvId)) {
                  _conversationProvider.appendToLastBotMessage(widgetMarker);
                  // Force immediate UI update for widget visibility
                  _conversationProvider.flushStreamUpdates();
                } else {
                  _backgroundTaskService.appendChunk(
                      targetConvId, widgetMarker);
                }

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

    // Ensure featureReasoning block is closed at the end of all iterations
    // This handles cases where the final response ends with featureReasoning
    if (enablefeatureReasoning && isfeatureReasoningBlockActive) {
      if (_isConversationActive(targetConvId)) {
        _conversationProvider.appendToLastBotMessage("</think>");
      } else {
        _backgroundTaskService.appendChunk(targetConvId, "</think>");
      }
      isfeatureReasoningBlockActive = false;
    }

    // Clear documents context after processing
    ToolRegistry.clearDocumentsContext();

    // Extract memory updates if any
    final finalResponseText = _conversationProvider.messages.isNotEmpty
        ? _conversationProvider.messages.last.text
        : "";
    final memoryExp =
    RegExp(r'<memory[)>]?([\s\S]*?)(?:</memory[)>]?|$)', caseSensitive: false);
    final memoryMatch = memoryExp.firstMatch(finalResponseText);
    if (memoryMatch != null) {
      final newMemory = memoryMatch.group(1)?.trim();
      if (newMemory != null && newMemory.isNotEmpty) {
        _userMemoryProvider.updateMemory(newMemory);
        debugPrint(
            '[Memory] Successfully extracted and updated memory from response.');
      }
    }

    // CHECK FOR EMPTY RESPONSE
    final cleanResponse = finalResponseText.replaceAll(memoryExp, '').trim();
    final bool hasGeneratedMedia = _conversationProvider.messages.isNotEmpty && _conversationProvider.messages.last.attachmentPaths.isNotEmpty;
    if (cleanResponse.isEmpty && !hasGeneratedMedia) {
      throw ApiException(localizations.errorServer, code: 'EMPTY_RESPONSE');
    }
  }

  void _handleSendError(Object error,
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
  }) async {
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

    _conversationProvider.updateMessageAtIndex(aiMessageIndex, updatedMessage);
    final convId = _conversationProvider.conversationID;
    if (convId != null) {
      await ChatStorageService.upsertMessage(
          convId, aiMessageIndex, updatedMessage);
    }
    if (_scrollService.isUserAtBottom()) {
      _scrollService.scrollToBottom(
          duration: const Duration(milliseconds: 100));
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
    p.extension(url
        .split('?')
        .first).toLowerCase().replaceAll('.', '');
    if (allowedExtensions.contains(ext)) {
      return ext;
    }

    return fallbackExtension;
  }

  bool _isImageFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
  }

  /// Checks the daily guest limit and returns true if the user can send a message.
  /// If the user is blocked, it shows the bottom sheet and returns false.
  Future<bool> checkGuestLimit(BuildContext context,
      AppLocalizations localizations) async {
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
  Future<void> _persistBackgroundCompletion(String convId,
      int aiMessageIndex) async {
    try {
      final accumulatedText = _backgroundTaskService.consumeBuffer(convId);
      if (accumulatedText.isEmpty) return;

      // Build a finalized AI message from the accumulated text.
      final finalMessage = Message(
        text: accumulatedText,
        isUserMessage: false,
        isThinking: false,
        includeInContext: true,
      );

      await ChatStorageService.upsertMessage(
          convId, aiMessageIndex, finalMessage);
      debugPrint(
          '[SendService] Background completion persisted for $convId (${accumulatedText
              .length} chars).');
    } catch (e) {
      debugPrint('[SendService] Error persisting background completion: $e');
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
  void _sendBackgroundCompletionNotification(String chatTitle,
      AppLocalizations localizations) {
    try {
      final plugin = FlutterLocalNotificationsPlugin();

      final title = localizations.backgroundChatNotificationTitle;
      final body = localizations.backgroundChatNotificationBody(chatTitle);

      const androidDetails = AndroidNotificationDetails(
        'background_chat',
        'Background Chats',
        channelDescription: 'Notifications when background chats finish generating.',
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
        DateTime
            .now()
            .millisecondsSinceEpoch
            .toSigned(31),
        title,
        body,
        platformDetails,
      );

      debugPrint('[SendService] Background notification sent for: $chatTitle');
    } catch (e) {
      debugPrint('[SendService] Failed to send background notification: $e');
    }
  }
}
