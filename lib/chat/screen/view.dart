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
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/server/credits.dart';
import '../../theme.dart';
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

  // --- UI Notifiers ---
  final ValueNotifier<bool> showScrollDownButtonNotifier =
  ValueNotifier<bool>(false);
  final ValueNotifier<double> bottomPanelHeightNotifier =
  ValueNotifier<double>(0.0);
  final ValueNotifier<double> briefingVisibleHeightNotifier =
  ValueNotifier<double>(0.0);

  // Constants
  static const double _briefingBottomOffset = 8.0;

  // --- Flags ---
  final bool _showInappropriateContentWarning = false;
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
    final sessionProvider = context.read<ChatSessionProvider>();
    final conversationProvider = context.read<ConversationProvider>();

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
    _inputProvider = context.read<InputProvider>();
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

    final modelService = context.read<ModelService>();
    final inputProvider = context.read<InputProvider>();

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
            langCode: langCode, modelService: modelService);

    if (isNewModelOffline) {
      inputProvider.setFeatureMode(ChatInputMode.offline);
    } else {
      if (inputProvider.featureMode == ChatInputMode.offline) {
        inputProvider.clearFeatureMode();
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
    // Session provider watched but value accessed explicitly further down instead of locally
    context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();
    final inputProvider = context.watch<InputProvider>();

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bottomSafe = mediaQuery.padding.bottom;
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0.0;

    // Watch ThemeProvider to rebuild on theme changes
    context.watch<ThemeProvider>();

    return Stack(
      children: [
        // LAYER 1: Main Content
        Column(
          children: [
            // Chat Body (Morphs into Dot)
            Expanded(
              child: AnimatedScale(
                scale: inputProvider.isVoiceModeActive ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: inputProvider.isVoiceModeActive
                    ? Curves.easeInBack
                    : Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: inputProvider.isVoiceModeActive ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
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
                    child: conversationProvider.isLoadingMessages
                        ? const MessageListSkeleton(key: ValueKey('skeleton'))
                        : conversationProvider.messages.isEmpty
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
              offset: inputProvider.isVoiceModeActive
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
                offset: inputProvider.isVoiceModeActive
                    ? const Offset(0, 1.5) // Slide deeper
                    : Offset.zero,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: BriefingOverlay(
                  availableCredits: context
                      .watch<CreditsManager>()
                      .totalCreditsNotifier
                      .value,
                  // LOGIC UPDATE: Universal Attachment Support
                  photoSelected: context
                      .watch<InputProvider>()
                      .hasAttachments,
                  isOfflineModel: _isOfflineCurrentModel(context),
                  modelMissing: _isModelMissing(context),
                  limitReached: _isLimitExceeded(context),
                  isStorageSufficient:
                  context
                      .watch<ChatSessionProvider>()
                      .isStorageSufficient,
                  isPremiumModel: context
                      .watch<ChatSessionProvider>()
                      .isCurrentModelPremium,
                  isSubscribed:
                  context
                      .watch<ChatSessionProvider>()
                      .isUserSubscribed,
                  premiumTrialUses:
                  context
                      .watch<ChatSessionProvider>()
                      .premiumTrialUses,
                  isDynamicChat: context
                      .watch<ChatSessionProvider>()
                      .isDynamicChat,
                  isSearchEnabled: context
                      .watch<InputProvider>()
                      .enableWebSearch,
                  conversationId: context
                      .watch<ConversationProvider>()
                      .conversationID,
                  inappropriate: _showInappropriateContentWarning,
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
                basePanel + briefingH + _briefingBottomOffset;

            // Pass slide offset directly to prevent Positioned nesting crash
            return _scrollService.buildScrollDownButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              bottomPanelHeight: combinedPanelHeight,
              showScrollDownButton: showButton,
              isKeyboardOpen: isKeyboardOpen,
              keyboardHeight: keyboardHeight,
              slideOffset: inputProvider.isVoiceModeActive
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
        if (context
            .watch<InputProvider>()
            .isVoiceModeActive)
          const VoiceSessionOverlay(), // Covers everything
      ],
    );
  }

  // --- Helpers ---

  bool _isLimitExceeded(BuildContext context) {
    return context
        .read<ChatSessionProvider>()
        .chatLimitManager
        ?.isLimitExceeded(context
        .read<ConversationProvider>()
        .messages) ??
        false;
  }

  bool _isOfflineCurrentModel(BuildContext context) {
    final session = context.read<ChatSessionProvider>();
    final langCode = Localizations
        .localeOf(context)
        .languageCode;
    return !Utils.isServerSideModel(
      session.modelId,
      langCode: langCode,
      modelService: context.read<ModelService>(),
    );
  }

  bool _isModelMissing(BuildContext context) {
    final session = context.read<ChatSessionProvider>();
    final isOffline = _isOfflineCurrentModel(context);
    final isDownloaded = context
        .read<ModelLocalStateProvider>()
        .downloadCompleted[session.modelId] ??
        false;
    return !session.isDynamicChat && isOffline && !isDownloaded;
  }
}
