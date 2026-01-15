// main.dart
//
// Entry point and global bootstrapping for Cortex.
// - Initializes Firebase, Crashlytics, messaging, time zones, and orientation.
// - Performs a lightweight bootstrap (onboarding state, initial auth state, theme).
// - Wires up all core, settings, chat and library providers.
// - Hosts the root [Cortex] widget and [AppLifecycleManager].
//

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/app.dart';
import 'package:cortex/screen.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/settings/providers/actions.dart';
import 'package:cortex/settings/providers/general.dart';
import 'package:cortex/settings/services/auth.dart';
import 'package:cortex/settings/services/profile.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'axon/inbox/logic/general.dart';
import 'banner.dart';
import 'chat/providers/conversation.dart';
import 'chat/providers/input.dart';
import 'chat/providers/session.dart';
import 'chat/services/api.dart';
import 'chat/services/context.dart';
import 'chat/services/database.dart';
import 'chat/services/offline.dart';
import 'chat/services/read.dart';
import 'chat/services/regenerate.dart';
import 'chat/services/response.dart';
import 'chat/services/scroll.dart';
import 'chat/services/select.dart';
import 'chat/services/send.dart';
import 'chat/services/stop.dart';
import 'chat/services/dynamic.dart';
import 'funds/backend.dart';
import 'initialization.dart';
import 'internet.dart';
import 'language.dart';
import 'library/backend/data/repository.dart';
import 'library/backend/data/service.dart';
import 'library/backend/download/download.dart';
import 'library/providers/catalog.dart';
import 'library/providers/local.dart';
import 'lifecycle.dart';
import 'news/service.dart';
import 'notifications/extrovert.dart';
import 'notifications/introvert.dart';
import 'theme.dart';

/// Global keys used across the app.
///
/// [mainScreenKey] lets services (like [AppLifecycleManager]) trigger
/// actions on the main screen (e.g., start a new conversation).
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

/// Global navigator key to allow navigation from services without BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// FlutterDownloader callback entry point.
/// This must be a top-level function and annotated with `@pragma('vm:entry-point')`.
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? sendPort =
  IsolateNameServer.lookupPortByName('downloader_send_port');
  sendPort?.send(<dynamic>[id, status, progress]);
}

/// Simple provider to track the currently selected bottom navigation tab.
class TabProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }
}

/// Data returned from the initial bootstrap phase.
class BootstrapResult {
  final AppStatus initialStatus;
  final String initialTheme;
  final String? initialLanguageCode;

  BootstrapResult({
    required this.initialStatus,
    required this.initialTheme,
    required this.initialLanguageCode,
  });
}

/// Performs all pre-UI bootstrapping:
/// - Firebase initialization
/// - Crashlytics + global error wiring
/// - FCM background handler registration
/// - Reading onboarding + auth status
/// - Choosing initial theme
/// - Orientation lock
class AppBootstrap {
  static Future<BootstrapResult> init() async {
    final stopwatch = Stopwatch()
      ..start();

    // 1. Initialize Firebase.
    await Firebase.initializeApp();

    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint("Firestore settings warning: $e");
    }

    // 2. Wire Crashlytics.
    FlutterError.onError = (FlutterErrorDetails details) {
      final String exceptionAsString = details.exception.toString();

      bool isNetworkNoise = exceptionAsString.contains("SocketException") ||
          exceptionAsString.contains("ClientException") ||
          exceptionAsString.contains("No route to host") ||
          exceptionAsString.contains("Connection failed") ||
          exceptionAsString.contains("NetworkImage");

      if (isNetworkNoise) {
        debugPrint(
            "Ignored Network/Image Error in FlutterError: $exceptionAsString");
        return;
      }

      FirebaseCrashlytics.instance.recordFlutterError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      final String errorString = error.toString();

      if (errorString.contains("System process kill detected") ||
          errorString.contains("DeadSystemException") ||
          errorString.contains("DeadSystemRuntimeException")) {
        return true;
      }

      if (errorString.contains("SocketException") ||
          errorString.contains("No route to host")) {
        debugPrint("Ignored Network Error in PlatformDispatcher: $errorString");
        return true;
      }

      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
      return true;
    };

    // 3. Register background message handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: true);
    FlutterDownloader.registerCallback(downloadCallback);

    // 4. Load shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final bool hasCompletedOnboarding =
        prefs.getBool('has_completed_onboarding') ?? false;

