// =================================================================
// ai.dart
// =================================================================

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../recognizer.dart';
import '../../../theme.dart';
import '../../providers/conversation.dart';
import '../../providers/session.dart';
import '../options.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../parser.dart';

class AIMessageTile extends StatefulWidget {
  const AIMessageTile({
    super.key,
    required this.text,
    required this.avatarPath,
    required this.opacity,
    required this.modelId,
    required this.isReported,
    this.isError = false,
    this.onFadeOutComplete,
    this.onReport,
    this.onRegenerate,
    this.parsedSpans,
    this.onStop,
    this.onChangeModel,
    this.isThinking = false,
    required this.isPersistentlyDynamic,
  });

  final String text;
  final String avatarPath;
  final double opacity;
  final String modelId;
  final bool isReported;
  final bool isError;
  final VoidCallback? onFadeOutComplete;
  final VoidCallback? onReport;
  final VoidCallback? onRegenerate;
  final List<InlineSpan>? parsedSpans;
  final VoidCallback? onStop;
  final ValueChanged<String>? onChangeModel;
  final bool isThinking;
  final bool isPersistentlyDynamic;

  @override
  State<AIMessageTile> createState() => _AIMessageTileState();
}

class _AIMessageTileState extends State<AIMessageTile> with TickerProviderStateMixin {
  // NEW: Controller for the initial appearance (entry) animation of the tile
  late final AnimationController _entryCtl;
  late final Animation<double> _entryScaleAnim;

  // Main fade controller for the entire tile
  late final AnimationController _fadeCtl;
  late final Animation<double> _fadeAnim;

  // Thinking animations (Pulse & Rotate)
  late final AnimationController _thinkPulseCtl;
  late final Animation<double> _thinkPulseAnim;
  late final AnimationController _thinkRotateCtl;

  // Header entry animation (Avatar + Model Name fade-in)
  late final AnimationController _headerEntryCtl;
  late final Animation<double> _headerEntryAnim;

  // Simplified text streaming animation
  late final AnimationController _textAnimCtl;
  String _stableText = "";
  String _animatingText = "";

  // Error state animations
  bool _isExpandedError = false;
  bool _showErrorText = false;
  late AnimationController _errorSlideCtl;
  late Animation<Offset> _errorSlideAnim;
  late AnimationController _errorFadeOutCtl;
  late Animation<double> _errorFadeOutAnim;

  // Cache for parsed markdown to improve performance
  final Map<String, List<InlineSpan>> _parseCache = {};

  /// Formats a raw model ID string into a display-friendly format.
  /// - Capitalizes the first letter of each word.
  /// - Converts specific acronyms and parameters (e.g., "gpt" -> "GPT", "7b" -> "7B").
  /// - Converts "ai" within words to "AI" without adding a space (e.g., "openai" -> "OpenAI").
  ///
  /// Example: "openai/gpt-4o" -> "OpenAI GPT 4o"
  /// Example: "google/gemma-7b" -> "Google Gemma 7B"
  /// Example: "stabilityai/sdxl" -> "StabilityAI Sdxl"
  String _formatModelIdForDisplay(String rawId) {
    if (rawId.isEmpty) {
      return "";
    }
    String spacedId = rawId.replaceAll('/', ' ').replaceAll('-', ' ');
    List<String> parts = spacedId.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return "";
    }

    List<String> formattedParts = [];

