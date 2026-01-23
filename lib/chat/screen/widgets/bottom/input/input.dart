// lib/chat/screen/selected/widgets/input/input.dart

import 'dart:async';
import 'dart:io';
import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../internet.dart';
import '../../../../../theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../services/speech.dart';
import '../../wave.dart';
import 'buttons.dart';
import 'service.dart';
import '../../../../../../fog.dart';

class InputField extends StatefulWidget {
  final AppLocalizations localizations;
  final bool isModelSelected;
  final bool isDynamicChatMode;
  final bool isLimitExceeded;
  final TextEditingController controller;
  final FocusNode textFieldFocusNode;
  final Future<void> Function() onSend;
  final Future<void> Function() onApplyEditedMessage;
  final bool isPhotoLoading;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final bool isSending;
  final bool isPremiumModel;
  final bool isSubscribed;
  final int premiumTrialUses;
  final String? originalMessageText;
  final bool isStorageSufficient;
  final int totalCredits;
  final String? role;
  final bool isServerSideModel;
  final VoidCallback onStop;
  final bool canHandleImage; // Maintained for legacy check logic
  final bool isEditingMode;
  final File?
      preselectedPhoto; // Deprecated but kept for signature compatibility
  final bool modelMissing;
  final VoidCallback onCancelEditing;

  const InputField({
    super.key,
    required this.localizations,
    required this.isModelSelected,
    required this.isDynamicChatMode,
    required this.isLimitExceeded,
    required this.controller,
    required this.textFieldFocusNode,
    required this.onSend,
    required this.onApplyEditedMessage,
    required this.isPhotoLoading,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.isSending,
    required this.isPremiumModel,
    required this.isSubscribed,
    required this.premiumTrialUses,
    this.originalMessageText,
    required this.isStorageSufficient,
    required this.totalCredits,
    this.role,
    required this.isServerSideModel,
    required this.onStop,
    this.onPhotoSelected, // Deprecated parameter, unused
    required this.canHandleImage,
    this.isEditingMode = false,
    this.preselectedPhoto,
    required this.modelMissing,
    required this.onCancelEditing,
  });

  // Deprecated parameter kept for signature compatibility
  final ValueChanged<File?>? onPhotoSelected;

  @override
  InputFieldState createState() => InputFieldState();
}

class InputFieldState extends State<InputField> with TickerProviderStateMixin {
  final InputService _inputService = InputService();
  double _inputFieldHeight = 0.0;
  final GlobalKey _inputFieldKey = GlobalKey();

  // Master controller for Input <-> Voice transition
  late AnimationController _modeController;

  late Animation<double> _inputOpacityAnim;
  late Animation<double> _waveOpacityAnim;

