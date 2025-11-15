// lib/screen.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
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

/// The main screen containing bottom navigation and the three primary app
/// sections:
/// - Chat
/// - Library
/// - Menu
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

  int _previousTabIndex = 0;
  bool hideBottomAppBar = false;
  bool _showOfflinePulse = false;
  bool _wasInAllModelsView = false;

  @override
  void initState() {
    super.initState();

    // Initialize model catalog and local state once the context is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ModelCatalogProvider>().initialize(context: context);
      context.read<ModelLocalStateProvider>().initialize(context: context);
    });
  }

  void onItemTapped(int index, {bool pulseOffline = false}) {
    final TabProvider tabProvider =
    Provider.of<TabProvider>(context, listen: false);

    // Only update previous index when the tab actually changes.
    if (tabProvider.selectedIndex != index) {
      setState(() {
        _previousTabIndex = tabProvider.selectedIndex;
      });
    }

    if (index == 0) {
      // Reactivate chat screen when returning to it.
      chatScreenKey.currentState?.onReactivated();
    }

    if (mounted && index == 1 && pulseOffline) {
      setState(() {
        _showOfflinePulse = true;
      });
    }

    tabProvider.setSelectedIndex(index);
  }

  /// Controls the visibility of the bottom navigation bar.
  void updateBottomAppBarVisibility([bool value = false]) {
    if (hideBottomAppBar == value) return;

    setState(() {
      hideBottomAppBar = value;
    });

    final introvertService =
    Provider.of<IntrovertNotificationService>(context, listen: false);
    introvertService.updateBottomBarVisibility(!hideBottomAppBar);

    Provider.of<ThemeProvider>(context, listen: false)
        .updateSystemUIOverlayStyle();
  }

  /// Open an existing conversation from the inbox/manager.
  void openConversation(ConversationManager manager) async {
    final TabProvider tabProvider =
    Provider.of<TabProvider>(context, listen: false);

    setState(() {
      _previousTabIndex = tabProvider.selectedIndex;
    });

    tabProvider.setSelectedIndex(0);

    // Ensure core services are fully ready.
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

  /// Starts a brand new conversation on the chat tab.
  void startNewConversation({bool isDynamic = false}) {
    final TabProvider tabProvider =
    Provider.of<TabProvider>(context, listen: false);

    setState(() {
      _previousTabIndex = tabProvider.selectedIndex;
    });

    tabProvider.setSelectedIndex(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

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

  /// Starts a new chat with the given [ModelEntity].
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

  /// Handles exiting the chat context back to the previously active tab.
  Future<void> _handleChatExit() async {
    // 1. Allow the ChatController to clean up any internal state.
    await chatScreenKey.currentState?.handleExit();

    // 2. Switch back to the previously active tab.
    if (mounted) {
      Provider.of<TabProvider>(context, listen: false)
          .setSelectedIndex(_previousTabIndex);
    }

    // 3. Restore "All Models" view if we were in it before entering chat.
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

    final List<Widget> screens = <Widget>[
      ChatController(
        key: chatScreenKey,
        onModelSelectionChanged: (bool isSelected) {
          updateBottomAppBarVisibility(isSelected);
        },
        onExitRequest: _handleChatExit,
      ),
      LibraryScreen(
        key: const ValueKey<String>('Models'),
        showOfflineModelsPulse: _showOfflinePulse,
      ),
      InboxScreen(key: inboxScreenKey),
    ];

    // Reset the offline pulse after first frame if it was set.
    if (_showOfflinePulse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _showOfflinePulse = false;
        });
      });
    }

    // Update app switcher description for multitasking UI.
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: 'Cortex',
        primaryColor: AppColors.background.toARGB32(),
      ),
    );

    final double bottomBarHeight = screenHeight * 0.09;
    final double iconBaseSize = screenHeight * 0.028;
    final double libraryIconSize = screenHeight * 0.022;
    final double iconContainerSize = iconBaseSize * 1.2;
    final double labelSpacing = screenHeight * 0.002;
    final double shadowBlurRadius = screenWidth * 0.02;
    final double borderRadius = screenWidth * 0.04;
    final bool shouldHideBottomAppBar = hideBottomAppBar;

    return PopScope(
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

        // If there is no chat controller yet, we handle a direct app-exit case.
        if (chatControllerState == null) {
          final bool shouldExit = await showExitConfirmationDialog(context);
          if (shouldExit) {
            SystemNavigator.pop();
          }
          return;
        }

        // Let ChatController consume the back press first (e.g. close drawers, etc.).
        if (!chatControllerState.handleSystemBackPress()) {
          return;
        }

        final ChatSessionProvider sessionProvider =
        context.read<ChatSessionProvider>();
        final AppBarMode currentMode = sessionProvider.appBarMode;

        // If we are in model selection, switch to selection view instead of exiting.
        if (currentMode == AppBarMode.inSelection) {
          chatControllerState.inactiveChatViewKey.currentState
              ?.showSelectionView();
          return;
        }

        // If a chat is active, exit back to the previous tab instead of quitting the app.
        if (sessionProvider.isChatActive) {
          await _handleChatExit();
          return;
        }

        // Final fallback: ask user if they want to exit the app.
        final bool shouldExit = await showExitConfirmationDialog(context);
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder:
              (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: screens[tabProvider.selectedIndex],
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
                    offset: Offset(0, -screenHeight * 0.0025),
                  ),
                ],
              ),
              child: BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                child: SizedBox(
                  height: bottomBarHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      BottomNavigationButton(
                        iconPath: 'assets/icons/inbox.svg',
                        label: appLocalizations.chats,
                        isSelected: tabProvider.selectedIndex == 2,
                        onTap: () => onItemTapped(2),
                        baseSize: iconBaseSize,
                        containerSize: iconContainerSize,
                        labelSpacing: labelSpacing,
                      ),
                      BottomNavigationButton(
                        iconPath: 'assets/icons/chat.svg',
                        label: appLocalizations.chat,
                        isSelected: tabProvider.selectedIndex == 0,
                        onTap: () => onItemTapped(0),
                        baseSize: iconBaseSize,
                        containerSize: iconContainerSize,
                        labelSpacing: labelSpacing,
                      ),
                      BottomNavigationButton(
                        iconPath: 'assets/icons/library.svg',
                        label: appLocalizations.library,
                        isSelected: tabProvider.selectedIndex == 1,
                        onTap: () => onItemTapped(1),
                        baseSize: libraryIconSize,
                        containerSize: libraryIconSize * 1.2,
                        labelSpacing: labelSpacing,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
  const BottomNavigationButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.baseSize = 20.0,
    this.containerSize = 24.0,
    this.labelSpacing = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected
        ? AppColors.primaryColor.inverted
        : AppColors.tertiaryColor;

    return Expanded(
      child: GestureDetector(
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
              style: GoogleFonts.roboto(
                fontSize: baseSize * 0.5,
                color: iconColor,
                fontWeight:
                isSelected ? FontWeight.w500 : FontWeight.normal,
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
      ),
    );
  }
}