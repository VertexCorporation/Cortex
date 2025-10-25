// app.dart
//
// Defines the visual structure and user interface of the Cortex application.
// This includes the root MaterialApp widget, lifecycle management, the main screen
// with its navigation, and other UI-related components and helpers.

import 'dart:async';

import 'package:cortex/chat/main/controller.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/read.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/conversations/manager.dart';
import 'package:cortex/darkener.dart';
import 'package:cortex/errorview.dart';
import 'package:cortex/initialization.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/language.dart';
import 'package:cortex/login/screen.dart';
import 'package:cortex/login/verify.dart';
import 'package:cortex/main.dart';
import 'package:cortex/models/screen/models.dart';
import 'package:cortex/notifications.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'conversations/inbox.dart';
import 'models/backend/data/info.dart';

/// The widget that acts as the main router for the application's lifecycle.
/// It listens to the `AppInitializer` service and displays the appropriate screen
/// based on the current application state (e.g., initializing, logged in, needs login).
class AppLifecycleManager extends StatefulWidget {
  const AppLifecycleManager({super.key});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

/// The widget that acts as the main router for the application's lifecycle.
/// It listens to the `AppInitializer` service and displays the appropriate screen
/// based on the current application state (e.g., initializing, logged in, needs login).
class _AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {
  AppStatus? _previousStatus;

  final Widget _mainScreen = MainScreen(key: mainScreenKey);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final initializer = Provider.of<AppInitializer>(context, listen: false);
    _previousStatus = initializer.status;
    initializer.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    context.read<NotificationService>().handleAppLifecycleStateChange(state);
    debugPrint("App Lifecycle State Changed: $state");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInitializer>(
      builder: (context, initializer, child) {
        final currentStatus = initializer.status;
        debugPrint("AppLifecycleManager: Rebuilding. Current: $currentStatus, Previous: $_previousStatus");

        if ((_previousStatus == AppStatus.ready || _previousStatus == AppStatus.initializing) && currentStatus == AppStatus.needsLogin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (navigatorKey.currentState != null && navigatorKey.currentState!.canPop()) {
              debugPrint("AppLifecycleManager: Logout!");
              navigatorKey.currentState!.popUntil((route) => route.isFirst);
            }
          });
        }
        _previousStatus = currentStatus;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildScreenForStatus(initializer),
        );
      },
    );
  }

  Widget _buildScreenForStatus(AppInitializer initializer) {
    final status = initializer.status;

    switch (status) {
      case AppStatus.needsLogin:
        return const AuthScreen(key: ValueKey('AuthScreen'));

      case AppStatus.needsVerification:
        final verificationData = initializer.verificationScreenData;
        if (verificationData != null) {
          return EmailVerificationScreen(
            key: const ValueKey('VerificationScreen'),
            email: verificationData['email'],
            username: verificationData['username'],
            userId: verificationData['userId'],
            password: '',
          );
        }
        return const AuthScreen(key: ValueKey('AuthScreen_Fallback'));

      case AppStatus.maintenance:
        return const MaintenanceScreen(key: ValueKey('MaintenanceScreen'));

      case AppStatus.updateRequired:
        return UpgradeAlert(
          key: const ValueKey('UpgradeScreen'),
          upgrader: initializer.upgrader,
          barrierDismissible: false,
          showIgnore: false,
          showLater: false,
          child: const Scaffold(
              body: Center(child: Text("Checking for updates..."))),
        );

      case AppStatus.initializing:
      case AppStatus.ready:
        return _mainScreen;
    }
  }
}

/// The main application widget that sets up MaterialApp.
class Cortex extends StatelessWidget {
  const Cortex({super.key, required this.navigatorKey, this.startupScreen});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget? startupScreen;

  ThemeData _buildTheme(String currentTheme) {
    final bool isDark = currentTheme == 'dark';
    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();
    return baseTheme.copyWith(
      primaryColor: AppColors.background,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: baseTheme.colorScheme.copyWith(
          primary: AppColors.primaryColor.inverted,
          onPrimary: AppColors.primaryColor,
          secondary: AppColors.border,
          onSecondary: AppColors.quaternaryColor,
          surface: AppColors.background,
          onSurface: AppColors.border,
          error: AppColors.septenaryColor),
      textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primaryColor.inverted,
          selectionColor: AppColors.quaternaryColor),
      inputDecorationTheme: InputDecorationTheme(
          focusColor: AppColors.primaryColor.inverted,
          hintStyle: TextStyle(color: AppColors.tertiaryColor),
          labelStyle: TextStyle(color: AppColors.tertiaryColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: _buildTheme(themeProvider.currentTheme),
      builder: (context, child) {
        themeProvider.updateSystemUIOverlayStyle();
        return child!;
      },
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        final chosenLocale = localeProvider.locale;
        if (kUnsupportedMaterialLocales.contains(chosenLocale.languageCode)) {
          return const Locale('en');
        }
        return chosenLocale;
      },
      home: startupScreen,
    );
  }
}

