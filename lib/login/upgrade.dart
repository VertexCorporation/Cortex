// lib/login/upgrade.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'controller.dart';
import 'view/register.dart';

class UpgradeAccountScreen extends StatefulWidget {
  const UpgradeAccountScreen({super.key});

  @override
  State<UpgradeAccountScreen> createState() => _UpgradeAccountScreenState();
}

class _UpgradeAccountScreenState extends State<UpgradeAccountScreen> with TickerProviderStateMixin {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
    _controller.initialize(this, context);

    _controller.switchAuthMode();
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
          Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1)),
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
          Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildSocialButtons(AppLocalizations l10n, double screenHeight, double fontScale) {
    final bool isTermsAccepted = _controller.agreeToTerms;
    final bool isDisabled = _controller.isLoading || !isTermsAccepted;

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
      side: BorderSide(color: AppColors.quinaryColor.withValues(alpha:0.3)),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontScale = screenWidth / 375;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // --- 1. Header (X Button) ---
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: IconButton(
                            icon: Icon(
                                Icons.close,
                                color: AppColors.primaryColor.inverted,
                                size: screenWidth * 0.08
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      // --- 2. Main Content ---
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Column(
                            children: [
                              // A) Form
                              RegisterForm(
                                key: const ValueKey('upgrade_register_form'),
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
                                onInputChanged: _controller.clearErrorsOnInput,
                                onSubmit: (username, email, password) =>
                                    _controller.submitUpgrade(context, username, email, password),
                              ),

                              // B) Divider
                              _buildOrDivider(l10n, fontScale),

                              // C) Social Buttons
                              _buildSocialButtons(l10n, screenHeight, fontScale),

                              // D) Terms Checkbox
                              SizedBox(height: screenHeight * 0.02),
                              Padding(
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
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}