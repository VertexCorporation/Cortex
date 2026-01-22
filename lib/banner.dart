// lib/banner.dart

import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/fog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'invite.dart';

class BannerService {
  final ValueNotifier<bool> showInviteBannerNotifier =
      ValueNotifier<bool>(false);
  final InviteService _inviteService = InviteService();

  bool _isSharingLink = false;

  // Key to track the NEXT allowed appearance time
  static const String _nextShowTimestampKey = 'inviteBannerNextShowTimestamp';

  Future<void> checkAndTriggerBanner() async {
    // 1. SECURITY: iOS detected → Auto-banner logic completely disabled.
    if (Platform.isIOS) return;

    // 2. DEBUG MODE: Bypass timer logic completely
    if (kDebugMode) {
      debugPrint("[BannerService] Debug Mode detected. Bypassing cooldown.");
      _displayBanner();
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? nextShowTimestamp = prefs.getInt(_nextShowTimestampKey);
      final int now = DateTime.now().millisecondsSinceEpoch;

      // Logic: If no timestamp exists (first run) OR current time >= next allowed time
      if (nextShowTimestamp == null || now >= nextShowTimestamp) {
        debugPrint(
            "[BannerService] Time condition met. Attempting to display Axon banner.");
        _displayBanner();
      } else {
        final double remainingHours = (nextShowTimestamp - now) / 1000 / 3600;
        debugPrint(
            "[BannerService] Cooldown active. Remaining: ${remainingHours.toStringAsFixed(1)} hours.");
      }
    } catch (e) {
      debugPrint("[BannerService] SharedPreferences error: $e");
    }
  }

  void _displayBanner() {
    if (Platform.isIOS) return;

    // Additional Random Chance: 50% chance even if cooldown met (User Experience)
    // Unless Debug Mode
    if (!kDebugMode) {
      if (Random().nextBool()) {
        debugPrint("[BannerService] Skipped by random chance (50%).");
        // FIX: Don't set a full cooldown. Just return.
        // The next session/check will try again.
        // OR optionally set a tiny cooldown (e.g. 1 hour) to avoid spamming logs if checked frequently.
        _scheduleNextAppearance(shortDelay: true);
        return;
      }
    }

    if (!showInviteBannerNotifier.value) {
      showInviteBannerNotifier.value = true;
      // FIX: Set the next cooldown immediately when we DECIDE to show it.
      // This ensures we don't show it again for 1-3 days even if the user crashes/restarts
      // without dismissing it manually.
      _scheduleNextAppearance();
    }
  }

  /// Called when the banner is swiped away.
  /// Sets a random cooldown between 1 day (24h) and 3 days (72h).
  Future<void> startCooldown() async {
    // Hide from UI immediately
    if (showInviteBannerNotifier.value) {
      showInviteBannerNotifier.value = false;
    }

    if (Platform.isIOS) return;

    // Re-schedule just in case, ensuring the "dismissed" action pushes it out.
    await _scheduleNextAppearance();
  }

  /// Calculates and saves the next allowed show time.
  /// [shortDelay] : If true, sets a small delay (e.g. 4 hours) instead of full 1-3 days.
  ///                Used when skipping by random chance.
  Future<void> _scheduleNextAppearance({bool shortDelay = false}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int randomHours;

      if (shortDelay) {
        // Retry in 4 hours
        randomHours = 4;
      } else {
        // 1 Day = 24 Hours
        // 3 Days = 72 Hours
        // Range = 72 - 24 = 48 Hours variance
        randomHours = 24 + Random().nextInt(48 + 1);
      }

      // Calculate the next allowed show time
      final DateTime nextShowTime =
          DateTime.now().add(Duration(hours: randomHours));

      await prefs.setInt(
          _nextShowTimestampKey, nextShowTime.millisecondsSinceEpoch);

      debugPrint(
          "[BannerService] Scheduled next appearance in $randomHours hours.");
    } catch (e) {
      debugPrint("[BannerService] Failed to set cooldown timestamp: $e");
    }
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

class FloatingInfoBanner extends StatefulWidget {
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;
  final GlobalKey? anchorKey;
  final bool isEmbedded;
  final double? referenceWidth;

  const FloatingInfoBanner({
    super.key,
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
  // Controls the collapsing height (AnimatedSize)
  bool _isVisible = false;
  late ScrollController _subtitleScrollController;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation; // Shared for Entry
  late Animation<double> _fadeAnimation; // Shared for Entry

  // Exit Specifics
  late AnimationController _exitController;
  late Animation<Offset> _exitSlideAnimation;
  late Animation<double> _exitFadeAnimation;
  Offset _exitOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) return;

    // --- 1. Entry Animation Setup ---
    _subtitleScrollController = ScrollController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Smooth entry duration
    );

