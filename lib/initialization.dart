// initialization.dart
//
// It provides the `AppInitializer`
// service, which acts as the central brain for the application's startup and
// lifecycle state management. It is responsible for handling authentication,
// checking server status, and managing background synchronization tasks
// without blocking the user interface.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cortex/referral.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/server/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'chat/services/moderator.dart';
import 'internet.dart';
import 'l10n/app_localizations.dart';
import 'language.dart';
import 'main.dart';
import 'models/backend/data/database.dart';
import 'notifications.dart';

/// Defines the possible high-level states of the application.
enum AppStatus {
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
      case UpgraderMessage.title: return appLocalizations.updateRequiredTitle;
      case UpgraderMessage.body: return appLocalizations.updateRequiredMessage;
      case UpgraderMessage.buttonTitleUpdate: return appLocalizations.updateNowButton;
      default: return super.message(messageKey);
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

  // This completer acts as a gate. It will be completed only after
  // essential services like Firebase are initialized.
  final Completer<void> _coreServicesReadyCompleter = Completer<void>();

  /// UI components can await this Future to ensure core services are ready
  /// before attempting to use them (e.g., accessing Firebase).
  Future<void> get onCoreServicesReady => _coreServicesReadyCompleter.future;

  late final Upgrader upgrader;

  AppInitializer(AppStatus initialStatus) : _status = initialStatus {
    debugPrint("AppInitializer: Instantiated with initial status: $_status");
  }

