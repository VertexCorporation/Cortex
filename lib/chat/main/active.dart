// lib/chat/main/active.dart
//
// This file defines the ActiveChatView widget, which is responsible for rendering
// the entire UI when a chat session is active. It manages the state specific to an
// ongoing conversation, such as the message list's scroll controller, the text input
// field's controllers, and UI animations. It orchestrates the composition of
// child widgets like the message list (`SelectedScreen`) and the input area (`InputField`).

import 'dart:async';
import 'dart:io';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/appbar/premium.dart';
import 'package:cortex/chat/screen/selected/input/input.dart';
import 'package:cortex/chat/screen/selected/input/panels/briefing.dart';
import 'package:cortex/chat/screen/selected/screen.dart';
import 'package:cortex/chat/services/edit.dart';
import 'package:cortex/chat/services/load.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/review.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/send.dart';
import 'package:cortex/chat/services/stop.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../extensions.dart';
import '../../funds/funds.dart';
import '../../l10n/app_localizations.dart';
import '../../navigation.dart';
import '../../server/credits.dart';
import 'package:cortex/chat/services/utils.dart';

import '../messages/report.dart';
import '../messages/skeleton.dart';
import '../screen/selected/input/panels/edit.dart';

/// A stateful widget that displays the active chat interface.
class ActiveChatView extends StatefulWidget {
  final void Function(bool isSelected)? onModelSelectionChanged;
  final Extensions extensions;

  const ActiveChatView({
    super.key,
    required this.onModelSelectionChanged,
    required this.extensions,
  });

  @override
  ActiveChatViewState createState() => ActiveChatViewState();
}

