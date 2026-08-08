// lib/chat/parts/bottom.dart

import 'dart:async';
import 'dart:io';
import 'package:cortex/chat/screen/widgets/glow.dart';
import 'package:cortex/chat/screen/widgets/bottom/panels/edit.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/edit.dart';
import 'package:cortex/chat/services/review.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/send.dart';
import 'package:cortex/chat/services/stop.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/user.dart';
import 'input/input.dart';

class ChatInputPanel extends StatefulWidget {
  final EditService editService;
  final ScrollService scrollService;
  final AnimationController editPanelController;
  final Animation<Offset> slideAnimation;

  const ChatInputPanel({
    super.key,
    required this.editService,
    required this.scrollService,
    required this.editPanelController,
    required this.slideAnimation,
  });

  @override
  State<ChatInputPanel> createState() => _ChatInputPanelState();
}

class _ChatInputPanelState extends State<ChatInputPanel>
    with TickerProviderStateMixin {
  // Local controllers for the InputField
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // We use a GlobalKey to access InputField state (specifically for button enabling logic)
  final GlobalKey<InputFieldState> _inputFieldKey =
      GlobalKey<InputFieldState>();

  // Animation for warning fade inside InputField
  late AnimationController _warningController;
  late Animation<double> _warningFadeAnimation;

  // PERFORMANCE: Cache the CurvedAnimation instead of recreating in build()
  late final Animation<double> _editPanelSizeFactor;

  @override
  void initState() {
    super.initState();
    _warningController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _warningFadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_warningController);

    _editPanelSizeFactor = CurvedAnimation(
      parent: widget.editPanelController,
      curve: Curves.easeOut,
    );

    // Update EditService with local controllers so it can manipulate text
    widget.editService.updateControllers(
      controller: _textController,
      focusNode: _focusNode,
    );

    // Initialize from Global Draft
    final draft = context.read<InputProvider>().globalDraft;
    if (draft.isNotEmpty) {
      _textController.text = draft;
    }

    // Keep Global Draft synced
    _textController.addListener(() {
      context.read<InputProvider>().updateGlobalDraft(_textController.text);
    });
  }

  /// Public method to request keyboard focus on the chat input field.
  /// Called by ChatController after the initial setup pipeline completes.
  void requestKeyboardFocus() {
    if (mounted && !_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _warningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE: Use context.select with records to only rebuild when
    // the specific fields we need actually change, not on any provider notification.
    final (
      modelId,
      isDynamicChat,
      canHandleImage,
      isStorageSufficient,
      role,
      isCurrentModelPremium,
      isUserSubscribed,
      chatLimitManager,
    ) = context.select<
        ChatSessionProvider,
        (
          String?,
          bool,
          bool,
          bool,
          String?,
          bool,
          bool,
          dynamic,
        )>((s) => (
          s.modelId,
          s.isDynamicChat,
          s.canHandleImage,
          s.isStorageSufficient,
          s.role,
          s.isCurrentModelPremium,
          s.isUserSubscribed,
          s.chatLimitManager,
        ));

    final conversationProvider = context.read<ConversationProvider>();

    final (
      isVoiceMode,
      isAttachmentLoading,
      isEditingMode,
      originalMessageText,
      preselectedPhoto,
    ) = context.select<
        InputProvider,
        (
          bool,
          bool,
          bool,
          String?,
          String?,
        )>((p) {
      final atts = p.attachments;
      final photoPath = atts.isNotEmpty && atts.first.file.path.isNotEmpty
          ? atts.first.file.path
          : null;
      return (
        p.isVoiceModeActive,
        p.isAttachmentLoading,
        p.isEditingMode,
        p.originalMessageText,
        photoPath,
      );
    });

    final userTier = context.select<UserProvider, int>(
      (p) => p.activeSubscriptionLevel,
    );

    final creditsManager = context.read<CreditsManager>();
    final modelService = context.read<ModelService>();

    final isDownloaded = context.select<ModelLocalStateProvider, bool>(
      (p) => p.downloadCompleted[modelId] ?? false,
    );

    final localizations = AppLocalizations.of(context)!;

    // --- Model Status Checks ---
    final langCode = Localizations.localeOf(context).languageCode;
    final isOffline = !Utils.isServerSideModel(
      modelId,
      langCode: langCode,
      modelService: modelService,
    );

    // Check if model is missing (Only for offline non-dynamic models)
    final modelMissing = !isDynamicChat && isOffline && !isDownloaded;

    final bool isLimitExceeded =
        context.select<ConversationProvider, bool>((c) {
      return chatLimitManager?.isLimitExceeded(c.messages) ?? false;
    });

    final bool isWaitingForResponse = context
        .select<ConversationProvider, bool>((c) => c.isWaitingForResponse);

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: const IgnorePointer(child: AmbientGlow()),
        ),
        // Standard Input Panel (Slides Down)
        AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          // Slide down (hide) when voice mode is active
          offset: isVoiceMode ? const Offset(0, 1.2) : Offset.zero,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isVoiceMode ? 0.0 : 1.0,
            child: SizeChangedLayoutNotifier(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Edit Panel (Slides down when editing)
                  SizeTransition(
                    sizeFactor: _editPanelSizeFactor,
                    axis: Axis.vertical,
                    child: EditPanelWidget(
                      slideAnimation: widget.slideAnimation,
                      onCancel: () {
                        widget.editService.cancelEditingMode();
                        widget.scrollService.updateButtonVisibility();
                      },
                    ),
                  ),

                  // 2. Main Input Field
                  // Wrapped in ValueListenableBuilders so that credit changes
                  // (e.g. after account switch) reactively rebuild the input.
                  ValueListenableBuilder<int?>(
                    valueListenable: creditsManager.totalCreditsNotifier,
                    builder: (context, totalCredits, _) {
                      return ValueListenableBuilder<int?>(
                        valueListenable: creditsManager.preditsNotifier,
                        builder: (context, availablePredits, _) {
                          return ValueListenableBuilder<int?>(
                            valueListenable: creditsManager.dreditsNotifier,
                            builder: (context, availableDredits, _) {
                              return InputField(
                                key: _inputFieldKey,
                                localizations: localizations,
                                isDynamicChatMode: isDynamicChat,
                                isModelSelected: true,
                                isLimitExceeded: isLimitExceeded,
                                isPhotoLoading: isAttachmentLoading,
                                isSending: isWaitingForResponse,
                                canHandleImage:
                                    isDynamicChat ? true : canHandleImage,
                                isEditingMode: isEditingMode,
                                originalMessageText: originalMessageText,
                                // Legacy photo support for UI
                                preselectedPhoto: preselectedPhoto != null
                                    ? File(preselectedPhoto)
                                    : null,
                                isStorageSufficient: isStorageSufficient,
                                modelMissing: modelMissing,
                                role: role,
                                isPremiumModel: isDynamicChat
                                    ? false
                                    : isCurrentModelPremium,
                                isSubscribed: isUserSubscribed,
                                userTier: userTier,
                                isServerSideModel: Utils.isServerSideModel(
                                  modelId,
                                  langCode: langCode,
                                  modelService: modelService,
                                ),
                                totalCredits: totalCredits,
                                availablePredits: availablePredits,
                                availableDredits: availableDredits,
                                controller: _textController,
                                textFieldFocusNode: _focusNode,
                                slideAnimation: widget.slideAnimation,
                                fadeAnimation: _warningFadeAnimation,

                                // --- Actions ---
                                onSend: () async => _handleSend(
                                    localizations,
                                    isLimitExceeded,
                                    langCode,
                                    modelService,
                                    context.read<InputProvider>(),
                                    conversationProvider),
                                onApplyEditedMessage: () async => await widget
                                    .editService
                                    .applyEditedMessage(context),
                                onStop: () {
                                  final voiceService =
                                      context.read<VoiceService>();
                                  if (voiceService.isFlowActive) {
                                    // [NEW] Flow Mode: Pause & Listen (Interruption)
                                    voiceService.interruptFlowAndListen();
                                    // Stop any text generation but keep session alive
                                    context
                                        .read<ConversationProvider>()
                                        .stopGenerating();
                                  } else {
                                    // Standard Mode: Stop Everything
                                    context.read<StopService>().stopResponse();
                                  }
                                },
                                // Logic Update: Null check before adding
                                onPhotoSelected: (photo) {
                                  if (photo != null) {
                                    context
                                        .read<InputProvider>()
                                        .addAttachment(photo, isImage: true);
                                  }
                                },
                                onCancelEditing: () {
                                  widget.editService.cancelEditingMode();
                                  widget.scrollService.updateButtonVisibility();
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Logic Helpers ---

  Future<void> _handleSend(
    AppLocalizations localizations,
    bool isLimitExceeded,
    String langCode,
    ModelService modelService,
    InputProvider inputProvider,
    ConversationProvider conversationProvider,
  ) async {
    // Basic validation
    final isEnabled = _inputFieldKey.currentState?.isSendButtonEnabled ?? false;
    if (!isEnabled || conversationProvider.isWaitingForResponse) return;
    if (isLimitExceeded) return;

    // A. Apply Edit
    if (inputProvider.isEditingMode) {
      await widget.editService.applyEditedMessage(context);
      return;
    }

    // B. Send New Message
    final String messageText = _textController.text;

    // Define sessionProvider first
    final sessionProvider = context.read<ChatSessionProvider>();
    final isServerSide = Utils.isServerSideModel(
      sessionProvider.modelId,
      langCode: langCode,
      modelService: modelService,
    );

    final sendService = context.read<SendService>();
    final userProvider = context.read<UserProvider>();
    if (userProvider.isAnonymous) {
      final canSend = await sendService.checkGuestLimit(context, localizations);
      if (!mounted) return;
      if (!canSend) return;
    }

    // InputProvider clears attachments inside SendService, but we unfocus here
    FocusScope.of(context).unfocus();
    // Send Logic
    debugPrint(
        "ChatInputPanel: Sending message. Text length: ${messageText.length}. Attachments: ${inputProvider.attachments.length}");
    final sendFuture = sendService.sendMessage(
      context: context,
      localizations: localizations,
      messageText: messageText,
    );

    // UI Cleanup AFTER initiating send
    _textController.clear();
    inputProvider
        .clearAfterSend(); // Clears draft and attachments, persists toggles

    // Post-Send Review Triggers
    if (isServerSide) {
      sendFuture.then((success) {
        if (success && mounted) {
          unawaited(ReviewService().triggerReviewPromptIfNeeded(context));
        }
      });
    } else {
      _attachOfflineReviewListener(conversationProvider);
    }
  }

  void _attachOfflineReviewListener(ConversationProvider conversationProvider) {
    if (!conversationProvider.isWaitingForResponse) return;

    late VoidCallback listener;
    listener = () {
      if (!mounted) {
        conversationProvider.removeListener(listener);
        return;
      }
      if (!conversationProvider.isWaitingForResponse) {
        conversationProvider.removeListener(listener);
        unawaited(ReviewService().triggerReviewPromptIfNeeded(context));
      }
    };
    conversationProvider.addListener(listener);
  }
}
