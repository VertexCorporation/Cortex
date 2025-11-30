// introvert.dart
//
// Manages "introverted" notifications: custom, in-app overlays (toasts)
// that provide immediate feedback within the app's own UI.
// These notifications do not interact with the external operating system and are
// responsible for showing ephemeral messages like success, error, or info alerts.

import 'dart:async';
import 'package:flutter/material.dart';

/// Defines the visual style of the in-app notification.
enum NotificationType { success, error, neutral }

/// A helper class to map [NotificationType] to concrete styles.
class _NotificationStyle {
  final Color backgroundColor;
  final IconData? icon;

  _NotificationStyle({required this.backgroundColor, this.icon});

  factory _NotificationStyle.fromType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return _NotificationStyle(
          backgroundColor: Colors.green.shade500,
          icon: Icons.check_circle_outline,
        );
      case NotificationType.error:
        return _NotificationStyle(
          backgroundColor: Colors.red.shade500,
          icon: Icons.highlight_off,
        );
      case NotificationType.neutral:
        return _NotificationStyle(
          backgroundColor: const Color(0xFF222222),
          icon: null,
        );
    }
  }
}

/// Internal handle that tracks the currently active notification.
/// This lets the service dismiss it with animation, without using a GlobalKey.
class _ActiveNotificationHandle {
  final OverlayEntry entry;
  final VoidCallback dismiss;

  _ActiveNotificationHandle({
    required this.entry,
    required this.dismiss,
  });
}

/// A dedicated service for displaying custom, animated in-app notifications (overlays).
///
/// This service is self-contained and handles the entire lifecycle of an overlay
/// notification, from creation and animation to dismissal. It requires a
/// [GlobalKey<NavigatorState>] to access the application's overlay stack.
class IntrovertNotificationService {
  final GlobalKey<NavigatorState> navigatorKey;

  IntrovertNotificationService({required this.navigatorKey});

  /// Tracks the currently visible notification overlay.
  OverlayEntry? _currentOverlayEntry;

  /// Tracks the currently active notification (entry + dismiss callback).
  _ActiveNotificationHandle? _activeNotification;

  /// Tracks whether the MainScreen bottom app bar is currently visible.
  /// Defaults to `true` because in the main shell nav bar başta açık.
  bool _isBottomAppBarVisible = true;

  /// Allows MainScreen (or other shells) to inform us about bottom app bar visibility.
  void updateBottomBarVisibility(bool isVisible) {
    _isBottomAppBarVisible = isVisible;
  }

  /// Displays a custom notification overlay with a message.
  ///
  /// If a notification is already visible, it will be dismissed gracefully
  /// before the new one is displayed (with its own exit animation).
  ///
  /// - [message]: The text to be displayed.
  /// - [type]: The style of the notification. Determines color and icon.
  ///   Defaults to [NotificationType.neutral].
  /// - [bottomOffset]: The proportional vertical offset from the bottom of the screen.
  /// - [fontSize]: The proportional font size based on the screen width.
  /// - [oneLine]: If true, forces the message to a single, ellipsis-truncated line.
  /// - [duration]: How long the notification stays on screen before auto-dismissing.
  /// - [onTap]: An optional callback to execute when the notification is tapped.
  void showNotification({
    required String message,
    NotificationType type = NotificationType.neutral,
    double bottomOffset = 0.1,
    double fontSize = 0.038,
    bool oneLine = false,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    // Ask the currently active notification (if any) to dismiss itself with animation.
    dismissCurrentNotification();

    // Immediately show the new overlay. Old one will animate out; new one will animate in.
    _showOverlayNotification(
      message: message,
      type: type,
      bottomOffset: bottomOffset,
      fontSizeProportion: fontSize,
      duration: duration,
      oneLine: oneLine,
      onTap: onTap,
    );
  }

  void _showOverlayNotification({
    required String message,
    required NotificationType type,
    required double bottomOffset,
    required double fontSizeProportion,
    bool oneLine = false,
    required Duration duration,
    VoidCallback? onTap,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) {
      debugPrint("[IntrovertService] Overlay not found. Cannot display notification.");
      return;
    }

    // Define style based on the notification type
    final style = _NotificationStyle.fromType(type);

    // Create the new OverlayEntry.
    // We capture `entry` inside the builder so each notification manages its own removal.
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final media = MediaQuery.of(context);
        final keyboardInset = media.viewInsets.bottom;

        final baseBottomOffset = bottomOffset * media.size.height;

        double extraOffset;
        if (_isBottomAppBarVisible) {
          extraOffset = media.size.height * 0.04;
        } else {
          extraOffset = media.size.height * 0.02;
        }

        double adjustedOffset = baseBottomOffset + extraOffset;
        if (adjustedOffset < 0) adjustedOffset = 0;
        if (adjustedOffset > media.size.height * 0.5) {
          adjustedOffset = media.size.height * 0.5;
        }

        final bottomPosition = keyboardInset + adjustedOffset;
        final actualFontSize = fontSizeProportion * media.size.width;

        return Positioned(
          bottom: bottomPosition,
          left: 0,
          right: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: media.size.width * 0.95),
              child: _AnimatedNotification(
                message: message,
                backgroundColor: style.backgroundColor,
                icon: style.icon,
                textColor: Colors.white,
                duration: duration,
                fontSize: actualFontSize,
                oneLine: oneLine,
                // Register this notification as the "active" one so the service
                // can dismiss it programmatically without a GlobalKey.
                registerDismiss: (dismissFn) {
                  _activeNotification = _ActiveNotificationHandle(
                    entry: entry,
                    dismiss: dismissFn,
                  );
                },
                onRemove: () {
                  // Remove this entry from the overlay.
                  entry.remove();

                  // Clear the active handle only if it still points to this entry.
                  if (_activeNotification?.entry == entry) {
                    _activeNotification = null;
                  }

                  // Also clean the generic reference if it was pointing here.
                  if (_currentOverlayEntry == entry) {
                    _currentOverlayEntry = null;
                  }
                },
                onTap: () {
                  // Dismiss via the service (with exit animation), then fire callback.
                  dismissCurrentNotification();
                  onTap?.call();
                },
              ),
            ),
          ),
        );
      },
    );

    _currentOverlayEntry = entry;
    overlay.insert(entry);
  }

  /// Programmatically dismisses the currently visible notification, if any.
  ///
  /// This triggers the notification's exit animation. The `OverlayEntry`
  /// is removed from the screen after the animation completes by the widget
  /// itself via its `onRemove` callback.
  void dismissCurrentNotification() {
    // If there is an active notification handle, trigger its dismiss animation.
    _activeNotification?.dismiss();
  }
}

