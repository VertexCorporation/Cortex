// lib/login/controller.dart

import 'package:cortex/analytics/service.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/webview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cache.dart';
import '../notifications/introvert.dart';
import '../settings/providers/general.dart';
import 'backend.dart';

/// Defines the authentication mode for the UI.
enum AuthMode { login, register }

/// The central orchestrator (ViewModel) for the entire authentication screen.
///
/// This class is the single source of truth for the UI. It holds all the state,
/// business logic, and animation controllers. It is completely decoupled from
/// the UI's `BuildContext`, making it more robust and preventing "ancestor" errors.
///
/// Responsibilities:
///   1. Managing UI state: `authMode`, `isLoading`, `agreeToTerms`, and all error messages.
///   2. Handling user actions by accepting a `BuildContext` as a parameter when needed.
///   3. Interacting with backend services (`LoginBackendService`).
///   4. Controlling all animations for the screen.
class LoginController extends ChangeNotifier {
  // --- Dependencies (Initialized via `initialize`) ---
  late final LoginBackendService _backendService;
  late final IntrovertNotificationService _notificationService;

  // --- UI State ---
  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  // Server-side error messages
  String? _loginEmailError;
  String? _loginPasswordError;
  String? _registerUsernameError;
  String? _registerEmailError;
  String? _registerPasswordError;

  // --- Animation Controllers ---
  late final AnimationController mainAnimationController;
  late final AnimationController loginEmailShakeController;
  late final AnimationController loginPasswordShakeController;
  late final AnimationController registerUsernameShakeController;
  late final AnimationController registerEmailShakeController;
  late final AnimationController registerPasswordShakeController;

  // --- Public Getters for UI ---
  AuthMode get authMode => _authMode;

  bool get isLoading => _isLoading;

  bool get agreeToTerms => _agreeToTerms;

  String? get loginEmailError => _loginEmailError;

  String? get loginPasswordError => _loginPasswordError;

  String? get registerUsernameError => _registerUsernameError;

  String? get registerEmailError => _registerEmailError;

  String? get registerPasswordError => _registerPasswordError;

  // --- Initialization and Disposal ---

  /// Initializes the controller with necessary dependencies and animation providers.
  /// Must be called once from the main screen's `initState`.
  /// The `context` is used only for the initial setup and is not stored.
  void initialize(TickerProvider vsync, BuildContext context) {
    _backendService = LoginBackendService();
    _notificationService =
        Provider.of<IntrovertNotificationService>(context, listen: false);

    const duration300 = Duration(milliseconds: 300);
    const shakeDuration = Duration(milliseconds: 500);

    mainAnimationController =
        AnimationController(vsync: vsync, duration: duration300);
    loginEmailShakeController =
        AnimationController(vsync: vsync, duration: shakeDuration);
    loginPasswordShakeController =
        AnimationController(vsync: vsync, duration: shakeDuration);
    registerUsernameShakeController =
        AnimationController(vsync: vsync, duration: shakeDuration);
    registerEmailShakeController =
        AnimationController(vsync: vsync, duration: shakeDuration);
    registerPasswordShakeController =
        AnimationController(vsync: vsync, duration: shakeDuration);
  }

  @override
  void dispose() {
    mainAnimationController.dispose();
    loginEmailShakeController.dispose();
    loginPasswordShakeController.dispose();
    registerUsernameShakeController.dispose();
    registerEmailShakeController.dispose();
    registerPasswordShakeController.dispose();
    super.dispose();
  }

  // --- Private State Management ---

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _clearServerErrors() {
    _loginEmailError = null;
    _loginPasswordError = null;
    _registerUsernameError = null;
    _registerEmailError = null;
    _registerPasswordError = null;
    // This is a helper and usually called before another notifyListeners().
  }

  // --- Public Methods for UI Interaction ---

  /// Clears any displayed server-side errors. Typically called when the user
  /// starts typing in a field again after a failed submission.
  void clearErrorsOnInput() {
    if (_loginEmailError != null ||
        _registerUsernameError != null ||
        _registerEmailError != null ||
        _registerPasswordError != null) {
      _clearServerErrors();
      notifyListeners();
    }
  }

  void toggleAgreeToTerms() {
    _agreeToTerms = !_agreeToTerms;
    notifyListeners();
  }

  void switchAuthMode() {
    _clearServerErrors();
    if (_authMode == AuthMode.login) {
      _authMode = AuthMode.register;
      mainAnimationController.forward();
    } else {
      _authMode = AuthMode.login;
      mainAnimationController.reverse();
    }
    notifyListeners();
  }