    // 5. Optimistic Auth Check.
    AppStatus initialStatus;
    if (!hasCompletedOnboarding) {
      initialStatus = AppStatus.needsOnboarding;
    } else {
      final initialUser = FirebaseAuth.instance.currentUser;
      initialStatus =
      initialUser == null ? AppStatus.needsLogin : AppStatus.ready;
    }

    // 6. Determine Theme.
    final savedTheme = prefs.getString('selectedTheme');
    final String initialTheme = savedTheme ??
        (PlatformDispatcher.instance.platformBrightness == Brightness.dark
            ? 'dark'
            : 'light');

    final String? savedLanguage = prefs.getString('language_code');

    debugPrint(
        "[AppBootstrap] Finished in ${stopwatch
            .elapsedMilliseconds}ms. Status: $initialStatus");
    stopwatch.stop();

    return BootstrapResult(
      initialStatus: initialStatus,
      initialTheme: initialTheme,
      initialLanguageCode: savedLanguage,
    );
  }
}

/// Application entry point.
///
/// Keeps the main setup ultra-light:
/// - Ensures widgets binding
/// - Preserves the native splash
/// - Initializes time zones
/// - Boots the [AppGatekeeper], which does the heavy lifting via a FutureBuilder.
void main() async {
  final WidgetsBinding widgetsBinding =
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const AppGatekeeper());
}

/// Top-level widget responsible for:
/// - Running the bootstrap once
/// - Building the provider tree
/// - Injecting [AppLifecycleManager] into [Cortex].
class AppGatekeeper extends StatelessWidget {
  const AppGatekeeper({super.key});

  /// Cached bootstrap future to avoid re-running initialization on hot reload
  /// or rebuilds of [FutureBuilder].
  static final Future<BootstrapResult> _bootstrapFuture =
  AppBootstrap.init();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BootstrapResult>(
      future: _bootstrapFuture,
      builder: (BuildContext context, AsyncSnapshot<BootstrapResult> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // A minimal, non-crashing UI for bootstrap errors.
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Bootstrap error: ${snapshot.error}'),
                ),
              ),
            );
          }

          final bootstrap = snapshot.data!;

          return MultiProvider(
            providers: <SingleChildWidget>[
              ..._buildCoreProviders(
                bootstrap.initialStatus,
                bootstrap.initialTheme,
                bootstrap.initialLanguageCode,
              ),
              ..._buildSettingsProviders(),
              ..._buildChatAndLibraryProviders(),
            ],
            child: Cortex(
              navigatorKey: navigatorKey,
              startupScreen: const AppLifecycleManager(),
            ),
          );
        }

        // While bootstrapping we keep the native splash visible and render nothing.
        return const SizedBox.shrink();
      },
    );
  }
}

