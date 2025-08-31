// main.dart
// Enhanced Flutter application with comprehensive English logging and dynamic sizing

import 'dart:isolate';
import 'dart:ui';
import 'package:cortex/server/credits.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat/chat.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'conversations/inbox.dart';
import 'conversations/manager.dart';
import 'errorview.dart';
import 'initialization.dart';
import 'internet.dart';
import 'models/backend/data.dart';
import 'models/screen/models.dart';
import 'models/backend/download.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'language.dart';
import 'notifications.dart';
import 'theme.dart';
import 'dart:async';

// Global keys for accessing specific widget states across the application
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

/// Provider class to manage tab selection state across the application
/// Uses ChangeNotifier to notify listeners when tab selection changes
class TabProvider with ChangeNotifier {
  int _selectedIndex = 0;

  /// Gets the currently selected tab index
  int get selectedIndex => _selectedIndex;

  /// Updates the selected tab index and notifies listeners if changed
  /// [index] - The new tab index to select
  void setSelectedIndex(int index) {
    debugPrint('TabProvider: Attempting to change tab from $_selectedIndex to $index');
    if (_selectedIndex != index) {
      _selectedIndex = index;
      debugPrint('TabProvider: Tab successfully changed to $index');
      notifyListeners();
    } else {
      debugPrint('TabProvider: Tab selection unchanged, already at index $index');
    }
  }
}

/// The new main entry point. Its role is drastically simplified:
/// 1. Initialize critical, low-latency services.
/// 2. Set up all providers.
/// 3. Call `runApp` with the `InitializationScreen` to delegate heavy loading.
Future<void> main() async {
  debugPrint('App: Starting minimal application setup.');

  // This is a mandatory first step.
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Fetching theme settings is quick and necessary for the ThemeProvider.
  // We do this here to avoid a flash of the wrong theme.
  final prefs = await SharedPreferences.getInstance();
  String? savedTheme = prefs.getString('selectedTheme');
  String initialTheme;

  if (savedTheme == null) {
    debugPrint('App: No saved theme found, detecting system theme.');
    Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    initialTheme = brightness == Brightness.dark ? 'dark' : 'light';
    await prefs.setString('selectedTheme', initialTheme);
  } else {
    initialTheme = savedTheme;
  }
  debugPrint('App: Using theme: $initialTheme');

  // Initialize notification service, which is lightweight.
  final notificationService = NotificationService(navigatorKey: navigatorKey);

  debugPrint('App: Launching application with MultiProvider and InitializationScreen.');
  runApp(
    MultiProvider(
      providers: [
        Provider<InternetService>(create: (_) => InternetService()),
        Provider<NotificationService>.value(value: notificationService),
        Provider<CreditsManager>.value(value: CreditsManager.instance),
        ChangeNotifierProvider(create: (_) => FileDownloadHelper()),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(initialTheme),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(),
        ),
        ChangeNotifierProvider<DownloadedModelsManager>(
          create: (_) => DownloadedModelsManager(),
        ),
        ChangeNotifierProvider(create: (_) => TabProvider()),
      ],
      child: Cortex(
          navigatorKey: navigatorKey,
          // The app ALWAYS starts with the InitializationScreen now.
          startupScreen: const InitializationScreen()
      ),
    ),
  );
  debugPrint('App: Minimal setup complete. Heavy lifting delegated to InitializationScreen.');
}

/// Extension to invert colors for theming purposes
/// Useful for creating contrasting colors in light/dark themes
extension InvertedColor on Color {
  Color get inverted => Color.fromARGB(alpha, 255 - red, 255 - green, 255 - blue);
}

const List<String> kUnsupportedMaterialLocales = ['ku'];

/// Main application widget that handles theming and localization
/// Sets up MaterialApp with proper theme configuration and navigation
class Cortex extends StatelessWidget {
  const Cortex({super.key, required this.navigatorKey, this.startupScreen});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget? startupScreen;

