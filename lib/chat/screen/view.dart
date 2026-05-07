// lib/chat/view.dart

import 'package:cortex/chat/screen/widgets/bottom/bottom.dart';
import 'package:cortex/chat/screen/widgets/bottom/panels/briefing.dart';
import 'package:cortex/chat/screen/widgets/list.dart';
import 'package:cortex/chat/screen/widgets/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/edit.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/initialization.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/user.dart';
import '../messages/skeleton.dart';
import 'default/view.dart';
import 'widgets/voice.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  ChatViewState createState() => ChatViewState();
}

class ChatViewState extends State<ChatView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // --- Core Controllers ---
  final ScrollController scrollController = ScrollController();
  final GlobalKey _bottomPanelKey = GlobalKey();

  // --- Animations ---
  late AnimationController editPanelController;
  late Animation<Offset> slideAnimation;

  // --- Services ---
  late final EditService editService;
  late final ScrollService _scrollService;
  late final OfflineService _offlineService;
  late final ModelService _modelService;

  // --- UI Notifiers ---
  final ValueNotifier<bool> showScrollDownButtonNotifier =
  ValueNotifier<bool>(false);
  final ValueNotifier<double> bottomPanelHeightNotifier =
  ValueNotifier<double>(0.0);
  final ValueNotifier<double> briefingVisibleHeightNotifier =
  ValueNotifier<double>(0.0);

  // Constants
  static const double _briefingBottomOffset = 8.0;

  String? _lastActiveOfflineModelId;

  // Cached references for dispose cleanup (avoid context.read in dispose)
  late final InputProvider _inputProvider;
  late final ChatSessionProvider _sessionProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scrollService = context.read<ScrollService>();
    _offlineService = context.read<OfflineService>();
    _modelService = context.read<ModelService>();
    final sessionProvider = context.read<ChatSessionProvider>();
    final conversationProvider = context.read<ConversationProvider>();
    _inputProvider = context.read<InputProvider>();

    _scrollService.setController(scrollController);
    _scrollService.attachListener(
      notifier: showScrollDownButtonNotifier,
      messageCountProvider: () => conversationProvider.messages.length,
    );

    editPanelController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: editPanelController, curve: Curves.easeOut));

    // Initialize EditService. Note: The actual TextEditingController is provided
    // by the ChatInputPanel later via updateControllers.
    editService = EditService(
      inputProvider: context.read<InputProvider>(),
      conversationProvider: context.read<ConversationProvider>(),
      regenerateService: context.read<RegenerateService>(),
      scrollService: context.read<ScrollService>(),
      controller: TextEditingController(),
      focusNode: FocusNode(),
      panelController: editPanelController,
    );

    // Cache session provider and add listener for model changes
    _sessionProvider = sessionProvider;
    _sessionProvider.addListener(_onSessionModelChange);
    _handleModelChange(sessionProvider);

    // CRITICAL: Sync editPanelController with InputProvider's isEditingMode
    // This ensures the edit panel hides when resetInputState() is called
    // Cache reference for safe disposal (can't use context.read in dispose)
    _inputProvider.addListener(_syncEditPanelWithProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateBottomPanelHeight();
        _scrollService.jumpToBottom();
      }
    });
  }

  /// Syncs the edit panel animation controller with InputProvider state.
  /// When isEditingMode becomes false externally (e.g., via resetInputState),
  /// the edit panel animation is reversed to hide it.
  void _syncEditPanelWithProvider() {
    if (!mounted) return;

    if (!_inputProvider.isEditingMode &&
        editPanelController.status != AnimationStatus.dismissed &&
        editPanelController.status != AnimationStatus.reverse) {
      editPanelController.reverse();
    }
  }

  /// Called when ChatSessionProvider notifies listeners (model may have changed).
  void _onSessionModelChange() {
    if (!mounted) return;
    _handleModelChange(_sessionProvider);
  }

  void _handleModelChange(ChatSessionProvider session) {
    // FIX: Hide scroll button when switching models/chats
    _scrollService.hideButtonImmediately();

    final langCode = session
        .getLocale()
        .languageCode;
    final newModelId = session.modelId;
    final newModelPath = session.modelPath;

    if (_lastActiveOfflineModelId == newModelId) return;

    // Release old model if switching
    if (_lastActiveOfflineModelId != null &&
        _lastActiveOfflineModelId != newModelId) {
      _offlineService.releaseModel();
    }

    final isNewModelOffline = newModelId != null &&
        !Utils.isServerSideModel(newModelId,
            langCode: langCode, modelService: _modelService);

    if (isNewModelOffline) {
      _inputProvider.setFeatureMode(ChatInputMode.offline);
    } else {
      if (_inputProvider.featureMode == ChatInputMode.offline) {
        _inputProvider.clearFeatureMode();
      }
    }

    if (isNewModelOffline && newModelPath != null && newModelPath.isNotEmpty) {
      _offlineService.cacheModel(newModelPath);
      _lastActiveOfflineModelId = newModelId;
    } else {
      _lastActiveOfflineModelId = null;
    }
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
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollService.updateButtonVisibility();
      _updateBottomPanelHeight();
    });
  }

  @override
  void dispose() {
    // Remove listeners to prevent memory leaks
    _inputProvider.removeListener(_syncEditPanelWithProvider);
    _sessionProvider.removeListener(_onSessionModelChange);

    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    editPanelController.dispose();
    _scrollService.detachListener();
    super.dispose();
  }

  void cancelAnyActiveEdit() {
    if (mounted && context
        .read<InputProvider>()
        .isEditingMode) {
      editService.cancelEditingMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    // We isolate rebuilds by using context.select instead of context.watch
    final isLoadingMessages = context.select<ConversationProvider, bool>((
        c) => c.isLoadingMessages);
    final isMessagesEmpty = context.select<ConversationProvider, bool>((c) =>
    c
        .messages.isEmpty);

    final isVoiceModeActive = context.select<InputProvider, bool>((p) =>
    p.isVoiceModeActive);

    // PERFORMANCE: Use granular MediaQuery accessors that do NOT subscribe
    // to viewInsets changes (keyboard). This prevents the entire ChatView
    // from rebuilding ~60 times during keyboard open/close animation.
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        // LAYER 1: Main Content
        Column(
          children: [
            // Chat Body (Morphs into Dot)
            Expanded(
              child: AnimatedScale(
                scale: isVoiceModeActive ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: isVoiceModeActive
                    ? Curves.easeInBack
                    : Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: isVoiceModeActive ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder:
                        (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: isLoadingMessages
                        ? const MessageListSkeleton(key: ValueKey('skeleton'))
                        : isMessagesEmpty
                        ? Container(
                      key: const ValueKey('empty'),
                      // Removed hardcoded alignment to allow dynamic spacing in child
                      child: const ChatEmptyState(),
                    )
                        : ChatMessageList(
                      key: const ValueKey('list'),
                      scrollController: scrollController,
                      editService: editService,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Panel (Slides Down)
            AnimatedSlide(
              offset: isVoiceModeActive
                  ? const Offset(0, 1)
                  : Offset.zero,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SafeArea(
                top: false,
                bottom: true,
                child: NotificationListener<SizeChangedLayoutNotification>(
                  onNotification: (notification) {
                    WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _updateBottomPanelHeight());
                    return true;
                  },
                  child: SizedBox(
                    key: _bottomPanelKey,
                    width: double.infinity,
                    child: ChatInputPanel(
                      editService: editService,
                      scrollService: _scrollService,
                      editPanelController: editPanelController,
                      slideAnimation: slideAnimation,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // LAYER 2: Briefing Overlay
        AnimatedBuilder(
          animation: bottomPanelHeightNotifier,
          builder: (context, _) {
            final basePanelHeight = bottomPanelHeightNotifier.value;
            const horizontalPadding = 16.0;

            return Positioned(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: basePanelHeight + bottomSafe + _briefingBottomOffset,
              child: AnimatedSlide(
                offset: isVoiceModeActive
                    ? const Offset(0, 1.5) // Slide deeper
                    : Offset.zero,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _BriefingOverlayWrapper(
                  onVisibleHeightChanged: (h) {
                    if (briefingVisibleHeightNotifier.value != h) {
                      briefingVisibleHeightNotifier.value = h;
                    }
                  },
                ),
              ),
            );
          },
        ),

        // LAYER 3: Scroll Down Button
        // PERFORMANCE: keyboard-dependent MediaQuery is read ONLY here,
        // inside this isolated AnimatedBuilder, not in the parent build().
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
            final double combinedPanelHeight =
                basePanel + briefingH + _briefingBottomOffset + bottomSafe;

            // Read keyboard state locally — only this builder rebuilds on keyboard changes.
            final double keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
            final bool isKeyboardOpen = keyboardHeight > 0.0;

            // Pass slide offset directly to prevent Positioned nesting crash
            return _scrollService.buildScrollDownButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              bottomPanelHeight: combinedPanelHeight,
              showScrollDownButton: showButton,
              isKeyboardOpen: isKeyboardOpen,
              keyboardHeight: keyboardHeight,
              slideOffset: isVoiceModeActive
                  ? const Offset(0, 2)
                  : Offset.zero,
            );
          },
        ),

        // LAYER 4: TTS Player Overlay (Below AppBar)
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: TtsPlayerOverlay(),
        ),

        // LAYER 5: Voice Overlay (Topmost)
        if (isVoiceModeActive)
          const VoiceSessionOverlay(), // Covers everything
      ],
    );
  }
}

class _BriefingOverlayWrapper extends StatelessWidget {
  final ValueChanged<double>? onVisibleHeightChanged;

  const _BriefingOverlayWrapper({this.onVisibleHeightChanged});

  @override
  Widget build(BuildContext context) {
    final creditsManager = context.read<CreditsManager>();
    final session = context.watch<ChatSessionProvider>();
    final conv = context.watch<ConversationProvider>();
    final input = context.watch<InputProvider>();
    final appInitializer = context.watch<AppInitializer>();
    final modelService = context.read<ModelService>();

    final langCode = Localizations
        .localeOf(context)
        .languageCode;

    final isOffline = !Utils.isServerSideModel(
      session.modelId,
      langCode: langCode,
      modelService: modelService,
    );

    final isDownloaded = context
        .watch<ModelLocalStateProvider>()
        .downloadCompleted[session.modelId] ?? false;
    final modelMissing = !session.isDynamicChat && isOffline && !isDownloaded;

    final isLimitExceeded = session.chatLimitManager?.isLimitExceeded(
        conv.messages) ?? false;

    final currentModel = session.selectedModel;
    final isVideoModel = currentModel != null &&
        (currentModel.outputs['video'] == true ||
            currentModel.category == 'video');

    bool isCurrentModelFal = false;
    if (session.modelId != null) {
      try {
        final model = modelService.getPreciseModelData(
            session.modelId!, langCode: langCode);
        isCurrentModelFal = model.source.toLowerCase() == 'fal';
      } catch (_) {}
    }

    return ValueListenableBuilder<int?>(
      valueListenable: creditsManager.totalCreditsNotifier,
      builder: (context, totalCredits, _) {
        return ValueListenableBuilder<int?>(
          valueListenable: creditsManager.preditsNotifier,
          builder: (context, predits, _) {
            return ValueListenableBuilder<int?>(
              valueListenable: creditsManager.dreditsNotifier,
              builder: (context, dredits, _) {
                return BriefingOverlay(
                  availableCredits: totalCredits,
                  availablePredits: predits,
                  availableDredits: dredits,
                  photoSelected: input.hasAttachments,
                  isOfflineModel: isOffline,
                  modelMissing: modelMissing,
                  limitReached: isLimitExceeded,
                  isStorageSufficient: session.isStorageSufficient,
                  isPremiumModel: session.isCurrentModelPremium,
                  isVideoModel: isVideoModel,
                  isSubscribed: session.isUserSubscribed,
                  userTier: context
                      .read<UserProvider>()
                      .userData?['tier'] ?? 0,
                  isDynamicChat: session.isDynamicChat,
                  isSearchEnabled: input.enableWebSearch,
                  isFalOffline: appInitializer.isFalOffline &&
                      isCurrentModelFal,
                  conversationId: conv.conversationID,
                  inappropriate: false,
                  onVisibleHeightChanged: onVisibleHeightChanged,
                );
              },
            );
          },
        );
      },
    );
  }
}

