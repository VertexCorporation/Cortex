// lib/navigation.dart

import 'package:flutter/material.dart';
import 'main.dart';

/// Navigates to a new screen using a premium, "Shared Axis" style transition.
///
/// This transition combines a slide, scale, and fade effect to create a sense
/// of depth and fluidity, providing a polished and professional user experience.
///
/// [screen]: The widget for the screen to navigate to.
/// [direction]: The starting offset for the slide animation.
///              For example, Offset(1.0, 0.0) slides in from the right in LTR.
///              In RTL mode, this automatically flips to slide in from the left.
Future<T?> navigateToScreen<T extends Object?>(Widget screen,
    {required Offset direction}) {
  final context = navigatorKey.currentContext;
  if (context == null) {
    debugPrint("Navigation failed: Navigator context is not available.");
    return Future.value(null); // This is a safe fallback
  }

  // Detect if the app is currently in Right-to-Left mode (e.g., Arabic).
  final bool isRtl = Directionality.of(context) == TextDirection.rtl;

  // If RTL, flip the horizontal direction (X-axis).
  // Example: If direction is (1.0, 0.0) [From Right],
  // in RTL it becomes (-1.0, 0.0) [From Left].
  final Offset effectiveDirection =
      isRtl ? Offset(-direction.dx, direction.dy) : direction;

  return Navigator.push<T>(
    context,
    PageRouteBuilder<T>(
      // The new screen widget itself.
      pageBuilder: (_, __, ___) => screen,

      // Use the runtime type of the screen widget as the route name for Analytics
      settings: RouteSettings(name: screen.runtimeType.toString()),

      // Set a comfortable duration for the complex animation.
      transitionDuration: const Duration(milliseconds: 400),

      // The core of the custom animation.
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final slideTween = Tween<Offset>(
          begin: effectiveDirection, // Use the language-aware direction
          end: Offset.zero,
        );
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic, // A smooth, decelerating curve.
        );
        final slideTransition = SlideTransition(
          position: slideTween.animate(curvedAnimation),
          child: child,
        );
        final scaleTween = Tween<double>(begin: 0.95, end: 1.0);
        final scaleTransition = ScaleTransition(
          scale: scaleTween.animate(curvedAnimation),
          child: slideTransition,
        );
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        );
        final fadeTransition = FadeTransition(
          opacity: fadeAnimation,
          child: scaleTransition,
        );
        return fadeTransition;
      },
    ),
  );
}