/// A screen to display during server maintenance.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ErrorView(
        title: appLocalizations.maintenanceTitle,
        message: appLocalizations.maintenanceMessage,
      ),
    );
  }
}

bool _isFirstSessionLaunch = true;

/// The main screen containing the bottom navigation and primary app views.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ChatControllerState> chatScreenKey = GlobalKey<ChatControllerState>();
  final GlobalKey<MenuScreenState> menuScreenKey = GlobalKey<MenuScreenState>();
  int _previousTabIndex = 0;
  bool hideBottomAppBar = false;
  bool _showOfflinePulse = false;
  bool _wasInAllModelsView = false;

  @override
  void initState() {
    super.initState();
    debugPrint("MainScreen: Initializing state...");

    if (_isFirstSessionLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          startNewConversation(isDynamic: true);
          _isFirstSessionLaunch = false;
        }
      });
    }
  }

  void onItemTapped(int index, {bool pulseOffline = false}) {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);

    // Only update if the index is actually changing to avoid self-referencing
    if (tabProvider.selectedIndex != index) {
      setState(() {
        _previousTabIndex = tabProvider.selectedIndex;
      });
    }

    if (index == 0) {
      chatScreenKey.currentState?.onReactivated();
    }

    if (mounted && index == 1 && pulseOffline) {
      setState(() {
        _showOfflinePulse = true;
      });
    }
    tabProvider.setSelectedIndex(index);
  }

  void updateBottomAppBarVisibility([bool value = false]) {
    if (hideBottomAppBar == value) return;
    setState(() {
      hideBottomAppBar = value;
    });
    Provider.of<ThemeProvider>(context, listen: false).updateSystemUIOverlayStyle();
  }

  void openConversation(ConversationManager manager) async {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    // Remember the current tab before switching to the chat tab
    setState(() {
      _previousTabIndex = tabProvider.selectedIndex;
    });

    tabProvider.setSelectedIndex(0);

    await context.read<AppInitializer>().onCoreServicesReady;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final readService = context.read<ReadService>();
      final localeProvider = context.read<LocaleProvider>();
      readService.loadConversation(manager, languageCode: localeProvider.locale.languageCode);
    });
  }

  void startNewConversation({bool isDynamic = false}) {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);

    // Set the previous tab to the current one. If the app is just starting,
    // this defaults to the chat screen itself (index 0), which is the correct behavior.
    setState(() {
      _previousTabIndex = tabProvider.selectedIndex;
    });

    tabProvider.setSelectedIndex(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sessionProvider = context.read<ChatSessionProvider>();
      final conversationProvider = context.read<ConversationProvider>();
      final inputProvider = context.read<InputProvider>();

      if (isDynamic) {
        sessionProvider.startDynamicConversation();
        conversationProvider.clearConversation();
        inputProvider.resetInputState();
      } else {
        sessionProvider.resetSessionState();
        conversationProvider.clearConversation();
        inputProvider.resetInputState();
      }

      updateBottomAppBarVisibility(true);
    });
  }


  void startChatWithModel(ModelInfo modelInfo) {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    final sessionProvider = context.read<ChatSessionProvider>();

    if (sessionProvider.appBarMode == AppBarMode.inSelection) {
      setState(() {
        _wasInAllModelsView = true;
      });
    }

    // Unconditionally set the previous tab to the current one (e.g., Models screen)
    // before switching to the chat tab.
    setState(() {
      _previousTabIndex = tabProvider.selectedIndex;
    });

    tabProvider.setSelectedIndex(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final selectionService = context.read<SelectionService>();
      selectionService.selectModel(modelInfo);
    });
  }

  Future<void> _handleChatExit() async {
    // 1. Tell the ChatController to clean up its state
    await chatScreenKey.currentState?.handleExit();
    // 2. Navigate back to the previously active tab
    if (mounted) {
      Provider.of<TabProvider>(context, listen: false).setSelectedIndex(_previousTabIndex);
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
    final tabProvider = Provider.of<TabProvider>(context);
    final appLocalizations = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // MOVED & UPDATED: The _screens list is now defined directly inside the
    // build method. This ensures it's reconstructed with the latest
    // state values (like _showOfflinePulse) on every rebuild.
    final List<Widget> screens = [
      ChatController(
        key: chatScreenKey,
        onModelSelectionChanged: (isSelected) {
          updateBottomAppBarVisibility(isSelected);
        },
        onExitRequest: _handleChatExit,
      ),
      ModelsScreen(
        key: const ValueKey('Models'),
        showOfflineModelsPulse: _showOfflinePulse, // This now correctly receives the updated value
      ),
      MenuScreen(key: menuScreenKey),
    ];

    if (_showOfflinePulse) {
      // This logic correctly resets the pulse flag for the next build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showOfflinePulse = false;
          });
        }
      });
    }

    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: 'Cortex',
        primaryColor: AppColors.background.value,
      ),
    );

    final bottomBarHeight = screenHeight * 0.09;
    final iconBaseSize = screenHeight * 0.028;
    final libraryIconSize = screenHeight * 0.022;
    final iconContainerSize = iconBaseSize * 1.2;
    final labelSpacing = screenHeight * 0.002;
    final shadowBlurRadius = screenWidth * 0.02;
    final borderRadius = screenWidth * 0.04;
    final bool shouldHideBottomAppBar = hideBottomAppBar;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic _) async {
        if (didPop) return;
        final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
        if (isKeyboardVisible) {
          FocusScope.of(context).unfocus();
          return;
        }

        final chatControllerState = chatScreenKey.currentState;
        if (chatControllerState == null) {
          await showExitConfirmationDialog(context);
          return;
        }

        if (!chatControllerState.handleSystemBackPress()) {
          return; // Event was handled by ChatController.
        }

        final sessionProvider = context.read<ChatSessionProvider>();
        final currentMode = sessionProvider.appBarMode;

        if (currentMode == AppBarMode.inSelection) {
          chatControllerState.inactiveChatViewKey.currentState?.showSelectionView();
          return;
        }

        if (sessionProvider.isChatActive) {
          await _handleChatExit();
          return;
        }

        if (sessionProvider.isChatActive) {
          await chatControllerState.handleExit();
          return;
        }

        await showExitConfirmationDialog(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: screens[tabProvider.selectedIndex],
        ),
        bottomNavigationBar: shouldHideBottomAppBar
            ? null
            : Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
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

/// A reusable, animated button for the bottom navigation bar.
class BottomNavigationButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double baseSize, containerSize, labelSpacing;

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
    final Color iconColor = isSelected ? AppColors.primaryColor.inverted : AppColors.tertiaryColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: containerSize,
              height: containerSize,
              child: Center(
                child: AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: SvgPicture.asset(iconPath,
                      width: baseSize, height: baseSize, color: iconColor),
                ),
              ),
            ),
            SizedBox(height: labelSpacing),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.roboto(
                  fontSize: baseSize * 0.5,
                  color: iconColor,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal),
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a centralized dialog to confirm if the user wants to exit the app.
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final appLocalizations = AppLocalizations.of(context)!;
  final restoreNavBar = Darkener.darken();

  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'ExitConfirmation',
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.8,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          appLocalizations.exitAppTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor.inverted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                        Text(
                          appLocalizations.exitAppConfirmation,
                          style: TextStyle(
                            color: AppColors.primaryColor.inverted.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Divider(color: AppColors.border, thickness: 0.5, height: 1),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: AppColors.senaryColor.withValues(alpha: 0.1),
                              highlightColor: AppColors.senaryColor.withValues(alpha: 0.1),
                              onTap: () => Navigator.of(ctx).pop(false),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(appLocalizations.no, style: TextStyle(color: AppColors.senaryColor, fontSize: 16)),
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(width: 1, thickness: 0.5, color: AppColors.border),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: AppColors.septenaryColor.withValues(alpha: 0.1),
                              highlightColor: AppColors.septenaryColor.withValues(alpha: 0.1),
                              onTap: () => Navigator.of(ctx).pop(true),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(appLocalizations.yes, style: TextStyle(color: AppColors.septenaryColor, fontSize: 16)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ).whenComplete(() {
    restoreNavBar();
  });

  if (result == true) {
    SystemNavigator.pop();
    return true;
  }
  return false;
}

// Helper extension to make color inversion cleaner.
extension InvertedColor on Color {
  Color get inverted => Color.fromARGB(alpha, 255 - red, 255 - green, 255 - blue);
}

// List of locales with incomplete Material translations.
const List<String> kUnsupportedMaterialLocales = ['ku'];