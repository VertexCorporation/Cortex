// login.dart

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/login/verify.dart';
import 'package:cortex/main.dart';
import 'package:cortex/notifications.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/webview.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../initialization.dart';
import '../referral.dart';

// --- ShakeWidget (No changes needed) ---
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  const ShakeWidget({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  _ShakeWidgetState createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> {
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _offsetAnimation = Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        final dx = sin(pi * _offsetAnimation.value) * 8;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// --- LoginScreen ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

enum AuthMode { login, register }

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin, WidgetsBindingObserver{
  // --- (All properties remain the same, no changes needed here) ---
  // Firebase Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Form Keys
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  // UI State
  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  // Form Data
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _username = '';

  // Server-side Form Error Messages
  String? _loginEmailError;
  String? _loginPasswordError;
  String? _registerUsernameError;
  String? _registerEmailError;
  String? _registerPasswordError;
  String? _registerConfirmPasswordError;

  // Animation Controllers
  late final AnimationController _mainAnimationController;
  late final AnimationController _loginEmailShakeController;
  late final AnimationController _loginPasswordShakeController;
  late final AnimationController _registerUsernameShakeController;
  late final AnimationController _registerEmailShakeController;
  late final AnimationController _registerPasswordShakeController;
  late final AnimationController _registerConfirmPasswordShakeController;

  // Text Editing Controllers
  late final TextEditingController _loginEmailController;
  late final TextEditingController _registerEmailController;
  late final TextEditingController _registerUsernameController;
  late final TextEditingController _registerPasswordController;


  // Services
  late final NotificationService _notificationService;

  // Regular Expressions
  final RegExp _usernameRegExp = RegExp(
    r'^[a-z0-9çğıöşü._-]{3,20}$',
    caseSensitive: false,
  );

  final _secureStorage = const FlutterSecureStorage();

  // --- (initState, dispose, and other lifecycle/theme methods remain the same) ---
  @override
  void initState() {
    super.initState();
    _loginEmailController = TextEditingController();
    _registerEmailController = TextEditingController();
    _registerUsernameController = TextEditingController();
    _registerPasswordController = TextEditingController();
    _mainAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    const shakeDuration = Duration(milliseconds: 500);
    _loginEmailShakeController = AnimationController(vsync: this, duration: shakeDuration);
    _loginPasswordShakeController = AnimationController(vsync: this, duration: shakeDuration);
    _registerUsernameShakeController = AnimationController(vsync: this, duration: shakeDuration);
    _registerEmailShakeController = AnimationController(vsync: this, duration: shakeDuration);
    _registerPasswordShakeController = AnimationController(vsync: this, duration: shakeDuration);
    _registerConfirmPasswordShakeController = AnimationController(vsync: this, duration: shakeDuration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notificationService = Provider.of<NotificationService>(context, listen: false);
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _registerEmailController.dispose();
    _registerUsernameController.dispose();
    _registerPasswordController.dispose();
    _mainAnimationController.dispose();
    _loginEmailShakeController.dispose();
    _loginPasswordShakeController.dispose();
    _registerUsernameShakeController.dispose();
    _registerEmailShakeController.dispose();
    _registerPasswordShakeController.dispose();
    _registerConfirmPasswordShakeController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) {
      _applyTheme();
    }
  }

  void _syncThemeAndSystemUI() {
    final brightness = MediaQuery.of(context).platformBrightness;
    final themeCode = brightness == Brightness.dark ? 'dark' : 'light';
    if (AppColors.currentTheme != themeCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted){
          Provider.of<ThemeProvider>(context, listen: false).changeTheme(themeCode);
        }
      });
    }
    _applyThemeColors(themeCode);
  }

  void _applyTheme() {
    final brightness = MediaQuery.of(context).platformBrightness;
    final themeCode = brightness == Brightness.dark ? 'dark' : 'light';
    _applyThemeColors(themeCode);
  }

  void _applyThemeColors(String themeCode){
    final colors = AppColors.getThemeColors(themeCode);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: colors.statusBarColor,
        statusBarIconBrightness: colors.statusBarIconBrightness,
        systemNavigationBarColor: colors.navigationBarColor,
        systemNavigationBarIconBrightness: colors.navigationBarIconBrightness,
      ),
    );
  }

  // It securely saves credentials if "Remember Me" is checked, or deletes them if not.
  Future<void> _handleSessionPersistence() async {
    if (_rememberMe) {
      dev.log('[Auth] "Remember Me" is ON. Storing credentials securely.', name: 'LoginScreen');
      await _secureStorage.write(key: 'email', value: _email);
      await _secureStorage.write(key: 'password', value: _password);
      await _secureStorage.write(key: 'remember_me', value: 'true');
    } else {
      dev.log('[Auth] "Remember Me" is OFF. Deleting all stored credentials.', name: 'LoginScreen');
      await _secureStorage.deleteAll();
    }
  }

  void _switchAuthMode() {
    setState(() {
      _loginFormKey.currentState?.reset();
      _registerFormKey.currentState?.reset();
      _loginEmailController.clear();
      _registerEmailController.clear();
      _registerUsernameController.clear();
      _registerPasswordController.clear();
      _loginEmailError = null;
      _loginPasswordError = null;
      _registerUsernameError = null;
      _registerEmailError = null;
      _registerPasswordError = null;
      _registerConfirmPasswordError = null;
      if (_authMode == AuthMode.login) {
        _authMode = AuthMode.register;
        _mainAnimationController.forward();
      } else {
        _authMode = AuthMode.login;
        _mainAnimationController.reverse();
      }
    });
  }

  /// Checks if a username is available by calling a secure Cloud Function.
  /// Returns `true` if available, `false` if taken or on error.
  /// Handles showing notifications for network/server errors.
  Future<bool> _isUsernameAvailable(String username) async {
    // Get localizations for notifications
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    if (username.isEmpty || !_usernameRegExp.hasMatch(username)) {
      return false;
    }

    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('isUsernameAvailable');

      dev.log('[UsernameCheck] Calling cloud function for username: "$username"', name: 'LoginScreen');
      final result = await callable.call<Map<String, dynamic>>({'username': username});
      final bool isAvailable = result.data['available'] as bool? ?? false;
      dev.log('[UsernameCheck] Server response for "$username": ${isAvailable ? "Available" : "Taken"}', name: 'LoginScreen');

      return isAvailable;

    } on FirebaseFunctionsException catch (e) {
      dev.log('[UsernameCheck] FirebaseFunctionsException: ${e.code} - ${e.message}', name: 'LoginScreen');
      _notificationService.showNotification(
          message: l10n.anErrorOccurred, // "An error occurred"
          isSuccess: false,
          bottomOffset: 0.02
      );
      return false; // Prevent sign-up on server error

    } catch (e) {
      dev.log('[UsernameCheck] Generic error: $e', name: 'LoginScreen');
      _notificationService.showNotification(
          message: l10n.noInternetConnection, // "No internet connection"
          isSuccess: false,
          bottomOffset: 0.02
      );
      return false; // Prevent sign-up on network error
    }
  }


  /// Handles form submission for both Login and Register modes.
  /// This function is the central point for user authentication via email/password.
  /// The registration flow implements a robust, synchronous protocol with the backend
  /// to ensure data integrity and prevent race conditions.
  Future<void> _submit() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final NotificationService notificationService = _notificationService;
    final bool isMounted = mounted;
    FocusScope.of(context).unfocus();

    // Guard: Check for internet connection first.
    final bool hasConnection = await InternetConnection().hasInternetAccess;
    if (!hasConnection) {
      notificationService.showNotification(message: l10n.noInternetConnection, bottomOffset: 0.02, isSuccess: false);
      return;
    }

    // Guard: Validate the form based on the current auth mode.
    final FormState? form = _authMode == AuthMode.login ? _loginFormKey.currentState : _registerFormKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    form.save();

    if (_authMode == AuthMode.register && _password != _confirmPassword) {
      setState(() => _registerConfirmPasswordError = l10n.passwordsDoNotMatch);
      _registerConfirmPasswordShakeController.forward(from: 0);
      _registerFormKey.currentState!.validate();
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_authMode == AuthMode.login) {
        // --- LOGIN FLOW (Correctly preserved from original code) ---
        dev.log('[Auth.Submit.Login] Attempting to sign in user: $_email', name: 'LoginScreen');
        await _auth.signInWithEmailAndPassword(email: _email, password: _password);

        final User? user = _auth.currentUser;
        if (user == null) {
          throw FirebaseAuthException(code: 'user-not-found-after-signin', message: l10n.authError);
        }
        dev.log('[Auth.Submit.Login] Sign-in successful for UID: ${user.uid}. Reloading user state.', name: 'LoginScreen');

        await _handleSessionPersistence(); // Your session persistence logic
        await Future.delayed(const Duration(milliseconds: 200));
        await user.reload();

        final freshUser = _auth.currentUser;
        if (freshUser == null || freshUser.uid != user.uid) {
          throw FirebaseAuthException(code: 'session-persistence-failed', message: 'Failed to persist session.');
        }

        if (!user.emailVerified) {
          dev.log('[Auth.Submit.Login] User email is not verified. Navigating to verification screen.', name: 'LoginScreen');
          if (isMounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => EmailVerificationScreen(
                  email: user.email!,
                  username: '', // Username is unknown on login; profile will handle it.
                  userId: user.uid,
                  password: _password,
                ),
                transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
              ),
            );
          }
          return;
        }

        dev.log('[Auth.Submit.Login] User is verified. Running purchase reconciliation before navigation.', name: 'LoginScreen');
        await reconcileAndSyncPurchases();

        dev.log('[Auth.Submit.Login] User is verified. Navigating to MainScreen.', name: 'LoginScreen');
        if (isMounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen(key: mainScreenKey)));
        }
      } else {
        // --- V16 "FIRE AND FORGET" REGISTRATION FLOW ---
        dev.log('[Auth.Submit.Register] Starting registration for username: $_username', name: 'LoginScreen');

        // Step 1: Pre-flight check for username availability.
        final bool isAvailable = await _isUsernameAvailable(_username);
        if (!isMounted) return;
        if (!isAvailable) {
          setState(() {
            _registerUsernameError = l10n.usernameTaken;
            _registerUsernameShakeController.forward(from: 0);
            _registerFormKey.currentState?.validate();
            _isLoading = false;
          });
          return;
        }

        // Step 2: Create the user in Firebase Authentication.
        dev.log('[Auth.Submit.Register] Creating user in Firebase Auth for email: $_email', name: 'LoginScreen');
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
        final User? user = userCredential.user;

        if (user == null) {
          throw FirebaseAuthException(code: 'user-creation-returned-null', message: 'User creation failed unexpectedly.');
        }
        final String uid = user.uid;
        dev.log('[Auth.Submit.Register] Firebase Auth user created successfully. UID: $uid', name: 'LoginScreen');

        // Step 3: "Fire and Forget" - Attempt to post the suggestion document.
        // We no longer need to handle the failure of this call, as the V16 backend will self-heal.
        // We also add the `expireAt` field for the TTL policy.
        final String? referrerId = await ReferralHandler.getSavedReferrerId();
        final expirationTime = DateTime.now().add(const Duration(hours: 1)); // Set document to expire in 1 hour

        _firestore.collection('usernameSuggestions').doc(uid).set({
          'username': _username,
          'invitedBy': referrerId,
          'expireAt': Timestamp.fromDate(expirationTime), // <-- THE TTL FIELD
        }).then((_) {
          dev.log('[Auth.Submit.Register] Suggestion document posted successfully.', name: 'LoginScreen');
          if (referrerId != null) {
            ReferralHandler.clearSavedReferrerId();
          }
        }).catchError((error) {
          // We only log the error. We DO NOT delete the user or stop the flow.
          dev.log('[Auth.Submit.Register] WARNING: Failed to post username suggestion. The backend will handle this.', name: 'LoginScreen', error: error);
        });

        // Step 4: Immediately send verification and navigate. NO MORE WAITING.
        dev.log('[Auth.Submit.Register] Proceeding immediately to verification screen.', name: 'LoginScreen');
        await user.sendEmailVerification();
        if (isMounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(email: _email, username: _username, userId: uid, password: _password),
          ));
        }
      }
    } on FirebaseAuthException catch (error) {
      dev.log('[Auth.Submit.Error] A Firebase-specific error occurred.', name: 'LoginScreen', error: '${error.code}: ${error.message}');
      if (!mounted) return;

      // Reset all error states
      _loginEmailError = null;
      _loginPasswordError = null;
      _registerEmailError = null;
      _registerPasswordError = null;
      _registerUsernameError = null; // Clear username error too

      setState(() {
        if (_authMode == AuthMode.login) {
          switch (error.code) {
            case 'invalid-credential':
            case 'user-not-found':
            case 'wrong-password':
              _loginEmailError = l10n.invalidCredentials;
              _loginPasswordError = ' ';
              _loginEmailShakeController.forward(from: 0);
              _loginPasswordShakeController.forward(from: 0);
              break;
            case 'invalid-email':
              _loginEmailError = l10n.invalidEmail;
              _loginEmailShakeController.forward(from: 0);
              break;
            case 'user-disabled':
              _loginEmailError = l10n.userDisabled;
              _loginEmailShakeController.forward(from: 0);
              break;
            default:
              _loginEmailError = '${l10n.authError} (${error.code})';
              _loginEmailShakeController.forward(from: 0);
          }
          _loginFormKey.currentState?.validate();
        } else { // AuthMode.register
          switch (error.code) {
            case 'email-already-in-use':
              _registerEmailError = l10n.emailAlreadyInUse;
              _registerEmailShakeController.forward(from: 0);
              break;
            case 'invalid-email':
              _registerEmailError = l10n.invalidEmail;
              _registerEmailShakeController.forward(from: 0);
              break;
            case 'weak-password':
              _registerPasswordError = l10n.weakPassword;
              _registerPasswordShakeController.forward(from: 0);
              break;
            default:
              _registerEmailError = '${l10n.authError} (${error.code})';
              _registerEmailShakeController.forward(from: 0);
          }
          _registerFormKey.currentState?.validate();
        }
      });
    } catch (error, stackTrace) {
      dev.log('[Auth.Submit.Error] A generic, non-Firebase error occurred.', name: 'LoginScreen', error: error, stackTrace: stackTrace);
      if (mounted) {
        notificationService.showNotification(message: l10n.authError, isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handles the entire Google Sign-In flow using the perfected, robust protocol.
  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final NotificationService notificationService = _notificationService;
    final bool isMounted = mounted;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        dev.log('[Auth.Google] Google Sign-In was cancelled by the user.', name: 'LoginScreen');
        if (isMounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("Firebase sign in returned a null user.");
      }
      final String uid = user.uid;
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // Step 1 (Conditional): If the user is new, "Fire and Forget" the suggestion doc.
      if (isNewUser) {
        dev.log('[Auth.Google] New Google user detected. Posting suggestion with TTL.', name: 'LoginScreen');
        final String? referrerId = await ReferralHandler.getSavedReferrerId();
        final expirationTime = DateTime.now().add(const Duration(hours: 1));

        _firestore.collection('usernameSuggestions').doc(uid).set({
          'username': null, // Explicitly send null for Google users.
          'invitedBy': referrerId,
          'expireAt': Timestamp.fromDate(expirationTime), // <-- THE TTL FIELD
        }).then((_) {
          dev.log('[Auth.Google] Suggestion posted for new Google user $uid.', name: 'LoginScreen');
          if (referrerId != null) {
            ReferralHandler.clearSavedReferrerId();
          }
        }).catchError((error) {
          dev.log('[Auth.Google] WARNING: Failed to post suggestion. Backend will self-heal.', name: 'LoginScreen', error: error);
        });
      }

      // Step 2: No more waiting! The backend handles it. Proceed directly.
      dev.log('[Auth.Google] Proceeding with post-login tasks immediately.', name: 'LoginScreen');
      await reconcileAndSyncPurchases();
      await _secureStorage.write(key: 'remember_me', value: 'true');
      await _secureStorage.write(key: 'email', value: user.email);

      if (isMounted) {
        dev.log('[Auth.Google] Sign-In flow complete. Proceeding to MainScreen.', name: 'LoginScreen');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen(key: mainScreenKey)));
      }

    } catch (e, st) {
      dev.log('[Auth.Google] Fatal error during Google Sign-In', name: 'LoginScreen', error: e, stackTrace: st);
      // We no longer need to delete the user on error, because the backend is robust.
      // We just sign them out to be safe.
      await _googleSignIn.signOut();
      await _auth.signOut();
      if (isMounted) {
        notificationService.showNotification(message: l10n.anErrorOccurred, isSuccess: false);
      }

    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- HELPERS ---
  Future<void> _launchResetPasswordURL() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Uri url = Uri.parse('https://vertexishere.com/reset-password');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _notificationService.showNotification(message: l10n.couldNotOpenLink, isSuccess: false);
    }
  }

  Future<void> _showTermsOfServiceandPrivacyPolicy(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    const String termsUrl = "https://vertexishere.com/cortex-terms-of-service";
    const String policyUrl = "https://vertexishere.com/cortex-privacy-policy";
    await showAppWebViewModal(context, l10n.termsOfService, termsUrl);
    if (!mounted) return;
    await showAppWebViewModal(context, l10n.privacyPolicy, policyUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyTheme();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontScale = screenWidth / 375;
    _syncThemeAndSystemUI();
    final themeColors = AppColors.getThemeColors(AppColors.currentTheme);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: themeColors.statusBarColor,
        statusBarIconBrightness: themeColors.statusBarIconBrightness,
        systemNavigationBarColor: themeColors.navigationBarColor,
        systemNavigationBarIconBrightness: themeColors.navigationBarIconBrightness,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24 * fontScale, vertical: 16 * fontScale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAuthForm(l10n, screenHeight, fontScale),
                  SizedBox(height: 16 * screenHeight / 812),
                  _buildOrDivider(l10n, fontScale),
                  SizedBox(height: 16 * screenHeight / 812),
                  _buildSocialButtons(l10n, screenHeight, fontScale),
                  SizedBox(height: 16 * screenHeight / 812),
                  _buildTermsAndConditions(l10n, fontScale),
                  SizedBox(height: 4 * screenHeight / 812),
                  _buildSwitchAuthModeButton(l10n, fontScale),
                ],
              ),
            ),
          ),
          // --- END OF FIX ---
        ),
      ),
    );
  }

  Widget _buildAuthForm(AppLocalizations l10n, double deviceHeight, double fontScale) {
    // A helper widget for the subtitle to keep the build method clean
    Widget buildSubtitle(String text) {
      return Padding(
        padding: EdgeInsets.only(top: deviceHeight * 0.001),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10 * fontScale,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final loginForm = Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ACTION: Added SizedBox to create symmetrical vertical spacing around the title.
          SizedBox(height: deviceHeight * 0.04),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n.loginToYourAccount,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42 * fontScale,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _authMode == AuthMode.login
                ? buildSubtitle(l10n.loginSubtitle)
                : const SizedBox.shrink(),
          ),
          // This SizedBox provides the symmetrical space below the title/subtitle block.
          SizedBox(height: deviceHeight * 0.04),
          ShakeWidget(
            controller: _loginEmailShakeController,
            child: TextFormField(
              cursorColor: AppColors.primaryColor.inverted,
              controller: _loginEmailController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(filled: true, fillColor: AppColors.secondaryColor, labelText: l10n.email, labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color), prefixIcon: Icon(Icons.email, color: Theme.of(context).iconTheme.color), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), counterText: '', errorMaxLines: 3),
              keyboardType: TextInputType.emailAddress,
              maxLength: 42,
              validator: (value) {
                if (_loginEmailError != null) { final temp = _loginEmailError; _loginEmailError = null; return temp; }
                if (value == null || !EmailValidator.validate(value.trim())) { return l10n.invalidEmail; }
                return null;
              },
              onSaved: (value) => _email = value!.trim(),
            ),
          ),
          SizedBox(height: deviceHeight * 0.02),
          ShakeWidget(
            controller: _loginPasswordShakeController,
            child: TextFormField(
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              cursorColor: AppColors.primaryColor.inverted,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryColor,
                labelText: l10n.password,
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),
                suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).iconTheme.color), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                counterText: '',
                errorMaxLines: 3,
              ),
              obscureText: !_isPasswordVisible,
              maxLength: 64,
              validator: (value) {
                if (_loginPasswordError != null) { final temp = _loginPasswordError; _loginPasswordError = null; return temp; }
                if (value == null || value.length < 6) { return l10n.invalidPassword; }
                return null;
              },
              onSaved: (value) => _password = value!.trim(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: deviceHeight * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(value: _rememberMe, onChanged: (value) => setState(() => _rememberMe = value ?? false), checkColor: AppColors.primaryColor, activeColor: AppColors.primaryColor.inverted),
                    Text(l10n.rememberMe, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  ],
                ),
                TextButton(onPressed: _launchResetPasswordURL, child: Text(l10n.forgotPassword, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          SizedBox(height: deviceHeight * 0.03),
          AnimatedOpacity(
            opacity: _isLoading ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor.inverted, padding: EdgeInsets.symmetric(vertical: deviceHeight * 0.02), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: _isLoading ? null : _submit,
                child: Text(l10n.logIn, style: TextStyle(fontSize: 18, color: AppColors.primaryColor)),
              ),
            ),
          ),
        ],
      ),
    );
    final registerForm = Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ACTION: Added SizedBox to create symmetrical vertical spacing around the title.
          SizedBox(height: deviceHeight * 0.04),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n.createYourAccount,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42 * fontScale,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _authMode == AuthMode.register
                ? buildSubtitle(l10n.registerSubtitle)
                : const SizedBox.shrink(),
          ),
          // This SizedBox provides the symmetrical space below the title/subtitle block.
          SizedBox(height: deviceHeight * 0.04),
          ShakeWidget(
            controller: _registerUsernameShakeController,
            child: TextFormField(
              cursorColor: AppColors.primaryColor.inverted,
              controller: _registerUsernameController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(filled: true, fillColor: AppColors.secondaryColor, labelText: l10n.username, labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color), prefixIcon: Icon(Icons.person, color: Theme.of(context).iconTheme.color), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), counterText: '', errorMaxLines: 3),
              maxLength: 20,
              validator: (value) {
                if (_registerUsernameError != null) { final temp = _registerUsernameError; _registerUsernameError = null; return temp; }
                if (value == null || value.length < 3) { return l10n.usernameTooShort; }
                if (value.length > 20) { return l10n.usernameTooLong; }
                if (!_usernameRegExp.hasMatch(value.trim())) { return l10n.invalidUsernameCharacters; }
                return null;
              },
              onSaved: (value) => _username = value!.trim().toLowerCase(),
            ),
          ),
          SizedBox(height: deviceHeight * 0.02),
          ShakeWidget(
            controller: _registerEmailShakeController,
            child: TextFormField(
              cursorColor: AppColors.primaryColor.inverted,
              controller: _registerEmailController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(filled: true, fillColor: AppColors.secondaryColor, labelText: l10n.email, labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color), prefixIcon: Icon(Icons.email, color: Theme.of(context).iconTheme.color), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), counterText: '', errorMaxLines: 3),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (_registerEmailError != null) { final temp = _registerEmailError; _registerEmailError = null; return temp; }
                if (value == null || !EmailValidator.validate(value.trim())) { return l10n.invalidEmail; }
                return null;
              },
              onSaved: (value) => _email = value!.trim(),
            ),
          ),
          SizedBox(height: deviceHeight * 0.02),
          ShakeWidget(
            controller: _registerPasswordShakeController,
            child: TextFormField(
              controller: _registerPasswordController,
              cursorColor: AppColors.primaryColor.inverted,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryColor,
                labelText: l10n.password,
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),
                suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).iconTheme.color), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                counterText: '',
                errorMaxLines: 3,
              ),
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (_registerPasswordError != null) { final temp = _registerPasswordError; _registerPasswordError = null; return temp; }
                if (value == null || value.length < 6) { return l10n.weakPassword; }
                return null;
              },
              onSaved: (value) => _password = value!.trim(),
            ),
          ),
          SizedBox(height: deviceHeight * 0.02),
          ShakeWidget(
            controller: _registerConfirmPasswordShakeController,
            child: TextFormField(
              cursorColor: AppColors.primaryColor.inverted,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryColor,
                labelText: l10n.confirmPassword,
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),
                suffixIcon: IconButton(icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).iconTheme.color), onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                counterText: '',
                errorMaxLines: 3,
              ),
              obscureText: !_isConfirmPasswordVisible,
              validator: (value) {
                if (_registerConfirmPasswordError != null) { final temp = _registerConfirmPasswordError; _registerConfirmPasswordError = null; return temp; }
                if (value?.trim() != _registerPasswordController.text.trim()) {
                  return l10n.passwordsDoNotMatch;
                }
                return null;
              },
              onSaved: (value) => _confirmPassword = value!.trim(),
            ),
          ),
          SizedBox(height: deviceHeight * 0.03),
          AnimatedOpacity(
            opacity: _isLoading ? 0.6 : (_agreeToTerms ? 1.0 : 0.6),
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor.inverted, padding: EdgeInsets.symmetric(vertical: deviceHeight * 0.02), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: (_isLoading || !_agreeToTerms) ? null : _submit,
                child: Text(l10n.signUp, style: TextStyle(fontSize: 18, color: AppColors.primaryColor)),
              ),
            ),
          ),
        ],
      ),
    );
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(opacity: animation, child: child),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _authMode == AuthMode.login
            ? Column(key: const ValueKey('login'), children: [loginForm])
            : Column(key: const ValueKey('register'), children: [registerForm]),
      ),
    );
  }

  Widget _buildOrDivider(AppLocalizations l10n, double fontScale) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1 * fontScale)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * fontScale),
          child: Text(l10n.or, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16 * fontScale)),
        ),
        Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1 * fontScale)),
      ],
    );
  }

  Widget _buildSocialButtons(AppLocalizations l10n, double screenHeight, double fontScale) {
    return AnimatedOpacity(
      opacity: _isLoading ? 0.6 : (_authMode == AuthMode.register && !_agreeToTerms ? 0.6 : 1.0),
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor.inverted,
            padding: EdgeInsets.symmetric(vertical: 16 * screenHeight / 812),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * fontScale)),
          ),
          onPressed: (_isLoading || (_authMode == AuthMode.register && !_agreeToTerms)) ? null : _signInWithGoogle,
          icon: Icon(Icons.g_mobiledata, color: AppColors.primaryColor, size: 24 * fontScale),
          label: Text(l10n.continueWithGoogle, style: TextStyle(color: AppColors.primaryColor, fontSize: 16 * fontScale)),
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions(AppLocalizations l10n, double fontScale) {
    return AnimatedOpacity(
      opacity: _authMode == AuthMode.register ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: _authMode == AuthMode.register
            ? Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0 * fontScale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTermsOfServiceandPrivacyPolicy(context),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.iHaveReadAndAgree,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14 * fontScale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Checkbox(
                value: _agreeToTerms,
                onChanged: (bool? value) => setState(() => _agreeToTerms = value ?? false),
                checkColor: AppColors.primaryColor,
                activeColor: AppColors.primaryColor.inverted,
              ),
            ],
          ),
        )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSwitchAuthModeButton(AppLocalizations l10n, double fontScale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _authMode == AuthMode.login ? l10n.dontHaveAccount : l10n.alreadyHaveAccount,
          style: TextStyle(fontSize: 16 * fontScale, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        TextButton(
          onPressed: _switchAuthMode,
          child: Text(
            _authMode == AuthMode.login ? l10n.signUp : l10n.logIn,
            style: TextStyle(fontSize: 16 * fontScale, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}