import 'dart:async';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/chat/messages/markdown/parser.dart';

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
  bool _wasFinished = false;
  List<InlineSpan>? _cachedParsedContent;
  String? _cachedContentText;

  late AnimationController _arrowController;
  late Animation<double> _arrowTurns;

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  // Animation for the "Thinking" -> "Thought" text transition
  late AnimationController _labelTransitionController;
  late Animation<double> _labelFadeOut;
  late Animation<double> _labelFadeIn;

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

    // Label transition animation (Thinking -> Thought)
    _labelTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _labelFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _labelTransitionController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _labelFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _labelTransitionController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Initialize finished state
    _wasFinished = widget.isFinished;
    if (_wasFinished) {
      _labelTransitionController.value = 1.0;
    }

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

  List<InlineSpan> _getParsedContent(BuildContext context) {
    if (_cachedContentText == widget.content && _cachedParsedContent != null) {
      return _cachedParsedContent!;
    }
    _cachedContentText = widget.content;
    _cachedParsedContent = parseText(context, widget.content,
        fontSize: 12, isFinished: widget.isFinished);
    return _cachedParsedContent!;
  }

  @override
  void didUpdateWidget(ThinkingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.content != oldWidget.content) {
      _cachedParsedContent = null;
    }

    if (widget.isFinished && !_wasFinished) {
      _wasFinished = true;
      _labelTransitionController.forward();
    }
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _contentController.dispose();
    _labelTransitionController.dispose();
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

    // Label texts for both states
    final thinkingLabel =
        widget.label ?? (localizations?.thinking ?? 'Thinking');
    final thoughtLabel = localizations?.thought ?? 'Thought';

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
                    // Animated text transition from "Thinking" -> "Thought"
                    AnimatedBuilder(
                      animation: _labelTransitionController,
                      builder: (context, child) {
                        // Show "Thinking" with shimmer when fading out, "Thought" when fading in
                        final showThinking =
                            _labelTransitionController.value < 0.5;
                        final opacity = showThinking
                            ? _labelFadeOut.value
                            : _labelFadeIn.value;

                        final labelText =
                            showThinking ? thinkingLabel : thoughtLabel;

                        // Show shimmer only when still in thinking state (not transitioning)
                        final showShimmer = showThinking && !widget.isFinished;

                        return Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: showShimmer
                              ? Shimmer.fromColors(
                                  baseColor: AppColors.tertiaryColor,
                                  highlightColor: AppColors.primaryColor
                                      .withValues(alpha: 0.5),
                                  period: const Duration(milliseconds: 2000),
                                  child: Text(
                                    labelText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.tertiaryColor,
                                    ),
                                  ),
                                )
                              : Text(
                                  labelText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tertiaryColor,
                                  ),
                                ),
                        );
                      },
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
                        children: _getParsedContent(context),
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted
                              .withValues(alpha: 0.8),
                          fontSize: 12,
                          height: 1.4,
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
