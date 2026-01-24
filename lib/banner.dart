// lib/banner.dart

import 'dart:io';
import 'dart:math';
import 'package:cortex/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'invite.dart';

class BannerService {
  final ValueNotifier<bool> showInviteBannerNotifier =
  ValueNotifier<bool>(false);

  final ValueNotifier<double> bannerHeightNotifier = ValueNotifier<double>(0.0);

  final InviteService _inviteService = InviteService();
  bool _isSharingLink = false;
  static const String _nextShowTimestampKey = 'inviteBannerNextShowTimestamp';

  /// Session-level flag: Once the banner is dismissed, it won't reappear
  /// during the current app session, regardless of the timestamp check.
  bool _hasDismissedThisSession = false;

  Future<void> checkAndTriggerBanner() async {
    if (Platform.isIOS) return;

    // If the banner was already dismissed this session, don't show it again.
    if (_hasDismissedThisSession) {
      debugPrint(
          "[BannerService] Banner already dismissed this session. Skipping.");
      return;
    }

    if (kDebugMode) {
      debugPrint(
          "[BannerService] Debug Mode detected. Showing banner immediately.");
      if (!showInviteBannerNotifier.value) {
        showInviteBannerNotifier.value = true;
      }
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? nextShowTimestamp = prefs.getInt(_nextShowTimestampKey);
      final int now = DateTime
          .now()
          .millisecondsSinceEpoch;

      if (nextShowTimestamp == null || now >= nextShowTimestamp) {
        if (!showInviteBannerNotifier.value) {
          showInviteBannerNotifier.value = true;
        }
      }
    } catch (e) {
      debugPrint("[BannerService] SharedPreferences error: $e");
    }
  }

  Future<void> startCooldown() async {
    // Mark as dismissed for this session to prevent re-triggering.
    _hasDismissedThisSession = true;

    if (showInviteBannerNotifier.value) {
      showInviteBannerNotifier.value = false;
      bannerHeightNotifier.value = 0.0;
    }

    if (Platform.isIOS) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int randomHours = 24 + Random().nextInt(48 + 1);
      final DateTime nextShowTime =
      DateTime.now().add(Duration(hours: randomHours));
      await prefs.setInt(
          _nextShowTimestampKey, nextShowTime.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint("[BannerService] Failed to set cooldown timestamp: $e");
    }
  }

  Future<void> generateAndShareInviteLink(BuildContext context) async {
    if (Platform.isIOS) return;
    if (_isSharingLink) return;
    _isSharingLink = true;

    try {
      HapticFeedback.lightImpact();
      await _inviteService.createAndShareReferralLink(context);
    } catch (e) {
      debugPrint('[BannerService] Error for invite system: $e');
    } finally {
      _isSharingLink = false;
    }
  }

  void dispose() {
    showInviteBannerNotifier.dispose();
    bannerHeightNotifier.dispose();
  }
}

class FloatingInfoBanner extends StatefulWidget {
  final VoidCallback? onDismissed;
  final VoidCallback? onTap;
  final bool isEmbedded;
  final double? referenceWidth;

  const FloatingInfoBanner({
    super.key,
    this.onDismissed,
    this.onTap,
    this.isEmbedded = false,
    this.referenceWidth,
  });

  @override
  State<FloatingInfoBanner> createState() => FloatingInfoBannerState();
}

