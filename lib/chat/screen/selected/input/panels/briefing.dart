// briefing.dart

import 'dart:io';
import 'dart:math';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../../theme.dart';

class BriefingOverlay extends StatefulWidget {
  final double inputFieldHeight;

  // raw data
  final int  availableCredits;
  final bool photoSelected;
  final bool isOfflineModel;
  final String? modelPath;
  final bool inappropriate;
  final bool limitReached;
  final bool isStorageSufficient;
  // Disclaimer-specific properties
  final bool showDisclaimer;
  final VoidCallback onDisclaimerDismissed;
  final bool showPhotoWarning;

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
  });

  @override
  State<BriefingOverlay> createState() => _BriefingOverlayState();
}

class _BriefingOverlayState extends State<BriefingOverlay>
    with TickerProviderStateMixin {

  // Animation controllers
  late final AnimationController _entryController;
  AnimationController? _releaseController;

  // Animations
  late Animation<Offset> _slideInAnimation;
  late Animation<double> _fadeInAnimation;

  // State for interactive dragging
  Offset _dragOffset = Offset.zero;
  double _releaseOpacity = 1.0;

  // Message state
  String? _msg;
  bool _isDismissible = false;

  // ------------ Lifecycle Methods ------------

  @override
  void initState() {
    super.initState();
    debugPrint('[BriefingOverlay] initState');

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideInAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeIn));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _evaluate();
  }

  @override
  void didUpdateWidget(covariant BriefingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _evaluate();
  }

  @override
  void dispose() {
    debugPrint('[BriefingOverlay] dispose');
    _entryController.dispose();
    _releaseController?.dispose();
    super.dispose();
  }



  // ------------ Helper & Evaluation Logic ------------

  /// Determines which message, if any, should be displayed based on widget properties.
  /// It checks for messages in a specific order of priority.
  void _evaluate() {
    final loc = AppLocalizations.of(context)!;
    String? next;
    // --- MODIFIED ---
    bool nextIsDismissible = false;

    // The order of these checks defines message priority.
    if (widget.inappropriate) {
      next = loc.inappropriateContentDetected;
    } else if (widget.limitReached) {
      next = loc.chatLengthLimitExceeded;
    } else if (!widget.isStorageSufficient) {
      next = loc.notEnoughStorage;
    } else if (_modelMissing) {
      next = loc.offlineModelNotInstalled;
    } else if (_requiredCredits() > widget.availableCredits) {
      next = loc.insufficientCredits(
        widget.availableCredits,
        _requiredCredits(),
      );
    } else if (widget.showPhotoWarning) {
      next = loc.photoWarningMessage; // You need to add this key to your .arb file
      nextIsDismissible = true;
    } else if (widget.showDisclaimer) {
      next = loc.disclaimerMessage;
      nextIsDismissible = true;
    }

    // Only update state and trigger animations if the message has changed.
    if (next != _msg) {
      debugPrint('[BriefingOverlay] Evaluated state. New message: "$next". Is Dismissible: $nextIsDismissible');
      setState(() {
        _msg = next;
        _isDismissible = nextIsDismissible;
        _dragOffset = Offset.zero; // Reset drag position for the new message.
      });

      // Control the entry/exit animation based on whether there's a message.
      if (_msg == null) {
        if (_entryController.isCompleted) _entryController.reverse();
      } else {
        if (_entryController.isDismissed) _entryController.forward(from: 0);
      }
    }
  }

  // ------------ Drag & Dismissal Animation Logic (ONLY for the disclaimer) ------------

  /// Handles the end of a drag gesture.
  /// This function is gated by the `_isDisclaimer` check in the GestureDetector's `onPanEnd`.
  void _handlePanEnd(DragEndDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final velocityObject = details.velocity;
    final pixelsPerSecond = velocityObject.pixelsPerSecond;
    final offset = _dragOffset;

    // Dismissal thresholds
    final dismissThreshold = screenSize.width / 4;
    final velocityThreshold = 750.0;

    // Condition to dismiss: drag far enough OR fling fast enough.
    if (offset.distance > dismissThreshold || pixelsPerSecond.distance > velocityThreshold) {
      debugPrint('[BriefingOverlay] Disclaimer dismissal threshold met. Flinging off-screen.');
      _animateFling(velocityObject);
    } else {
      debugPrint('[BriefingOverlay] Disclaimer dismissal threshold not met. Snapping back.');
      _animateSnapBack();
    }
  }

  /// Animates the card off-screen in the direction of the fling, now with a fade-out effect.
  void _animateFling(Velocity velocity) {
    // Calculate a realistic end offset based on the current drag position and fling direction.
    final direction = _dragOffset.direction;
    final endOffset = Offset(cos(direction), sin(direction)) * MediaQuery.of(context).size.width;

    _startReleaseAnimation(
      from: _dragOffset,
      to: endOffset,
      shouldFadeOut: true,
      onComplete: () {
        debugPrint('[BriefingOverlay] Fling animation complete. Notifying parent to dismiss disclaimer.');
        // This is the crucial callback to the parent widget.
        widget.onDisclaimerDismissed();
      },
    );
  }

  /// Animates the card back to its original centered position if not dismissed.
  void _animateSnapBack() {
    _startReleaseAnimation(
        from: _dragOffset,
        to: Offset.zero,
        shouldFadeOut: false, // <-- Tell the animation NOT to fade
        onComplete: () {
          debugPrint('[BriefingOverlay] Snap-back animation complete.');
          // Reset drag offset state after animation finishes to be clean.
          setState(() {
            _dragOffset = Offset.zero;
          });
        });
  }

  /// A generic method to start the post-drag animation (either fling or snap-back).
  /// It now orchestrates both position and opacity animations.
  void _startReleaseAnimation({
    required Offset from,
    required Offset to,
    required bool shouldFadeOut, // New parameter to control fading
    required VoidCallback onComplete
  }) {
    _releaseController?.dispose(); // Dispose of any existing controller.
    _releaseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    // Animation for the card's position (fling or snap-back)
    final positionAnimation = Tween<Offset>(begin: from, end: to).animate(
      CurvedAnimation(parent: _releaseController!, curve: Curves.easeOut),
    );

    // NEW: Animation for the card's opacity (fade-out or stay opaque)
    final opacityAnimation = Tween<double>(begin: 1.0, end: shouldFadeOut ? 0.0 : 1.0).animate(
      CurvedAnimation(parent: _releaseController!, curve: Curves.easeOut),
    );

    _releaseController!
      ..addListener(() {
        // Update both position and opacity state on each animation frame
        setState(() {
          _dragOffset = positionAnimation.value;
          _releaseOpacity = opacityAnimation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          onComplete();
        }
      });

    _releaseController!.forward();
  }

  /// Dismisses the disclaimer with a simple tap, animating it downwards.
  void _handleTapDismiss() {
    debugPrint('[BriefingOverlay] Dismissing disclaimer via tap.');
    // Fling downwards with a fixed velocity to trigger the dismiss animation.
    _animateFling(const Velocity(pixelsPerSecond: Offset(0, 1000)));
  }

  // ------------ Build Method ------------

  @override
  Widget build(BuildContext context) {
    if (_msg == null) return const SizedBox.shrink();

    // The icon is now conditional. We can use a different icon for the photo warning.
    final String iconAsset = 'assets/icons/warning.svg';

    return Positioned(
      bottom: widget.inputFieldHeight + 12,
      left: 16,
      right: 16,
      child: GestureDetector(
        // The gestures are now enabled if the message is dismissible.
        onTap: _isDismissible ? _handleTapDismiss : null,
        onPanUpdate: _isDismissible ? (details) {
          setState(() {
            _dragOffset += details.delta;
            _releaseOpacity = 1.0;
          });
        } : null,
        onPanEnd: _isDismissible ? _handlePanEnd : null,
        child: SlideTransition(
          position: _slideInAnimation,
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Transform.translate(
              offset: _dragOffset,
              child: Opacity(
                opacity: _releaseOpacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        iconAsset,
                        colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _msg!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryColor.inverted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  /// Calculates the number of credits required for a server-side model action.
  int _requiredCredits() {
    if (widget.isOfflineModel) return 0; // Offline models don't use credits.
    final base  = 20;
    final photo = widget.photoSelected ? 30 : 0;
    return base + photo;
  }

  /// Checks if an offline model's file is missing from the device storage.
  bool get _modelMissing {
    if (!widget.isOfflineModel) return false; // Not applicable for server-side models.
    if (widget.modelPath == null || widget.modelPath!.isEmpty) return true; // Path is null or empty.
    return !File(widget.modelPath!).existsSync(); // Check if the file exists at the path.
  }
}