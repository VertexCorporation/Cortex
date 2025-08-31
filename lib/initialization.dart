// lib/initialization.dart
//
// This screen acts as a smart, high-performance loading gate for the application.
// Its primary purpose is to be displayed IMMEDIATELY after the native splash screen,
// preventing any "skipped frames" or jank by offloading all heavy initialization
// tasks from the main() function.
//
// ARCHITECTURE:
// 1. main() calls runApp() with this screen as the home widget.
// 2. The UI (a pulsing animation) is built and rendered instantly.
// 3. In `initState`, a post-frame callback starts the `_initializeAndNavigate` method.
// 4. This method performs all the original async startup logic (Firebase, user auth, etc.).
// 5. Once the final destination screen is determined, this screen fades out its
//    loading UI and navigates using `pushReplacement`, providing a seamless transition.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/referral.dart';
import 'package:cortex/server/credits.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'chat/services/moderator.dart';
import 'l10n/app_localizations.dart';
import 'login/login.dart';
import 'login/verify.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Import necessary widgets and keys from main.dart
import 'main.dart';
import 'theme.dart';
import 'models/backend/data.dart';

/// A custom messages class for Upgrader that uses the app's own localization logic.
/// This is the correct way to provide custom translations as per the documentation.
class AppUpgraderMessages extends UpgraderMessages {
  final AppLocalizations appLocalizations;

  AppUpgraderMessages({required this.appLocalizations});

