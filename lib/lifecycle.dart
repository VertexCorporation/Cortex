// lifecycle.dart
//
// App-wide shell widgets that live directly under MaterialApp.
// - AppLifecycleManager: orchestrates routing between high-level app states
//   (onboarding, auth, maintenance, update, ready).
// - MainScreen: hosts bottom navigation and the three primary sections
//   (Chat, Library, Menu).
// - BottomNavigationButton: animated icon+label button used in the nav bar.
// - showExitConfirmationDialog: centralized confirmation dialog on app exit.

import 'package:cortex/initialization.dart';
import 'package:cortex/login/screen.dart';
import 'package:cortex/login/verify.dart';
import 'package:cortex/main.dart';
import 'package:cortex/maintenance.dart';
import 'package:cortex/notifications/extrovert.dart';
import 'package:cortex/screen.dart';
import 'package:cortex/update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'meet.dart';

/// Routes the user to the correct screen depending on [AppInitializer.status].
/// Handles:
/// - First-time onboarding
/// - Login / verification
/// - Maintenance & forced-update screens
/// - Main app shell when ready
class AppLifecycleManager extends StatefulWidget {
  const AppLifecycleManager({super.key});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  AppStatus? _previousStatus;
  bool _splashRemoved = false;
  bool _firstLaunchConversationStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final initializer = Provider.of<AppInitializer>(context, listen: false);
    _previousStatus = initializer.status;

    // Kick off the initialization.
    // Since 'initialize()' is now non-blocking/fast, this will return almost instantly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      initializer.initialize();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;

    context
        .read<ExtrovertNotificationService>()
        .handleAppLifecycleStateChange(state);
    debugPrint('AppLifecycleManager: App lifecycle state changed: $state');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInitializer>(
      builder: (BuildContext context, AppInitializer initializer, Widget? _) {
        final AppStatus currentStatus = initializer.status;

        // We remove the splash as soon as we are NOT initializing.
        // Since Bootstrap now returns 'ready' or 'needsLogin' immediately,
        // this happens almost instantly.
        if (!_splashRemoved && currentStatus != AppStatus.initializing) {
          _splashRemoved = true;

          // Defer removal slightly to ensure the MainScreen frame is painted.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            debugPrint('AppLifecycleManager: UI Ready. Removing Native Splash.');
            FlutterNativeSplash.remove();
          });
        }

        debugPrint(
          'AppLifecycleManager: Rebuilding. Current: $currentStatus, Previous: $_previousStatus',
        );

        // Remove native splash exactly once once we are past the initializing state.
        if (!_splashRemoved && currentStatus != AppStatus.initializing) {
          _splashRemoved = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            debugPrint(
              'AppLifecycleManager: First real frame is ready. Removing native splash...',
            );
            FlutterNativeSplash.remove();
          });
        }

        // If the user is logged out from a ready/initializing state, pop back
        // to the first route (e.g. login).
        if ((_previousStatus == AppStatus.ready ||
            _previousStatus == AppStatus.initializing) &&
            currentStatus == AppStatus.needsLogin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (navigatorKey.currentState != null &&
                navigatorKey.currentState!.canPop()) {
              debugPrint(
                'AppLifecycleManager: Logout detected. Resetting navigation stack.',
              );
              navigatorKey.currentState!.popUntil(
                    (Route<dynamic> route) => route.isFirst,
              );
            }
          });
        }

        _previousStatus = currentStatus;

        if (!_firstLaunchConversationStarted &&
            currentStatus == AppStatus.ready) {

          _firstLaunchConversationStarted = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              mainScreenKey.currentState?.startNewConversation(isDynamic: true);
            }
          });
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _buildScreenForStatus(initializer),
        );
      },
    );
  }

  /// Maps each [AppStatus] to the appropriate root screen.
  Widget _buildScreenForStatus(AppInitializer initializer) {
    final AppStatus status = initializer.status;

    switch (status) {
      case AppStatus.needsOnboarding:
        return const OnboardingScreen(key: ValueKey('OnboardingScreen'));

      case AppStatus.needsLogin:
        return const AuthScreen(key: ValueKey('AuthScreen'));

      case AppStatus.needsVerification:
        final verificationData = initializer.verificationScreenData;
        if (verificationData != null) {
          return EmailVerificationScreen(
            key: const ValueKey('VerificationScreen'),
            email: verificationData['email'],
            username: verificationData['username'],
            userId: verificationData['userId'],
            password: verificationData['password'],
          );
        }
        // Fallback: if somehow verification data is missing, go to auth screen.
        return const AuthScreen(key: ValueKey('AuthScreen_Fallback'));

      case AppStatus.maintenance:
        return const MaintenanceScreen(key: ValueKey('MaintenanceScreen'));

      case AppStatus.updateRequired:
        return const UpdateRequiredScreen(key: ValueKey('UpdateScreen'));

      case AppStatus.initializing:
      // While initializing, let the native splash stay visible.
        return const SizedBox.shrink(key: ValueKey('Initializing'));

      case AppStatus.ready:
        return MainScreen(key: mainScreenKey);
    }
  }
}