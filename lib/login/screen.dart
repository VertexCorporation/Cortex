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

    final fontScale = screenWidth / 375;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32 * fontScale, vertical: 16 * fontScale),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstCurve: Curves.easeInOut,
                  secondCurve: Curves.easeInOut,
                  sizeCurve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  crossFadeState: _controller.authMode == AuthMode.login
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,

                  // CHILD 1: LOGIN FORM
                  firstChild: LoginForm(
                    key: const ValueKey('login_form'),
                    isLoading: _controller.isLoading,
                    emailError: _controller.loginEmailError,
                    passwordError: _controller.loginPasswordError,
                    emailShakeController: _controller.loginEmailShakeController,
                    passwordShakeController: _controller.loginPasswordShakeController,
                    deviceHeight: screenHeight,
                    fontScale: fontScale,
                    onSubmit: (email, password, rememberMe) => _controller.submitLogin(context, email, password, rememberMe),
                    onForgotPassword: () => _controller.launchResetPasswordURL(context),
                    onInputChanged: _controller.clearErrorsOnInput,
                  ),

                  // CHILD 2: REGISTER FORM
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
                    deviceHeight: screenHeight,
                    fontScale: fontScale,
                    onSubmit: (username, email, password) => _controller.submitRegister(context, username, email, password),
                    onInputChanged: _controller.clearErrorsOnInput,
                  ),
                ),

                SizedBox(height: 12 * screenHeight / 812),

                _buildOrDivider(l10n, fontScale),

                SizedBox(height: 12 * screenHeight / 812),

                _buildSocialButtons(l10n, screenHeight, fontScale),

                SizedBox(height: 12 * screenHeight / 812),

                _buildTermsAndConditions(l10n, fontScale, screenHeight),

                _buildGuestLoginButton(l10n, fontScale, screenHeight),

                _buildSwitchAuthModeButton(l10n, fontScale),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Common UI Widgets ---

  Widget _buildGuestLoginButton(AppLocalizations l10n, double fontScale, double screenHeight) {
    final isRegisterMode = _controller.authMode == AuthMode.register;
    final isEnabled = isRegisterMode && _controller.agreeToTerms && !_controller.isLoading;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: isRegisterMode
          ? Column(
        children: [
          SizedBox(height: 12 * screenHeight / 812),
          AnimatedOpacity(
            opacity: isEnabled ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !isEnabled,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _controller.submitAnonymousLogin(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.continueAsGuest,
                      style: TextStyle(
                        fontSize: 15 * fontScale,
                        color: AppColors.primaryColor.inverted,
                        fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
          ),
        ],
      )
          : const SizedBox.shrink(),
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

    final buttonPadding = EdgeInsets.symmetric(vertical: 14 * screenHeight / 812);
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

            SizedBox(height: 12 * screenHeight / 812),

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
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: _controller.authMode == AuthMode.register
          ? Column(
        children: [
          SizedBox(height: 12 * screenHeight / 812),
          Padding(
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
          ),
        ],
      )
          : const SizedBox.shrink(),
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