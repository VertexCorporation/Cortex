import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';

class LiquidGlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  const LiquidGlassPanel(
      {super.key,
      required this.child,
      this.borderRadius =
          const BorderRadius.vertical(top: Radius.circular(28))});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: .86),
            border: Border.all(color: AppColors.border.withValues(alpha: .8)),
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}

class ScaledBottomSheet extends StatelessWidget {
  final Widget child;

  const ScaledBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route == null || route.animation == null) {
      return child;
    }

    return AnimatedBuilder(
      animation: route.animation!,
      builder: (context, childWidget) {
        final double curvedValue =
            Curves.easeOutQuart.transform(route.animation!.value);
        final double scale = 0.92 + (0.08 * curvedValue);

        return Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: LiquidGlassPanel(child: childWidget!),
        );
      },
      child: child,
    );
  }
}
