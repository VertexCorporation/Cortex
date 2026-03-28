// lib/notifications/introvert.dart

import 'dart:async';
import 'package:flutter/material.dart';


enum NotificationType { success, error, neutral }

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

class IntrovertNotificationService {
  final GlobalKey<NavigatorState> navigatorKey;

  IntrovertNotificationService({required this.navigatorKey});

  _ActiveNotificationHandle? _activeNotification;

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
    bool isChatMode = false,
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

      isChatMode: isChatMode,
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

    required bool isChatMode,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    final style = _NotificationStyle.fromType(type);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final media = MediaQuery.of(context);
        final double screenH = media.size.height;
        final double screenW = media.size.width;

        return Builder(
          builder: (context) {

            // --- POSITIONING LOGIC (Restored from your working code) ---
            double? leftPos;
            double? rightPos;
            double? explicitWidth;
            double bottomPosition;
            double maxWidthConstraint;

            if (isAxonMode && axonWidth > 0) {
              // --- AXON MODE ---
              // Left = 0, Width = AxonWidth, Right = NULL
              leftPos = 0;
              rightPos = null;
              explicitWidth = axonWidth;

              // Footer Height (~10.5%) + Banner Height
              final double footerHeight = screenH * 0.105;
              bottomPosition = footerHeight;

              maxWidthConstraint = axonWidth * 0.90;
            } else {
              // --- DEFAULT / CHAT MODE ---
              // Left = 0 AND Right = 0. This forces the container to span the full screen.
              leftPos = 0;
              rightPos = 0;
              explicitWidth = null;

              final keyboardInset = media.viewInsets.bottom;
              double baseOffset;

              if (isChatMode) {
                final double chatInputHeight = screenH * 0.11;
                final double padding = screenH * 0.025;
                baseOffset = chatInputHeight + padding;
              } else {
                baseOffset = bottomOffset * screenH;
              }

              bottomPosition = keyboardInset + baseOffset;
              maxWidthConstraint = screenW * 0.95;
            }

            return Stack(
              children: [
                // Background Tap Handler
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => dismissCurrentNotification(),
                    child: const SizedBox.expand(),
                  ),
                ),

                // [FIXED POSITIONING - USING STANDARD POSITIONED]
                // We replaced AnimatedPositioned with Positioned because the animation
                // is handled inside the child (_AnimatedNotification).
                // Using 'left: 0' and 'right: 0' ensures perfect centering.
                Positioned(
                  bottom: bottomPosition,
                  left: leftPos,
                  right: rightPos,
                  width: explicitWidth,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidthConstraint),
                      child: _AnimatedNotification(
                        message: message,
                        backgroundColor: style.backgroundColor,
                        icon: style.icon,
                        textColor: Colors.white,
                        duration: duration,
                        fontSize: 13.5,
                        // Fixed Style
                        oneLine: oneLine,
                        registerDismiss: (dismissFn) {
                          _activeNotification = _ActiveNotificationHandle(
                            entry: entry,
                            dismiss: dismissFn,
                            isAxonMode: isAxonMode,
                          );
                        },
                        onRemove: () {
                          try {
                            entry.remove();
                          } catch (_) {}
                          if (_activeNotification?.entry == entry) {
                            _activeNotification = null;
                          }
                        },
                        onTap: () {
                          dismissCurrentNotification();
                          onTap?.call();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    overlay.insert(entry);
  }

  void dismissCurrentNotification() {
    _activeNotification?.dismiss();
  }

  void dismissAxonNotification() {
    if (_activeNotification?.isAxonMode == true) {
      dismissCurrentNotification();
    }
  }
}

class _AnimatedNotification extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData? icon;
  final Color textColor;
  final Duration duration;
  final double fontSize;
  final bool oneLine;
  final void Function(VoidCallback dismiss) registerDismiss;
  final VoidCallback onRemove;
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
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide up animation (Same as Code 3)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    widget.registerDismiss(dismiss);
    _controller.forward();
    _dismissTimer = Timer(widget.duration, dismiss);
  }

  void dismiss() {
    if (!mounted || _isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();

    _controller.reverse().then((_) {
      if (mounted) {
        widget.onRemove();
      } else {
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

  @override
  Widget build(BuildContext context) {
    // --- STYLING CONSTANTS (From Code 2) ---
    const double borderRadius = 12.0;
    const double iconSize = 20.0;
    const double gapSize = 10.0;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onPanUpdate: (details) {
            if (details.delta.distance > 10) {
              dismiss();
            }
          },
          child: Material(
            color: Colors.transparent,
            elevation: 4.0,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Wrap content width
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.textColor,
                      size: iconSize,
                    ),
                    const SizedBox(width: gapSize),
                  ],
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 13.5, // Fixed Style
                        fontWeight: FontWeight.w500, // Fixed Style
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