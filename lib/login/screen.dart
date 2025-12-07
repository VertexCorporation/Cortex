// lib/login/screen.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'controller.dart';
import 'view/login.dart'; // "Dumb" Login Form UI
import 'view/register.dart'; // "Dumb" Register Form UI

/// The main orchestrator widget for the authentication flow.
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
    _controller.initialize(this, context);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double fontScale = screenWidth / 375.0;

    if (screenWidth > 600) {
      fontScale = 1.6 + (screenWidth - 600) * 0.0004;
    }

    fontScale = fontScale.clamp(0.85, 2.4);

    final double containerMaxWidth = 400 * fontScale;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: containerMaxWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: 30 * fontScale,
                vertical: 16 * fontScale
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. FORMS (Login / Register CrossFade)
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstCurve: Curves.easeInOut,
                  secondCurve: Curves.easeInOut,
                  sizeCurve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  crossFadeState: _controller.authMode == AuthMode.login
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,

                  firstChild: LoginForm(
                    key: const ValueKey('login_form'),
                    isLoading: _controller.isLoading,
                    emailError: _controller.loginEmailError,
                    passwordError: _controller.loginPasswordError,
                    emailShakeController: _controller.loginEmailShakeController,
                    passwordShakeController: _controller.loginPasswordShakeController,
                    fontScale: fontScale,
                    onSubmit: (email, password, rememberMe) => _controller.submitLogin(context, email, password, rememberMe),
                    onForgotPassword: () => _controller.launchResetPasswordURL(context),
                    onInputChanged: _controller.clearErrorsOnInput,
                  ),

                  secondChild: RegisterForm(
                    key: const ValueKey('register_form'),
                    isLoading: _controller.isLoading,
                    agreeToTerms: _controller.agreeToTerms,
                    usernameError: _controller.registerUsernameError,
                    emailError: _controller.registerEmailError,
                    passwordError: _controller.registerPasswordError,
                    usernameShakeController: _controller.registerUsernameShakeController,
                    emailShakeController: _controller.registerEmailShakeController,
                    passwordShakeController: _controller.registerPasswordShakeController,
                    fontScale: fontScale,
                    onSubmit: (username, email, password) => _controller.submitRegister(context, username, email, password),
                    onInputChanged: _controller.clearErrorsOnInput,
                  ),
                ),

                SizedBox(height: 8 * fontScale),

                // 2. OR DIVIDER
                _buildOrDivider(l10n, fontScale),

                SizedBox(height: 8 * fontScale),

                // 3. SOCIAL BUTTONS
                _buildSocialButtons(l10n, screenHeight, fontScale),

                // 4. TERMS AND CONDITIONS (Register Only - Animated)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _controller.authMode == AuthMode.register
                      ? Column(
                    children: [
                      SizedBox(height: 12 * fontScale),
                      _buildTermsAndConditions(l10n, fontScale, screenHeight),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),

                SizedBox(height: 12 * fontScale),

                // 5. SWITCH ACCOUNT
                _buildSwitchAuthModeButton(l10n, fontScale),

                // 6. GUEST LOGIN (Bottom - Always Visible)
                _buildGuestLoginButton(l10n, fontScale, screenHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Common UI Widgets ---

  Widget _buildGuestLoginButton(AppLocalizations l10n, double fontScale, double screenHeight) {
    // No "isRegisterMode" check. It is now always visible.
    // No "checkbox" requirement. It is frictionless.

    return Column(
      children: [
        SizedBox(height: 16 * fontScale), // Spacing from the "Sign Up" button above

        AnimatedOpacity(
          opacity: _controller.isLoading ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: TextButton(
            onPressed: _controller.isLoading ? null : () => _controller.submitAnonymousLogin(context),
            style: TextButton.styleFrom(
              // Simple text style, no background
              foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.continueAsGuest,
              style: TextStyle(
                fontSize: 15 * fontScale, // Original size
                color: AppColors.primaryColor.inverted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        SizedBox(height: 6 * fontScale),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32 * fontScale),
          child: Text(
            l10n.guestModeWarning,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11 * fontScale,
              color: AppColors.tertiaryColor,
              height: 1.3,
            ),
          ),
        ),

        // Extra bottom padding for safety
        SizedBox(height: 10 * fontScale),
      ],
    );
  }

  Widget _buildOrDivider(AppLocalizations l10n, double fontScale) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1 * fontScale)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * fontScale),
          child: Text(
            l10n.or,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16 * fontScale),
          ),
        ),
        Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1 * fontScale)),
      ],
    );
  }

  Widget _buildSocialButtons(AppLocalizations l10n, double screenHeight, double fontScale) {
    final isRegisterMode = _controller.authMode == AuthMode.register;
    final isDisabled = _controller.isLoading || (isRegisterMode && !_controller.agreeToTerms);

    // Using fontScale for padding ensures icons don't get too big on iPad
    final buttonPadding = EdgeInsets.symmetric(vertical: 14 * fontScale);
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * fontScale));

    final ButtonStyle elegantButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primaryColor.inverted,
      disabledBackgroundColor: AppColors.background,
      disabledForegroundColor: AppColors.primaryColor.inverted,
      padding: buttonPadding,
      shape: buttonShape,
      elevation: 0,
      side: BorderSide(color: AppColors.quinaryColor.withValues(alpha: 0.3)),
    );

    return AnimatedOpacity(
      opacity: isDisabled ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: isDisabled,
        child: Column(
          children: [
            // --- Apple Sign-In Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: elegantButtonStyle,
                onPressed: () => _controller.signInWithApple(context),
                icon: Icon(Icons.apple, size: 24 * fontScale),
                label: Text(
                  l10n.continueWithApple,
                  style: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            SizedBox(height: 12 * fontScale),

            // --- Google Sign-In Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: elegantButtonStyle,
                onPressed: () => _controller.signInWithGoogle(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/google.svg',
                      colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                      width: 16 * fontScale,
                      height: 16 * fontScale,
                    ),

                    SizedBox(width: 12 * fontScale),

                    Text(
                      l10n.continueWithGoogle,
                      style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions(AppLocalizations l10n, double fontScale, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0 * fontScale),
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
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 12.6 * fontScale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20 * fontScale,
            width: 20 * fontScale,
            child: Checkbox(
              value: _controller.agreeToTerms,
              onChanged: (bool? value) => _controller.toggleAgreeToTerms(),
              checkColor: AppColors.primaryColor,
              activeColor: AppColors.primaryColor.inverted,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
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