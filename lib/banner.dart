// lib/banner.dart
//
// This file defines reusable banner components for the application.
// It includes a service for managing the "invite" banner's cooldown logic
// and a generic, self-animating FloatingInfoBanner widget that can display
// various types of content and position itself relative to other widgets.

import 'dart:io';

import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'invite.dart';

class BannerService {
  final ValueNotifier<bool> showInviteBannerNotifier = ValueNotifier<bool>(false);
  final InviteService _inviteService = InviteService();

  bool _isSharingLink = false;

  static const String _bannerTimestampKey = 'inviteBannerLastShownTimestamp';
  static const int _showIntervalInHours = 24;

  Future<void> checkAndTriggerBanner() async {
    if (Platform.isIOS) {
      debugPrint("[BannerService] iOS detected → auto-banner disabled.");
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? lastShownTimestamp = prefs.getInt(_bannerTimestampKey);

      if (lastShownTimestamp == null) {
        debugPrint("[BannerService] No dismissal timestamp found. Displaying banner.");
        _displayBanner();
        return;
      }

      final DateTime lastDismissalTime = DateTime.fromMillisecondsSinceEpoch(lastShownTimestamp);
      final Duration difference = DateTime.now().difference(lastDismissalTime);

      if (difference.inHours >= _showIntervalInHours) {
        debugPrint("[BannerService] More than 24 hours have passed. Showing again.");
        _displayBanner();
      } else {
        debugPrint("[BannerService] Banner dismissed within the last 24 hours. Skipping.");
      }
    } catch (e) {
      debugPrint("[BannerService] SharedPreferences error: $e");
    }
  }

  void _displayBanner() {
    if (!showInviteBannerNotifier.value) {
      showInviteBannerNotifier.value = true;
      debugPrint("[BannerService] Banner visibility set to true.");
    }
  }

  Future<void> startCooldown() async {
    if (showInviteBannerNotifier.value) {
      showInviteBannerNotifier.value = false;
    }
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_bannerTimestampKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint("[BannerService] Dismissal confirmed. 24-hour cooldown started.");
    } catch (e) {
      debugPrint("[BannerService] Failed to set cooldown timestamp: $e");
    }
  }

  void triggerBannerManually() {
    if (Platform.isIOS) {
      debugPrint("[BannerService] iOS → Manual banner trigger blocked.");
      return;
    }
    debugPrint("[BannerService] A manual request was made to show the invite banner.");
    _displayBanner();
  }

  Future<void> generateAndShareInviteLink(BuildContext context) async {
    if (_isSharingLink) return;
    _isSharingLink = true;

    try {
      await _inviteService.createAndShareReferralLink(context);
    } catch (e) {
      debugPrint('[BannerService] Error for invite system: $e');
    } finally {
      _isSharingLink = false;
    }
  }

  void dispose() {
    showInviteBannerNotifier.dispose();
  }
}

/// An enum to define the different types of content the banner can display.
enum BannerType {
  discount,
  inviteCredits,
  extensionInfo,
}

/// A highly reusable, self-animating, and dynamically positioned banner.
///
/// This widget is designed to be a direct child of a `Stack`. It manages its own
/// animations and can be anchored relative to another widget using `anchorKey`.
class FloatingInfoBanner extends StatefulWidget {
  final BannerType bannerType;
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;
  /// An optional GlobalKey to anchor the banner's position to.
  /// If provided, the banner will appear relative to this widget.
  final GlobalKey? anchorKey;

  const FloatingInfoBanner({
    super.key,
    this.bannerType = BannerType.inviteCredits,
    this.onDismissed,
    this.onTap,
    this.anchorKey,
  });

  @override
  State<FloatingInfoBanner> createState() => FloatingInfoBannerState();
}

class FloatingInfoBannerState extends State<FloatingInfoBanner> {
  bool _isVisible = false;
  Offset _anchorOffset = Offset.zero;
  Size _anchorSize = Size.zero;

