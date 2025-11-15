// lib/initialization.dart
//
// Provides the `AppInitializer` service, which acts as the central brain for
// the application's startup and lifecycle state management. It is responsible
// for handling authentication, checking server status, and managing background
// synchronization tasks without blocking the user interface.

import 'dart:async';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/reconcile.dart';
import 'package:cortex/referral.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/settings/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'cache.dart';
import 'chat/services/moderator.dart';
import 'internet.dart';
import 'l10n/app_localizations.dart';
import 'library/backend/download/download.dart';
import 'main.dart';
import 'maintenance.dart';
import 'notifications/extrovert.dart';
import 'notifications/introvert.dart';

/// Defines the possible high-level states of the application.
enum AppStatus {
  needsOnboarding,
  initializing,
  needsLogin,
  needsVerification,
  ready,
  maintenance,
  updateRequired,
}

/// A custom messages class for Upgrader to use the app's localization.
class AppUpgraderMessages extends UpgraderMessages {
  final AppLocalizations appLocalizations;
  AppUpgraderMessages({required this.appLocalizations});

  @override
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.title:
        return appLocalizations.updateRequiredTitle;
      case UpgraderMessage.body:
        return appLocalizations.updateRequiredMessage;
      case UpgraderMessage.buttonTitleUpdate:
        return appLocalizations.updateNowButton;
      default:
        return super.message(messageKey);
    }
  }
}

/// The core service for managing the application's lifecycle and state.
class AppInitializer with ChangeNotifier {
  AppStatus _status = AppStatus.initializing;
  AppStatus get status => _status;
  User? _currentUser;
  User? get currentUser => _currentUser;
  Map<String, dynamic>? _verificationScreenData;
  Map<String, dynamic>? get verificationScreenData => _verificationScreenData;

  /// Completer that is completed once essential core services are ready.
  /// UI components can await this future before touching those services.
  final Completer<void> _coreServicesReadyCompleter = Completer<void>();
  Future<void> get onCoreServicesReady => _coreServicesReadyCompleter.future;

  Upgrader? _upgrader;

  Upgrader get upgrader {
    _upgrader ??= Upgrader(
      debugLogging: kDebugMode,
    );
    return _upgrader!;
  }

  void configureUpgrader(AppLocalizations l10n) {
    _upgrader ??= Upgrader(
        messages: AppUpgraderMessages(appLocalizations: l10n),
        debugLogging: kDebugMode,
      );
  }

  /// Flag used to prevent authStateChanges from running user flow checks
  /// during an active registration flow.
  bool _isRegistering = false;
  void setRegistrationStatus(bool isRegistering) {
    _isRegistering = isRegistering;
  }

  /// Flag used to indicate a deliberate sign-out is in progress. This prevents
  /// the offline check from blocking a user-initiated sign-out.
  bool _isSigningOut = false;
  final AuthService _authService;
  final ModelService _modelService;
  final ExtrovertNotificationService _extrovertNotificationService;
  final IntrovertNotificationService _introvertNotificationService;
  final InternetProvider _internetProvider;
  final UserProvider _userProvider;
  AppInitializer({
    required AppStatus initialStatus,
    required AuthService authService,
    required ModelService modelService,
    required ExtrovertNotificationService extrovertNotificationService,
    required IntrovertNotificationService introvertNotificationService,
    required InternetProvider internetProvider,
    required UserProvider userProvider,
  })  : _status = initialStatus,
        _authService = authService,
        _modelService = modelService,
        _extrovertNotificationService = extrovertNotificationService,
        _introvertNotificationService = introvertNotificationService,
        _internetProvider = internetProvider,
        _userProvider = userProvider {
    debugPrint("AppInitializer: Instantiated with initial status: $_status");
  }