class FloatingInfoBannerState extends State<FloatingInfoBanner>
    with TickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _exitController;
  late Animation<Offset> _exitSlideAnimation;
  late Animation<double> _exitFadeAnimation;
  Offset _exitOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) return;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
    );

    _exitSlideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(_exitController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  void dismiss(Offset swipeDelta) async {
    if (!mounted ||
        _exitController.isAnimating ||
        _exitController.isCompleted) {
      return;
    }

    double dx = 0;
    double dy = 0;
    if (swipeDelta.dx.abs() > swipeDelta.dy.abs()) {
      dx = swipeDelta.dx > 0 ? 0.5 : -0.5;
    } else {
      dy = swipeDelta.dy > 0 ? 0.5 : -0.5;
    }

    setState(() {
      _exitOffset = Offset(dx, dy);
      _exitSlideAnimation = Tween<Offset>(begin: Offset.zero, end: _exitOffset)
          .animate(CurvedAnimation(
          parent: _exitController, curve: Curves.easeOutQuad));
    });

    await _exitController.forward();

    if (!mounted) return;
    setState(() => _isVisible = false);

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) widget.onDismissed?.call();
  }

  /// Calculates the exact height the banner needs to be for a given width.
  double _calculateDesiredHeight(BuildContext context, double refWidth,
      AppLocalizations localizations) {
    if (!_isVisible) return 0.0;

    final double internalHorizontalPadding = refWidth * 0.04;
    final double internalVerticalPadding = refWidth * 0.035;
    final double iconSpacing = refWidth * 0.03;
    final double iconSize = refWidth * 0.08;
    final double gapBetweenText = refWidth * 0.01;
    final double borderThickness = refWidth * 0.003;

    // Available width for text
    final double textAvailableWidth = refWidth -
        (internalHorizontalPadding * 2) -
        iconSize -
        iconSpacing -
        (borderThickness * 2);

    if (textAvailableWidth <= 0) return 0.0;

    final String title = localizations.plusBannerTitle;
    final String subtitle = localizations.plusBannerSubtitle;

    final double titleFontSize = refWidth * 0.04;
    final double subtitleFontSize = titleFontSize * 0.80;

    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    // Measure Title
    final TextPainter titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          height: 1.1,
        ),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )
      ..layout(maxWidth: textAvailableWidth);

    // Measure Subtitle
    final TextPainter subtitlePainter = TextPainter(
      text: TextSpan(
        text: subtitle,
        style: TextStyle(
          fontSize: subtitleFontSize,
          height: 1.2,
        ),
      ),
      maxLines: 4,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )
      ..layout(maxWidth: textAvailableWidth);

    // Calculate total height of the content column
    final double textColumnHeight =
        titlePainter.height + gapBetweenText + subtitlePainter.height;

    // The container height is max(Icon, Text) + Vertical Padding
    final double contentHeight = max(iconSize, textColumnHeight);
    final double totalHeight =
        contentHeight + (internalVerticalPadding * 2) + (borderThickness * 2);

    // Add extra padding for the outer wrapper (bottom: 0.04, top: 0.02)
    final double wrapperPadding = (refWidth * 0.04) + (refWidth * 0.02);

    // +1 Buffer to avoid rounding jitter causing overflow
    return totalHeight + wrapperPadding + 1.0;
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) return const SizedBox.shrink();

    final localizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery
        .of(context)
        .size;
    final double refWidth = widget.referenceWidth ?? screenSize.width;

    if (widget.isEmbedded) {
      final double targetHeight =
      _calculateDesiredHeight(context, refWidth, localizations);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final service = Provider.of<BannerService>(context, listen: false);
        if ((service.bannerHeightNotifier.value - targetHeight).abs() > 0.5) {
          service.bannerHeightNotifier.value = targetHeight;
        }
      });

      // --- FIXED ALIGNMENT LOGIC ---
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: targetHeight,
        alignment: Alignment.bottomCenter,
        // Ensure child sticks to bottom
        child: _isVisible
            ? OverflowBox(
          // Allow content to be its natural height (even if larger than container during animation)
          minHeight: 0,
          maxHeight: double.infinity,
          alignment: Alignment.bottomCenter, // Glue content to bottom
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _exitSlideAnimation,
                child: FadeTransition(
                  opacity: _exitFadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: refWidth * 0.04, top: refWidth * 0.02),
                    child: GestureDetector(
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
          ),
        )
            : const SizedBox.shrink(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBannerContent(BuildContext context,
      AppLocalizations localizations, double refWidth) {
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

    final Color tintColor = AppColors.premium.withValues(alpha: 0.15);
    final Color solidBackgroundColor =
    Color.alphaBlend(tintColor, AppColors.background);
    final Color borderColor = AppColors.premium;
    final Color contentColor = AppColors.premium;
    final Color subtitleColor = AppColors.premium.withValues(alpha: 0.8);

    return Material(
      color: solidBackgroundColor,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.primaryColor.withValues(alpha: 0.1),
        highlightColor: AppColors.primaryColor.withValues(alpha: 0.05),
        child: Container(
          width: widget.isEmbedded ? refWidth * 0.9 : null,
          padding: EdgeInsets.symmetric(
            horizontal: internalHorizontalPadding,
            vertical: internalVerticalPadding,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: refWidth * 0.003),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: gapBetweenText),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: subtitleFontSize,
                        height: 1.2,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
