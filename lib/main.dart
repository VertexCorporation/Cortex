// main.dart
//
// The primary entry point for the Cortex application. This file is responsible for
// setting up essential services, providers, and launching the core application structure.
// The startup logic is designed to be extremely fast, delegating heavy lifting to
// a dedicated service after the initial UI is rendered.

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/login/login.dart';
import 'package:cortex/login/verify.dart';
import 'package:cortex/server/credits.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'chat/chat.dart';
import 'chat/screen/unselected/news.dart';
import 'conversations/inbox.dart';
import 'conversations/manager.dart';
import 'errorview.dart';
import 'initialization.dart';
import 'internet.dart';
import 'language.dart';
import 'models/backend/download.dart';
import 'models/screen/models.dart';
import 'notifications.dart';
import 'theme.dart';
import 'package:timezone/data/latest_all.dart' as tz;

// Global keys for accessing specific widget states across the application.
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Entry point for the Flutter Downloader background isolate.
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("--- Background Message Handler ---");
  debugPrint("Handling a background message: ${message.messageId}");
  debugPrint("Title: ${message.notification?.title}");
  debugPrint("Body: ${message.notification?.body}");
  debugPrint("Data: ${message.data}");
}

/// Manages the selected tab index for the bottom navigation bar.
class TabProvider with ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}

/// The main entry point of the application.
/// It now performs a rapid, synchronous check for a cached user session
/// to prevent a UI flash on startup. Heavy async operations are still
/// delegated to the AppInitializer service.
Future<void> main() async {
  debugPrint("App: Starting application setup.");
  tz.initializeTimeZones();

  WidgetsFlutterBinding.ensureInitialized();

  // Initializing Firebase here is essential to safely check for a current user
  // and to set up the background message handler before the app runs.
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Point to the new, centralized background handler in notifications.dart
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // This is a very fast, synchronous check of the locally cached user token.
  // It does NOT involve a network request.
  final initialUser = FirebaseAuth.instance.currentUser;
  final initialStatus = initialUser == null
      ? AppStatus.needsLogin
      : AppStatus.initializing;
  debugPrint("App: Pre-runApp check complete. Initial status: $initialStatus");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('selectedTheme');
  final initialTheme = savedTheme ?? (WidgetsBinding.instance.window.platformBrightness == Brightness.dark ? 'dark' : 'light');
  debugPrint("App: Using theme: $initialTheme");
  await GoogleSignIn.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<InternetService>(create: (_) => InternetService()),
        Provider<NotificationService>(create: (_) => NotificationService(navigatorKey: navigatorKey)),
        Provider<CreditsManager>.value(value: CreditsManager.instance),
        ChangeNotifierProvider(create: (_) => AppInitializer(initialStatus)),
        ChangeNotifierProvider(create: (_) => NewsService()),
        ChangeNotifierProvider(create: (_) => FileDownloadHelper()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialTheme)),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => DownloadedModelsManager()),
        ChangeNotifierProvider(create: (_) => TabProvider()),
      ],
      child: Cortex(
        navigatorKey: navigatorKey,
        startupScreen: const AppLifecycleManager(),
      ),
    ),
  );
  debugPrint("App: Minimal setup complete. Heavy lifting delegated to AppInitializer service.");
}