  void _updateStatus(AppStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      debugPrint("AppInitializer: Status changed to $_status");
      notifyListeners();
    }
  }

  void requestEmailVerification({
    required String email,
    required String userId,
    String? username,
    String? password,
  }) {
    _verificationScreenData = {
      'email': email,
      'userId': userId,
      'username': username ?? '',
      'password': password ?? '',
    };
    _updateStatus(AppStatus.needsVerification);
  }

  /// Entry point for the application initialization pipeline.
  ///
  /// Design goals:
  /// - Keep the UI thread as free as possible.
  /// - Run heavy work in background tasks.
  /// - Only block when absolutely necessary (e.g. maintenance checks).
  Future<void> initialize() async {
    dev.log(
      "AppInitializer: Starting initialization sequence. Current status is '$_status'.",
    );

    try {
      // PHASE 1 – Lightweight core services (awaited)
      dev.log("AppInitializer: Phase 1 - Initializing lightweight core services...");
      await _initializeCoreServicesLightweight();

      if (!_coreServicesReadyCompleter.isCompleted) {
        _coreServicesReadyCompleter.complete();
      }
      dev.log("AppInitializer: Phase 1 - SUCCESS. Core services are ready.");

      // PHASE 1B – Heavy core services (non-blocking, background)
      dev.log(
        "AppInitializer: Phase 1B - Spawning heavy core service initialization in the background...",
      );
      _runInBackground(_initializeCoreServicesHeavy);

      // PHASE 2 – Maintenance / server status (async, but not CPU-heavy)
      dev.log(
        "AppInitializer: Phase 2 - Performing critical, blocking server checks...",
      );
      if (await _checkServerStatus()) {
        dev.log(
          "AppInitializer: Server is in maintenance. Halting further initialization.",
        );
        return;
      }

      // PHASE 3 – Authentication / user flow orchestration
      dev.log(
        "AppInitializer: Phase 3 - Critical checks passed. Starting user flow logic...",
      );
      _listenToAuthStateChanges();

      // PHASE 4 – Background reconciliation tasks (only if we're already ready)
      if (_status == AppStatus.ready) {
        dev.log(
          "AppInitializer: Phase 4 - Spawning non-blocking background tasks...",
        );
        _runInBackground(reconcileLocalAndRemoteModelCounts);
        _runInBackground(reconcileAndSyncPurchases);
        _runInBackground(ReferralHandler.checkAndStoreReferrer);
      }

      dev.log("AppInitializer: Initialization sequence complete.");
    } catch (e, s) {
      dev.log(
        "AppInitializer: CRITICAL FAILURE during initialization: $e\n$s",
      );
      if (!_coreServicesReadyCompleter.isCompleted) {
        _coreServicesReadyCompleter.completeError(e, s);
      }
    }
  }

  /// Initializes lightweight core services that are required before
  /// UI and high-level logic can safely proceed.
  ///
  /// These should be relatively fast and non-CPU heavy.
  Future<void> _initializeCoreServicesLightweight() async {
    await FlutterDownloader.initialize(
      debug: kDebugMode,
      ignoreSsl: true,
    );
    FlutterDownloader.registerCallback(downloadCallback);

    await _extrovertNotificationService.initialize();
    _extrovertNotificationService.recordAppOpen();
  }

  /// Initializes heavy core services that might be CPU intensive,
  /// executed in a non-blocking fashion.
  ///
  /// Any operation here should be safe to complete slightly later
  /// (i.e., not strictly required for the first screen).
  Future<void> _initializeCoreServicesHeavy() async {
    try {
      await OfflineModeratorService().initialize();
      debugPrint(
        "AppInitializer: Heavy core services initialized (offline moderator, etc.).",
      );
    } catch (e, s) {
      debugPrint(
        "AppInitializer: Heavy core service initialization failed: $e\n$s",
      );
      // Not fatal for startup; log to Crashlytics for visibility.
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: "heavyCoreServicesInitializationFailure",
      );
    }
  }

  /// Performs a blocking check for the server's maintenance status.
  ///
  /// Returns `true` and updates the app status if maintenance is active,
  /// otherwise returns `false`.
  Future<bool> _checkServerStatus() async {
    final bool isMaintenance =
    kDebugMode ? false : await checkMaintenanceMode();

    if (isMaintenance) {
      _updateStatus(AppStatus.maintenance);
      return true;
    }

    _extrovertNotificationService.schedulePendingNotification();
    return false;
  }

  void _listenToAuthStateChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (_status == AppStatus.initializing && user != null) {

      }
      if (_isRegistering) {
        dev.log(
          "Auth State Listener: Ignoring auth change because a registration is in progress.",
        );
        return;
      }

      _currentUser = user;

      // If we're mid sign-out and offline, ignore a null user to avoid
      // flickering state transitions due to connectivity noise.
      if (!_isSigningOut &&
          !_internetProvider.isConnected &&
          _status == AppStatus.ready &&
          user == null) {
        debugPrint(
          'Auth State Listener: Offline and in ready state. '
              'Ignoring null user from auth stream to maintain session.',
        );
        return;
      }

      if (user == null) {
        debugPrint(
          'Auth State Listener: User signed out. Disposing credits listener and clearing user data.',
        );
        CreditsManager.instance.dispose();
        _userProvider.clearDataOnSignOut();
        _determineUserFlow();
      } else {
        debugPrint(
          'Auth State Listener: User signed in. Initializing credits and user data listeners.',
        );
        CreditsManager.instance.listenToCredits();
        _userProvider.listenToUserData(user);
        _determineUserFlow();
      }
    });
  }

  /// Handles the complete, orchestrated user sign-out process centrally.
  Future<void> signOut() async {
    debugPrint(
      "AppInitializer: Starting orchestrated sign-out process.",
    );

    _isSigningOut = true;
    try {
      // STEP 1: Application-level data cleanup.
      _modelService.clearAllCache();
      CacheService.clearAll();
      debugPrint("AppInitializer: All in-memory caches cleared.");

      await const FlutterSecureStorage().deleteAll();
      debugPrint(
        "AppInitializer: All credentials cleared from secure storage.",
      );

      await _extrovertNotificationService.clearUserTokenOnSignOut();
      debugPrint("AppInitializer: FCM token cleared from server.");

      await FileDownloadHelper().cancelAllPendingDownloads();
      debugPrint("AppInitializer: All downloads cancelled.");

      // STEP 2: Sign out from auth providers.
      await _authService.signOutFromProviders();
      debugPrint(
        "AppInitializer: Provider sign-out successful. UI transition will now occur.",
      );
    } finally {
      _isSigningOut = false;
    }
  }

  /// Orchestrates the post-onboarding sequence:
  /// 1. Request notification permissions.
  /// 2. Re-evaluate the user flow and navigate accordingly.
  Future<void> completeOnboarding() async {
    debugPrint(
      "AppInitializer: Onboarding completed. Starting post-onboarding sequence.",
    );

    await _extrovertNotificationService.requestPermission();

    debugPrint(
      "AppInitializer: Permission flow complete. Resuming normal user flow.",
    );
    await _determineUserFlow();
  }

  /// Determines the correct application state based on the user's authentication
  /// and verification status, including a robust check for Firestore data readiness.
  ///
  /// This method is carefully structured to avoid heavy synchronous work on
  /// the main isolate and relies on async I/O instead.
  Future<void> _determineUserFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('has_completed_onboarding') ?? false;

    if (!hasCompletedOnboarding) {
      debugPrint(
        "[_determineUserFlow] Onboarding not completed. "
            "Setting status to needsOnboarding.",
      );
      _updateStatus(AppStatus.needsOnboarding);
      return;
    }

    final bool isConnected = _internetProvider.isConnected;

    if (!isConnected) {
      debugPrint(
        "[_determineUserFlow] Offline mode detected. "
            "Checking for cached user.",
      );
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        debugPrint(
          "[_determineUserFlow] Cached user found. "
              "Loading data from cache before proceeding.",
        );
        await _userProvider.fetchInitialData(currentUser);
        debugPrint(
          "[_determineUserFlow] Cached data loaded. "
              "Setting status to ready for offline access.",
        );
        _updateStatus(AppStatus.ready);
      } else {
        debugPrint(
          "[_determineUserFlow] No cached user found. Login is required.",
        );
        _updateStatus(AppStatus.needsLogin);
      }
      return;
    }

    // --- Online flow ---
    debugPrint(
      "[_determineUserFlow] Online mode detected. "
          "Proceeding with user authentication flow.",
    );
    User? user = FirebaseAuth.instance.currentUser;
    user ??= await _attemptAutoLogin();

    if (user == null) {
      debugPrint(
        "[_determineUserFlow] No authenticated user found. Needs login.",
      );
      _updateStatus(AppStatus.needsLogin);
      return;
    }

    try {
      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint(
          "[_determineUserFlow] User became null after reload. "
              "Forcing logout -> needsLogin.",
        );
        _updateStatus(AppStatus.needsLogin);
        return;
      }

      if (user.emailVerified) {
        debugPrint(
          "[_determineUserFlow] User email is verified (UID: ${user.uid}). "
              "Now checking for Firestore document readiness...",
        );

        bool userDocumentCreated;
        try {
          userDocumentCreated = await _waitForUserDocument(user.uid);
        } on FirebaseException catch (e, s) {
          FirebaseCrashlytics.instance.recordError(
            e,
            s,
            reason: "userDocCheckFailureNonRetryable",
          );
          userDocumentCreated = false;
        }

        if (userDocumentCreated) {
          debugPrint(
            "[_determineUserFlow] Firestore document found. App is truly ready.",
          );
          _updateStatus(AppStatus.ready);
        } else {
          debugPrint(
            "[_determineUserFlow] CRITICAL: User is verified but Firestore "
                "document was not created. Forcing logout.",
          );

          if (navigatorKey.currentContext != null &&
              navigatorKey.currentContext!.mounted) {
            final l10n = AppLocalizations.of(navigatorKey.currentContext!)!;
            _introvertNotificationService.showNotification(
              message: l10n.authError,
              type: NotificationType.error,
            );
          }
          await signOut();
        }
      } else {
        debugPrint(
          "[_determineUserFlow] User is authenticated but email is not verified. "
              "Showing verification screen.",
        );

        Map<String, dynamic>? data;

        try {
          final userDocServer = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(const GetOptions(source: Source.server))
              .timeout(const Duration(seconds: 6));

          data = userDocServer.data();
        } catch (_) {
          DocumentSnapshot<Map<String, dynamic>>? userDocCache;
          try {
            userDocCache = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(const GetOptions(source: Source.cache));
          } catch (_) {
            userDocCache = null;
          }

          data = userDocCache?.data();
        }

        _verificationScreenData = {
          'email': data?['email'] ?? user.email ?? '',
          'username': data?['username'] ?? '',
          'userId': user.uid,
          'password': '',
        };
        _updateStatus(AppStatus.needsVerification);
      }
    } catch (e, s) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-token-expired':
          case 'user-disabled':
          case 'user-not-found':
            debugPrint(
              "[_determineUserFlow] Non-recoverable auth state detected "
                  "(${e.code}). Forcing a clean sign-out.",
            );
            await signOut();
            break;

          case 'network-request-failed':
          case 'web-context-cancelled':
            debugPrint(
              "[_determineUserFlow] Network request failed during user "
                  "validation, but a cached user exists. Assuming offline and "
                  "proceeding to ready state.",
            );
            _updateStatus(AppStatus.ready);
            break;

          default:
            debugPrint(
              "[_determineUserFlow] Unhandled FirebaseAuthException: "
                  "${e.code}. Forcing logout.",
            );
            FirebaseCrashlytics.instance.recordError(
              e,
              s,
              reason: "authenticatedUserFlowFailure",
            );
            await signOut();
            break;
        }
      } else {
        debugPrint(
          "[_determineUserFlow] Non-Firebase CRITICAL error during "
              "authenticated user flow: $e. Forcing logout.",
        );
        FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: "authenticatedUserFlowFailure",
        );
        await signOut();
      }
    }
  }

  Duration _expBackoff(int attempt, {int baseMs = 300, int maxMs = 5000}) {
    final pow = 1 << attempt; // 1,2,4,8...
    final ms = (baseMs * pow).clamp(baseMs, maxMs);
    final jitter = (ms * 0.2).toInt();
    final actual = ms + (DateTime.now().microsecond % (jitter * 2)) - jitter;
    return Duration(milliseconds: actual);
  }

  bool _isRetryableFirestoreError(FirebaseException e) {
    const retryable = {
      'unavailable',
      'deadline-exceeded',
      'aborted',
      'internal',
      'resource-exhausted',
    };
    return e.plugin == 'cloud_firestore' && retryable.contains(e.code);
  }

  /// Polls Firestore to check for the existence of the user document.
  ///
  /// Returns `true` if the document is found within the timeout window,
  /// `false` otherwise.
  Future<bool> _waitForUserDocument(String uid) async {
    const int maxRetries = 8;

    for (int i = 0; i < maxRetries; i++) {
      debugPrint(
        "[_waitForUserDocument] Attempt ${i + 1}/$maxRetries to find user "
            "document for UID: $uid",
      );

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 6));

        if (userDoc.exists) {
          debugPrint("[_waitForUserDocument] Success (server). Document found.");
          return true;
        }

        DocumentSnapshot<Map<String, dynamic>>? cached;
        try {
          cached = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get(const GetOptions(source: Source.cache));
        } catch (_) {
          cached = null;
        }

        if (cached?.exists == true) {
          debugPrint(
            "[_waitForUserDocument] Cache says exists; treating as ready.",
          );
          return true;
        }

        await Future.delayed(_expBackoff(i));
        continue;
      } on FirebaseException catch (e, s) {
        if (_isRetryableFirestoreError(e)) {
          debugPrint(
            "[_waitForUserDocument] Retryable Firestore error ${e.code}; "
                "backing off and retrying.",
          );
          FirebaseCrashlytics.instance.recordError(
            e,
            s,
            reason: "waitForUserDocumentRetryable",
          );

          DocumentSnapshot<Map<String, dynamic>>? cached;
          try {
            cached = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get(const GetOptions(source: Source.cache));
          } catch (_) {
            cached = null;
          }

          if (cached?.exists == true) {
            debugPrint(
              "[_waitForUserDocument] Cache says exists (after error); "
                  "treating as ready.",
            );
            return true;
          }

          await Future.delayed(_expBackoff(i));
          continue;
        }

        rethrow;
      } on TimeoutException {
        debugPrint(
          "[_waitForUserDocument] Server timeout; checking cache + retry.",
        );

        DocumentSnapshot<Map<String, dynamic>>? cached;
        try {
          cached = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get(const GetOptions(source: Source.cache));
        } catch (_) {
          cached = null;
        }

        if (cached?.exists == true) {
          debugPrint(
            "[_waitForUserDocument] Cache says exists (after timeout); "
                "treating as ready.",
          );
          return true;
        }

        await Future.delayed(_expBackoff(i));
        continue;
      }
    }

    debugPrint(
      "[_waitForUserDocument] Failed to find user document after $maxRetries "
          "attempts.",
    );
    return false;
  }

  /// Tries to auto-login the user using credentials stored in secure storage.
  Future<User?> _attemptAutoLogin() async {
    debugPrint(
      'Startup: No active Firebase session. Checking secure storage for auto-login...',
    );
    const secureStorage = FlutterSecureStorage();

    try {
      final rememberMe = await secureStorage.read(key: 'remember_me');
      if (rememberMe == 'true') {
        final email = await secureStorage.read(key: 'email');
        final password = await secureStorage.read(key: 'password');

        if (email != null && password != null) {
          final cred = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          debugPrint(
            'Startup: Auto-login successful for UID: ${cred.user!.uid}',
          );
          return cred.user;
        }
      }
    } catch (e) {
      debugPrint(
        'Startup: Auto-login failed (credentials might be outdated). '
            'Clearing secure storage. Error: $e',
      );
      await secureStorage.deleteAll();
    }

    return null;
  }

  /// Helper to run a function in the background without awaiting it.
  void _runInBackground(Future<void> Function() task) {
    task().catchError((e, s) {
      debugPrint("Background task failed: $e\n$s");
      FirebaseCrashlytics.instance.recordError(e, s, reason: "backgroundTask");
    });
  }
}