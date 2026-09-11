import 'package:cortex/design.dart';
import 'dart:async';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/chat/messages/markdown/parser.dart';
import 'package:cortex/chat/messages/tiles/ai/reveal_text.dart';
import 'package:cortex/chat/messages/tiles/ai/reveal_timeline.dart';

class ThinkingWidget extends StatefulWidget {
  final String content;
  final bool isFinished;
  final String? label;
  final bool autoFadeOut;

  /// Typography/layout multiplier for hosts that scale their message tiles
  /// (the AI message tile). Defaults to 1.0, which is what the in-markdown
  /// usage (`processBlockMatch`) has always used.
  final double scale;

  /// The host message's shared reveal timeline. When provided, the reasoning
  /// text is painted through the SAME [RevealText] glyph pipeline (same fade,
  /// stagger, clock and generation state) as the assistant's main answer, so
  /// a streamed reasoning block animates identically to streamed answer text
  /// instead of appearing as plain typing. Static hosts (message viewer,
  /// markdown blocks) omit it and keep the plain [RichText].
  final RevealTimeline? reveal;

  const ThinkingWidget({
    super.key,
    required this.content,
    this.isFinished = false,
    this.label,
    this.autoFadeOut = false,
    this.scale = 1.0,
    this.reveal,
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
        fontSize: 12 * widget.scale, isFinished: widget.isFinished);
    return _cachedParsedContent!;
  }

  @override
  void didUpdateWidget(ThinkingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.content != oldWidget.content) {
      _cachedParsedContent = null;
    }

    // The finished flag changes how the content is parsed (final markdown
    // polish): a completed reasoning block must be re-parsed, not served
    // from the streaming-phase cache.
    if (widget.isFinished != oldWidget.isFinished) {
      _cachedParsedContent = null;
    }

