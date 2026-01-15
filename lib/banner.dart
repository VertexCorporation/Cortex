// lib/banner.dart

import 'dart:io';
import 'dart:math';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'invite.dart';

class BannerService {
  final ValueNotifier<bool> showInviteBannerNotifier = ValueNotifier<bool>(
      false);
  final InviteService _inviteService = InviteService();

  bool _isSharingLink = false;

  // Key to track the NEXT allowed appearance time
  static const String _nextShowTimestampKey = 'inviteBannerNextShowTimestamp';

  Future<void> checkAndTriggerBanner() async {
    // 1. SECURITY: iOS detected → Auto-banner logic completely disabled.
    if (Platform.isIOS) {
      debugPrint("[BannerService] iOS detected → Auto-banner logic disabled.");
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? nextShowTimestamp = prefs.getInt(_nextShowTimestampKey);
      final int now = DateTime
          .now()
          .millisecondsSinceEpoch;

      // Logic: If no timestamp exists (first run) OR current time >= next allowed time
      if (nextShowTimestamp == null || now >= nextShowTimestamp) {
        debugPrint("[BannerService] Time condition met. Displaying banner.");
        _displayBanner();
      } else {
        final double remainingHours = (nextShowTimestamp - now) / 1000 / 3600;
        debugPrint(
            "[BannerService] Still in cooldown. Remaining hours: ${remainingHours
                .toStringAsFixed(1)}");
      }
    } catch (e) {
      debugPrint("[BannerService] SharedPreferences error: $e");
    }
  }

  void _displayBanner() {
    if (Platform.isIOS) return;

    if (!showInviteBannerNotifier.value) {
      showInviteBannerNotifier.value = true;
      debugPrint("[BannerService] Banner visibility set to true.");
    }
  }

