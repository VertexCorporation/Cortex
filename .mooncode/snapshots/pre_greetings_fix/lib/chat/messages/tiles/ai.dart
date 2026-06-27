import 'dart:io';
import 'package:cortex/app.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../library/utils.dart';
import '../../../theme.dart';
import '../messages.dart';
import 'package:cortex/chat/messages/markdown/parser.dart';
import 'package:cortex/l10n/app_localizations.dart';

import 'package:flutter/services.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/server/credits.dart';
import '../../../notifications/introvert.dart';
import '../options/change.dart';
import '../options/panel.dart';
import 'package:cortex/chat/services/tts.dart';
import 'package:cortex/arts/provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:pasteboard/pasteboard.dart';

part 'ai/error.dart';

part 'ai/header.dart';

part 'ai/content.dart';

part 'ai/options.dart';

class AiStreamFinishedNotification extends Notification {
  const AiStreamFinishedNotification();
}

class AIMessageTile extends StatefulWidget {
  final Message message;
  final String avatarPath;
  final Widget? embeddedMedia;
  final bool mediaAboveText;
  final VoidCallback? onFadeOutComplete;
  final VoidCallback? onReport;
  final void Function({String? newModelId})? onRegenerate;
  final VoidCallback? onStop;
  final List<InlineSpan>? parsedSpans;

  const AIMessageTile({
    super.key,
    required this.message,
    required this.avatarPath,
    this.embeddedMedia,
    this.mediaAboveText = true,
    this.onFadeOutComplete,
    this.onReport,
    this.onRegenerate,
    this.onStop,
    this.parsedSpans,
  });

  @override
  State<AIMessageTile> createState() => _AIMessageTileState();
}