  /// Builds custom theme based on current theme selection
  /// [currentTheme] - String indicating 'dark' or 'light' theme
  /// Returns configured ThemeData with custom colors and styles
  ThemeData _buildTheme(String currentTheme) {
    debugPrint('Theme: Building theme for mode: $currentTheme');
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
        error: AppColors.septenaryColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryColor.inverted,
        selectionColor: AppColors.quaternaryColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusColor: AppColors.primaryColor.inverted,
        hintStyle: TextStyle(color: AppColors.tertiaryColor),
        labelStyle: TextStyle(color: AppColors.tertiaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    debugPrint('Cortex: Building main application widget');
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: _buildTheme(themeProvider.currentTheme),

      builder: (context, child) {
        themeProvider.updateSystemUIOverlayStyle();

        return child!;
      },

      locale: Provider.of<LocaleProvider>(context).locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale('tr'), // Turkish
        Locale('zh'), // Chinese
        Locale('fr'), // French
        Locale('hi'), // Hindi
        Locale('pt'), // Portuguese
        Locale('id'), // Indonesian
        Locale('az'), // Azerbaijani
        Locale('de'), // German
        Locale('es'), // Spanish
        Locale('it'), // Italian
        Locale('ja'), // Japanese
        Locale('ar'), // Arabic
        Locale('ku'), // Kurdish
        Locale('nl'), // Dutch
        Locale('ru'), // Russian
        Locale('ko'), // Korean
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
        final chosenLocale = localeProvider.locale;

        if (kUnsupportedMaterialLocales.contains(chosenLocale.languageCode)) {
          debugPrint('Cortex: Unsupported Material locale detected (${chosenLocale.languageCode}). Falling back to English for Material components.');
          return const Locale('en');
        }

        debugPrint('Cortex: Resolving locale to: ${chosenLocale.languageCode}');
        return chosenLocale;
      },
      home: startupScreen,
    );
  }
}

/// A dedicated screen to be shown when the server is under maintenance.
/// It correctly uses the app's theme and localization.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access providers to get theme and localization.
    final appLocalizations = AppLocalizations.of(context)!;

    // Now we can use AppColors safely because we are in a build context.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ErrorView(
        title: appLocalizations.maintenanceTitle, // Localized title
        message: appLocalizations.maintenanceMessage, // Localized message
      ),
    );
  }
}

