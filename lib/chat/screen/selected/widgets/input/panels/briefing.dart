// lib/chat/screen/selected/input/panels/briefing.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../../theme.dart';

/// An overlay widget that displays contextual warnings and information
/// to the user (e.g., insufficient credits, disclaimers). It intelligently
/// animates the transition of one high-priority message at a time.
///
/// This widget is now decoupled from its positioning logic. It is responsible
/// only for building its content and reporting its rendered height back to the
/// parent via the `heightNotifier`. The parent widget is responsible for
/// placing it on the screen (e.g., inside a `Positioned` widget).
class BriefingOverlay extends StatefulWidget {
  /// A ValueNotifier passed from the parent. This widget will update its value
  /// with its current rendered height, allowing the parent to react to size changes.
  final ValueNotifier<double> heightNotifier;

  // --- Data properties to determine which message to show ---
  final int? availableCredits;
  final bool photoSelected;
  final bool isOfflineModel;
  final String? modelPath;
  final bool inappropriate;
  final bool limitReached;
  final bool isStorageSufficient;
  final bool showDisclaimer;
  final VoidCallback onDisclaimerDismissed;
  final bool showPhotoWarning;
  final bool isPremiumModel;
  final bool isSubscribed;
  final int premiumTrialUses;

  const BriefingOverlay({
    super.key,
    required this.heightNotifier,
    required this.availableCredits,
    required this.photoSelected,
    required this.isOfflineModel,
    this.modelPath,
    required this.inappropriate,
    required this.limitReached,
    required this.showDisclaimer,
    required this.onDisclaimerDismissed,
    required this.isStorageSufficient,
    required this.showPhotoWarning,
    required this.isPremiumModel,
    required this.isSubscribed,
    required this.premiumTrialUses,
  });

  @override
  State<BriefingOverlay> createState() => _BriefingOverlayState();
}

class _BriefingOverlayState extends State<BriefingOverlay>
    with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late final AnimationController _slideController;
  late final AnimationController _dragController;

  // --- Animations ---
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // --- Internal State ---
  String? _currentMessageText;
  bool _isCurrentMessageDismissible = false;
  Offset _dragOffset = Offset.zero;

  /// A key to access the RenderBox of the content and measure its size.
  final GlobalKey _contentKey = GlobalKey();

  static const Duration _animationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _slideController =
        AnimationController(vsync: this, duration: _animationDuration);
    _dragController =
        AnimationController(vsync: this, duration: _animationDuration);

    final curvedAnimation =
    CurvedAnimation(parent: _slideController, curve: Curves.easeOut);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(curvedAnimation);
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

    // Initial evaluation and size measurement happen after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _evaluateAndAnimate();
        _measureSize();
      }
    });
  }

  @override
  void didUpdateWidget(covariant BriefingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _evaluateAndAnimate();
    // Re-measure size after any potential content change.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureSize());
  }

  @override
  void dispose() {
    _slideController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  /// Safely measures the size of the rendered content after the layout phase
  /// and updates the parent's notifier.
  void _measureSize() {
    if (!mounted) return;
    final RenderBox? box =
    _contentKey.currentContext?.findRenderObject() as RenderBox?;

    // Determine the new height. If the widget is invisible (no message), its height is 0.
    final double newHeight = (box != null && box.hasSize) ? box.size.height : 0.0;

    // Update the notifier only if the value has actually changed.
    if (widget.heightNotifier.value != newHeight) {
      widget.heightNotifier.value = newHeight;
    }
  }

  /// Determines the highest priority message to display based on widget properties.
  String? _evaluateMessageText(AppLocalizations loc) {
    if (widget.isPremiumModel && !widget.isSubscribed && widget.premiumTrialUses >= 3) return loc.premiumTrialExhaustedMessage;
    if (widget.inappropriate) return loc.inappropriateContentDetected;
    if (widget.limitReached) return loc.chatLengthLimitExceeded;
    if (!widget.isStorageSufficient) return loc.notEnoughStorage;
    if (_modelMissing) return loc.offlineModelNotInstalled;
    if (widget.availableCredits != null && _requiredCredits() > widget.availableCredits!) return loc.insufficientCredits(widget.availableCredits!, _requiredCredits());
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

  /// Orchestrates the animation logic for showing, hiding, or transitioning
  /// between different warning messages.
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
          if (mounted && hasNewMessage) {
            setState(() {
              _currentMessageText = nextMessageText;
              _isCurrentMessageDismissible = nextIsDismissible;
              _dragOffset = Offset.zero;
            });
            _slideController.forward(from: 0.0);
          } else if (mounted) {
            setState(() => _currentMessageText = null);
          }
        });
      } else if (hasNewMessage) {
        setState(() {
          _currentMessageText = nextMessageText;
          _isCurrentMessageDismissible = nextIsDismissible;
        });
        _slideController.forward(from: 0.0);
      }
    }
  }

  /// Handles the end of a user's drag gesture to dismiss the panel.
  void _handlePanEnd(DragEndDetails details) {
    _handleDismiss();
  }

  /// Triggers the dismissal animation and then calls the parent callback.
  void _handleDismiss() {
    if (_isCurrentMessageDismissible && _slideController.isCompleted) {
      _slideController.reverse().then((_) {
        if (mounted) {
          widget.onDisclaimerDismissed();
          setState(() {
            _dragOffset = Offset.zero;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldBeVisible = _currentMessageText != null;
    if (!shouldBeVisible) {
      // Even when not visible, we must ensure the height notifier is updated to 0.
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureSize());
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onPanUpdate: _isCurrentMessageDismissible
              ? (details) => setState(() => _dragOffset += details.delta)
              : null,
          onPanEnd: _isCurrentMessageDismissible ? _handlePanEnd : null,
          onTap: _isCurrentMessageDismissible ? _handleDismiss : null,
          child: Transform.translate(
            offset: _dragOffset,
            // We wrap the actual content with a container that has the measurement key.
            child: Container(
              key: _contentKey,
              child: _BriefingPanelContent(message: _currentMessageText!),
            ),
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

  bool get _modelMissing {
    if (!widget.isOfflineModel || widget.modelPath == null || widget.modelPath!.isEmpty) {
      return false;
    }
    return !File(widget.modelPath!).existsSync();
  }
}

/// A stateless widget for the panel's visual content.
/// This improves performance by preventing the panel's decoration and layout
/// from rebuilding on every animation frame.
class _BriefingPanelContent extends StatelessWidget {
  final String message;

  const _BriefingPanelContent({required this.message});

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
            colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
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