/// A new widget that acts as the main router for the application's lifecycle.
/// It listens to the `AppInitializer` service and displays the appropriate screen
/// based on the current application state (e.g., initializing, logged in, needs login).
/// This eliminates the need for a separate loading screen.
class AppLifecycleManager extends StatefulWidget {
  const AppLifecycleManager({super.key});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppInitializer>(context, listen: false).initialize();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    context.read<NotificationService>().handleAppLifecycleStateChange(state);
    debugPrint("IGNITION HAS BEEN TURNED! New State: $state");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We consume the AppInitializer to react to state changes.
    return Consumer<AppInitializer>(
      builder: (context, initializer, child) {
        final status = initializer.status;
        final user = initializer.currentUser; // Get the user from the initializer
        debugPrint("AppLifecycleManager: Rebuilding with AppStatus: $status");

        // The switch statement determines which high-level screen to display.
        switch (status) {
          case AppStatus.needsLogin:
            return const LoginScreen();

          case AppStatus.needsVerification:
          // Safely access user data passed by the initializer.
            final verificationData = initializer?.verificationScreenData;
            if (verificationData != null) {
              return EmailVerificationScreen(
                email: verificationData['email'],
                username: verificationData['username'],
                userId: verificationData['userId'],
                password: '', // Password should never be passed to the UI.
              );
            }
            // Fallback if data is unexpectedly null.
            return const LoginScreen();

          case AppStatus.maintenance:
            return const MaintenanceScreen();

          case AppStatus.updateRequired:
          // The Upgrader widget will handle showing the mandatory update dialog.
          // It wraps a minimal Scaffold to provide a basic background.
            return UpgradeAlert(
              upgrader: initializer.upgrader,
              barrierDismissible: false,
              showIgnore: false,
              showLater: false,
              child: const Scaffold(body: Center(child: Text("Checking for updates..."))),
            );

          case AppStatus.initializing:
          case AppStatus.ready:
          default:
          // For both 'initializing' and 'ready' states, we show the MainScreen.
          // This is the key to the "no extra loading animation" approach.
          // The MainScreen and its children are responsible for displaying their
          // own content, or a skeleton/empty state while their specific data is loading.
            return MainScreen(key: mainScreenKey);
        }
      },
    );
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
        // Your existing locale resolution logic is sound.
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

/// The main screen containing the bottom navigation and primary app views.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ChatScreenState> chatScreenKey = GlobalKey<ChatScreenState>();
  final GlobalKey<MenuScreenState> menuScreenKey = GlobalKey<MenuScreenState>();

  bool hideBottomAppBar = false;
  bool _showOfflinePulse = false;

  @override
  void initState() {
    super.initState();
    debugPrint("MainScreen: Initializing state.");
  }

  // Now informs the ChatScreen when its tab is tapped.
  void onItemTapped(int index, {bool pulseOffline = false}) {
    // If the user is tapping on the Chat tab (index 0),
    // we notify the ChatScreenState to re-evaluate its status.
    if (index == 0) {
      chatScreenKey.currentState?.onReactivated();
    }

    if (mounted && index == 1 && pulseOffline) {
      setState(() {
        _showOfflinePulse = true;
      });
    }
    Provider.of<TabProvider>(context, listen: false).setSelectedIndex(index);
  }

  // MODIFIED: This is now the single source of truth for visibility.
  void updateBottomAppBarVisibility([bool value = false]) {
    if (hideBottomAppBar == value) return;
    setState(() {
      hideBottomAppBar = value;
    });
    Provider.of<ThemeProvider>(context, listen: false).updateSystemUIOverlayStyle();
  }

  void openConversation(ConversationManager manager) {
    Provider.of<TabProvider>(context, listen: false).setSelectedIndex(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatScreenKey.currentState?.readService.loadConversation(manager);
      // Let the ChatScreen decide the visibility. It's usually true here.
      // updateBottomAppBarVisibility(true);
    });
  }

  // MODIFIED: This method now correctly defers visibility logic to the ChatScreen.
  void startNewConversation({bool isDynamic = false}) {
    Provider.of<TabProvider>(context, listen: false).setSelectedIndex(0);
    if (isDynamic) {
      chatScreenKey.currentState?.resetAndStartDynamicConversation();
    } else {
      chatScreenKey.currentState?.resetConversation();
    }
    // The visibility will be handled by the methods called above,
    // so we remove the direct call from here.
    // updateBottomAppBarVisibility(false);
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = Provider.of<TabProvider>(context);
    final appLocalizations = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> screens = [
      ChatScreen(
        key: chatScreenKey,
        onModelSelectionChanged: (isSelected) {
          // This callback is now less critical as ChatScreen manages visibility directly,
          // but we can keep it for consistency.
          updateBottomAppBarVisibility(isSelected);
        },
      ),
      ModelsScreen(
        key: const ValueKey('Models'),
        showOfflineModelsPulse: _showOfflinePulse,
      ),
      MenuScreen(key: menuScreenKey),
    ];

    if (_showOfflinePulse) {
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

    // SIMPLIFIED: The `hideBottomAppBar` state is now the only factor.
    final bool shouldHideBottomAppBar = hideBottomAppBar;

    return Scaffold(
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
                  color: AppColors.primaryColor.inverted.withOpacity(0.1),
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

// Helper extension to make color inversion cleaner.
extension InvertedColor on Color {
  Color get inverted => Color.fromARGB(alpha, 255 - red, 255 - green, 255 - blue);
}

// List of locales with incomplete Material translations.
const List<String> kUnsupportedMaterialLocales = ['ku'];