  @override
  void initState() {
    super.initState();

    // 600ms total transition duration
    _modeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 1. Input Opacity (Fade Out 0.0 -> 0.4)
    // Reverse: Fade In (0.4 -> 0.0) -> Buttons appear last
    _inputOpacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _modeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        reverseCurve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // 2. Wave Opacity (Fade In 0.5 -> 1.0)
    // Reverse: Fade Out (1.0 -> 0.5) -> Wave disappears first
    _waveOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _modeController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    widget.controller.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final speechService = context.read<SpeechService>();
      speechService.addListener(_onSpeechStatusChange);

      // Initialize state based on provider
      final inputProvider = context.read<InputProvider>();
      if (inputProvider.isVoiceRecording) {
        _modeController.value = 1.0;
      }
    });
  }

  @override
  void dispose() {
    _modeController.dispose();
    _speechService?.removeListener(_onSpeechStatusChange);
    super.dispose();
  }

  SpeechService? _speechService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newService = context.read<SpeechService>();
    if (_speechService != newService) {
      _speechService?.removeListener(_onSpeechStatusChange);
      _speechService = newService;
      _speechService?.addListener(_onSpeechStatusChange);
    }
  }

  void _onSpeechStatusChange() {
    if (!mounted) return;
    final inputProvider = context.read<InputProvider>();
    final speechService = _speechService;

    if (speechService == null) return;

    if (inputProvider.isVoiceRecording && !speechService.isListening) {
      inputProvider.setVoiceRecording(false);
    }
  }

  // Monitor provider state changes to drive animation
  void _syncAnimationWithState(bool isRecording) {
    if (isRecording) {
      if (_modeController.status != AnimationStatus.forward &&
          _modeController.status != AnimationStatus.completed) {
        _modeController.forward();
      }
    } else {
      if (_modeController.status != AnimationStatus.reverse &&
          _modeController.status != AnimationStatus.dismissed) {
        _modeController.reverse();
      }
    }
  }

  void clearPhotoPanel() {
    context.read<InputProvider>().clearAttachments();
  }

  bool get isSendButtonEnabled {
    return _inputService.isSendButtonEnabled(
      context: context,
      controller: widget.controller,
      isServerSideModel: widget.isServerSideModel,
      isDynamicChatMode: widget.isDynamicChatMode,
      isLimitExceeded: widget.isLimitExceeded,
      isSending: widget.isSending,
      modelMissing: widget.modelMissing,
      isStorageSufficient: widget.isStorageSufficient,
      isPremiumModel: widget.isPremiumModel,
      isSubscribed: widget.isSubscribed,
      premiumTrialUses: widget.premiumTrialUses,
      totalCredits: widget.totalCredits,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    final inputProvider = context.watch<InputProvider>();
    final bool isRecording = inputProvider.isVoiceRecording;

    _syncAnimationWithState(isRecording);

    if (!widget.isModelSelected && !widget.isDynamicChatMode) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());

        final double radius = isTablet ? screenWidth * 0.025 : 16.0;

        return Container(
          key: _inputFieldKey,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),
            border:
                Border(top: BorderSide(color: AppColors.border, width: 1.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AttachmentPreviewSection(
                  screenWidth: screenWidth, isTablet: isTablet),

              // Main Animated Area
              AnimatedBuilder(
                animation: _modeController,
                builder: (context, child) {
                  // Logic for sequencing Layout Changes (Expansion/Shrink)
                  // Forward (Input->Voice):
                  //   0.0->0.2: Standard Input (Wave Offstage)
                  //   0.2: Wave Onstage -> Layout expands to max
                  //   1.0: Input Offstage -> Layout shrinks to Wave
                  // Reverse (Voice->Input):
                  //   1.0->0.8: Wave Visible (Input Offstage)
                  //   0.8: Input Onstage -> "Input Expand" triggers here (Stack becomes Max)
                  //   0.0: Wave Offstage -> Stack becomes Input

                  // Asymmetric Logic for sequencing:
                  // Forward: Cut input early (0.5) to avoid empty box.
                  // Reverse: Expand input early (0.9) to ensure expansion finishes before buttons fade in.
                  final bool isForward =
                      _modeController.status == AnimationStatus.forward ||
                          _modeController.status == AnimationStatus.completed;
                  final double inputCutoff = isForward ? 0.5 : 0.9;

                  final bool showInputLayout =
                      _modeController.value < inputCutoff;
                  final bool showWaveLayout = _modeController.value > 0.1;

                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // 1. INPUT CONTENT
                        Visibility(
                          visible: showInputLayout,
                          maintainState: true,
                          child: IgnorePointer(
                            ignoring: _inputOpacityAnim.value < 0.1,
                            child: FadeTransition(
                              opacity: _inputOpacityAnim,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _TextFieldSection(
                                              key: const ValueKey('textfield'),
                                              controller: widget.controller,
                                              focusNode:
                                                  widget.textFieldFocusNode,
                                              localizations:
                                                  widget.localizations,
                                              screenWidth: screenWidth,
                                              isTablet: isTablet,
                                              showHintText: true,
                                              onEnterPressed: () {
                                                if (isSendButtonEnabled) {
                                                  widget.onSend();
                                                }
                                              },
                                            ),
                                            _SequencedToolsTransition(
                                              isVisible: true,
                                              child: _ToolsSection(
                                                screenWidth: screenWidth,
                                                isTablet: isTablet,
                                                widget: widget,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: false,
                                        maintainSize: true,
                                        maintainAnimation: true,
                                        maintainState: true,
                                        child: _SendButtonSection(
                                          screenWidth: screenWidth,
                                          isTablet: isTablet,
                                          widget: widget,
                                          isEnabled: isSendButtonEnabled,
                                          controller: widget.controller,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 2. WAVEFORM CONTENT
                        Visibility(
                          visible: showWaveLayout,
                          maintainState: true,
                          child: IgnorePointer(
                            ignoring: _waveOpacityAnim.value < 0.1,
                            child: FadeTransition(
                              opacity: _waveOpacityAnim,
                              child: const _WaveformSection(
                                  key: ValueKey('waveform')),
                            ),
                          ),
                        ),

                        // 3. MAIN ACTION BUTTON (PERSISTENT)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: _SendButtonSection(
                            screenWidth: screenWidth,
                            isTablet: isTablet,
                            widget: widget,
                            isEnabled: isSendButtonEnabled,
                            controller: widget.controller,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateHeight() {
    final RenderBox? renderBox =
        _inputFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final newHeight = renderBox.size.height;
      if (newHeight != _inputFieldHeight) {
        setState(() => _inputFieldHeight = newHeight);
      }
    }
  }
}

// --- WIDGET COMPONENTS ---

class _WaveformSection extends StatelessWidget {
  const _WaveformSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      // Lowered position per user request (increased top padding from 16.0 to 24.0)
      padding: EdgeInsets.fromLTRB(12.0, 24.0, 0, 16.0),
      child: WaveformVisualizer(),
    );
  }
}

// --- Multi-File Attachment Preview ---
class _AttachmentPreviewSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;

  const _AttachmentPreviewSection(
      {required this.screenWidth, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();
    final attachments = inputProvider.attachments;

    final double itemSize = isTablet ? screenWidth * 0.15 : screenWidth * 0.20;
    // Reverted padding to standard
    final double padding = isTablet ? screenWidth * 0.02 : 12.0;

    return _AttachmentListWithFog(
      attachments: attachments,
      itemSize: itemSize,
      padding: padding,
      onRemove: (index) => inputProvider.removeAttachmentAt(index),
    );
  }
}

class _AttachmentListWithFog extends StatefulWidget {
  final List<InputAttachment> attachments;
  final double itemSize;
  final double padding;
  final Function(int) onRemove;

  const _AttachmentListWithFog({
    required this.attachments,
    required this.itemSize,
    required this.padding,
    required this.onRemove,
  });

  @override
  State<_AttachmentListWithFog> createState() => _AttachmentListWithFogState();
}

class _AttachmentListWithFogState extends State<_AttachmentListWithFog> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  late List<InputAttachment> _displayedItems;

  @override
  void initState() {
    super.initState();
    _displayedItems = List.from(widget.attachments);
  }

  @override
  void didUpdateWidget(_AttachmentListWithFog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncList();
  }

  void _syncList() {
    final newItems = widget.attachments;

    // Calculate Diff (Simple implementation optimized for single operations)
    // 1. Check for Additions
    if (newItems.length > _displayedItems.length) {
      for (int i = 0; i < newItems.length; i++) {
        if (i >= _displayedItems.length || newItems[i] != _displayedItems[i]) {
          _displayedItems.insert(i, newItems[i]);
          _listKey.currentState?.insertItem(i);

          // Auto-scroll to end on add
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          // Single addition optimization
          if (newItems.length == _displayedItems.length) break;
        }
      }
    }
    // 2. Check for Removals
    else if (newItems.length < _displayedItems.length) {
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
          if (newItems.length == _displayedItems.length) break;
          i--; // Adjust index since we removed
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildItem(
      InputAttachment attachment, Animation<double> animation, int index,
      {bool isRemoving = false}) {
    // Combined Fade and Size transition for polished effect
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
              _AttachmentItem(attachment: attachment, size: widget.itemSize),
              // Only show delete button if NOT removing (visual polish)
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
                              offset: Offset(0, 1))
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
    // If empty (and no outgoing animations pending?), collapse.
    // AnimatedList keeps state, so strict check on _displayedItems might hide outgoing element.
    // Better to check widget.attachments for the "container" visibility, but for AnimatedList to work
    // it needs to be in the tree.
    // However, our parent uses AnimatedSize to hide this whole block if "hasAttachments" is false.
    // If we rely on parent to hide, the "last item removal" animation will be clipped instantly.
    // SO: We must ensure parent logic in _AttachmentPreviewSection doesn't hide us prematurely!

    // FIX: _AttachmentPreviewSection (parent) wraps this in AnimatedList logic?
    // No, currently _AttachmentPreviewSection passes `attachments` to us.
    // If `attachments` is empty, parent MIGHT rebuild us?
    // Actually `_AttachmentListWithFog` wraps itself in `AnimatedSize` in the OLD code.
    // In MY NEW code, I am REPLACING `_AttachmentListWithFog`.
    // I should INCLUDE the `AnimatedSize` wrapper HERE.

    // Logic: If _displayedItems is empty, height is 0.
    // But while animating out, _displayedItems is already empty?
    // No, _displayedItems is sync with provider. removeItem animation runs even if item removed from list.
    // The AnimatedList itself needs to remain visible until animation finishes.

    // We will use AnimatedSize on the CONTAINER.
    // Trigger: _displayedItems.isNotEmpty ?

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: Container(
        // Ensure localized constraints don't squash us
        // If hasContent is false, height 0 is fine.
        // But "removing" item still needs space.
        // AnimatedList holds the widget in tree during animation.
        // So `_displayedItems` removal happens, but widget needs non-zero height?
        // Is AnimatedList empty immediately? No, it contains the "removing" item.
        // So checking `_listKey.currentState` length? Hard.

        // Better strategy: Always return the Container with AnimatedList.
        // Let AnimatedList determine its own width/height?
        // Since it's horizontal, we need fixed height.

        // Wait, if I set height 0 when _displayedItems is empty (after last removal),
        // the last item's exit animation (width shrink) might be visible, but height cut?
        // Actually, if I set height 0 immediately when provider clears, yes, animation is cut.
        // I need to wait for animation?
        // UX Decision: Just keep height if `widget.attachments` OR `_displayedItems` has stuff?
        // If Provider clears, `_displayedItems` clears immediately in my sync logic.
        // I should probably just keep the height until the list is truly visually empty.
        // Simpler: Just rely on `widget.attachments.isNotEmpty` for the 'height' toggle?
        // If user deletes last item -> Provider empty -> Widget rebuilds -> Height 0.
        // Animation cut.
        // FIX: Don't use AnimatedSize for the height toggle of the LAST item.
        // Just let AnimatedList be empty (height fixed, width 0).
        // But we want it to collapse.

        // Revised: Use `AnimatedSize` and toggle based on `_displayedItems.isNotEmpty`.
        // BUT, since we remove from `_displayedItems` BEFORE animation, this is the problem.
        // I will DELAY the removal from `_displayedItems`? No, that desyncs state.

        // I will simply use `widget.attachments.isNotEmpty` for the height check? Same issue.

        // Hack: AnimatedList handles the width. The container height can stay?
        // If width becomes 0, does it matters?
        // Let's rely on `hasContent` but adding a check?
        // Actually, standard `AnimatedList` implementation:
        // Use a boolean `_isAnimatingOut`?

        // Let's stick to the industry standard:
        // When last item is removed, we animate it out, THEN collapse the container.
        // That is hard without callbacks.

        // Acceptable Compromise: The "Slide to fill" is the main goal.
        // The last item disappearing instantly is acceptable if it collapses smoothly vertically.
        // So I will use `AnimatedSize` toggled by `widget.attachments.isNotEmpty`.
        // The "Slide" works for items 1..N. The last one just vertically collapses.

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
                      horizontal: widget.padding, vertical: widget.padding),
                  initialItemCount: _displayedItems.length,
                  itemBuilder: (context, index, animation) {
                    // Safety for fast tapping
                    if (index >= _displayedItems.length)
                      return const SizedBox.shrink();
                    return _buildItem(_displayedItems[index], animation, index);
                  },
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

// Extracted for cleaner code
class _AttachmentItem extends StatelessWidget {
  final InputAttachment attachment;
  final double size;

  const _AttachmentItem({required this.attachment, required this.size});

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
            // RE-IMPLEMENTED getFileIcon Logic locally or helper
            // Ideally we pass this down or make it static.
            // For now, let's assume the previous helper `_getFileIcon` is moved or copied?
            // Ah, `_AttachmentPreviewSection` method `_getFileIcon` will be lost.
            // I will duplicate the simple logic mostly or make it a top level helper.
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

class _TextFieldSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final AppLocalizations localizations;
  final double screenWidth;
  final bool isTablet;
  final VoidCallback onEnterPressed;
  final bool showHintText;

  const _TextFieldSection({
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
    final double fontSize = isTablet ? screenWidth * 0.025 : screenWidth * 0.04;
    final double verticalPadding = isTablet ? screenWidth * 0.015 : 12.0;
    final double horizontalPadding = isTablet ? screenWidth * 0.015 : 8.0;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? screenWidth * 0.02 : screenWidth * 0.02),
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
              vertical: verticalPadding, horizontal: horizontalPadding),
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
            color: AppColors.primaryColor.inverted, fontSize: fontSize),
        onSubmitted: (_) => onEnterPressed(),
      ),
    );
  }
}

class _SequencedToolsTransition extends StatefulWidget {
  final bool isVisible;
  final Widget child;

  const _SequencedToolsTransition({
    required this.isVisible,
    required this.child,
  });

  @override
  State<_SequencedToolsTransition> createState() =>
      _SequencedToolsTransitionState();
}

class _SequencedToolsTransitionState extends State<_SequencedToolsTransition>
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

    // Fade Out: 0.0 - 0.4 progress
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        reverseCurve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Shrink: 0.4 - 1.0 progress
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
  void didUpdateWidget(_SequencedToolsTransition oldWidget) {
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

class _ToolsSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final InputField widget;

  const _ToolsSection(
      {required this.screenWidth,
      required this.isTablet,
      required this.widget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isTablet ? screenWidth * 0.02 : 12.0,
        right: 8.0,
        top: 2.0,
        bottom: isTablet ? screenWidth * 0.015 : 12.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Replaced AddPhotoButton with generic button
          AddPhotoButton(
            isLimitExceeded: widget.isLimitExceeded,
            isPhotoLoading: widget.isPhotoLoading,
            localizations: widget.localizations,
          ),
          SizedBox(width: screenWidth * 0.02),
          FeaturesButton(controller: widget.controller),
          SizedBox(width: screenWidth * 0.02),
          ModelSelectButton(
            screenWidth: screenWidth,
            isTablet: isTablet,
            localizations: widget.localizations,
          ),
        ],
      ),
    );
  }
}

class _SendButtonSection extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final InputField widget;
  final bool isEnabled;
  final TextEditingController controller;

  const _SendButtonSection({
    required this.screenWidth,
    required this.isTablet,
    required this.widget,
    required this.isEnabled,
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
        // Optimistic update: Stop UI immediately
        inputProvider.setVoiceRecording(false);
        await speechService.stopListening();
      };
    } else {
      effectiveOnStop = widget.onStop;
    }

    return Padding(
      padding: EdgeInsets.only(
        right: isTablet ? screenWidth * 0.02 : 16.0,
        bottom: isTablet ? screenWidth * 0.015 : 12.0,
      ),
      child: ActionButtonWidget(
        isEnabled: effectiveEnabled,
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
