// lib/screen.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'chat/main/controller.dart';
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
import 'sidebar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final GlobalKey<ChatControllerState> chatScreenKey = GlobalKey<ChatControllerState>();

  late AnimationController _sidebarController;
  AnimationController? _elasticController; // Dedicated controller for the spring-back

  // Extra width dragged beyond the 85% mark
  double _elasticWidth = 0.0;

  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350), // Base duration
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
    _elasticController?.dispose();
    super.dispose();
  }

  // --- DRAWER & GESTURE LOGIC ---

  void toggleSidebar() {
    if (_sidebarController.isDismissed) {
      _animateSidebarTo(1.0);
      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      _closeSidebarWithAnimation();
    }
  }

  void closeSidebar() {
    if (!_sidebarController.isDismissed) {
      _closeSidebarWithAnimation();
    }
  }

  void _closeSidebarWithAnimation() {
    if (_isSearchFocused) setState(() => _isSearchFocused = false);
    FocusManager.instance.primaryFocus?.unfocus();

    // Snap elastic to 0 immediately if closing
    if (_elasticWidth > 0) {
      setState(() => _elasticWidth = 0.0);
    }
    _animateSidebarTo(0.0);
  }

  /// Animates the sidebar with dynamic duration based on distance
  void _animateSidebarTo(double target) {
    // Calculate how far we need to go (0.0 to 1.0)
    final double dist = (target - _sidebarController.value).abs();

    // Adjust duration: Short distance = faster, Long distance = slower (but capped)
    // This fixes the "slow start" issue.
    final int ms = (350 * dist).clamp(150, 350).toInt();

    _sidebarController.animateTo(
      target,
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutQuart, // Very smooth, mobile-native feel
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isSearchFocused) return;

    final double screenW = MediaQuery.of(context).size.width;
    final double standardSidebarW = screenW * 0.85;
    final double delta = details.primaryDelta!;

    // 1. Elastic Drag (Pulling right when already Open)
    if (_sidebarController.value >= 1.0 && delta > 0) {
      setState(() {
        // Resistance Factor: 0.25 (Feel free to tweak: 0.1 is stiff, 0.5 is loose)
        // Logarithmic resistance makes it harder to pull the further you go
        double resistance = 1.0 - (_elasticWidth / (screenW * 0.3)).clamp(0.0, 0.8);
        _elasticWidth += delta * 0.25 * resistance;
      });
    }
    // 2. Recovering from Elasticity (Pushing left back to standard width)
    else if (_elasticWidth > 0) {
      setState(() {
        _elasticWidth += delta;
        // If we pushed back past 0, start closing the sidebar normally
        if (_elasticWidth < 0) {
          double remainingDelta = _elasticWidth; // Negative value
          _elasticWidth = 0.0;
          _sidebarController.value += remainingDelta / standardSidebarW;
        }
      });
    }
    // 3. Normal Slide (0% to 100% of Sidebar)
    else {
      _sidebarController.value += delta / standardSidebarW;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isSearchFocused) return;

    final double velocity = details.primaryVelocity!;

    // 1. Handle Elastic Spring Back
    if (_elasticWidth > 0) {
      _runElasticSpringBack();
      // Ensure sidebar stays open
      _sidebarController.value = 1.0;
      return;
    }

    // 2. Fling Logic (Fast Swipe)
    if (velocity.abs() > 300) {
      if (velocity > 0) {
        _animateSidebarTo(1.0); // Fling Open
      } else {
        _animateSidebarTo(0.0); // Fling Close
      }
      return;
    }

    // 3. Static Position Logic (No Fling)
    if (_sidebarController.value > 0.5) {
      _animateSidebarTo(1.0);
    } else {
      _animateSidebarTo(0.0);
    }
  }

  void _runElasticSpringBack() {
    _elasticController?.dispose();
    _elasticController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Longer duration for bouncy feel
    );

    final double startElastic = _elasticWidth;

    // ElasticOut curve gives that nice "boing" effect
    final Animation<double> curve = CurvedAnimation(
      parent: _elasticController!,
      curve: Curves.elasticOut,
    );

    _elasticController!.addListener(() {
      setState(() {
        _elasticWidth = startElastic * (1 - curve.value);
      });
    });

    _elasticController!.forward();
  }

  // --- NAVIGATION HELPERS ---
  void openLibraryScreen() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LibraryScreen()));

  void openConversation(ConversationManager manager) async {
    _forceCloseKeyboard();
    await context.read<AppInitializer>().onCoreServicesReady;
    if (!mounted) return;
    final ReadService readService = context.read<ReadService>();
    final LocaleProvider localeProvider = context.read<LocaleProvider>();
    await readService.loadConversation(manager, languageCode: localeProvider.locale.languageCode);
    closeSidebar();
  }

  void startNewConversation({bool isDynamic = true}) {
    _forceCloseKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
      context.read<SelectionService>().selectModel(model);
      if (Navigator.canPop(context)) Navigator.pop(context);
      closeSidebar();
    });
  }

  void _openNewsModal() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: AppColors.background,
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
          if (!_sidebarController.isDismissed) {
            closeSidebar();
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
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: AnimatedBuilder(
              animation: Listenable.merge([_sidebarController, _elasticController]),
              builder: (context, child) {

                // Use the controller value directly for linear-mapped logic,
                // but use a Curve for opacity to make it look nicer.
                final double rawValue = _sidebarController.value;
                final double curvedValue = Curves.easeOutQuad.transform(rawValue);

                // --- CALCULATIONS ---

                // 1. Sidebar Width Logic
                // If search is focused, full screen.
                // Else: Standard Width + Elastic Drag
                final double currentSidebarWidth = _isSearchFocused
                    ? screenWidth
                    : (standardSidebarWidth + _elasticWidth);

                // 2. Main Screen Translation (X Axis)
                // Moves right by Standard Width * Progress + Elastic Drag
                double mainScreenX = (standardSidebarWidth * rawValue);
                if (!_isSearchFocused) mainScreenX += _elasticWidth;

                // 3. Sidebar Translation (Parallax Effect)
                // Starts at -25% (offset left). Moves to 0.
                // This creates the depth effect.
                // If elastic > 0, we lock it to 0 so it feels anchored while stretching.
                double sidebarParallaxX = -(standardSidebarWidth * 0.25) * (1.0 - rawValue);

                if (_isSearchFocused || _elasticWidth > 0) {
                  sidebarParallaxX = 0;
                }

                // 4. Overlay Dimming
                double dimOpacity = (curvedValue * 0.5).clamp(0.0, 1.0);

                return Stack(
                  children: [
                    // --- LAYER 1: SIDEBAR ---
                    Transform.translate(
                      offset: Offset(sidebarParallaxX, 0),
                      child: SizedBox(
                        width: currentSidebarWidth,
                        height: MediaQuery.of(context).size.height,
                        child: Sidebar(
                          onNewChatTap: () => startNewConversation(isDynamic: true),
                          onLibraryTap: openLibraryScreen,
                          onNewsTap: _openNewsModal,
                          onOfflineModeChanged: (val) {},
                          onSearchFocusChanged: (focused) {
                            setState(() => _isSearchFocused = focused);
                          },
                          // Pass standard width so internal items don't stretch weirdly
                          referenceWidth: standardSidebarWidth,
                        ),
                      ),
                    ),

                    // --- LAYER 2: MAIN SCREEN ---
                    Transform.translate(
                      offset: Offset(mainScreenX, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          boxShadow: [
                            // Shadow grows as drawer opens
                            if (rawValue > 0)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3 * rawValue),
                                blurRadius: 30,
                                spreadRadius: -5,
                                offset: const Offset(-10, 0),
                              )
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Chat Screen
                            ChatController(key: chatScreenKey),

                            // Dimming Overlay
                            if (rawValue > 0 && !_isSearchFocused)
                              IgnorePointer(
                                ignoring: false,
                                child: GestureDetector(
                                  onTap: closeSidebar,
                                  child: Container(
                                    color: Colors.black.withValues(alpha: dimOpacity),
                                  ),
                                ),
                              ),
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
    );
  }
}