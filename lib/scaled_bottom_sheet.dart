import 'package:flutter/material.dart';

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
          child: childWidget,
        );
      },
      child: child,
    );
  }
}