  void _updateStatus(AppStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      debugPrint("AppInitializer: Status changed to $_status");
      notifyListeners();
    }
  }

  /// It's now structured to guarantee core services are ready before proceeding,
  /// with a critical, blocking check for server maintenance happening first.
  Future<void> initialize() async {
    debugPrint("AppInitializer: Starting initialization sequence. Current status is '$_status'.");
    // Record the app open time as early as possible for accurate scheduling.
    final context = navigatorKey.currentContext;
    if (context != null) {
      // We don't await this so it doesn't block the startup sequence.
      Provider.of<NotificationService>(context, listen: false).recordAppOpen();
    }
    try {
      // --- PHASE 1: CRITICAL CORE SERVICES (BLOCKING) ---
      // These must complete successfully before any other part of the app
      // can reliably function.
      debugPrint("AppInitializer: Phase 1 - Initializing critical core services...");
      await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: true);
      FlutterDownloader.registerCallback(downloadCallback);
      await OfflineModeratorService().initialize();

      // Signal that all critical, blocking services are now ready.
      // Any part of the app awaiting `onCoreServicesReady` can now proceed.
      if (!_coreServicesReadyCompleter.isCompleted) {
        _coreServicesReadyCompleter.complete();
      }
      debugPrint("AppInitializer: Phase 1 - SUCCESS. Core services are ready.");

      // --- PHASE 2: SERVER STATUS CHECK (BLOCKING) ---
      debugPrint("AppInitializer: Phase 2 - Checking server status...");

      final context = navigatorKey.currentContext;
      NotificationService? notificationService;
      if (context != null) {
        final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
        final l10n = await AppLocalizations.delegate.load(locale);
        notificationService = Provider.of<NotificationService>(context, listen: false);
        await notificationService.initialize(l10n);
      } else {
        debugPrint("[AppInitializer] CRITICAL: Could not get context to initialize NotificationService.");
      }

      if (await _checkServerStatus(notificationService)) {
        debugPrint("AppInitializer: Server is in maintenance. Halting further initialization.");
        return; // Halt execution if in maintenance mode.
      }
      debugPrint("AppInitializer: Phase 2 - SUCCESS. Server is online.");


      // --- PHASE 3: USER FLOW & NON-BLOCKING BACKGROUND TASKS ---
      // This part of the initialization can now safely run.
      debugPrint("AppInitializer: Phase 3 - Determining user flow...");
      _listenToAuthStateChanges();
      await _determineUserFlow();

      // These tasks run only if the user is fully authenticated and ready.
      if (_status == AppStatus.ready) {
        debugPrint("AppInitializer: Phase 3 - Spawning non-blocking background tasks...");
        _runInBackground(_checkForUpdates); // Check for non-critical updates in the background.
        _runInBackground(_reconcileLocalAndRemoteModelCounts);
        _runInBackground(reconcileAndSyncPurchases);
        _runInBackground(ReferralHandler.checkAndStoreReferrer);
      }

      debugPrint("AppInitializer: Initialization sequence complete.");

    } catch (e, s) {
      debugPrint("AppInitializer: CRITICAL FAILURE during initialization: $e\n$s");
      // If core services fail, we signal it so the app doesn't hang.
      if (!_coreServicesReadyCompleter.isCompleted) {
        _coreServicesReadyCompleter.completeError(e, s);
      }
      // Optionally, you could set a global error status here.
      // For now, the app will likely show an error in the part that failed.
    }
  }

  void _listenToAuthStateChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;

      final context = navigatorKey.currentContext;
      if (context == null) {
        debugPrint("[AppInitializer] Auth Listener: CRITICAL: Could not get context.");
        return;
      }
      final userProvider = Provider.of<UserProvider>(context, listen: false);


      if (user == null) {
        debugPrint('Auth State Listener: User signed out. Disposing credits listener and clearing user data.');
        CreditsManager.instance.dispose();

        userProvider.clearDataOnSignOut();

        _updateStatus(AppStatus.needsLogin);

      } else {
        debugPrint('Auth State Listener: User signed in. Initializing credits and user data listeners.');
        CreditsManager.instance.listenToCredits();

        userProvider.listenToUserData(user);

        _determineUserFlow();
      }
    });
  }

  Future<void> _determineUserFlow() async {
    final context = navigatorKey.currentContext;
    bool isConnected; // Define isConnected at a higher scope

    if (context == null) {
      debugPrint("[AppInitializer] CRITICAL ERROR: Could not get context to access InternetService.");
      FirebaseCrashlytics.instance.recordError(
          Exception("AppInitializer failed to get context for InternetService"),
          StackTrace.current,
          reason: "determineUserFlow_context_null"
      );

      // Failsafe: Assume offline if context is unavailable.
      isConnected = false;
    } else {
      final internetProvider = Provider.of<InternetProvider>(context, listen: false);
      isConnected = internetProvider.isConnected;
    }

    if (!isConnected) {
      debugPrint("Startup: Offline mode detected. Checking for cached user.");
      if (FirebaseAuth.instance.currentUser != null) {
        _updateStatus(AppStatus.ready);
      } else {
        _updateStatus(AppStatus.needsLogin);
      }
      return;
    }

    // --- Online Flow ---
    debugPrint("Startup: Online mode detected. Proceeding with user authentication flow.");
    User? user = FirebaseAuth.instance.currentUser;

    user ??= await _attemptAutoLogin();

    if (user == null) {
      debugPrint("Startup: No authenticated user found after checking cache and auto-login. Needs login.");
      _updateStatus(AppStatus.needsLogin);
      return;
    }

    // User is authenticated, now check Firestore data and verification status.
    try {
      await user.reload();
      user = FirebaseAuth.instance.currentUser; // Get reloaded user instance
      if (user == null) { // Should not happen, but as a safeguard
        debugPrint("Startup: User became null after reload. This is unexpected. Forcing logout.");
        _updateStatus(AppStatus.needsLogin);
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        debugPrint('Startup: CRITICAL: User exists in Auth but not in Firestore (UID: ${user.uid}). Forcing logout.');
        await FirebaseAuth.instance.signOut();
        await const FlutterSecureStorage().deleteAll();
        _updateStatus(AppStatus.needsLogin);
        return;
      }

      if (user.emailVerified) {
        debugPrint("Startup: User is authenticated and verified. App is ready.");
        _updateStatus(AppStatus.ready);
      } else {
        debugPrint("Startup: User is authenticated but email is not verified. Needs verification.");
        final data = userDoc.data() as Map<String, dynamic>;
        _verificationScreenData = {
          'email': data['email'] ?? user.email ?? '',
          'username': data['username'] ?? '',
          'userId': user.uid,
        };
        _updateStatus(AppStatus.needsVerification);
      }
    } catch (e, s) {
      debugPrint("Startup: CRITICAL error during authenticated user flow: $e. Forcing logout.");
      FirebaseCrashlytics.instance.recordError(e, s, reason: "authenticatedUserFlowFailure");
      await FirebaseAuth.instance.signOut();
      await const FlutterSecureStorage().deleteAll();
      _updateStatus(AppStatus.needsLogin);
    }
  }

  Future<User?> _attemptAutoLogin() async {
    debugPrint('Startup: No active Firebase session. Checking secure storage for auto-login...');
    const secureStorage = FlutterSecureStorage();
    try {
      final rememberMe = await secureStorage.read(key: 'remember_me');
      if (rememberMe == 'true') {
        final email = await secureStorage.read(key: 'email');
        final password = await secureStorage.read(key: 'password');

        if (email != null && password != null) {
          final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          debugPrint('Startup: Auto-login successful for UID: ${cred.user!.uid}');
          return cred.user;
        }
      }
    } catch (e) {
      debugPrint('Startup: Auto-login failed (credentials might be outdated). Clearing secure storage. Error: $e');
      await secureStorage.deleteAll();
    }
    return null;
  }

  /// Performs a blocking check for the server's maintenance status.
  ///
  /// Returns `true` and updates the app status if maintenance is active,
  /// otherwise returns `false`.
  Future<bool> _checkServerStatus(NotificationService? notificationService) async {
    final bool isMaintenance = kDebugMode ? false : await checkMaintenanceMode();
    if (isMaintenance) {
      _updateStatus(AppStatus.maintenance);
      return true;
    }

    notificationService?.schedulePendingNotification();

    return false;
  }

  /// Checks for a mandatory app update using the Upgrader package.
  /// This is intended to be run as a non-blocking background task.
  Future<void> _checkForUpdates() async {
    // We can't show Upgrader without a BuildContext, so we'll prepare it here
    // and let the UI decide when to show it.
    upgrader = Upgrader(
      debugLogging: kDebugMode,
      // The UI layer will provide the localized messages when it displays the alert.
    );

    if (upgrader.isUpdateAvailable()) {
      _updateStatus(AppStatus.updateRequired);
    }
  }

  /// Helper to run a function in the background without awaiting it.
  void _runInBackground(Future<void> Function() task) {
    task().catchError((e, s) {
      debugPrint("Background task failed: $e\n$s");
    });
  }
}


