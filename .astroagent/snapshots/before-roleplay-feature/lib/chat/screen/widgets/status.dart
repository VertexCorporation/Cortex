import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

class ToolStatusWidget extends StatefulWidget {
  final String text;
  final bool isFinished;
  final double fontSize;

  const ToolStatusWidget({
    super.key,
    required this.text,
    required this.isFinished,
    this.fontSize = 14.0,
  });

  @override
  State<ToolStatusWidget> createState() => _ToolStatusWidgetState();
}

class _ToolStatusWidgetState extends State<ToolStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // If initial state is finished or checked, start completely hidden
    if (widget.isFinished || widget.text.contains('✅')) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ToolStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldHide = widget.isFinished || widget.text.contains('✅');
    final wasHidden = oldWidget.isFinished || oldWidget.text.contains('✅');

    if (shouldHide && !wasHidden) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // If animation is complete (value 1.0), shrink to nothing
        if (_controller.value >= 1.0) {
          return const SizedBox.shrink();
        }
        return FadeTransition(
          opacity: _opacityAnim,
          child: SizeTransition(
            // Collapse size as we fade out
            sizeFactor: Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.0, 1.0, curve: Curves.easeOut)),
            ),
            child: child,
          ),
        );
      },
      child: Shimmer.fromColors(
        baseColor: AppColors.tertiaryColor,
        highlightColor: AppColors.primaryColor.withValues(alpha: 0.5),
        period: const Duration(milliseconds: 2000),
        child: Text(
          AppLocalizations
              .of(context)
              ?.workInProgress ?? 'Work In Progress',
          style: TextStyle(
            fontSize: widget.fontSize * 0.9,
            fontWeight: FontWeight.w400,
            color: AppColors.tertiaryColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
