// lib/chat/screen/selected/widgets/input/buttons.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../../internet.dart';
import '../../../../../theme.dart';

class ActionButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onStop;

  const ActionButtonWidget({
    super.key,
    required this.isEnabled,
    required this.isSending,
    required this.onSend,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConnected = context.watch<InternetProvider>().isConnected;
    final screenWidth = MediaQuery.of(context).size.width;

    // RESPONSIVE LOGIC
    final bool isTablet = screenWidth >= 600;

    // --- FULLY DYNAMIC DIMENSIONS ---

    // Button Size (Container dimensions)
    // Tablet: 6% of screen width (e.g. 48px on 800w). Phone: ~9% (approx 36px).
    // This reduction on tablet gives it breathing room inside the input field padding.
    final double buttonSize = isTablet ? screenWidth * 0.052 : screenWidth * 0.09;

    // Send Icon Size (Arrow)
    // Tablet: 3.5% of width. Phone: 6%.
    final double sendIconSize = isTablet ? screenWidth * 0.035 : screenWidth * 0.06;

    // Stop Icon Size (SVG)
    // Tablet: 3% of width. Phone: 5.5%.
    final double stopIconSize = isTablet ? screenWidth * 0.03 : screenWidth * 0.055;

    // Border Radius for Stop Button
    // Half of buttonSize to keep it circular/rounded.
    final double stopBorderRadius = buttonSize / 2;

    final Duration currentDuration = isEnabled
        ? const Duration(milliseconds: 100)
        : const Duration(milliseconds: 200);

    Color backgroundColor;
    if (isSending || isEnabled) {
      backgroundColor = AppColors.primaryColor.inverted;
    } else if (!isConnected) {
      backgroundColor = AppColors.primaryColor.inverted.withValues(alpha: 0.1);
    } else {
      backgroundColor = AppColors.primaryColor.inverted.withValues(alpha: 0.06);
    }

    Color iconColor = (isSending || isEnabled)
        ? AppColors.primaryColor
        : AppColors.tertiaryColor;

    Widget sendButton = GestureDetector(
      key: const ValueKey('sendButton'),
      onTap: isEnabled ? onSend : null,
      child: AnimatedContainer(
        duration: currentDuration,
        curve: Curves.easeOut,
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: AnimatedOpacity(
          duration: currentDuration,
          opacity: (isSending || isEnabled) ? 1.0 : 0.5,
          curve: Curves.easeInOut,
          child: Icon(
            Icons.arrow_upward,
            color: iconColor,
            size: sendIconSize,
          ),
        ),
      ),
    );

    Widget stopButton = GestureDetector(
      key: const ValueKey('stopButton'),
      onTap: onStop,
      child: AnimatedContainer(
        duration: currentDuration,
        curve: Curves.easeOut,
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.inverted,
          borderRadius: BorderRadius.circular(stopBorderRadius),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/stop.svg',
            width: stopIconSize,
            height: stopIconSize,
            colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
          ),
        ),
      ),
    );

    Widget currentChild = isSending ? stopButton : sendButton;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: currentChild,
    );
  }
}