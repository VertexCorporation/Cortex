// lib/chat/screen/selected/tiles.dart

import 'package:universal_io/io.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p; // Standard path manipulation
import 'package:cortex/app.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/messages/viewer.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../library/backend/data/service.dart';
import '../../messages/tiles/ai.dart';
import '../../messages/tiles/user.dart';
import 'audio_player.dart';

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
              Icon(Icons.info_outline,
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
        if (message.text.trim().isNotEmpty)
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
    final bool isTablet = screenWidth >= 600;
    final langCode = Localizations.localeOf(context).languageCode;
    final preciseModelId = message.model ?? modelId;

    final model =
        modelService.getPreciseModelData(preciseModelId, langCode: langCode);
    final correctImagePath = modelService.getModelImagePath(model);

    final bool hasText = message.text.trim().isNotEmpty;
    // [FIX] Show placeholder even if isThinking is false, provided we have no text/attachments and no error
    // This handles the gap between "Thinking done" and "First token arrived"
    final bool showContent = hasText ||
        message.isThinking ||
        (!message.hasAttachments && !message.isError);

    // Dimensions
    final double leftPadding =
        isTablet ? screenWidth * 0.03 : screenWidth * 0.04;

    // 1. Text Content Widget
    final aiMessageContentWidget = AIMessageTile(
      message: message,
      avatarPath: correctImagePath,
      onReport: onReport,
      onRegenerate: ({String? newModelId}) {
        debugPrint("[Tiles] Callback forwarding: '$newModelId'");
        onRegenerate(newModelId: newModelId);
      },
      onStop: onStop,
      parsedSpans: message.parsedSpans,
    );

    // 2. Attachments Widget (e.g. Generated Images)
    Widget attachmentWidget = const SizedBox.shrink();

    if (message.hasAttachments) {
      attachmentWidget = Padding(
        padding: EdgeInsets.only(
          left: leftPadding,
          bottom: (showContent) ? screenHeight * 0.006 : 0,
        ),
        child: _buildAttachmentList(
          context: context,
          paths: message.attachmentPaths,
          isUser: false,
          screenWidth: screenWidth,
        ),
      );
    }

    return Column(
      key: ValueKey('ai_message_${message.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        attachmentWidget,
        if (showContent) aiMessageContentWidget,
      ],
    );
  }

  // --- UNIVERSAL ATTACHMENT BUILDER ---

  /// Renders a list of attachments (Images/Docs) using a Wrap layout.
  static Widget _buildAttachmentList({
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
      alignment: isUser ? WrapAlignment.end : WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      spacing: 8.0,
      runSpacing: 8.0,
      children: paths.map((path) {
        final File file = File(path);
        final bool isImage = _isImageFile(path);
        final bool isAudio = _isAudioFile(path);

        // A. Audio Attachment
        if (isAudio) {
          return AudioPlayerWidget(
            audioPath: path,
            isUser: isUser,
            screenWidth: screenWidth,
          );
        }

        // B. Image Attachment
        if (isImage) {
          return GestureDetector(
            onTap: () => Navigator.push(context, PhotoViewer.route(file)),
            child: Hero(
              tag: path, // Basic hero tag
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Image.file(
                  file,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          );
        }

        // B. Document/File Attachment
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
    if (path.startsWith('data:audio')) return true;
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg'].contains(ext);
  }

  static bool _isImageFile(String path) {
    if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('data:image')) {
      return true;
    }
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
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
      return buildUserMessageTile(
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
      );
    } else {
      return buildAIMessageTile(
        context: context,
        message: message,
        modelId: modelId,
        onReport: onReport,
        onRegenerate: onRegenerate,
        onStop: onStop,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        modelService: modelService,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final modelService = context.read<ModelService>();
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalTopPadding = statusBarHeight;

    // Filter invisible messages but keep track of original indices
    final List<int> visibleIndices = [];
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].isVisible) {
        visibleIndices.add(i);
      }
    }

    return ListView.separated(
      controller: scrollController,
      padding:
          EdgeInsets.only(top: totalTopPadding, bottom: bottomPadding + (screenHeight * 0.01)),
      cacheExtent: 500,
      itemCount: visibleIndices.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: screenHeight * 0.01),
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
