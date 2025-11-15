// lib/chat/screen/selected/widgets/input/panels/briefing.dart
//
// BRIEFING OVERLAY — FLOATING VERSION
//
// Key changes:
// 1) The panel is designed to be used as an absolutely-positioned floating
//    widget (e.g., inside a Stack with Positioned). It no longer assumes
//    any responsibility for reserving layout space.
// 2) It reports its *visible* height (after slide animation *and* drag)
//    via onVisibleHeightChanged so the parent can position other floating
//    UI (e.g., scroll button) exactly above it.
// 3) Dismiss is drag/tap driven for dismissible messages, unchanged in UX.

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../../../theme.dart';

class BriefingOverlay extends StatefulWidget {
  // --- Data properties to determine which message to show ---
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

  /// Called whenever the *visible* height of the panel changes.
  /// `height` already accounts for animation progress, current drag offset,
  /// and panel measurement. Parent can use this to reposition other floaters.
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
    this.onVisibleHeightChanged,
  });

  @override
  State<BriefingOverlay> createState() => _BriefingOverlayState();
}

class _BriefingOverlayState extends State<BriefingOverlay>
    with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late final AnimationController _slideController;

  // --- Animations ---
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // --- Internal State ---
  String? _currentMessageText;
  bool _isCurrentMessageDismissible = false;

  // Measurement of the panel content.
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

    // Listen to animation progress to continuously report visible height.
    _slideController.addListener(_reportVisibleHeightThrottled);

    // Initial evaluation happens after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _evaluateAndAnimate();
        _measurePanelHeightAndReport(); // ensure baseline
      }
    });
  }

  @override
  void didUpdateWidget(covariant BriefingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _evaluateAndAnimate();
    // Re-measure next frame (icon/text can change with locale/data).
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

  /// Determines the highest priority message to display based on widget properties.
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
      return loc.insufficientCredits(
        widget.availableCredits!,
        _requiredCredits(),
      );
    }
    if (widget.showPhotoWarning) return loc.photoWarningMessage;
    if (widget.showDisclaimer) return loc.disclaimerMessage;
    return null;
  }

  /// Checks if the current message type is user-dismissible.
  bool _isMessageDismissible(String? messageText, AppLocalizations loc) {
    if (messageText == null) return false;
    return messageText == loc.photoWarningMessage ||
        messageText == loc.disclaimerMessage;
  }

  /// Orchestrates transitions between messages (slide out -> swap -> slide in).
  void _evaluateAndAnimate() {
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    final nextMessageText = _evaluateMessageText(loc);

    if (nextMessageText != _currentMessageText) {
      final nextIsDismissible = _isMessageDismissible(nextMessageText, loc);
      final bool isShowingMessage = _slideController.isCompleted;
      final bool hasNewMessage = nextMessageText != null;

      if (isShowingMessage) {
        _slideController.reverse().then((_) {
          if (!mounted) return;
          if (hasNewMessage) {
            setState(() {
              _currentMessageText = nextMessageText;
              _isCurrentMessageDismissible = nextIsDismissible;
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
          _isCurrentMessageDismissible = nextIsDismissible;
        });
        _slideController.forward(from: 0.0);
        _measurePanelHeightAndReport();
      } else {
        // No message to show
        setState(() {
          _currentMessageText = null;
        });
        _measurePanelHeightAndReport();
      }
    }
  }

  /// Triggered when a drag gesture ends.
  void _handlePanEnd(DragEndDetails details) {
    _handleDismiss();
  }

  /// Dismiss if allowed; otherwise ignore.
  void _handleDismiss() {
    if (_isCurrentMessageDismissible && _slideController.isCompleted) {
      _slideController.reverse().then((_) {
        if (!mounted) return;
        widget.onDisclaimerDismissed();
        setState(() {});
      });
    }
  }

  // --- Measurement & Reporting ------------------------------------------------

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
    // Called frequently by the animation controller; keep it lightweight.
    _reportVisibleHeight();
  }

  void _reportVisibleHeight() {
    if (!mounted) return;

    // 1) Base panel height (measured once the layout is done)
    final double base = _measuredPanelHeight;

    // 2) Animation progress
    final double slideT = _slideController.isDismissed
        ? 0.0
        : _slideController.value.clamp(0.0, 1.0);
    final double fadeT = _fadeAnimation.value.clamp(0.0, 1.0);

    // 3) Effective visible height (no drag offset anymore)
    double visible = base * slideT * fadeT;

    // Small epsilon to avoid jitter
    if (visible < 0.5) visible = 0.0;

    widget.onVisibleHeightChanged?.call(visible);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMessageText == null) {
      // Notify parent that there is no visible height anymore.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onVisibleHeightChanged?.call(0.0);
      });
      return const SizedBox.shrink();
    }

    // Floating visual only: does not reserve layout space.
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          // Any drag gesture (any direction) simply triggers a downward
          // dismiss animation; the panel no longer follows the finger.
          onPanUpdate: _isCurrentMessageDismissible
              ? (details) {
            _handleDismiss();
          }
              : null,
          onPanEnd: _isCurrentMessageDismissible ? _handlePanEnd : null,
          onTap: _isCurrentMessageDismissible ? _handleDismiss : null,
          child: _BriefingPanelContent(
            key: _panelKey,
            message: _currentMessageText!,
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---
  int _requiredCredits() {
    if (widget.isOfflineModel) return 0;
    final base = widget.isPremiumModel ? 20 : 10;
    final photo = widget.photoSelected ? 30 : 0;
    return base + photo;
  }
}

/// Stateless content container (visuals only).
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
