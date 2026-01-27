// lib/inbox/widgets/tiles/actions/panel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../theme.dart';
import 'buttons.dart';

class ActionPanelController {
  final Future<void> Function() _closeImpl;
  bool _isClosed = false;

  // Global reference to the currently open panel
  static ActionPanelController? _activeController;

  ActionPanelController._(this._closeImpl);

  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    if (_activeController == this) {
      _activeController = null;
    }
    await _closeImpl();
  }

  static Future<void> closeCurrent() async {
    if (_activeController != null) {
      await _activeController!.close();
    }
  }
}

ActionPanelController showActionPanel({
  required BuildContext context,
  required Offset touchPosition,
  required List<ActionPanelButton> buttons,
  VoidCallback? onClosed,
}) {
  final overlay = Overlay.of(context);
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  final double panelWidth = 160.0;
  final double estimatedHeight = (buttons.length * 50.0) + 20.0;

  final bool openUpwards = touchPosition.dy > (screenHeight * 0.6);

  double left = touchPosition.dx - (panelWidth / 2);

  if (left < 10) left = 10;
  if (left + panelWidth > screenWidth - 10) {
    left = screenWidth - panelWidth - 10;
  }

  double top;
  if (openUpwards) {
    top = touchPosition.dy - estimatedHeight - 10;
  } else {
    top = touchPosition.dy + 10;
  }

  late OverlayEntry entry;
  final ValueNotifier<bool> isClosing = ValueNotifier<bool>(false);
  final Completer<void> closeCompleter = Completer<void>();

  Future<void> requestClose() {
    if (closeCompleter.isCompleted) return closeCompleter.future;
    isClosing.value = true;
    return closeCompleter.future;
  }

  final controller = ActionPanelController._(requestClose);

  entry = OverlayEntry(
    builder: (overlayContext) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          HapticFeedback.lightImpact();
          controller.close();
        },
        onVerticalDragEnd: (_) => controller.close(),
        child: Stack(
          children: [
            Positioned(
              top: top,
              left: left,
              child: _AnimatedPanelContainer(
                openUpwards: openUpwards,
                width: panelWidth,
                buttons: buttons,
                isClosing: isClosing,
                onDismissed: () {
                  if (!closeCompleter.isCompleted) closeCompleter.complete();
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

  // Register as active
  ActionPanelController._activeController = controller;

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
      duration: const Duration(milliseconds: 100),
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
        if (mounted) widget.onDismissed();
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
    final Alignment origin =
        widget.openUpwards ? Alignment.bottomCenter : Alignment.topCenter;

    return FadeTransition(
      opacity: _animationController,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
        alignment: origin,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 0.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < widget.buttons.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  widget.buttons[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