/// Core app-wide providers: networking, localization, connectivity, auth,
/// models, initialization, notifications, theming, and storage helpers.
List<SingleChildWidget> _buildCoreProviders(AppStatus initialStatus,
    String initialTheme,
    String? initialLanguageCode,) {
  return <SingleChildWidget>[
    // Global Dio instance with Smart Retry.
    Provider<Dio>(
      create: (_) {
        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        dio.interceptors.add(
          RetryInterceptor(
            dio: dio,
            logPrint: (Object msg) =>
                debugPrint('[DioRetry-Global] $msg'),
            retries: 5,
            retryDelays: const <Duration>[
              Duration(seconds: 1),
              Duration(seconds: 3),
              Duration(seconds: 5),
              Duration(seconds: 7),
              Duration(seconds: 9),
            ],
          ),
        );

        return dio;
      },
    ),

    // Locale & connectivity.
    ChangeNotifierProvider<LocaleProvider>(
      create: (_) {
        final provider = LocaleProvider();
        if (initialLanguageCode != null) {
          provider.setLocale(Locale(initialLanguageCode));
        }
        return provider;
      },
    ),
    ChangeNotifierProvider<InternetProvider>(
      create: (_) => InternetProvider(),
    ),

    // User data & credits.
    ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(),
    ),
    Provider<CreditsManager>.value(
      value: CreditsManager.instance,
    ),

    // Auth & notifications.
    Provider<AuthService>(
      create: (_) => AuthService(),
    ),
    Provider<ExtrovertNotificationService>(
      create: (_) =>
          ExtrovertNotificationService(navigatorKey: navigatorKey),
    ),
    Provider<IntrovertNotificationService>(
      create: (_) =>
          IntrovertNotificationService(navigatorKey: navigatorKey),
    ),

    // Model repository + service.
    Provider<ModelRepository>(
      create: (BuildContext context) =>
          ModelRepository(
            dio: context.read<Dio>(),
          ),
    ),
    ChangeNotifierProvider<ModelService>(
      create: (BuildContext context) =>
          ModelService(
            repository: context.read<ModelRepository>(),
          ),
    ),

    // App initializer orchestrates startup + auth + lifecycle gatekeeping.
    ChangeNotifierProvider<AppInitializer>(
      create: (BuildContext context) =>
          AppInitializer(
            initialStatus: initialStatus,
            authService: context.read<AuthService>(),
            modelService: context.read<ModelService>(),
            extrovertNotificationService:
            context.read<ExtrovertNotificationService>(),
            introvertNotificationService:
            context.read<IntrovertNotificationService>(),
            internetProvider: context.read<InternetProvider>(),
            userProvider: context.read<UserProvider>(),
          ),
    ),

    // News service depends on AppInitializer + Dio + connectivity.
    ChangeNotifierProxyProvider3<AppInitializer,
        Dio,
        InternetProvider,
        NewsService>(
      create: (BuildContext context) =>
          NewsService(
            appInitializer: context.read<AppInitializer>(),
            dio: context.read<Dio>(),
            internetProvider: context.read<InternetProvider>(),
          ),
      update: (BuildContext _,
          AppInitializer appInit,
          Dio dio,
          InternetProvider internet,
          NewsService? previous,) {
        final service = previous ??
            NewsService(
              appInitializer: appInit,
              dio: dio,
              internetProvider: internet,
            );
        service.updateDependencies(
          appInitializer: appInit,
          dio: dio,
          internetProvider: internet,
        );
        return service;
      },
    ),

    // Downloads, theming, tab navigation, database, and banners.
    ChangeNotifierProvider<FileDownloadHelper>(
      create: (_) => FileDownloadHelper(),
    ),
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(initialTheme),
    ),
    ChangeNotifierProvider<TabProvider>(
      create: (_) => TabProvider(),
    ),
    Provider<DbHelper>(
      create: (_) => DbHelper(),
    ),
    Provider<BannerService>(
      create: (_) => BannerService(),
    ),
    ChangeNotifierProxyProvider<IntrovertNotificationService, FundsBackend>(
      create: (BuildContext context) => FundsBackend(),
      update: (BuildContext context,
          IntrovertNotificationService notificationService,
          FundsBackend? previous,) {
        final backend = previous ?? FundsBackend();
        backend.setNotificationService(notificationService);
        return backend;
      },
    ),
  ];
}

/// Settings-related providers (profile, general settings and actions).
List<SingleChildWidget> _buildSettingsProviders() {
  return <SingleChildWidget>[
    Provider<ProfileService>(
      create: (_) => ProfileService(),
    ),
    ChangeNotifierProxyProvider<InternetProvider, SettingsGeneralProvider>(
      create: (BuildContext context) =>
          SettingsGeneralProvider(
            authService: context.read<AuthService>(),
            profileService: context.read<ProfileService>(),
            notificationService: context.read<IntrovertNotificationService>(),
          ),
      update: (BuildContext context,
          InternetProvider internetProvider,
          SettingsGeneralProvider? previous,) {
        final provider = previous ??
            SettingsGeneralProvider(
              authService: context.read<AuthService>(),
              profileService: context.read<ProfileService>(),
              notificationService:
              context.read<IntrovertNotificationService>(),
            );
        provider.updateConnectivity(internetProvider);
        return provider;
      },
    ),
    ChangeNotifierProvider<SettingsActionProvider>(
      create: (BuildContext context) =>
          SettingsActionProvider(
            authService: context.read<AuthService>(),
            profileService: context.read<ProfileService>(),
            notificationService: context.read<IntrovertNotificationService>(),
            appInitializer: context.read<AppInitializer>(),
            internetProvider: context.read<InternetProvider>(),
          ),
    ),
  ];
}

