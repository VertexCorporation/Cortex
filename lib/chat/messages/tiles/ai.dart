// ai.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../recognizer.dart';
import '../../../theme.dart';
import '../../chat.dart';
import '../options.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../parser.dart';

class AIMessageTile extends StatefulWidget {
  const AIMessageTile({
    super.key,
    required this.text,
    required this.imagePath,
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
  });

  final String text;
  final String imagePath;
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

  @override
  State<AIMessageTile> createState() => _AIMessageTileState();
}

class _AIMessageTileState extends State<AIMessageTile>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtl;
  late final Animation<double> _fadeAnim;

  late final AnimationController _typeCtl;
  static const int _durPerBatch = 50;
  static const int _fadeDur = 200;
  static const int _minBatch = 5;

  String _text = '';
  late final ValueNotifier<bool> _thinkNtf;
  late String _curModelId;
  int _staticCharCount = 0;
  List<String> _batches = [];

  Timer? _parseTimer;
  String _chunkBuffer = '';

  bool _isExpanded = false;
  bool _showText = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeOutController;
  late Animation<double> _fadeOutAnimation;

  final Map<String, List<InlineSpan>> _parseCache = {};

  @override
  void initState() {
    super.initState();
    _curModelId = widget.modelId;

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuad),
    );
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeOutAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeOutController);

    _fadeCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_fadeCtl);

    if (widget.isError) {
      _fadeOutController.value = 1.0;
      _fadeCtl.value = 0.0;
    } else {
      _fadeOutController.value = 0.0;
      if (widget.opacity == 1) {
        _fadeCtl.forward(from: 0);
      } else {
        _fadeCtl.reverse(from: 1);
      }
    }

    _typeCtl = AnimationController(vsync: this);
    _text = widget.text;
    _staticCharCount = _text.length;
    _thinkNtf = ValueNotifier(widget.isThinking);

    if (_text.isNotEmpty) {
      _typeCtl.duration = const Duration(milliseconds: 1);
      _typeCtl.value = 1;
    }

    _parseTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_typeCtl.isAnimating || _chunkBuffer.isNotEmpty) {
        if (mounted) {
          setState(() {});
        }
      }
    });

    _typeCtl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() {});
      }
    });

    if (_text.isNotEmpty) _recomputeBatches();
  }

  void _recomputeBatches() {
    _batches = [];
    if (_text.isEmpty) return;
    for (var i = 0; i < _text.length; i += _minBatch) {
      _batches.add(_text.substring(i, math.min(i + _minBatch, _text.length)));
    }
  }

  void _onChunk(String textToAdd) {
    if (textToAdd.isEmpty || widget.isError) return;

    final bool wasAnimating = _typeCtl.isAnimating;

    if (!wasAnimating) {
      _staticCharCount = _text.length;
      _batches.clear();
    }

    _text += textToAdd;

    final newBatchSize = (textToAdd.length / 2).ceil().clamp(_minBatch, 100);
    final List<String> newBatches = [];
    for (var i = 0; i < textToAdd.length; i += newBatchSize) {
      newBatches.add(
          textToAdd.substring(i, math.min(i + newBatchSize, textToAdd.length))
      );
    }

    _batches.addAll(newBatches);

    final newDur = (_batches.length * _durPerBatch) + _fadeDur;
    _typeCtl.duration = Duration(milliseconds: newDur);

    if (!wasAnimating) {
      _typeCtl.forward(from: 0);
    }
  }

  void _flushRemaining() {
    _parseTimer?.cancel();
    if (_chunkBuffer.isNotEmpty) {
      _onChunk(_chunkBuffer);
      _chunkBuffer = '';
    }

    if (!_typeCtl.isAnimating) return;
    final remain = ((1 - _typeCtl.value) * (_typeCtl.duration!.inMilliseconds))
        .clamp(0, 120)
        .toInt();
    _typeCtl.animateTo(
        1, duration: Duration(milliseconds: remain), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _parseTimer?.cancel();
    _fadeCtl.dispose();
    _typeCtl.dispose();
    _thinkNtf.dispose();
    _slideController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AIMessageTile old) {
    super.didUpdateWidget(old);

    if (!old.isThinking && widget.isThinking) {
      _parseTimer?.cancel();
      _chunkBuffer = '';
      _text = '';
      _staticCharCount = 0;
      _batches.clear();
      if(_typeCtl.isAnimating) _typeCtl.stop();
      _typeCtl.value = 1;
    }

    if (old.isThinking != widget.isThinking) {
      _thinkNtf.value = widget.isThinking;
    }

    if (old.modelId != widget.modelId) {
      _curModelId = widget.modelId;
    }

    if (!widget.isError && widget.text.length > _text.length) {
      final newChunk = widget.text.substring(_text.length);

      if (old.isThinking && !widget.isThinking) {
        _parseTimer?.cancel();
        _chunkBuffer = '';
        _onChunk(newChunk);
      }
      else if (!widget.isThinking) {
        _chunkBuffer += newChunk;
        _parseTimer?.cancel();
        _parseTimer = Timer(const Duration(milliseconds: 50), () {
          if (_chunkBuffer.isNotEmpty && mounted) {
            final textToProcess = _chunkBuffer;
            _chunkBuffer = '';
            _onChunk(textToProcess);
          }
        });
      }
    }

    if (old.isError != widget.isError) {
      if (widget.isError) {
        _parseTimer?.cancel();
        _chunkBuffer = '';
        _fadeCtl.reverse();
        _fadeOutController.forward();
        if (_typeCtl.isAnimating) _typeCtl.stop();
        if (widget.isThinking) _thinkNtf.value = false;
      } else {
        _fadeOutController.reverse();
        _fadeCtl.forward();

        if (widget.text.isNotEmpty && !widget.isThinking) {
          _text = '';
          _staticCharCount = 0;
          _onChunk(widget.text);
        }
      }
    } else if (old.opacity != widget.opacity) {
      final controller = widget.isError ? _fadeOutController : _fadeCtl;
      if (widget.opacity == 1) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }
  }

  void _onLongPress(BuildContext ctx, Offset pos) {
    final chatState = ctx.findAncestorStateOfType<ChatScreenState>();
    if (chatState == null) return;

    final conversationHasPhoto = chatState.messages.any((m) =>
    m.photoPath?.isNotEmpty ?? false);

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
      isWaitingForResponseNotifier: chatState.isWaitingForResponseNotifier,
      isReported: widget.isReported,
      onReport: widget.onReport,
      onRegenerate: widget.onRegenerate,
      onChangeModel: widget.onChangeModel,
      modelIdAndExtension: _curModelId,
      conversationHasPhoto: conversationHasPhoto,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 400;

    if (widget.isError) {
      return _buildErrorWidget(context, scale);
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: RawGestureDetector(
          behavior: HitTestBehavior.deferToChild,
          gestures: {
            ShortLongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                ShortLongPressGestureRecognizer>(
                  () =>
                  ShortLongPressGestureRecognizer(debugOwner: this,
                      shortPressDuration: const Duration(milliseconds: 330)),
                  (inst) =>
              inst.onLongPressStart =
                  (d) => _onLongPress(context, d.globalPosition),
            ),
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              splashColor: AppColors.primaryColor.inverted.withOpacity(0.1),
              onTap: _flushRemaining,
              onLongPress: () {},
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_typeCtl, _thinkNtf]),
                  builder: (ctx, _) =>
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _avatar(scale),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(child: _content(context, scale)),
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

  Widget _buildErrorWidget(BuildContext context, double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.02;
    final dynamicBorderRadius = screenWidth * 0.03;
    final containerPadding = screenWidth * 0.03;
    final dynamicFontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.06;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_isExpanded) {
            _showText = false;
            _slideController.reverse().then((_) {
              if (mounted) setState(() => _isExpanded = false);
            });
          } else {
            _isExpanded = true;
            _slideController.forward().whenComplete(() {
              if (mounted) setState(() => _showText = true);
            });
          }
        });
      },
      child: FadeTransition(
        opacity: _fadeOutAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.septenaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(dynamicBorderRadius),
              border: Border.all(color: AppColors.septenaryColor, width: 0.5),
            ),
            padding: EdgeInsets.all(containerPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.septenaryColor, size: iconSize),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.requestFailed,
                        style: TextStyle(color: AppColors.septenaryColor, fontSize: dynamicFontSize),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.50 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuad,
                      child: SvgPicture.asset('assets/icons/arrov.svg', width: iconSize, height: iconSize, color: AppColors.septenaryColor),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuad,
                  alignment: Alignment.topCenter,
                  child: _isExpanded
                      ? ClipRect(
                    child: AnimatedOpacity(
                      opacity: _showText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.02),
                          child: SelectableText(
                            widget.text,
                            style: TextStyle(color: AppColors.septenaryColor, fontSize: dynamicFontSize * 0.9),
                          ),
                        ),
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(double s) {
    final containerSize = 30 * s;
    final iconSize = 24 * s;

    // --- THE PERFECT FIX IS HERE ---

    // 1. Create the correctly colored fallback widget ONCE.
    final fallbackWidget = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(15 * s),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/icons/self.svg',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
      ),
    );

    // 2. Handle the logic to decide which widget to show.
    Widget imageWidget;
    if (widget.imagePath.isEmpty || widget.imagePath.endsWith('self.svg')) {
      // If path is empty OR it's the self.svg, ALWAYS use our colored fallback.
      imageWidget = fallbackWidget;
    } else {
      // For any other image path, try to load it.
      final isSvg = widget.imagePath.toLowerCase().endsWith('.svg');
      final isAsset = widget.imagePath.startsWith('assets/');

      if (isSvg) {
        imageWidget = isAsset
            ? SvgPicture.asset(widget.imagePath, width: iconSize, height: iconSize, fit: BoxFit.contain, placeholderBuilder: (_) => fallbackWidget)
            : SvgPicture.file(File(widget.imagePath), width: iconSize, height: iconSize, fit: BoxFit.contain, placeholderBuilder: (_) => fallbackWidget);
      } else {
        final imageProvider = isAsset ? AssetImage(widget.imagePath) as ImageProvider : FileImage(File(widget.imagePath));
        imageWidget = Image(
          image: imageProvider,
          width: containerSize,
          height: containerSize,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallbackWidget,
        );
      }
    }
    // --- END OF FIX ---

    // 3. Return the final widget inside the main container.
    return Container(
      width: containerSize,
      height: containerSize,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(15 * s),
      ),
      alignment: Alignment.center,
      child: imageWidget,
    );
  }

  InlineSpan _applyOpacity(InlineSpan span, double op, double sigma) {
    if (span is TextSpan) {
      final basePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = (span.style?.color ?? AppColors.primaryColor.inverted).withOpacity(op)
        ..maskFilter = sigma > 0 ? MaskFilter.blur(BlurStyle.normal, sigma) : null;
      return TextSpan(
        text: span.text,
        children: span.children,
        style: span.style?.copyWith(foreground: basePaint) ?? TextStyle(foreground: basePaint),
      );
    } else if (span is WidgetSpan) {
      return WidgetSpan(
        alignment: span.alignment,
        baseline: span.baseline,
        child: Opacity(opacity: op, child: span.child),
      );
    }
    return span;
  }

  Widget _content(BuildContext ctx, double s) {
    final base = TextStyle(fontSize: 16 * s, height: 1.35, color: AppColors.primaryColor.inverted);

    if (_thinkNtf.value && _text.isEmpty && !widget.isError) {
      return Shimmer.fromColors(
        baseColor: base.color!,
        highlightColor: AppColors.quaternaryColor,
        child: Text(AppLocalizations.of(ctx)!.thinking, style: base.copyWith(fontWeight: FontWeight.bold)),
      );
    }

    List<InlineSpan> getParsedSpans(String text) {
      if (_parseCache.containsKey(text)) {
        return _parseCache[text]!;
      }
      final spans = parseText(text);
      _parseCache[text] = spans;
      return spans;
    }

    if (!_typeCtl.isAnimating && _text.isNotEmpty) {
      return RichText(text: TextSpan(children: parseText(_text), style: base));
    }

    final tot = _typeCtl.duration!.inMilliseconds;
    final t = _typeCtl.value * tot;
    final spans = <InlineSpan>[];

    if (_staticCharCount > 0) {
      spans.addAll(getParsedSpans(_text.substring(0, _staticCharCount)));
    }

    for (var idx = 0; idx < _batches.length; idx++) {
      final seg = _batches[idx];
      final start = idx * _durPerBatch;
      final end = start + _fadeDur;
      final op = t < start ? 0.0 : (t >= end ? 1.0 : (t - start) / _fadeDur);
      final sigma = 3 * (1 - op);

      for (final span in getParsedSpans(seg)) {
        spans.add(_applyOpacity(span, op, sigma));
      }
    }

    if (spans.isEmpty) return const SizedBox.shrink();
    return RichText(text: TextSpan(children: spans, style: base));
  }
}