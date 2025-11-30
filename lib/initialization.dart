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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:upgrader/upgrader.dart';
import 'cache.dart';
import 'chat/services/moderator.dart';
import 'internet.dart';
import 'l10n/app_localizations.dart';
import 'library/backend/download/download.dart';
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

      if (_status == AppStatus.ready && !_coreServicesReadyCompleter.isCompleted) {
        debugPrint("[AppInitializer] Status became READY via flow change. Triggering post-startup tasks.");
        _runInBackground(_performPostStartupTasks);
      }

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
  Future<void> initialize() async {
    dev.log("[AppInitializer] Phase 1: Fast Start. Status: $_status");

    // 1. Check Connectivity IMMEDIATELY.
    await _internetProvider.checkInternetConnection();

    if (await _checkForAppUpdate()) {
      dev.log("[AppInitializer] Update required. Flow halted.");
      return;
    }

    if (await _checkServerStatus()) {
      dev.log("[AppInitializer] Maintenance mode. Flow halted.");
      return;
    }

    if (_status == AppStatus.ready) {
      dev.log("[AppInitializer] User exists locally. UI will render. Scheduling background tasks.");
      _listenToAuthStateChanges();
      _runInBackground(_performPostStartupTasks);
    }
    else {
      _listenToAuthStateChanges();
      if (_status != AppStatus.initializing) {
        _runInBackground(_determineUserFlow);
      }
    }
  }

  /// It handles everything that used to block the startup.
  /// This method runs AFTER the main screen is visible.
  Future<void> _performPostStartupTasks() async {
    if (_isPostStartupTasksRunning || _coreServicesReadyCompleter.isCompleted) {
      return;
    }
    _isPostStartupTasksRunning = true;
    try
    {
      dev.log("[AppInitializer] Phase 2: Starting Background Verification & Heavy Init...");

      await Future.delayed(const Duration(milliseconds: 200));

      // 1. Initialize Heavy Libraries (Timezones, Downloader, etc.)
      await _initializeHeavyLibraries();

      await Future.delayed(Duration.zero);

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

  /// Checks for app updates using a hybrid approach.
  Future<bool> _checkForAppUpdate() async {

    // --- STRATEGY 1: STORE CHECK (UPGRADER) ---
    try {
      await upgrader.initialize();
      if (upgrader.isUpdateAvailable()) {
        dev.log("[AppInitializer] Upgrader detected a new version.");
        _updateStatus(AppStatus.updateRequired);
        return true;
      }
    } catch (e) {
      dev.log("[AppInitializer] Upgrader check failed: $e. Proceeding to Remote Config fallback.");
    }

    // --- STRATEGY 2: REMOTE CONFIG FALLBACK ---
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await remoteConfig.fetchAndActivate();

      final String minRequiredVersion = remoteConfig.getString('min_required_version');

      if (minRequiredVersion.isNotEmpty) {
        final packageInfo = await PackageInfo.fromPlatform();
        final String currentVersion = packageInfo.version;

        dev.log("[AppInitializer] Remote Config Check: Current ($currentVersion) vs Required ($minRequiredVersion)");

        if (_isCurrentVersionLower(currentVersion, minRequiredVersion)) {
          dev.log("[AppInitializer] Remote Config enforcement: Update required.");
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
      final length = [currParts.length, reqParts.length].reduce((a, b) => a > b ? a : b);
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

  /// Moved here from main.dart to unblock startup.
  Future<void> _initializeHeavyLibraries() async {
    try {
      // Timezones
      tz.initializeTimeZones();

      // Moderator
      await OfflineModeratorService().initialize();

      // Notification
      await _extrovertNotificationService.initialize();
      _extrovertNotificationService.recordAppOpen();

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
          dev.log("[AppInitializer] Critical: User verified but no doc. Logging out.");
          await signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle token expiration or corruption here (as discussed before)
      final bool isCorruptSessionError = e.code == 'unknown' &&
          (e.message?.contains('Json conversion failed') == true ||
              e.message?.contains('403') == true);

      if (isCorruptSessionError || e.code == 'user-token-expired' || e.code == 'user-disabled') {
        dev.log("[AppInitializer] Remote verification failed (${e.code}). Logging out.");
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
    if (_isSigningOut) {
      return;
    }

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
    debugPrint("AppInitializer: Starting orchestrated sign-out process.");

    _isSigningOut = true;
    try {
      // STEP 1: Application-level data cleanup.
      _modelService.clearAllCache();
      CacheService.clearAll();

      await const FlutterSecureStorage().deleteAll();
      await _extrovertNotificationService.clearUserTokenOnSignOut();
      await FileDownloadHelper().cancelAllPendingDownloads();

      // Clear User Provider Data Explicitly
      await _userProvider.clearDataOnSignOut();
      CreditsManager.instance.dispose();

      // STEP 2: Sign out from auth providers.
      await _authService.signOutFromProviders();

      _currentUser = null;

      debugPrint("AppInitializer: Sign-out complete. Forcing UI transition.");

      // STEP 3: FORCE UI UPDATE
      _updateStatus(AppStatus.needsLogin);

    } catch (e) {
      debugPrint("AppInitializer: Error during sign out: $e");
      _updateStatus(AppStatus.needsLogin);
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
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
  /// and verification status.
  ///
  /// This version is "BULLETPROOF". It prioritizes keeping the user IN the app
  /// over strict server validation during unstable network conditions.
  Future<void> _determineUserFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('has_completed_onboarding') ?? false;

    if (!hasCompletedOnboarding) {
      _updateStatus(AppStatus.needsOnboarding);
      return;
    }

    // 1. Initial Connectivity Check
    // If we are definitely offline, trust the local cache immediately.
    if (!_internetProvider.isConnected) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _userProvider.fetchInitialData(currentUser);
        _updateStatus(AppStatus.ready);
      } else {
        _updateStatus(AppStatus.needsLogin);
      }
      return;
    }

    // 2. Resolve Current User
    User? user = FirebaseAuth.instance.currentUser;
    user ??= await _attemptAutoLogin();

    if (user == null) {
      _updateStatus(AppStatus.needsLogin);
      return;
    }

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
          _updateStatus(AppStatus.ready);
        } else {
          // Critical: User verified, internet works, but NO doc exists after retries.
          // This implies a deleted account or data corruption.
          debugPrint("[_determineUserFlow] Critical: Verified user missing doc. Signing out.");
          await signOut();
        }

      } else {
        // 5. Handle Unverified User
        // We need to fetch data to show the email address on the Verify Screen.
        debugPrint("[_determineUserFlow] User email not verified. Loading verification data.");

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

        // A. TRANSIENT NETWORK ERRORS (DO NOT LOG OUT)
        // Includes: "unexpected end of stream", "network-request-failed", timeouts.
        final bool isNetworkGlitch =
            code == 'network-request-failed' ||
                msg.contains('end of stream') ||
                msg.contains('connection closed') ||
                msg.contains('socket') ||
                msg.contains('timeout') ||
                msg.contains('unable to resolve host');

        if (isNetworkGlitch) {
          debugPrint("[_determineUserFlow] Network error during reload ($code). Assuming Offline-Ready.");
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
          debugPrint("[_determineUserFlow] Corrupt session (HTML/403). Logging out safely.");
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
            debugPrint("[_determineUserFlow] Fatal auth error ($code). Signing out.");
            await signOut();
            break;

          default:
          // D. UNKNOWN FIREBASE ERRORS
          // If we don't know what it is, but it's NOT a network glitch,
          // it's safer to log it and sign out to prevent stuck states.
            debugPrint("[_determineUserFlow] Unhandled Firebase Error: $code. Signing out.");
            FirebaseCrashlytics.instance.recordError(e, s, reason: "AuthFlow_UnhandledFirebase");
            await signOut();
            break;
        }
      } else {
        // E. NON-FIREBASE ERRORS (Platform, etc.)
        // If it's a generic SocketException (not wrapped in FirebaseAuthException), handle it as network.
        if (e.toString().toLowerCase().contains('socketexception') ||
            e.toString().toLowerCase().contains('handshake')) {
          debugPrint("[_determineUserFlow] Socket/Handshake error. Assuming Offline-Ready.");
          _updateStatus(AppStatus.ready);
          return;
        }

        // Otherwise, it's a crash-worthy logic error.
        debugPrint("[_determineUserFlow] Critical system error: $e. Signing out.");
        FirebaseCrashlytics.instance.recordError(e, s, reason: "AuthFlow_SystemError");
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
      } on FirebaseException catch (e) {
        if (_isRetryableFirestoreError(e)) {
          debugPrint(
            "[_waitForUserDocument] Retryable Firestore error ${e.code}; "
                "backing off and retrying.",
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