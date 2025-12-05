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
class PremiumModelBanner extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const PremiumModelBanner({
    super.key,
    required this.isVisible,
    required this.onTap,
    this.onDismiss,
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
        widget.onDismiss?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // RESPONSIVE LOGIC
    final bool isTablet = screenWidth >= 600;

    // --- TABLET OPTIMIZATIONS (Balanced) ---

    // 1. Width / Margin:
    // Tablet: 5% margin on sides (covers 90% of width). Phone: Fixed 12px.
    final double horizontalMargin = isTablet ? screenWidth * 0.05 : 12.0;

    // 2. Font Sizes (Middle Ground):
    // Tablet: Title 22, Desc 17. Phone: Scaled.
    final double titleFontSize = isTablet ? 22.0 : screenWidth * 0.038;
    final double descriptionFontSize = isTablet ? 17.0 : screenWidth * 0.033;

    // 3. Icon Size:
    // Tablet: 32 (Visible but not giant). Phone: Scaled.
    final double iconSize = isTablet ? 32.0 : screenWidth * 0.07;

    // 4. Spacing & Padding:
    final double borderRadius = isTablet ? 16.0 : screenWidth * 0.03;
    final double borderThickness = isTablet ? 4.0 : screenWidth * 0.005;

    final double internalPaddingVertical = isTablet ? 16.0 : screenWidth * 0.03;
    final double internalPaddingHorizontal = isTablet ? 20.0 : screenWidth * 0.04;

    final double gapBetweenIconAndText = isTablet ? 20.0 : screenWidth * 0.03;
    final double gapBetweenTitleAndDesc = isTablet ? 6.0 : screenWidth * 0.01;

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
      child: ClipRect(
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            bottom: false,
            child: Padding(
              // Apply the new balanced margin here
              padding: EdgeInsets.fromLTRB(horizontalMargin, 8.0, horizontalMargin, 0),
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