/// The state for ActiveChatView. It owns and manages all controllers, services,
/// and UI logic required for an active conversation.
class ActiveChatViewState extends State<ActiveChatView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // All these controllers and keys are specific to the active chat view.
  // They manage the text input, focus, scrolling, and animations of the chat UI,
  // so they belong in this state, not the parent controller.
  final TextEditingController controller = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  final GlobalKey<InputFieldState> inputFieldKey = GlobalKey<InputFieldState>();
  final GlobalKey _inputSectionKey = GlobalKey();
  final GlobalKey _briefingOverlayKey = GlobalKey();

  // These animation controllers are for UI effects (edit panel, warnings)
  // that only appear in the active chat view.
  late AnimationController editPanelController;
  late AnimationController warningAnimationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> warningFadeAnimation;

  // EditService is a specialized service that directly manipulates the input
  // field's state and message list. It's only needed here, so we initialize it here.
  late final EditService editService;
  // Caching the ScrollService instance to avoid using context in dispose().
  late final ScrollService _scrollService;

  // These notifiers and local flags manage transient UI state like
  // button visibility and overlay heights, which are irrelevant when no chat is active.
  final ValueNotifier<bool> showScrollDownButtonNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> inputSectionHeightNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> briefingOverlayHeightNotifier = ValueNotifier<double>(0.0);
  final bool _showInappropriateContentWarning = false;
  bool _showPhotoModelWarning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scrollService = context.read<ScrollService>();
    final conversationProvider = context.read<ConversationProvider>();

    // Setting the global ScrollService's controller is the responsibility
    // of the view that owns the ScrollController instance.
    _scrollService.setController(scrollController);

    _scrollService.attachListener(
      notifier: showScrollDownButtonNotifier,
      messageCountProvider: () => conversationProvider.messages.length,
    );

    // Initialize all animation controllers.
    editPanelController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    warningAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: editPanelController, curve: Curves.easeOut));
    warningFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(warningAnimationController);

    // Initialize the EditService with necessary dependencies from providers and this state.

    editService = EditService(
      inputProvider: context.read<InputProvider>(),
      conversationProvider: context.read<ConversationProvider>(),
      regenerateService: context.read<RegenerateService>(),
      scrollService: context.read<ScrollService>(),
      controller: controller,
      focusNode: textFieldFocusNode,
      panelController: editPanelController,
    );

    // When this view is first built, it signifies a chat has become active.
    // We notify the parent controller to update the main app UI (e.g., hide bottom bar)
    // and immediately focus the text field for a seamless user experience.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateInputSectionHeight();
        _scrollService.jumpToBottom();
        widget.onModelSelectionChanged?.call(true);
      }
    });
  }

  /// Public method to allow the parent controller to programmatically focus the text field.
  void focusTextField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) {
        textFieldFocusNode.requestFocus();
      }
    });
  }

  /// Public method for the parent controller to command this view to clear its controllers.
  /// This is essential for a clean state transition when exiting a chat.
  void clearControllers() {
    controller.clear();
    textFieldFocusNode.unfocus();
  }

  void cancelAnyActiveEdit() {
    if (mounted && context.read<InputProvider>().isEditingMode) {
      editService.cancelEditingMode();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    controller.dispose();
    textFieldFocusNode.dispose();
    scrollController.dispose();
    editPanelController.dispose();
    warningAnimationController.dispose();
    _scrollService.detachListener();

    super.dispose();
  }

  // Metrics changes (like keyboard visibility) affect the layout of the
  // active chat. This state listens for those changes to update its layout-dependent
  // components, like the BriefingOverlay's position.
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollService.updateButtonVisibility();
        _updateInputSectionHeight();
      }
    });
  }

  /// Calculates and updates the height of the input section, notifying listeners.
  void _updateInputSectionHeight() {
    final RenderBox? box = _inputSectionKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final newHeight = box.size.height;
      if (inputSectionHeightNotifier.value != newHeight) {
        inputSectionHeightNotifier.value = newHeight;
      }
    }
  }

  /// Navigates to the premium purchase screen.
  void _navigateToPremiumScreen() {
    FocusScope.of(context).unfocus();
    navigateToScreen(context, const FundsScreen(), direction: const Offset(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    // Watch all necessary providers at the top of the build method.
    final sessionProvider = context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();
    final inputProvider = context.watch<InputProvider>();
    final creditsManager = context.watch<CreditsManager>();

    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // The entire UI for an active chat is built here. It's a composition of the
    // message list, the input section, and various overlays. This keeps the parent
    // controller's build method extremely simple.
    return Stack(
      children: [
        SafeArea(
          bottom: true,
          child: Column(
            children: [
              Expanded(
                child: _buildChatContent(localizations),
              ),
              _buildInputSectionWrapper(),
            ],
          ),
        ),

        PremiumModelBanner(
          isVisible: sessionProvider.showPremiumBanner,
          onTap: _navigateToPremiumScreen,
        ),
        AnimatedBuilder(
          // The animation property listens to any change in the merged our guys.
          animation: Listenable.merge([
            showScrollDownButtonNotifier,
            inputSectionHeightNotifier,
            briefingOverlayHeightNotifier,
          ]),
          builder: (context, child) {
            // Get the latest values directly from the notifiers inside the builder.
            final bool showButton = showScrollDownButtonNotifier.value;
            final double inputHeight = inputSectionHeightNotifier.value;
            final double briefingHeight = briefingOverlayHeightNotifier.value;

            return Stack(
              children: [
                // Position the ScrollDownButton.
                _scrollService.buildScrollDownButton(
                  screenWidth: screenWidth,
                  inputFieldHeight: inputHeight + briefingHeight,
                  showScrollDownButton: showButton,
                  safeAreaBottomPadding: bottomPadding,
                ),

                // Position the BriefingOverlay.
                if (sessionProvider.isChatActive && !widget.extensions.isPanelVisible)
                  Positioned(
                    // Use the notifier's value to dynamically position the overlay.
                    bottom: inputHeight + bottomPadding + 12,
                    left: 16,
                    right: 16,
                    child: BriefingOverlay(
                      key: _briefingOverlayKey,
                      heightNotifier: briefingOverlayHeightNotifier,
                      availableCredits: creditsManager.totalCreditsNotifier.value,
                      photoSelected: inputProvider.selectedPhoto != null,
                      isOfflineModel: Utils.isLocalModel(sessionProvider.modelId),
                      modelPath: sessionProvider.modelPath,
                      limitReached: sessionProvider.chatLimitManager
                          ?.isLimitExceeded(conversationProvider.messages) ??
                          false,
                      isStorageSufficient: sessionProvider.isStorageSufficient,
                      showDisclaimer: sessionProvider.showDisclaimer,
                      isPremiumModel: sessionProvider.showPremiumBanner,
                      isSubscribed: sessionProvider.isUserSubscribed,
                      premiumTrialUses: sessionProvider.premiumTrialUses,
                      inappropriate: _showInappropriateContentWarning,
                      showPhotoWarning: _showPhotoModelWarning,
                      onDisclaimerDismissed: () {
                        if (mounted) {
                          context.read<ChatSessionProvider>().dismissDisclaimer();
                          setState(() => _showPhotoModelWarning = false);
                        }
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Builds the main content area for messages.
  Widget _buildChatContent(AppLocalizations localizations) {
    // Read from both providers here to have all necessary data.
    final conversationProvider = context.watch<ConversationProvider>();
    final sessionProvider = context.watch<ChatSessionProvider>(); // <-- ADD THIS WATCH

    if (conversationProvider.isLoadingMessages) {
      return const MessageListSkeleton(key: ValueKey('messages_skeleton'));
    }

    // This view is responsible for connecting the high-level services (Stop,
    // Edit, Regenerate) to the actual UI components in SelectedScreen via callbacks.
    return SelectedScreen(
      key: const ValueKey('selected_screen'),
      scrollController: scrollController,
      onStop: context.read<StopService>().stopResponse,
      onEdit: (index) => editService.startEditingMessage(index),
      onFadeOutComplete: (index) => context.read<ConversationProvider>().removeMessageAtIndex(index),

      onRegenerate: (index) {
        final regenerateService = context.read<RegenerateService>();
        // Now, we correctly read the dynamic status from the session provider
        // and pass it to the onRegenerate method.
        final bool isDynamic = sessionProvider.isDynamicChat;

        regenerateService.onRegenerate(
          index,
          context: context,
          localizations: localizations,
          isDynamicRegenerate: isDynamic,
        );
      },
      onChangeModel: (index, newFullId) {
        final regenerateService = context.read<RegenerateService>();
        final bool isDynamic = sessionProvider.isDynamicChat;

        regenerateService.onRegenerate(
          index,
          context: context,
          localizations: localizations,
          newModelId: newFullId,
          isDynamicRegenerate: isDynamic, // Also pass it here for consistency
        );
      },

      onReport: (index) {
        final messages = conversationProvider.messages;
        // The modelId can be null in dynamic chat, so we need a fallback.
        // We get it from the message itself.
        final modelId = messages[index].model;
        if (modelId == null) return;
        ReportDialog.show(context, aiMessage: messages[index].text, modelId: modelId,
          onReportSuccess: () {
            if (mounted) {
              final updatedMessage = messages[index].copyWith(isReported: true);
              conversationProvider.updateMessageAtIndex(index, updatedMessage);
              if (conversationProvider.conversationID != null) {
                ChatStorageService.updateStoredMessage(conversationProvider.conversationID!, updatedMessage, index);
              }
            }
          },
        );
      },
    );
  }

  /// Wraps the input section with listeners to update its height dynamically.
  Widget _buildInputSectionWrapper() {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateInputSectionHeight());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        key: _inputSectionKey,
        child: _buildInputSection(),
      ),
    );
  }

  /// Builds the complete input section, including the edit panel and the input field.
  Widget _buildInputSection() {
    // Read data from all three providers to configure the InputField.
    final sessionProvider = context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();
    final inputProvider = context.watch<InputProvider>();
    final creditsManager = context.watch<CreditsManager>();

    final isOffline = !Utils.isServerSideModel(sessionProvider.modelId);
    final modelMissing = !sessionProvider.isDynamicChat && isOffline && !context.read<LoadService>().isModelOnDisk(sessionProvider.modelPath);
    final bool isLimitExceeded = sessionProvider.chatLimitManager?.isLimitExceeded(conversationProvider.messages) ?? false;
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: editPanelController,
            curve: Curves.easeOut,
          ),
          axis: Axis.vertical,
          child: EditPanelWidget(
            slideAnimation: slideAnimation,
            onCancel: editService.cancelEditingMode,
          ),
        ),
        InputField(
          key: inputFieldKey,
          localizations: localizations,
          isDynamicChatMode: sessionProvider.isDynamicChat,
          isModelSelected: sessionProvider.isModelSelected,
          isLimitExceeded: isLimitExceeded,
          isPhotoLoading: inputProvider.isPhotoLoading,
          isSending: conversationProvider.isWaitingForResponse,
          canHandleImage: sessionProvider.isDynamicChat ? true : sessionProvider.canHandleImage,
          isEditingMode: inputProvider.isEditingMode,
          originalMessageText: inputProvider.originalMessageText,
          preselectedPhoto: inputProvider.selectedPhoto,
          isStorageSufficient: sessionProvider.isStorageSufficient,
          modelMissing: modelMissing,
          role: sessionProvider.role,
          isPremiumModel: sessionProvider.showPremiumBanner,
          isSubscribed: sessionProvider.isUserSubscribed,
          premiumTrialUses: sessionProvider.premiumTrialUses,
          isServerSideModel: Utils.isServerSideModel(sessionProvider.modelId),
          totalCredits: creditsManager.totalCreditsNotifier.value ?? 0,
          controller: controller,
          textFieldFocusNode: textFieldFocusNode,
          slideAnimation: slideAnimation,
          fadeAnimation: warningFadeAnimation,
          onSend: () async {
            if ((inputFieldKey.currentState?.isSendButtonEnabled ?? false) && !conversationProvider.isWaitingForResponse) {
              if (isLimitExceeded) return;

              if (inputProvider.isEditingMode) {
                await editService.applyEditedMessage(context);
              } else {
                final String messageText = controller.text;
                final File? photo = inputProvider.selectedPhoto;
                controller.clear();
                inputFieldKey.currentState?.clearPhotoPanel();
                FocusScope.of(context).unfocus();

                context.read<SendService>().sendMessage(
                  context: context,
                  localizations: localizations,
                  messageText: messageText,
                  photo: photo,
                ).then((success) {
                  if (success && mounted) {
                    unawaited(ReviewService().triggerReviewPromptIfNeeded(context));
                  }
                });
              }
            }
          },
          onApplyEditedMessage: () async => await editService.applyEditedMessage(context),
          onStop: context.read<StopService>().stopResponse,
          onPhotoSelected: (photo) => context.read<InputProvider>().selectPhoto(photo),
          onCancelEditing: editService.cancelEditingMode,
        ),
      ],
    );
  }
}