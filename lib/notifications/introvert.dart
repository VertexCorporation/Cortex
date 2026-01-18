// lib/notifications/introvert.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../banner.dart'; // BannerService'e erişim için

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
  }) {
    dismissCurrentNotification();

    final context = navigatorKey.currentContext;
    bool isBannerVisible = false;

    if (context != null) {
      try {
        final bannerService = Provider.of<BannerService>(
            context, listen: false);
        isBannerVisible = bannerService.showInviteBannerNotifier.value;
      } catch (e) {
        // CATCH
      }
    }

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
      isBannerVisible: isBannerVisible,
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
    required bool isBannerVisible,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    final style = _NotificationStyle.fromType(type);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final media = MediaQuery.of(context);

        // --- POSITIONING LOGIC ---
        double? leftPos;
        double? rightPos;
        double? explicitWidth;
        double bottomPosition;
        double widthConstraint;

        final double bannerHeightPadding = isBannerVisible ? (media.size
            .height * 0.16) : 0.0;

        if (isAxonMode && axonWidth > 0) {
          // SIDEBAR (AXON) MODE
          leftPos = 0;
          rightPos = null;
          explicitWidth = axonWidth;

          bottomPosition = 80.0 + bannerHeightPadding;
          widthConstraint = axonWidth - 32.0;
        } else {
          // DEFAULT MODE
          leftPos = 0;
          rightPos = 0;
          explicitWidth = null;

          final keyboardInset = media.viewInsets.bottom;
          final baseOffset = bottomOffset * media.size.height;

          // Klavye varsa banner zaten görünmez/altta kalır, o yüzden max() kullanıyoruz
          // Klavye yoksa banner payını ekliyoruz.
          bottomPosition = keyboardInset + baseOffset +
              (keyboardInset > 0 ? 0 : bannerHeightPadding);

          widthConstraint = media.size.width * 0.95;
        }

        final actualFontSize = fontSizeProportion * media.size.width;

        return Stack(
          children: [
            // Layer 1: Şeffaf Dedektör (Ekrana dokunmayı yakalar)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  dismissCurrentNotification();
                },
                child: const SizedBox.expand(),
              ),
            ),

            // Layer 2: Bildirim Baloncuğu
            Positioned(
              bottom: bottomPosition,
              left: leftPos,
              right: rightPos,
              width: explicitWidth,
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
                      try {
                        entry.remove();
                      } catch (_) {
                        // Zaten silinmişse hata vermesin
                      }
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

    // Giriş: Hafif aşağıdan yukarı
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // Servis'e "beni kapatmak istersen bu fonksiyonu çağır" diyoruz
    widget.registerDismiss(dismiss);

    _controller.forward();

    // Otomatik kapanma zamanlayıcısı
    _dismissTimer = Timer(widget.duration, dismiss);
  }

  void dismiss() {
    if (!mounted || _isDismissing) return;
    _isDismissing = true;

    _dismissTimer?.cancel();

    // Çıkış: Yukarıdan aşağı düşerek (Drop) kaybol
    // Reverse animasyonunu başlat, bitince overlay'den sil
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onRemove();
      } else {
        // Widget dispose olduysa bile remove çağrılmalı ki Overlay temizlensin
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        // Bu GestureDetector baloncuk üzerindeki tıklamayı yakalar
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