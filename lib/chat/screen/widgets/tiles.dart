// lib/chat/screen/selected/tiles.dart

import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p; // Standard path manipulation
import 'package:cortex/app.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/messages/viewer.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../library/backend/data/service.dart';
import '../../messages/tiles/ai.dart';
import '../../messages/tiles/user.dart';
import 'audio.dart';
import 'media.dart';

/// A utility class that acts as a factory for building different types of message widgets.
class Tiles {
  // --- USER MESSAGE TILES ---

  /// Builds a user's message tile, handling the switch between its normal and "editing" states.
  static Widget buildUserMessageTile({
    required BuildContext context,
    required Message message,
    required int index,
    Key? key,
    required bool isEditingMode,
    required int? editingMessageIndex,
    required VoidCallback onEdit,
    VoidCallback? onFadeOutComplete,
    required double screenWidth,
    required double screenHeight,
  }) {
    final isEditingThisMessage =
        isEditingMode && (editingMessageIndex == index);
    final bool isTablet = screenWidth >= 600;

    // Dimensions
    final double padding = isTablet ? screenWidth * 0.03 : screenWidth * 0.04;
    final double fontSize = isTablet ? screenWidth * 0.022 : 15.0;
    final double iconSize = isTablet ? screenWidth * 0.03 : 20.0;
    final double borderRadius = isTablet ? screenWidth * 0.015 : 12.0;

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      crossFadeState: isEditingThisMessage
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      sizeCurve: Curves.easeInOut,
      alignment: Alignment.centerRight,
      // 1. Edit Indicator (When editing is active for this message)
      firstChild: Padding(
        key: ValueKey('editing_$index'),
        padding: EdgeInsets.all(padding),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_rounded,
                  color: AppColors.primaryColor.inverted, size: iconSize),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.editingMessageInfo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: fontSize),
                ),
              ),
            ],
          ),
        ),
      ),
      // 2. Normal Content
      secondChild: buildNormalUserContent(
        context: context,
        message: message,
        index: index,
        key: key,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        onEdit: onEdit,
        onFadeOutComplete: onFadeOutComplete,
      ),
    );
  }

  /// Builds the standard content for a user message (Attachments + Text Bubble).
  static Widget buildNormalUserContent({
    required BuildContext context,
    required Message message,
    required int index,
    Key? key,
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onEdit,
    VoidCallback? onFadeOutComplete,
  }) {
    final bool isTablet = screenWidth >= 600;
    final double rightPadding =
    isTablet ? screenWidth * 0.03 : screenWidth * 0.04;

    return Column(
      key: ValueKey('normal_user_$index'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // --- ATTACHMENTS SECTION ---
        if (message.hasAttachments)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(
                  right: rightPadding, bottom: screenHeight * 0.006),
              child: _buildAttachmentList(
                context: context,
                paths: message.attachmentPaths,
                isUser: true,
                screenWidth: screenWidth,
              ),
            ),
          ),

        // --- TEXT BUBBLE SECTION ---
        if (message.text
            .trim()
            .isNotEmpty)
          UserMessageTile(
            message: message,
            key: key,
            onFadeOutComplete: onFadeOutComplete,
            onEdit: onEdit,
          ),
      ],
    );
  }

  // --- AI MESSAGE TILES ---

  /// Builds an AI's message tile (Attachments/Generated Images + Text Bubble).
  static Widget buildAIMessageTile({
    required BuildContext context,
    required Message message,
    required String modelId,
    required VoidCallback onReport,
    required void Function({String? newModelId}) onRegenerate,
    required VoidCallback onStop,
    required double screenWidth,
    required double screenHeight,
    required ModelService modelService,
  }) {
    final langCode = Localizations
        .localeOf(context)
        .languageCode;
    final preciseModelId = message.model ?? modelId;

    final model =
    modelService.getPreciseModelData(preciseModelId, langCode: langCode);
    final correctImagePath = modelService.getModelImagePath(model);

    final bool hasText = message.text
        .trim()
        .isNotEmpty;
    final bool hasShimmer =
        message.pendingMediaType != MediaGenerationType.none;
    // UX rule:
    // - Text + media => media can stay above the text block.
    // - Media-only => render media below AI header (as part of the bubble flow).
    final bool shouldRenderMediaBelowHeader =
        !hasText && (message.hasAttachments || hasShimmer);
    // [FIX] Show placeholder even if isThinking is false, provided we have no text/attachments and no error
    // This handles the gap between "Thinking done" and "First token arrived"
    final bool showContent = hasText ||
        message.isThinking ||
        message.hasAttachments ||
        hasShimmer ||
        !message.isError;

    // Media Widget - Shimmer placeholder OR real attachments with crossfade
    Widget mediaWidget;
    if (hasShimmer) {
      mediaWidget = MediaShimmerPlaceholder(
        key: ValueKey('shimmer_${message.pendingMediaType}'),
        type: message.pendingMediaType,
      );
    } else if (message.hasAttachments) {
      mediaWidget = _buildAttachmentList(
        key: const ValueKey('attachments'),
        context: context,
        paths: message.attachmentPaths,
        isUser: false,
        screenWidth: screenWidth,
      );
    } else {
      mediaWidget = const SizedBox.shrink(key: ValueKey('no_media'));
    }

    final embeddedMedia = (hasShimmer || message.hasAttachments)
        ? AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      layoutBuilder:
          (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: mediaWidget,
    )
        : null;

    // Text Content Widget (media is now embedded into the same tap/ripple container)
    final aiMessageContentWidget = AIMessageTile(
      message: message,
      avatarPath: correctImagePath,
      embeddedMedia: embeddedMedia,
      mediaAboveText: !shouldRenderMediaBelowHeader,
      onReport: onReport,
      onRegenerate: ({String? newModelId}) {
        debugPrint("[Tiles] Callback forwarding: '$newModelId'");
        onRegenerate(newModelId: newModelId);
      },
      onStop: onStop,
      parsedSpans: message.parsedSpans,
    );

    return Column(
      key: ValueKey('ai_message_${message.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showContent) aiMessageContentWidget,
      ],
    );
  }

  // --- UNIVERSAL ATTACHMENT BUILDER ---

  /// Renders a list of attachments (Images/Docs) using a Wrap layout.
  static Widget _buildAttachmentList({
    Key? key,
    required BuildContext context,
    required List<String> paths,
    required bool isUser,
    required double screenWidth,
  }) {
    final bool isTablet = screenWidth >= 600;

    // Dynamic sizing for items
    final double imageSize = isTablet ? screenWidth * 0.3 : screenWidth * 0.4;
    final double borderRadius = isTablet ? screenWidth * 0.015 : 12.0;

    return Wrap(
      key: key,
      alignment: isUser ? WrapAlignment.end : WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      spacing: 8.0,
      runSpacing: 8.0,
      children: paths.map((path) {
        final bool isImage = _isImageFile(path);
        final bool isAudio = _isAudioFile(path);
        final bool isVideo = _isVideoFile(path);

        // A. Audio Attachment
        if (isAudio) {
          return AudioPlayerWidget(
            audioPath: path,
            isUser: isUser,
            screenWidth: screenWidth,
          );
        }

        // B. Video Attachment
        if (isVideo) {
          return _VideoAttachmentCard(
            path: path,
            width: imageSize,
            height: imageSize * 0.7,
            borderRadius: borderRadius,
            isTablet: isTablet,
            screenWidth: screenWidth,
          );
        }

        // C. Image Attachment
        if (isImage) {
          final bool isNetworkImage =
              path.startsWith('http://') || path.startsWith('https://');
          final bool isDataImage = path.startsWith('data:image');
          final File file = File(path);
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            clipBehavior: Clip.hardEdge, // PERFORMANCE: hardEdge avoids saveLayer
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: isNetworkImage || isDataImage
                  ? null
                  : () => Navigator.push(
                        context,
                        PhotoViewer.route(
                          file,
                          onEditImage: (imageFile) {
                            // Add image as attachment and request keyboard focus
                            final inputProvider =
                                Provider.of<InputProvider>(context, listen: false);
                            inputProvider.addAttachment(imageFile, isImage: true);
                          },
                        ),
                      ),
              child: Hero(
                tag: path, // Basic hero tag
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: isDataImage
                      ? Image.memory(
                    base64Decode(path
                        .split(',')
                        .last),
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image,
                        color: Colors.grey),
                  )
                      : isNetworkImage
                      ? Image.network(
                    path,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image,
                        color: Colors.grey),
                  )
                      : Image.file(
                    file,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image,
                        color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        }

        // D. Document/File Attachment
        else {
          return Container(
            width: imageSize, // Keep same width as images for grid consistency
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: AppColors.tertiaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getFileIcon(path),
                  color: AppColors.primaryColor.inverted,
                  size: screenWidth * 0.08,
                ),
                const SizedBox(height: 6),
                Text(
                  p.basename(path),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: isTablet ? screenWidth * 0.018 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
      }).toList(),
    );
  }

  // --- HELPERS ---

  static bool _isAudioFile(String path) {
    final normalized = path
        .split('?')
        .first
        .toLowerCase();
    if (normalized.startsWith('data:audio')) return true;
    final ext = p.extension(normalized).toLowerCase().replaceAll('.', '');
    return ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg'].contains(ext);
  }

  static bool _isImageFile(String path) {
    final normalized = path
        .split('?')
        .first
        .toLowerCase();
    if (normalized.startsWith('data:image')) return true;
    final ext = p.extension(normalized).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
  }

  static bool _isVideoFile(String path) {
    final normalized = path
        .split('?')
        .first
        .toLowerCase();
    if (normalized.startsWith('data:video')) return true;
    final ext = p.extension(normalized).toLowerCase().replaceAll('.', '');
    return ['mp4', 'webm', 'mov', 'mkv', 'm4v'].contains(ext);
  }

  static IconData _getFileIcon(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart_rounded;
      case 'txt':
      case 'md':
        return Icons.text_snippet_rounded;
      case 'json':
      case 'xml':
      case 'html':
      case 'dart':
      case 'js':
      case 'py':
        return Icons.code_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  // --- TOP LEVEL BUILDERS (Unchanged Logic, just wiring) ---

  static Widget buildMessageTile({
    required BuildContext context,
    required Message message,
    required int index,
    Key? key,
    required bool isEditingMode,
    required int? editingMessageIndex,
    required VoidCallback onEdit,
    VoidCallback? onFadeOutComplete,
    required double screenWidth,
    required double screenHeight,
    required String modelId,
    required VoidCallback onReport,
    required void Function({String? newModelId}) onRegenerate,
    required VoidCallback onStop,
    required ModelService modelService,
  }) {
    if (message.isUserMessage) {
      return RepaintBoundary( // PERFORMANCE: Repaint Boundary
        child: buildUserMessageTile(
        context: context,
        message: message,
        index: index,
        key: key,
        isEditingMode: isEditingMode,
        editingMessageIndex: editingMessageIndex,
        onEdit: onEdit,
        onFadeOutComplete: onFadeOutComplete,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
      );
    } else {
      return RepaintBoundary( // PERFORMANCE: Repaint Boundary
        child: buildAIMessageTile(
        context: context,
        message: message,
        modelId: modelId,
        onReport: onReport,
        onRegenerate: onRegenerate,
        onStop: onStop,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        modelService: modelService,
      ),
      );
    }
  }

  static Widget buildMessagesList({
    required BuildContext context,
    required List<Message> messages,
    required ScrollController scrollController,
    required bool isEditingMode,
    required int? editingMessageIndex,
    required String modelId,
    required VoidCallback onStop,
    required ValueChanged<int> onEdit,
    ValueChanged<int>? onFadeOutComplete,
    required void Function(int index, {String? newModelId}) onRegenerate,
    required ValueChanged<int> onReport,
    double bottomPadding = 0.0,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final modelService = context.read<ModelService>();
    final double statusBarHeight = mediaQuery.padding.top;
    final double totalTopPadding = statusBarHeight;

    // Pre-compute separator to avoid closure allocation per frame
    final separatorWidget = SizedBox(height: screenHeight * 0.01);

    // Filter invisible messages but keep track of original indices
    final List<int> visibleIndices = [];
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].isVisible) {
        visibleIndices.add(i);
      }
    }

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.only(
          top: totalTopPadding, bottom: bottomPadding + (screenHeight * 0.01)),
      cacheExtent: 2500, // PERFORMANCE: Keep generous cache extent for smooth scrolling
      addAutomaticKeepAlives: false, // PERFORMANCE: Let cacheExtent manage viewport window instead of keeping ALL tiles alive
      addRepaintBoundaries: true, // PERFORMANCE: Independent Repaint boundaries per tile
      itemCount: visibleIndices.length,
      separatorBuilder: (context, index) => separatorWidget,
      itemBuilder: (context, index) {
        final int realIndex = visibleIndices[index];
        Message message = messages[realIndex];

        final bool isMessageUnderEdit = isEditingMode &&
            editingMessageIndex != null &&
            realIndex > editingMessageIndex;
        if (isMessageUnderEdit) {
          message = message.copyWith(opacity: 0.0);
        }

        return buildMessageTile(
          context: context,
          message: message,
          index: realIndex,
          key: ValueKey(message.id),
          isEditingMode: isEditingMode,
          editingMessageIndex: editingMessageIndex,
          onEdit: () => onEdit(realIndex),
          onFadeOutComplete: isMessageUnderEdit
              ? null
              : () => onFadeOutComplete?.call(realIndex),
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          modelId: modelId,
          onReport: () => onReport(realIndex),
          onRegenerate: ({String? newModelId}) {
            onRegenerate(realIndex, newModelId: newModelId);
          },
          onStop: onStop,
          modelService: modelService,
        );
      },
    );
  }
}