  /// Handles the login submission logic. Requires a fresh `BuildContext` from the UI.
  Future<void> submitLogin(BuildContext context, String email, String password,
      bool rememberMe) async {
    if (_isLoading) return;
    _clearServerErrors();
    _setLoading(true);

    final result = await _backendService.loginWithEmail(
      context: context,
      notificationService: _notificationService,
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    if (!(context.mounted)) return;
    final l10n = AppLocalizations.of(context)!;

    switch (result) {
      case LoginSuccess():
        AnalyticsService().logLoginSuccess('email');
        Navigator.of(context).pop();
        break;
      case LoginInvalidCredentials():
        _loginEmailError = l10n.invalidCredentials;
        _loginPasswordError =
            ' '; // Prevents default validator but shows field as invalid.
        loginEmailShakeController.forward(from: 0);
        loginPasswordShakeController.forward(from: 0);
        AnalyticsService().logLoginFailure('email', 'invalid_credentials');
        _setLoading(false);
        break;
      case LoginUserDisabled():
        _loginEmailError = l10n.userDisabled;
        loginEmailShakeController.forward(from: 0);
        AnalyticsService().logLoginFailure('email', 'user_disabled');
        _setLoading(false);
        break;
      case LoginNetworkError():
        AnalyticsService().logLoginFailure('email', 'network_error');
        _setLoading(false);
        break;
      case LoginUnknownError():
        AnalyticsService().logLoginFailure('email', 'unknown_error');
        _setLoading(false);
        break;
    }
    // _setLoading(false) is intentionally omitted for LoginSuccess
    // to keep the UI locked while navigation happens.
  }

  /// Handles the registration submission logic. Requires a fresh `BuildContext` from the UI.
  Future<void> submitRegister(BuildContext context, String username,
      String email, String password) async {
    if (_isLoading) return;

    _clearServerErrors();
    _setLoading(true);

    final result = await _backendService.registerWithEmail(
      context: context,
      notificationService: _notificationService,
      username: username,
      email: email,
      password: password,
    );

    if (!(context.mounted)) return;
    final l10n = AppLocalizations.of(context)!;

    switch (result) {
      case RegistrationSuccess():
        AnalyticsService().logRegisterSuccess('email');
        Navigator.of(context).pop();
        break;
      case RegistrationUsernameTaken():
        _registerUsernameError = l10n.usernameTaken;
        registerUsernameShakeController.forward(from: 0);
        AnalyticsService().logRegisterFailure('email', 'username_taken');
        _setLoading(false);
        break;
      case RegistrationInvalidUsername():
        _registerUsernameError = l10n.invalidUsernameFormat;
        registerUsernameShakeController.forward(from: 0);
        AnalyticsService().logRegisterFailure('email', 'invalid_username');
        _setLoading(false);
        break;
      case RegistrationEmailInUse():
        _registerEmailError = l10n.emailAlreadyInUse;
        registerEmailShakeController.forward(from: 0);
        AnalyticsService().logRegisterFailure('email', 'email_in_use');
        _setLoading(false);
        break;
      case RegistrationWeakPassword():
        _registerPasswordError = l10n.weakPassword;
        registerPasswordShakeController.forward(from: 0);
        AnalyticsService().logRegisterFailure('email', 'weak_password');
        _setLoading(false);
        break;
      case RegistrationNetworkError():
        AnalyticsService().logRegisterFailure('email', 'network_error');
        _setLoading(false);
        break;
      case RegistrationUnknownError():
        AnalyticsService().logRegisterFailure('email', 'unknown_error');
        _setLoading(false);
        break;
    }
  }

  /// Handles Google Sign-In. Requires a fresh `BuildContext` from the UI.
  Future<void> signInWithGoogle(BuildContext context) async {
    if (_isLoading) return;

    _setLoading(true);
    final result = await _backendService.signInWithGoogle(
      context: context,
      notificationService: _notificationService,
    );

    if (!(context.mounted)) return;

    switch (result) {
      case GoogleSignInSuccess():
        AnalyticsService().logLoginSuccess('google');
        // Do NOT stop loading here. Wait for navigation.
        break;
      case GoogleSignInFailure():
        AnalyticsService().logLoginFailure('google', 'sign_in_failed');
        _setLoading(false);
        break;
      case GoogleSignInCancelled():
        _setLoading(false);
        break;
      case GoogleSignInNetworkError():
        AnalyticsService().logLoginFailure('google', 'network_error');
        _setLoading(false);
        break;
    }
  }

  /// Handles the anonymous login submission.
  /// This should usually be called after the user confirms the warning dialog.
  Future<void> submitAnonymousLogin(BuildContext context) async {
    if (_isLoading) return;

    _clearServerErrors();
    _setLoading(true);

    final result = await _backendService.signInAnonymously(
      context: context,
      notificationService: _notificationService,
    );

    if (!(context.mounted)) return;

    switch (result) {
      case AnonymousSignInSuccess():
        AnalyticsService().logLoginSuccess('anonymous');
        // Do NOT stop loading here. Wait for navigation.
        break;
      case AnonymousSignInNetworkError():
        AnalyticsService().logLoginFailure('anonymous', 'network_error');
        _setLoading(false);
        break;
      case AnonymousSignInFailure():
        AnalyticsService().logLoginFailure('anonymous', 'sign_in_failed');
        _setLoading(false);
        break;
    }
  }

  /// Handles Apple Sign-In. Requires a fresh `BuildContext` from the UI.
  Future<void> signInWithApple(BuildContext context) async {
    if (_isLoading) return;

    _setLoading(true);
    final result = await _backendService.signInWithApple(
      context: context,
      notificationService: _notificationService,
    );

    if (!(context.mounted)) return;

    switch (result) {
      case AppleSignInSuccess():
        AnalyticsService().logLoginSuccess('apple');
        // Do NOT stop loading here. Wait for navigation.
        break;
      case AppleSignInFailure():
        AnalyticsService().logLoginFailure('apple', 'sign_in_failed');
        _setLoading(false);
        break;
      case AppleSignInCancelled():
        _setLoading(false);
        break;
      case AppleSignInNetworkError():
        AnalyticsService().logLoginFailure('apple', 'network_error');
        _setLoading(false);
        break;
    }
  }

  /// Handles the upgrade (linking) submission logic.
  Future<void> submitUpgrade(BuildContext context, String username,
      String email, String password) async {
    if (_isLoading) return;

    _clearServerErrors();
    _setLoading(true);

    final result = await _backendService.linkAnonymousWithEmail(
      context: context,
      notificationService: _notificationService,
      username: username,
      email: email,
      password: password,
    );

    if (!(context.mounted)) return;
    final l10n = AppLocalizations.of(context)!;

    switch (result) {
      case RegistrationSuccess():
        CacheService.invalidate(CacheKey.settingsUserData);

        if (context.mounted) {
          await context.read<SettingsGeneralProvider>().refreshData();
        }

        if (context.mounted) {
          Navigator.of(context).pop();
          _notificationService.showNotification(
              message: l10n.accountLinkedSuccess,
              type: NotificationType.success);
        }
        _setLoading(
            false); // Here we DO unblock because we popped the dialog, we didn't navigate to a new screen.
        break;
      case RegistrationUsernameTaken():
        _registerUsernameError = l10n.usernameTaken;
        registerUsernameShakeController.forward(from: 0);
        _setLoading(false);
        break;
      case RegistrationInvalidUsername():
        _registerUsernameError = l10n.invalidUsernameFormat;
        registerUsernameShakeController.forward(from: 0);
        _setLoading(false);
        break;
      case RegistrationEmailInUse():
        _registerEmailError = l10n.emailAlreadyInUse;
        registerEmailShakeController.forward(from: 0);
        _setLoading(false);
        break;
      case RegistrationWeakPassword():
        _registerPasswordError = l10n.weakPassword;
        registerPasswordShakeController.forward(from: 0);
        _setLoading(false);
        break;
      case RegistrationNetworkError():
      case RegistrationUnknownError():
        _setLoading(false);
        break;
    }
  }

  // --- UI Helper Methods ---

  Future<void> launchResetPasswordURL(BuildContext context) async {
    const String url = 'https://vertexishere.com/reset-password';
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint("[LoginController] Browser is not found. Falling back to WebView.");
        if (context.mounted) {
          await showAppWebViewModal(context, "Reset Password", url);
        }
      }
    } catch (e) {
      debugPrint("[LoginController] Link opening error: $e. Falling back to WebView.");
      if (context.mounted) {
        try {
          await showAppWebViewModal(context, "Reset Password", url);
        } catch (innerE) {
          if (context.mounted) {
            final l10n = AppLocalizations.of(context)!;
            _notificationService.showNotification(
              message: l10n.couldNotOpenLink,
              type: NotificationType.error,
            );
          }
        }
      }
    }
  }

  Future<void> showTermsAndPolicy(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    const String termsUrl = "https://vertexishere.com/cortex-terms-of-service";
    const String policyUrl = "https://vertexishere.com/cortex-privacy-policy";

    await showAppWebViewModal(context, l10n.termsOfService, termsUrl);
    if (!(context.mounted)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!(context.mounted)) return;
      showAppWebViewModal(context, l10n.privacyPolicy, policyUrl);
    });
  }
}
