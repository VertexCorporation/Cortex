// lib/chat/screen/selected/widgets/input/panels/briefing.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../../../theme.dart';

class BriefingOverlay extends StatefulWidget {
  final int? availableCredits;
  final bool photoSelected;
  final bool isOfflineModel;
  final bool modelMissing;
  final bool inappropriate;
  final bool limitReached;
  final bool isStorageSufficient;
  final bool isPremiumModel;
  final bool isSubscribed;
  final int premiumTrialUses;
  final bool isDynamicChat;

  final ValueChanged<double>? onVisibleHeightChanged;

  const BriefingOverlay({
    super.key,
    required this.availableCredits,
    required this.photoSelected,
    required this.isOfflineModel,
    required this.modelMissing,
    required this.inappropriate,
    required this.limitReached,
    required this.isStorageSufficient,
    required this.isPremiumModel,
    required this.isSubscribed,
    required this.premiumTrialUses,
    required this.isDynamicChat,
    this.onVisibleHeightChanged,
  });

  @override
  State<BriefingOverlay> createState() => _BriefingOverlayState();
}

class _BriefingOverlayState extends State<BriefingOverlay>
    with TickerProviderStateMixin {

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  String? _currentMessageText;

  final GlobalKey _panelKey = GlobalKey();
  double _measuredPanelHeight = 0.0;

  static const Duration _animationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    _slideController =
        AnimationController(vsync: this, duration: _animationDuration);

    final curvedAnimation =
    CurvedAnimation(parent: _slideController, curve: Curves.easeOut);

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(curvedAnimation);

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

    _slideController.addListener(_reportVisibleHeightThrottled);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _evaluateAndAnimate();
        _measurePanelHeightAndReport();
      }
    });
  }

  @override
  void didUpdateWidget(covariant BriefingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _evaluateAndAnimate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measurePanelHeightAndReport();
    });
  }

  @override
  void dispose() {
    _slideController.removeListener(_reportVisibleHeightThrottled);
    _slideController.dispose();
    super.dispose();
  }

  String? _evaluateMessageText(AppLocalizations loc) {
    if (widget.isPremiumModel &&
        !widget.isSubscribed &&
        widget.premiumTrialUses >= 3) {
      return loc.premiumTrialExhaustedMessage;
    }
    if (widget.inappropriate) return loc.inappropriateContentDetected;
    if (widget.limitReached) return loc.chatLengthLimitExceeded;
    if (!widget.isStorageSufficient) return loc.notEnoughStorage;
    if (widget.modelMissing) return loc.offlineModelNotInstalled;

    if (widget.availableCredits != null &&
        _requiredCredits() > widget.availableCredits!) {
      return loc.reachedLimit;
    }
    return null;
  }

  void _evaluateAndAnimate() {
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    final nextMessageText = _evaluateMessageText(loc);

    if (nextMessageText == _currentMessageText && _slideController.value > 0) {
      return;
    }

    if (nextMessageText != _currentMessageText) {
      final bool isShowingMessage = _slideController.value > 0.0;
      final bool hasNewMessage = nextMessageText != null;

      if (isShowingMessage) {
        _slideController.reverse().then((_) {
          if (!mounted) return;

          if (hasNewMessage) {
            setState(() {
              _currentMessageText = nextMessageText;
            });
            _slideController.forward(from: 0.0);
          } else {
            setState(() => _currentMessageText = null);
          }
          _measurePanelHeightAndReport();
        });
      } else if (hasNewMessage) {
        setState(() {
          _currentMessageText = nextMessageText;
        });
        _slideController.forward(from: 0.0);
        _measurePanelHeightAndReport();
      } else {
        setState(() {
          _currentMessageText = null;
        });
        _measurePanelHeightAndReport();
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
      _handleDismiss();
    }
  }

  void _handleDismiss() {
    if (_slideController.isCompleted) {
      _slideController.reverse().then((_) {
        if (!mounted) return;
        setState(() {});
        _reportVisibleHeight();
      });
    }
  }

  void _measurePanelHeightAndReport() {
    final RenderBox? box =
    _panelKey.currentContext?.findRenderObject() as RenderBox?;
    final newHeight = box?.size.height ?? 0.0;
    if (newHeight != _measuredPanelHeight) {
      _measuredPanelHeight = newHeight;
    }
    _reportVisibleHeight();
  }

  void _reportVisibleHeightThrottled() {
    _reportVisibleHeight();
  }

  void _reportVisibleHeight() {
    if (!mounted) return;
    final double base = _measuredPanelHeight;
    final double slideT = _slideController.value.clamp(0.0, 1.0);
    double visible = base * slideT;

    if (visible < 0.5) visible = 0.0;
    widget.onVisibleHeightChanged?.call(visible);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMessageText == null ||
        (_currentMessageText != null && _slideController.isDismissed)) {
      if (_measuredPanelHeight != 0 && _slideController.isDismissed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onVisibleHeightChanged?.call(0.0);
        });
      }
      if (_slideController.isDismissed) return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! > 0) {
              _slideController.value -=
                  details.primaryDelta! / _measuredPanelHeight;
            }
          },
          onVerticalDragEnd: _handlePanEnd,
          onTap: _handleDismiss,
          child: _BriefingPanelContent(
            key: _panelKey,
            message: _currentMessageText ?? "",
          ),
        ),
      ),
    );
  }

  int _requiredCredits() {
    if (widget.isOfflineModel) return 0;
    final base = (widget.isDynamicChat || widget.isPremiumModel) ? 20 : 10;
    final photo = widget.photoSelected ? 30 : 0;
    return base + photo;
  }
}

class _BriefingPanelContent extends StatelessWidget {
  final String message;

  const _BriefingPanelContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final bool isTablet = screenWidth >= 600;

    final double fontSize = isTablet ? screenWidth * 0.022 : 14.0;
    final double iconSize = isTablet ? screenWidth * 0.035 : 24.0;
    final double paddingHorizontal = isTablet ? screenWidth * 0.03 : 20.0;
    final double paddingVertical = isTablet ? screenWidth * 0.02 : 12.0;
    final double borderRadius = isTablet ? screenWidth * 0.015 : 12.0;

    final boxDecoration = BoxDecoration(
      color: AppColors.background,
      border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    );

    final textStyle = TextStyle(
      fontSize: fontSize,
      color: AppColors.primaryColor.inverted,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: paddingVertical, horizontal: paddingHorizontal),
        decoration: boxDecoration,
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/warning.svg',
              colorFilter: ColorFilter.mode(
                AppColors.primaryColor.inverted,
                BlendMode.srcIn,
              ),
              width: iconSize,
              height: iconSize,
            ),
            SizedBox(width: isTablet ? screenWidth * 0.02 : 12.0),
            Expanded(
              child: Text(
                message,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}