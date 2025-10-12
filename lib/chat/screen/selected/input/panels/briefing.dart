// briefing.dart

import 'dart:io';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../../theme.dart';

/// An overlay widget that displays contextual warnings and information
/// to the user, such as insufficient credits, storage warnings, or disclaimers.
/// It intelligently handles the animated transition of one single, high-priority
/// message at a time.
class BriefingOverlay extends StatefulWidget {
  final double inputFieldHeight;
  final int availableCredits;
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
    required this.inputFieldHeight,
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

class _BriefingOverlayState extends State<BriefingOverlay> with TickerProviderStateMixin {
  // --- Animation Controllers ---
  /// Controls the primary slide-in and slide-out animation of the briefing panel.
  late final AnimationController _slideController;

  /// Controls the user-driven drag-to-dismiss and snap-back animation.
  late final AnimationController _dragController;

  // --- Animations ---
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late Animation<Offset> _dragAnimation;

  // --- State Management ---
  /// Holds the text of the message currently displayed or animating.
  String? _currentMessageText;
  /// Tracks if the current message can be dismissed by the user.
  bool _isCurrentMessageDismissible = false;
  /// The current drag offset for the dismissible panel.
  Offset _dragOffset = Offset.zero;

  // --- Constants ---
  static const Duration _animationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: _animationDuration);
    _dragController = AnimationController(vsync: this, duration: _animationDuration);

    final curvedAnimation = CurvedAnimation(parent: _slideController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curvedAnimation);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

    // Initial evaluation happens after the first frame when the context is fully available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _evaluateAndAnimate();
      }
    });
  }

  @override
  void didUpdateWidget(covariant BriefingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // On every update from the parent, re-evaluate which message should be shown.
    _evaluateAndAnimate();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  /// Determines the highest priority message to display based on the current app state.
  /// The order of checks establishes the priority.
  String? _evaluateMessageText(AppLocalizations loc) {
    if (widget.isPremiumModel && !widget.isSubscribed && widget.premiumTrialUses >= 3) {
      return loc.premiumTrialExhaustedMessage;
    }
    if (widget.inappropriate) {
      return loc.inappropriateContentDetected;
    }
    if (widget.limitReached) {
      return loc.chatLengthLimitExceeded;
    }
    if (!widget.isStorageSufficient) {
      return loc.notEnoughStorage;
    }
    if (_modelMissing) {
      return loc.offlineModelNotInstalled;
    }
    if (_requiredCredits() > widget.availableCredits) {
      return loc.insufficientCredits(widget.availableCredits, _requiredCredits());
    }
    if (widget.showPhotoWarning) {
      return loc.photoWarningMessage;
    }
    if (widget.showDisclaimer) {
      return loc.disclaimerMessage;
    }
    return null; // No message to show
  }

  /// Checks if a given message text corresponds to a dismissible message type.
  bool _isMessageDismissible(String? messageText, AppLocalizations loc) {
    if (messageText == null) return false;
    // These specific messages are user-dismissible.
    return messageText == loc.photoWarningMessage || messageText == loc.disclaimerMessage;
  }

  /// The core logic hub. It compares the next message with the current one and
  /// orchestrates the required animations for a smooth transition.
  void _evaluateAndAnimate() {
    final loc = AppLocalizations.of(context)!;
    final nextMessageText = _evaluateMessageText(loc);

    // Only act if the message content has actually changed.
    if (nextMessageText != _currentMessageText) {
      final nextIsDismissible = _isMessageDismissible(nextMessageText, loc);

      // --- Transition Logic ---
      final bool isShowingMessage = _slideController.isCompleted;
      final bool hasNewMessage = nextMessageText != null;

      // Case 1: A message is currently shown, and we need to transition to another or none.
      if (isShowingMessage) {
        _slideController.reverse().then((_) {
          if (mounted && hasNewMessage) {
            // After hiding the old one, update state for the new one and show it.
            setState(() {
              _currentMessageText = nextMessageText;
              _isCurrentMessageDismissible = nextIsDismissible;
              _dragOffset = Offset.zero; // Reset drag for the new panel
            });
            _slideController.forward(from: 0.0);
          } else if (mounted) {
            // If there's no new message, just clear the state after hiding.
            setState(() {
              _currentMessageText = null;
            });
          }
        });
      }
      // Case 2: No message is shown, but a new one needs to appear.
      else if (hasNewMessage) {
        setState(() {
          _currentMessageText = nextMessageText;
          _isCurrentMessageDismissible = nextIsDismissible;
        });
        _slideController.forward(from: 0.0);
      }
    }
  }

  // --- User Interaction Handlers for Dismissible Panels ---

  /// Called when the user lifts their finger after a drag gesture.
  void _handlePanEnd(DragEndDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final flingVelocity = details.velocity.pixelsPerSecond.distance;
    final dragDistance = _dragOffset.distance;

    // Dismiss if dragged far enough or flung fast enough.
    if (dragDistance > screenSize.width * 0.3 || flingVelocity > 750) {
      _handleDismiss();
    } else {
      // Animate the panel snapping back to its original position.
      _animateDrag(from: _dragOffset, to: Offset.zero);
    }
  }

  /// Triggers the parent callback to update the app state, which will in turn
  /// cause this widget to animate out via `didUpdateWidget`.
  void _handleDismiss() {
    if (_isCurrentMessageDismissible) {
      widget.onDisclaimerDismissed();
    }
  }

  /// Helper to animate the drag offset, e.g., for the snap-back effect.
  void _animateDrag({required Offset from, required Offset to}) {
    _dragAnimation = Tween<Offset>(begin: from, end: to).animate(
      CurvedAnimation(parent: _dragController, curve: Curves.easeOut),
    );
    _dragController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _dragController]),
      builder: (context, child) {
        // The panel should only be removed from the widget tree if it's
        // meant to be hidden AND it has finished its exit animation.
        final bool shouldBeVisible = _currentMessageText != null || _slideController.isAnimating;
        if (!shouldBeVisible) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: widget.inputFieldHeight + 12,
          left: 16,
          right: 16,
          child: child!,
        );
      },
      child: FadeTransition(
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
              child: _BriefingPanelContent(message: _currentMessageText ?? ''),
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
    if (widget.isOfflineModel == false || widget.modelPath == null || widget.modelPath!.isEmpty) {
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
      borderRadius: const BorderRadius.all(Radius.circular(8)),
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