/// Main screen widget that contains the bottom navigation and manages screen transitions
/// Handles tab switching, model initialization, and bottom app bar visibility
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ChatScreenState> chatScreenKey = GlobalKey<ChatScreenState>();
  final GlobalKey<MenuScreenState> menuScreenKey = GlobalKey<MenuScreenState>();

  late final List<Widget> _screens;
  // This state is now managed by the callback from ChatScreen.
  bool hideBottomAppBar = false;

  @override
  void initState() {
    super.initState();
    debugPrint('MainScreen: Initializing main screen state');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('MainScreen: Triggering initial model data load...');
      final langCode = Localizations.localeOf(context).languageCode;
      await ModelData.getModels(langCode: langCode);
      debugPrint('MainScreen: Initial model data load process completed.');
      if (mounted) {
        setState(() {});
      }
    });

    // --- FIX: Pass the callback function to ChatScreen ---
    // ChatScreen will now notify its parent about its state (model selected/deselected) through this function.
    _screens = [
      KeyedSubtree(
        key: const ValueKey('Chat'),
        child: ChatScreen(
          key: chatScreenKey,
          onModelSelectionChanged: (isSelected) {
            // Update the bottom bar visibility based on the information from ChatScreen.
            updateBottomAppBarVisibility(isSelected);
          },
        ),
      ),
      KeyedSubtree(
        key: const ValueKey('Models'),
        child: const ModelsScreen(key: ValueKey('Models')),
      ),
      KeyedSubtree(
        key: const ValueKey('Menu'),
        child: MenuScreen(key: menuScreenKey),
      ),
    ];
    debugPrint('MainScreen: Screen tabs initialized with ${_screens.length} screens');
  }

  /// Handles bottom navigation tab selection
  /// [index] - The index of the tab to select
  void onItemTapped(int index) {
    debugPrint('MainScreen: Tab tapped - index: $index');
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    tabProvider.setSelectedIndex(index);
  }

  /// Updates bottom app bar visibility state
  /// [value] - Boolean indicating whether to hide the bottom app bar
  void updateBottomAppBarVisibility([bool value = false]) {
    // --- FIX: Check to prevent unnecessary rebuilds ---
    // If the state is already the same, no need to call setState.
    if (hideBottomAppBar == value) return;

    debugPrint('MainScreen: Updating bottom app bar visibility to: ${value ? "hidden" : "visible"}');
    setState(() {
      hideBottomAppBar = value;
    });
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.updateSystemUIOverlayStyle();
  }

  /// Opens a specific conversation and navigates to chat screen
  /// [manager] - The conversation manager containing the conversation data
  void openConversation(ConversationManager manager) {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    tabProvider.setSelectedIndex(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('MainScreen: Loading conversation into chat screen from complete manager.');
      chatScreenKey.currentState?.readService.loadConversation(manager);

      updateBottomAppBarVisibility(true);
      debugPrint('MainScreen: Conversation loaded and chat screen updated.');
    });
  }

  /// Starts a new conversation by resetting the chat screen
  void startNewConversation() {
    debugPrint('MainScreen: Starting new conversation');
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    tabProvider.setSelectedIndex(0);
    chatScreenKey.currentState?.resetConversation();
    updateBottomAppBarVisibility(false);
    debugPrint('MainScreen: New conversation started and chat screen reset');
  }


  @override
  Widget build(BuildContext context) {
    // Listen to providers for state changes
    final tabProvider = Provider.of<TabProvider>(context);
    final appLocalizations = AppLocalizations.of(context)!;

    // Get screen dimensions for dynamic sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final appName = 'Cortex';

    // Set the primary color for the Android app switcher description
    final primaryThemeColor = AppColors.background;
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: appName,
        primaryColor: primaryThemeColor.value,
      ),
    );

    debugPrint('MainScreen: Building main screen - Current tab: ${tabProvider.selectedIndex}');
    debugPrint('MainScreen: Screen dimensions - Height: $screenHeight, Width: $screenWidth');

    // Dynamic sizing calculations for the bottom navigation bar
    final bottomBarHeight = screenHeight * 0.09;
    final iconBaseSize = screenHeight * 0.028;
    final libraryIconSize = screenHeight * 0.022;
    final iconContainerSize = iconBaseSize * 1.2;
    final labelSpacing = screenHeight * 0.002;
    final shadowBlurRadius = screenWidth * 0.02;
    final borderRadius = screenWidth * 0.04;

    debugPrint('MainScreen: Dynamic sizing - BottomBar: $bottomBarHeight, IconBase: $iconBaseSize');

    // Determine if the bottom navigation bar should be hidden
    bool shouldHideBottomAppBar = tabProvider.selectedIndex == 0 && hideBottomAppBar;
    debugPrint('MainScreen: Final decision - shouldHideBottomAppBar: $shouldHideBottomAppBar');

    return GestureDetector(
      onTap: () {
        // Dismiss any visible SnackBars when tapping the main screen area
        debugPrint('MainScreen: Screen tapped - hiding snack bars');
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey(tabProvider.selectedIndex),
            child: _screens[tabProvider.selectedIndex],
          ),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
        ),
        bottomNavigationBar: shouldHideBottomAppBar
            ? null
            : Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            // This builder already rebuilds on theme change.
            debugPrint('MainScreen: Rebuilding BottomAppBar container AND buttons due to theme change.');

            return Container(
              decoration: BoxDecoration(
                color: AppColors.background, // This is fine, it's read during the rebuild
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
              // --- THE KEY CHANGE: We build the BottomAppBar INSIDE the builder ---
              // We remove the 'child' parameter from the Consumer to ensure
              // that the BottomAppBar and its buttons are part of what gets rebuilt.
              child: BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                child: SizedBox(
                  height: bottomBarHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: BottomNavigationButton(
                          iconPath: 'assets/icons/inbox.svg',
                          label: appLocalizations.chats,
                          isSelected: tabProvider.selectedIndex == 2,
                          onTap: tabProvider.selectedIndex == 2
                              ? null
                              : () => onItemTapped(2),
                          // Pass the rest of the dynamic sizes
                          baseSize: iconBaseSize,
                          containerSize: iconContainerSize,
                          labelSpacing: labelSpacing,
                        ),
                      ),
                      Expanded(
                        child: BottomNavigationButton(
                          iconPath: 'assets/icons/chat.svg',
                          label: appLocalizations.chat,
                          isSelected: tabProvider.selectedIndex == 0,
                          onTap: tabProvider.selectedIndex == 0
                              ? null
                              : () => onItemTapped(0),
                          baseSize: iconBaseSize,
                          containerSize: iconContainerSize,
                          labelSpacing: labelSpacing,
                        ),
                      ),
                      Expanded(
                        child: BottomNavigationButton(
                          iconPath: 'assets/icons/library.svg',
                          label: appLocalizations.library,
                          isSelected: tabProvider.selectedIndex == 1,
                          onTap: tabProvider.selectedIndex == 1
                              ? null
                              : () => onItemTapped(1),
                          baseSize: libraryIconSize,
                          containerSize: libraryIconSize * 1.2,
                          labelSpacing: labelSpacing,
                        ),
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

/// Custom bottom navigation button widget with dynamic sizing and animations
/// Provides visual feedback for selection state and tap interactions
class BottomNavigationButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final double baseSize;
  final double containerSize;
  final double labelSpacing;

  const BottomNavigationButton({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.baseSize = 20.0,
    this.containerSize = 24.0,
    this.labelSpacing = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine icon color based on selection state
    Color iconColor = isSelected ? AppColors.primaryColor.inverted : AppColors.tertiaryColor;

    debugPrint('BottomNavigationButton: Building button - Icon: $iconPath, Selected: $isSelected');

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          debugPrint('BottomNavigationButton: Button tapped - $label');
          onTap!();
        } else {
          debugPrint('BottomNavigationButton: Button tap ignored - already selected ($label)');
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with dynamic sizing and scaling animation
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
                    color: iconColor,
                  ),
                ),
              ),
            ),
            // Dynamic spacing between icon and label
            SizedBox(height: labelSpacing),
            // Animated label with dynamic styling
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: GoogleFonts.roboto(
                fontSize: baseSize * 0.5, // Dynamic font size based on icon size
                color: iconColor,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}