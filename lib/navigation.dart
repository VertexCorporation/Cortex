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
///              For example, Offset(0.05, 0.0) creates a subtle horizontal slide.
Future<T?> navigateToScreen<T extends Object?>(Widget screen,
    {required Offset direction}) {
  final context = navigatorKey.currentContext;
  if (context == null) {
    debugPrint("Navigation failed: Navigator context is not available.");
    return Future.value(null); // This is a safe fallback
  }

  return Navigator.push<T>(
    context,
    PageRouteBuilder<T>(
      // The new screen widget itself.
      pageBuilder: (_, __, ___) => screen,

      // Set a comfortable duration for the complex animation.
      transitionDuration: const Duration(milliseconds: 400),

      // The core of the custom animation.
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final slideTween = Tween<Offset>(
          begin: direction,
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