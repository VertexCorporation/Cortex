// lib/login/screen.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';

import 'controller.dart';
import 'view/login.dart'; // "Dumb" Login Form UI
import 'view/register.dart'; // "Dumb" Register Form UI

/// The main orchestrator widget for the authentication flow.
///
/// This widget is the "director" of the authentication screen. Its responsibilities are:
///   1. To create and manage the lifecycle of the `LoginController`.
///   2. To build the main screen skeleton (`Scaffold`, `SingleChildScrollView`, etc.).
///   3. To listen for state changes from the `LoginController` and rebuild the UI.
///   4. To use `AnimatedSwitcher` to display either the `LoginForm` or `RegisterForm`.
///   5. To build the common UI elements shared between both forms.
///   6. To provide a fresh `BuildContext` to the controller's methods when they are called.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
    // Initialize the controller. The context is only used here to find providers.
    _controller.initialize(this, context);
    // Listen to the controller to rebuild the UI whenever its state changes.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate responsive values here, in the orchestrator.
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontScale = screenWidth / 375;

    return Scaffold(
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
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: _controller.authMode == AuthMode.login
                        ? LoginForm(
                      key: const ValueKey('login_form'),
                      // Pass state from the controller.
                      isLoading: _controller.isLoading,
                      emailError: _controller.loginEmailError,
                      passwordError: _controller.loginPasswordError,
                      // Pass animation controllers.
                      emailShakeController: _controller.loginEmailShakeController,
                      passwordShakeController: _controller.loginPasswordShakeController,
                      // Pass responsive values.
                      deviceHeight: screenHeight,
                      fontScale: fontScale,
                      // Pass callbacks, wrapping them to include the current `context`.
                      onSubmit: (email, password, rememberMe) => _controller.submitLogin(context, email, password, rememberMe),
                      onForgotPassword: () => _controller.launchResetPasswordURL(context),
                      onInputChanged: _controller.clearErrorsOnInput,
                    )
                        : RegisterForm(
                      key: const ValueKey('register_form'),
                      // Pass state from the controller.
                      isLoading: _controller.isLoading,
                      agreeToTerms: _controller.agreeToTerms,
                      usernameError: _controller.registerUsernameError,
                      emailError: _controller.registerEmailError,
                      passwordError: _controller.registerPasswordError,
                      // Pass animation controllers.
                      usernameShakeController: _controller.registerUsernameShakeController,
                      emailShakeController: _controller.registerEmailShakeController,
                      passwordShakeController: _controller.registerPasswordShakeController,
                      confirmPasswordShakeController: _controller.registerConfirmPasswordShakeController,
                      // Pass responsive values.
                      deviceHeight: screenHeight,
                      fontScale: fontScale,
                      // Pass callbacks, wrapping them to include the current `context`.
                      onSubmit: (username, email, password) => _controller.submitRegister(context, username, email, password),
                      onInputChanged: _controller.clearErrorsOnInput,
                    ),
                  ),
                ),
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
      ),
    );
  }

  // --- Common UI Widgets ---

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
    final isRegisterMode = _controller.authMode == AuthMode.register;
    final isDisabled = _controller.isLoading || (isRegisterMode && !_controller.agreeToTerms);

    return AnimatedOpacity(
      opacity: isDisabled ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor.inverted,
            padding: EdgeInsets.symmetric(vertical: 16 * screenHeight / 812),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * fontScale)),
          ),
          onPressed: isDisabled ? null : () => _controller.signInWithGoogle(context),
          icon: Icon(Icons.g_mobiledata, color: AppColors.primaryColor, size: 24 * fontScale),
          label: Text(l10n.continueWithGoogle, style: TextStyle(color: AppColors.primaryColor, fontSize: 16 * fontScale)),
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions(AppLocalizations l10n, double fontScale) {
    return AnimatedOpacity(
      opacity: _controller.authMode == AuthMode.register ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: _controller.authMode == AuthMode.register
            ? Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0 * fontScale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _controller.showTermsAndPolicy(context),
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
                value: _controller.agreeToTerms,
                onChanged: (bool? value) => _controller.toggleAgreeToTerms(),
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
          _controller.authMode == AuthMode.login ? l10n.dontHaveAccount : l10n.alreadyHaveAccount,
          style: TextStyle(fontSize: 16 * fontScale, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        TextButton(
          onPressed: _controller.switchAuthMode,
          child: Text(
            _controller.authMode == AuthMode.login ? l10n.signUp : l10n.logIn,
            style: TextStyle(fontSize: 16 * fontScale, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}