  @override
  void initState() {
    super.initState();
    debugPrint("[FloatingInfoBanner] initState: Banner type '${widget.bannerType}' is being added.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // The position is now calculated in build(), so we just trigger the animation here.
        debugPrint("[FloatingInfoBanner] Triggering entry animation.");
        setState(() => _isVisible = true);
      }
    });
  }

  /// Calculates the position and size of the anchor widget if a key is provided.
  void _updateAnchorPosition() {
    if (widget.anchorKey?.currentContext != null) {
      final RenderBox? renderBox = widget.anchorKey!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _anchorSize = renderBox.size;
        _anchorOffset = renderBox.localToGlobal(Offset.zero);
      }
    }
  }

  void dismiss() {
    if (!mounted || !_isVisible) return;
    debugPrint("[FloatingInfoBanner] Triggering exit animation.");
    setState(() => _isVisible = false);
    // Give time for the animation to complete before calling the callback.
    Future.delayed(const Duration(milliseconds: 300), () {
      debugPrint("[FloatingInfoBanner] Exit animation complete. Calling onDismissed.");
      widget.onDismissed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    // By calling this in every build, we ensure the anchor position is never stale,
    // even if the keyboard appears or other layout changes happen.
    _updateAnchorPosition();

    final localizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double topSafeArea = MediaQuery.of(context).padding.top;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    // --- Banner Type Specific Configurations ---
    bool isTopBanner;
    double verticalMargin;
    Widget content;
    bool useSpecialAnimation = false; // Flag for the new animation

    switch (widget.bannerType) {
      case BannerType.extensionInfo:
        isTopBanner = true; // Anchored to the app bar title
        verticalMargin = screenHeight * 0.02;
        content = _buildExtensionInfoContent(context, localizations);
        useSpecialAnimation = true; // Enable the new animation for this type
        break;
      case BannerType.discount:
        isTopBanner = true;
        verticalMargin = screenHeight * 0.06;
        content = _buildDefaultContent(context, localizations);
        break;
      case BannerType.inviteCredits:
      isTopBanner = false;
        verticalMargin = screenHeight * 0.02;
        content = _buildDefaultContent(context, localizations);
        break;
    }

    // --- Positioning Logic ---
    double? onScreenTop, onScreenBottom, onScreenLeft, onScreenRight;
    double offscreenTop = -(screenHeight * 0.3); // Default offscreen positions
    double offscreenBottom = -(screenHeight * 0.3);

    if (widget.anchorKey != null && _anchorOffset != Offset.zero) {
      // Anchored positioning (used for extensionInfo)
      final double panelWidth = screenWidth * 0.8;
      onScreenLeft = _anchorOffset.dx + _anchorSize.width / 2 - (panelWidth / 2);
      // Clamp to screen edges
      onScreenLeft = max(screenWidth * 0.04, min(onScreenLeft, screenWidth - panelWidth - (screenWidth * 0.04)));
      onScreenTop = _anchorOffset.dy + _anchorSize.height + verticalMargin;
    } else {
      // Standard top/bottom positioning
      final double horizontalMargin = screenWidth * 0.02;
      onScreenLeft = horizontalMargin;
      onScreenRight = horizontalMargin;
      if (isTopBanner) {
        onScreenTop = topSafeArea + verticalMargin;
      } else {
        onScreenBottom = bottomSafeArea + verticalMargin;
      }
    }

    if (useSpecialAnimation) {
      // For extensionInfo: Use a static Positioned and animate scale/opacity internally.
      return Positioned(
        top: onScreenTop,
        left: onScreenLeft,
        right: onScreenRight,
        child: GestureDetector(
          // Allow taps on the banner itself to dismiss it
          onTap: dismiss,
          child: AnimatedScale(
            scale: _isVisible ? 1.0 : 0.85,
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: content,
            ),
          ),
        ),
      );
    } else {
      // For all other banners: Use the original AnimatedPositioned for the sliding effect.
      return AnimatedPositioned(
        duration: Duration(milliseconds: _isVisible ? 800 : 400),
        curve: _isVisible ? Curves.elasticOut : Curves.easeOutCubic,
        top: isTopBanner ? (_isVisible ? onScreenTop : offscreenTop) : null,
        bottom: !isTopBanner ? (_isVisible ? onScreenBottom : offscreenBottom) : null,
        left: onScreenLeft,
        right: onScreenRight,
        child: GestureDetector(
          onTap: () {
            widget.onTap?.call();
            dismiss();
          },
          onVerticalDragUpdate: (details) {
            if (isTopBanner && details.primaryDelta! < -2) {
              dismiss();
            } else if (!isTopBanner && details.primaryDelta! > 2) {dismiss();}
          },
          child: content,
        ),
      );
    }
  }

  /// Builds the new, custom content for the Extension Info banner.
  Widget _buildExtensionInfoContent(BuildContext context, AppLocalizations localizations) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Sizing values migrated from ChatTitleState
    final double panelWidth = screenWidth * 0.8;
    final double borderRadiusValue = screenWidth * 0.04;
    final double borderWidth = screenWidth * 0.002;
    final double shadowBlurRadius = screenWidth * 0.05;
    final double shadowOffsetY = screenHeight * 0.01;
    final double titleFontSize = screenWidth * 0.042;
    final double bodyFontSize = screenWidth * 0.035;
    final double footerFontSize = screenWidth * 0.033;
    final double horizontalPadding = screenWidth * 0.045;
    final double verticalPadding = screenWidth * 0.035;
    final double smallSpacing = screenHeight * 0.012;
    final double mediumSpacing = screenHeight * 0.015;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: panelWidth,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(borderRadiusValue),
          border: Border.all(color: AppColors.border, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: shadowBlurRadius,
              offset: Offset(0, shadowOffsetY),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.extensionInfoPanelTitle,
                style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: smallSpacing),
            Text(localizations.extensionInfoPanelBody1,
                style: TextStyle(
                    color: AppColors.primaryColor.inverted.withValues(alpha: 0.9),
                    fontSize: bodyFontSize,
                    height: 1.5)),
            SizedBox(height: smallSpacing),
            Text(localizations.extensionInfoPanelBody2,
                style: TextStyle(
                    color: AppColors.primaryColor.inverted.withValues(alpha: 0.9),
                    fontSize: bodyFontSize,
                    height: 1.5)),
            SizedBox(height: mediumSpacing),
            Text(localizations.extensionInfoPanelFooter,
                style: TextStyle(
                    color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                    fontSize: footerFontSize,
                    fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  /// Builds the default banner content with an icon, title, and subtitle.
  Widget _buildDefaultContent(BuildContext context, AppLocalizations localizations) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

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
      case BannerType.extensionInfo:
      // This case is handled by the custom builder, but we provide a fallback.
        title = "Info";
        subtitle = "Additional information is available.";
        iconPath = 'assets/icons/info.svg';
        break;
    }

    return Material(
      color: Colors.transparent,
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
              color: AppColors.senaryColor.withValues(alpha: 0.5),
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
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: subtitleFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}