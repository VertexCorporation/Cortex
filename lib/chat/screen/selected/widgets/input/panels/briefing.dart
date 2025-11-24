// lib/chat/screen/selected/widgets/input/panels/briefing.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../../../theme.dart';

class BriefingOverlay extends StatefulWidget {
  // --- Data properties ---
  final int? availableCredits;
  final bool photoSelected;
  final bool isOfflineModel;
  final bool modelMissing;
  final bool inappropriate;
  final bool limitReached;
  final bool isStorageSufficient;
  final bool showDisclaimer;
  final VoidCallback onDisclaimerDismissed;
  final bool showPhotoWarning;
  final bool isPremiumModel;
  final bool isSubscribed;
  final int premiumTrialUses;
  final bool isVisible;

  final ValueChanged<double>? onVisibleHeightChanged;

  const BriefingOverlay({
    super.key,
    required this.availableCredits,
    required this.photoSelected,
    required this.isOfflineModel,
    required this.modelMissing,
    required this.inappropriate,
    required this.limitReached,
    required this.showDisclaimer,
    required this.onDisclaimerDismissed,
    required this.isStorageSufficient,
    required this.showPhotoWarning,
    required this.isPremiumModel,
    required this.isSubscribed,
    required this.premiumTrialUses,
    required this.isVisible,
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
  bool _isCurrentMessageDismissible = false;

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

    // Slide from bottom (Offset 0,1) to position (Offset 0,0)
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
    // Trigger animation evaluation whenever any prop changes
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
    // If parent says hide, return null immediately.
    // This forces the exit animation logic to trigger.
    if (!widget.isVisible) return null;

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
      return loc.insufficientCredits(
        widget.availableCredits!,
        _requiredCredits(),
      );
    }
    if (widget.showPhotoWarning) return loc.photoWarningMessage;
    if (widget.showDisclaimer) return loc.disclaimerMessage;
    return null;
  }

  bool _isMessageDismissible(String? messageText, AppLocalizations loc) {
    if (messageText == null) return false;
    return messageText == loc.photoWarningMessage ||
        messageText == loc.disclaimerMessage;
  }

  /// The core animation logic handles the 'Exit' gracefully now.
  void _evaluateAndAnimate() {
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    final nextMessageText = _evaluateMessageText(loc);

    if (nextMessageText != _currentMessageText) {
      final nextIsDismissible = _isMessageDismissible(nextMessageText, loc);
      final bool isShowingMessage = _slideController.value > 0.0;
      final bool hasNewMessage = nextMessageText != null;

      if (isShowingMessage) {
        // CASE 1: Currently showing something.
        // We must reverse (slide down) FIRST.
        _slideController.reverse().then((_) {
          if (!mounted) return;

          if (hasNewMessage) {
            // If swapping to a new message: change text, slide up.
            setState(() {
              _currentMessageText = nextMessageText;
              _isCurrentMessageDismissible = nextIsDismissible;
            });
            _slideController.forward(from: 0.0);
          } else {
            // If hiding completely: just clear text (animation is already done).
            setState(() => _currentMessageText = null);
          }
          _measurePanelHeightAndReport();
        });
      } else if (hasNewMessage) {
        // CASE 2: Was hidden, now showing. Slide up.
        setState(() {
          _currentMessageText = nextMessageText;
          _isCurrentMessageDismissible = nextIsDismissible;
        });
        _slideController.forward(from: 0.0);
        _measurePanelHeightAndReport();
      } else {
        // CASE 3: Was hidden, stays hidden.
        setState(() {
          _currentMessageText = null;
        });
        _measurePanelHeightAndReport();
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _handleDismiss();
  }

  void _handleDismiss() {
    if (_isCurrentMessageDismissible && _slideController.isCompleted) {
      _slideController.reverse().then((_) {
        if (!mounted) return;
        widget.onDisclaimerDismissed();
        setState(() {}); // Triggers re-evaluation
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
    // Calculate precise visible height based on animation value
    final double slideT = _slideController.value.clamp(0.0, 1.0);
    double visible = base * slideT;

    if (visible < 0.5) visible = 0.0;
    widget.onVisibleHeightChanged?.call(visible);
  }

  @override
  Widget build(BuildContext context) {
    // Don't use SizedBox.shrink here if animating out.
    // Only return shrink if text is null AND animation is fully dismissed.
    if (_currentMessageText == null && _slideController.isDismissed) {
      // Just to be safe, report 0 height
      if (_measuredPanelHeight != 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(mounted) widget.onVisibleHeightChanged?.call(0.0);
        });
      }
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onPanUpdate: _isCurrentMessageDismissible
              ? (details) { _handleDismiss(); }
              : null,
          onPanEnd: _isCurrentMessageDismissible ? _handlePanEnd : null,
          onTap: _isCurrentMessageDismissible ? _handleDismiss : null,
          child: _BriefingPanelContent(
            key: _panelKey,
            message: _currentMessageText ?? "", // Safe fallback
          ),
        ),
      ),
    );
  }

  // --- Helpers ---
  int _requiredCredits() {
    if (widget.isOfflineModel) return 0;
    final base = widget.isPremiumModel ? 20 : 10;
    final photo = widget.photoSelected ? 30 : 0;
    return base + photo;
  }
}

class _BriefingPanelContent extends StatelessWidget {
  final String message;
  const _BriefingPanelContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      color: AppColors.background,
      border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    );

    final textStyle = TextStyle(
      fontSize: 14,
      color: AppColors.primaryColor.inverted,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: boxDecoration,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/warning.svg',
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor.inverted,
              BlendMode.srcIn,
            ),
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}