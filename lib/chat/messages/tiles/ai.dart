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
  late final AnimationController _entryFadeCtl;
  late final Animation<double> _entryFadeAnim;
  late final AnimationController _thinkAnimCtl;
  late final AnimationController _headerEntryCtl;
  late final Animation<double> _headerEntryAnim;

  String _stableText = "";
  String _animatingText = "";
  final Map<String, List<InlineSpan>> _parseCache = {};

  @override
  void initState() {
    super.initState();
    _entryFadeCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _entryFadeAnim = CurvedAnimation(parent: _entryFadeCtl, curve: Curves.easeOut);
    _thinkAnimCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _headerEntryCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _headerEntryAnim = CurvedAnimation(parent: _headerEntryCtl, curve: Curves.easeOut);

    if (widget.message.isThinking && !widget.message.isError) {
      _thinkAnimCtl.repeat(reverse: true);
      _entryFadeCtl.forward();
    }

    if (widget.message.isThinking &&
        !widget.message.isError &&
        (widget.message.displayableText.isNotEmpty || widget.embeddedMedia != null)) {
      _headerEntryCtl.forward();
    }

    if (widget.message.isError) {
      _entryFadeCtl.value = 0.0;
    } else if (widget.message.opacity == 1) {
      _entryFadeCtl.forward(from: 0);
    } else {
      _entryFadeCtl.value = widget.message.opacity;
    }

    if (!widget.message.isThinking &&
        (widget.message.displayableText.isNotEmpty ||
            widget.message.hasAttachments || widget.embeddedMedia != null)) {
      _stableText = widget.message.displayableText;
      _headerEntryCtl.value = 1.0;
      _entryFadeCtl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entryFadeCtl.dispose();
    _thinkAnimCtl.dispose();
    _headerEntryCtl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AIMessageTile old) {
    super.didUpdateWidget(old);
    final msg = widget.message;
    final oldMsg = old.message;

    final isNowError = msg.isError;
    final wasError = oldMsg.isError;
    final isNowThinking = msg.isThinking;
    final wasThinking = oldMsg.isThinking;
    final newText = msg.displayableText;
    final oldText = oldMsg.displayableText;
    final oldOpacity = oldMsg.opacity;
    final newOpacity = msg.opacity;

    if (isNowError && !wasError) {
      _thinkAnimCtl.stop();
      _headerEntryCtl.reverse();
      if (newText.isEmpty) {
        _entryFadeCtl.reverse();
      } else {
        _entryFadeCtl.forward();
      }
      return;
    }
    if (!isNowError && wasError) {
      _entryFadeCtl.forward();
      return;
    }

    if (isNowError) return;

    final isStreamStart = wasThinking && wasThinking == isNowThinking &&
        oldText.isEmpty && newText.isNotEmpty;
    final isStreamFinish = wasThinking && !isNowThinking;
    final isRegenStart = !wasThinking && isNowThinking;
    final textChanged = newText != oldText;

    if (isStreamStart) {
      _thinkAnimCtl.stop();
      _headerEntryCtl.forward();
      return;
    }

    if (isStreamFinish) {
      _thinkAnimCtl.stop();
      _stableText = newText;
      _animatingText = "";
      if (!_headerEntryCtl.isCompleted) _headerEntryCtl.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          const AiStreamFinishedNotification().dispatch(context);
          if (msg.hasAttachments) {
            Provider.of<ArtsProvider>(context, listen: false).loadMedia();
          }
        }
      });
      return;
    }

    if (isRegenStart) {
      _entryFadeCtl.forward(from: 0);
      _headerEntryCtl.reverse();
      _stableText = "";
      _animatingText = "";
      _thinkAnimCtl.repeat(reverse: true);
      return;
    }

    if (textChanged && isNowThinking) {
      _stableText = newText;
      _animatingText = "";
    } else if (textChanged && !isNowThinking) {
      _stableText = newText;
      _animatingText = "";
    }

    if (oldOpacity != newOpacity) {
      if (newOpacity == 1.0) {
        _entryFadeCtl.forward();
      } else if (newOpacity == 0.0) {
        _entryFadeCtl.reverse().whenComplete(() => widget.onFadeOutComplete?.call());
      } else {
        _entryFadeCtl.value = newOpacity;
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
    return FadeTransition(
      opacity: _entryFadeAnim,
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
    final headerData = _AiHeader._resolveHeaderData(context, widget.message);
    return FadeTransition(
      opacity: _entryFadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: GestureDetector(
          onTap: () {},
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
                  thinkAnim: _thinkAnimCtl,
                  headerEntryAnim: _headerEntryAnim,
                  textToDisplay: headerData.textToDisplay,
                  isCortexDynamic: headerData.isCortexDynamic,
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
                        scale: scale,
                        parseCache: _parseCache,
                      ),
                      _InlineOptionsRow(
                        message: widget.message,
                        onReport: widget.onReport,
                        onRegenerate: widget.onRegenerate,
                        scale: scale,
                      ),
                    ],
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
