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
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat/services/moderator.dart';
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


  /// This method now contains ALL the startup logic that was previously in main().
  /// It determines the correct screen to show and then navigates to it.
  ///
  /// FINAL, CORRECTED VERSION:
  /// This strategy correctly handles plugins that require main-isolate initialization (like flutter_downloader)
  /// by running them sequentially after the initial UI has rendered, while still parallelizing other
  /// lightweight async tasks to optimize startup time. This prevents the "Bad state: BackgroundIsolateBinaryMessenger" error.
  Future<void> _initializeAndNavigate() async {
    // --- START: All logic from the original main() function is moved here ---

    // --- STEP 1: Start lightweight, truly async tasks in parallel first. ---
    // These tasks (SharedPreferences, internet check) do not block the UI thread.
    // We start them but don't await them yet.
    debugPrint('Initialization: Starting parallel fetch of Core Services...');
    final coreServicesFuture = _initializeCoreServices();

    // --- STEP 2: Sequentially initialize heavy, main-thread-dependent plugins. ---
    // Since this runs inside a post-frame callback, the initial loading UI has
    // already been painted, preventing a frozen screen on app launch.
    // Isolate.run() has been removed as it is not compatible with this plugin.
    debugPrint(
        'Initialization: Sequentially initializing Flutter Downloader on the main thread...');
    await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: true);
    FlutterDownloader.registerCallback(downloadCallback);
    debugPrint('Initialization: Flutter Downloader is ready.');

    // --- STEP 3: Now, await the completion of the lightweight tasks. ---
    final (prefs, isConnected) = await coreServicesFuture;
    debugPrint('Initialization: Core Services are ready.');

    // --- The rest of the logic remains exactly the same ---

    await OfflineModeratorService().initialize();

    Widget finalStartupScreen;

    if (isConnected) {
      debugPrint('Initialization: Online. Checking server status...');
      bool isServerInMaintenance = await _checkMaintenanceMode();

      await prefs.setBool('is_in_maintenance', isServerInMaintenance);
      await prefs.setInt('maintenance_last_checked', DateTime
          .now()
          .millisecondsSinceEpoch);
      debugPrint(
          'Initialization: Server status saved. Maintenance = $isServerInMaintenance');

      if (isServerInMaintenance) {
        finalStartupScreen = const MaintenanceScreen();
      } else {
        finalStartupScreen = await _determineStartupScreen(prefs, isConnected);
      }
    } else {
      debugPrint(
          'Initialization: Offline. Checking last known status from local storage...');
      bool wasInMaintenance = prefs.getBool('is_in_maintenance') ?? false;

      if (wasInMaintenance) {
        int lastCheckedMillis = prefs.getInt('maintenance_last_checked') ?? 0;
        var lastCheckedTime = DateTime.fromMillisecondsSinceEpoch(
            lastCheckedMillis);
        var oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

        if (lastCheckedTime.isBefore(oneHourAgo)) {
          debugPrint(
              'Initialization: Offline, but maintenance info is STALE (>1 hour old). Allowing offline access.');
          finalStartupScreen =
          await _determineStartupScreen(prefs, isConnected);
        } else {
          debugPrint(
              'Initialization: Last known status is maintenance and data is FRESH. Enforcing lockdown.');
          finalStartupScreen = const MaintenanceScreen();
        }
      } else {
        debugPrint(
            'Initialization: Last known status is operational. Proceeding with normal offline mode.');
        finalStartupScreen = await _determineStartupScreen(prefs, isConnected);
      }
    }

    debugPrint(
        'Initialization: Final startup screen determined: ${finalStartupScreen
            .runtimeType}');

    // This listener should be set up early so it's ready when the app starts.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint(
            'Auth State Listener: User signed out. Disposing credits listener.');
        CreditsManager.instance.dispose();
      } else {
        debugPrint(
            'Auth State Listener: User signed in. Initializing credits listener.');
        CreditsManager.instance.listenToCredits();
      }
    });

    // --- END: All logic from the original main() function ---

    // Now, navigate to the determined screen with a fade transition.
    if (mounted) {
      debugPrint(
          "InitializationScreen: All tasks complete. Fading out and navigating...");

      // Trigger the fade-out animation for the loading UI
      setState(() {
        _isLoading = false;
      });

      // Wait for the fade-out to complete before navigating away.
      await Future.delayed(const Duration(milliseconds: 400));

      if (mounted) {
        navigatorKey.currentState?.pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation,
                secondaryAnimation) => finalStartupScreen,
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, animation, secondaryAnimation,
                child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    }
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

/// Reconciles the number of local user-created models with the counts stored on the server.
///
/// This function is a critical self-healing mechanism that corrects data discrepancies
/// which can arise if a user manually clears the app's storage or reinstalls the app.
/// It treats the local database as the "source of truth" and updates the server to match,
/// ensuring users are never unfairly blocked from creating new models due to "ghost data".
Future<void> _reconcileLocalAndRemoteModelCounts() async {
  debugPrint('Reconciliation: Starting model count consistency check...');
  final user = FirebaseAuth.instance.currentUser;

  // This check can only run for an authenticated user.
  if (user == null) {
    debugPrint('Reconciliation: No user logged in. Skipping.');
    return;
  }

  try {
    // STEP 1: Get LOCAL state (The Device's Ground Truth)
    // We query the local DB directly for the most accurate current state of user models.
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

    // STEP 3: Compare and Act if a Discrepancy Exists
    // If the local and remote counts do not match, we trigger the secure Cloud Function.
    if (localRoleplayCount != remoteRoleplayCount || localOfflineCount != remoteOfflineCount) {
      debugPrint('Reconciliation: Discrepancy detected! Initiating server-side reconciliation.');

      final callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('reconcileModelCounts');
      await callable.call({
        'localRoleplayCount': localRoleplayCount,
        'localOfflineCount': localOfflineCount,
      });

      debugPrint('Reconciliation: Server counts successfully updated to match local state.');
    } else {
      debugPrint('Reconciliation: Local and remote model counts are in sync. No action needed.');
    }
  } on FirebaseFunctionsException catch (e) {
    // It's safe to fail gracefully here. The check will run again on the next app launch.
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
    final rememberMe = await secureStorage.read(key: 'remember_me');

    if (rememberMe == 'true') {
      final email = await secureStorage.read(key: 'email');
      final password = await secureStorage.read(key: 'password');

      // Check for email/password combo (Google Sign-In won't have a password)
      if (email != null && password != null) {
        try {
          debugPrint('Startup: Credentials found. Attempting silent auto-login...');
          final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          user = userCredential.user; // Success! We have a user now.
          debugPrint('Startup: Auto-login successful for UID: ${user!.uid}');
        } catch (e) {
          debugPrint('Startup: Auto-login failed (credentials might be outdated). Clearing secure storage. Error: $e');
          await secureStorage.deleteAll();
          return const LoginScreen(); // Navigate to login after failure.
        }
      } else if (email != null) {
        // This case handles Google Sign-In where only email and remember_me flag exist.
        // We can't auto-login, but we also shouldn't block the user. We'll proceed to LoginScreen.
        debugPrint('Startup: Remembered user is likely a Google user. Proceeding to LoginScreen for re-authentication.');
        return const LoginScreen();
      }
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