// lib/login/upgrade.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cortex/appbar.dart';
import 'controller.dart';
import 'view/login.dart';
import 'view/register.dart';

/// Combined Login/Register screen for anonymous users upgrading their account.
/// Defaults to Register mode with a toggle to switch to Login.
class UpgradeAccountScreen extends StatefulWidget {
  final bool showLoginFirst;

  const UpgradeAccountScreen({super.key, this.showLoginFirst = false});

  @override
  State<UpgradeAccountScreen> createState() => _UpgradeAccountScreenState();
}

class _UpgradeAccountScreenState extends State<UpgradeAccountScreen>
    with TickerProviderStateMixin {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
    _controller.initialize(this, context);

    // Default to Register mode for upgrade flow unless overridden
    if (!widget.showLoginFirst) {
      _controller.switchAuthMode();
    }
    _controller.toggleAgreeToTerms();

    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showTermsAndPolicy(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    const String termsUrl = "https://vertexishere.com/cortex-terms-of-service";
    const String policyUrl = "https://vertexishere.com/cortex-privacy-policy";

    await showAppWebViewModal(context, l10n.termsOfService, termsUrl);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showAppWebViewModal(context, l10n.privacyPolicy, policyUrl);
      }
    });
  }

  // --- UI HELPERS ---

  Widget _buildOrDivider(AppLocalizations l10n, double fontScale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * fontScale),
      child: Row(
        children: [
          Expanded(
              child:
                  Divider(color: Theme.of(context).dividerColor, thickness: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12 * fontScale),
            child: Text(
              l10n.or,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
              child:
                  Divider(color: Theme.of(context).dividerColor, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildSocialButtons(
      AppLocalizations l10n, double screenHeight, double fontScale) {
    final isRegisterMode = _controller.authMode == AuthMode.register;
    final bool isDisabled =
        _controller.isLoading || (isRegisterMode && !_controller.agreeToTerms);

    final buttonPadding = EdgeInsets.symmetric(vertical: 14 * fontScale);
    final buttonShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10 * fontScale));

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
      opacity: isDisabled ? 0.5 : 1.0,
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
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _controller.signInWithApple(context);
                },
                icon: Icon(Icons.apple, size: 24 * fontScale),
                label: Text(
                  l10n.continueWithApple,
                  style: TextStyle(
                      fontSize: 16 * fontScale, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            SizedBox(height: 12 * fontScale),

            // --- Google Sign-In Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: elegantButtonStyle,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _controller.signInWithGoogle(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/google.svg',
                      colorFilter: ColorFilter.mode(
                          AppColors.primaryColor.inverted, BlendMode.srcIn),
                      width: 16 * fontScale,
                      height: 16 * fontScale,
                    ),
                    SizedBox(width: 12 * fontScale),
                    Text(
                      l10n.continueWithGoogle,
                      style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.w600),
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

  Widget _buildTermsAndConditions(AppLocalizations l10n, double fontScale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0 * fontScale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showTermsAndPolicy(context),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.iHaveReadAndAgree,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 13.0 * fontScale,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * fontScale),
          SizedBox(
            height: 24 * fontScale,
            width: 24 * fontScale,
            child: Checkbox(
              value: _controller.agreeToTerms,
              onChanged: (bool? value) => _controller.toggleAgreeToTerms(),
              checkColor: AppColors.primaryColor,
              activeColor: AppColors.primaryColor.inverted,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
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
          _controller.authMode == AuthMode.login
              ? l10n.dontHaveAccount
              : l10n.alreadyHaveAccount,
          style: TextStyle(
              fontSize: 16 * fontScale,
              color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _controller.switchAuthMode();
          },
          child: Text(
            _controller.authMode == AuthMode.login ? l10n.signUp : l10n.logIn,
            style: TextStyle(
                fontSize: 16 * fontScale,
                color: Colors.blue,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // --- SCALING LOGIC ---
    double fontScale = screenWidth / 375.0;
    if (screenWidth > 450) {
      fontScale = 1.2 + (screenWidth - 450) * 0.0005;
    }
    fontScale = fontScale.clamp(0.85, 1.35);
    final double containerMaxWidth = 400 * fontScale;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Builder(builder: (context) {
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        return AnimatedPadding(
          padding: EdgeInsets.only(bottom: bottomInset),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: containerMaxWidth),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 30 * fontScale),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40 * fontScale),

                          // A) Forms — CrossFade between Login and Register
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            firstCurve: Curves.easeInOut,
                            secondCurve: Curves.easeInOut,
                            sizeCurve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            crossFadeState:
                                _controller.authMode == AuthMode.login
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                            firstChild: LoginForm(
                              key: const ValueKey('upgrade_login_form'),
                              isLoading: _controller.isLoading,
                              emailError: _controller.loginEmailError,
                              passwordError: _controller.loginPasswordError,
                              emailShakeController:
                                  _controller.loginEmailShakeController,
                              passwordShakeController:
                                  _controller.loginPasswordShakeController,
                              fontScale: fontScale,
                              onSubmit: (email, password, rememberMe) =>
                                  _controller.submitLogin(
                                      context, email, password, rememberMe),
                              onForgotPassword: () =>
                                  _controller.launchResetPasswordURL(context),
                              onInputChanged: _controller.clearErrorsOnInput,
                            ),
                            secondChild: RegisterForm(
                              key: const ValueKey('upgrade_register_form'),
                              isLoading: _controller.isLoading,
                              agreeToTerms: _controller.agreeToTerms,
                              usernameError: _controller.registerUsernameError,
                              emailError: _controller.registerEmailError,
                              passwordError: _controller.registerPasswordError,
                              usernameShakeController:
                                  _controller.registerUsernameShakeController,
                              emailShakeController:
                                  _controller.registerEmailShakeController,
                              passwordShakeController:
                                  _controller.registerPasswordShakeController,
                              fontScale: fontScale,
                              onInputChanged: _controller.clearErrorsOnInput,
                              onSubmit: (username, email, password) =>
                                  _controller.submitUpgrade(
                                      context, username, email, password),
                            ),
                          ),

                          // B) Divider
                          _buildOrDivider(l10n, fontScale),

                          // C) Social Buttons
                          _buildSocialButtons(l10n, screenHeight, fontScale),

                          // D) Terms Checkbox — Register mode only
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: _controller.authMode == AuthMode.register
                                ? Column(
                                    children: [
                                      SizedBox(height: 16 * fontScale),
                                      _buildTermsAndConditions(l10n, fontScale),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),

                          SizedBox(height: 12 * fontScale),

                          // E) Switch between Login / Register
                          _buildSwitchAuthModeButton(l10n, fontScale),

                          SizedBox(height: 20 * fontScale),
                        ],
                      ),
                    ),
                  ),
                ),

                // Close button
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10 * fontScale),
                    child: AppBarButton(
                      size: 40.0,
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close_rounded,
                          color: AppColors.primaryColor.inverted, size: 20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