  /// Called when the banner is swiped away.
  /// Sets a random cooldown of 24, 48, 72, or 96 hours.
  Future<void> startCooldown() async {
    // Hide from UI immediately
    if (showInviteBannerNotifier.value) {
      showInviteBannerNotifier.value = false;
    }

    if (Platform.isIOS) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // CHANCE FACTOR: Pick one random interval
      final List<int> intervals = [24, 48, 72, 96];
      final int randomHours = intervals[Random().nextInt(intervals.length)];

      // Calculate the next allowed show time
      final DateTime nextShowTime = DateTime.now().add(
          Duration(hours: randomHours));

      await prefs.setInt(
          _nextShowTimestampKey, nextShowTime.millisecondsSinceEpoch);

      debugPrint(
          "[BannerService] Banner dismissed. Random cooldown set: $randomHours hours.");
      debugPrint(
          "[BannerService] Next appearance allowed after: $nextShowTime");
    } catch (e) {
      debugPrint("[BannerService] Failed to set cooldown timestamp: $e");
    }
  }

  void triggerBannerManually() {
    if (Platform.isIOS) {
      debugPrint("[BannerService] iOS → Manual banner trigger blocked.");
      return;
    }
    debugPrint("[BannerService] Manual trigger requested.");
    _displayBanner();
  }

  Future<void> generateAndShareInviteLink(BuildContext context) async {
    if (Platform.isIOS) return;

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

enum BannerType {
  discount,
  inviteCredits,
}

class FloatingInfoBanner extends StatefulWidget {
  final BannerType bannerType;
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;
  final GlobalKey? anchorKey;
  final bool isEmbedded;
  final double? referenceWidth;

  const FloatingInfoBanner({
    super.key,
    this.bannerType = BannerType.inviteCredits,
    this.onDismissed,
    this.onTap,
    this.anchorKey,
    this.isEmbedded = false,
    this.referenceWidth,
  });

  @override
  State<FloatingInfoBanner> createState() => FloatingInfoBannerState();
}

class FloatingInfoBannerState extends State<FloatingInfoBanner>
    with TickerProviderStateMixin {
  // Visibility for AnimatedSize (Shrink effect)
  bool _isVisible = false;

  // Animation Controller for Sliding (Slide Out effect)
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  Offset _anchorOffset = Offset.zero;
  Size _anchorSize = Size.zero;

  @override
  void initState() {
    super.initState();

    // iOS Check on Init
    if (Platform.isIOS && widget.bannerType == BannerType.inviteCredits) {
      debugPrint("[FloatingInfoBanner] iOS detected on Init. Skipped.");
      return;
    }

    // Setup Slide Animation (Slides Downwards)
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Moves from position 0 (start) to 1.5 (downwards off view)
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5),
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeInBack));

    debugPrint("[FloatingInfoBanner] initState: Type '${widget
        .bannerType}', Embedded: ${widget.isEmbedded}");

    // Trigger Entry Animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _updateAnchorPosition() {
    if (widget.anchorKey?.currentContext != null) {
      final RenderBox? renderBox = widget.anchorKey!.currentContext!
          .findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _anchorSize = renderBox.size;
        _anchorOffset = renderBox.localToGlobal(Offset.zero);
      }
    }
  }

  /// Handles the dismiss logic: Slide Down -> Shrink -> Callback
  void dismiss() {
    if (!mounted) return;
    debugPrint("[FloatingInfoBanner] Swipe down detected. Dismissing...");

    // 1. Play Slide Out Animation
    _slideController.forward().then((_) {
      // 2. Shrink the space
      if (mounted) {
        setState(() => _isVisible = false);

        // 3. Trigger the actual logic (Cooldown) after animation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onDismissed?.call();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. SECURITY: UI Layer protection for iOS
    if (Platform.isIOS && widget.bannerType == BannerType.inviteCredits) {
      return const SizedBox.shrink();
    }

    final localizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery
        .of(context)
        .size;
    final double refWidth = widget.referenceWidth ?? screenSize.width;

    // --- Embedded Mode (Inside Scroll View) ---
    if (widget.isEmbedded) {
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        child: _isVisible
            ? SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: EdgeInsets.only(bottom: refWidth * 0.04), // Dynamic Margin
            child: GestureDetector(
              // TAP: Performs action but DOES NOT dismiss
              onTap: widget.onTap,

              // SWIPE: Vertical Drag Update
              onVerticalDragUpdate: (details) {
                // Detect swipe down (positive delta)
                if (details.primaryDelta! > 3) {
                  dismiss();
                }
              },
              child: _buildDefaultContent(context, localizations, refWidth),
            ),
          ),
        )
            : const SizedBox(width: double.infinity, height: 0),
      );
    }

    // --- Overlay Mode ---
    _updateAnchorPosition();

    final double screenHeight = screenSize.height;
    final double topSafeArea = MediaQuery
        .of(context)
        .padding
        .top;
    final double bottomSafeArea = MediaQuery
        .of(context)
        .padding
        .bottom;

    bool isTopBanner;
    double verticalMargin;
    Widget content;

    switch (widget.bannerType) {
      case BannerType.discount:
        isTopBanner = true;
        verticalMargin = screenHeight * 0.06;
        content = _buildDefaultContent(context, localizations, refWidth);
        break;
      case BannerType.inviteCredits:
        isTopBanner = false;
        verticalMargin = screenHeight * 0.02;
        content = _buildDefaultContent(context, localizations, refWidth);
        break;
    }

    double? onScreenTop, onScreenBottom, onScreenLeft, onScreenRight;
    double offscreenTop = -(screenHeight * 0.3);
    double offscreenBottom = -(screenHeight * 0.3);

    if (widget.anchorKey != null && _anchorOffset != Offset.zero) {
      final double panelWidth = refWidth * 0.8;
      onScreenLeft =
          _anchorOffset.dx + _anchorSize.width / 2 - (panelWidth / 2);
      onScreenLeft = max(refWidth * 0.04,
          min(onScreenLeft, refWidth - panelWidth - (refWidth * 0.04)));
      onScreenTop = _anchorOffset.dy + _anchorSize.height + verticalMargin;
    } else {
      final double horizontalMargin = refWidth * 0.02;
      onScreenLeft = horizontalMargin;
      onScreenRight = horizontalMargin;
      if (isTopBanner) {
        onScreenTop = topSafeArea + verticalMargin;
      } else {
        onScreenBottom = bottomSafeArea + verticalMargin;
      }
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: _isVisible ? 800 : 400),
      curve: _isVisible ? Curves.elasticOut : Curves.easeOutCubic,
      top: isTopBanner ? (_isVisible ? onScreenTop : offscreenTop) : null,
      bottom: !isTopBanner
          ? (_isVisible ? onScreenBottom : offscreenBottom)
          : null,
      left: onScreenLeft,
      right: onScreenRight,
      child: GestureDetector(
        onTap: widget.onTap,
        onVerticalDragUpdate: (details) {
          if (isTopBanner && details.primaryDelta! < -2) {
            // Swipe Up to dismiss top banner
            dismiss();
          } else if (!isTopBanner && details.primaryDelta! > 2) {
            // Swipe Down to dismiss bottom banner
            dismiss();
          }
        },
        child: content,
      ),
    );
  }

  /// Builds the default banner content with an icon, title, and subtitle.
  /// Updated to use AppColors.premium with subtle opacity and fully dynamic sizing.
  Widget _buildDefaultContent(BuildContext context,
      AppLocalizations localizations, double refWidth) {
    // --- Dynamic Dimensions ---
    final double internalHorizontalPadding = refWidth * 0.04;
    final double internalVerticalPadding = refWidth * 0.035;
    final double iconSpacing = refWidth * 0.03;
    final double iconSize = refWidth * 0.08;
    final double baseFontSize = refWidth * 0.04;
    final double titleFontSize = baseFontSize;
    final double subtitleFontSize = baseFontSize * 0.80;
    final double borderRadius = refWidth * 0.04;
    final double gapBetweenText = refWidth *
        0.01; // Dynamic gap (replaces fixed 4.0)
    final double borderWidth = refWidth * 0.003;

    final String title;
    final String subtitle;
    final String iconPath;

    switch (widget.bannerType) {
      case BannerType.inviteCredits:
        title = localizations.plusBannerTitle;
        subtitle = localizations.plusBannerSubtitle;
        iconPath = 'assets/icons/credit.svg';
        break;
      case BannerType.discount:
        title = localizations.discountBannerTitle;
        subtitle = localizations.discountBannerSubtitle;
        iconPath = 'assets/icons/warning.svg';
        break;
    }

    // --- Premium Styling Colors ---
    // Background: Premium color with very low opacity (tint)
    final Color backgroundColor = AppColors.premium.withValues(alpha: 0.15);
    // Border: Solid Premium color
    final Color borderColor = AppColors.premium;
    // Text/Icon: Solid Premium color for readability
    final Color contentColor = AppColors.premium;
    final Color subtitleColor = AppColors.premium.withValues(alpha: 0.8);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.isEmbedded ? refWidth * 0.9 : null,
        padding: EdgeInsets.symmetric(
          horizontal: internalHorizontalPadding,
          vertical: internalVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          // Clean look (No Shadow), or extremely subtle if needed
          boxShadow: [
            BoxShadow(
              color: AppColors.premium.withValues(alpha: 0.05),
              blurRadius: refWidth * 0.02,
              offset: Offset(0, refWidth * 0.01),
            )
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
                width: iconSize,
                height: iconSize,
              ),
              SizedBox(width: iconSpacing),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: gapBetweenText), // Dynamic spacing
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: subtitleFontSize,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}