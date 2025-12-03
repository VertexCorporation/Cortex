// lib/chat/main/active.dart
//
// ACTIVE CHAT VIEW — FLOATING BRIEFING + SMART SCROLL BUTTON
//
// What changed (high level):
// - The BriefingOverlay is NO LONGER inside the input/bottom panel Column.
//   It is now a true floating layer (Positioned in the root Stack), so it
//   does not reserve layout height or push anything.
// - We track two heights:
//     (a) base bottom panel height (edit panel + input field),
//     (b) floating briefing visible height (animation + drag aware).
//   The scroll-to-bottom button sits above the *sum* of these heights, so it
//   follows the briefing as you drag it down.
// - No behavioral changes to send/edit flows; only layout + positioning logic.

import 'dart:async';
import 'dart:io';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/appbar/premium.dart';
import 'package:cortex/chat/screen/selected/screen.dart';
import 'package:cortex/chat/services/edit.dart';
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
import '../../library/backend/data/service.dart';
import '../../library/providers/local.dart';
import '../../login/upgrade.dart';
import '../../navigation.dart';
import '../../server/credits.dart';
import 'package:cortex/chat/services/utils.dart';
import '../../server/user.dart';
import '../messages/options/report.dart';
import '../messages/skeleton.dart';
import '../messages/tiles/ai.dart';
import '../screen/selected/widgets/input/input.dart';
import '../screen/selected/widgets/input/panels/briefing.dart';
import '../screen/selected/widgets/input/panels/edit.dart';
import '../services/offline.dart';

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

