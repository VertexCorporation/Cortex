// lib/chat/screen/appbar/claim_offer.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../../funds/backend/service.dart';

/// A premium-styled "Claim Offer" button for the Chat AppBar.
/// Mirrors the PremiumButton design but uses a gift card icon
/// and localized "Claim Offer" text.
class ClaimOfferButton extends StatefulWidget {
  final VoidCallback onTap;

  const ClaimOfferButton({
    super.key,
    required this.onTap,
  });

  @override
  State<ClaimOfferButton> createState() => _ClaimOfferButtonState();
}

class _ClaimOfferButtonState extends State<ClaimOfferButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;
  late final Animation<double> _shineAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _shineAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _shineController.forward(from: 0.0);
    });

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _shineController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final funds = context.watch<FundsBackend>();
    if (funds.currentUserSubscriptionLevel > 0) {
      return const SizedBox.shrink();
    }
    final shouldUseSpecialOfferCopy = funds.shouldShowSpecialOfferEntryPoint;
    final hasFreeTrial = funds.hasFreeTrial;

    final localizations = AppLocalizations.of(context)!;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double scale = (screenWidth / 375.0).clamp(0.85, 1.2);

    final double buttonHeight = 36.0 * scale;
    final double iconSize = 16.0 * scale;
    final double fontSize = 13.0 * scale;
    final double paddingH = 14.0 * scale;
    final double gap = 6.0 * scale;
    final double borderRadius = 36.0 * scale;
    final double borderWidth = 0.8 * scale;

    final Color baseColor = AppColors.premium.withValues(alpha: 0.15);
    final Color backgroundColor =
        Color.alphaBlend(baseColor, AppColors.background);
    final Color contentColor = AppColors.premium;
    final Color borderColor = baseColor.withValues(alpha: 0.8);

    String buttonText;
    Widget buttonIconWidget;

    if (shouldUseSpecialOfferCopy) {
      buttonText = localizations.claimOffer;
      buttonIconWidget = Icon(
        Icons.card_giftcard_rounded,
        color: contentColor,
        size: iconSize,
      );
    } else if (hasFreeTrial) {
      buttonText = localizations.freeOffer;
      buttonIconWidget = Icon(
        Icons.card_giftcard_rounded,
        color: contentColor,
        size: iconSize,
      );
    } else {
      buttonText = 'Cortex Premium';
      buttonIconWidget = SvgPicture.asset(
        'assets/icons/sparkle.svg',
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(
          contentColor,
          BlendMode.srcIn,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: contentColor.withValues(alpha: 0.1),
          highlightColor: contentColor.withValues(alpha: 0.05),
          child: Stack(
            children: [
              // 1. Base Content
              Ink(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                ),
                child: Container(
                  height: buttonHeight,
                  padding: EdgeInsets.symmetric(horizontal: paddingH),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buttonIconWidget,
                      SizedBox(width: gap),
                      Flexible(
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                            color: contentColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Shine Overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: AnimatedBuilder(
                    animation: _shineAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                            screenWidth * 0.4 * _shineAnimation.value, 0.0),
                        child: child,
                      );
                    },
                    child: Container(
                      width: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.1, 0.5, 0.9],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
