// lib/chat/services/send.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cortex/analytics/service.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/api.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/chat/services/background.dart';
import 'package:cortex/chat/services/context.dart';
import 'package:cortex/chat/services/generation.dart';
import 'package:cortex/chat/services/moderator.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/notifications/extrovert.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../library/providers/local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cortex/chat/screen/widgets/bottom/guest.dart';
import '../messages/messages.dart';
import 'package:cortex/chat/providers/memory.dart';
import 'package:cortex/chat/services/pii_filter.dart';
import 'package:cortex/rag/chat.dart';
import 'tools.dart';
import 'send/media.dart';
import 'send/circuit.dart';
import 'send/saver.dart';
import 'send/notify.dart';

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
  final RagChatService _ragChat;
  late final MediaRouter _mediaRouter;
  final CircuitBreaker _circuitBreaker = CircuitBreaker();

  /// Track which conversations are currently sending.
  /// Replaces the old single boolean `_isSending`.
  final Set<String> _activeSendConversations = {};

  // PERF: Stateless moderator — create once, reuse on every offline send.
  final OfflineModeratorService _offlineModerator = OfflineModeratorService();

  Timer? _retryTimer;

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
    required RagChatService ragChat,
  })  : _conversationProvider = conversationProvider,
        _inputProvider = inputProvider,
        _apiService = apiService,
        _contextService = contextService,
        _scrollService = scrollService,
        _offlineService = offlineService,
        _modelService = modelService,
        _voiceService = voiceService,
        _userMemoryProvider = userMemoryProvider,
        _backgroundTaskService = backgroundTaskService,
        _ragChat = ragChat {
    _mediaRouter = MediaRouter(_modelService);
  }

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
    if (lower.contains("i am") ||
        lower.contains("i'm") ||
        lower.contains("i like") ||
        lower.contains("i love") ||
        lower.contains("i hate") ||
        lower.contains("my name") ||
        lower.contains("my favorite") ||
        lower.contains("call me") ||
        lower.contains("i prefer") ||
        lower.contains("i have") ||
        lower.contains("my ") ||
        lower.contains("about me")) {
      return true;
    }

    // Turkish indicators
    if (lower.contains("benim") ||
        lower.contains(" adım") ||
        lower.contains("bana ") ||
        lower.contains("severim") ||
        lower.contains("nefret") ||
        lower.contains("favori") ||
        lower.contains("yaşındayım") ||
        lower.contains("hoşlanırım") ||
        lower.contains("ben ") ||
        lower.contains("yapmayı") ||
        lower.contains("olmayı")) {
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
    bool flowMode = false,
    // CONTINUATION MODE: resume a server-reported truncated response
    // (`isIncomplete`). No new user text is sent; the response loop keeps
    // the partial answer in context and appends a continuation instruction,
    // and the streamed remainder appends to the SAME message.
    bool isContinue = false,
  }) async {
    final sessionProvider = context.read<ChatSessionProvider>();

    // -----------------------------------------------------------------------
    // 0. CROSS-CONVERSATION ISOLATION (offline)
    // -----------------------------------------------------------------------
    // If an on-device generation is still decoding for a conversation the
    // user has ALREADY LEFT (the native llama stream keeps running until it
    // is stopped), its tokens would pass the single, conversation-blind
    // `isWaitingForResponse` guard the moment THIS exchange starts waiting —
    // i.e. the new chat would absorb another chat's tokens and its terminal
    // completion. Stop any live native stream BEFORE this exchange exists so
    // that can never happen. Harmless no-op when the stream is idle or the
    // platform has no native handler (guarded by the loaded flag).
    if (sessionProvider.isLocalModelLoaded) {
      // The stop REQUEST is dispatched synchronously at invoke time (the
      // platform message is out before the next line runs); awaiting its
      // response is unnecessary — OfflineService tears any live stream
      // down again, with a bounded ack wait, right before the actual
      // native generation. `unawaited` keeps the BuildContext use below
      // synchronous-only.
      unawaited(_offlineService.stopGeneration());
    }

    // -----------------------------------------------------------------------
    // 1. PREPARE CONTENT
    // -----------------------------------------------------------------------

    final String text = messageText.trim();
    final String displayText = text;
    List<String> currentAttachmentPaths = [];

    if (isRegenerate) {
      final messages = _conversationProvider.messages;
      final lastUserMessage = messages.reversed.firstWhere(
        (m) => m.isUserMessage,
        orElse: () => Message(text: '', isUserMessage: true),
      );
      // Continuation re-uses the ORIGINAL turn's attachments already in
      // history — re-attaching them to the continuation instruction would
      // double-send the media blocks.
      currentAttachmentPaths =
          isContinue ? [] : List.from(lastUserMessage.attachmentPaths);
    } else {
      // Use the class member _inputProvider or the local one.
      // Since we injected it, _inputProvider is safe.
      currentAttachmentPaths =
          _inputProvider.attachments.map((a) => a.file.path).toList();
    }

    // A continuation carries no new user text by design — the response loop
    // appends the continuation instruction itself.
    if (text.isEmpty && currentAttachmentPaths.isEmpty && !isContinue) {
      return false;
    }

    // _isSending guard replaced by per-conversation tracking below.

    // Declare target state outside try so catch/finally can clean up the
    // exact conversation that launched this request.
    String? targetConvId;
    int? targetAiMessageIndex;
    String? targetModelIdForSend;
    bool targetIsServerSide = false;

    // Generation lane ('image' | 'video' | 'audio' | 'music') and conversation
    // language, hoisted for the same reason: the catch reads them as the
    // credit-recovery context when Fulcrum refuses the request with a
    // insufficient-credit typed error.
    String? generationTarget;
    String? langCode;

    // Server-side title sync
    String? newConvIdForTitle;
    String? defaultTitleForServer;
    bool serverTitleReceived = false;
    Future<void> handleServerTitle(String title) async {
      if (serverTitleReceived || title.isEmpty || newConvIdForTitle == null) {
        return;
      }
      serverTitleReceived = true;

      final rawTitle =
          title.length > 40 ? title.substring(0, 40) : title;

      final cleanTitle = rawTitle
          .split(' ')
          .map((word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');

      final didRename = await ChatStorageService.renameConversation(
        newConvIdForTitle,
        cleanTitle,
        source: 'titlegen_sse',
        expectedCurrentTitle: defaultTitleForServer,
      );

      if (!didRename) {
        debugPrint(
            "[TitleGen] Skipped applying server-side title for $newConvIdForTitle because the title changed before completion.");
        return;
      }

      if (_conversationProvider.conversationID == newConvIdForTitle) {
        _conversationProvider.updateConversationTitle(cleanTitle);
      }
    }

    try {
      // -----------------------------------------------------------------------
      // 2. FEATURE MODES (Study, Quiz, etc.)
      // -----------------------------------------------------------------------
      final activeMode = _inputProvider.featureMode;
      final bool enableThinkingMode =
          activeMode == ChatInputMode.featureReasoning;
      String textForApi = text;
      if (isContinue) {
        // CONTINUATION INSTRUCTION (model-facing, fixed English): the partial
        // answer is already in context (appended manually by the response
        // loop); this turn only instructs the resume.
        textForApi =
            "Continue your previous response exactly where it stopped. Resume mid-sentence without repeating any earlier text, and finish the response.";
      }

      // Generation feature modes never rewrite the user's prompt. Resolve
      // the explicit transport target here. Audio is split into music versus
      // speech/sound so Fulcrum can use the correct model group, pricing lane
      // and media-duration defaults.
      generationTarget = generationTargetForMode(activeMode, text);

      // -----------------------------------------------------------------------
      // 3. MODEL RESOLUTION
      // -----------------------------------------------------------------------
      String? apiModelIdForSend;
      String errorMessage = localizations.errorNoModelsAvailable;

      final localState = context.read<ModelLocalStateProvider>();
      // Hoisted like generationTarget: the credit-recovery prompt needs the
      // conversation's language when the lightweight model composes the
      // natural refusal acknowledgment.
      langCode = Localizations.localeOf(context).languageCode;
      // Read before the await below; the context must not be touched across it.
      final creditsManager = context.read<CreditsManager>();

      // The Features sheet can only gate the generic Audio button against the
      // cheap speech lane before a prompt exists. Once the prompt is known,
      // enforce the actual resolved lane as well — especially music, which has
      // its own published cost. The server still remains the final authority.
      final generationCreditLane =
          generationCreditLaneForTarget(generationTarget);
      if (generationCreditLane != null &&
          !creditsManager.canGenerate(generationCreditLane)) {
        throw ApiException(
          localizations.errorReachedLimit,
          code: 'LIMIT_MEDIA_INSUFFICIENT',
        );
      }

      final hasInternet = await InternetConnection().hasInternetAccess;

      var originalUiModelId = overrideModelId ??
          (sessionProvider.isDynamicChat
              ? 'cortex/auto'
              : sessionProvider.modelId) ??
          'cortex/auto';

      if (overrideModelId != null && overrideModelId.isNotEmpty) {
        apiModelIdForSend = overrideModelId;
      } else if (sessionProvider.isDynamicChat) {
        apiModelIdForSend = 'cortex/auto';
      } else {
        apiModelIdForSend = sessionProvider.modelId;
      }

      // Under the unified credit engine, model choice belongs to the `full`
      // access band — but ONLY for SERVER-SIDE selections. Credit
      // restrictions ration paid cloud inference; they never apply to local
      // inference. An installed OFFLINE model keeps executing on-device at
      // ANY balance, even at the debt floor: it consumes no Fulcrum credits
      // and — privacy critically — its prompt must stay completely local
      // instead of silently shipping to Cortex through Dynamic Chat (remote
      // TitleGen below is the single connectivity-gated exception, and it
      // only ever shares the first message as a short title prompt). The
      // gateway enforces the same rule for online models, so applying it
      // here too keeps the message labelled with the model that actually
      // answered it.
      //
      // The session's preferred model is left alone on purpose — when the
      // allowance renews tomorrow the user gets it back without having to pick
      // it again.
      final bool selectedModelIsServerSide = Utils.isServerSideModel(
        apiModelIdForSend,
        langCode: langCode,
        modelService: _modelService,
      );
      if (lowCreditsForcesDynamicChat(
        canChooseModel: creditsManager.canChooseModel,
        selectedModelIsServerSide: selectedModelIsServerSide,
      )) {
        apiModelIdForSend = 'cortex/auto';
        originalUiModelId = 'cortex/auto';
      } else if (!creditsManager.canChooseModel) {
        debugPrint(
            "[SendService] Credits below the full band; local model '$apiModelIdForSend' stays on-device — offline inference is never credit-gated and never falls back to cortex/auto.");
      }

      final intentResolvedModelId = _mediaRouter.resolveAttachmentIntentModelId(
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
          final bool hasVisualContent = currentAttachmentPaths
              .any((path) => _mediaRouter.isImageFile(path));

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
          // Route the request gracefully back to a text LLM so it can answer properly
          apiModelIdForSend = "cortex/auto";
        }
      }

      if (apiModelIdForSend == null) {
        throw ApiException(errorMessage);
      }

      if (apiModelIdForSend == 'dynamic') {
        apiModelIdForSend = 'cortex/auto';
      }

      // Circuit breaker: skip models that have repeatedly failed this session
      if (apiModelIdForSend != 'cortex/auto' &&
          _circuitBreaker.isFailed(apiModelIdForSend)) {
        debugPrint(
            "SendService: Circuit breaker triggered for '$apiModelIdForSend'. Skipping to cortex/auto.");
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
        text: displayText,
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
              (displayText.isEmpty && currentAttachmentPaths.isNotEmpty)
                  ? "📁"
                  : (displayText.length > 32
                      ? displayText.substring(0, 32)
                      : displayText);

          final modelForStorage = originalUiModelId;

          // Capture for late server-side title events
          newConvIdForTitle = newConvId;
          defaultTitleForServer = defaultTitle;

          if (isHidden) {
            _conversationProvider.startEphemeralSession(
                newConvId, modelForStorage, userMessage,
                title: isHidden ? localizations.flowMode : null);
          } else {
            await _conversationProvider.startNewConversationSession(
              newConvId,
              defaultTitle,
              modelForStorage,
              userMessage,
              modelTitleForStorage: modelTitleForStorage,
              modelImagePathForStorage: modelImagePathForStorage,
            );

            // ASYNC AI CHAT TITLE GENERATION
            //
            // TitleGen is the one product-defined exception to offline
            // locality: for offline chats the message itself never leaves
            // the device (only the offline branch can run below), but the
            // tiny one-shot title prompt — built from the first user
            // message only — goes through the same remote TitleGen flow
            // online chats use, provided the device actually has internet.
            // Offline chats with no connectivity keep the local fallback
            // title instead of firing a request that cannot succeed, and
            // any TitleGen failure (offline chats included) is non-fatal:
            // catchError below keeps the conversation running with the
            // fallback title.
            if (text.isNotEmpty &&
                shouldGenerateTitleRemotely(
                  isServerSide: isServerSide,
                  hasInternet: hasInternet,
                )) {
              debugPrint(
                  "[SendService] Triggering TitleGen for new chat (${isServerSide ? 'online' : 'offline chat, remote title only'})...");
              _apiService
                  .generateChatTitle(
                      text,
                      'You are a chat title generator. Generate a very short, concise, and relevant title (max 6 words) for the following user message. Respond ONLY with the title text. No quotes, no punctuation, no explanation.',
                      'CRITICAL: Output must be ONLY the title. No markdown, no quotes, no emojis, no extra text. Just the plain title.')
                  .then((aiTitle) async {
                if (serverTitleReceived) {
                  debugPrint("[TitleGen] Server-side title already received, skipping client-side title.");
                  return;
                }
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
      if (isServerSide &&
          text.isNotEmpty &&
          !isHidden &&
          _isMemoryWorthy(text)) {
        debugPrint("[SendService] Triggering Memory Extraction...");
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

      // MEDIA REQUEST INSTRUMENTATION (safe metadata only — never content).
      // Mirrors the server's [MEDIA] log so any media failure can be traced
      // end-to-end: what the client attached, which model was pinned, whether
      // the pin was manual or dynamic, and where execution went.
      debugPrint(
          '[MediaTrace] attachments: image='
          '${currentAttachmentPaths.where(_mediaRouter.isImageFile).length} '
          'video=${currentAttachmentPaths.where(_mediaRouter.isVideoFile).length} '
          'audio=${currentAttachmentPaths.where(_mediaRouter.isAudioFile).length} | '
          'pinnedModel=$apiModelIdForSend '
          '(${isAutoRouter ? 'dynamic' : 'manual'}) | '
          'serverSide=$isServerSide | generationTarget=$generationTarget');

      if (!isServerSide) {
        // Offline Flow
        if (_offlineModerator.isPromptAcceptable(textForApi)) {
          await _offlineService.sendMessage(
            textForApi,
            currentAttachmentPaths.firstOrNull,
            activeMode,
            currentAttachmentPaths,
            _inputProvider.ragEnabled,
            _inputProvider.ragDocumentIds,
            targetConvId,
          );
        } else {
          throw ApiException(localizations.errorPromptFlagged);
        }
      } else {
        // Server Flow (with Tool Loop & featureReasoning)
        final String convId = targetConvId!;
        final String preFallbackModelId = apiModelIdForSend;
        int attempt = 0;
        bool success = false;
        String? dynamicFallbackNotice;
        bool hasTriedDynamicServerFallback =
            apiModelIdForSend == 'cortex/auto' ||
                apiModelIdForSend == 'dynamic';
        final triedMediaFallbackIds = <String>{apiModelIdForSend};

        // "Continue generating": the kept partial is part of THIS turn's
        // final text. Seed the background buffer with it so a completion
        // that finishes in the background persists partial + continuation
        // (the buffer is the source of truth for background finalization).
        if (isContinue) {
          final keptPartial = _conversationProvider.messages[aiMessageIndex].text;
          if (keptPartial.isNotEmpty) {
            _backgroundTaskService.seedBuffer(convId, keptPartial);
          }
        }

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

          _clearPendingMediaState(convId, aiMessageIndex);

          if (isContinue) {
            // "Continue generating": keep the partial — the retry loop re-reads
            // it as the assistant turn and the seeded background buffer keeps
            // it in the finalization source. Only relabel the bubble so the
            // model attribution matches the dynamic answer's source.
            if (_isConversationActive(convId)) {
              final currentMsg = _conversationProvider.messages[aiMessageIndex];
              _conversationProvider.updateMessageAtIndex(
                  aiMessageIndex, currentMsg.copyWith(model: 'cortex/auto'));
            }
          } else {
            _backgroundTaskService.resetBuffer(convId);
            if (_isConversationActive(convId)) {
              _conversationProvider.fadeOutMessage(aiMessageIndex);
              await _delayed(const Duration(milliseconds: 300));
              _conversationProvider.prepareForRegeneration(
                  aiMessageIndex, 'cortex/auto');
            }
          }
          await _delayed(const Duration(milliseconds: 100));
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
              generationTarget: generationTarget,
              onTitleReceived: handleServerTitle,
              activeMode: activeMode,
              flowMode: flowMode,
              isContinue: isContinue,
              continuationPartial: isContinue
                  ? _conversationProvider.messages[aiMessageIndex].text
                  : null,
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
              // "Continue generating" retries keep the partial: the buffer is
              // seeded with it and the loop re-reads it as the assistant turn.
              if (!isContinue) {
                _backgroundTaskService.resetBuffer(convId);
                if (_isConversationActive(convId)) {
                  final currentMsg =
                      _conversationProvider.messages[aiMessageIndex];
                  _conversationProvider.updateMessageAtIndex(
                      aiMessageIndex, currentMsg.copyWith(text: ""));
                }
              }
              await _delayed(const Duration(milliseconds: 500));
            } else if (e is ApiException && (e.code ?? '').startsWith('FAL_')) {
              final failedModelId = apiModelIdForSend ?? 'cortex/auto';
              final failedModel = _modelService.getPreciseModelData(
                failedModelId,
                langCode: langCode,
              );
              final hasImageAttachment =
                  currentAttachmentPaths.any(_mediaRouter.isImageFile);
              final canRetryImageToImage = hasImageAttachment &&
                  _mediaRouter.isFalMediaModel(failedModel, 'image') &&
                  failedModel.modalities['image'] != true;
              final imageToImageFallback = canRetryImageToImage
                  ? _mediaRouter.findFalMediaModel(
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
                  await _delayed(const Duration(milliseconds: 300));
                  _conversationProvider.prepareForRegeneration(
                      aiMessageIndex, imageToImageFallback.id);
                }
                await _delayed(const Duration(milliseconds: 100));
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

        // Circuit breaker: if the original model failed and fallback succeeded,
        // remember the failure so we skip the failing model next time.
        if (preFallbackModelId != (apiModelIdForSend ?? 'cortex/auto') &&
            preFallbackModelId != 'cortex/auto') {
          _circuitBreaker.recordFailure(preFallbackModelId);
          debugPrint(
              "SendService: Added '$preFallbackModelId' to circuit breaker.");
        }

        // Only update UI provider if user is still on this conversation.
        if (_isConversationActive(convId)) {
          _syncActiveMessageFromBackgroundBuffer(
              convId, aiMessageIndex, apiModelIdForSend!);
          _applyStreamCompletionStatus(convId, aiMessageIndex);
          _conversationProvider.finishBotResponse(aiMessageIndex);
        } else {
          // Background: persist the final message to DB.
          await _persistBackgroundCompletion(
              convId, aiMessageIndex, apiModelIdForSend!);
          if (_isConversationActive(convId)) {
            _syncActiveMessageFromBackgroundBuffer(
                convId, aiMessageIndex, apiModelIdForSend!);
            _applyStreamCompletionStatus(convId, aiMessageIndex);
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
        _handleSendError(
          e,
          isRegenerate,
          regenerateAiIndex,
          localizations,
          generationTarget: generationTarget,
          langCode: langCode,
        );
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
      _retryTimer?.cancel();
      if (targetConvId != null) {
        _activeSendConversations.remove(targetConvId);
        _backgroundTaskService.markComplete(targetConvId);
      }
    }
  }

  Future<void> _delayed(Duration duration) {
    _retryTimer?.cancel();
    final completer = Completer<void>();
    _retryTimer = Timer(duration, () => completer.complete());
    return completer.future;
  }

  /// Builds the RAG context block for the current message, or returns null
  /// when RAG is not active or nothing relevant was found.
  Future<String?> _buildRagContext({
    required String queryText,
    required List<String> attachmentPaths,
  }) {
    return _ragChat.buildContext(
      queryText: queryText,
      toggleEnabled: _inputProvider.ragEnabled,
      toggleDocumentIds: _inputProvider.ragDocumentIds,
      attachmentPaths: attachmentPaths,
    );
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
    String? generationTarget,
    Function(String)? onTitleReceived,
    required ChatInputMode activeMode,
    bool flowMode = false,
    bool isContinue = false,
    String? continuationPartial,
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
      // CONTINUATION: the trigger user turn must STAY in history (the model
      // resumes the answer it gave to it). The partial answer itself is
      // appended manually below — it is marked `isThinking` for the UI and
      // therefore excluded from the provider history.
      includeLastUser: !isContinue,
      targetModelId: modelId,
      langCode: langCode,
      isCharacterModel: isCharacterModel,
    );

    // 2. Add Current User Message to Context (Manual Construction)
    // We do this manually because attachments need to be processed into base64 blocks
    final List<Map<String, dynamic>> userContent = [];

    // RAG (Document Chat): retrieve relevant passages for this message and
    // prepend them as reference material. PII-safe before going online.
    final String? ragContext = isContinue
        ? null // Continuation: no new document query — the original turn's RAG material is already in history.
        : await _buildRagContext(
            queryText: initialText,
            attachmentPaths: attachments,
          );
    final bool ragActive = ragContext != null && ragContext.isNotEmpty;

    String combinedText = "";
    if (ragActive) {
      final safeContext = LocalPiiRedactionFilter.redact(ragContext);
      if (safeContext.isNotEmpty) {
        combinedText += "$safeContext\n\n";
      }
    }

    if (initialText.isNotEmpty) {
      combinedText += initialText;
    }

    if (combinedText.isNotEmpty) {
      userContent.add({"type": "text", "text": combinedText.trim()});
    }
    for (var path in attachments) {
      final block = await Utils.processAttachment(path);
      if (block != null) userContent.add(block);
    }

    // CONTINUATION: append the partial answer as the assistant turn the model
    // must resume from, BEFORE the instruction turn. The provider history
    // excludes it (it is marked `isThinking` for the streaming UI), so this
    // manual append is what keeps the model's resume anchored mid-sentence.
    // Continuation carries no attachment blocks — the original turn's media
    // is already in history and re-processing it here would double-send it.
    if (isContinue && continuationPartial != null) {
      contextMessages.add({"role": "assistant", "content": continuationPartial});
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

    // Tool execution is a separate, transient UI channel. Keep it on the
    // message so the tile can show a localized, expandable trace while the
    // response loop is waiting for a tool result. It never enters the model
    // context or the persisted assistant text.
    final toolSteps = <String>[];
    void setToolActivity(String toolName, {bool completed = false}) {
      // Durable step recording happens BEFORE the active guard: completed
      // steps are facts about the turn and must survive the chat being
      // backgrounded and the in-memory message being replaced on re-entry.
      // They are merged into the persisted message at finalization —
      // in-memory-only tracking is what lost them on reopen (the DB write
      // only happens when the response finalizes).
      if (completed && toolName.isNotEmpty && !toolSteps.contains(toolName)) {
        toolSteps.add(toolName);
        _backgroundTaskService.addToolStep(targetConvId, toolName);
      }
      if (!_isConversationActive(targetConvId)) return;
      final messages = _conversationProvider.messages;
      if (aiMessageIndex < 0 || aiMessageIndex >= messages.length) return;

      final message = messages[aiMessageIndex];
      final active = completed ? '' : toolName;
      if (message.toolActivity == active &&
          listEquals(message.toolSteps, toolSteps)) {
        return;
      }
      _conversationProvider.updateMessageAtIndex(
        aiMessageIndex,
        message.copyWith(
          toolActivity: active,
          toolSteps: List<String>.unmodifiable(toolSteps),
        ),
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
          'document' => MediaGenerationType.document,
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
          onTitleReceived: onTitleReceived,
          flowMode: flowMode,
        );
        // Characters exit loop immediately
        shouldContinue = false;
      } else {
        // Standard Models (Support Tools)
        final isMediaModel = modelData.category == 'image' ||
            modelData.category == 'video' ||
            modelData.category == 'audio';

        // --- [PROMPT OPTIMIZATION FOR IMAGE GENERATION] ---
        if (modelData.category == 'image' && contextMessages.isNotEmpty) {
          final lastMsg = contextMessages.last;
          if (lastMsg['role'] == 'user') {
            String? originalText;
            final content = lastMsg['content'];
            if (content is String) {
              originalText = content;
            } else if (content is List) {
              final textBlock = content.firstWhere(
                  (b) => b is Map && b['type'] == 'text',
                  orElse: () => null);
              if (textBlock != null) originalText = textBlock['text'];
            }

            if (originalText != null && originalText.isNotEmpty) {
              // Optimize to English using the cheap pipeline
              onMediaGenerating('image');
              final optimizedPrompt =
                  await _apiService.optimizeImagePrompt(originalText);
              if (optimizedPrompt != null && optimizedPrompt.isNotEmpty) {
                debugPrint("[SendService] Optimized Prompt: $optimizedPrompt");

                if (content is String) {
                  contextMessages.last['content'] = optimizedPrompt;
                } else if (content is List) {
                  for (var i = 0; i < content.length; i++) {
                    if (content[i] is Map && content[i]['type'] == 'text') {
                      content[i]['text'] = optimizedPrompt;
                      break;
                    }
                  }
                }
              }
            }
          }
        }
        // --------------------------------------------------

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
          customInstruction: _userMemoryProvider.customInstruction,
          userMemory: _userMemoryProvider.memory,
          characterRole: modelData.role,
          voiceMode: _inputProvider.isVoiceModeActive,
          featureMode: activeMode == ChatInputMode.study
              ? 'study'
              : activeMode == ChatInputMode.quiz
                  ? 'quiz'
                  : null,
          enablefeatureReasoning: enablefeatureReasoning,
          enableWebSearch: enableWebSearch,
          enableRag: ragActive,
          generationTarget: generationTarget,
          useTools: !isMediaModel && !_voiceService.isFlowActive,
          // Disable tools in Flow Mode
          flowMode: flowMode,
          onTextChunk: onTextChunk,
          onfeatureReasoning: onfeatureReasoning,
          onImageReceived: onImageReceived,
          onVideoReceived: onVideoReceived,
          onAudioReceived: onAudioReceived,
          onMediaGenerating: onMediaGenerating,
          onTitleReceived: onTitleReceived,
          // Capture Tools
          onToolCall: (tools) {
            turnToolCalls = tools;
          },
          // Live tool announcement: surface tool activity on the AI message
          // while the stream is still running, not only after stream end.
          onToolActivity: (name) {
            setToolActivity(name);
          },
          // Explicit completion contract: record the server's truncation
          // verdict for this conversation so finalization can mark the
          // message instead of persisting a cut-short response as complete.
          onStreamDone: (truncated) {
            _backgroundTaskService.setTruncated(targetConvId, truncated);
          },
          onCitations: (citations) {
            setWebSearchActive(false);
            if (_isConversationActive(targetConvId)) {
              _conversationProvider.updateLastBotMessageSources(citations);
            }
          },
          onWebSearchActive: setWebSearchActive,
          onServerFallback: () {
            if (!_isConversationActive(targetConvId)) return;
            final messages = _conversationProvider.messages;
            if (aiMessageIndex < 0 || aiMessageIndex >= messages.length) return;
            final message = messages[aiMessageIndex];
            if (!message.isServerFallback) {
              _conversationProvider.updateMessageAtIndex(
                aiMessageIndex,
                message.copyWith(isServerFallback: true),
              );
            }
          },
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
          final String callId = (call['id'] ?? '').toString();
          final function = call['function'];
          final String name = function is Map
              ? (function['name'] ?? 'tool').toString()
              : 'tool';
          final String argsStr = function is Map
              ? (function['arguments'] ?? '{}').toString()
              : '{}';

          setToolActivity(name);

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

          setToolActivity(name, completed: true);

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
        // MEMORY LIFECYCLE LOG: UserMemoryProvider (SharedPreferences) is the
        // single authoritative memory store. It is persisted, rendered and
        // editable in Settings → Memory, and injected as `userMemory` into
        // every future request. The former duplicate write into the SQLite
        // `semantic_memories` table was removed: that store had no readers
        // (SemanticMemoryService.queryRelevantMemories had zero callers), so
        // it was effectively write-only dead weight.
        debugPrint('[Memory] Lifecycle: extracted ${lines.length} fact(s) '
            'from a <memory> block -> UserMemoryProvider (persisted + '
            'injected into future prompts).');
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
    String? generationTarget,
    String? langCode,
  }) {
    String errorMessage =
        error is ApiException ? error.message : localizations.anErrorOccurred;
    final bool isContentFlagError = error is ApiException &&
        error.message == localizations.errorPromptFlagged;

    // Credit-limit conversational recovery: a typed server refusal is
    // answered with ONE natural assistant message instead of an error
    // bubble. The bubble starts as the same canonical credit copy the
    // briefing overlay uses (what happened, when it renews, what to do) and
    // is refined in place by a lightweight-model reply composed from
    // structured facts only — see `_recoverCreditRefusal`. When the client
    // credit state is too thin to be deterministic, or the refusal came from
    // a regenerate turn, the error styling with the canonical copy is kept.
    if (error is ApiException) {
      final credits = CreditsManager.instance;
      final String? deterministicCopy = creditRefusalRecoveryMessage(
        code: error.code,
        spendable: credits.spendableNotifier.value,
        debtFloor: credits.debtFloor,
        access: credits.accessNotifier.value,
        tier: credits.subscriptionTier,
        renewalRemaining: credits.nextDailyRenewal().difference(
              DateTime.now(),
            ),
        localizations: localizations,
      );
      if (deterministicCopy != null && !isRegenerate) {
        _recoverCreditRefusal(
          code: error.code ?? 'INSUFFICIENT_CREDITS',
          deterministicCopy: deterministicCopy,
          failedUserText: failedUserText ?? '',
          failedAttachmentPaths:
              failedAttachmentPaths ?? const <String>[],
          generationTarget: generationTarget,
          langCode: langCode,
        );
        return;
      }
      errorMessage = deterministicCopy ?? errorMessage;
    }

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

  /// One recovery in flight at a time, plus a dedupe key so the same refusal
  /// surfacing twice within a few seconds (double dispatch, send + regenerate
  /// overlap) inserts exactly one recovery pair.
  static bool _recoveryInFlight = false;
  static String? _lastRecoveryKey;
  static DateTime _lastRecoveryAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Credit-limit recovery for a recognized, typed server refusal.
  ///
  /// Shows the deterministic canonical copy as ONE in-context assistant
  /// message immediately (so feedback never waits on the network), then
  /// refines that same bubble in place with a natural reply composed by the
  /// backend's lightweight model from STRUCTURED FACTS ONLY — no invented
  /// prices, renewal dates, or policy, and never an answer to the original
  /// request.
  ///
  /// Safety properties: the model call goes straight to the fast endpoint
  /// (never through the send flow, so it cannot re-enter this code path and
  /// cannot recurse); it is one-shot — any failure keeps the deterministic
  /// copy with no retry and no resend of the original request; the in-flight
  /// flag and dedupe key collapse duplicate refusals into one message.
  Future<void> _recoverCreditRefusal({
    required String code,
    required String deterministicCopy,
    required String failedUserText,
    required List<String> failedAttachmentPaths,
    required String? generationTarget,
    required String? langCode,
  }) async {
    final credits = CreditsManager.instance;

    final dedupeKey = '$code|${credits.spendableNotifier.value}';
    final now = DateTime.now();
    if (_recoveryInFlight) return;
    if (_lastRecoveryKey == dedupeKey &&
        now.difference(_lastRecoveryAt) < const Duration(seconds: 3)) {
      return;
    }
    _recoveryInFlight = true;
    _lastRecoveryKey = dedupeKey;
    _lastRecoveryAt = now;

    try {
      final aiIndex = _conversationProvider.showCreditRecovery(
        Message(
          text: failedUserText,
          isUserMessage: true,
          attachmentPaths: failedAttachmentPaths,
        ),
        deterministicCopy,
      );
      if (aiIndex == null) return;

      final naturalReply = await _apiService.getCreditRecoveryMessage(
        failedUserText: failedUserText,
        operation: generationTarget ?? 'text',
        code: code,
        spendable: credits.spendableNotifier.value ?? 0,
        debtFloor: credits.debtFloor,
        access: credits.accessNotifier.value,
        tier: credits.subscriptionTier,
        renewalRemaining: credits.nextDailyRenewal().difference(
              DateTime.now(),
            ),
        langCode: langCode ?? 'en',
      );
      if (naturalReply == null || naturalReply.isEmpty) return;

      _conversationProvider.updateCreditRecoveryText(aiIndex, naturalReply);
    } finally {
      _recoveryInFlight = false;
    }
  }

  Future<void> _attachGeneratedMediaToAiMessage({
    required int aiMessageIndex,
    required String mediaPath,
    required String targetConvId,
  }) async {
    // GENERATED MEDIA PERSISTENCE LOG (item: media disappearing after app
    // restart). A local path under the app's Documents directory is durable;
    // a remote URL is NOT — MediaSaver falls back to it only when the file
    // download failed, and the URL is typically a short-lived signed CDN
    // link. Arts intentionally skips http(s) paths, so a URL fallback means
    // the item will not survive restart. This log makes the degradation
    // visible in production logs.
    if (mediaPath.startsWith('http://') || mediaPath.startsWith('https://')) {
      debugPrint('[SendService] MEDIA PERSISTENCE WARNING: generated media '
          'stored as a remote URL (local download failed) — it will render '
          'this session but will NOT survive as a local file. conv='
          '$targetConvId index=$aiMessageIndex');
    } else {
      debugPrint('[SendService] Generated media attached (conv='
          '$targetConvId, index=$aiMessageIndex, '
          'file=${mediaPath.split('/').last})');
    }
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
  }) =>
      MediaSaver.persistGeneratedMedia(
        url: url,
        dataPrefix: dataPrefix,
        allowedExtensions: allowedExtensions,
        fallbackExtension: fallbackExtension,
      );

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
      'MODERATION_UNAVAILABLE',
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

  /// Applies the server's explicit completion verdict (terminal `done` SSE
  /// event, `truncated: true`) to the in-memory AI message. Called right
  /// before `finishBotResponse` so the marker is part of the finalized
  /// message and gets persisted with it.
  void _applyStreamCompletionStatus(String convId, int aiMessageIndex) {
    if (!_backgroundTaskService.isTruncated(convId)) return;
    if (!_isConversationActive(convId)) return;
    final messages = _conversationProvider.messages;
    if (aiMessageIndex < 0 || aiMessageIndex >= messages.length) return;
    final message = messages[aiMessageIndex];
    if (message.isUserMessage || message.isError || message.isIncomplete) {
      return;
    }
    _conversationProvider.updateMessageAtIndex(
      aiMessageIndex,
      message.copyWith(isIncomplete: true),
    );
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

      // Merge the durable tool-step trace: the steps recorded in background
      // task state (facts of this turn) union whatever the DB message
      // already carried. Steps recorded only in memory were lost when the
      // user left the chat mid-tool-flow — the DB write only happens at
      // finalization.
      final mergedToolSteps = <String>{
        if (existingMsg != null) ...existingMsg.toolSteps,
        ..._backgroundTaskService.getToolSteps(convId),
      }.toList(growable: false);

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
        // Durable tool trace: steps recorded before the conversation went to
        // the background, merged with whatever the DB message already had.
        toolSteps: mergedToolSteps,
        isIncomplete: _backgroundTaskService.isTruncated(convId),
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
  Future<String> _getChatTitleForNotification(String convId) =>
      BackgroundNotifier.getChatTitle(convId);

  /// Sends a local push notification when a background chat finishes.
  void _sendBackgroundCompletionNotification(
          String convId, String chatTitle, AppLocalizations localizations) =>
      BackgroundNotifier.sendCompletionNotification(
        convId: convId,
        chatTitle: chatTitle,
        localizations: localizations,
      );
}

/// Typed server codes that mean a credit refusal. Mirrors the provider-limit
/// set in `chat/services/api.dart` — that file decides that a failure *is* a
/// credit refusal; this set decides how the refusal is worded. The two must
/// stay in step.
const Set<String> _creditRefusalCodes = {
  'INSUFFICIENT_USER_CREDITS',
  'PREDIT_EXHAUSTED',
  'DREDIT_EXHAUSTED',
  'PREMIUM_TRIAL_EXHAUSTED',
  'DYNAMIC_CREDITS_EXHAUSTED',
  'LIMIT_IMAGE_INSUFFICIENT',
  'LIMIT_VIDEO_INSUFFICIENT',
  'LIMIT_AUDIO_INSUFFICIENT',
  'LIMIT_MEDIA_INSUFFICIENT',
  'INSUFFICIENT_CREDITS',
  'INSUFFICIENT_BALANCE',
  'CREDITS_EXHAUSTED',
  'CREDIT_EXHAUSTED',
  'QUOTA_EXCEEDED',
  'PAYMENT_REQUIRED',
};

/// Whether the unified credit engine forces this send onto Dynamic Chat.
///
/// The invariant this encodes — credit restrictions ration SERVER-SIDE
/// inference only:
///
/// * credits below the `full` band + a server-side/manual selection →
///   Dynamic Chat (`cortex/auto`) answers, mirroring the gateway's
///   `manual_selection_disabled` policy for online models;
/// * credits below the `full` band + an OFFLINE selection → NEVER. Local
///   inference consumes no Fulcrum credits, so it must keep executing
///   on-device at any balance — including negative balances and the debt
///   floor — and its prompt must never be silently redirected to Cortex
///   servers through Dynamic Chat.
///
/// [selectedModelIsServerSide] is the canonical model execution property
/// (`ModelEntity.isServerSide`, i.e. `type != 'offline'`), not a fragile
/// model-ID list. Pure and side-effect free so the routing matrix is unit
/// tested directly (test/credit_routing_test.dart).
bool lowCreditsForcesDynamicChat({
  required bool canChooseModel,
  required bool selectedModelIsServerSide,
}) =>
    !canChooseModel && selectedModelIsServerSide;


/// Whether a new chat should ask the remote TitleGen flow for a title.
///
/// Online chats always try — their message path already required
/// connectivity, and the server response may deliver a title of its own.
/// OFFLINE chats also try whenever the device has internet: TitleGen is the
/// single product-defined exception to offline locality, sharing only the
/// first user message as a short title prompt while the conversation itself
/// stays fully local. With no connectivity there is nothing to ask — the
/// chat simply keeps its local fallback title. A failed TitleGen call never
/// breaks the send: the caller treats errors as non-fatal and the fallback
/// title survives. Credits are never consulted here, so the exception holds
/// at any balance, including the debt floor.
///
/// Pure and side-effect free so the matrix is unit tested directly
/// (test/credit_routing_test.dart).
bool shouldGenerateTitleRemotely({
  required bool isServerSide,
  required bool hasInternet,
}) =>
    isServerSide || hasInternet;


/// Composes the conversational recovery copy for a typed credit refusal, or
/// null when the refusal is not a credit one or the client credit state is
/// too thin to be deterministic (the caller keeps the plain limit message
/// then).
///
/// The wording is the canonical credit copy the briefing overlay uses,
/// selected by the same access bands that mirror the server's
/// `evaluateCreditPolicy`: at or below the debt floor nothing is sendable
/// until renewal (exhausted copy), below zero intelligence is degraded but
/// Dynamic Chat stays open (declining copy), and a non-negative balance means
/// the refusal was about a specific lane (media/dynamic pool) rather than the
/// daily allowance — the plain limit message already says that right.
///
/// Deterministic and side-effect free: it only reads the passed-in state and
/// only composes a string. No resend, no retry, no recursion.
String? creditRefusalRecoveryMessage({
  required String? code,
  required int? spendable,
  required int debtFloor,
  required String access,
  required String tier,
  required Duration renewalRemaining,
  required AppLocalizations localizations,
}) {
  final normalizedCode = code?.toUpperCase();
  if (normalizedCode == null ||
      !_creditRefusalCodes.contains(normalizedCode)) {
    return null;
  }

  // The premium-model trial running out is its own product story, worded
  // independently of the daily balance bands.
  if (normalizedCode == 'PREMIUM_TRIAL_EXHAUSTED') {
    return localizations.premiumTrialExhaustedMessage;
  }

  // Without a live balance snapshot any band inference would be a guess;
  // fall back to the plain limit message rather than inventing one.
  if (spendable == null) return null;

  final String renewal =
      formatRenewalRemainingLocalized(renewalRemaining, localizations);

  if (access == CreditAccess.blocked || spendable <= debtFloor) {
    // Nothing is sendable until the allowance renews. Ultra has no higher
    // plan, so its copy carries no upgrade nudge.
    return tier == 'ultra'
        ? localizations.creditWarningUltraExhaustedMessage(renewal)
        : localizations.creditWarningExhaustedMessage(renewal);
  }

  if (access == CreditAccess.lowOnly || spendable < 0) {
    // Below zero but above the floor: intelligence is degraded, the
    // conversation continues, and the tier decides the nudge.
    switch (tier) {
      case 'ultra':
        return localizations.creditWarningUltraMessage(renewal);
      case 'plus':
      case 'pro':
        return localizations.creditWarningPaidUpgradeMessage(renewal);
      default:
        return localizations.creditWarningFreeDecliningMessage(renewal);
    }
  }

  // `full` band with a positive balance: the refusal was about a specific
  // lane (media codes, dynamic pool), not the daily allowance — the generic
  // limit message is already the correct wording.
  return null;
}

