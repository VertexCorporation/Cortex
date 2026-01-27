import 'dart:async';
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

  late AnimationController _arrowController;
  late Animation<double> _arrowTurns;

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    // Arrow rotation controller
    _arrowController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _arrowTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    // Content expand animation (Fade + Slide)
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _contentFade =
        Tween<double>(begin: 0.0, end: 1.0).animate(_contentController);
    _contentSlide =
        Tween<Offset>(begin: const Offset(0.0, -0.1), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutQuad));

    // Auto fade out logic
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
  void didUpdateWidget(ThinkingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (widget.content.isEmpty) return;
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _arrowController.forward();
        _contentController.forward();
      } else {
        _arrowController.reverse();
        _contentController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: const SizedBox.shrink(),
      );
    }

    final localizations = AppLocalizations.of(context);
    final hasContent = widget.content.isNotEmpty;

    // Determine label text
    String labelText;
    if (!widget.isFinished) {
      // Still thinking
      labelText = widget.label ?? (localizations?.thinking ?? 'Thinking');
    } else {
      // Finished logic
      // User requested to remove duration info ("ne kadar düşündüğü süre bilgisini vermeyelim")
      labelText = localizations?.thought ?? 'Thought';
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isVisible ? 1.0 : 0.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: hasContent ? _toggleExpand : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text section
                    widget.isFinished
                        ? Text(
                            labelText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tertiaryColor,
                              // NO ITALIC
                            ),
                          )
                        : Shimmer.fromColors(
                            baseColor: AppColors.tertiaryColor,
                            highlightColor:
                                AppColors.primaryColor.withValues(alpha: 0.5),
                            period: const Duration(milliseconds: 2000),
                            child: Text(
                              labelText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.tertiaryColor,
                                // NO ITALIC
                              ),
                            ),
                          ),

                    const SizedBox(width: 8),

                    // Arrow Icon
                    if (hasContent)
                      RotationTransition(
                        turns: _arrowTurns,
                        child: SvgPicture.asset(
                          'assets/icons/arrov.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            AppColors.tertiaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Collapsible content with Slide + Fade
          SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: _contentController,
              curve: Curves.easeInOut,
            ),
            axisAlignment: -1.0,
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Container(
                  margin: const EdgeInsets.only(left: 4, bottom: 8),
                  padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.tertiaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: SelectionArea(
                    child: RichText(
                      text: TextSpan(
                        children: parseText(context, widget.content,
                            fontSize: 12, isFinished: widget.isFinished),
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted
                              .withValues(alpha: 0.8),
                          fontSize: 12,
                          height: 1.4,
                          // Ensure child text style is normal too, unless overridden
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
