import 'package:url_launcher/url_launcher.dart';
import 'package:cortex/analytics/service.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'axon/inbox/panel/view.dart';
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
      if (kIsWeb) {
        _checkAndShowWebDemoDialog();
      }
    });
  }

  Future<void> _checkAndShowWebDemoDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenDemoDialog = prefs.getBool('has_seen_web_demo') ?? false;

    if (!hasSeenDemoDialog && mounted) {
      prefs.setBool('has_seen_web_demo', true);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
                  width: 1),
            ),
            title: Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.secondaryColor, size: 28),
                const SizedBox(width: 10),
                Text(
                  "Demo Sürümü",
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cortex'in web sürümü şu anda demo aşamasındadır. Sesli giriş, resim indirme, yerel veritabanı gibi bazı gelişmiş özellikler düzgün çalışmayabilir veya devre dışı bırakılmış olabilir. Tam ve stabil bir deneyim için mobil uygulamamızı kullanmanız önerilir.",
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted
                          .withValues(alpha: 0.8),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStoreButton(
                        context,
                        "App Store",
                        Icons.apple,
                        "https://apps.apple.com/tr/app/cortex-online-offline-ai/id6755621587",
                      ),
                      _buildStoreButton(
                        context,
                        "Play Store",
                        Icons.android,
                        "https://play.google.com/store/apps/details?id=com.vertex.cortex&pcampaignid=web_share",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor:
                      AppColors.secondaryColor.withValues(alpha: 0.1),
                  foregroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text("Anladım",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildStoreButton(
      BuildContext context, String label, IconData icon, String url) {
    return InkWell(
      onTap: () async {
        if (kIsWeb) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.inverted.withValues(alpha: 0.05),
          border: Border.fromBorderSide(BorderSide(
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
              width: 1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryColor.inverted, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
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
    } else if (velocity < 0) {
      _animateAxonTo(0.0);
    } else {
      if (_axonController.value > 0.5) {
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

  void switchToLibrary({bool pulse = false}) {
    if (_currentView == MainScreenView.library && pulse) {
      libraryScreenKey.currentState?.triggerPulseAnimation();
      closeAxon();
      return;
    }

    setState(() => _currentView = MainScreenView.library);
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
    setState(() => _currentView = MainScreenView.news);
    AnalyticsService().logNewsScreen();
    AnalyticsService().logTabSwitched('news');
    closeAxon();
  }

  void openConversation(ConversationManager manager) async {
    _forceCloseKeyboard();
    await context.read<AppInitializer>().onCoreServicesReady;
    if (!mounted) return;

    setState(() => _currentView = MainScreenView.chat);
    AnalyticsService().logChatScreen();
    AnalyticsService().logTabSwitched('chat');

    // CRITICAL: Clear editing mode when switching to a different conversation
    // This preserves the global draft but clears editing-specific state
    context.read<InputProvider>().resetInputState();

    final ReadService readService = context.read<ReadService>();
    final LocaleProvider localeProvider = context.read<LocaleProvider>();
    await readService.loadConversation(manager,
        languageCode: localeProvider.locale.languageCode);
    AnalyticsService().logConversationStarted(isNew: false);
    closeAxon();
  }

  void startNewConversation({bool closeSidebar = true}) {
    _forceCloseKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _currentView = MainScreenView.chat);
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
      setState(() => _currentView = MainScreenView.chat);
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

  Widget _buildMobileLayout(BuildContext context, double standardAxonWidth,
      double directionMultiplier, bool isRtl) {
    return Listener(
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
          animation: Listenable.merge(
              [_axonController, _elasticController, _searchModeController]),
          builder: (context, child) {
            final double rawValue = _axonController.value;
            final double searchValue =
                Curves.easeInOutCubic.transform(_searchModeController.value);

            final double screenWidth = MediaQuery.of(context).size.width;
            final double visibleAxonWidth = standardAxonWidth + _elasticWidth;
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

            final double overlayOpacity = (0.3 * rawValue).clamp(0.0, 1.0);

            return Stack(
              children: [
                // --- LAYER 1: Axon (Sidebar) ---
                Transform.translate(
                  offset: Offset(axonParallaxX, 0),
                  child: SizedBox(
                    width: currentAxonWidth,
                    height: MediaQuery.of(context).size.height,
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
                    alignment:
                        isRtl ? Alignment.centerRight : Alignment.centerLeft,
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
                              offset: Offset(-15 * directionMultiplier, 0),
                            )
                        ],
                        borderRadius: BorderRadius.circular(30.0 * rawValue),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0 * rawValue),
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            viewInsets: (rawValue > 0 || searchValue > 0)
                                ? EdgeInsets.zero
                                : MediaQuery.of(context).viewInsets,
                          ),
                          child: Stack(
                            children: [
                              _buildCurrentScreenWidget(),
                              if (rawValue > 0)
                                IgnorePointer(
                                  child: Container(
                                    color: Colors.black
                                        .withValues(alpha: overlayOpacity),
                                  ),
                                ),
                              Align(
                                alignment: isRtl
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 1.0,
                                  height: (MediaQuery.of(context).size.height *
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
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    const double desktopSidebarWidth = 280.0;
    return Listener(
      onPointerDown: (_) {
        context
            .read<IntrovertNotificationService>()
            .dismissCurrentNotification();
      },
      child: Row(
        children: [
          // Fixed Sidebar
          SizedBox(
            width: desktopSidebarWidth,
            child: Axon(
              onNewChatTap: () => startNewConversation(closeSidebar: false),
              onLibraryTap: switchToLibrary,
              onNewsTap: openNewsScreen,
              onCloseAxon: () {}, // Desktop sidebar never closes
              onOpenAxon: () {}, // Desktop sidebar never closes
              onSearchFocusChanged: _handleSearchFocusChanged,
              referenceWidth: desktopSidebarWidth,
              activeTab: _getCurrentViewIndex(),
            ),
          ),

          // Divider
          Container(
            width: 1.0,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),

          // Main Content Region
          Expanded(
            child: ClipRRect(
              child: _buildCurrentScreenWidget(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            setState(() => _currentView = MainScreenView.chat);
            return;
          }

          if (MediaQuery.of(context).viewInsets.bottom > 0) {
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth >= 800;

              if (isDesktop) {
                return _buildDesktopLayout(context);
              } else {
                final double standardAxonWidth = constraints.maxWidth * 0.85;
                return _buildMobileLayout(
                    context, standardAxonWidth, directionMultiplier, isRtl);
              }
            },
          ),
        ),
      ),
    );
  }
}
