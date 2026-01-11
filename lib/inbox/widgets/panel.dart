// lib/inbox/widgets/tiles/actions/panel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../theme.dart';
import 'buttons.dart';

/// Controller used to programmatically close the action panel.
///
/// It is intentionally small: just a single [close] method.
/// Internally it's idempotent, so calling [close] multiple times is safe.
class ActionPanelController {
  final Future<void> Function() _closeImpl;
  bool _isClosed = false;

  ActionPanelController._(this._closeImpl);

  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    await _closeImpl();
  }
}

/// Shows a floating action panel anchored to the widget referenced by [anchorKey].
///
/// The panel:
/// - Positions itself near the anchor (opening upwards if there's no space below).
/// - Animates in with fade + scale.
/// - Animates out with reverse fade + scale when closed.
/// - Closes when the user taps outside or drags vertically.
/// - Calls [onClosed] exactly once when it is fully dismissed.
///
/// Returns an [ActionPanelController] that can be used to close the panel
/// programmatically (e.g., from a button press inside the panel).
ActionPanelController showActionPanel({
  required BuildContext context,
  required GlobalKey anchorKey,
  required List<ActionPanelButton> buttons,
  VoidCallback? onClosed,
}) {
  final overlay = Overlay.of(context);

  final renderBox = anchorKey.currentContext!.findRenderObject() as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  final double panelHeight = screenHeight * 0.2;
  final double panelWidth = screenWidth * 0.3;

  final bool openUpwards =
      (offset.dy + size.height + panelHeight + 20) > screenHeight;

  final double panelTop =
  openUpwards ? (offset.dy - panelHeight) : (offset.dy + size.height);
  final double panelRight = screenWidth - (offset.dx + size.width);

  late OverlayEntry entry;

  // This notifier is set to true when we want to start the close animation.
  final ValueNotifier<bool> isClosing = ValueNotifier<bool>(false);

  // Completer used so that controller.close() completes only *after*
  // the close animation finishes and the overlay is removed.
  final Completer<void> closeCompleter = Completer<void>();

  Future<void> requestClose() {
    if (closeCompleter.isCompleted) {
      return closeCompleter.future;
    }
    isClosing.value = true;
    return closeCompleter.future;
  }

  final controller = ActionPanelController._(requestClose);

  entry = OverlayEntry(
    builder: (overlayContext) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          controller.close();
        },
        onVerticalDragEnd: (_) {
          controller.close();
        },
        child: Stack(
          children: [
            Positioned(
              top: panelTop,
              right: panelRight,
              child: _AnimatedPanelContainer(
                openUpwards: openUpwards,
                width: panelWidth,
                buttons: buttons,
                isClosing: isClosing,
                onDismissed: () {
                  if (!closeCompleter.isCompleted) {
                    closeCompleter.complete();
                  }
                  entry.remove();
                  onClosed?.call();
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  overlay.insert(entry);
  return controller;
}

class _AnimatedPanelContainer extends StatefulWidget {
  final bool openUpwards;
  final double width;
  final List<ActionPanelButton> buttons;
  final ValueListenable<bool> isClosing;
  final VoidCallback onDismissed;

  const _AnimatedPanelContainer({

    required this.openUpwards,
    required this.width,
    required this.buttons,
    required this.isClosing,
    required this.onDismissed,
  });

  @override
  State<_AnimatedPanelContainer> createState() =>
      _AnimatedPanelContainerState();
}

class _AnimatedPanelContainerState extends State<_AnimatedPanelContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _hasStartedClose = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    )..forward();

    widget.isClosing.addListener(_handleClosingChanged);
  }

  @override
  void didUpdateWidget(covariant _AnimatedPanelContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isClosing != widget.isClosing) {
      oldWidget.isClosing.removeListener(_handleClosingChanged);
      widget.isClosing.addListener(_handleClosingChanged);
    }
  }

  void _handleClosingChanged() {
    if (!mounted) return;
    if (!_hasStartedClose && widget.isClosing.value) {
      _hasStartedClose = true;
      _animationController.reverse().then((_) {
        if (mounted) {
          widget.onDismissed();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.isClosing.removeListener(_handleClosingChanged);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final chatCardBackgroundColor = AppColors.background;

    return FadeTransition(
      opacity: _animationController,
      child: ScaleTransition(
        scale: _animationController,
        alignment:
        widget.openUpwards ? Alignment.bottomRight : Alignment.topRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.01,
              horizontal: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: chatCardBackgroundColor,
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              border: Border.all(
                color: AppColors.border,
                width: 0.5,
              ),
            ),
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: widget.width),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < widget.buttons.length; i++) ...[
                      if (i > 0)
                        SizedBox(height: screenHeight * 0.01),
                      widget.buttons[i],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}