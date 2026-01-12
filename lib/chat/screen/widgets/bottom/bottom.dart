// lib/chat/parts/bottom.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Internal Imports ---
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
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/server/credits.dart';

import 'input/input.dart';
import 'input/panels/edit.dart';

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

class _ChatInputPanelState extends State<ChatInputPanel> with TickerProviderStateMixin {
  // Local controllers for the InputField
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<InputFieldState> _inputFieldKey = GlobalKey<InputFieldState>();

  // Animation for warning fade inside InputField
  late AnimationController _warningController;
  late Animation<double> _warningFadeAnimation;

  @override
  void initState() {
    super.initState();
    _warningController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _warningFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_warningController);

    // Update EditService with local controllers so it can manipulate text
    widget.editService.updateControllers(
      controller: _textController,
      focusNode: _focusNode,
    );
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
    final sessionProvider = context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();
    final inputProvider = context.watch<InputProvider>();
    final creditsManager = context.watch<CreditsManager>();
    final modelService = context.read<ModelService>();
    final localStateProvider = context.watch<ModelLocalStateProvider>();
    final localizations = AppLocalizations.of(context)!;

    // --- Model Status Checks ---
    final langCode = Localizations.localeOf(context).languageCode;
    final isOffline = !Utils.isServerSideModel(
      sessionProvider.modelId,
      langCode: langCode,
      modelService: modelService,
    );

    final bool isDownloaded =
        localStateProvider.downloadCompleted[sessionProvider.modelId] ?? false;

    // Check if model is missing (Only for offline non-dynamic models)
    final modelMissing = !sessionProvider.isDynamicChat && isOffline && !isDownloaded;

    final bool isLimitExceeded = sessionProvider.chatLimitManager
        ?.isLimitExceeded(conversationProvider.messages) ?? false;

    // We wrap the column in SizeChangedLayoutNotifier so the parent (View)
    // knows when the panel grows/shrinks (e.g. keyboard open, edit panel open).
    return SizeChangedLayoutNotifier(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Edit Panel (Slides down when editing)
          SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: widget.editPanelController,
              curve: Curves.easeOut,
            ),
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
          InputField(
            key: _inputFieldKey,
            localizations: localizations,
            isDynamicChatMode: sessionProvider.isDynamicChat,
            isModelSelected: true,
            isLimitExceeded: isLimitExceeded,
            isPhotoLoading: inputProvider.isPhotoLoading,
            isSending: conversationProvider.isWaitingForResponse,
            canHandleImage: sessionProvider.isDynamicChat
                ? true
                : sessionProvider.canHandleImage,
            isEditingMode: inputProvider.isEditingMode,
            originalMessageText: inputProvider.originalMessageText,
            preselectedPhoto: inputProvider.selectedPhoto,
            isStorageSufficient: sessionProvider.isStorageSufficient,
            modelMissing: modelMissing,
            role: sessionProvider.role,
            isPremiumModel: sessionProvider.isCurrentModelPremium,
            isSubscribed: sessionProvider.isUserSubscribed,
            premiumTrialUses: sessionProvider.premiumTrialUses,
            isServerSideModel: Utils.isServerSideModel(
              sessionProvider.modelId,
              langCode: langCode,
              modelService: modelService,
            ),
            totalCredits: creditsManager.totalCreditsNotifier.value ?? 0,
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
                inputProvider,
                conversationProvider
            ),
            onApplyEditedMessage: () async =>
            await widget.editService.applyEditedMessage(context),
            onStop: context.read<StopService>().stopResponse,
            onPhotoSelected: (photo) =>
                context.read<InputProvider>().selectPhoto(photo),
            onCancelEditing: () {
              widget.editService.cancelEditingMode();
              widget.scrollService.updateButtonVisibility();
            },
          ),
        ],
      ),
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
    final File? photo = inputProvider.selectedPhoto;

    // UI Cleanup
    _textController.clear();
    _inputFieldKey.currentState?.clearPhotoPanel();
    FocusScope.of(context).unfocus();

    final sessionProvider = context.read<ChatSessionProvider>();
    final isServerSide = Utils.isServerSideModel(
      sessionProvider.modelId,
      langCode: langCode,
      modelService: modelService,
    );

    // Send Logic
    final sendFuture = context.read<SendService>().sendMessage(
      context: context,
      localizations: localizations,
      messageText: messageText,
      photo: photo,
    );

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