/// The private widget that renders the animated notification.
///
/// It handles its own animations for appearing and disappearing and calculates
/// the optimal font size to fit the content.
class _AnimatedNotification extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData? icon;
  final Color textColor;
  final Duration duration;
  final double fontSize;
  final bool oneLine;

  /// Called by the widget to report its dismiss function back to the service.
  /// This replaces the old GlobalKey-based approach.
  final void Function(VoidCallback dismiss) registerDismiss;

  /// Called after the exit animation is fully complete and the widget
  /// should be removed from the overlay.
  final VoidCallback onRemove;

  /// Called when the notification is tapped.
  final VoidCallback onTap;

  const _AnimatedNotification({
    required this.message,
    required this.backgroundColor,
    this.icon,
    required this.textColor,
    required this.duration,
    required this.fontSize,
    required this.oneLine,
    required this.registerDismiss,
    required this.onRemove,
    required this.onTap,
  });

  @override
  _AnimatedNotificationState createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8), // Start a bit lower for a smoother feel
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Register this state's dismiss function with the service.
    widget.registerDismiss(dismiss);

    _controller.forward();
    _dismissTimer = Timer(widget.duration, dismiss);
  }

  /// Public method to programmatically dismiss the notification.
  void dismiss() {
    if (!mounted) return;
    if (_controller.status == AnimationStatus.dismissed) return;

    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onRemove();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Calculates the best-fit font size for the message, especially for single-line notifications.
  double _calculateFontSize(
      String text,
      double initialFontSize,
      double maxWidth,
      IconData? icon,
      ) {
    double fontSize = initialFontSize;
    final minFontSize = initialFontSize * 0.7;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
      maxLines: widget.oneLine ? 1 : null,
      textDirection: TextDirection.ltr,
    )..layout();

    double iconWidth = icon != null ? fontSize + 8.0 : 0.0;
    double totalWidth = textPainter.size.width + iconWidth + 32.0;

    while (widget.oneLine && totalWidth > maxWidth && fontSize > minFontSize) {
      fontSize -= 1.0;
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize),
      );
      textPainter.layout();
      totalWidth = textPainter.size.width + iconWidth + 32.0;
    }
    return fontSize;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double adjustedFontSize = _calculateFontSize(
      widget.message,
      widget.fontSize,
      screenWidth * 0.9,
      widget.icon,
    );
    final double iconSize =
    widget.icon != null ? adjustedFontSize * 1.2 : 0.0;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Material(
            color: Colors.transparent,
            elevation: 8.0, // For better depth perception
            shadowColor: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              padding:
              const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.textColor,
                      size: iconSize,
                    ),
                    const SizedBox(width: 12.0),
                  ],
                  Flexible(
                    child: widget.oneLine
                        ? FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: adjustedFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.start,
                      ),
                    )
                        : Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: adjustedFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: null,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}