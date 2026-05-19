// lib/initialization.dart
//
// Provides the `AppInitializer` service, which acts as the central brain for
// the application's startup and lifecycle state management. It is responsible
// for handling authentication, checking server status, and managing background
// synchronization tasks without blocking the user interface.

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/funds/backend.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/reconcile.dart';
import 'package:cortex/referral.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/settings/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:upgrader/upgrader.dart';
import 'cache.dart';
import 'chat/services/moderator.dart';
import 'internet.dart';
import 'l10n/app_localizations.dart';
import 'library/backend/download/download.dart';
import 'login/anonymous_device_entitlement.dart';
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

  bool _isFalOffline = false;
  bool get isFalOffline => _isFalOffline;

  StreamSubscription<DocumentSnapshot>? _falStatusSubscription;

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

  /// Flag used to follow post startup tasks.
  bool _isPostStartupTasksRunning = false;

  final AuthService _authService;
  final ModelService _modelService;
  final ExtrovertNotificationService _extrovertNotificationService;
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
        _internetProvider = internetProvider,
        _userProvider = userProvider {
    debugPrint("AppInitializer: Instantiated with initial status: $_status");
  }

  void _updateStatus(AppStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      debugPrint("AppInitializer: Status changed to $_status");

      if (_status == AppStatus.ready &&
          !_coreServicesReadyCompleter.isCompleted) {
        debugPrint(
            "[AppInitializer] Status became READY via flow change. Triggering post-startup tasks.");
        _runInBackground(_performPostStartupTasks);
      }

      notifyListeners();
    }
  }

  /// Forces the app into offline mode and re-evaluates the user flow.
  /// This allows users to bypass the maintenance screen.
  Future<void> bypassMaintenanceMode() async {
    debugPrint(
        "[AppInitializer] Bypassing maintenance mode (forcing offline)...");
    _internetProvider.setForceOffline(true);
    // Give a small delay to ensure the provider notifies listeners (though likely synchronous)
    // and for the UI to potentially react if needed, but mainly to ensure state consistency.
    await Future.delayed(const Duration(milliseconds: 100));
    await _determineUserFlow();
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
  Future<void> initialize() async {
    dev.log("[AppInitializer] Phase 1: Fast Start. Status: $_status");

    // 1. Check Connectivity IMMEDIATELY.
    await _internetProvider.checkInternetConnection();

    // [STARTUP PERF] Non-blocking model fetch — UI renders immediately with
    // stub model data from SharedPreferences. ChatSessionProvider hydrates
    // when the catalog arrives via refreshModelAfterCatalogLoad().
    // This saves 1-3s on cold start (network latency for Firestore fetch).
    final sysLocale = Platform.localeName.split('_').first;
    unawaited(_modelService.getModels(langCode: sysLocale).then((_) {
      dev.log("[AppInitializer] Model catalog loaded successfully");
    }).catchError((e) {
      dev.log("[AppInitializer] Model fetch failed (will retry later): $e");
    }));

    if (_internetProvider.isConnected) {
      // 2. Parallelize Remote Checks (Update & Maintenance)
      // This saves time by not waiting for one to finish before starting the other.
      final results = await Future.wait([
        _checkForAppUpdate(),
        _checkServerStatus(),
      ]);

      final bool updateRequired = results[0];
      final bool maintenanceActive = results[1];

      if (updateRequired) {
        dev.log("[AppInitializer] Update required. Flow halted.");
        return;
      }

      if (maintenanceActive) {
        dev.log("[AppInitializer] Maintenance mode. Flow halted.");
        return;
      }
    } else {
      // Offline fallback: skip remote checks
      dev.log("[AppInitializer] Offline. Skipping remote checks.");
    }

    if (_status == AppStatus.ready) {
      dev.log(
          "[AppInitializer] User exists locally. UI will render. Scheduling background tasks.");
      _listenToAuthStateChanges();
      _runInBackground(_performPostStartupTasks);
    } else {
      _listenToAuthStateChanges();
      if (_status != AppStatus.initializing) {
        _runInBackground(_determineUserFlow);
      }
    }
  }

  /// Checks for app updates using a hybrid approach.
  Future<bool> _checkForAppUpdate() async {
    // --- BYPASS FOR WEB & DEBUG ---
    if (kIsWeb || kDebugMode) return false;

    // --- STRATEGY 1: STORE CHECK (UPGRADER) ---
    try {
      await upgrader.initialize();
      if (upgrader.isUpdateAvailable()) {
        dev.log("[AppInitializer] Upgrader detected a new version.");
        _updateStatus(AppStatus.updateRequired);
        return true;
      }
    } catch (e) {
      dev.log(
          "[AppInitializer] Upgrader check failed: $e. Proceeding to Remote Config fallback.");
    }

    // --- STRATEGY 2: REMOTE CONFIG FALLBACK ---
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await remoteConfig.fetchAndActivate();

      final String minRequiredVersion =
          remoteConfig.getString('min_required_version');

      if (minRequiredVersion.isNotEmpty) {
        final packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        dev.log(
            "[AppInitializer] Remote Config Check: Current ($currentVersion) vs Required ($minRequiredVersion)");

        if (_isCurrentVersionLower(currentVersion, minRequiredVersion)) {
          dev.log(
              "[AppInitializer] Remote Config enforcement: Update required.");
          _updateStatus(AppStatus.updateRequired);
          return true;
        }
      }
    } catch (e) {
      dev.log("[AppInitializer] Remote Config check failed: $e");
    }

    return false;
  }

  /// Helper to compare semantic version strings (e.g., "2.9.4" vs "2.9.5").
  /// Returns true if [current] is lower than [required].
  bool _isCurrentVersionLower(String current, String required) {
    try {
      List<int> currParts = current.split('.').map(int.parse).toList();
      List<int> reqParts = required.split('.').map(int.parse).toList();

      // Normalize lengths (e.g. 2.9 vs 2.9.1)
      final length =
          [currParts.length, reqParts.length].reduce((a, b) => a > b ? a : b);
      for (int i = 0; i < length; i++) {
        final int c = i < currParts.length ? currParts[i] : 0;
        final int r = i < reqParts.length ? reqParts[i] : 0;

        if (c < r) return true; // Current is lower
        if (c > r) return false; // Current is higher
      }
    } catch (e) {
      dev.log("[AppInitializer] Error parsing versions: $e");
    }
    return false; // Assume safe if parsing fails
  }

  /// It handles everything that used to block the startup.
  /// This method runs AFTER the main screen is visible.
  Future<void> _performPostStartupTasks() async {
    if (_isPostStartupTasksRunning || _coreServicesReadyCompleter.isCompleted) {
      return;
    }
    _isPostStartupTasksRunning = true;
    try {
      dev.log(
          "[AppInitializer] Phase 2: Starting Background Verification & Heavy Init...");

      // PRIORITY: Preload Premium Screen Data FIRST (no delay!)
      // This ensures FundsScreen loads instantly when user navigates to it
      if (_currentUser != null && _internetProvider.isConnected) {
        dev.log('[AppInitializer] Starting Premium Screen preload...');
        final preloadSuccess = await FundsBackend.preloadInBackground();
        dev.log(
            '[AppInitializer] Premium Screen preload result: $preloadSuccess');
      } else {
        dev.log(
            '[AppInitializer] Skipping Premium preload - user: ${_currentUser != null}, internet: ${_internetProvider.isConnected}');
      }

      // Brief yield to let the UI render smoothly before heavy background work.
      await Future.delayed(const Duration(milliseconds: 300));

      // 1. Initialize Heavy Libraries (Only Timezones & Moderator now)
      await _initializeHeavyLibraries();

      // 2. Check Server Maintenance
      if (await _checkServerStatus()) {
        return;
      }

      // 3. Verify the User Session
      if (_currentUser != null && _internetProvider.isConnected) {
        await _verifyUserSessionRemote();
      }

      // 4. Background Reconciliations
      _runInBackground(reconcileLocalAndRemoteModelCounts);
      _runInBackground(reconcileAndSyncPurchases);

      if (Platform.isAndroid) {
        _runInBackground(ReferralHandler.checkAndStoreReferrer);
      }

      if (!_coreServicesReadyCompleter.isCompleted) {
        _coreServicesReadyCompleter.complete();
      }
      dev.log("[AppInitializer] Phase 2 Complete. App is fully synced.");
    } finally {
      if (!_coreServicesReadyCompleter.isCompleted) {
        _coreServicesReadyCompleter.complete();
        dev.log("[AppInitializer] Core Services Marked Ready (Finally Block).");
      }
    }
  }

  /// Moved here from main.dart to unblock startup.
  Future<void> _initializeHeavyLibraries() async {
    try {
      // Timezones
      tz.initializeTimeZones();

      // Parallelize Moderator and Notification service initialization
      await Future.wait([
        OfflineModeratorService().initialize(),
        _extrovertNotificationService.initialize(),
      ]);

      _extrovertNotificationService.recordAppOpen();

      dev.log("[AppInitializer] Heavy libraries initialized.");
    } catch (e) {
      dev.log("Error initializing heavy libraries: $e");
    }
  }

  /// Verifies the user with the server (Reload + Firestore).
  /// If this fails, we log the user out (Late-Fail strategy).
  Future<void> _verifyUserSessionRemote() async {
    try {
      dev.log("[AppInitializer] Verifying remote session...");
      await _currentUser!.reload();
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser == null) {
        await signOut();
        return;
      }

      // Load fresh data (Credits, etc.)
      _userProvider.listenToUserData(_currentUser!);

      // Check Firestore Document existence (Security check)
      if (_currentUser!.emailVerified) {
        final docExists = await _waitForUserDocument(_currentUser!.uid);
        if (!docExists) {
          dev.log(
              "[AppInitializer] Critical: User verified but no doc. Logging out.");
          await signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle token expiration or corruption here (as discussed before)
      final bool isCorruptSessionError = e.code == 'unknown' &&
          (e.message?.contains('Json conversion failed') == true ||
              e.message?.contains('403') == true);

      if (isCorruptSessionError ||
          e.code == 'user-token-expired' ||
          e.code == 'user-disabled') {
        dev.log(
            "[AppInitializer] Remote verification failed (${e.code}). Logging out.");
        await signOut();
      }
    } catch (e) {
      dev.log("[AppInitializer] Remote verification warning: $e");
      // If internet is flaky, we stay in 'ready' state (Offline mode).
    }
  }

  /// Performs a blocking check for the server's maintenance status.
  ///
  /// Returns `true` and updates the app status if maintenance is active,
  /// otherwise returns `false`.
  Future<bool> _checkServerStatus() async {
    // If we are offline (or forced offline), we shouldn't be blocked by server maintenance.
    if (!_internetProvider.isConnected) {
      return false;
    }

    final bool isMaintenance = await checkMaintenanceMode();

    if (isMaintenance) {
      if (kDebugMode) {
        debugPrint(
            "[AppInitializer] Server is in maintenance, but bypassing due to kDebugMode.");
      } else {
        _updateStatus(AppStatus.maintenance);
        return true;
      }
    }

    _extrovertNotificationService.schedulePendingNotification();
    return false;
  }

  StreamSubscription<User?>? _authSubscription;

  void _listenToAuthStateChanges() {
    if (_isSigningOut) {
      return;
    }

    // [BUG FIX] Prevent duplicate listeners if this is called multiple times
    if (_authSubscription != null) {
      return;
    }

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
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
        _falStatusSubscription?.cancel();
        _falStatusSubscription = null;
        CreditsManager.instance.dispose();
        _userProvider.clearDataOnSignOut();
        _determineUserFlow();
      } else {
        debugPrint(
          'Auth State Listener: User signed in. Initializing credits and user data listeners.',
        );
        await _registerAnonymousEntitlement(user);
        if (FirebaseAuth.instance.currentUser?.uid != user.uid) {
          debugPrint(
              'Auth State Listener: Ignoring stale signed-in event for ${user.uid}.');
          return;
        }
        _startFalStatusListener();
        CreditsManager.instance.listenToCredits();
        _userProvider.listenToUserData(user);
        _determineUserFlow();
      }
    });
  }

  void _startFalStatusListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (!_internetProvider.isConnected || _falStatusSubscription != null || user == null || user.isAnonymous) {
      return;
    }

    _falStatusSubscription = FirebaseFirestore.instance
        .collection('server')
        .doc('main')
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final isOffline = snapshot.data()?['isFalOffline'] ?? false;
      if (_isFalOffline != isOffline) {
        _isFalOffline = isOffline;
        notifyListeners();
      }
    }, onError: (Object error, StackTrace stackTrace) {
      debugPrint('[AppInitializer] Fal status listener paused: $error');
      
      final isPermissionDenied = error.toString().contains('permission-denied');
      if (!isPermissionDenied) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'FalStatusListener',
          fatal: false,
        );
      }
      _falStatusSubscription?.cancel();
      _falStatusSubscription = null;
    });
  }

  Future<void> _registerAnonymousEntitlement(User user) async {
    if (!user.isAnonymous) return;

    try {
      await AnonymousDeviceEntitlement.instance.registerIfAnonymous(user);
    } catch (e, s) {
      debugPrint(
          "AppInitializer: Anonymous entitlement registration failed: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: "AnonymousDeviceEntitlement",
        fatal: false,
      );
    }
  }

  /// Handles the complete, orchestrated user sign-out process centrally.
  Future<void> signOut() async {
    debugPrint("AppInitializer: Starting orchestrated sign-out process.");

    _isSigningOut = true;
    try {
      // Cancel the auth subscription to be recreated when we return to login
      _authSubscription?.cancel();
      _authSubscription = null;
      await _falStatusSubscription?.cancel();
      _falStatusSubscription = null;

      // STEP 1: Application-level data cleanup.
      _modelService.clearAllCache();
      CacheService.clearAll();

      await const FlutterSecureStorage().deleteAll();
      await _extrovertNotificationService.clearUserTokenOnSignOut();
      await FileDownloadHelper().cancelAllPendingDownloads();

      // STEP 2: Sign out from auth providers.
      await _authService.signOutFromProviders();
      await _ensureFirebaseAuthSessionCleared();

      // STEP 3: Clear local user-bound state only after auth session is closed.
      await _userProvider.clearDataOnSignOut();
      CreditsManager.instance.dispose();

      _currentUser = null;

      debugPrint(
          "AppInitializer: Sign-out complete. Restarting in anonymous mode.");

      // STEP 4: Re-evaluate user flow to trigger anonymous login
      await _determineUserFlow();
    } catch (e) {
      debugPrint("AppInitializer: Error during sign out: $e");
      await _determineUserFlow();
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isSigningOut = false;
      // Re-attach the auth listener now that sign-out is complete
      _listenToAuthStateChanges();
    }
  }

  Future<void> _ensureFirebaseAuthSessionCleared() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    debugPrint(
      "AppInitializer: Firebase user still present after signOut(). Waiting for auth state to settle.",
    );

    try {
      await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((user) => user == null)
          .timeout(const Duration(seconds: 3));
      return;
    } on TimeoutException {
      debugPrint(
        "AppInitializer: Auth stream did not emit null in time. Retrying hard Firebase signOut.",
      );
      await FirebaseAuth.instance.signOut().timeout(const Duration(seconds: 5));
      await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((user) => user == null)
          .timeout(const Duration(seconds: 3));
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      throw StateError(
        "Firebase session is still active after sign-out retry (uid: ${currentUser.uid}).",
      );
    }
  }

  /// Orchestrates the post-onboarding sequence:
  /// Re-evaluates the user flow and navigates accordingly.
  Future<void> completeOnboarding() async {
    debugPrint(
      "AppInitializer: Onboarding completed. Resuming normal user flow.",
    );
    await _determineUserFlow();
  }

  /// Completes the verification flow and explicitly moves to the ready state.
  /// This must be used instead of direct navigator pushes to keep the routing lifecycle alive.
  void completeVerificationState() {
    debugPrint(
        "AppInitializer: Verification completed. Setting status to ready.");
    _updateStatus(AppStatus.ready);
  }

  /// Determines the correct application state based on the user's authentication
  /// and verification status.
  ///
  /// This version is "BULLETPROOF". It prioritizes keeping the user IN the app
  /// over strict server validation during unstable network conditions.
  Future<void> _determineUserFlow() async {
    // 1. Initial Connectivity Check
    // If we are definitely offline, trust the local cache immediately.
    if (!_internetProvider.isConnected) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _userProvider.fetchInitialData(currentUser);
      }
      // If offline and no user, still proceed to ready.
      _updateStatus(AppStatus.ready);
      return;
    }

    // 2. Resolve Current User
    User? user = FirebaseAuth.instance.currentUser;
    user ??= await _attemptAutoLogin();

    if (user == null) {
      debugPrint(
          'AppInitializer: No user found. Signing in anonymously for lazy registration.');
      try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        user = userCredential.user;
        if (user != null) {
          await _registerAnonymousEntitlement(user);
          _startFalStatusListener();
        }
      } catch (e) {
        debugPrint('AppInitializer: Fatal error during anonymous login: $e');
      }

      if (user == null) {
        // If anonymous login fails (e.g. offline on first open), still proceed to ready state.
        _updateStatus(AppStatus.ready);
        return;
      }
    }

    // --- OPTIMISTIC INIT: Load from cache immediately ---
    // This ensures the UI (Premium banner, avatar, username) is populated
    // instantly, eliminating the "blank state" flash while waiting for the network.
    await _userProvider.loadFromCache(user: user);
    // Use notifyListeners inside the provider if needed, or if data is set,
    // the provider getter will return it when the UI builds.

    // If we have valid cached data, we can signal the UI to be ready,
    // although we still perform the security checks below.
    // For now, we populate the data so when 'ready' fires properly, it's populated.

    try {
      // 3. Attempt Server Sync (Reload)
      // This is where "end of stream" errors usually happen.
      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      // Edge case: User deleted while app was running?
      if (user == null) {
        _updateStatus(AppStatus.needsLogin);
        return;
      }

      // --- USER IS AUTHENTICATED BEYOND THIS POINT ---
      _startFalStatusListener();

      // 4. Check Verification Status
      if (user.emailVerified || user.isAnonymous) {
        // User is logically ready. Now check/wait for their database doc.

        bool userDocumentReady = false;
        try {
          // Robust check with retries
          userDocumentReady = await _waitForUserDocument(user.uid);
        } catch (e) {
          debugPrint("[_determineUserFlow] Warning: Doc check failed ($e).");
          // If anonymous, or if it failed due to network, be lenient.
          // For a new registration, the doc might be creating via Cloud Functions.
          // Better to let them in than kick them out.
          userDocumentReady = true;
        }

        if (userDocumentReady) {
          // Success Path
          // Also fetch models here! Useful if they logged out and logged in (cache was cleared).
          try {
            final sysLocale = Platform.localeName.split('_').first;
            // Don't wait for it completely here to not block ready.
            _modelService.getModels(langCode: sysLocale);
          } catch (e) {
            debugPrint("[_determineUserFlow] Failed to getModels: $e");
          }

          _updateStatus(AppStatus.ready);
        } else {
          // Critical: User verified, internet works, but NO doc exists after retries.
          // This implies a deleted account or data corruption.
          debugPrint(
              "[_determineUserFlow] Critical: Verified user missing doc. Signing out.");
          await signOut();
        }
      } else {
        // 5. Handle Unverified User
        // We need to fetch data to show the email address on the Verify Screen.
        debugPrint(
            "[_determineUserFlow] User email not verified. Loading verification data.");

        Map<String, dynamic>? data;
        try {
          // Try server first
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          data = doc.data();
        } catch (_) {
          // Fallback to cache/local info if server fails
          data = null;
        }

        _verificationScreenData = {
          'email': data?['email'] ?? user.email ?? '',
          'username': data?['username'] ?? '',
          'userId': user.uid,
          'password': '', // Password not needed for simple status check
        };
        _updateStatus(AppStatus.needsVerification);
      }
    } catch (e, s) {
      // --- CRITICAL ERROR HANDLING SECTION ---

      if (e is FirebaseAuthException) {
        final String msg = e.message?.toLowerCase() ?? '';
        final String code = e.code;

        final bool isConnectionFailure = msg.contains('failed to connect') ||
            msg.contains('connection refused') ||
            msg.contains('network is unreachable');

        // A. TRANSIENT NETWORK ERRORS (DO NOT LOG OUT)
        // Includes: "unexpected end of stream", "network-request-failed", timeouts.
        final bool isNetworkGlitch = code == 'network-request-failed' ||
            isConnectionFailure ||
            msg.contains('end of stream') ||
            msg.contains('connection closed') ||
            msg.contains('socket') ||
            msg.contains('timeout') ||
            msg.contains('unable to resolve host');

        if (isNetworkGlitch) {
          debugPrint(
              "[_determineUserFlow] Network error during reload ($code). Assuming Offline-Ready.");
          // Even though reload failed, the local session is likely valid.
          // Let the user in. The UserProvider will handle missing data.
          _updateStatus(AppStatus.ready);
          return;
        }

        // B. CORRUPT SESSION ERRORS (MUST LOG OUT)
        // Usually caused by captive portals (public wifi) returning HTML instead of JSON.
        final bool isCorruptSession = code == 'unknown' &&
            (msg.contains('json conversion failed') ||
                msg.contains('403') ||
                msg.contains('forbidden') ||
                msg.contains('html'));

        if (isCorruptSession) {
          debugPrint(
              "[_determineUserFlow] Corrupt session (HTML/403). Logging out safely.");
          await signOut();
          return;
        }

        // C. FATAL AUTH ERRORS (MUST LOG OUT)
        switch (code) {
          case 'user-token-expired':
          case 'user-disabled':
          case 'user-not-found':
          case 'invalid-credential':
          case 'session-cookie-expired':
            debugPrint(
                "[_determineUserFlow] Fatal auth error ($code). Signing out.");
            await signOut();
            break;

          default:
            // D. UNKNOWN FIREBASE ERRORS
            // If we don't know what it is, but it's NOT a network glitch,
            // it's safer to log it and sign out to prevent stuck states.
            debugPrint(
                "[_determineUserFlow] Unhandled Firebase Error: $code. Signing out.");
            FirebaseCrashlytics.instance
                .recordError(e, s, reason: "AuthFlow_UnhandledFirebase");
            await signOut();
            break;
        }
      } else {
        // E. NON-FIREBASE ERRORS (Platform, etc.)
        // If it's a generic SocketException (not wrapped in FirebaseAuthException), handle it as network.
        if (e.toString().toLowerCase().contains('socketexception') ||
            e.toString().toLowerCase().contains('handshake') ||
            e.toString().toLowerCase().contains('certpathvalidator')) {
          debugPrint(
              "[_determineUserFlow] Socket/Handshake/Cert error. Assuming Offline-Ready.");
          _updateStatus(AppStatus.ready);
          return;
        }

        // Otherwise, it's a crash-worthy logic error.
        debugPrint(
            "[_determineUserFlow] Critical system error: $e. Signing out.");
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: "AuthFlow_SystemError");
        await signOut();
      }
    }
  }

  /// Listens to Firestore to check for the existence of the user document via Stream.
  ///
  /// Returns `true` if the document is found within the timeout window,
  /// `false` otherwise. Uses a 15-second timeout to effortlessly handle any server delays.
  Future<bool> _waitForUserDocument(String uid) async {
    try {
      debugPrint(
          "[_waitForUserDocument] Starting real-time stream for UID: $uid");
      final docStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(includeMetadataChanges: true);

      // Wait for the first snapshot that actually exists
      final firstValidDoc = await docStream
          .firstWhere(
            (snapshot) => snapshot.exists,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint(
          "[_waitForUserDocument] Success. Profile document streamed successfully!");
      return firstValidDoc.exists;
    } on TimeoutException {
      debugPrint(
          "[_waitForUserDocument] Stream timed out after 15 seconds. Checking cache fallback.");

      try {
        final cached = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(const GetOptions(source: Source.cache));
        if (cached.exists) {
          debugPrint("[_waitForUserDocument] Cache fallback successful.");
          return true;
        }
      } catch (_) {}

      return false;
    } catch (e) {
      debugPrint("[_waitForUserDocument] Fatal error checking stream: $e");
      return false;
    }
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
