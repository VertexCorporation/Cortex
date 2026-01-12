// lib/screen.dart

import 'dart:ui';

import 'package:cortex/sidebar/view.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'chat/controller.dart';
import 'chat/providers/conversation.dart';
import 'chat/providers/input.dart';
import 'chat/providers/session.dart';
import 'chat/services/read.dart';
import 'chat/services/select.dart';
import 'chat/widgets/news/view.dart';
import 'exit.dart';
import 'inbox/manager.dart';
import 'initialization.dart';
import 'language.dart';
import 'library/backend/data/entity.dart';
import 'library/providers/catalog.dart';
import 'library/providers/local.dart';
import 'library/screen/models/controller.dart';

enum MainScreenView {
  chat,
  library,
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final GlobalKey<ChatControllerState> chatScreenKey = GlobalKey<ChatControllerState>();

  MainScreenView _currentView = MainScreenView.chat;

  late AnimationController _sidebarController;
  late AnimationController _searchModeController;
  AnimationController? _elasticController;

  double _elasticWidth = 0.0;
  bool _ignoreDrag = false;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );

    _searchModeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ModelCatalogProvider>().initialize(context: context);
      context.read<ModelLocalStateProvider>().initialize(context: context);
    });
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _searchModeController.dispose();
    _elasticController?.dispose();
    super.dispose();
  }

  // --- DRAWER & GESTURE LOGIC ---

  void toggleSidebar() {
    if (_sidebarController.value < 0.5) {
      _animateSidebarTo(1.0);
      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      _closeSidebarWithAnimation();
    }
  }

  void closeSidebar() {
    if (_sidebarController.value > 0.0) {
      _closeSidebarWithAnimation();
    }
  }

  void _closeSidebarWithAnimation() {
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
    _animateSidebarTo(0.0);
  }

  void _animateSidebarTo(double target) {
    final double dist = (target - _sidebarController.value).abs();
    final int ms = (300 * dist).clamp(150, 300).toInt();

    _sidebarController.animateTo(
      target,
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutQuart,
    );
  }

  void _onDragStart(DragStartDetails details) {
    if (_isSearchFocused) return;

    // EDGE GUARD: If drag starts within 16px of the left edge, IGNORE IT.
    if (details.globalPosition.dx < 16.0 && _sidebarController.value == 0) {
      _ignoreDrag = true;
    } else {
      _ignoreDrag = false;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_ignoreDrag) return;
    if (_isSearchFocused) return;

    final double screenW = MediaQuery.of(context).size.width;
    final double standardSidebarW = screenW * 0.85;
    final double delta = details.primaryDelta!;

    if (_sidebarController.value >= 1.0 && delta > 0) {
      setState(() {
        double resistance = 1.0 - (_elasticWidth / (screenW * 0.3)).clamp(0.0, 0.4);
        _elasticWidth += delta * 0.7 * resistance;
      });
    } else if (_elasticWidth > 0) {
      setState(() {
        _elasticWidth += delta;
        if (_elasticWidth < 0) {
          double remainingDelta = _elasticWidth;
          _elasticWidth = 0.0;
          _sidebarController.value += remainingDelta / standardSidebarW;
        }
      });
    } else {
      _sidebarController.value += delta / standardSidebarW;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_ignoreDrag) {
      _ignoreDrag = false;
      return;
    }

    final double velocity = details.primaryVelocity!;

    if (_isSearchFocused && velocity < -500) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _isSearchFocused = false);
      _searchModeController.reverse();
      return;
    }

    if (_isSearchFocused) return;

    if (_elasticWidth > 0) {
      _runElasticSpringBack();
      _sidebarController.value = 1.0;
      return;
    }

    if (velocity > 0) {
      _animateSidebarTo(1.0);
    } else if (velocity < 0) {
      _animateSidebarTo(0.0);
    } else {
      if (_sidebarController.value > 0.5) {
        _animateSidebarTo(1.0);
      } else {
        _animateSidebarTo(0.0);
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

  void switchToLibrary() {
    setState(() => _currentView = MainScreenView.library);
    closeSidebar();
  }

  void openConversation(ConversationManager manager) async {
    _forceCloseKeyboard();
    await context.read<AppInitializer>().onCoreServicesReady;
    if (!mounted) return;

    setState(() => _currentView = MainScreenView.chat);

    final ReadService readService = context.read<ReadService>();
    final LocaleProvider localeProvider = context.read<LocaleProvider>();
    await readService.loadConversation(manager, languageCode: localeProvider.locale.languageCode);
    closeSidebar();
  }

  void startNewConversation({bool isDynamic = true}) {
    _forceCloseKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _currentView = MainScreenView.chat);
      final session = context.read<ChatSessionProvider>();
      final conv = context.read<ConversationProvider>();
      final input = context.read<InputProvider>();
      if (isDynamic) {
        session.startDynamicConversation();
      } else {
        session.resetSessionState();
      }
      conv.clearConversation();
      input.resetInputState();
      closeSidebar();
    });
  }

  void startChatWithModel(ModelEntity model) {
    _forceCloseKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _currentView = MainScreenView.chat);
      context.read<SelectionService>().selectModel(model);
      if (Navigator.canPop(context)) Navigator.pop(context);
      closeSidebar();
    });
  }

  void _openNewsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8, maxChildSize: 0.95, minChildSize: 0.5, expand: false,
        builder: (_, __) => Container(padding: const EdgeInsets.all(16), child: const NewsSection()),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double standardSidebarWidth = screenWidth * 0.85;

    return Title(
      title: 'Cortex',
      color: AppColors.background,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic _) async {
          if (didPop) return;

          if (_isSearchFocused) {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => _isSearchFocused = false);
            _searchModeController.reverse();
            return;
          }

          if (!_sidebarController.isDismissed) {
            closeSidebar();
            return;
          }
          if (_currentView == MainScreenView.library) {
            setState(() => _currentView = MainScreenView.chat);
            return;
          }
          if (MediaQuery.of(context).viewInsets.bottom > 0) {
            _forceCloseKeyboard();
            return;
          }
          final ChatControllerState? chatControllerState = chatScreenKey.currentState;
          if (chatControllerState != null && !chatControllerState.handleSystemBackPress()) return;
          final bool shouldExit = await showExitConfirmationDialog(context);
          if (shouldExit) SystemNavigator.pop();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          body: GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: AnimatedBuilder(
              animation: Listenable.merge([_sidebarController, _elasticController, _searchModeController]),
              builder: (context, child) {

                final double rawValue = _sidebarController.value;
                final double searchValue = Curves.easeInOutCubic.transform(_searchModeController.value);

                final double visibleSidebarWidth = standardSidebarWidth + _elasticWidth;
                final double currentSidebarWidth =
                    visibleSidebarWidth + ((screenWidth - visibleSidebarWidth) * searchValue);

                final double sidebarOpenOffset = (standardSidebarWidth * rawValue) + _elasticWidth;
                final double searchOffset = (screenWidth - sidebarOpenOffset) * searchValue;
                final double mainScreenX = sidebarOpenOffset + searchOffset;

                double sidebarParallaxX = -(standardSidebarWidth * 0.25) * (1.0 - rawValue);
                if (searchValue > 0) {
                  sidebarParallaxX = sidebarParallaxX * (1.0 - searchValue);
                }

                return Stack(
                  children: [
                    // --- LAYER 1: SIDEBAR (Back) ---
                    Transform.translate(
                      offset: Offset(sidebarParallaxX, 0),
                      child: SizedBox(
                        width: currentSidebarWidth,
                        height: MediaQuery.of(context).size.height,
                        child: Sidebar(
                          onNewChatTap: () => startNewConversation(isDynamic: true),
                          onLibraryTap: switchToLibrary,
                          onNewsTap: _openNewsModal,
                          onCloseSidebar: closeSidebar,
                          onOpenSidebar: () => _animateSidebarTo(1.0),
                          onOfflineModeChanged: (val) {},
                          onSearchFocusChanged: _handleSearchFocusChanged,
                          referenceWidth: standardSidebarWidth,
                        ),
                      ),
                    ),

                    // --- LAYER 2: MAIN SCREEN (Front) ---
// --- LAYER 2: MAIN SCREEN (Front) ---
                    Transform.translate(
                      offset: Offset(mainScreenX, 0),
                      child: Transform.scale(
                        scale: 1.0 - (0.07 * rawValue),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            boxShadow: [
                              if (rawValue > 0)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3 * rawValue),
                                  blurRadius: 50,
                                  spreadRadius: -10,
                                  offset: const Offset(-20, 0),
                                )
                            ],
                            borderRadius: BorderRadius.circular(30.0 * rawValue),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.0 * rawValue),
                            child: Stack(
                              children: [
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: 3.0 * rawValue,
                                    sigmaY: 3.0 * rawValue,
                                  ),
                                  child: Stack(
                                    children: [
                                      IndexedStack(
                                        index: _currentView == MainScreenView.chat ? 0 : 1,
                                        children: [
                                          ChatController(key: chatScreenKey),
                                          const LibraryScreen(),
                                        ],
                                      ),

                                      if (rawValue > 0)
                                        Container(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white.withValues(alpha: 0.04 * rawValue)
                                              : Colors.black.withValues(alpha: 0.02 * rawValue),
                                        ),
                                    ],
                                  ),
                                ),

                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 2.0,
                                    height: (MediaQuery.of(context).size.height * 0.6) * rawValue,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Theme.of(context).dividerColor.withValues(alpha: 0.0),
                                          Theme.of(context).dividerColor.withValues(alpha: 0.5),
                                          Theme.of(context).dividerColor.withValues(alpha: 0.5),
                                          Theme.of(context).dividerColor.withValues(alpha: 0.0),
                                        ],
                                        stops: const [0.0, 0.3, 0.7, 1.0],
                                      ),
                                    ),
                                  ),
                                ),

                                if (rawValue > 0 && searchValue == 0)
                                  GestureDetector(
                                    onTap: closeSidebar,
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
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}