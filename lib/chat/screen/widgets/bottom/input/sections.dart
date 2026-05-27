// lib/chat/screen/widgets/bottom/input/sections.dart
//
// Extracted widget sections for InputField - keeps input.dart lean and focused.

import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/fog.dart';
import 'package:cortex/internet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../app.dart';
import '../../../../../theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../wave.dart';
import 'buttons.dart';
import 'input.dart';

// --- Waveform Section ---
class WaveformSection extends StatelessWidget {
  const WaveformSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 800;
    final bool isTablet = screenWidth >= 600;

    final double buttonSize = isDesktop ? 40.0 : (isTablet ? 40.0 : 36.0);
    final double buttonPadding =
        isDesktop ? 16.0 : (isTablet ? screenWidth * 0.02 : 16.0);
    final double rightPadding = buttonPadding + (buttonSize / 2);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(12.0, 24.0, rightPadding, 16.0),
      child: const WaveformVisualizer(origin: WaveOrigin.right),
    );
  }
}

// --- Multi-File Attachment Preview ---
class AttachmentPreviewSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;

  const AttachmentPreviewSection({
    super.key,
    required this.screenWidth,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();
    final attachments = inputProvider.attachments;
    final bool isDesktop = screenWidth >= 800;

    final double itemSize =
        isDesktop ? 80.0 : (isTablet ? screenWidth * 0.15 : screenWidth * 0.20);
    final double padding =
        isDesktop ? 12.0 : (isTablet ? screenWidth * 0.02 : 12.0);

    return AttachmentListWithFog(
      attachments: attachments,
      itemSize: itemSize,
      padding: padding,
      onRemove: (index) {
        inputProvider.removeAttachmentAt(index);
      },
    );
  }
}

class AttachmentListWithFog extends StatefulWidget {
  final List<InputAttachment> attachments;
  final double itemSize;
  final double padding;
  final Function(int) onRemove;

  const AttachmentListWithFog({
    super.key,
    required this.attachments,
    required this.itemSize,
    required this.padding,
    required this.onRemove,
  });

  @override
  State<AttachmentListWithFog> createState() => _AttachmentListWithFogState();
}