    for (String segment in parts) {
      String segmentLower = segment.toLowerCase();
      String formattedSegment;

      // Priority 1: Handle full-word acronyms and parameters
      if (segmentLower == 'gpt') {
        formattedSegment = 'GPT';
      } else if (segmentLower == 'ai') {
        formattedSegment = 'AI';
      } else if (segment.length > 1 && segmentLower.endsWith('b') && int.tryParse(segment.substring(0, segment.length - 1)) != null) {
        formattedSegment = '${segment.substring(0, segment.length - 1)}B';
      }
      // Priority 2: General case for all other words
      else {
        // Step 1: Capitalize the first letter of the word.
        formattedSegment = segment[0].toUpperCase() + segment.substring(1).toLowerCase();

        // Step 2: If the original word ended with "ai", correct the suffix.
        // This turns "Openai" into "OpenAI".
        if (segmentLower.endsWith('ai')) {
          formattedSegment = formattedSegment.substring(0, formattedSegment.length - 2) + 'AI';
        }
      }
      formattedParts.add(formattedSegment);
    }
    return formattedParts.join(' ');
  }

  @override
  void initState() {
    super.initState();

    _entryCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _entryScaleAnim = CurvedAnimation(parent: _entryCtl, curve: Curves.elasticOut);

    _fadeCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeCtl, curve: Curves.easeOut));

    _thinkPulseCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _thinkPulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _thinkPulseCtl, curve: Curves.easeInOut));
    _thinkRotateCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000));

    if (widget.isThinking && !widget.isError) {
      _thinkPulseCtl.repeat(reverse: true);
      _thinkRotateCtl.repeat();
      _entryCtl.forward(); // Play entry animation if it starts as "thinking"
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

    _errorSlideCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _errorSlideAnim = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(CurvedAnimation(parent: _errorSlideCtl, curve: Curves.easeOutQuad));
    _errorFadeOutCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _errorFadeOutAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_errorFadeOutCtl);

    if (widget.isError) {
      _errorFadeOutCtl.value = 1.0;
      _fadeCtl.value = 0.0;
    } else {
      _errorFadeOutCtl.value = 0.0;
      if (widget.opacity == 1) {
        _fadeCtl.forward(from: 0);
      } else {
        _fadeCtl.value = widget.opacity;
      }
    }

    if (!widget.isThinking && widget.text.isNotEmpty) {
      _stableText = widget.text;
      _headerEntryCtl.value = 1.0;
      _entryCtl.value = 1.0; // If not thinking, it's already "entered"
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

    // Transition from Thinking -> Not Thinking
    if (old.isThinking && !widget.isThinking) {
      _thinkPulseCtl.stop();
      _thinkRotateCtl.stop();
      // ENHANCED: Use easeOutBack curve for a satisfying "pop" when settling.
      _thinkPulseCtl.animateTo(1.0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack);
      // FIXED: Use .roundToDouble() to ensure the target is a double, not an int.
      _thinkRotateCtl.animateTo(_thinkRotateCtl.value.roundToDouble(), duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      _headerEntryCtl.forward();
    }

    // Transition from Not Thinking -> Thinking (for regeneration)
    if (!old.isThinking && widget.isThinking) {
      _entryCtl.forward(from: 0); // Play the entry animation on regenerate
      _headerEntryCtl.reverse();
      _stableText = "";
      _animatingText = "";
      _thinkPulseCtl.repeat(reverse: true);
      _thinkRotateCtl.repeat();
    }

    // Dynamic & Smooth Text Animation Logic
    if (widget.text.length > old.text.length) {
      if (_textAnimCtl.isAnimating) {
        _stableText += _animatingText;
      }
      _stableText = old.text;
      _animatingText = widget.text.substring(old.text.length);

      final int newChars = _animatingText.length;
      const int msPerChar = 12;
      const int minDuration = 100;
      const int maxDuration = 600;
      final newDuration = (newChars * msPerChar).clamp(minDuration, maxDuration);

      _textAnimCtl.duration = Duration(milliseconds: newDuration);
      _textAnimCtl.forward(from: 0);

    } else if (widget.text != old.text && !widget.isThinking) {
      _stableText = widget.text;
      _animatingText = "";
      if (_textAnimCtl.isAnimating) _textAnimCtl.stop();
      _textAnimCtl.value = 1.0;
    }

    if (old.isError != widget.isError) {
      if (widget.isError) {
        _fadeCtl.reverse();
        _errorFadeOutCtl.forward();
      } else {
        _errorFadeOutCtl.reverse();
        _fadeCtl.forward();
      }
    }

    if (old.opacity != widget.opacity && !widget.isError) {
      if (widget.opacity == 1.0) {
        _fadeCtl.forward();
      } else if (widget.opacity == 0.0) {
        _fadeCtl.reverse().whenComplete(() {
          widget.onFadeOutComplete?.call();
        });
      } else {
        _fadeCtl.value = widget.opacity;
      }
    }
  }

  void _onLongPress(BuildContext ctx, Offset pos) {
    final conversationProvider = ctx.read<ConversationProvider>();
    final sessionProvider = ctx.read<ChatSessionProvider>();
    final conversationHasPhoto = conversationProvider.messages.any((m) => m.photoPath?.isNotEmpty ?? false);
    final isUserSubscribed = sessionProvider.isUserSubscribed;
    final premiumTrialUses = sessionProvider.premiumTrialUses;
    final aiMessageOptions = [MessageOption.copy, MessageOption.select];
    if (!widget.isError) {
      aiMessageOptions.addAll([MessageOption.regenerate, MessageOption.changeModel]);
      if (!widget.isReported) aiMessageOptions.add(MessageOption.report);
    } else {
      aiMessageOptions.add(MessageOption.regenerate);
    }
    showMessageOptions(
      context: ctx,
      tapPosition: pos,
      messageText: widget.text,
      messageNotifier: ValueNotifier<String>(widget.text),
      options: aiMessageOptions,
      isReported: widget.isReported,
      onReport: widget.onReport,
      onRegenerate: widget.onRegenerate,
      onChangeModel: widget.onChangeModel,
      modelIdAndExtension: widget.modelId,
      conversationHasPhoto: conversationHasPhoto,
      isSubscribed: isUserSubscribed,
      premiumTrialUses: premiumTrialUses,
      isPersistentlyDynamic: widget.isPersistentlyDynamic,
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
    if (widget.isError) return _buildErrorWidget(context, scale);

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
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, child: child)),
                        child: !widget.isThinking
                            ? Padding(
                          key: const ValueKey('content'),
                          padding: EdgeInsets.only(top: 8 * scale, left: 2.0 * scale),
                          child: _buildContent(scale),
                        )
                            : const SizedBox.shrink(key: ValueKey('thinking')),
                      )
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _thinkPulseAnim,
          child: RotationTransition(
            turns: _thinkRotateCtl,
            child: SvgPicture.asset('assets/cortex.svg', width: 26 * s, height: 26 * s, colorFilter: const ColorFilter.matrix([
              -1, 0, 0, 0, 255,
              0,-1, 0, 0, 255,
              0, 0,-1, 0, 255,
              0, 0, 0, 1, 0,
            ])),
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
                SizedBox(width: 6 * s),
                Text("•", style: TextStyle(color: AppColors.primaryColor.inverted.withValues(alpha:0.5), fontSize: 14 * s, fontWeight: FontWeight.bold)),
                SizedBox(width: 6 * s),
                Text(_formatModelIdForDisplay(widget.modelId), style: TextStyle(color: AppColors.primaryColor.inverted.withValues(alpha:0.7), fontSize: 12 * s, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
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
    if (!_textAnimCtl.isAnimating && _animatingText.isEmpty) {
      if(widget.text.isEmpty) return const SizedBox.shrink();
      return RichText(text: TextSpan(children: _getParsedSpans(widget.text), style: baseStyle));
    }
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
    final spans = parseText(text);
    if (text.length < 1000) _parseCache[text] = spans;
    return spans;
  }

  InlineSpan _applyOpacityAndBlur(InlineSpan span, double opacity, double sigma) {
    if (span is TextSpan) {
      final baseColor = span.style?.color ?? AppColors.primaryColor.inverted;
      final Paint foregroundPaint = Paint()..color = baseColor.withValues(alpha:opacity);
      if (sigma > 0.1) foregroundPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
      return TextSpan(
        text: span.text,
        children: span.children?.map((child) => _applyOpacityAndBlur(child, opacity, sigma)).toList(),
        style: span.style?.copyWith(foreground: foregroundPaint) ?? TextStyle(foreground: foregroundPaint),
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
                    Icon(Icons.error_outline, color: AppColors.septenaryColor, size: iconSize),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(child: Text(AppLocalizations.of(context)!.requestFailed, style: TextStyle(color: AppColors.septenaryColor, fontSize: dynamicFontSize))),
                    AnimatedRotation(
                      turns: _isExpandedError ? 0.50 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuad,
                      child: SvgPicture.asset('assets/icons/cortex.svg', width: iconSize, height: iconSize, colorFilter: ColorFilter.mode(AppColors.septenaryColor, BlendMode.srcIn)),
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
                          child: SelectableText(widget.text, style: TextStyle(color: AppColors.septenaryColor, fontSize: dynamicFontSize * 0.9)),
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