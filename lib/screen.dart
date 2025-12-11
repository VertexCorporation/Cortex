// lib/screen.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'chat/main/controller.dart';
import 'chat/providers/conversation.dart';
import 'chat/providers/input.dart';
import 'chat/providers/session.dart';
import 'chat/services/read.dart';
import 'chat/services/select.dart';
import 'exit.dart';
import 'inbox/manager.dart';
import 'inbox/screen.dart';
import 'initialization.dart';
import 'l10n/app_localizations.dart';
import 'language.dart';
import 'library/backend/data/entity.dart';
import 'library/providers/catalog.dart';
import 'library/providers/local.dart';
import 'library/screen/models/controller.dart';
import 'main.dart';
import 'notifications/introvert.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final GlobalKey<ChatControllerState> chatScreenKey =
  GlobalKey<ChatControllerState>();
  final GlobalKey<InboxScreenState> inboxScreenKey =
  GlobalKey<InboxScreenState>();
  final GlobalKey<LibraryScreenState> libraryScreenKey =
  GlobalKey<LibraryScreenState>();

  int _previousTabIndex = 0;
  bool hideBottomAppBar = false;
  bool _wasInAllModelsView = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ModelCatalogProvider>().initialize(context: context);
      context.read<ModelLocalStateProvider>().initialize(context: context);
    });
  }

  void onItemTapped(int index, {bool pulseOffline = false}) {
    final TabProvider tabProvider =
    Provider.of<TabProvider>(context, listen: false);

    if (tabProvider.selectedIndex != index) {
      setState(() {
        _previousTabIndex = tabProvider.selectedIndex;
      });
    }

    if (index == 0) {
      chatScreenKey.currentState?.onReactivated();
    }

    if (index == 1 && pulseOffline) {
      debugPrint("[MainScreen] Explicit Pulse request received via Navigation.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        libraryScreenKey.currentState?.triggerPulseAnimation();
      });
    }

    tabProvider.setSelectedIndex(index);
  }

  void updateBottomAppBarVisibility([bool value = false]) {
    if (hideBottomAppBar == value) return;

    setState(() {
      hideBottomAppBar = value;
    });

    final introvertService =
    Provider.of<IntrovertNotificationService>(context, listen: false);
    introvertService.updateBottomBarVisibility(!hideBottomAppBar);

    try {
      Provider.of<ThemeProvider>(context, listen: false)
          .updateSystemUIOverlayStyle();
    } catch (_) {}
  }

  void openConversation(ConversationManager manager) async {
    final TabProvider tabProvider =
    Provider.of<TabProvider>(context, listen: false);

    setState(() {
      _previousTabIndex = tabProvider.selectedIndex;
    });

    tabProvider.setSelectedIndex(0);

    await context.read<AppInitializer>().onCoreServicesReady;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final ReadService readService = context.read<ReadService>();
      final LocaleProvider localeProvider = context.read<LocaleProvider>();

      readService.loadConversation(
        manager,
        languageCode: localeProvider.locale.languageCode,
      );
    });
  }

  void startNewConversation({bool isDynamic = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final TabProvider tabProvider =
      Provider.of<TabProvider>(context, listen: false);

      if (tabProvider.selectedIndex != 0) {
        setState(() {
          _previousTabIndex = tabProvider.selectedIndex;
        });
        tabProvider.setSelectedIndex(0);
      }

      final ChatSessionProvider sessionProvider =
      context.read<ChatSessionProvider>();
      final ConversationProvider conversationProvider =
      context.read<ConversationProvider>();
      final InputProvider inputProvider = context.read<InputProvider>();

      if (isDynamic) {
        sessionProvider.startDynamicConversation();
      } else {
        sessionProvider.resetSessionState();
      }

      conversationProvider.clearConversation();
      inputProvider.resetInputState();

      updateBottomAppBarVisibility(true);
    });
  }

  void startChatWithModel(ModelEntity model) {
    final TabProvider tabProvider =
    Provider.of<TabProvider>(context, listen: false);
    final ChatSessionProvider sessionProvider =
    context.read<ChatSessionProvider>();

    if (sessionProvider.appBarMode == AppBarMode.inSelection) {
      setState(() {
        _wasInAllModelsView = true;
      });
    }

    setState(() {
      _previousTabIndex = tabProvider.selectedIndex;
    });

    tabProvider.setSelectedIndex(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final SelectionService selectionService =
      context.read<SelectionService>();
      selectionService.selectModel(model);
    });
  }

  Future<void> _handleChatExit() async {
    await chatScreenKey.currentState?.handleExit();

    if (mounted) {
      Provider.of<TabProvider>(context, listen: false)
          .setSelectedIndex(_previousTabIndex);
    }

    if (_wasInAllModelsView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        chatScreenKey.currentState?.inactiveChatViewKey.currentState
            ?.showAllModelsView();
      });
      setState(() {
        _wasInAllModelsView = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TabProvider tabProvider = Provider.of<TabProvider>(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final bool isTablet = screenSize.shortestSide >= 600;

    final double bottomBarHeight = isTablet ? 80.0 : screenHeight * 0.09;
    final double iconBaseSize = isTablet ? 28.0 : screenHeight * 0.028;
    final double iconContainerSize = iconBaseSize * 1.2;
    final double labelSpacing = isTablet ? 6.0 : screenHeight * 0.002;
    final double shadowBlurRadius = isTablet ? 10.0 : screenWidth * 0.02;
    final double borderRadius = isTablet ? 24.0 : screenWidth * 0.04;
    final double horizontalPadding = isTablet ? screenWidth * 0.15 : 0.0;

    final bool useExpandedButtons = !isTablet;
    final bool shouldHideBottomAppBar = hideBottomAppBar;

    return Title(
      title: 'Cortex',
      color: AppColors.background,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic _) async {
          if (didPop) return;

          final bool isKeyboardVisible =
              MediaQuery.of(context).viewInsets.bottom > 0;
          if (isKeyboardVisible) {
            FocusScope.of(context).unfocus();
            return;
          }

          final ChatControllerState? chatControllerState =
              chatScreenKey.currentState;

          if (chatControllerState == null) {
            final bool shouldExit = await showExitConfirmationDialog(context);
            if (shouldExit) {
              SystemNavigator.pop();
            }
            return;
          }

          if (!chatControllerState.handleSystemBackPress()) {
            return;
          }

          final ChatSessionProvider sessionProvider =
          context.read<ChatSessionProvider>();
          final AppBarMode currentMode = sessionProvider.appBarMode;

          if (currentMode == AppBarMode.inSelection) {
            chatControllerState.inactiveChatViewKey.currentState
                ?.showSelectionView();
            return;
          }

          if (sessionProvider.isChatActive) {
            await _handleChatExit();
            return;
          }

          final bool shouldExit = await showExitConfirmationDialog(context);
          if (shouldExit) {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: FadeIndexedStack(
            index: tabProvider.selectedIndex,
            duration: const Duration(milliseconds: 200),
            children: <Widget>[
              Consumer<ChatSessionProvider>(
                builder: (context, sessionProvider, _) {
                  return ChatController(
                    key: chatScreenKey,
                    onModelSelectionChanged: (bool isSelected) {
                      updateBottomAppBarVisibility(isSelected);
                    },
                    onExitRequest: _handleChatExit,
                  );
                },
              ),
              LibraryScreen(
                key: libraryScreenKey,
              ),
              InboxScreen(key: inboxScreenKey),
            ],
          ),
          bottomNavigationBar: shouldHideBottomAppBar
              ? null
              : Consumer<ThemeProvider>(
            builder: (
                BuildContext context,
                ThemeProvider themeProvider,
                Widget? child,
                ) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primaryColor.inverted
                          .withValues(alpha: 0.1),
                      blurRadius: shadowBlurRadius,
                      offset: Offset(0, -2.0),
                    ),
                  ],
                ),
                child: BottomAppBar(
                  color: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  child: Container(
                    height: bottomBarHeight,
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding),
                    child: Row(
                      mainAxisAlignment: isTablet
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        BottomNavigationButton(
                          iconPath: 'assets/icons/inbox.svg',
                          label: appLocalizations.chats,
                          isSelected: tabProvider.selectedIndex == 2,
                          onTap: () => onItemTapped(2),
                          baseSize: iconBaseSize,
                          containerSize: iconContainerSize,
                          labelSpacing: labelSpacing,
                          useExpanded: useExpandedButtons,
                        ),
                        BottomNavigationButton(
                          iconPath: 'assets/icons/chat.svg',
                          label: appLocalizations.chat,
                          isSelected: tabProvider.selectedIndex == 0,
                          onTap: () => onItemTapped(0),
                          baseSize: iconBaseSize,
                          containerSize: iconContainerSize,
                          labelSpacing: labelSpacing,
                          useExpanded: useExpandedButtons,
                        ),
                        BottomNavigationButton(
                          iconPath: 'assets/icons/library.svg',
                          label: appLocalizations.library,
                          isSelected: tabProvider.selectedIndex == 1,
                          onTap: () => onItemTapped(1),
                          baseSize: iconBaseSize,
                          containerSize: iconBaseSize * 1.2,
                          labelSpacing: labelSpacing,
                          useExpanded: useExpandedButtons,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A reusable, animated bottom navigation button used in [MainScreen].
class BottomNavigationButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double baseSize;
  final double containerSize;
  final double labelSpacing;
  final bool useExpanded;

  const BottomNavigationButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.baseSize = 20.0,
    this.containerSize = 24.0,
    this.labelSpacing = 2.0,
    this.useExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected
        ? AppColors.primaryColor.inverted
        : AppColors.tertiaryColor;

    Widget content = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: containerSize,
            height: containerSize,
            child: Center(
              child: AnimatedScale(
                scale: isSelected ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: SvgPicture.asset(
                  iconPath,
                  width: baseSize,
                  height: baseSize,
                  colorFilter: ColorFilter.mode(
                    iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: labelSpacing),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: baseSize * 0.5,
              color: iconColor,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );

    if (useExpanded) {
      return Expanded(child: content);
    }

    return Flexible(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 120.0),
        child: content,
      ),
    );
  }
}

class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.children.asMap().entries.map((entry) {
        final int childIndex = entry.key;
        final Widget child = entry.value;
        final bool isActive = childIndex == widget.index;

        return _SmartFadeItem(
          isActive: isActive,
          duration: widget.duration,
          child: child,
        );
      }).toList(),
    );
  }
}

class _SmartFadeItem extends StatefulWidget {
  final bool isActive;
  final Duration duration;
  final Widget child;

  const _SmartFadeItem({
    required this.isActive,
    required this.duration,
    required this.child,
  });

  @override
  State<_SmartFadeItem> createState() => _SmartFadeItemState();
}

class _SmartFadeItemState extends State<_SmartFadeItem> {
  late bool _isOffstage;

  @override
  void initState() {
    super.initState();
    _isOffstage = !widget.isActive;
  }

  @override
  void didUpdateWidget(_SmartFadeItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && _isOffstage) {
      setState(() {
        _isOffstage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !_isOffstage,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: AnimatedOpacity(
        opacity: widget.isActive ? 1.0 : 0.0,
        duration: widget.duration,
        curve: Curves.easeInOut,
        onEnd: () {
          if (!widget.isActive) {
            setState(() {
              _isOffstage = true;
            });
          }
        },
        child: widget.child,
      ),
    );
  }
}