class _AttachmentListWithFogState extends State<AttachmentListWithFog>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  late List<InputAttachment> _displayedItems;
  AnimationController? _syncController;

  @override
  void initState() {
    super.initState();
    _displayedItems = List.from(widget.attachments);
  }

  @override
  void didUpdateWidget(AttachmentListWithFog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncList();
  }

  void _syncList() {
    final newItems = widget.attachments;

    if (newItems.length > _displayedItems.length) {
      for (int i = 0; i < newItems.length; i++) {
        if (i >= _displayedItems.length || newItems[i] != _displayedItems[i]) {
          _displayedItems.insert(i, newItems[i]);
          _listKey.currentState?.insertItem(i);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          if (newItems.length == _displayedItems.length) break;
        }
      }
    } else if (newItems.length < _displayedItems.length) {
      for (int i = 0; i < _displayedItems.length; i++) {
        if (i >= newItems.length || _displayedItems[i] != newItems[i]) {
          final removedItem = _displayedItems[i];
          _displayedItems.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) =>
                _buildItem(removedItem, animation, i, isRemoving: true),
            duration: const Duration(milliseconds: 300),
          );

          _syncController?.dispose();
          _syncController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 300),
          )
            ..addListener(() {
              if (mounted) {
                try {
                  context.read<ScrollService>().updateButtonVisibility();
                } catch (_) {}
              }
            })
            ..forward();

          if (newItems.length == _displayedItems.length) break;
          i--;
        }
      }
    }
  }

  @override
  void dispose() {
    _syncController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildItem(
    InputAttachment attachment,
    Animation<double> animation,
    int index, {
    bool isRemoving = false,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axis: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AttachmentItem(attachment: attachment, size: widget.itemSize),
              if (!isRemoving)
                Positioned(
                  top: 2,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => widget.onRemove(index),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: widget.attachments.isNotEmpty
            ? widget.itemSize + (widget.padding * 2)
            : 0,
        width: double.infinity,
        child: widget.attachments.isNotEmpty
            ? ScrollFogHorizontal(
                scrollController: _scrollController,
                child: AnimatedList(
                  key: _listKey,
                  controller: _scrollController,
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.padding,
                    vertical: widget.padding,
                  ),
                  initialItemCount: _displayedItems.length,
                  itemBuilder: (context, index, animation) {
                    if (index >= _displayedItems.length) {
                      return const SizedBox.shrink();
                    }
                    return _buildItem(_displayedItems[index], animation, index);
                  },
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

// --- Attachment Item ---
class AttachmentItem extends StatelessWidget {
  final InputAttachment attachment;
  final double size;

  const AttachmentItem({
    super.key,
    required this.attachment,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (attachment.type == AttachmentType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(
          attachment.file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) =>
              Icon(Icons.broken_image, color: AppColors.tertiaryColor),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.tertiaryColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFileIcon(attachment.extension),
              size: size * 0.4,
              color: AppColors.primaryColor.inverted,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                attachment.extension.replaceAll('.', '').toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor.inverted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      );
    }
  }

  IconData _getFileIcon(String ext) {
    switch (ext) {
      case '.pdf':
        return Icons.picture_as_pdf_rounded;
      case '.doc':
      case '.docx':
        return Icons.description_rounded;
      case '.xls':
      case '.xlsx':
      case '.csv':
        return Icons.table_chart_rounded;
      case '.txt':
      case '.md':
        return Icons.text_snippet_rounded;
      case '.json':
      case '.xml':
      case '.html':
      case '.dart':
      case '.js':
      case '.py':
        return Icons.code_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}

// --- Text Field Section ---
class TextFieldSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final AppLocalizations localizations;
  final double screenWidth;
  final bool isTablet;
  final VoidCallback onEnterPressed;
  final bool showHintText;

  const TextFieldSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.localizations,
    required this.screenWidth,
    required this.isTablet,
    required this.onEnterPressed,
    this.showHintText = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = screenWidth >= 800;

    final double fontSize = isDesktop
        ? 16.0
        : (isTablet ? screenWidth * 0.025 : screenWidth * 0.04);
    final double verticalPadding = isDesktop
        ? 14.0
        : (isTablet ? screenWidth * 0.015 : screenWidth * 0.03);
    final double horizontalPadding = isDesktop
        ? 12.0
        : (isTablet ? screenWidth * 0.015 : screenWidth * 0.02);

    // [NEW] Intercept hardware 'Enter' key on desktop to send message directly, while Shift+Enter adds a new line.
    focusNode.onKeyEvent = (FocusNode node, KeyEvent event) {
      if (isDesktop &&
          event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        if (!HardwareKeyboard.instance.isShiftPressed) {
          // Send message
          onEnterPressed();
          // Consume the key event to prevent TextField from inserting a new line
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 8.0 : screenWidth * 0.02),
      child: TextField(
        key: const ValueKey('chat_input_field'),
        focusNode: focusNode,
        cursorColor: AppColors.primaryColor.inverted,
        controller: controller,
        maxLength: 4000,
        minLines: 1,
        maxLines: 6,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          hintText: showHintText ? localizations.messageHint : '',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: fontSize),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          counterText: '',
        ),
        style: TextStyle(
          color: AppColors.primaryColor.inverted,
          fontSize: fontSize,
        ),
        onSubmitted: (_) => onEnterPressed(),
      ),
    );
  }
}

// --- Tools Section ---
class ToolsSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final InputField widget;
  final bool isActionPermitted;

  const ToolsSection({
    super.key,
    required this.screenWidth,
    required this.isTablet,
    required this.widget,
    required this.isActionPermitted,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = screenWidth >= 800;
    final double startPadding =
        isDesktop ? 16.0 : (screenWidth * (isTablet ? 0.02 : 0.03));
    final double bottomPadding =
        isDesktop ? 12.0 : (screenWidth * (isTablet ? 0.015 : 0.025));
    final double spacing =
        isDesktop ? 16.0 : (screenWidth * (isTablet ? 0.02 : 0.025));

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: startPadding,
        end: screenWidth * 0.02,
        top: screenWidth * 0.005,
        bottom: bottomPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AddPhotoButton(
            isLimitExceeded: widget.isLimitExceeded,
            isPhotoLoading: widget.isPhotoLoading,
            localizations: widget.localizations,
          ),
          SizedBox(width: spacing),
          FeaturesButton(
            controller: widget.controller,
            isLimitExceeded: widget.isLimitExceeded,
            isActionPermitted: isActionPermitted,
          ),
          SizedBox(width: spacing),
          ModelSelectButton(
            screenWidth: screenWidth,
            isTablet: isTablet,
            localizations: widget.localizations,
            onSelectionComplete: () => widget.textFieldFocusNode.requestFocus(),
          ),
        ],
      ),
    );
  }
}

// --- Send Button Section ---
class SendButtonSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final InputField widget;
  final bool isEnabled;
  final bool isActionPermitted;
  final TextEditingController controller;

  const SendButtonSection({
    super.key,
    required this.screenWidth,
    required this.isTablet,
    required this.widget,
    required this.isEnabled,
    required this.isActionPermitted,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConnected = context.watch<InternetProvider>().isConnected;
    final inputProvider = context.watch<InputProvider>();
    final speechService = context.watch<SpeechService>();

    bool effectiveEnabled = isEnabled;
    if ((widget.isServerSideModel || widget.isDynamicChatMode) &&
        !isConnected) {
      effectiveEnabled = false;
    }

    VoidCallback? effectiveOnStop;
    if (inputProvider.isVoiceRecording) {
      effectiveOnStop = () async {
        inputProvider.setVoiceRecording(false);
        await speechService.stopListening();
      };
    } else {
      effectiveOnStop = widget.onStop;
    }

    final bool isDesktop = screenWidth >= 800;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        end: isDesktop ? 16.0 : (screenWidth * (isTablet ? 0.02 : 0.04)),
        bottom: isDesktop ? 12.0 : (screenWidth * (isTablet ? 0.015 : 0.025)),
      ),
      child: ActionButtonWidget(
        isEnabled: effectiveEnabled,
        isActionPermitted: isActionPermitted,
        isSending: widget.isSending,
        isRecording: inputProvider.isVoiceRecording,
        isTextEmpty: controller.text.trim().isEmpty,
        onSend: widget.onSend,
        onStop: effectiveOnStop,
        controller: controller,
      ),
    );
  }
}

// --- Sequenced Tools Transition ---
class SequencedToolsTransition extends StatefulWidget {
  final bool isVisible;
  final Widget child;

  const SequencedToolsTransition({
    super.key,
    required this.isVisible,
    required this.child,
  });

  @override
  State<SequencedToolsTransition> createState() =>
      _SequencedToolsTransitionState();
}

class _SequencedToolsTransitionState extends State<SequencedToolsTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        reverseCurve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic),
        reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    if (!widget.isVisible) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SequencedToolsTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _sizeAnimation,
          axis: Axis.vertical,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
