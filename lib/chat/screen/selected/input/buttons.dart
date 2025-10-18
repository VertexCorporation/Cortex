// buttons.dart

import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../internet.dart';
import '../../../../theme.dart';

class ActionButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onStop;

  const ActionButtonWidget({
    Key? key,
    required this.isEnabled,
    required this.isSending,
    required this.onSend,
    required this.onStop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isConnected = context.watch<InternetProvider>().isConnected;
    final Duration currentDuration = isEnabled
        ? const Duration(milliseconds: 100)
        : const Duration(milliseconds: 200);

    Color backgroundColor;
    if (isSending || isEnabled) {
      backgroundColor = AppColors.primaryColor.inverted;
    } else if (!isConnected) {
      backgroundColor = AppColors.primaryColor.inverted.withOpacity(0.1);
    } else {
      backgroundColor = AppColors.primaryColor.inverted.withOpacity(0.06);
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
        width: 34,
        height: 34,
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
            size: 24,
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
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.inverted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/stop.svg',
            width: 22,
            height: 22,
            color: AppColors.primaryColor,
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