// --- All other helper functions from the old initialization.dart ---
// These are now private to this file and called by the AppInitializer service.

Future<bool> checkMaintenanceMode() async {
  try {
    final callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('getServerStatus');
    final result = await callable.call();
    return result.data['isUnderMaintenance'] ?? false;
  } catch (e) {
    debugPrint("Could not check maintenance mode, assuming it's off. Error: $e");
    return false;
  }
}

Future<void> _reconcileLocalAndRemoteModelCounts() async {
  debugPrint('Reconciliation: Starting model count consistency check...');
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final db = await DatabaseHelper.instance.database;
    final localRoleplayModels = await db.query('models', where: "id LIKE 'self_%'");
    final localOfflineModels = await db.query('models', where: "id LIKE 'local_%'");
    final int localRoleplayCount = localRoleplayModels.length;
    final int localOfflineCount = localOfflineModels.length;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return;

    final remoteData = userDoc.data()!;
    final int remoteRoleplayCount = remoteData['roleplayModelCount'] ?? 0;
    final int remoteOfflineCount = remoteData['offlineModelCount'] ?? 0;

    if (localRoleplayCount > remoteRoleplayCount || localOfflineCount > remoteOfflineCount) {
      debugPrint('Reconciliation: Local count is higher. Syncing up with server.');
      final callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('reconcileModelCounts');
      await callable.call({
        'localRoleplayCount': localRoleplayCount,
        'localOfflineCount': localOfflineCount,
      });
      debugPrint('Reconciliation: Server counts updated.');
    } else {
      debugPrint('Reconciliation: Counts are in sync or server is ahead. No action needed.');
    }
  } catch (e) {
    debugPrint("Reconciliation: Error during model count sync: $e");
  }
}

Future<void> reconcileAndSyncPurchases() async {
  debugPrint('Purchase Sync: Starting full purchase reconciliation.');
  final InAppPurchase iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? streamSubscription;

  try {
    if (FirebaseAuth.instance.currentUser == null || !await iap.isAvailable()) {
      return;
    }

    final completer = Completer<void>();
    final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

    streamSubscription = iap.purchaseStream.listen(
          (purchaseDetailsList) async {
        if (purchaseDetailsList.isEmpty && !completer.isCompleted) {
          completer.complete();
          return;
        }

        for (final purchase in purchaseDetailsList) {
          if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
            try {
              final callable = functions.httpsCallable('verifyPurchase');
              await callable.call<dynamic>({
                'receiptData': purchase.verificationData.serverVerificationData,
                'productId': purchase.productID,
                'platform': defaultTargetPlatform.name.toLowerCase(),
              });
              if (purchase.pendingCompletePurchase) {
                await iap.completePurchase(purchase);
              }
            } catch (e) {
              debugPrint('Purchase Sync: Server verification failed for ${purchase.productID}. Error: $e');
            }
          }
        }
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () => !completer.isCompleted ? completer.complete() : null,
      onError: (e) => !completer.isCompleted ? completer.completeError(e) : null,
    );

    await iap.restorePurchases();
    await Future.any([completer.future, Future.delayed(const Duration(seconds: 15))]);
  } catch (e) {
    debugPrint("Purchase Sync: A critical error occurred: $e");
  } finally {
    await streamSubscription?.cancel();
    debugPrint("Purchase Sync: Reconciliation listener cancelled.");
  }
}