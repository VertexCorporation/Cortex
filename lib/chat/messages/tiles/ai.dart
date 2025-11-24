// chat/messages/tiles/ai.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../library/utils.dart';
import '../../../recognizer.dart';
import '../../../theme.dart';
import '../options/manager.dart';
import '../messages.dart';
import '../parser.dart';
import 'package:cortex/l10n/app_localizations.dart';

class AIMessageTile extends StatefulWidget {
  final Message message;
  final String avatarPath;
  final VoidCallback? onFadeOutComplete;
  final VoidCallback? onReport;
  final void Function({String? newModelId})? onRegenerate;
  final VoidCallback? onStop;
  final List<InlineSpan>? parsedSpans;

  const AIMessageTile({
    super.key,
    required this.message,
    required this.avatarPath,
    this.onFadeOutComplete,
    this.onReport,
    this.onRegenerate,
    this.onStop,
    this.parsedSpans,
  });

  @override
  State<AIMessageTile> createState() => _AIMessageTileState();
}

class _AIMessageTileState extends State<AIMessageTile> with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _entryCtl;
  late final Animation<double> _entryScaleAnim;
  late final AnimationController _fadeCtl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _thinkPulseCtl;
  late final Animation<double> _thinkPulseAnim;
  late final AnimationController _thinkRotateCtl;
  late final AnimationController _headerEntryCtl;
  late final Animation<double> _headerEntryAnim;
  late final AnimationController _textAnimCtl;

  // State for text animation
  String _stableText = "";
  String _animatingText = "";

  // State for error display
  bool _isExpandedError = false;
  bool _showErrorText = false;
  late AnimationController _errorSlideCtl;
  late Animation<Offset> _errorSlideAnim;
  late AnimationController _errorFadeOutCtl;
  late Animation<double> _errorFadeOutAnim;
  final Map<String, List<InlineSpan>> _parseCache = {};

  @override
  void initState() {
    super.initState();
    _entryCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _entryScaleAnim = CurvedAnimation(parent: _entryCtl, curve: Curves.elasticOut);
    _fadeCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeCtl, curve: Curves.easeOut),
    );
    _thinkPulseCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _thinkPulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _thinkPulseCtl, curve: Curves.easeInOut),
    );
    _thinkRotateCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000));

    if (widget.message.isThinking && !widget.message.isError) {
      _thinkPulseCtl.repeat(reverse: true);
      _thinkRotateCtl.repeat();
      _entryCtl.forward();
    }

    _headerEntryCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _headerEntryAnim = CurvedAnimation(parent: _headerEntryCtl, curve: Curves.easeOut);
    _textAnimCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));

    _textAnimCtl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted && _animatingText.isNotEmpty) {
          setState(() {
            _stableText += _animatingText;
            _animatingText = "";
          });
        }
      }
    });

    _errorSlideCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _errorSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _errorSlideCtl, curve: Curves.easeOutQuad));

    _errorFadeOutCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _errorFadeOutAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _errorFadeOutCtl, curve: Curves.easeOut),
    );

    if (widget.message.isError) {
      _fadeCtl.value = 0.0;
      _errorFadeOutCtl.value = 0.0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _errorFadeOutCtl.forward(); // smooth fade-in
        }
      });
    } else {
      _errorFadeOutCtl.value = 0.0;
      if (widget.message.opacity == 1) {
        _fadeCtl.forward(from: 0);
      } else {
        _fadeCtl.value = widget.message.opacity;
      }
    }

    if (!widget.message.isThinking && widget.message.text.isNotEmpty) {
      _stableText = widget.message.text;
      _headerEntryCtl.value = 1.0;
      _entryCtl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entryCtl.dispose();
    _fadeCtl.dispose();
    _thinkPulseCtl.dispose();
    _thinkRotateCtl.dispose();
    _headerEntryCtl.dispose();
    _textAnimCtl.dispose();
    _errorSlideCtl.dispose();
    _errorFadeOutCtl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AIMessageTile old) {
    super.didUpdateWidget(old);
    final String logPrefix = "[AIMessageTile.didUpdateWidget]";

    // 1. Stream Starting Logic
    final bool isStreamStarting = old.message.text.isEmpty && widget.message.text.isNotEmpty && widget.message.isThinking;

    if (isStreamStarting && !widget.message.isError) {
      debugPrint("$logPrefix Stream starting. Revealing header.");
      if (_thinkPulseCtl.isAnimating) _thinkPulseCtl.stop();
      if (_thinkRotateCtl.isAnimating) _thinkRotateCtl.stop();

      _thinkPulseCtl.animateTo(1.0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack);
      _thinkRotateCtl.animateTo(_thinkRotateCtl.value.roundToDouble(), duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      _headerEntryCtl.forward();
    }

    // 2. ERROR STATE HANDLING
    if (old.message.isError != widget.message.isError) {
      if (widget.message.isError) {
        debugPrint("$logPrefix Error detected. Halting thinking animations.");

        final bool hasContent = _stableText.isNotEmpty || widget.message.text.isNotEmpty;

        if (_thinkPulseCtl.isAnimating) _thinkPulseCtl.stop();
        if (_thinkRotateCtl.isAnimating) _thinkRotateCtl.stop();

        if (_textAnimCtl.isAnimating) {
          _textAnimCtl.stop();
          if (_animatingText.isNotEmpty) {
            _stableText += _animatingText;
            _animatingText = "";
          }
        }

        if (!hasContent) {
          _fadeCtl.reverse();
        } else {

        }

        _errorFadeOutCtl
          ..value = 0.0
          ..forward();

      } else {
        _errorFadeOutCtl.reverse();
        _fadeCtl.forward();
      }
    }

    // 3. Stream Finished Logic
    if (!widget.message.isError && old.message.isThinking && !widget.message.isThinking) {
      debugPrint("$logPrefix Stream finished successfully.");

      if (_thinkPulseCtl.isAnimating) _thinkPulseCtl.stop();
      if (_thinkRotateCtl.isAnimating) _thinkRotateCtl.stop();

      final double current = _thinkRotateCtl.value;
      double target = current.ceilToDouble();
      if ((target - current).abs() < 0.001) target += 1.0;

      _thinkRotateCtl.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuad,
      );

      if (!_headerEntryCtl.isCompleted) _headerEntryCtl.forward();
      if (_textAnimCtl.isAnimating) _textAnimCtl.stop();

      setState(() {
        _stableText = widget.message.text;
        _animatingText = "";
      });
      _textAnimCtl.value = 1.0;
    }

    // 4. Regeneration Logic
    if (!old.message.isThinking && widget.message.isThinking && !widget.message.isError) {
      debugPrint("$logPrefix Regeneration started.");
      _entryCtl.forward(from: 0);
      _headerEntryCtl.reverse();
      _stableText = "";
      _animatingText = "";
      _thinkPulseCtl.repeat(reverse: true);
      _thinkRotateCtl.repeat();
    }

    // 5. Text Update Logic
    if (!widget.message.isError && widget.message.text != old.message.text && widget.message.isThinking) {
      setState(() {
        if (_textAnimCtl.isAnimating) {
          _stableText += _animatingText;
        }

        if (_stableText.length < widget.message.text.length) {
          _animatingText = widget.message.text.substring(_stableText.length);
        } else {
          _stableText = widget.message.text;
          _animatingText = "";
          if (_textAnimCtl.isAnimating) _textAnimCtl.stop();
        }

        if (_animatingText.isNotEmpty) {
          final int newChars = _animatingText.length;
          const int msPerChar = 15;
          final newDuration = (newChars * msPerChar).clamp(150, 800);
          _textAnimCtl.duration = Duration(milliseconds: newDuration);
          _textAnimCtl.forward(from: 0.0);
        }
      });
    }

    // 6. Static Text Change
    else if (!widget.message.isError && widget.message.text != old.message.text && !widget.message.isThinking) {
      setState(() {
        _stableText = widget.message.text;
        _animatingText = "";
      });
      if (_textAnimCtl.isAnimating) _textAnimCtl.stop();
      _textAnimCtl.value = 1.0;
    }

    // 7. Opacity Updates
    if (old.message.opacity != widget.message.opacity && !widget.message.isError) {
      if (widget.message.opacity == 1.0) {
        _fadeCtl.forward();
      } else if (widget.message.opacity == 0.0) {
        _fadeCtl.reverse().whenComplete(() {
          widget.onFadeOutComplete?.call();
        });
      } else {
        _fadeCtl.value = widget.message.opacity;
      }
    }
  }

  void _onLongPress(BuildContext context, Offset pos) {
    showMessageOptions(
      context: context,
      tapPosition: pos,
      message: widget.message,
      onReport: widget.onReport,
      onRegenerate: widget.onRegenerate,
      onStop: widget.onStop,
    );
  }

  void _flushAnimation() {
    if (_textAnimCtl.isAnimating) {
      _textAnimCtl.stop();
      if(mounted) {
        setState(() {
          _stableText += _animatingText;
          _animatingText = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 400;
    if (widget.message.isError) return _buildErrorWidget(context, scale);

    return ScaleTransition(
      scale: _entryScaleAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: RawGestureDetector(
            behavior: HitTestBehavior.deferToChild,
            gestures: {
              ShortLongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<ShortLongPressGestureRecognizer>(
                    () => ShortLongPressGestureRecognizer(debugOwner: this, shortPressDuration: const Duration(milliseconds: 330)),
                    (inst) => inst.onLongPressStart = (d) => _onLongPress(context, d.globalPosition),
              ),
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                splashColor: AppColors.primaryColor.inverted.withValues(alpha:0.1),
                onTap: _flushAnimation,
                onLongPress: () {},
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(scale),
                      // ================== NEW & IMPROVED CONTENT AREA ==================
                      // Removed the problematic AnimatedSwitcher.
                      // This SizeTransition gracefully reveals the content area as the header animates in.
                      // It ensures the _buildContent widget is always in the tree during streaming,
                      // allowing it to update and render each new chunk.
                      SizeTransition(
                        sizeFactor: _headerEntryAnim,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8 * scale, left: 2.0 * scale),
                          child: _buildContent(scale),
                        ),
                      ),
                      // =================================================================
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

  Widget _buildHeader(double s) {
    final modelService = context.read<ModelService>();

    // 1. Get the current language code from the context.
    final langCode = Localizations.localeOf(context).languageCode;

    // 2. Fetch the type-safe ModelEntity using the provider.
    final model = modelService.getPreciseModelData(widget.message.model ?? '', langCode: langCode);

    // 3. Use the entity's properties directly.
    String? textToDisplay;
    if (model.category == 'self') {
      if (model.displayTitle.isNotEmpty) textToDisplay = model.displayTitle;
    } else {
      if (model.displayTitle.isNotEmpty) {
        textToDisplay = model.displayTitle;
      } else if (model.id.isNotEmpty) {
        textToDisplay = model.id;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _thinkPulseAnim,
          child: RotationTransition(
            turns: _thinkRotateCtl,
            child: SvgPicture.asset('assets/cortex.svg', width: 26 * s, height: 26 * s, colorFilter: const ColorFilter.matrix([-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0])),
          ),
        ),
        SizeTransition(
          sizeFactor: _headerEntryAnim,
          axis: Axis.horizontal,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _headerEntryAnim,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 8 * s),
                _buildAvatar(s * 0.7),
                if (textToDisplay != null && textToDisplay.isNotEmpty) ...[
                  SizedBox(width: 6 * s),
                  Text("•", style: TextStyle(color: AppColors.primaryColor.inverted.withValues(alpha:0.5), fontSize: 14 * s, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6 * s),
                  Text(
                    ModelDataUtils.formatModelName(textToDisplay),
                    style: TextStyle(color: AppColors.primaryColor.inverted.withValues(alpha:0.7), fontSize: 12 * s, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(double s) {
    final containerSize = 30 * s;
    final iconSize = 24 * s;
    final fallbackWidget = SvgPicture.asset('assets/icons/self.svg', width: iconSize, height: iconSize, fit: BoxFit.contain, colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn));
    Widget imageWidget;
    if (widget.avatarPath.isEmpty || widget.avatarPath.endsWith('self.svg')) {
      imageWidget = fallbackWidget;
    } else {
      final isSvg = widget.avatarPath.toLowerCase().endsWith('.svg');
      final isAsset = widget.avatarPath.startsWith('assets/');
      if (isSvg) {
        imageWidget = isAsset
            ? SvgPicture.asset(widget.avatarPath, width: iconSize, height: iconSize, fit: BoxFit.contain, placeholderBuilder: (_) => fallbackWidget)
            : SvgPicture.file(File(widget.avatarPath), width: iconSize, height: iconSize, fit: BoxFit.contain, placeholderBuilder: (_) => fallbackWidget);
      } else {
        final imageProvider = isAsset ? AssetImage(widget.avatarPath) as ImageProvider : FileImage(File(widget.avatarPath));
        imageWidget = Image(image: imageProvider, width: containerSize, height: containerSize, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallbackWidget);
      }
    }
    return Container(
      padding: EdgeInsets.all(1.5 * s),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryColor.inverted.withValues(alpha:0.2), width: 1.0)),
      child: Container(width: containerSize, height: containerSize, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: AppColors.secondaryColor, shape: BoxShape.circle), alignment: Alignment.center, child: imageWidget),
    );
  }

  Widget _buildContent(double s) {
    final baseStyle = TextStyle(fontSize: 16 * s, height: 1.35, color: AppColors.primaryColor.inverted);

    // If there's no text at all, render nothing.
    if (_stableText.isEmpty && _animatingText.isEmpty) {
      return const SizedBox.shrink();
    }

    // If not animating, just show the fully parsed, stable text.
    if (!_textAnimCtl.isAnimating && _animatingText.isEmpty) {
      return RichText(text: TextSpan(children: _getParsedSpans(_stableText), style: baseStyle));
    }

    // Otherwise, build the animated text.
    return AnimatedBuilder(
      animation: _textAnimCtl,
      builder: (context, child) {
        final animValue = _textAnimCtl.value;
        final opacity = animValue.clamp(0.0, 1.0);
        final sigma = (1.0 - opacity) * 2.0;
        return RichText(
          text: TextSpan(
            style: baseStyle,
            children: [
              ..._getParsedSpans(_stableText),
              if (_animatingText.isNotEmpty) ..._getParsedSpans(_animatingText).map((span) => _applyOpacityAndBlur(span, opacity, sigma)),
            ],
          ),
        );
      },
    );
  }

  List<InlineSpan> _getParsedSpans(String text) {
    if (text.isEmpty) return [];
    if (_parseCache.containsKey(text)) return _parseCache[text]!;

    final spans = parseText(context, text);

    if (text.length < 1000) _parseCache[text] = spans;
    return spans;
  }

  InlineSpan _applyOpacityAndBlur(InlineSpan span, double opacity, double sigma) {
    if (span is TextSpan) {
      final baseColor = span.style?.color ?? AppColors.primaryColor.inverted;
      final Paint foregroundPaint = Paint()..color = baseColor.withValues(alpha:opacity);
      if (sigma > 0.1) {
        foregroundPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
      }
      return TextSpan(
        text: span.text,
        children: span.children?.map((child) => _applyOpacityAndBlur(child, opacity, sigma)).toList(),
        style: span.style?.copyWith(foreground: foregroundPaint, color: null) ?? TextStyle(foreground: foregroundPaint),
      );
    } else if (span is WidgetSpan) {
      return WidgetSpan(alignment: span.alignment, baseline: span.baseline, child: Opacity(opacity: opacity, child: span.child));
    }
    return span;
  }

  Widget _buildErrorWidget(BuildContext context, double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dynamicFontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.06;
    return GestureDetector(
      onTap: () => setState(() {
        if (_isExpandedError) {
          _errorSlideCtl.reverse().then((_) { if (mounted) setState(() { _isExpandedError = false; _showErrorText = false; }); });
        } else {
          _isExpandedError = true;
          _errorSlideCtl.forward().whenComplete(() { if (mounted) setState(() => _showErrorText = true); });
        }
      }),
      child: FadeTransition(
        opacity: _errorFadeOutAnim,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Container(
            decoration: BoxDecoration(color: AppColors.septenaryColor.withValues(alpha:0.3), borderRadius: BorderRadius.circular(screenWidth * 0.03), border: Border.all(color: AppColors.septenaryColor, width: 0.5)),
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.septenaryColor,
                      size: iconSize,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.requestFailed,
                        style: TextStyle(
                          color: AppColors.septenaryColor,
                          fontSize: dynamicFontSize,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpandedError ? 0.50 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuad,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.septenaryColor,
                        size: iconSize,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuad,
                  alignment: Alignment.topCenter,
                  child: !_isExpandedError ? const SizedBox.shrink() : ClipRect(
                    child: AnimatedOpacity(
                      opacity: _showErrorText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: SlideTransition(
                        position: _errorSlideAnim,
                        child: Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.02),
                          child: SelectableText(widget.message.text, style: TextStyle(color: AppColors.septenaryColor, fontSize: dynamicFontSize * 0.9)),
                        ),
                      ),
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