class _AIMessageTileState extends State<AIMessageTile>
    with TickerProviderStateMixin {
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

  String _stableText = "";
  String _animatingText = "";

  final Map<String, List<InlineSpan>> _parseCache = {};

  late bool _isInitialLoad;

  @override
  void initState() {
    super.initState();
    _isInitialLoad = !widget.message.isThinking && !widget.message.isError;
    _entryCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _entryScaleAnim =
        CurvedAnimation(parent: _entryCtl, curve: Curves.elasticOut);
    _fadeCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeCtl, curve: Curves.easeOut),
    );
    _thinkPulseCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _thinkPulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _thinkPulseCtl, curve: Curves.easeInOut),
    );
    _thinkRotateCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000));

    if (widget.message.isThinking && !widget.message.isError) {
      _thinkPulseCtl.repeat(reverse: true);
      _thinkRotateCtl.repeat();
      _entryCtl.forward();
    }

    _headerEntryCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _headerEntryAnim =
        CurvedAnimation(parent: _headerEntryCtl, curve: Curves.easeOut);

    _textAnimCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));

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

    if (widget.message.isThinking &&
        !widget.message.isError &&
        (widget.message.displayableText.isNotEmpty ||
            widget.embeddedMedia != null)) {
      _headerEntryCtl.forward();
    }

    if (widget.message.isError) {
      _fadeCtl.value = 0.0;
    } else {
      if (widget.message.opacity == 1) {
        _fadeCtl.forward(from: 0);
      } else {
        _fadeCtl.value = widget.message.opacity;
      }
    }

    if (!widget.message.isThinking &&
        (widget.message.displayableText.isNotEmpty ||
            widget.message.hasAttachments ||
            widget.embeddedMedia != null)) {
      _stableText = widget.message.displayableText;
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
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AIMessageTile old) {
    super.didUpdateWidget(old);
    final String logPrefix = "[AIMessageTile.didUpdateWidget]";

    // 1. Stream Starting Logic
    final bool isStreamStarting =
        (old.message.displayableText.isEmpty && old.embeddedMedia == null) &&
            (widget.message.displayableText.isNotEmpty ||
                widget.embeddedMedia != null) &&
            widget.message.isThinking;

    if (isStreamStarting && !widget.message.isError) {
      debugPrint("$logPrefix Stream starting. Revealing header.");
      if (_thinkPulseCtl.isAnimating) _thinkPulseCtl.stop();
      if (_thinkRotateCtl.isAnimating) _thinkRotateCtl.stop();

      _thinkPulseCtl.animateTo(1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack);
      _thinkRotateCtl.animateTo(_thinkRotateCtl.value.roundToDouble(),
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      _headerEntryCtl.forward();
    }

    // 2. ERROR STATE HANDLING
    if (old.message.isError != widget.message.isError) {
      if (widget.message.isError) {
        debugPrint("$logPrefix Error detected. Halting thinking animations.");

        final bool hasContent = widget.message.displayableText.isNotEmpty;

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
        }
      } else {
        _fadeCtl.forward();
      }
    }

    // 3. Stream Finished Logic
    if (!widget.message.isError &&
        old.message.isThinking &&
        !widget.message.isThinking) {
      debugPrint("$logPrefix Stream finished successfully.");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          const AiStreamFinishedNotification().dispatch(context);
          if (widget.message.hasAttachments) {
            Provider.of<ArtsProvider>(context, listen: false).loadMedia();
          }
        }
      });

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
        _stableText = widget.message.displayableText;
        _animatingText = "";
      });
      _textAnimCtl.value = 1.0;
    }

    // 4. Regeneration Logic
    if (!old.message.isThinking &&
        widget.message.isThinking &&
        !widget.message.isError) {
      debugPrint("$logPrefix Regeneration started.");
      _entryCtl.forward(from: 0);
      _headerEntryCtl.reverse();
      _stableText = "";
      _animatingText = "";
      _thinkPulseCtl.repeat(reverse: true);
      _thinkRotateCtl.repeat();
    }

    // 5. Text Update Logic
    if (!widget.message.isError &&
        widget.message.displayableText != old.message.displayableText &&
        widget.message.isThinking) {
      setState(() {
        if (_textAnimCtl.isAnimating) {
          _stableText += _animatingText;
        }

        if (_stableText.length < widget.message.displayableText.length) {
          _animatingText =
              widget.message.displayableText.substring(_stableText.length);
        } else {
          _stableText = widget.message.displayableText;
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
    else if (!widget.message.isError &&
        widget.message.displayableText != old.message.displayableText &&
        !widget.message.isThinking) {
      setState(() {
        _stableText = widget.message.displayableText;
        _animatingText = "";
      });
      if (_textAnimCtl.isAnimating) _textAnimCtl.stop();
      _textAnimCtl.value = 1.0;
    }

    // 5. Opacity Updates
    if (old.message.opacity != widget.message.opacity &&
        !widget.message.isError) {
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

  void _flushAnimation() {
    if (_textAnimCtl.isAnimating) {
      _textAnimCtl.stop();
      if (mounted) {
        setState(() {
          _stableText += _animatingText;
          _animatingText = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = screenWidth / 400;

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: widget.message.isError
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: _buildErrorOnlyTile(context, scale),
      secondChild: _buildStandardTile(context, scale),
    );
  }

  Widget _buildErrorOnlyTile(BuildContext context, double scale) {
    return ScaleTransition(
      scale: _entryScaleAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 8 * scale),
                  child: _AiErrorWidget(
                    message: widget.message,
                    scale: scale,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardTile(BuildContext context, double scale) {
    return ScaleTransition(
      scale: _entryScaleAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: _flushAnimation,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AiHeader(
                    message: widget.message,
                    avatarPath: widget.avatarPath,
                    scale: scale,
                    thinkPulseAnim: _thinkPulseAnim,
                    thinkRotateAnim: _thinkRotateCtl,
                    headerEntryAnim: _headerEntryAnim,
                  ),
                  SizeTransition(
                    sizeFactor: _headerEntryAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AiBodyContent(
                          message: widget.message,
                          embeddedMedia: widget.embeddedMedia,
                          mediaAboveText: widget.mediaAboveText,
                          stableText: _stableText,
                          animatingText: _animatingText,
                          textAnimCtl: _textAnimCtl,
                          scale: scale,
                          parseCache: _parseCache,
                        ),
                        _InlineOptionsRow(
                          message: widget.message,
                          onReport: widget.onReport,
                          onRegenerate: widget.onRegenerate,
                          scale: scale,
                        ),
                        if (widget.message.isServerFallback && _isInitialLoad)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 8 * scale,
                                  left: 12 * scale,
                                  right: 12 * scale),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 2 * scale),
                                    child: SvgPicture.asset(
                                      'assets/icons/warning.svg',
                                      width: 12 * scale,
                                      height: 12 * scale,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.primaryColor.inverted
                                            .withValues(alpha: 0.5),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8 * scale),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .fallbackInfoPanelText,
                                      style: TextStyle(
                                        fontSize: 11 * scale,
                                        color: AppColors.primaryColor.inverted
                                            .withValues(alpha: 0.5),
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