    // A NEW reasoning stream landed on this slot — a regeneration, or a
    // different message recycled into the same list position. The label
    // lifecycle must restart with it: a fresh, still-open stream shimmers
    // "Thinking" again instead of inheriting the previous response's
    // settled "Thought" state. (The finished flag flipping true→false and
    // the content resetting to empty are the two observable stream
    // restarts; neither is tied to expand/collapse.)
    if ((!widget.isFinished && oldWidget.isFinished) ||
        (widget.content.isEmpty && oldWidget.content.isNotEmpty)) {
      _wasFinished = widget.isFinished;
      _labelTransitionController.stop();
      _labelTransitionController.value = widget.isFinished ? 1.0 : 0.0;
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
                padding: EdgeInsets.symmetric(
                    vertical: 8.0 * widget.scale,
                    horizontal: 4.0 * widget.scale),
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

                        // Shimmer while the reasoning stream is open — and
                        // keep it mounted while the label fades out so the
                        // shimmer melts away with the fade instead of
                        // snapping to a flat label. The settled "Thought"
                        // state never shimmers.
                        final showShimmer = showThinking &&
                            (!widget.isFinished ||
                                _labelTransitionController.isAnimating);

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
                                      fontSize: 14 * widget.scale,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.tertiaryColor,
                                    ),
                                  ),
                                )
                              : Text(
                                  labelText,
                                  style: TextStyle(
                                    fontSize: 14 * widget.scale,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
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
                          width: CortexDesign.icon,
                          height: CortexDesign.icon,
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
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Container(
                  margin: EdgeInsets.only(
                      left: 4 * widget.scale, bottom: 8 * widget.scale),
                  padding: EdgeInsets.only(
                      left: 12 * widget.scale,
                      top: 4 * widget.scale,
                      bottom: 4 * widget.scale),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.tertiaryColor.withValues(alpha: 0.3),
                        width: 2 * widget.scale,
                      ),
                    ),
                  ),
                  child: SelectionArea(
                    child: _buildContentText(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The reasoning text. Without a [ThinkingWidget.reveal] timeline this is
  /// the historical plain [RichText] (message viewer, markdown blocks). With
  /// one — the AI message tile — the SAME [RevealText] component paints the
  /// reasoning glyphs on the host message's shared reveal clock, so streamed
  /// reasoning animates exactly like streamed main-answer text: identical
  /// fade duration, stagger, catch-up pacing and generation resets.
  Widget _buildContentText(BuildContext context) {
    final style = TextStyle(
      color: AppColors.primaryColor.inverted.withValues(alpha: 0.8),
      fontSize: 12 * widget.scale,
      height: 1.4,
    );
    final spans = _getParsedContent(context);
    final reveal = widget.reveal;
    if (reveal == null) {
      return RichText(
        text: TextSpan(children: spans, style: style),
      );
    }
    return RevealText(
      timeline: reveal,
      text: TextSpan(style: style, children: spans),
    );
  }
}

/// A compact tool trace shown inside an AI message while the server-side
/// tool loop is running. It deliberately shares the same arrow and
/// expand/collapse language as the reasoning block, while keeping tool
/// details out of the assistant's markdown text.
class ToolActivityWidget extends StatefulWidget {
  final String activeTool;
  final List<String> steps;

  const ToolActivityWidget({
    super.key,
    this.activeTool = '',
    this.steps = const [],
  });

  @override
  State<ToolActivityWidget> createState() => _ToolActivityWidgetState();
}

class _ToolActivityWidgetState extends State<ToolActivityWidget>
    with TickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _arrowController;
  late final Animation<double> _arrowTurns;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _arrowTurns = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  String _label(BuildContext context, String name, {bool active = false}) {
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';
    final labels = <String, List<String>>{
      'run_python_code': ['Kod çalıştırılıyor', 'Kod çalıştırıldı'],
      'get_weather': ['Hava durumu aranıyor', 'Hava durumu getirildi'],
      'get_stock_price': ['Piyasa verisi aranıyor', 'Piyasa verisi getirildi'],
      'read_document': ['Belge okunuyor', 'Belge okundu'],
      'render_chart': ['Grafik hazırlanıyor', 'Grafik hazırlandı'],
      'calculate': ['Hesaplanıyor', 'Hesaplandı'],
      'need_web_search': ['Web aranıyor', 'Web araması tamamlandı'],
      'web_search': ['Web aranıyor', 'Web araması tamamlandı'],
    };
    final pair = labels[name] ??
        (isTurkish
            ? ['Araç çalıştırılıyor', 'Araç tamamlandı']
            : ['Using a tool', 'Tool completed']);
    if (isTurkish) return active ? pair[0] : pair[1];

    final english = <String, List<String>>{
      'run_python_code': ['Running code', 'Code executed'],
      'get_weather': ['Checking weather', 'Weather checked'],
      'get_stock_price': ['Checking market data', 'Market data checked'],
      'read_document': ['Reading document', 'Document read'],
      'render_chart': ['Preparing chart', 'Chart prepared'],
      'calculate': ['Calculating', 'Calculated'],
      'need_web_search': ['Searching the web', 'Web search complete'],
      'web_search': ['Searching the web', 'Web search complete'],
    };
    final englishPair = english[name] ?? ['Using a tool', 'Tool completed'];
    return active ? englishPair[0] : englishPair[1];
  }

  void _toggle() {
    if (widget.steps.isEmpty && widget.activeTool.isEmpty) return;
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _arrowController.forward();
    } else {
      _arrowController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActivity = widget.activeTool.isNotEmpty || widget.steps.isNotEmpty;
    if (!hasActivity) return const SizedBox.shrink();

    final visibleSteps = <String>[...widget.steps];
    if (widget.activeTool.isNotEmpty &&
        (visibleSteps.isEmpty || visibleSteps.last != widget.activeTool)) {
      visibleSteps.add(widget.activeTool);
    }
    final isActive = widget.activeTool.isNotEmpty;
    final title = isActive
        ? _label(context, widget.activeTool, active: true)
        : (Localizations.localeOf(context).languageCode == 'tr'
            ? 'Araç adımları'
            : 'Tool steps');

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive)
                      Shimmer.fromColors(
                        baseColor: AppColors.tertiaryColor,
                        highlightColor:
                            AppColors.primaryColor.withValues(alpha: 0.55),
                        period: const Duration(milliseconds: 1500),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: AppColors.tertiaryColor,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    else
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.tertiaryColor,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    const SizedBox(width: 8),
                    RotationTransition(
                      turns: _arrowTurns,
                      child: SvgPicture.asset(
                        'assets/icons/arrov.svg',
                        width: CortexDesign.icon,
                        height: CortexDesign.icon,
                        colorFilter: ColorFilter.mode(
                          AppColors.tertiaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
                SizeTransition(
                  sizeFactor: CurvedAnimation(
                    parent: _arrowController,
                    curve: Curves.easeInOut,
                  ),
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: visibleSteps
                          .asMap()
                          .entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text(
                                '${entry.key + 1}. ${_label(context, entry.value, active: entry.value == widget.activeTool)}',
                                style: TextStyle(
                                  color: AppColors.primaryColor.inverted
                                      .withValues(alpha: 0.62),
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