/// Chat and model-library providers:
/// - Model catalog + local state
/// - Chat session + conversation + input
/// - Recent models, API, scroll, dynamic chat
/// - Response, context, offline, selection, read, send, stop, regenerate
List<SingleChildWidget> _buildChatAndLibraryProviders() {
  return <SingleChildWidget>[
    // Inbox, Model catalog and local state.
    ChangeNotifierProvider<InboxViewModel>(
      create: (BuildContext context) {
        final vm = InboxViewModel(
          modelService: context.read<ModelService>(),
          notificationService: context.read<IntrovertNotificationService>(),
        );

        final langCode =
            context
                .read<LocaleProvider>()
                .locale
                .languageCode;
        scheduleMicrotask(() => vm.initialize(langCode));

        return vm;
      },
    ),
    ChangeNotifierProvider<ModelCatalogProvider>(
      create: (_) => ModelCatalogProvider(),
    ),
    ChangeNotifierProvider<DownloadedModelsManager>(
      create: (_) => DownloadedModelsManager(),
    ),

    ChangeNotifierProxyProvider<ModelCatalogProvider, ModelLocalStateProvider>(
      create: (BuildContext context) {
        final provider = ModelLocalStateProvider();
        provider.initialize(context: context);
        return provider;
      },
      update: (BuildContext context,
          ModelCatalogProvider catalog,
          ModelLocalStateProvider? local,) {
        final localState = local ?? ModelLocalStateProvider();
        localState.update(catalog.allModels);
        return localState;
      },
    ),

    // Chat session.
    ChangeNotifierProxyProvider3<UserProvider,
        ModelService,
        ModelLocalStateProvider,
        ChatSessionProvider>(
      create: (BuildContext context) =>
          ChatSessionProvider(
            modelService: context.read<ModelService>(),
          ),
      update: (BuildContext _,
          UserProvider user,
          ModelService modelService,
          ModelLocalStateProvider local,
          ChatSessionProvider? previous,) {
        final session =
            previous ?? ChatSessionProvider(modelService: modelService);
        session.setDependencies(local);

        if (user.userData != null) {
          session.updateUserData(user.userData!);
        }
        return session;
      },
    ),

    // Conversation + input.
    ChangeNotifierProvider<ConversationProvider>(
      create: (_) => ConversationProvider(),
    ),
    ChangeNotifierProvider<InputProvider>(
      create: (_) => InputProvider(),
    ),

    // Core chat services.
    Provider<ApiService>(
      create: (_) => ApiService(),
    ),
    Provider<ScrollService>(
      create: (_) => ScrollService(),
    ),
    Provider<DynamicChatService>(
      create: (BuildContext context) =>
          DynamicChatService(context.read<ChatSessionProvider>()),
    ),
    Provider<ResponseService>(
      create: (BuildContext context) =>
          ResponseService(
            conversationProvider: context.read<ConversationProvider>(),
            scrollService: context.read<ScrollService>(),
          ),
    ),
    Provider<ContextService>(
      create: (BuildContext context) =>
          ContextService(
            sessionProvider: context.read<ChatSessionProvider>(),
            conversationProvider: context.read<ConversationProvider>(),
            modelService: context.read<ModelService>(),
          ),
    ),
    Provider<OfflineService>(
      create: (BuildContext context) =>
          OfflineService(
            responseService: context.read<ResponseService>(),
            sessionProvider: context.read<ChatSessionProvider>(),
            modelService: context.read<ModelService>(),
            contextService: context.read<ContextService>(),
          ),
    ),
    Provider<SelectionService>(
      create: (BuildContext context) =>
          SelectionService(
            sessionProvider: context.read<ChatSessionProvider>(),
            conversationProvider: context.read<ConversationProvider>(),
            modelService: context.read<ModelService>(),
          ),
    ),
    Provider<ReadService>(
      create: (BuildContext context) =>
          ReadService(
            sessionProvider: context.read<ChatSessionProvider>(),
            conversationProvider: context.read<ConversationProvider>(),
            modelService: context.read<ModelService>(),
          ),
    ),
    Provider<SendService>(
      create: (BuildContext context) =>
          SendService(
            sessionProvider: context.read<ChatSessionProvider>(),
            conversationProvider: context.read<ConversationProvider>(),
            inputProvider: context.read<InputProvider>(),
            apiService: context.read<ApiService>(),
            contextService: context.read<ContextService>(),
            scrollService: context.read<ScrollService>(),
            offlineService: context.read<OfflineService>(),
            modelService: context.read<ModelService>(),
          ),
    ),
    Provider<StopService>(
      create: (BuildContext context) =>
          StopService(
            conversationProvider: context.read<ConversationProvider>(),
            sessionProvider: context.read<ChatSessionProvider>(),
            apiService: context.read<ApiService>(),
            offlineService: context.read<OfflineService>(),
            modelService: context.read<ModelService>(),
          ),
    ),
    Provider<RegenerateService>(
      create: (BuildContext context) =>
          RegenerateService(
            conversationProvider: context.read<ConversationProvider>(),
            stopService: context.read<StopService>(),
            sendService: context.read<SendService>(),
            scrollService: context.read<ScrollService>(),
          ),
    ),
  ];
}