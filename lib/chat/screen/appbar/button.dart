// lib/chat/screen/appbar/button.dart

// --- HELPER WIDGET: THE PILL BUTTON ---

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app.dart';
import '../../../theme.dart';

class AppBarButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isTitle;

  const AppBarButton({
    super.key,
    required this.child,
    required this.onTap,
    this.isTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 42.0;
    context.watch<ThemeProvider>();
    final Color backgroundColor = AppColors.background.withValues(alpha: 0.8);
    final Color borderColor = AppColors.primaryColor.inverted.withValues(
        alpha: 0.1);
    final Color rippleColor = AppColors.primaryColor.inverted.withValues(
        alpha: 0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent, // Must be transparent for Ink to show
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(36),
              splashColor: rippleColor,
              // Strong ripple
              highlightColor: rippleColor.withValues(alpha: 0.05),
              child: Container(
                height: size,
                width: isTitle ? null : size,
                padding: isTitle
                    ? const EdgeInsets.symmetric(horizontal: 20)
                    : EdgeInsets.zero,
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}