import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cortex/l10n/app_localizations.dart';

/// An enum to define the different types of content the banner can display.
enum BannerType {
  discount,
  inviteCredits
}

/// A highly reusable, self-animating, and dynamically sized banner that appears from the top OR bottom.
///
/// This widget is designed to be a direct child of a `Stack`. It manages its own
/// "slide-in" and "slide-out" animations using `AnimatedPositioned`.
///
/// It now supports conditional animations and layout based on the final user request:
/// - `discount` slides in from the TOP with a LARGER vertical margin.
/// - `inviteCredits` slides in from the BOTTOM with a SMALLER vertical margin.
///
/// The exit animation is fast and responsive, and all sizing values are preserved.
class FloatingInfoBanner extends StatefulWidget {
  final BannerType bannerType;
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;

  const FloatingInfoBanner({
    super.key,
    this.bannerType = BannerType.inviteCredits,
    this.onDismissed,
    this.onTap,
  });

  @override
  State<FloatingInfoBanner> createState() => _FloatingInfoBannerState();
}

class _FloatingInfoBannerState extends State<FloatingInfoBanner> {
  /// Controls the banner's visibility and triggers its animations.
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    debugPrint("[FloatingInfoBanner] initState: Banner is being added to the tree.");
    // Animate the banner into view shortly after it's been built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint("[FloatingInfoBanner] Triggering entry animation.");
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  /// Triggers the exit animation and calls the onDismissed callback when complete.
  void _dismiss() {
    // Prevent multiple dismiss calls.
    if (!mounted || !_isVisible) return;

    debugPrint("[FloatingInfoBanner] Triggering exit animation.");
    setState(() {
      _isVisible = false;
    });

    // The exit duration is shorter to feel fast and responsive ("flick").
    // This duration must match the exit duration in the AnimatedPositioned widget.
    Future.delayed(const Duration(milliseconds: 400), () {
      debugPrint("[FloatingInfoBanner] Exit animation complete. Calling onDismissed callback.");
      widget.onDismissed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double topSafeArea = MediaQuery.of(context).padding.top;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    // Logic to determine if the banner should animate from the top.
    // `discount` is from the top, `inviteCredits` is from the bottom.
    final bool isTopBanner = widget.bannerType == BannerType.discount;

    // ====================== FINAL REQUEST: CONDITIONAL VERTICAL MARGIN ======================
    // Based on the user's final request, we set different vertical margins
    // for the top and bottom banners to achieve the desired visual spacing.
    final double verticalMargin = isTopBanner
        ? screenHeight * 0.06  // More margin for the top banner (discount)
        : screenHeight * 0.02; // Less margin for the bottom banner (inviteCredits)
    // ======================================================================================

    debugPrint("[FloatingInfoBanner] Building banner. Type: ${widget.bannerType}. Is top banner: $isTopBanner. Vertical Margin: $verticalMargin");

    // All other sizing values are preserved.
    final double horizontalMargin = screenWidth * 0.02;

    // Position calculations for a TOP banner
    final double visibleTopPosition = topSafeArea + verticalMargin;
    final double hiddenTopPosition = -(screenHeight * 0.3); // Hide well above the screen

    // Position calculations for a BOTTOM banner
    final double visibleBottomPosition = bottomSafeArea + verticalMargin;
    final double hiddenBottomPosition = -(screenHeight * 0.3); // Hide well below the screen

    final double internalHorizontalPadding = screenWidth * 0.04;
    final double internalVerticalPadding = screenHeight * 0.015;
    final double iconSpacing = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.1;
    final double baseFontSize = screenWidth * 0.04;
    final double titleFontSize = baseFontSize;
    final double subtitleFontSize = baseFontSize * 0.85;
    final double borderRadius = screenWidth * 0.04;
    final double shadowBlurRadius = screenWidth * 0.03;
    final double shadowOffsetY = screenHeight * 0.006;

    // --- Dynamic Content Selection ---
    final String title;
    final String subtitle;
    final String iconPath;

    switch (widget.bannerType) {
      case BannerType.inviteCredits:
        title = localizations.creditBannerTitle;
        subtitle = localizations.creditBannerSubtitle;
        iconPath = 'assets/icons/credit.svg';
        break;
      case BannerType.discount:
        title = localizations.discountBannerTitle;
        subtitle = localizations.discountBannerSubtitle;
        iconPath = 'assets/icons/warning.svg';
        break;
    }

    return AnimatedPositioned(
      // Use different durations and curves for entry vs. exit for a better feel.
      duration: Duration(milliseconds: _isVisible ? 800 : 400),
      curve: _isVisible ? Curves.elasticOut : Curves.easeOutCubic,

      // Set 'top' or 'bottom' based on the banner type. The unused property is set to null.
      top: isTopBanner ? (_isVisible ? visibleTopPosition : hiddenTopPosition) : null,
      bottom: !isTopBanner ? (_isVisible ? visibleBottomPosition : hiddenBottomPosition) : null,
      left: horizontalMargin,
      right: horizontalMargin,

      child: GestureDetector(
        onTap: () {
          widget.onTap?.call();
          _dismiss();
        }, // Any tap will now correctly dismiss the banner.
        onVerticalDragUpdate: (details) {
          // Intuitive swipe-to-dismiss based on banner position
          if (isTopBanner && details.primaryDelta! < -2) {
            _dismiss(); // Swipe up to dismiss a top banner
          } else if (!isTopBanner && details.primaryDelta! > 2) {
            _dismiss(); // Swipe down to dismiss a bottom banner
          }
        },
        child: Material(
          color: Colors.transparent, // Important for shadow and border radius to show correctly
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: internalHorizontalPadding,
              vertical: internalVerticalPadding,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.senaryColor, AppColors.septenaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.senaryColor.withOpacity(0.5),
                  blurRadius: shadowBlurRadius,
                  offset: Offset(0, shadowOffsetY),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconPath,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  width: iconSize,
                  height: iconSize,
                ),
                SizedBox(width: iconSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.0025),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: subtitleFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}