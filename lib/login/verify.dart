// verify.dart

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../notifications/introvert.dart';
import '../reconcile.dart';
import '../screen.dart';
import '../theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String username;
  final String userId;
  final String? password;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.username,
    required this.userId,
    this.password,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late IntrovertNotificationService _notificationService;
  static const int totalVerificationDuration = 86400;
  int _remainingSeconds = totalVerificationDuration;
  Timer? _countdownTimer;
  Timer? _emailCheckTimer;
  bool _isVerified = false;
  bool _isResendLoading = false;
  bool _isContinuing = false;

  /// Securely saves the user's credentials after they register, ensuring the
  /// "Remember Me" feature works correctly from the very first launch.
  Future<void> _saveRememberMeState() async {
    final secureStorage = const FlutterSecureStorage();
    await secureStorage.write(key: 'remember_me', value: 'true');
    await secureStorage.write(key: 'email', value: widget.email);
    await secureStorage.write(key: 'password', value: widget.password);
    dev.log('[EmailVerification] Saved credentials securely for new user.', name: 'EmailVerification');
  }

  /// Navigates the user to the main app.
  /// The user document is guaranteed to exist by the time this screen is reached,
  /// so this function is now a simple, direct navigator.
  Future<void> _continueToApp() async {
    if (_isContinuing) return;
    if (!mounted) return;

    setState(() => _isContinuing = true);
    _cancelTimers();

    try {
      dev.log('[Continue] User chose to continue without verification. Navigating to MainScreen.', name: 'EmailVerification');

      await _saveRememberMeState();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => MainScreen(key: mainScreenKey),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    } catch (e, st) {
      dev.log('[Continue] Unexpected error during navigation: $e', name: 'EmailVerification', error: e, stackTrace: st);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _notificationService.showNotification(message: l10n.authError, type: NotificationType.error);
        setState(() => _isContinuing = false);
        _startTimers();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _notificationService = Provider.of<IntrovertNotificationService>(context, listen: false);
    _initializeRemainingTime();
    _startTimers();
  }

  void _startTimers() {
    // Ensure any existing timers are cancelled before starting new ones to prevent duplicates.
    _countdownTimer?.cancel();
    _emailCheckTimer?.cancel();

    // This timer is for the UI countdown display. It doesn't make network calls.
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() => _remainingSeconds--);
        }
      } else {
        timer.cancel(); // Stop the countdown when it reaches zero.
      }
    });

    // This timer periodically checks if the user's email has been verified.
    // This is where the network call happens and where the error must be handled.
    _emailCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // THE FIX IS IMPLEMENTED HERE:
      // We wrap the entire network-dependent logic in a try-catch block
      // to gracefully handle potential network failures without crashing the app.
      try {
        final user = FirebaseAuth.instance.currentUser;

        // Safety check: If for some reason the user is no longer signed in,
        // stop the timer to prevent further errors.
        if (user == null) {
          dev.log('[EmailVerification] User is null, stopping verification check.', name: 'EmailVerification');
          timer.cancel();
          return;
        }

        // This is the network request that was causing the crash.
        // It fetches the latest user data from Firebase servers.
        await user.reload();

        // After reload(), we need to get the updated user object instance.
        final freshUser = FirebaseAuth.instance.currentUser;

        // Check the verification status on the fresh user object.
        if (freshUser != null && freshUser.emailVerified) {
          dev.log('[EmailVerification] Email has been successfully verified for ${freshUser.email}.', name: 'EmailVerification');
          _handleVerified(); // Trigger navigation to the main app
          timer.cancel();      // Stop this timer as its job is done.
        }
      } on FirebaseAuthException catch (e) {
        // This block specifically catches Firebase-related exceptions.
        if (e.code == 'network-request-failed') {
          // This is the expected error when the device is offline.
          // We log it for debugging but do not crash the app. The timer will simply try again.
          dev.log('[EmailVerification] Network request failed while checking email status. Will retry.', name: 'EmailVerification');
        } else {
          // Log other potential Firebase errors (e.g., 'user-token-expired') for diagnostics.
          dev.log('[EmailVerification] A Firebase error occurred during verification check: ${e.code}', name: 'EmailVerification', error: e);
        }
      } catch (e) {
        // This is a general catch-all for any other unexpected errors,
        // ensuring the application remains stable under all circumstances.
        dev.log('[EmailVerification] A generic error occurred during verification check.', name: 'EmailVerification', error: e);
      }
    });
  }

  /// Handles successful email verification.
  void _handleVerified() {
    if (!_isVerified) {
      setState(() => _isVerified = true);
      _cancelTimers();
      dev.log('Email ${widget.email} successfully verified. Preparing to navigate to MainScreen.', name: 'EmailVerification');

      _navigateToMainScreenAfterVerification();
    }
  }

  /// Saves user state, runs purchase reconciliation, and then navigates.
  Future<void> _navigateToMainScreenAfterVerification() async {
    await _saveRememberMeState();

    dev.log('[EmailVerification] Running purchase reconciliation after successful verification.', name: 'EmailVerification');
    await reconcileAndSyncPurchases();

    if(mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainScreen(key: mainScreenKey),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }


  void _cancelTimers() {
    _countdownTimer?.cancel();
    _emailCheckTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  Future<void> _initializeRemainingTime() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (doc.exists && doc.data()?['createdAt'] != null) {
        final Timestamp createdAtTimestamp = doc.data()!['createdAt'];
        final DateTime createdAt = createdAtTimestamp.toDate();
        final int verifyAttempts = doc.data()?['verifyAttempts'] ?? 0;
        final DateTime deadline = createdAt.add(Duration(hours: 24 * (verifyAttempts + 1)));
        final remaining = deadline.difference(DateTime.now()).inSeconds;
        if (mounted) {
          setState(() {
            _remainingSeconds = remaining > 0 ? remaining : 0;
          });
        }
      }
    } catch (e) {
      dev.log('Error fetching user creation data: $e', name: 'EmailVerification');
      if (mounted) {
        setState(() {
          _remainingSeconds = totalVerificationDuration;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    final l10n = AppLocalizations.of(context)!;
    if (!mounted) return;
    setState(() => _isResendLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not signed in.");
      }
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
      final docSnapshot = await userDocRef.get();
      final int verifyAttempts = docSnapshot.exists ? (docSnapshot.data()?['verifyAttempts'] ?? 0) : 0;
      if (verifyAttempts >= 2) {
        _notificationService.showNotification(
          message: l10n.maxResendLimitReached,
          bottomOffset: 0.02,
          type: NotificationType.error,
        );
        return;
      }
      dev.log('Attempting to resend verification email to ${user.email}...', name: 'EmailVerification');
      await user.sendEmailVerification();
      dev.log('Verification email sent successfully.', name: 'EmailVerification');
      await userDocRef.update({
        'verifyAttempts': FieldValue.increment(1),
      });
      dev.log('Incremented verifyAttempts to ${verifyAttempts + 1}.', name: 'EmailVerification');
      await _initializeRemainingTime();
      _notificationService.showNotification(
        message: l10n.linkSent,
        type: NotificationType.success,
        bottomOffset: 0.02,
      );
    } on FirebaseAuthException catch (e) {
      dev.log('Error resending verification email: ${e.code}', name: 'EmailVerification', error: e);
      if (e.code == 'too-many-requests') {
        _notificationService.showNotification(message: l10n.tooManyRequests, type: NotificationType.error, bottomOffset: 0.02);
      } else {
        _notificationService.showNotification(message: '${l10n.authError}: ${e.message}', type: NotificationType.error, bottomOffset: 0.02);
      }
    } catch (e) {
      dev.log('Unknown error during resend: $e', name: 'EmailVerification', error: e);
      _notificationService.showNotification(message: l10n.authError, type: NotificationType.error, bottomOffset: 0.02);
    } finally {
      if (mounted) {
        setState(() => _isResendLoading = false);
      }
    }
  }

  String _formatTime(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final availableWidth = constraints.maxWidth;
            return Center(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -availableHeight * 0.21,
                        left: -availableWidth * 0.2,
                        child: Transform.rotate(
                          angle: -80 * pi / 180,
                          child: Container(
                            width: availableWidth * 1.2,
                            height: availableWidth * 1.2,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(availableWidth * 0.15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: availableWidth * 0.8,
                        height: availableWidth * 0.75,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset('assets/icons/verification.png'),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: availableWidth * 0.1),
                    child: Text(
                      appLocalizations.verifyYourEmail,
                      style: TextStyle(
                        fontSize: availableHeight * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: availableHeight * 0.01),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: availableWidth * 0.06),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: availableHeight * 0.02,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        children: [
                          TextSpan(text: '${appLocalizations.pleaseCheckYourEmail} '),
                          TextSpan(
                            text: widget.email,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  if (!_isVerified) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: availableWidth * 0.1),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.senaryColor,
                            padding: EdgeInsets.symmetric(vertical: availableHeight * 0.022),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isResendLoading ? null : _resendVerificationEmail,
                          child: _isResendLoading
                              ? SizedBox(
                            height: availableHeight * 0.02,
                            width: availableHeight * 0.02,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                          )
                              : Text(
                            appLocalizations.resendCode,
                            style: TextStyle(color: AppColors.primaryColor, fontSize: availableHeight * 0.02, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: availableHeight * 0.01),
                    // "Continue without verification" button - **MODIFIED**
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: availableWidth * 0.1),
                      child: TextButton(
                        onPressed: _isContinuing ? null : _continueToApp, // **CHANGED**
                        child: _isContinuing // **CHANGED**
                            ? SizedBox( // Show a small loader
                          height: availableHeight * 0.02,
                          width: availableHeight * 0.02,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor.inverted,
                          ),
                        )
                            : Text(
                          appLocalizations.verificationScreenContinueWithoutVerification,
                          style: TextStyle(
                            fontSize: availableHeight * 0.02,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor.inverted,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: availableHeight * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: availableHeight * 0.02),
                      child: Text(
                        appLocalizations.verificationScreenWarning,
                        style: TextStyle(fontSize: availableHeight * 0.017, color: AppColors.primaryColor.inverted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    AnimatedTime(
                      time: _formatTime(_remainingSeconds),
                      style: TextStyle(
                          fontSize: availableHeight * 0.025,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(flex: 1),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Animated Widgets (No changes needed) ---
class AnimatedDigit extends StatelessWidget {
  final String digit;
  final TextStyle? style;
  const AnimatedDigit({super.key, required this.digit, this.style});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(digit, key: ValueKey<String>(digit), style: style),
    );
  }
}

class AnimatedTime extends StatelessWidget {
  final String time; // "HH:MM:SS"
  final TextStyle? style;
  const AnimatedTime({super.key, required this.time, this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: time.split('').map((char) {
        return char.contains(RegExp(r'\d'))
            ? AnimatedDigit(digit: char, style: style)
            : Text(char, style: style);
      }).toList(),
    );
  }
}