  /// Overrides the message function to provide custom language localization.
  @override
  String? message(UpgraderMessage messageKey) {
    // We only need to override the messages we want to customize.
    switch (messageKey) {
      case UpgraderMessage.title:
        return appLocalizations.updateRequiredTitle;
      case UpgraderMessage.body:
        return appLocalizations.updateRequiredMessage;
      case UpgraderMessage.buttonTitleUpdate:
        return appLocalizations.updateNowButton;

    // For any other messages (like release notes, ignore button, etc.),
    // we fall back to the package's default translations.
      default:
        return super.message(messageKey);
    }
  }
}

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> with SingleTickerProviderStateMixin {
  /// Controls the fade-in/out of the loading animation.
  late final AnimationController _animationController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint("InitializationScreen: initState - UI is ready to be built.");

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..repeat(reverse: true);

    // This is the key to a jank-free startup. We wait until the first frame is
    // painted, and only THEN do we start our heavy async work.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
          "InitializationScreen: Post-frame callback triggered. Starting heavy initialization.");
      _initializeAndNavigate();
    });
  }



  /// This method now contains ALL the startup logic. It determines the correct
  /// screen and then wraps it with the mandatory update checker before navigating.
  Future<void> _initializeAndNavigate() async {
    // --- The initial setup steps ---
    debugPrint('Initialization: Starting parallel fetch of Core Services...');
    final coreServicesFuture = _initializeCoreServices();

    debugPrint('Initialization: Sequentially initializing Flutter Downloader on the main thread...');
    await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: true);
    FlutterDownloader.registerCallback(downloadCallback);
    debugPrint('Initialization: Flutter Downloader is ready.');

    final (prefs, isConnected) = await coreServicesFuture;
    debugPrint('Initialization: Core Services are ready.');

    await OfflineModeratorService().initialize();

    Widget finalStartupScreen;

    if (isConnected) {
      debugPrint('Initialization: Online. Checking server status...');
      // We only need to check for maintenance mode now. Upgrader handles its own logic.
      final isServerInMaintenance = kDebugMode ? false : await _checkMaintenanceMode();

      await prefs.setBool('is_in_maintenance', isServerInMaintenance);
      await prefs.setInt('maintenance_last_checked', DateTime.now().millisecondsSinceEpoch);
      debugPrint('Initialization: Server status saved. Maintenance = $isServerInMaintenance');

      // The update check is now handled declaratively by the UpgradeAlert wrapper.
      // We first determine the screen assuming there's no update or maintenance.
      if (isServerInMaintenance) {
        finalStartupScreen = const MaintenanceScreen();
      } else {
        finalStartupScreen = await _determineStartupScreen(prefs, isConnected);
      }
    } else {
      // Offline logic remains unchanged...
      finalStartupScreen = await _determineStartupScreen(prefs, isConnected);
    }

    debugPrint('Initialization: Final startup screen determined: ${finalStartupScreen.runtimeType}');

    // Auth state listener remains the same...
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('Auth State Listener: User signed out. Disposing credits listener.');
        CreditsManager.instance.dispose();
      } else {
        debugPrint('Auth State Listener: User signed in. Initializing credits listener.');
        CreditsManager.instance.listenToCredits();
      }
    });

    if (mounted) {
      debugPrint("InitializationScreen: All tasks complete. Fading out and navigating...");
      setState(() { _isLoading = false; });
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {

        // --- THE KEY CHANGE IS HERE ---
        // We wrap the determined screen with our configured UpgradeAlert.
        // It will only show the alert if an update is available; otherwise, it will show its child.
        final screenWithUpdateCheck = _buildUpdateScreen(context, finalStartupScreen);

        navigatorKey.currentState?.pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => screenWithUpdateCheck,
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  /// Wraps the target screen with a configured `UpgradeAlert`.
  /// The alert is configured to be non-dismissible and mandatory.
  /// THIS IS THE FINAL, CORRECTED VERSION FOR UPGRADER v11.5.0+.
  Widget _buildUpdateScreen(BuildContext context, Widget childScreen) {
    // 1. Create the Upgrader instance, now only passing our custom messages class.
    final upgrader = Upgrader(
      debugLogging: kDebugMode,
      messages: AppUpgraderMessages(appLocalizations: AppLocalizations.of(context)!),
      // For iOS, providing the App Store ID is highly recommended.
      // storeController: UpgraderStoreController(ios: StoreConfig(appId: 'YOUR_APP_STORE_ID')),
    );

    // 2. Configure UpgradeAlert directly with the correct, documented parameters.
    return UpgradeAlert(
      upgrader: upgrader,
      child: childScreen,

      // --- THESE ARE THE PARAMETERS FOR THE WIDGET ---
      barrierDismissible: false,
      // Explicitly hide the "IGNORE" button.
      showIgnore: false,

      // Explicitly hide the "LATER" button.
      showLater: false,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme
        .of(context)
        .colorScheme
        .onBackground;

    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final logoSize = screenWidth * 0.4;

    return AnimatedOpacity(
      opacity: _isLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: FadeTransition(
            opacity: _animationController,
            child: SvgPicture.asset(
              'assets/cortex.svg',
              width: logoSize,
              height: logoSize,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- HELPER FUNCTIONS ---

/// Replaces the old `_checkAndUpdateSubscription`. This function handles ALL purchases,
/// not just subscriptions. It's designed to find and process any "stuck"
/// transactions, such as unconsumed credits, on every app startup.
Future<void> reconcileAndSyncPurchases() async {
  debugPrint('Purchase Sync: Starting full, non-blocking purchase reconciliation process.');
  final InAppPurchase iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? streamSubscription;

  try {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Purchase Sync: No authenticated user. Skipping.');
      return;
    }

    if (!await iap.isAvailable()) {
      debugPrint('Purchase Sync: In-App Purchase service is unavailable. Skipping.');
      return;
    }

    final completer = Completer<void>();
    final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

    // This temporary listener will catch all purchase details delivered by the store.
    streamSubscription = iap.purchaseStream.listen(
          (purchaseDetailsList) async {
        debugPrint('Purchase Sync: Received ${purchaseDetailsList.length} purchase details from the stream.');

        // If the stream returns an empty list, it means there are no pending items.
        // We can complete the process immediately.
        if (purchaseDetailsList.isEmpty && !completer.isCompleted) {
          completer.complete();
          return;
        }

        for (final purchaseDetails in purchaseDetailsList) {
          // Process any item that is in a valid state but may not have been finalized.
          if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {

            debugPrint('Purchase Sync: Found a valid pending/restored purchase: ${purchaseDetails.productID}. Verifying with server...');

            try {
              // Call our robust server-side function.
              // It will grant entitlement AND, crucially, CONSUME consumables if needed.
              final callable = functions.httpsCallable('verifyPurchase');
              await callable.call<dynamic>({
                'receiptData': purchaseDetails.verificationData.serverVerificationData,
                'productId': purchaseDetails.productID,
                'platform': defaultTargetPlatform.name.toLowerCase(),
              });
              debugPrint('Purchase Sync: Server verification successful for ${purchaseDetails.productID}.');

              // CRITICAL: After successful server verification, we must complete
              // the purchase on the client side to acknowledge it with the store.
              if (purchaseDetails.pendingCompletePurchase) {
                await iap.completePurchase(purchaseDetails);
                debugPrint('Purchase Sync: Client-side purchase completion successful for ${purchaseDetails.productID}.');
              }
            } catch (e) {
              debugPrint('Purchase Sync: ERROR during server verification for ${purchaseDetails.productID}. It will be retried on next app launch. Error: $e');
              // Do NOT complete the purchase if verification fails, allowing it to be retried.
            }
          } else if (purchaseDetails.status == PurchaseStatus.error) {
            debugPrint('Purchase Sync: Purchase with error found for ${purchaseDetails.productID}: ${purchaseDetails.error}');
          }
        }

        // Once all items in this batch are processed, we can consider the task complete.
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onDone: () {
        debugPrint("Purchase Sync: Purchase stream was closed.");
        if (!completer.isCompleted) completer.complete();
      },
      onError: (error) {
        debugPrint("Purchase Sync: Error on purchase stream: $error");
        if (!completer.isCompleted) completer.completeError(error);
      },
    );

    // This is the key call. It triggers the store to send all active subscriptions
    // AND any un-acknowledged purchases, including unconsumed consumables.
    await iap.restorePurchases();
    debugPrint('Purchase Sync: `restorePurchases()` called to trigger stream events.');

    // Wait for the stream to process its events OR for a timeout to occur.
    await Future.any([
      completer.future,
      Future.delayed(const Duration(seconds: 15)), // A generous 15-second timeout.
    ]);
    debugPrint('Purchase Sync: Reconciliation process finished or timed out.');

  } catch (e) {
    debugPrint("Purchase Sync: A critical error occurred during the reconciliation setup: $e");
  } finally {
    // CRITICAL: Always cancel the temporary listener to prevent memory leaks.
    await streamSubscription?.cancel();
    debugPrint("Purchase Sync: Reconciliation listener has been cancelled.");
  }
}

/// This self-healing mechanism handles data discrepancies. Its logic is now aligned
/// with the secure server-side function which ONLY allows INCREASING the count.
///
/// 1.  If `localCount > serverCount`: This is a legitimate sync-up. The user may have
///     created models offline. We call the Cloud Function to update the server.
/// 2.  If `localCount < serverCount`: This indicates local data loss (e.g., app data cleared).
///     We DO NOT call the function, as decreasing the server count is forbidden.
///     The server remains the "source of truth" for the user's limits.
/// 3.  If `localCount == serverCount`: Everything is in sync. No action is needed.
Future<void> _reconcileLocalAndRemoteModelCounts() async {
  debugPrint('Reconciliation: Starting model count consistency check...');
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    debugPrint('Reconciliation: No user logged in. Skipping.');
    return;
  }

  try {
    // STEP 1: Get LOCAL state (The Device's Ground Truth)
    final db = await DatabaseHelper.instance.database;
    final localRoleplayModels = await db.query('models', where: "id LIKE 'self_%'");
    final localOfflineModels = await db.query('models', where: "id LIKE 'local_%'");
    final int localRoleplayCount = localRoleplayModels.length;
    final int localOfflineCount = localOfflineModels.length;
    debugPrint('Reconciliation: Local state -> Roleplay: $localRoleplayCount, Offline: $localOfflineCount');

    // STEP 2: Get REMOTE state (The Server's Believed State)
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      debugPrint('Reconciliation: User document not found on server. Skipping.');
      return;
    }
    final remoteData = userDoc.data()!;
    final int remoteRoleplayCount = remoteData['roleplayModelCount'] ?? 0;
    final int remoteOfflineCount = remoteData['offlineModelCount'] ?? 0;
    debugPrint('Reconciliation: Remote state -> Roleplay: $remoteRoleplayCount, Offline: $remoteOfflineCount');

    // --- STEP 3 (REVISED): Compare and Act SECURELY ---
    bool needsSyncUp = localRoleplayCount > remoteRoleplayCount || localOfflineCount > remoteOfflineCount;

    if (needsSyncUp) {
      debugPrint('Reconciliation: Local count is higher. Initiating server-side sync-up.');

      final callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('reconcileModelCounts');
      // We still send both counts, the server will decide which one to update.
      await callable.call({
        'localRoleplayCount': localRoleplayCount,
        'localOfflineCount': localOfflineCount,
      });

      debugPrint('Reconciliation: Server counts successfully updated to match local state.');
    } else if (localRoleplayCount < remoteRoleplayCount || localOfflineCount < remoteOfflineCount) {
      debugPrint('Reconciliation: Server count is higher. This indicates local data loss. No action taken to prevent exploiting limits.');
      // This is a good place to log an analytics event to monitor how often this happens.
    }
    else {
      debugPrint('Reconciliation: Local and remote model counts are in sync. No action needed.');
    }
  } on FirebaseFunctionsException catch (e) {
    debugPrint("Reconciliation: Failed to call Cloud Function. It will be retried on next launch. Error: ${e.code} - ${e.message}");
  } catch (e) {
    debugPrint("Reconciliation: An unexpected error occurred during the process: $e");
  }
}


/// Initializes core services in the correct order to prevent race conditions,
/// while still parallelizing independent tasks to optimize startup time.
Future<(SharedPreferences, bool)> _initializeCoreServices() async {
  debugPrint('Startup: Starting sequenced initialization of core services.');

  // STEP 1: Initialize Firebase FIRST. This is a blocking call because other
  // services (like OfflineModeratorService) depend on it.
  await Firebase.initializeApp();
  debugPrint('Startup: Firebase initialized successfully.');

  // STEP 2: Initialize services that depend on Firebase.
  await OfflineModeratorService().initialize();
  debugPrint('Startup: Offline Moderator service initialized.');

  // STEP 3: Now that all dependencies are met, run the remaining truly
  // independent tasks in parallel to fetch their results quickly.
  debugPrint('Startup: Starting parallel fetch of SharedPreferences and Internet status.');
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    InternetConnection().hasInternetAccess,
    ReferralHandler.checkAndStoreReferrer(),
  ]);
  debugPrint('Startup: Parallel fetching complete.');

  final prefs = results[0] as SharedPreferences;
  final isConnected = results[1] as bool;

  return (prefs, isConnected);
}

/// If no session exists, it attempts a silent auto-login using credentials
/// from secure storage. This makes the "Remember Me" feature resilient against
/// aggressive OS background process killers.
Future<Widget> _determineStartupScreen(SharedPreferences prefs, bool isConnected) async {
  debugPrint('Startup: Beginning startup screen determination process...');

  if (!isConnected) {
    debugPrint('Startup: Operating in offline mode.');
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint('Startup: Offline with a cached user session. Showing MainScreen.');
      return MainScreen(key: mainScreenKey);
    } else {
      debugPrint('Startup: Offline with no cached session. Showing LoginScreen.');
      return const LoginScreen();
    }
  }

  // --- ONLINE LOGIC ---
  User? user = await FirebaseAuth.instance.authStateChanges().first;

  // If Firebase session is null, attempt auto-login from secure storage
  if (user == null) {
    debugPrint('Startup: No active Firebase session found. Checking secure storage for auto-login...');
    const secureStorage = FlutterSecureStorage();

    try {
      final rememberMe = await secureStorage.read(key: 'remember_me');

      if (rememberMe == 'true') {
        final email = await secureStorage.read(key: 'email');
        final password = await secureStorage.read(key: 'password');

        if (email != null && password != null) {
          debugPrint('Startup: Credentials found. Attempting silent auto-login...');
          final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          user = userCredential.user;
          debugPrint('Startup: Auto-login successful for UID: ${user!.uid}');
        } else if (email != null) {
          debugPrint('Startup: Remembered user is likely a Google user. Proceeding to LoginScreen for re-authentication.');
          return const LoginScreen();
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Startup: Secure storage could not be read (likely corrupted or key changed). Wiping storage. Error: ${e.message}");
      await secureStorage.deleteAll();
      return const LoginScreen();
    } catch (e) {
      debugPrint('Startup: Auto-login failed (credentials might be outdated). Clearing secure storage. Error: $e');
      await secureStorage.deleteAll();
      return const LoginScreen();
    }
  }

  // --- At this point, 'user' is either the initially found user, the auto-logged-in user, or null.
  if (user == null) {
    debugPrint('Startup: No authenticated user after all checks. Showing LoginScreen.');
    return const LoginScreen();
  }

  // --- USER IS AUTHENTICATED: Use your existing robust logic ---
  try {
    debugPrint('Startup: User authenticated (${user.uid}). Starting parallel data sync and UI determination.');

    // Your existing background and UI-critical tasks run here.
    final backgroundReconciliation = Future.wait([
      _reconcileLocalAndRemoteModelCounts(),
      reconcileAndSyncPurchases(),
    ]);
    backgroundReconciliation
        .then((_) => debugPrint('Startup: [BACKGROUND] All reconciliation tasks completed successfully.'))
        .catchError((e) => debugPrint('Startup: [BACKGROUND] Error during reconciliation: $e'));

    final userDocFuture = FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final userReloadFuture = user.reload();

    final results = await Future.wait([userDocFuture, userReloadFuture]);
    final userDoc = results[0] as DocumentSnapshot;
    user = FirebaseAuth.instance.currentUser; // Get the reloaded user object

    if (!userDoc.exists) {
      debugPrint('Startup: CRITICAL: User exists in Auth but not in Firestore. Logging out.');
      await FirebaseAuth.instance.signOut();
      await const FlutterSecureStorage().deleteAll(); // Also clear invalid stored credentials
      return const LoginScreen();
    }

    if (user!.emailVerified) {
      debugPrint('Startup: Email verified, showing MainScreen.');
      return MainScreen(key: mainScreenKey);
    } else {
      debugPrint('Startup: Email not verified, showing EmailVerificationScreen.');
      final data = userDoc.data() as Map<String, dynamic>;
      // We pass an empty password because we should not expose the stored password to the UI.
      return EmailVerificationScreen(
        email: data['email'] ?? user.email ?? '',
        username: data['username'] ?? '',
        userId: user.uid,
        password: '',
      );
    }
  } catch (e) {
    debugPrint("Startup: Critical error during authenticated user flow: $e. Logging out.");
    await FirebaseAuth.instance.signOut();
    await const FlutterSecureStorage().deleteAll();
    return const LoginScreen();
  }
}

/// Checks if the server is in maintenance mode.
/// This function is called on startup if there is an internet connection.
/// Returns true if in maintenance, false otherwise.
Future<bool> _checkMaintenanceMode() async {
  debugPrint('Startup: Checking for server maintenance mode.');
  try {
    // Call the Cloud Function
    final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable('getServerStatus');
    final result = await callable.call();

    final bool isUnderMaintenance = result.data['isUnderMaintenance'] ?? false;
    debugPrint('Startup: Maintenance mode status from server: $isUnderMaintenance');

    return isUnderMaintenance;

  } on FirebaseFunctionsException catch (e) {
    debugPrint("Startup: Could not check maintenance mode, assuming it's off. Error: ${e.code} - ${e.message}");
    // Fail-safe: If the function fails, assume not in maintenance to avoid locking users out.
    return false;
  } catch (e) {
    debugPrint("Startup: An unexpected error occurred during maintenance check: $e");
    // Fail-safe for any other unexpected error.
    return false;
  }
}