import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/login/controller.dart';
import 'package:cortex/login/upgrade.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:cortex/scaled_bottom_sheet.dart';

void showGuestLimitSheet(BuildContext context, AppLocalizations localizations) {
  FocusScope.of(context).unfocus();

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: false,
    constraints: BoxConstraints(
      maxWidth: MediaQuery
          .of(context)
          .size
          .width,
    ),
    builder: (BuildContext modalContext) {
      return ScaledBottomSheet(
        child: _GuestLimitSheetContent(localizations: localizations),
      );
    },
  );
}

class _GuestLimitSheetContent extends StatefulWidget {
  final AppLocalizations localizations;

  const _GuestLimitSheetContent({required this.localizations});

  @override
  State<_GuestLimitSheetContent> createState() =>
      _GuestLimitSheetContentState();
}

class _GuestLimitSheetContentState extends State<_GuestLimitSheetContent>
    with TickerProviderStateMixin {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
    _controller.initialize(this, context);

    // Automatically agree to terms since guests have already seen onboarding
    if (!_controller.agreeToTerms) {
      _controller.toggleAgreeToTerms();
    }

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final sw = MediaQuery.sizeOf(context).width;

    // Scaling logic similar to AuthScreen
    double fontScale = sw / 375.0;
    if (sw > 450) {
      fontScale = 1.2 + (sw - 450) * 0.0005;
    }
    fontScale = fontScale.clamp(0.85, 1.35);

    final double topRadius = sw * 0.07;
    final double titleSize = sw > 600 ? sw * 0.035 : sw * 0.055;
    final double descriptionSize = sw > 600 ? sw * 0.02 : sw * 0.035;

    final buttonPadding = EdgeInsets.symmetric(vertical: 14 * fontScale);
    final buttonShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10 * fontScale));

    final ButtonStyle elegantButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primaryColor.inverted,
      disabledBackgroundColor: AppColors.background,
      disabledForegroundColor: AppColors.primaryColor.inverted,
      shadowColor: Colors.transparent,
      padding: buttonPadding,
      shape: buttonShape,
      elevation: 0,
      side: BorderSide(color: AppColors.border),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => AppColors.primaryColor.inverted.withValues(alpha: 0.1),
      ),
    );

    final bool isDisabled = _controller.isLoading;

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: sw * 0.06),
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: sw * 0.12,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.quaternaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Center(
                  child: Text(
                    widget.localizations.guestLimitBottomSheetTitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor.inverted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Description
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  widget.localizations.guestLimitBottomSheetText,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: descriptionSize,
                    color: AppColors.tertiaryColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Buttons
              AnimatedOpacity(
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
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _controller.signInWithApple(context);
                          },
                          icon: Icon(Icons.apple, size: 24 * fontScale),
                          label: Text(
                            widget.localizations.continueWithApple,
                            style: TextStyle(
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.w600),
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
                                    AppColors.primaryColor.inverted,
                                    BlendMode.srcIn),
                                width: 16 * fontScale,
                                height: 16 * fontScale,
                              ),
                              SizedBox(width: 12 * fontScale),
                              Text(
                                widget.localizations.continueWithGoogle,
                                style: TextStyle(
                                    fontSize: 16 * fontScale,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 12 * fontScale),

                      // --- Standard Login Button ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: elegantButtonStyle,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context); // Close bottom sheet
                            navigateToScreen(
                              const UpgradeAccountScreen(showLoginFirst: true),
                              direction: const Offset(0.0, 1.0),
                            );
                          },
                          child: Text(
                            widget.localizations.loginToYourAccount,
                            style: TextStyle(
                              fontSize: 16 * fontScale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32 * fontScale),
            ],
          ),
        ),
      ),
    );
  }
}
