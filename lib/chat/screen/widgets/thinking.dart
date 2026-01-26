import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../messages/parser.dart';

class ThinkingWidget extends StatefulWidget {
  final String content;
  final bool isFinished;
  final String? label;
  final bool autoFadeOut;

  const ThinkingWidget({
    super.key,
    required this.content,
    this.isFinished = false,
    this.label,
    this.autoFadeOut = false,
  });

  @override
  State<ThinkingWidget> createState() => _ThinkingWidgetState();
}

class _ThinkingWidgetState extends State<ThinkingWidget>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isVisible = true;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // If autoFadeOut is true and there is no content to show, fade out after a delay
    if (widget.autoFadeOut && widget.content.isEmpty) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (widget.content.isEmpty) return; // Cannot expand empty content
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // If not visible (faded out), collapse entirely
    if (!_isVisible) {
      return AnimatedSize(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: const SizedBox.shrink(),
      );
    }

    final hasContent = widget.content.isNotEmpty;
    final labelText =
        widget.label ?? (AppLocalizations.of(context)?.thinking ?? 'Thinking');

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1.0 : 0.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: hasContent ? _toggleExpand : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasContent)
                    RotationTransition(
                      turns: _iconTurns,
                      child: SvgPicture.asset(
                        'assets/icons/arrov.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          AppColors.tertiaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  else
                    // Placeholder to keep alignment or just nothing
                    const SizedBox(width: 4),

                  const SizedBox(width: 8),

                  // Label: Shimmer only if NOT finished
                  widget.isFinished
                      ? Text(
                          labelText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tertiaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Shimmer.fromColors(
                          baseColor: AppColors.tertiaryColor,
                          highlightColor:
                              AppColors.primaryColor.withValues(alpha:0.5),
                          period: const Duration(milliseconds: 2000),
                          child: Text(
                            labelText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tertiaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
          if (hasContent)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                margin: const EdgeInsets.only(left: 12, bottom: 8),
                padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.tertiaryColor.withValues(alpha:0.3),
                      width: 2,
                    ),
                  ),
                ),
                child: SelectionArea(
                  child: RichText(
                    text: TextSpan(
                      children:
                          parseText(context, widget.content, fontSize: 14),
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted.withValues(alpha:0.8),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
        ],
      ),
    );
  }
}