class _VideoAttachmentCard extends StatefulWidget {
  final String path;
  final double width;
  final double height;
  final double borderRadius;
  final bool isTablet;
  final double screenWidth;

  const _VideoAttachmentCard({
    required this.path,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.isTablet,
    required this.screenWidth,
  });

  @override
  State<_VideoAttachmentCard> createState() => _VideoAttachmentCardState();
}

class _VideoAttachmentCardState extends State<_VideoAttachmentCard> {
  VideoPlayerController? _previewController;
  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePreview();
  }

  Future<void> _initializePreview() async {
    try {
      final source = widget.path;
      final controller =
      source.startsWith('http://') || source.startsWith('https://')
          ? VideoPlayerController.networkUrl(Uri.parse(source))
          : VideoPlayerController.file(File(source));

      await controller.initialize();
      await controller.seekTo(Duration.zero);
      await controller.pause();

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _previewController = controller;
        _isReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _previewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.borderRadius);
    final iconSize =
    widget.isTablet ? widget.screenWidth * 0.08 : widget.screenWidth * 0.12;

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.hardEdge, // PERFORMANCE: hardEdge avoids saveLayer
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => Navigator.push(context, VideoViewer.route(widget.path)),
        child: Ink(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.tertiaryColor.withValues(alpha: 0.2),
            borderRadius: borderRadius,
            border: Border.all(
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.01),
              width: 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: borderRadius,
                child: _buildPreviewContent(),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.06),
                        Colors.black.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  size: iconSize,
                  color: Colors.white.withValues(alpha: 0.86),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    final controller = _previewController;
    if (_isReady && controller != null && controller.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }

    if (_hasError) {
      return Container(
        color: AppColors.tertiaryColor.withValues(alpha: 0.3),
        alignment: Alignment.center,
        child: Icon(
          Icons.videocam_rounded,
          color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
          size: widget.isTablet
              ? widget.screenWidth * 0.06
              : widget.screenWidth * 0.08,
        ),
      );
    }

    return Container(
      color: AppColors.tertiaryColor.withValues(alpha: 0.28),
      alignment: Alignment.center,
      child: SizedBox(
        width: widget.isTablet
            ? widget.screenWidth * 0.04
            : widget.screenWidth * 0.06,
        height: widget.isTablet
            ? widget.screenWidth * 0.04
            : widget.screenWidth * 0.06,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