class ActiveChatViewState extends State<ActiveChatView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Controllers/keys for the chat UI.
  final TextEditingController controller = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  final GlobalKey<InputFieldState> inputFieldKey = GlobalKey<InputFieldState>();

  // Measures the ENTIRE bottom panel area (edit panel + input) — excludes briefing.
  final GlobalKey _bottomPanelKey = GlobalKey();

  // Animations for edit panel and generic warning fade (used by InputField).
  late AnimationController editPanelController;
  late AnimationController warningAnimationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> warningFadeAnimation;

  // Services.
  late final EditService editService;
  late final ScrollService _scrollService;
  late final OfflineService _offlineService;

  // Notifiers:
  // 1) Should the scroll-down button show?
  final ValueNotifier<bool> showScrollDownButtonNotifier =
  ValueNotifier<bool>(false);
  // 2) Measured height of the base bottom panel (edit + input) — dynamic.
  final ValueNotifier<double> bottomPanelHeightNotifier =
  ValueNotifier<double>(0.0);
  // 3) *Visible* height of the floating Briefing overlay — dynamic (animation + drag).
  final ValueNotifier<double> briefingVisibleHeightNotifier =
  ValueNotifier<double>(0.0);
  static const double _briefingBottomOffset = 8.0;

  // Other state.
  final bool _showInappropriateContentWarning = false;
  bool _showPhotoModelWarning = false;
  String? _lastActiveOfflineModelId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scrollService = context.read<ScrollService>();
    _offlineService = context.read<OfflineService>();
    final sessionProvider = context.read<ChatSessionProvider>();
    final conversationProvider = context.read<ConversationProvider>();

    _scrollService.setController(scrollController);
    _scrollService.attachListener(
      notifier: showScrollDownButtonNotifier,
      messageCountProvider: () => conversationProvider.messages.length,
    );

    editPanelController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    warningAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: editPanelController, curve: Curves.easeOut));
    warningFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(warningAnimationController);

    editService = EditService(
      inputProvider: context.read<InputProvider>(),
      conversationProvider: context.read<ConversationProvider>(),
      regenerateService: context.read<RegenerateService>(),
      scrollService: context.read<ScrollService>(),
      controller: controller,
      focusNode: textFieldFocusNode,
      panelController: editPanelController,
    );

    _handleModelChange(sessionProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateBottomPanelHeight();
        _scrollService.jumpToBottom();
        widget.onModelSelectionChanged?.call(true);
      }
    });
  }

  void focusTextField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        textFieldFocusNode.requestFocus();
      }
    });
  }

  void clearControllers() {
    controller.clear();
    textFieldFocusNode.unfocus();
  }

  void cancelAnyActiveEdit() {
    if (mounted && context.read<InputProvider>().isEditingMode) {
      editService.cancelEditingMode();
    }
  }

  void _handleModelChange(ChatSessionProvider session) {
    final modelService = context.read<ModelService>();
    final langCode = session.getLocale().languageCode;
    final newModelId = session.modelId;
    final newModelPath = session.modelPath;

    if (_lastActiveOfflineModelId == newModelId) return;

    if (_lastActiveOfflineModelId != null &&
        _lastActiveOfflineModelId != newModelId) {
      _offlineService.releaseModel();
    }

    final isNewModelOffline = newModelId != null &&
        !Utils.isServerSideModel(newModelId,
            langCode: langCode, modelService: modelService);

    if (isNewModelOffline && newModelPath != null && newModelPath.isNotEmpty) {
      _offlineService.cacheModel(newModelPath);
      _lastActiveOfflineModelId = newModelId;
    } else {
      _lastActiveOfflineModelId = null;
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

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollService.updateButtonVisibility();
      _updateBottomPanelHeight();
    });
  }

  void _updateBottomPanelHeight() {
    final RenderBox? box =
    _bottomPanelKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final newHeight = box.size.height;
      if (bottomPanelHeightNotifier.value != newHeight) {
        bottomPanelHeightNotifier.value = newHeight;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<ChatSessionProvider>();
    final localizations = AppLocalizations.of(context)!;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bottomSafe = mediaQuery.padding.bottom;
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0.0;

    return Stack(
      children: [
        // LAYER 1: Main content (messages + base bottom panel).
        SafeArea(
          bottom: true,
          child: Column(
            children: [
              Expanded(
                child: _buildChatContent(localizations),
              ),
              _buildBottomPanelWrapper(),
            ],
          ),
        ),

        // LAYER 2: Premium banner.
        PremiumModelBanner(
          isVisible: sessionProvider.showPremiumBanner,
          onDismiss: () {
            context.read<ChatSessionProvider>().dismissPremiumBanner();
          },
          onTap: () {
            final isAnonymous = context.read<UserProvider>().isAnonymous;

            if (isAnonymous) {
              navigateToScreen(const UpgradeAccountScreen(), direction: const Offset(0.0, 1.0));
              FocusScope.of(context).unfocus();
            } else {
              navigateToScreen(const FundsScreen(), direction: const Offset(0.0, 1.0));
              FocusScope.of(context).unfocus();
            }
          },
        ),

        // LAYER 3: Floating briefing overlay
        AnimatedBuilder(
          animation: bottomPanelHeightNotifier,
          builder: (context, _) {
            final basePanelHeight = bottomPanelHeightNotifier.value;
            const horizontalPadding = 16.0;

            final bool shouldBeVisible = sessionProvider.isChatActive;

            return Positioned(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: basePanelHeight + bottomSafe + _briefingBottomOffset,
              child: BriefingOverlay(
                isVisible: shouldBeVisible,
                availableCredits:
                context.watch<CreditsManager>().totalCreditsNotifier.value,
                photoSelected:
                context.watch<InputProvider>().selectedPhoto != null,
                isOfflineModel: _isOfflineCurrentModel(context),
                modelMissing: _isModelMissing(context),
                limitReached: _isLimitExceeded(context),
                isStorageSufficient:
                context.watch<ChatSessionProvider>().isStorageSufficient,
                showDisclaimer:
                context.watch<ChatSessionProvider>().showDisclaimer,
                isPremiumModel:
                context.watch<ChatSessionProvider>().isCurrentModelPremium,
                isSubscribed:
                context.watch<ChatSessionProvider>().isUserSubscribed,
                premiumTrialUses:
                context.watch<ChatSessionProvider>().premiumTrialUses,
                inappropriate: _showInappropriateContentWarning,
                showPhotoWarning: _showPhotoModelWarning,
                onDisclaimerDismissed: () {
                  if (mounted) {
                    context.read<ChatSessionProvider>().dismissDisclaimer();
                    setState(() => _showPhotoModelWarning = false);
                  }
                },
                onVisibleHeightChanged: (h) {
                  if (briefingVisibleHeightNotifier.value != h) {
                    briefingVisibleHeightNotifier.value = h;
                  }
                },
                isDynamicChat: sessionProvider.isDynamicChat,
              ),
            );
          },
        ),

        // LAYER 4: Scroll-to-bottom button — now correctly compensates keyboard height.
        AnimatedBuilder(
          animation: Listenable.merge([
            showScrollDownButtonNotifier,
            bottomPanelHeightNotifier,
            briefingVisibleHeightNotifier,
          ]),
          builder: (context, child) {
            final bool showButton = showScrollDownButtonNotifier.value;
            final double basePanel = bottomPanelHeightNotifier.value;
            final double briefingH = briefingVisibleHeightNotifier.value;

            // This is the vertical size of everything sitting directly
            // above the very bottom of the *content area*:
            //   edit panel + input + (optional) briefing + small gap.
            final double combinedPanelHeight =
                basePanel + briefingH + _briefingBottomOffset;

            return _scrollService.buildScrollDownButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              bottomPanelHeight: combinedPanelHeight,
              showScrollDownButton: showButton,
              safeAreaBottomPadding: bottomSafe,
              isKeyboardOpen: isKeyboardOpen,
              keyboardHeight: keyboardHeight,
            );
          },
        ),
      ],
    );
  }

  // ---------------- Bottom Panel (base) ----------------

  Widget _buildBottomPanelWrapper() {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _updateBottomPanelHeight());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        key: _bottomPanelKey,
        child: _buildBottomPanel(),
      ),
    );
  }

  /// The base bottom panel: Edit panel + InputField.
  Widget _buildBottomPanel() {
    // Read from all providers needed here.
    final sessionProvider = context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();
    final inputProvider = context.watch<InputProvider>();
    final creditsManager = context.watch<CreditsManager>();
    final modelService = context.read<ModelService>();
    final localStateProvider = context.watch<ModelLocalStateProvider>();

    final langCode = Localizations.localeOf(context).languageCode;
    final isOffline = !Utils.isServerSideModel(
      sessionProvider.modelId,
      langCode: langCode,
      modelService: modelService,
    );

    final bool isDownloaded =
        localStateProvider.downloadCompleted[sessionProvider.modelId] ?? false;
    final modelMissing =
        !sessionProvider.isDynamicChat && isOffline && !isDownloaded;

    final bool isLimitExceeded = sessionProvider.chatLimitManager
        ?.isLimitExceeded(conversationProvider.messages) ??
        false;

    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // EDIT PANEL (slides within the base panel space)
        SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: editPanelController,
            curve: Curves.easeOut,
          ),
          axis: Axis.vertical,
          child: EditPanelWidget(
            slideAnimation: slideAnimation,
            onCancel: () {
              // 1) Exit editing mode
              editService.cancelEditingMode();
              // 2) Re-evaluate scroll-down button visibility.
              //    If the user is not at the bottom and there are enough messages,
              //    the button will show itself again automatically.
              _scrollService.updateButtonVisibility();
            },
          ),
        ),

        // INPUT FIELD
        InputField(
          key: inputFieldKey,
          localizations: localizations,
          isDynamicChatMode: sessionProvider.isDynamicChat,
          isModelSelected: sessionProvider.isModelSelected,
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
          controller: controller,
          textFieldFocusNode: textFieldFocusNode,
          slideAnimation: slideAnimation,
          fadeAnimation: warningFadeAnimation,
          onSend: () async {
            if ((inputFieldKey.currentState?.isSendButtonEnabled ?? false) &&
                !conversationProvider.isWaitingForResponse) {
              if (isLimitExceeded) return;

              if (inputProvider.isEditingMode) {
                await editService.applyEditedMessage(context);
              } else {
                final String messageText = controller.text;
                final File? photo = inputProvider.selectedPhoto;
                controller.clear();
                inputFieldKey.currentState?.clearPhotoPanel();
                FocusScope.of(context).unfocus();

                final isServerSide = Utils.isServerSideModel(
                  sessionProvider.modelId,
                  langCode: langCode,
                  modelService: modelService,
                );

                final sendFuture = context.read<SendService>().sendMessage(
                  context: context,
                  localizations: localizations,
                  messageText: messageText,
                  photo: photo,
                );

                if (isServerSide) {
                  sendFuture.then((success) {
                    if (success && mounted) {
                      unawaited(
                        ReviewService().triggerReviewPromptIfNeeded(context),
                      );
                    }
                  });
                } else {
                  _attachOfflineReviewListener();
                }
              }
            }
          },
          onApplyEditedMessage: () async =>
          await editService.applyEditedMessage(context),
          onStop: context.read<StopService>().stopResponse,
          onPhotoSelected: (photo) =>
              context.read<InputProvider>().selectPhoto(photo),
          onCancelEditing: () {
            editService.cancelEditingMode();
            _scrollService.updateButtonVisibility();
          },
        ),
      ],
    );
  }

  // ---------------- Messages ----------------

  Widget _buildChatContent(AppLocalizations localizations) {
    final conversationProvider = context.watch<ConversationProvider>();
    final sessionProvider = context.watch<ChatSessionProvider>();

    if (conversationProvider.isLoadingMessages) {
      return const MessageListSkeleton(key: ValueKey('messages_skeleton'));
    }

    return NotificationListener<AiStreamFinishedNotification>(
      onNotification: (notification) {
        debugPrint("[ActiveChatView] AI Stream visual animation finished.");

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            ReviewService().triggerReviewPromptIfNeeded(context);
          }
        });

        return true;
      },
      child: SelectedScreen(
        key: const ValueKey('selected_screen'),
        scrollController: scrollController,
        onStop: context.read<StopService>().stopResponse,
        onEdit: (index) => editService.startEditingMessage(index),
        onFadeOutComplete: (index) =>
            context.read<ConversationProvider>().removeMessageAtIndex(index),
        onRegenerate: (int index, {String? newModelId}) {
          final regenerateService = context.read<RegenerateService>();
          final bool isDynamic = sessionProvider.isDynamicChat;
          regenerateService.onRegenerate(
            index,
            context: context,
            newModelId: newModelId,
            isDynamicRegenerate: isDynamic,
          );
        },
        onReport: (index) {
          final messages = conversationProvider.messages;
          final modelId = messages[index].model;
          if (modelId == null) return;
          ReportDialog.show(
            context,
            aiMessage: messages[index].text,
            modelId: modelId,
            onReportSuccess: () {
              if (!mounted) return;
              final updatedMessage = messages[index].copyWith(isReported: true);
              conversationProvider.updateMessageAtIndex(index, updatedMessage);
              if (conversationProvider.conversationID != null) {
                ChatStorageService.updateStoredMessage(
                  conversationProvider.conversationID!,
                  updatedMessage,
                  index,
                );
              }
            },
          );
        },
      ),
    );
  }

  // ---------------- Helpers ----------------

  void _attachOfflineReviewListener() {
    final conversationProvider = context.read<ConversationProvider>();

    if (!conversationProvider.isWaitingForResponse) {
      return;
    }

    late VoidCallback listener;

    listener = () {
      if (!mounted) {
        conversationProvider.removeListener(listener);
        return;
      }

      if (!conversationProvider.isWaitingForResponse) {
        conversationProvider.removeListener(listener);
        unawaited(
          ReviewService().triggerReviewPromptIfNeeded(context),
        );
      }
    };

    conversationProvider.addListener(listener);
  }

  bool _isLimitExceeded(BuildContext context) {
    final sessionProvider = context.read<ChatSessionProvider>();
    final conversationProvider = context.read<ConversationProvider>();
    return sessionProvider.chatLimitManager
        ?.isLimitExceeded(conversationProvider.messages) ??
        false;
  }

  bool _isOfflineCurrentModel(BuildContext context) {
    final sessionProvider = context.read<ChatSessionProvider>();
    final modelService = context.read<ModelService>();
    final langCode = Localizations.localeOf(context).languageCode;
    return !Utils.isServerSideModel(
      sessionProvider.modelId,
      langCode: langCode,
      modelService: modelService,
    );
  }

  bool _isModelMissing(BuildContext context) {
    final sessionProvider = context.read<ChatSessionProvider>();
    final localStateProvider = context.read<ModelLocalStateProvider>();
    final isOffline = _isOfflineCurrentModel(context);
    final isDownloaded =
        localStateProvider.downloadCompleted[sessionProvider.modelId] ?? false;
    return !sessionProvider.isDynamicChat && isOffline && !isDownloaded;
  }
}