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
  final bool isAxonMode;

  _ActiveNotificationHandle({
    required this.entry,
    required this.dismiss,
    required this.isAxonMode,
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
  /// - [isAxonMode]: Controls whether the notification appears in the sidebar (Axon).
  /// - [axonWidth]: The width of the sidebar, used for centering within that area.
  void showNotification({
    required String message,
    NotificationType type = NotificationType.neutral,
    double bottomOffset = 0.1,
    double fontSize = 0.038,
    bool oneLine = false,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    bool isAxonMode = false,
    double axonWidth = 0.0,
  }) {
    dismissCurrentNotification();

    _showOverlayNotification(
      message: message,
      type: type,
      bottomOffset: bottomOffset,
      fontSizeProportion: fontSize,
      duration: duration,
      oneLine: oneLine,
      onTap: onTap,
      isAxonMode: isAxonMode,
      axonWidth: axonWidth,
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
    required bool isAxonMode,
    required double axonWidth,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    final style = _NotificationStyle.fromType(type);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final media = MediaQuery.of(context);

        // --- POSITIONING LOGIC ---
        // Variables to determine where the Positioned widget sits.
        double? leftPos;
        double? rightPos;
        double? explicitWidth; // Defines the bounding box width for centering
        double bottomPosition;
        double widthConstraint; // Inner max-width for the bubble itself

        if (isAxonMode && axonWidth > 0) {
          // SIDEBAR (AXON) MODE:
          // Instead of aligning left with a margin, we set the Positioned width
          // to exactly match the sidebar width. The child 'Center' widget
          // will then handle centering the toast within that specific strip.

          leftPos = 0;
          rightPos = null;
          explicitWidth = axonWidth; // Force overlay container to sidebar width

          // Position just above the Settings button (approx 100px from bottom)
          bottomPosition = 100.0;

          // Ensure the bubble doesn't touch the edges of the sidebar
          widthConstraint = axonWidth - 32.0;
        } else {
          // DEFAULT MODE:
          // Spans the entire screen width (left:0, right:0), creating a context
          // where 'Center' aligns to the middle of the device screen.

          leftPos = 0;
          rightPos = 0;
          explicitWidth = null; // Let left/right control width

          final keyboardInset = media.viewInsets.bottom;
          final baseOffset = bottomOffset * media.size.height;
          bottomPosition = keyboardInset + baseOffset;
          widthConstraint = media.size.width * 0.95;
        }

        final actualFontSize = fontSizeProportion * media.size.width;

        return Positioned(
          bottom: bottomPosition,
          left: leftPos,
          right: rightPos,
          width: explicitWidth,
          // Applies primarily in Axon mode
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widthConstraint),
              child: _AnimatedNotification(
                message: message,
                backgroundColor: style.backgroundColor,
                icon: style.icon,
                textColor: Colors.white,
                duration: duration,
                fontSize: actualFontSize,
                oneLine: oneLine,
                registerDismiss: (dismissFn) {
                  _activeNotification = _ActiveNotificationHandle(
                    entry: entry,
                    dismiss: dismissFn,
                    isAxonMode: isAxonMode,
                  );
                },
                onRemove: () {
                  entry.remove();
                  if (_activeNotification?.entry == entry) {
                    _activeNotification = null;
                  }
                  if (_currentOverlayEntry == entry) {
                    _currentOverlayEntry = null;
                  }
                },
                onTap: () {
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

  void dismissAxonNotification() {
    if (_activeNotification?.isAxonMode == true) {
      dismissCurrentNotification();
    }
  }
}

/// The private widget that renders the animated notification.
///
/// It handles its own animations for appearing and disappearing.
class _AnimatedNotification extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData? icon;
  final Color textColor;
  final Duration duration;
  final double fontSize;
  final bool oneLine;

  /// Called by the widget to report its dismiss function back to the service.
  final void Function(VoidCallback dismiss) registerDismiss;

  /// Called after the exit animation is fully complete.
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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // Subtle slide up
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    widget.registerDismiss(dismiss);
    _controller.forward();
    _dismissTimer = Timer(widget.duration, dismiss);
  }

  void dismiss() {
    if (!mounted) return;
    if (_controller.status == AnimationStatus.dismissed) return;
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) widget.onRemove();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Material(
            color: Colors.transparent,
            elevation: 4.0,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1), width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.textColor, size: 20),
                    const SizedBox(width: 10.0),
                  ],
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        // Use a slightly smaller font for sidebar compatibility
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: widget.oneLine ? 1 : null,
                      overflow: widget.oneLine ? TextOverflow.ellipsis : null,
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