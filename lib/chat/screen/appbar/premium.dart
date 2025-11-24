// chat/screen/premium.dart

import 'dart:math';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../login/upgrade.dart';
import '../../../navigation.dart';
import '../../../server/user.dart';
import '../../../theme.dart';

/// A banner that appears below the AppBar to notify the user that a premium model is selected.
/// It features an animated RGB border, navigates to the premium screen on tap,
/// and can be dismissed by swiping it up.
class PremiumModelBanner extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onTap;

  const PremiumModelBanner({
    super.key,
    required this.isVisible,
    required this.onTap,
  });

  @override
  State<PremiumModelBanner> createState() => PremiumModelBannerState();
}

class PremiumModelBannerState extends State<PremiumModelBanner>
    with TickerProviderStateMixin {
  late final AnimationController _rgbController;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  bool _isDismissedByUser = false;

  @override
  void initState() {
    super.initState();
    _rgbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    if (widget.isVisible) {
      _slideController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant PremiumModelBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible && !oldWidget.isVisible) {
      setState(() {
        _isDismissedByUser = false;
      });
      _slideController.forward(from: 0.0);
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _slideController.reverse();
    }
  }

  @override
  void dispose() {
    _rgbController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _slideController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isDismissedByUser = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double borderRadius = screenWidth * 0.03;
    final double borderThickness = screenWidth * 0.005;
    final double internalPaddingVertical = screenWidth * 0.03;
    final double internalPaddingHorizontal = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.07;
    final double gapBetweenIconAndText = screenWidth * 0.03;
    final double gapBetweenTitleAndDesc = screenWidth * 0.01;
    final double titleFontSize = screenWidth * 0.038;
    final double descriptionFontSize = screenWidth * 0.033;
    final double maxBannerHeight = screenHeight * 0.2;
    final bool shouldBeVisible = widget.isVisible && !_isDismissedByUser;

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        if (!shouldBeVisible && !_slideController.isAnimating) {
          return const SizedBox.shrink();
        }
        return child!;
      },
      // The ClipRect widget is added here to contain the slide animation.
      // This ensures the banner appears to slide out from under the AppBar,
      // not from the top of the screen.
      child: ClipRect(
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0),
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < 0) {
                    _handleDismiss();
                  }
                },
                child: AnimatedBuilder(
                  animation: _rgbController,
                  builder: (context, child) {
                    return Container(
                      padding: EdgeInsets.all(borderThickness),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: SweepGradient(
                          center: Alignment.center,
                          colors: const [
                            Colors.red, Colors.yellow, Colors.green, Colors.cyan,
                            Colors.blue, Colors.purple, Colors.red,
                          ],
                          transform:
                          GradientRotation(_rgbController.value * 2 * pi),
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: Material(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(borderRadius * 0.8),
                    child: InkWell(
                        onTap: () {
                          final isAnonymous = context
                              .read<UserProvider>()
                              .isAnonymous;

                          if (isAnonymous) {
                            navigateToScreen(const UpgradeAccountScreen(), direction: const Offset(0.0, 1.0));
                            FocusScope.of(context).unfocus();
                          } else {
                            widget.onTap();
                          }
                        },
                      borderRadius: BorderRadius.circular(borderRadius * 0.8),
                      splashColor: AppColors.primaryColor.withValues(alpha: 0.1),
                      highlightColor: AppColors.primaryColor.withValues(alpha: 0.05),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxBannerHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: internalPaddingVertical,
                            horizontal: internalPaddingHorizontal,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: SvgPicture.asset(
                                  'assets/icons/sparkle.svg',
                                  colorFilter: ColorFilter.mode(
                                      AppColors.primaryColor.inverted,
                                      BlendMode.srcIn),
                                  width: iconSize,
                                  height: iconSize,
                                ),
                              ),
                              SizedBox(width: gapBetweenIconAndText),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        localizations.premiumModelNoticeTitle,
                                        style: TextStyle(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor.inverted,
                                        ),
                                      ),
                                      SizedBox(height: gapBetweenTitleAndDesc),
                                      Text(
                                        localizations
                                            .premiumModelNoticeDescription,
                                        style: TextStyle(
                                          fontSize: descriptionFontSize,
                                          color: AppColors.primaryColor.inverted
                                              .withValues(alpha: 0.8),
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}