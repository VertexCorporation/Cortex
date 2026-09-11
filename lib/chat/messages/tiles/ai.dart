import 'package:cortex/design.dart';
import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'ai/reveal_timeline.dart';
import 'ai/reveal_text.dart';
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
import 'package:cortex/chat/screen/widgets/thinking.dart';
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

/// Sent while the visual reveal grows so the message list can keep the latest
/// revealed line visible without taking control away from a user scrolling up.
class AiMessageRevealNotification extends Notification {
  const AiMessageRevealNotification();
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
  // "Continue generating" affordance for server-reported truncated responses
  // (`isIncomplete`). Rendered inside the truncation notice when provided.
  final VoidCallback? onContinue;

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
    this.onContinue,
  });

  @override
  State<AIMessageTile> createState() => _AIMessageTileState();
}

class _AIMessageTileState extends State<AIMessageTile>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtl;
  late final Animation<double> _entryScaleAnim;
  late final AnimationController _fadeCtl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _thinkPulseCtl;
  late final Animation<double> _thinkPulseAnim;
  late final AnimationController _thinkRotateCtl;
  late final AnimationController _headerEntryCtl;
  late final Animation<double> _headerEntryAnim;
  late final AnimationController _regenerationExitCtl;
  late final Animation<double> _regenerationExitAnim;
  late final RevealTimeline _reveal;
  late final Ticker _revealTicker;
  Duration _previousFrame = Duration.zero;
  bool _finishNotificationSent = false;
  bool _completionScheduled = false;
  bool _isRegenerating = false;
  String _pendingRegenerationText = '';
  bool _pendingRegenerationComplete = false;
  Message? _regenerationMessage;
  Widget? _regenerationEmbeddedMedia;
  bool get _visualComplete => _reveal.visualComplete;

  final Map<String, List<InlineSpan>> _parseCache = {};

  late bool _isInitialLoad;

  @override
  void initState() {
    super.initState();
    _isInitialLoad = !widget.message.isThinking && !widget.message.isError;
    _reveal = RevealTimeline()
      ..reset(widget.message.displayableText,
          complete: !widget.message.isThinking,
          showImmediately: !widget.message.isThinking);
    _finishNotificationSent = !widget.message.isThinking;
    _revealTicker = createTicker((elapsed) {
      final delta = elapsed - _previousFrame;
      _previousFrame = elapsed;
      _reveal.advance(delta);
      if (!_reveal.needsFrames) _revealTicker.stop();
    });
    _reveal.addListener(_onRevealChanged);
    widget.message.notifier.addListener(_onStreamToken);
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
    _regenerationExitCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _regenerationExitAnim = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _regenerationExitCtl, curve: Curves.easeOutCubic),
    );
    _regenerationExitCtl.addStatusListener(_onRegenerationExitStatus);

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
      _headerEntryCtl.value = 1.0;
      _entryCtl.value = 1.0;
    } else if (widget.message.isThinking &&
        widget.message.displayableText.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startRevealClock();
      });
    }
  }

  @override
  void dispose() {
    widget.message.notifier.removeListener(_onStreamToken);
    _entryCtl.dispose();
    _fadeCtl.dispose();
    _thinkPulseCtl.dispose();
    _thinkRotateCtl.dispose();
    _headerEntryCtl.dispose();
    _regenerationExitCtl.dispose();
    _revealTicker.dispose();
    _reveal.removeListener(_onRevealChanged);
    _reveal.dispose();
    super.dispose();
  }

  void _startRevealClock() {
    if (!_isRegenerating && !_revealTicker.isActive && _reveal.needsFrames) {
      _previousFrame = Duration.zero;
      _revealTicker.start();
    }
  }

  void _onRegenerationExitStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _completeRegenerationExit();
    }
  }

  void _completeRegenerationExit() {
    if (!mounted || !_isRegenerating) return;

    final pendingText = _pendingRegenerationText;
    final pendingComplete = _pendingRegenerationComplete;
    _isRegenerating = false;
    _pendingRegenerationText = '';
    _pendingRegenerationComplete = false;
    // The exit transition is one-shot. Reset it before rebuilding the new
    // response so the next options row and header metadata are visible again.
    _regenerationExitCtl.value = 0;
    _regenerationMessage = null;
    _regenerationEmbeddedMedia = null;
    _parseCache.clear();
    _finishNotificationSent = false;

    // The network may have delivered the complete answer during the exit
    // animation. It still enters the same character reveal pipeline here.
    _headerEntryCtl.value = 0;
    _reveal.reset(pendingText, complete: pendingComplete);
    if (widget.message.isThinking && !widget.message.isError) {
      _thinkPulseCtl.repeat(reverse: true);
      _thinkRotateCtl.repeat();
    }
    if (pendingText.isNotEmpty || widget.embeddedMedia != null) {
      _headerEntryCtl.forward();
    }
    _startRevealClock();
    setState(() {});
  }

  void _beginRegenerationExit(
      Message oldMessage, Widget? oldEmbeddedMedia, Message newMessage) {
    if (_isRegenerating) return;

    _isRegenerating = true;
    _regenerationMessage = oldMessage;
    _regenerationEmbeddedMedia = oldEmbeddedMedia;
    _pendingRegenerationText = newMessage.displayableText;
    _pendingRegenerationComplete = !newMessage.isThinking;
    _revealTicker.stop();
    _finishNotificationSent = false;
    _completionScheduled = false;
    if (_thinkPulseCtl.isAnimating) _thinkPulseCtl.stop();
    if (_thinkRotateCtl.isAnimating) _thinkRotateCtl.stop();
    // Hold the Cortex mark at its resting scale during the outgoing controls
    // fade. Rotation/pulse resumes only when the new reveal is released.
    _thinkPulseCtl.value = 0;
    _regenerationExitCtl.forward(from: 0);
  }

  void _captureRegenerationUpdate() {
    _pendingRegenerationText = widget.message.displayableText;
    _pendingRegenerationComplete = !widget.message.isThinking;
  }

  bool _shouldShowFallbackNotice(BuildContext context, Message message) {
    if (!message.isServerFallback || !_isInitialLoad) {
      return false;
    }

    final conversation = context.read<ConversationProvider>();
    final messages = conversation.messages;
    final messageIndex = messages.indexOf(message);

    String? selectedModel;
    if (messageIndex >= 0) {
      for (var i = messageIndex - 1; i >= 0; i--) {
        final candidate = messages[i];
        if (candidate.isUserMessage) {
          selectedModel = candidate.model;
          break;
        }
      }
    }
    final normalized = (selectedModel ?? '').trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'cortex/auto' &&
        normalized != 'dynamic';
  }

  void _onRevealChanged() {
    if (!mounted) return;
    const AiMessageRevealNotification().dispatch(context);
    if (!_visualComplete || _finishNotificationSent || _completionScheduled) {
      return;
    }
    _completionScheduled = true;
    final generation = _reveal.generation;
    // Dispatch after the frame containing the final fully opaque glyph.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _completionScheduled = false;
      if (!mounted ||
          _isRegenerating ||
          generation != _reveal.generation ||
          !_visualComplete ||
          _finishNotificationSent ||
          widget.message.isError) {
        return;
      }
      _finishNotificationSent = true;
      setState(() {});
      const AiStreamFinishedNotification().dispatch(context);
      if (widget.message.hasAttachments) {
        Provider.of<ArtsProvider>(context, listen: false).loadMedia();
      }
    });
  }

  void _acceptStreamText() {
    _reveal.accept(widget.message.displayableText,
        complete: !widget.message.isThinking);
    _startRevealClock();
  }

  void _onStreamToken() {
    if (!mounted || widget.message.isError || _isRegenerating) return;
    // copyWithText publishes before the provider replaces its Message snapshot.
    // Read the notifier's value, not the old immutable widget.message.text.
    final text = widget.message
        .copyWith(text: widget.message.notifier.value)
        .displayableText;
    _reveal.accept(text, complete: false);
    if (text.isNotEmpty) {
      if (!_headerEntryCtl.isAnimating && !_headerEntryCtl.isCompleted) {
        _headerEntryCtl.forward();
      }
      _startRevealClock();
    }
  }

  @override
  void didUpdateWidget(covariant AIMessageTile old) {
    super.didUpdateWidget(old);
    if (old.message.notifier != widget.message.notifier) {
      old.message.notifier.removeListener(_onStreamToken);
      widget.message.notifier.addListener(_onStreamToken);
    }
    final String logPrefix = "[AIMessageTile.didUpdateWidget]";

    // 1. Stream Starting Logic
    final bool isStreamStarting =
        (old.message.displayableText.isEmpty && old.embeddedMedia == null) &&
            (widget.message.displayableText.isNotEmpty ||
                widget.embeddedMedia != null) &&
            widget.message.isThinking;

    if (isStreamStarting && !_isRegenerating && !widget.message.isError) {
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

        if (_isRegenerating) {
          _regenerationExitCtl.stop();
          _isRegenerating = false;
          _regenerationMessage = null;
          _regenerationEmbeddedMedia = null;
          _pendingRegenerationText = '';
          _pendingRegenerationComplete = false;
        }

        _revealTicker.stop();
        _reveal.flush();

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
      if (_isRegenerating) {
        _captureRegenerationUpdate();
      } else {
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

        _acceptStreamText();
      }
    }

    // 4. Regeneration Logic
    if (!old.message.isThinking &&
        widget.message.isThinking &&
        !widget.message.isError) {
      debugPrint("$logPrefix Regeneration started.");
      _beginRegenerationExit(old.message, old.embeddedMedia, widget.message);
    }

    // 5. Text Update Logic
    if (!widget.message.isError &&
        widget.message.displayableText != old.message.displayableText &&
        widget.message.isThinking) {
      if (_isRegenerating) {
        _captureRegenerationUpdate();
      } else {
        _acceptStreamText();
      }
    }

    // 6. Static Text Change
    else if (!widget.message.isError &&
        widget.message.displayableText != old.message.displayableText &&
        !widget.message.isThinking &&
        !old.message.isThinking) {
      _acceptStreamText();
    }

    // Opacity Updates
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
    _reveal.flush();
    _revealTicker.stop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = screenWidth / 400;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tile = AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: widget.message.isError
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildErrorOnlyTile(context, scale),
          secondChild: _buildStandardTile(context, scale),
        );
        // ListView gives this tile a finite cross-axis width. Locking it here
        // prevents each newly revealed prefix from changing the tile's
        // intrinsic width and shifting the whole message horizontally.
        return constraints.hasBoundedWidth
            ? SizedBox(width: constraints.maxWidth, child: tile)
            : tile;
      },
    );
  }

  Widget _buildErrorOnlyTile(BuildContext context, double scale) {
    return FadeTransition(
      opacity: _entryScaleAnim,
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
                  child: _AiErrorWidget(message: widget.message, scale: scale),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardTile(BuildContext context, double scale) {
    final displayedMessage = _regenerationMessage ?? widget.message;
    final displayedMedia = _isRegenerating
        ? (_regenerationEmbeddedMedia ?? widget.embeddedMedia)
        : widget.embeddedMedia;
    final headerData = _AiHeader._resolveHeaderData(context, displayedMessage);
    return FadeTransition(
      opacity: _entryScaleAnim,
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
                    message: displayedMessage,
                    avatarPath: widget.avatarPath,
                    scale: scale,
                    thinkPulseAnim: _thinkPulseAnim,
                    thinkRotateAnim: _thinkRotateCtl,
                    headerEntryAnim: _headerEntryAnim,
                    modelDetailsAnim: _isRegenerating
                        ? _regenerationExitAnim
                        : _headerEntryAnim,
                    textToDisplay: headerData.textToDisplay,
                    isCortexDynamic: headerData.isCortexDynamic,
                  ),
                  FadeTransition(
                    opacity: _headerEntryAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _regenerationExitAnim,
                          child: AnimatedBuilder(
                            animation: _reveal,
                            builder: (context, _) => _AiBodyContent(
                              message: displayedMessage,
                              embeddedMedia: displayedMedia,
                              mediaAboveText: widget.mediaAboveText,
                              reveal: _reveal,
                              scale: scale,
                              parseCache: _parseCache,
                              onContinue: widget.onContinue,
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _regenerationExitAnim,
                          child: _InlineOptionsRow(
                            message: displayedMessage,
                            onReport: widget.onReport,
                            onRegenerate: widget.onRegenerate,
                            scale: scale,
                            revealComplete: _visualComplete || _isRegenerating,
                            isExiting: _isRegenerating,
                          ),
                        ),
                        if (_shouldShowFallbackNotice(
                            context, displayedMessage))
                          FadeTransition(
                            opacity: _regenerationExitAnim,
                            child: TweenAnimationBuilder<double>(
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
                                        width: CortexDesign.icon,
                                        height: CortexDesign.icon,
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
