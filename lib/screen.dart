// lib/screen.dart

import 'dart:async';

import 'package:cortex/analytics/service.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/axon/inbox/archived_dialog.dart';

import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'axon/view.dart';
import 'chat/controller.dart';
import 'chat/providers/conversation.dart';
import 'chat/providers/input.dart';
import 'chat/providers/session.dart';
import 'chat/services/read.dart';
import 'chat/services/select.dart';
import 'chat/services/voice.dart';
import 'axon/inbox/logic/manager.dart';
import 'axon/inbox/panel/view.dart'; // [NEW] For global panel close
import 'initialization.dart';
import 'language.dart';
import 'library/backend/data/entity.dart';
import 'library/providers/catalog.dart';
import 'library/providers/local.dart';
import 'library/screen/models/controller.dart';
import 'library/screen/new/controller.dart';
import 'news/view.dart';
import 'arts/screen.dart';
import 'roleplay/screens/discover_screen.dart';
import 'notifications/introvert.dart';

enum MainScreenView {
  chat,
  library,
  news,
  create,
  arts,
  roleplay,
}

class FadeIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    final idx = index;
    final list = children;
    return Stack(
      fit: StackFit.expand,
      children: List<Widget>.generate(list.length, (int i) {
        final isActive = idx == i;
        return IgnorePointer(
          ignoring: !isActive,
          child: AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: duration,
            child: TickerMode(
              enabled: isActive,
              child: isActive
                  ? list[i]
                  : MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        viewInsets: EdgeInsets.zero,
                      ),
                      child: list[i],
                    ),
            ),
          ),
        );
      }),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final GlobalKey<ChatControllerState> chatScreenKey =
      GlobalKey<ChatControllerState>();
  final GlobalKey<LibraryScreenState> libraryScreenKey =
      GlobalKey<LibraryScreenState>();

  MainScreenView _currentView = MainScreenView.chat;

  Animation<double> get axonAnimation => _axonController;
  late AnimationController _axonController;
  late AnimationController _searchModeController;
  AnimationController? _elasticController;

  double _elasticWidth = 0.0;
  bool _ignoreDrag = false;
  bool _isSearchFocused = false;
  bool _isDialogOpen = false;
  int _forceCloseGeneration = 0;
  int _keyboardOpenGeneration = 0;

  double _accumulatedDrag = 0.0;
  bool _hasTriggeredNavigation = false;

  // PERF: Cache gradient colors so build() doesn't allocate a new List<Color>
  // on every frame. Recomputed only when the theme's divider color changes.
  List<Color>? _cachedGradientColors;
  Color? _cachedDividerColor;

  // PERF: Cache Axon widget to avoid rebuilding the entire sidebar on every frame
  // during animation, preventing massive UI lag on the conversation list.
  Widget? _cachedAxonWidget;
  bool _cachedAxonIsOpen = false;
  int _cachedAxonActiveTab = -1;

  Widget _getAxonWidget(bool isOpen, int activeTab, double standardAxonWidth) {
    if (_cachedAxonWidget != null &&
        _cachedAxonIsOpen == isOpen &&
        _cachedAxonActiveTab == activeTab) {
      return _cachedAxonWidget!;
    }
    _cachedAxonIsOpen = isOpen;
    _cachedAxonActiveTab = activeTab;
    return _cachedAxonWidget = Axon(
      onNewChatTap: () => startNewConversation(),
      onLibraryTap: switchToLibrary,
      onCreateAITap: switchToCreate,
      onArtsTap: openArtsScreen,
      onRoleplayTap: openRoleplayScreen,
      onNewsTap: openNewsScreen,
      onArchivedTap: _showArchivedConversations,
      onCloseAxon: closeAxon,
      onOpenAxon: () => _animateAxonTo(1.0),
      referenceWidth: standardAxonWidth,
      activeTab: activeTab,
      isOpen: isOpen,
    );
  }

  List<Color> _getGradientColors(Color dividerColor) {
    if (_cachedDividerColor == dividerColor && _cachedGradientColors != null) {
      return _cachedGradientColors!;
    }
    _cachedDividerColor = dividerColor;
    return _cachedGradientColors = [
      dividerColor.withValues(alpha: 0.0),
      dividerColor.withValues(alpha: 0.3),
      dividerColor.withValues(alpha: 0.3),
      dividerColor.withValues(alpha: 0.0),
    ];
  }

  @override
  void initState() {
    super.initState();
    _axonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 0.0,
    );

    _searchModeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );

    // Log initial chat screen view
    AnalyticsService().logChatScreen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ModelCatalogProvider>().initialize(context: context);
      context.read<ModelLocalStateProvider>().initialize(context: context);
    });
  }

  @override
  void dispose() {
    _axonController.dispose();
    _searchModeController.dispose();
    _elasticController?.dispose();
    super.dispose();
  }

  void setDialogOpen(bool isOpen) {
    _isDialogOpen = isOpen;
  }

  void _requestChatKeyboardFocus({
    int initialDelayMs = 0,
    int controllerRetries = 10,
    int focusRetries = 8,
    int retryDelayMs = 240,
    String source = 'unknown',
  }) {
    final int generation = ++_keyboardOpenGeneration;

    // Cancel any pending force-close retry chain. A keyboard-open request is
    // intentional and should win over stale hide retries from sidebar/tab work.
    _forceCloseGeneration++;

    Future.delayed(Duration(milliseconds: initialDelayMs), () {
      void attempt(int attemptNumber) {
        if (!mounted ||
            generation != _keyboardOpenGeneration ||
            _currentView != MainScreenView.chat) {
          return;
        }

        if (_isDialogOpen || _isSearchFocused) {
          debugPrint(
              "[KeyboardFocus] Deferred by overlay/search for $source. Retrying $attemptNumber/$controllerRetries.");
          if (attemptNumber < controllerRetries) {
            Future.delayed(Duration(milliseconds: retryDelayMs), () {
              attempt(attemptNumber + 1);
            });
          }
          return;
        }

        final chatState = chatScreenKey.currentState;
        if (chatState == null) {
          debugPrint(
              "[KeyboardFocus] ChatController not ready for $source. Retrying $attemptNumber/$controllerRetries.");
          if (attemptNumber < controllerRetries) {
            Future.delayed(Duration(milliseconds: retryDelayMs), () {
              attempt(attemptNumber + 1);
            });
          }
          return;
        }

        debugPrint(
            "[KeyboardFocus] Dispatching focus request from $source. controllerAttempt=$attemptNumber");
        chatState.requestKeyboardFocus(
          delayMs: 0,
          maxRetries: focusRetries,
          retryDelayMs: retryDelayMs,
        );
      }

      attempt(1);
    });
  }

  // --- DRAWER & GESTURE LOGIC ---

  void toggleAxon() {
    if (_axonController.value < 0.5) {
      FocusManager.instance.primaryFocus?.unfocus();
      AnalyticsService().logSidebarOpened();
      _animateAxonTo(1.0);
    } else {
      _closeAxonWithAnimation();
    }
  }

  void closeAxon() {
    if (_axonController.value > 0.0) {
      _closeAxonWithAnimation();
    }
  }

  void _showArchivedConversations() {
    showDialog(
      context: context,
      builder: (context) => const ArchivedConversationsDialog(),
    );
  }

  void _closeAxonWithAnimation() {
    if (mounted) {
      context.read<IntrovertNotificationService>().dismissAxonNotification();
    }

    // Close any open context menu (Long Press Panel)
    ActionPanelController.closeCurrent();

    AnalyticsService().logSidebarClosed();

    if (_isSearchFocused) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _isSearchFocused = false);
      _searchModeController.reverse();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    if (_elasticWidth > 0) {
      setState(() => _elasticWidth = 0.0);
    }
    _animateAxonTo(0.0);
  }

  void _animateAxonTo(double target) {
    if (target > 0.0) {
      _forceCloseKeyboard();
    }
    _axonController.animateTo(
      target,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
    );
  }

  // --- DRAWER & GESTURE LOGIC (RTL ADAPTED) ---
  void _onDragStart(DragStartDetails details) {
    _accumulatedDrag = 0.0;
    _hasTriggeredNavigation = false;

    final double screenW = MediaQuery.of(context).size.width;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    if (isRtl) {
      if (details.globalPosition.dx < 25.0) {
        _ignoreDrag = true;
        return;
      }
    } else {
      if (details.globalPosition.dx > screenW - 25.0) {
        _ignoreDrag = true;
        return;
      }
    }

    _ignoreDrag = false;

    // Auto-close any open panel when user starts dragging the drawer
    ActionPanelController.closeCurrent();

    if (_axonController.value == 0) {
      _forceCloseKeyboard();
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_ignoreDrag) return;

    if (!_isSearchFocused) {
      final focusNode = FocusManager.instance.primaryFocus;
      if (focusNode != null && focusNode.hasFocus) {
        focusNode.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    }

    final double screenW = MediaQuery.of(context).size.width;
    // Full-width sidebar: standardAxonW is now the full screen width.
    final double standardAxonW = screenW;
    // searchGapW is 0 in full-width mode; guard against division by zero.
    final double searchGapW = (screenW * 0.15).clamp(1.0, double.infinity);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    final double rawDelta = details.primaryDelta!;
    final double delta = isRtl ? -rawDelta : rawDelta;

    if (_currentView == MainScreenView.library &&
        _axonController.value == 0 &&
        !_hasTriggeredNavigation) {
      if (delta < 0) {
        _accumulatedDrag += delta;
        if (_accumulatedDrag.abs() > 60) {
          _hasTriggeredNavigation = true;
          HapticFeedback.lightImpact();
          context.read<ModelCatalogProvider>().openCreateScreen(context);
          _accumulatedDrag = 0.0;
          return;
        }
      }
    }
    // -------------------------------------------------------------

    if (_isSearchFocused) {
      if (delta > 0) {
        if (_axonController.value < 1.0) {
          _axonController.value += delta / standardAxonW;
        } else {
          _searchModeController.value += delta / searchGapW;
        }
      } else {
        if (_searchModeController.value > 0.0) {
          _searchModeController.value += delta / searchGapW;
        } else {
          _axonController.value += delta / standardAxonW;
        }
      }
      return;
    }

    if (_axonController.value >= 1.0 && delta > 0) {
      setState(() {
        double resistance =
            1.0 - (_elasticWidth / (screenW * 0.3)).clamp(0.0, 0.4);
        _elasticWidth += delta * 0.7 * resistance;
      });
    } else if (_elasticWidth > 0) {
      setState(() {
        _elasticWidth += delta;
        if (_elasticWidth < 0) {
          double remainingDelta = _elasticWidth;
          _elasticWidth = 0.0;
          _axonController.value += remainingDelta / standardAxonW;
        }
      });
    } else {
      _axonController.value += delta / standardAxonW;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_hasTriggeredNavigation) {
      _hasTriggeredNavigation = false;
      return;
    }

    if (_ignoreDrag) {
      _ignoreDrag = false;
      return;
    }

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final double rawVelocity = details.primaryVelocity!;
    final double velocity = isRtl ? -rawVelocity : rawVelocity;

    if (_isSearchFocused) {
      if (velocity < -1200) {
        closeAxon();
        return;
      }
      if (velocity < -500) {
        if (_searchModeController.value > 0.0) {
          _searchModeController.reverse();
        } else {
          closeAxon();
        }
        return;
      }
      if (velocity > 500) {
        _searchModeController.forward();
        _animateAxonTo(1.0);
        return;
      }

      if (_searchModeController.value > 0.5) {
        _searchModeController.forward();
        _animateAxonTo(1.0);
      } else if (_axonController.value > 0.5) {
        _searchModeController.reverse();
        _animateAxonTo(1.0);
      } else {
        closeAxon();
      }
      return;
    }

    if (_elasticWidth > 0) {
      _runElasticSpringBack();
      _axonController.value = 1.0;
      return;
    }

    if (velocity > 300) {
      _animateAxonTo(1.0);
    } else if (velocity < -300) {
      _animateAxonTo(0.0);
    } else {
      // Sensitivity threshold for position: if opened even ~20%, snap it open fully!
      if (_axonController.value > 0.2) {
        _animateAxonTo(1.0);
      } else {
        _animateAxonTo(0.0);
      }
    }
  }

  void _runElasticSpringBack() {
    _elasticController?.dispose();
    _elasticController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final double startElastic = _elasticWidth;
    final Animation<double> curve = CurvedAnimation(
      parent: _elasticController!,
      curve: Curves.easeOutQuad,
    );

    _elasticController!.addListener(() {
      setState(() {
        _elasticWidth = startElastic * (1 - curve.value);
      });
    });

    _elasticController!.forward();
  }

  // --- VIEW SWITCHING ---

  void _updateCurrentView(MainScreenView view) {
    if (_currentView == view) return;
    setState(() => _currentView = view);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TabProvider>().setSelectedIndex(_getCurrentViewIndex());
      }
    });
  }

  void switchToLibrary({bool pulse = false}) {
    _forceCloseKeyboard();
    if (_currentView == MainScreenView.library && pulse) {
      libraryScreenKey.currentState?.triggerPulseAnimation();
      closeAxon();
      return;
    }

    _updateCurrentView(MainScreenView.library);
    AnalyticsService().logLibraryScreen();
    AnalyticsService().logTabSwitched('library');
    closeAxon();

    if (pulse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          libraryScreenKey.currentState?.triggerPulseAnimation();
        }
      });
    }
  }

  void openNewsScreen() {
    _forceCloseKeyboard();
    _updateCurrentView(MainScreenView.news);
    AnalyticsService().logNewsScreen();
    AnalyticsService().logTabSwitched('news');
    closeAxon();
  }

  void switchToCreate() {
    _forceCloseKeyboard();
    _updateCurrentView(MainScreenView.create);
    AnalyticsService().logTabSwitched('create');
    closeAxon();
  }

  void openRoleplayScreen() {
    _forceCloseKeyboard();
    _updateCurrentView(MainScreenView.roleplay);
    closeAxon();
  }

  void openArtsScreen() {
    _forceCloseKeyboard();
    _updateCurrentView(MainScreenView.arts);
    AnalyticsService().logTabSwitched('arts');
    closeAxon();
  }

  Future<void> openConversation(ConversationManager manager) async {
    _forceCloseKeyboard();

    // CRITICAL FIX: Set loading state synchronously NO MATTER WHAT!
    // If we await CoreServices *before* setting this, the UI stays 'false' and renders the EmptyScreen
    // while the heavy initialization is happening in the background!
    context.read<ConversationProvider>().setLoadingMessages(true);
    _updateCurrentView(MainScreenView.chat);

    await context.read<AppInitializer>().onCoreServicesReady;

    if (!mounted) return;

    AnalyticsService().logChatScreen();
    AnalyticsService().logTabSwitched('chat');

    // CRITICAL: Clear editing mode when switching to a different conversation
    // This preserves the global draft but clears editing-specific state
    context.read<InputProvider>().resetInputState();

    final ReadService readService = context.read<ReadService>();
    final LocaleProvider localeProvider = context.read<LocaleProvider>();
    await readService.loadConversation(manager,
        languageCode: localeProvider.locale.languageCode);

    if (mounted) {
      final session = context.read<ChatSessionProvider>();
      if (session.selectedModel?.isServerSide == false) {
        context.read<InputProvider>().setFeatureMode(ChatInputMode.offline);
      } else {
        context.read<InputProvider>().setFeatureMode(ChatInputMode.none);
      }
    }

    AnalyticsService().logConversationStarted(isNew: false);
    closeAxon();

    // AUTO-FOCUS: Request keyboard focus after conversation is fully loaded
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _requestChatKeyboardFocus(
            initialDelayMs: 120,
            controllerRetries: 6,
            focusRetries: 7,
            retryDelayMs: 220,
            source: 'open_conversation',
          );
        }
      });
    }
  }

  void startNewConversation({
    bool closeSidebar = true,
    bool autoFocus = false,
    bool restoreDefaultModel = true,
  }) {
    // Skip keyboard close on first launch so auto-focus can open it
    if (!autoFocus) {
      _forceCloseKeyboard();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _updateCurrentView(MainScreenView.chat);
      AnalyticsService().logChatScreen();
      AnalyticsService().logTabSwitched('chat');

      final session = context.read<ChatSessionProvider>();
      final conv = context.read<ConversationProvider>();
      final input = context.read<InputProvider>();
      final voiceService = context.read<VoiceService>();

      // Force Voice Mode OFF
      if (input.isVoiceModeActive) {
        await voiceService.stopSession();
        input.setVoiceModeActive(false);
      }

      // BACKGROUND CHAT SUPPORT: Instead of stopping the active response,
      // let it continue generating in the background. The SendService will
      // detect that the ConversationProvider no longer points to the old chat
      // and will buffer chunks via BackgroundTaskService.
      // The explicit Stop button in the chat UI still works for the active chat.

      if (restoreDefaultModel) {
        await session.initializeDefaultSession();
      }

      conv.clearConversation();
      input.resetInputState();
      AnalyticsService().logConversationStarted(isNew: true);

      if (closeSidebar) {
        closeAxon();
      }

      // AUTO-FOCUS: Request focus ONLY if we are navigating to the chat screen
      // (closeSidebar is true) OR if the sidebar is already fully closed.
      // If the user deleted a chat inside Axon (closeSidebar: false), suppress keyboard popup!
      if (closeSidebar || _axonController.value == 0.0) {
        if (mounted) {
          _requestChatKeyboardFocus(
            initialDelayMs: autoFocus ? 650 : 350,
            controllerRetries: autoFocus ? 14 : 8,
            focusRetries: autoFocus ? 10 : 7,
            retryDelayMs: autoFocus ? 260 : 220,
            source: autoFocus ? 'first_launch' : 'new_chat',
          );
        }
      }
    });
  }

  Future<void> startChatWithModel(ModelEntity model) {
    _forceCloseKeyboard();
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!mounted) return;
        _updateCurrentView(MainScreenView.chat);
        await context.read<SelectionService>().selectModel(model);

        closeAxon();

        // AUTO-FOCUS: Request keyboard focus after model selection is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _requestChatKeyboardFocus(
              initialDelayMs: 180,
              controllerRetries: 6,
              focusRetries: 7,
              retryDelayMs: 220,
              source: 'start_chat_with_model',
            );
          }
        });
      } finally {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    return completer.future;
  }

  void _forceCloseKeyboard() {
    // Skip if a dialog (e.g. rename) is open — don't steal its focus
    if (_isDialogOpen) return;

    // Increment generation so any pending retries from a previous call are cancelled
    final int generation = ++_forceCloseGeneration;

    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Add retries to handle race conditions where keyboard re-opens,
    // but ONLY if we are NOT in search mode and no dialog opened since.
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted &&
          !_isSearchFocused &&
          !_isDialogOpen &&
          generation == _forceCloseGeneration) {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted &&
              !_isSearchFocused &&
              !_isDialogOpen &&
              generation == _forceCloseGeneration) {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
        });
      }
    });
  }

  int _getCurrentViewIndex() {
    switch (_currentView) {
      case MainScreenView.chat:
        return 0;
      case MainScreenView.library:
        return 1;
      case MainScreenView.news:
        return 2;
      case MainScreenView.create:
        return 3;
      case MainScreenView.arts:
        return 4;
      case MainScreenView.roleplay:
        return 5;
    }
  }

  Widget _buildCurrentScreenWidget() {
    // Use FadeIndexedStack to keep all screens alive and prevent rebuilds
    // while providing a smooth 0.3s crossfade transition when switching tabs.
    return FadeIndexedStack(
      index: _getCurrentViewIndex(),
      children: [
        // Index 0: Chat
        RepaintBoundary(
          child: ChatController(key: chatScreenKey),
        ),
        // Index 1: Library
        RepaintBoundary(
          child: LibraryScreen(key: libraryScreenKey),
        ),
        // Index 2: News
        const RepaintBoundary(
          child: NewsScreen(),
        ),
        // Index 3: Create AI
        // PERF: Selector guards rebuilds — only fires when model list length
        // changes, not on every ModelCatalogProvider notification.
        RepaintBoundary(
          child: Selector<ModelCatalogProvider, List<ModelEntity>>(
            selector: (_, catalog) => catalog.allModels,
            shouldRebuild: (prev, next) => prev.length != next.length,
            builder: (context, models, _) =>
                ModelCreationHost(availableBaseModels: models),
          ),
        ),
        // Index 4: Arts
        const RepaintBoundary(
          child: ArtsScreen(),
        ),
        // Index 5: Roleplay / Discover
        const RepaintBoundary(
          child: DiscoverScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final screenWidth = mediaQuery.width;
    final screenHeight = mediaQuery.height;
    // Full-width sidebar: Axon occupies the entire screen width.
    // Users close it via left-swipe gesture, tapping "New Chat", or selecting a conversation.
    final double standardAxonWidth = screenWidth;

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final double directionMultiplier = isRtl ? -1.0 : 1.0;

    final dividerColor = Theme.of(context).dividerColor;
    final gradientColors = _getGradientColors(dividerColor);

    // PERFORMANCE: If another screen (like Login or a modal) is pushed on top of MainScreen,
    // prevent MainScreen from receiving viewInsets. This stops 5 tabs from relayouting
    // simultaneously in the background when the keyboard opens on the top screen!
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;

    return Builder(builder: (context) {
      if (isCurrentRoute) {
        return _buildMainContent(context, screenWidth, screenHeight,
            standardAxonWidth, isRtl, directionMultiplier, gradientColors);
      }

      final baseMediaQuery = MediaQuery.of(context);
      return MediaQuery(
        data: baseMediaQuery.copyWith(viewInsets: EdgeInsets.zero),
        child: _buildMainContent(context, screenWidth, screenHeight,
            standardAxonWidth, isRtl, directionMultiplier, gradientColors),
      );
    });
  }

  Widget _buildMainContent(
      BuildContext context,
      double screenWidth,
      double screenHeight,
      double standardAxonWidth,
      bool isRtl,
      double directionMultiplier,
      List<Color> gradientColors) {
    return Title(
      title: 'Cortex',
      color: AppColors.background,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic _) async {
          if (didPop) return;

          if (_isSearchFocused) {
            if (_searchModeController.value > 0.1) {
              _searchModeController.reverse();
            } else {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() => _isSearchFocused = false);
            }
            return;
          }

          if (_axonController.value > 0.0) {
            closeAxon();
            return;
          }

          if (_currentView == MainScreenView.library ||
              _currentView == MainScreenView.news ||
              _currentView == MainScreenView.create ||
              _currentView == MainScreenView.arts ||
              _currentView == MainScreenView.roleplay) {
            _updateCurrentView(MainScreenView.chat);
            return;
          }

          if (MediaQuery.viewInsetsOf(context).bottom > 0) {
            _forceCloseKeyboard();
            return;
          }

          final ChatControllerState? chatState = chatScreenKey.currentState;
          if (chatState != null) {
            if (!chatState.handleSystemBackPress()) return;
          }

          await SystemNavigator.pop();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          body: Listener(
            onPointerDown: (_) {
              context
                  .read<IntrovertNotificationService>()
                  .dismissCurrentNotification();
            },
            child: GestureDetector(
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _axonController,
                  _elasticController,
                  _searchModeController
                ]),
                child: _buildCurrentScreenWidget(),
                builder: (context, child) {
                  final double rawValue = _axonController.value;
                  final double searchValue = Curves.easeInOutCubic
                      .transform(_searchModeController.value);

                  final double visibleAxonWidth =
                      standardAxonWidth + _elasticWidth;
                  final double currentAxonWidth = visibleAxonWidth +
                      ((screenWidth - visibleAxonWidth) * searchValue);

                  final double axonOpenOffset =
                      (standardAxonWidth * rawValue) + _elasticWidth;
                  final double searchOffset =
                      (screenWidth - axonOpenOffset) * searchValue;

                  final double mainScreenX =
                      (axonOpenOffset + searchOffset) * directionMultiplier;

                  double axonParallaxX =
                      -(standardAxonWidth * 0.15) * (1.0 - rawValue);
                  if (searchValue > 0) {
                    axonParallaxX = axonParallaxX * (1.0 - searchValue);
                  }
                  axonParallaxX *= directionMultiplier;

                  return Stack(
                    children: [
                      // --- LAYER 1: Axon (Sidebar) ---
                      Transform.translate(
                        offset: Offset(axonParallaxX, 0),
                        child: SizedBox(
                          width: currentAxonWidth,
                          height: screenHeight,
                          child: Stack(
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: _getAxonWidget(
                                  rawValue > 0.0,
                                  _getCurrentViewIndex(),
                                  standardAxonWidth,
                                ),
                              ),
                              if (rawValue < 1.0)
                                IgnorePointer(
                                  child: Container(
                                    color: Colors.black.withValues(
                                      alpha: 0.25 * (1.0 - rawValue),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // --- LAYER 2: MAIN SCREEN (Front) ---
                      // No scaling, rounding, or darkening — only translate.
                      Transform.translate(
                        offset: Offset(mainScreenX, 0),
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            boxShadow: [
                              if (rawValue > 0)
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.2 * rawValue),
                                  blurRadius: 30,
                                  spreadRadius: -5,
                                  offset: Offset(-15 * directionMultiplier, 0),
                                )
                            ],
                          ),
                          // PERFORMANCE: Removed MediaQuery wrapper that caused
                          // ~60 rebuilds per keyboard animation. resizeToAvoidBottomInset
                          // is already false; scroll button reads keyboard height in its
                          // own isolated AnimatedBuilder (view.dart:370).
                          child: Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    child!,
                                    Align(
                                      alignment: isRtl
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        width: 1.0,
                                        height: (screenHeight * 0.6) * rawValue,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: gradientColors,
                                            stops: const [0.0, 0.3, 0.7, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (rawValue > 0 && searchValue == 0)
                                      GestureDetector(
                                        onTap: closeAxon,
                                        behavior: HitTestBehavior.translucent,
                                        child: Container(
                                          color: Colors.transparent,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              _buildBottomNavigationBar(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return const SizedBox.shrink();
  }
}