    // CHANGED: Slide from slightly below (0.3), not far below.
    // CHANGED: Curve is EaseOutCubic (Smooth), not Elastic (Bouncy).
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Fade matches the slide
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // --- 2. Exit Animation Setup ---
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
    );

    _exitSlideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(_exitController);

    // Trigger Entry Animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _subtitleScrollController.dispose();
    _controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  /// Handles the complex dismiss logic:
  /// Calculate Direction -> Animate Out -> Shrink Space -> Callback
  void dismiss(Offset swipeDelta) async {
    if (!mounted ||
        _exitController.isAnimating ||
        _exitController.isCompleted) {
      return;
    }

    // Determine exit direction based on swipe
    double dx = 0;
    double dy = 0;

    if (swipeDelta.dx.abs() > swipeDelta.dy.abs()) {
      dx = swipeDelta.dx > 0 ? 0.5 : -0.5; // Horizontal
    } else {
      dy = swipeDelta.dy > 0 ? 0.5 : -0.5; // Vertical
    }

    setState(() {
      _exitOffset = Offset(dx, dy);
      _exitSlideAnimation = Tween<Offset>(begin: Offset.zero, end: _exitOffset)
          .animate(CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeOutQuad,
      ));
    });

    // 1. Play Exit Animation (Fade out + Slide slightly)
    await _exitController.forward();

    if (!mounted) return;

    // 2. Collapse the layout (AnimatedSize shrinks)
    setState(() => _isVisible = false);

    // 3. Wait for collapse to finish, then callback
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      widget.onDismissed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) return const SizedBox.shrink();

    final localizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    final double refWidth = widget.referenceWidth ?? screenSize.width;

    // --- Embedded Mode (Inside Axon List) ---
    if (widget.isEmbedded) {
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        child: _isVisible
            ? SlideTransition(
                // 1. Entry Animation Layer (Slight Slide Up)
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation, // Entry Fade
                  child: SlideTransition(
                    // 2. Exit Animation Layer (Directional Slide Out)
                    position: _exitSlideAnimation,
                    child: FadeTransition(
                      opacity: _exitFadeAnimation, // Exit Fade
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: refWidth * 0.04, top: refWidth * 0.02),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onTap?.call();
                          },
                          // Listen to ALL swipes (Pan)
                          onPanUpdate: (details) {
                            if (details.delta.distance > 1.5) {
                              dismiss(details.delta);
                            }
                          },
                          child: _buildBannerContent(
                              context, localizations, refWidth),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(width: double.infinity, height: 0),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBannerContent(
      BuildContext context, AppLocalizations localizations, double refWidth) {
    final double internalHorizontalPadding = refWidth * 0.04;
    final double internalVerticalPadding = refWidth * 0.035;
    final double iconSpacing = refWidth * 0.03;
    final double iconSize = refWidth * 0.08;
    final double titleFontSize = refWidth * 0.04;
    final double subtitleFontSize = titleFontSize * 0.80;
    final double borderRadius = refWidth * 0.04;
    final double gapBetweenText = refWidth * 0.01;

    final String title = localizations.plusBannerTitle;
    final String subtitle = localizations.plusBannerSubtitle;
    final String iconPath = 'assets/icons/sparkle.svg';

    // --- COLOR MAGIC: Solid "Faux-Transparent" ---
    final Color tintColor = AppColors.premium.withValues(alpha: 0.15);
    final Color solidBackgroundColor =
        Color.alphaBlend(tintColor, AppColors.background);
    final Color borderColor = AppColors.premium;
    final Color contentColor = AppColors.premium;
    final Color subtitleColor = AppColors.premium.withValues(alpha: 0.8);

    return Material(
      color: Colors.transparent,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: widget.isEmbedded ? refWidth * 0.9 : null,
        padding: EdgeInsets.symmetric(
          horizontal: internalHorizontalPadding,
          vertical: internalVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: solidBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: refWidth * 0.003,
          ),
        ),
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
            Expanded(
              child: Column(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: gapBetweenText),
                  Container(
                    // FIX: Enforce a fixed height for 2 lines of text to prevent
                    // layout jumps at different widths.
                    // Height = fontSize * lineHeight (1.2) * 2 lines
                    height: subtitleFontSize * 1.2 * 2,
                    alignment: Alignment.centerLeft,
                    child: ScrollFog(
                      // Since FloatingInfoBanner is Stateful, I can add a controller there.
                      // But `_buildBannerContent` is just a method.
                      // I'll add `_subtitleScrollController` to the State class.
                      scrollController: _subtitleScrollController,
                      topFogHeight: 4,
                      bottomFogHeight: 12,
                      child: SingleChildScrollView(
                        controller: _subtitleScrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: subtitleFontSize,
                            height: 1.2,
                          ),
                        ),
                      ),
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
