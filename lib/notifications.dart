import 'package:flutter/material.dart';

class NotificationService {
  final GlobalKey<NavigatorState> navigatorKey;

  NotificationService({required this.navigatorKey});

  void showNotification({
    required String message,
    bool? isSuccess,
    double bottomOffset = 0.1,
    double fontSize = 0.038,
    bool oneLine = false, // New parameter
    Duration duration = const Duration(seconds: 1),
    VoidCallback? onTap,
  }) {
    _showOverlayNotification(
      message: message,
      backgroundColor: isSuccess != null
          ? (isSuccess ? Colors.green : Colors.red)
          : const Color(0xFF222222),
      icon: isSuccess != null
          ? (isSuccess ? Icons.check_circle : Icons.error)
          : null,
      textColor: Colors.white,
      bottomOffset: bottomOffset,
      fontSizeProportion: fontSize,
      duration: duration,
      oneLine: oneLine,
      // Pass it down
      onTap: onTap,
    );
  }

  // _showOverlayNotification metodunda
  void _showOverlayNotification({
    required String message,
    required Color backgroundColor,
    IconData? icon,
    required Color textColor,
    required double bottomOffset,
    required double fontSizeProportion,
    bool oneLine = false,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) {
      print("Overlay bulunamadı");
      return;
    }

    final GlobalKey<_AnimatedNotificationState> notificationKey = GlobalKey();

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery
            .of(context)
            .size;
        final media   = MediaQuery.of(context);
        final kbInset = media.viewInsets.bottom;
        final baseBot = bottomOffset * media.size.height;
        final bottom  = kbInset + baseBot;
        final actualFontSize = fontSizeProportion * screenSize.width;

        Widget notificationWidget = _AnimatedNotification(
          key: notificationKey,
          message: message,
          backgroundColor: backgroundColor,
          icon: icon,
          textColor: textColor,
          duration: duration,
          fontSize: actualFontSize,
          // Piksel cinsinden font boyutu
          oneLine: oneLine,
          // Pass it to the widget
          onRemove: () {
            overlayEntry.remove();
            print("Overlay kaldırıldı");
          },
          onTap: () {
            notificationKey.currentState?.dismiss();
            if (onTap != null) {
              onTap();
            }
          },
        );

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  notificationKey.currentState?.dismiss();
                },
                child: Container(),
              ),
            ),
            Positioned(
              bottom: bottom,
              left: 0, right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: media.size.width * 0.95),
                  child: notificationWidget,
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(overlayEntry);
  }
}

  class _AnimatedNotification extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData? icon;
  final Color textColor;
  final Duration duration;
  final double fontSize; // Piksel cinsinden font boyutu
  final bool oneLine; // New parameter
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _AnimatedNotification({
    super.key,
    required this.message,
    required this.backgroundColor,
    this.icon,
    required this.textColor,
    required this.duration,
    required this.fontSize,
    required this.oneLine, // Initialize it
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

  // Maksimum genişlik sınırı
  double get maxWidth => MediaQuery.of(context).size.width * 0.9;

  // Minimum font boyutu
  double get minFontSize => widget.fontSize * 0.7;

  // Mevcut font boyutunu hesaplamak için
  double calculateFontSize(String text, double initialFontSize, double maxWidth, IconData? icon) {
    double fontSize = initialFontSize;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize),
      ),
      maxLines: widget.oneLine ? 1 : null, // Control maxLines based on oneLine
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // İkon varsa, ikonu da hesaba kat
    double iconWidth = icon != null ? fontSize + 8.0 : 0.0; // İkon boyutu + boşluk

    // Metnin genişliği + ikon genişliği
    double totalWidth = textPainter.size.width + iconWidth + 32.0; // 16 padding sol ve sağ

    // Eğer toplam genişlik maksimum genişliği aşıyorsa, font boyutunu küçült
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
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Bildirim animasyonu (aşağıdan yukarıya)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Opaklık animasyonu
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Bildirimi belirli süre sonra kapatma
    Future.delayed(widget.duration, () {
      _startExitAnimation();
    });
  }

  void dismiss() {
    _startExitAnimation();
  }

  void _startExitAnimation() {
    if (mounted) {
      _controller.reverse().then((_) {
        widget.onRemove();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double adjustedFontSize = calculateFontSize(
      widget.message,
      widget.fontSize,
      maxWidth,
      widget.icon,
    );

    double iconSize = widget.icon != null ? adjustedFontSize : 0.0;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.textColor,
                      size: iconSize, // İkon boyutu font boyutuyla aynı
                    ),
                    const SizedBox(width: 8.0),
                  ],
                  // Expanded widget'ını kaldırdık
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: adjustedFontSize,
                      ),
                      maxLines: widget.oneLine ? 1 : null, // Control maxLines
                      overflow: widget.oneLine ? TextOverflow.ellipsis : TextOverflow.visible,
                      textAlign:
                      widget.icon != null ? TextAlign.start : TextAlign.center,
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