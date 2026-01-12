// lib/chat/view.dart
//
// CHAT VIEW — UNIFIED ORCHESTRATOR
//
// This is the main layout skeleton. It connects:
// 1. The Message List (parts/list.dart)
// 2. The Empty State (parts/empty.dart)
// 3. The Input Panel (parts/bottom.dart)
// 4. Banners & Overlays

import 'package:cortex/chat/screen/widgets/bottom/bottom.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/panels/briefing.dart';
import 'package:cortex/chat/screen/widgets/empty.dart';
import 'package:cortex/chat/screen/widgets/list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Internal Imports ---
import 'package:cortex/extensions.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/appbar/premium.dart';
import 'package:cortex/chat/services/edit.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/funds/funds.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/login/upgrade.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/user.dart';
import '../messages/skeleton.dart';

class ChatView extends StatefulWidget {
  final Extensions extensions;

  const ChatView({
    super.key,
    required this.extensions,
  });

  @override
  ChatViewState createState() => ChatViewState();
}

class ChatViewState extends State<ChatView>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // --- Core Controllers ---
  final ScrollController scrollController = ScrollController();

  // This key is used to measure the height of the Bottom Panel (Input + Edit)
  final GlobalKey _bottomPanelKey = GlobalKey();

  // --- Animations ---
  late AnimationController editPanelController;
  late Animation<Offset> slideAnimation;

  // --- Services ---
  late final EditService editService;
  late final ScrollService _scrollService;
  late final OfflineService _offlineService;

  // --- UI Notifiers ---
  final ValueNotifier<bool> showScrollDownButtonNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> bottomPanelHeightNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> briefingVisibleHeightNotifier = ValueNotifier<double>(0.0);

  // Constants
  static const double _briefingBottomOffset = 8.0;

  // --- Flags ---
  final bool _showInappropriateContentWarning = false;
  bool _showPhotoModelWarning = false;
  String? _lastActiveOfflineModelId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1. Initialize Services
    _scrollService = context.read<ScrollService>();
    _offlineService = context.read<OfflineService>();
    final sessionProvider = context.read<ChatSessionProvider>();
    final conversationProvider = context.read<ConversationProvider>();

    // 2. Connect Scroll Service
    _scrollService.setController(scrollController);
    _scrollService.attachListener(
      notifier: showScrollDownButtonNotifier,
      messageCountProvider: () => conversationProvider.messages.length,
    );

    // 3. Initialize Edit Animations
    editPanelController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: editPanelController, curve: Curves.easeOut));

    // 4. Initialize Edit Service
    // Note: We pass temporary controllers here, but 'ChatInputPanel' in bottom.dart
    // will update them with the real TextControllers once it builds.
    editService = EditService(
      inputProvider: context.read<InputProvider>(),
      conversationProvider: context.read<ConversationProvider>(),
      regenerateService: context.read<RegenerateService>(),
      scrollService: context.read<ScrollService>(),
      controller: TextEditingController(), // Placeholder
      focusNode: FocusNode(), // Placeholder
      panelController: editPanelController,
    );

    // 5. Initial Checks
    _handleModelChange(sessionProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateBottomPanelHeight();
        _scrollService.jumpToBottom();
      }
    });
  }

  // --- Model Logic ---

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

  // --- Layout Helpers ---

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
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    editPanelController.dispose();
    _scrollService.detachListener();
    super.dispose();
  }

  // --- Public Access Methods (for Controller) ---

  // These allow the parent controller (ChatController) to interact with the view
  // without knowing about internal implementation details like 'editService'.

  void focusTextField() {
    // This relies on the internal FocusNode which is managed inside ChatInputPanel.
    // Since we separated it, we can't easily access the FocusNode directly here
    // without a GlobalKey on ChatInputPanel, or by passing the FocusNode down.
    // However, since ChatInputPanel manages its own focus, we can rely on
    // User interactions usually. If programmatic focus is strictly needed from
    // outside, we would need to lift the FocusNode up to this class.
    // For now, keeping it clean: simpler is better.
  }

  void cancelAnyActiveEdit() {
    if (mounted && context.read<InputProvider>().isEditingMode) {
      editService.cancelEditingMode();
    }
  }

  // --- MAIN BUILD ---

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bottomSafe = mediaQuery.padding.bottom;
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0.0;

    return Stack(
      children: [
        // LAYER 1: Main Content
        SafeArea(
          bottom: true,
          child: Column(
            children: [
              // A. Chat Body (List or Empty)
              Expanded(
                child: conversationProvider.isLoadingMessages
                    ? const MessageListSkeleton(key: ValueKey('skeleton'))
                    : conversationProvider.messages.isEmpty
                    ? const ChatEmptyState(key: ValueKey('empty'))
                    : ChatMessageList(
                  key: const ValueKey('list'),
                  scrollController: scrollController,
                  editService: editService,
                ),
              ),

              // B. Bottom Panel (Input)
              NotificationListener<SizeChangedLayoutNotification>(
                onNotification: (notification) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _updateBottomPanelHeight());
                  return true;
                },
                child: Container(
                  key: _bottomPanelKey,
                  child: ChatInputPanel(
                    editService: editService,
                    scrollService: _scrollService,
                    editPanelController: editPanelController,
                    slideAnimation: slideAnimation,
                  ),
                ),
              ),
            ],
          ),
        ),

        // LAYER 2: Premium Banner
        PremiumModelBanner(
          isVisible: sessionProvider.showPremiumBanner,
          onDismiss: () => context.read<ChatSessionProvider>().dismissPremiumBanner(),
          onTap: () {
            final isAnonymous = context.read<UserProvider>().isAnonymous;
            final target = isAnonymous ? const UpgradeAccountScreen() : const FundsScreen();
            navigateToScreen(target, direction: const Offset(0.0, 1.0));
            FocusScope.of(context).unfocus();
          },
        ),

        // LAYER 3: Briefing Overlay
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
                availableCredits: context.watch<CreditsManager>().totalCreditsNotifier.value,
                photoSelected: context.watch<InputProvider>().selectedPhoto != null,
                isOfflineModel: _isOfflineCurrentModel(context),
                modelMissing: _isModelMissing(context),
                limitReached: _isLimitExceeded(context),
                isStorageSufficient: context.watch<ChatSessionProvider>().isStorageSufficient,
                showDisclaimer: context.watch<ChatSessionProvider>().showDisclaimer,
                isPremiumModel: context.watch<ChatSessionProvider>().isCurrentModelPremium,
                isSubscribed: context.watch<ChatSessionProvider>().isUserSubscribed,
                premiumTrialUses: context.watch<ChatSessionProvider>().premiumTrialUses,
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

        // LAYER 4: Scroll Down Button
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
            final double combinedPanelHeight = basePanel + briefingH + _briefingBottomOffset;

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

  // --- Helper Getters ---

  bool _isLimitExceeded(BuildContext context) {
    return context.read<ChatSessionProvider>().chatLimitManager
        ?.isLimitExceeded(context.read<ConversationProvider>().messages) ?? false;
  }

  bool _isOfflineCurrentModel(BuildContext context) {
    final session = context.read<ChatSessionProvider>();
    final langCode = Localizations.localeOf(context).languageCode;
    return !Utils.isServerSideModel(
      session.modelId,
      langCode: langCode,
      modelService: context.read<ModelService>(),
    );
  }

  bool _isModelMissing(BuildContext context) {
    final session = context.read<ChatSessionProvider>();
    final isOffline = _isOfflineCurrentModel(context);
    final isDownloaded = context.read<ModelLocalStateProvider>()
        .downloadCompleted[session.modelId] ?? false;
    return !session.isDynamicChat && isOffline && !isDownloaded;
  }
}