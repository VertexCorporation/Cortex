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
    final bool isConnected = context
        .watch<InternetProvider>()
        .isConnected;

    // Fixed size to match the '+' and 'Model' buttons in input.dart
    const double buttonSize = 36.0;
    const double sendIconSize = 20.0; // Proportional to 36.0
    const double stopIconSize = 14.0; // Proportional to 36.0
    const double stopBorderRadius = buttonSize / 2;

    final Duration currentDuration = isEnabled
        ? const Duration(milliseconds: 100)
        : const Duration(milliseconds: 200);

    // Color Logic: Keeps the button 'Filled' (Solid) because it's the Primary Action.
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

    // SEND BUTTON
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
            Icons.arrow_upward_rounded, // Rounded variant looks cleaner
            color: iconColor,
            size: sendIconSize,
          ),
        ),
      ),
    );

    // STOP BUTTON
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
          // Solid background for stop too
          borderRadius: BorderRadius.circular(stopBorderRadius),
          border: Border.all(
            color: AppColors.border, // Optional subtle border for stop
            width: 1.0,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/stop.svg',
            width: stopIconSize,
            height: stopIconSize,
            colorFilter: ColorFilter.mode(
                AppColors.primaryColor,
                BlendMode.srcIn
            ),
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