// lib/screen.dart

import 'package:cortex/analytics/service.dart';
import 'package:cortex/theme.dart';
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
import 'chat/services/stop.dart';
import 'chat/services/voice.dart';
import 'axon/inbox/logic/manager.dart';
import 'axon/inbox/panel/view.dart'; // [NEW] For global panel close
import 'initialization.dart';
import 'language.dart';
import 'library/backend/data/entity.dart';
import 'library/providers/catalog.dart';
import 'library/providers/local.dart';
import 'library/screen/models/controller.dart';
import 'news/view.dart';
import 'notifications/introvert.dart';

enum MainScreenView {
  chat,
  library,
  news,
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

  double _accumulatedDrag = 0.0;
  bool _hasTriggeredNavigation = false;

  @override
  void initState() {
    super.initState();
    _axonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
    final double dist = (target - _axonController.value).abs();
    final int ms = (300 * dist).clamp(150, 300).toInt();

    _axonController.animateTo(
      target,
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutQuart,
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
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_ignoreDrag) return;

    final double screenW = MediaQuery.of(context).size.width;
    final double standardAxonW = screenW * 0.85;
    final double searchGapW = screenW - standardAxonW;
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

    if (velocity > 0) {
      _animateAxonTo(1.0);
    } else if (velocity < -100) {
      _animateAxonTo(0.0);
    } else {
      // Sensitivity threshold for position: if opened even ~0.5%, snap it open fully!
      if (_axonController.value > 0.005) {
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

  void openConversation(ConversationManager manager) async {
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
  }

  void startNewConversation({bool closeSidebar = true}) {
    _forceCloseKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _updateCurrentView(MainScreenView.chat);
      AnalyticsService().logChatScreen();
      AnalyticsService().logTabSwitched('chat');

      final session = context.read<ChatSessionProvider>();
      final conv = context.read<ConversationProvider>();
      final input = context.read<InputProvider>();
      final stopService = context.read<StopService>();
      final voiceService = context.read<VoiceService>();

      // Force Voice Mode OFF
      if (input.isVoiceModeActive) {
        await voiceService.stopSession();
        input.setVoiceModeActive(false);
      }

      // CRITICAL: Stop any active response stream BEFORE clearing
      // This prevents response chunks from appearing in the new empty chat
      if (conv.isWaitingForResponse) {
        await stopService.stopResponse();
      }

      await session.initializeDefaultSession();

      conv.clearConversation();
      input.resetInputState();
      AnalyticsService().logConversationStarted(isNew: true);

      if (closeSidebar) {
        closeAxon();
      }
    });
  }

  void startChatWithModel(ModelEntity model) {
    _forceCloseKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateCurrentView(MainScreenView.chat);
      context.read<SelectionService>().selectModel(model);
      if (Navigator.canPop(context)) Navigator.pop(context);
      closeAxon();
    });
  }

  void _forceCloseKeyboard() {
    final FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _handleSearchFocusChanged(bool focused) {
    setState(() {
      _isSearchFocused = focused;
    });
    if (focused) {
      _searchModeController.forward();
    } else {
      _searchModeController.reverse();
    }
  }

  int _getCurrentViewIndex() {
    switch (_currentView) {
      case MainScreenView.chat:
        return 0;
      case MainScreenView.library:
        return 1;
      case MainScreenView.news:
        return 2;
    }
  }

  Widget _buildCurrentScreenWidget() {
    // Use IndexedStack to keep all screens alive and prevent rebuilds
    // This dramatically improves performance when switching tabs
    return IndexedStack(
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final double standardAxonWidth = screenWidth * 0.85;

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final double directionMultiplier = isRtl ? -1.0 : 1.0;

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
              _currentView == MainScreenView.news) {
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
                      -(standardAxonWidth * 0.25) * (1.0 - rawValue);
                  if (searchValue > 0) {
                    axonParallaxX = axonParallaxX * (1.0 - searchValue);
                  }
                  axonParallaxX *= directionMultiplier;

                  final double overlayOpacity =
                      (0.3 * rawValue).clamp(0.0, 1.0);

                  return Stack(
                    children: [
                      // --- LAYER 1: Axon (Sidebar) ---
                      Transform.translate(
                        offset: Offset(axonParallaxX, 0),
                        child: SizedBox(
                          width: currentAxonWidth,
                          height: MediaQuery.sizeOf(context).height,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Axon(
                              onNewChatTap: () => startNewConversation(),
                              onLibraryTap: switchToLibrary,
                              onNewsTap: openNewsScreen,
                              onCloseAxon: closeAxon,
                              onOpenAxon: () => _animateAxonTo(1.0),
                              onSearchFocusChanged: _handleSearchFocusChanged,
                              referenceWidth: standardAxonWidth,
                              activeTab: _getCurrentViewIndex(),
                            ),
                          ),
                        ),
                      ),

                      // --- LAYER 2: MAIN SCREEN (Front) ---
                      Transform.translate(
                        offset: Offset(mainScreenX, 0),
                        child: Transform.scale(
                          scale: 1.0 - (0.08 * rawValue),
                          alignment: isRtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              boxShadow: [
                                if (rawValue > 0)
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.2 * rawValue),
                                    blurRadius: 30,
                                    spreadRadius: -5,
                                    offset:
                                        Offset(-15 * directionMultiplier, 0),
                                  )
                              ],
                              borderRadius:
                                  BorderRadius.circular(30.0 * rawValue),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(30.0 * rawValue),
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  viewInsets: (rawValue > 0 || searchValue > 0)
                                      ? EdgeInsets.zero
                                      : MediaQuery.viewInsetsOf(context),
                                ),
                                child: Stack(
                                  children: [
                                    child!,
                                    if (rawValue > 0)
                                      IgnorePointer(
                                        child: Container(
                                          color: Colors.black.withValues(
                                              alpha: overlayOpacity),
                                        ),
                                      ),
                                    Align(
                                      alignment: isRtl
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        width: 1.0,
                                        height: (MediaQuery.sizeOf(context)
                                                    .height *
                                                0.6) *
                                            rawValue,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Theme.of(context)
                                                  .dividerColor
                                                  .withValues(alpha: 0.0),
                                              Theme.of(context)
                                                  .dividerColor
                                                  .withValues(alpha: 0.3),
                                              Theme.of(context)
                                                  .dividerColor
                                                  .withValues(alpha: 0.3),
                                              Theme.of(context)
                                                  .dividerColor
                                                  .withValues(alpha: 0.0),
                                            ],
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
                            ),
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
}
