// main.dart
//
// The primary entry point for the Cortex application. This file is responsible for
// setting up essential services, providers, and launching the core application structure.
// It performs minimal, fast setup and delegates all UI rendering to 'app.dart'.

import 'dart:isolate';
import 'dart:ui';
import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'banner.dart';
import 'chat/providers/conversation.dart';
import 'chat/providers/input.dart';
import 'chat/providers/session.dart';
import 'chat/screen/unselected/news.dart';
import 'chat/services/api.dart';
import 'chat/services/context.dart';
import 'chat/services/database.dart';
import 'chat/services/load.dart';
import 'chat/services/offline.dart';
import 'chat/services/read.dart';
import 'chat/services/recent.dart';
import 'chat/services/regenerate.dart';
import 'chat/services/response.dart';
import 'chat/services/scroll.dart';
import 'chat/services/select.dart';
import 'chat/services/send.dart';
import 'chat/services/stop.dart';
import 'chat/screen/selected/dynamic.dart';
import 'initialization.dart';
import 'internet.dart';
import 'language.dart';
import 'models/backend/download.dart';
import 'notifications.dart';
import 'theme.dart';

// Global keys for accessing specific widget states across the application.
// These are defined here to be passed down to the UI layer.
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// A top-level function for the Flutter Downloader background isolate.
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

/// A simple state manager for the selected tab index of the bottom navigation bar.
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
/// It performs a rapid, synchronous check for a cached user session,
/// sets up all necessary background services and providers, and then
/// launches the UI defined in `app.dart`.
Future<void> main() async {
  debugPrint("App: Starting application setup.");
  tz.initializeTimeZones();

  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase, essential for auth checks and background messaging.
  await Firebase.initializeApp();

  // Configure global error handlers to report to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Set up the background message handler.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Perform a fast, synchronous check of the locally cached user token.
  // This does NOT involve a network request and prevents UI flash.
  final initialUser = FirebaseAuth.instance.currentUser;
  final initialStatus = initialUser == null
      ? AppStatus.needsLogin
      : AppStatus.initializing;
  debugPrint("App: Pre-runApp check complete. Initial status: $initialStatus");

  // Enforce portrait orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load saved theme preference before the UI builds.
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('selectedTheme');
  final initialTheme = savedTheme ?? (PlatformDispatcher.instance.platformBrightness == Brightness.dark ? 'dark' : 'light');
  debugPrint("App: Using theme: $initialTheme");

  // Pre-load localizations to avoid any flicker.
  await AppLocalizations.delegate.load(
    binding.platformDispatcher.locale,
  );

  // Launch the application by providing the providers and running the Cortex widget.
  runApp(
    MultiProvider(
      providers: [
        //======================================================================
        // SECTION 1: CORE & APP-WIDE PROVIDERS
        //======================================================================
        ChangeNotifierProvider(create: (_) => InternetProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider<NotificationService>(create: (_) => NotificationService(navigatorKey: navigatorKey)),
        Provider<CreditsManager>.value(value: CreditsManager.instance),
        ChangeNotifierProvider(create: (_) => AppInitializer(initialStatus)),
        ChangeNotifierProvider(create: (_) => NewsService()),
        ChangeNotifierProvider(create: (_) => FileDownloadHelper()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialTheme)),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => DownloadedModelsManager()),
        ChangeNotifierProvider(create: (_) => TabProvider()),
        Provider<RecentModelsManager>(create: (_) => RecentModelsManager()),
        Provider<DbHelper>(create: (_) => DbHelper()),
        Provider<BannerService>(create: (_) => BannerService()),

        //======================================================================
        // SECTION 2: CHAT FEATURE PROVIDERS (STATE & SERVICES)
        //======================================================================

        // State Providers
        ChangeNotifierProxyProvider<UserProvider, ChatSessionProvider>(
          create: (_) => ChatSessionProvider(),
          update: (_, userProvider, previousSessionProvider) {
            if (userProvider.userData != null) {
              previousSessionProvider!.updateUserData(userProvider.userData!);
            }
            return previousSessionProvider!;
          },
        ),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => InputProvider()),

        // Foundational Services
        Provider<ScrollService>(create: (_) => ScrollService()),
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<DynamicChatService>(create: (context) => DynamicChatService(context.read<ChatSessionProvider>())),

        // Services with Dependencies
        Provider<ResponseService>(create: (context) => ResponseService(conversationProvider: context.read<ConversationProvider>(), scrollService: context.read<ScrollService>())),
        Provider<OfflineService>(create: (context) => OfflineService(responseService: context.read<ResponseService>(), sessionProvider: context.read<ChatSessionProvider>())),
        Provider<SelectionService>(create: (context) => SelectionService(sessionProvider: context.read<ChatSessionProvider>(), conversationProvider: context.read<ConversationProvider>())),
        Provider<ContextService>(create: (context) => ContextService(sessionProvider: context.read<ChatSessionProvider>(), conversationProvider: context.read<ConversationProvider>())),
        Provider<LoadService>(create: (context) => LoadService(sessionProvider: context.read<ChatSessionProvider>(), selectionService: context.read<SelectionService>())),
        Provider<ReadService>(create: (context) => ReadService(sessionProvider: context.read<ChatSessionProvider>(), conversationProvider: context.read<ConversationProvider>(), loadService: context.read<LoadService>())),
        Provider<SendService>(create: (context) => SendService(sessionProvider: context.read<ChatSessionProvider>(), conversationProvider: context.read<ConversationProvider>(), inputProvider: context.read<InputProvider>(), apiService: context.read<ApiService>(), contextService: context.read<ContextService>(), scrollService: context.read<ScrollService>(), recentModelsManager: context.read<RecentModelsManager>(), offlineService: context.read<OfflineService>())),
        Provider<StopService>(create: (context) => StopService(
            conversationProvider: context.read<ConversationProvider>(),
            sessionProvider: context.read<ChatSessionProvider>(),
            apiService: context.read<ApiService>(),
            offlineService: context.read<OfflineService>()
        )),
        Provider<RegenerateService>(
          create: (context) => RegenerateService(
            conversationProvider: context.read<ConversationProvider>(),
            stopService: context.read<StopService>(),
            sendService: context.read<SendService>(),
            scrollService: context.read<ScrollService>(),
          ),
          lazy: true,
        ),
      ],
      // The root widget of the application is now Cortex from app.dart
      child: Cortex(
        navigatorKey: navigatorKey,
        startupScreen: const AppLifecycleManager(),
      ),
    ),
  );
  debugPrint("App: Minimal setup complete. UI rendering and heavy lifting delegated.");
}