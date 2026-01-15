// lib/chat/screen/selected/tiles.dart

import 'dart:io';
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

/// A utility class that acts as a factory for building different types of message widgets.
class Tiles {
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
    final isEditingThisMessage = isEditingMode &&
        (editingMessageIndex == index);
    final bool isTablet = screenWidth >= 600;

    // --- DYNAMIC DIMENSIONS ---
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
      firstChild: Padding(
        key: ValueKey('editing_$index'),
        padding: EdgeInsets.all(padding),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.02
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryColor.inverted,
                  size: iconSize),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.editingMessageInfo,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.primaryColor.inverted,
                      fontSize: fontSize),
                ),
              ),
            ],
          ),
        ),
      ),
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

  /// Builds the standard content for a user message, including the photo and text bubble.
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
    final bool hasPhoto = message.photoPath != null;
    final bool isImage = hasPhoto && _isImageFile(message.photoPath!);

    // --- DYNAMIC DIMENSIONS ---
    // Image Width: Tablet 30% (prevents huge images), Phone 40%.
    final double imageWidth = isTablet ? screenWidth * 0.3 : screenWidth * 0.4;
    // Padding: Tablet 3%, Phone 4%.
    final double rightPadding = isTablet ? screenWidth * 0.03 : screenWidth *
        0.04;
    final double borderRadius = isTablet ? screenWidth * 0.015 : 8.0;

    return Column(
      key: ValueKey('normal_user_$index'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasPhoto && isImage)
          Padding(
            padding: EdgeInsets.only(
                right: rightPadding,
                bottom: screenHeight * 0.006
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () =>
                    Navigator.push(
                        context, PhotoViewer.route(File(message.photoPath!))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Image.file(
                    File(message.photoPath!),
                    width: imageWidth,
                    height: imageWidth, // Square aspect ratio
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(
                            Icons.broken_image, color: AppColors.tertiaryColor),
                  ),
                ),
              ),
            ),
          )
        else
          if (hasPhoto && !isImage)
            Container(
              margin: EdgeInsets.only(right: rightPadding, bottom: 8),
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                  color: AppColors.tertiaryColor,
                  borderRadius: BorderRadius.circular(borderRadius)
              ),
              child: Icon(Icons.insert_drive_file, color: Colors.black54,
                  size: screenWidth * 0.06),
            ),

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

  /// Builds an AI's message tile, which can include a photo and a text bubble.
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
    final langCode = Localizations
        .localeOf(context)
        .languageCode;
    final preciseModelId = message.model ?? modelId;

    final model = modelService.getPreciseModelData(
        preciseModelId, langCode: langCode);
    final correctImagePath = modelService.getModelImagePath(model);

    final bool hasPhoto = message.photoPath != null &&
        message.photoPath!.isNotEmpty;
    final bool isImage = hasPhoto && _isImageFile(message.photoPath!);

    final bool hasText = message.text
        .trim()
        .isNotEmpty;
    final bool isThinkingWithoutContent = message.isThinking && !hasPhoto &&
        !hasText;

    // --- DYNAMIC DIMENSIONS ---
    final double leftPadding = isTablet ? screenWidth * 0.03 : screenWidth *
        0.04;
    // Image Width: Tablet 30%, Phone 40%.
    final double imageWidth = isTablet ? screenWidth * 0.3 : screenWidth * 0.4;
    final double borderRadius = isTablet ? screenWidth * 0.015 : 8.0;

    final aiMessageContentWidget = AIMessageTile(
      message: message,
      avatarPath: correctImagePath,
      onReport: onReport,
      onRegenerate: ({String? newModelId}) {
        debugPrint(
            "[Tiles.buildAIMessageTile] Callback forwarding: '$newModelId'");
        onRegenerate(newModelId: newModelId);
      },
      onStop: onStop,
      parsedSpans: message.parsedSpans,
    );

    Widget photoWidget;

    if (hasPhoto && isImage) {
      photoWidget = Padding(
        padding: EdgeInsets.only(
          left: leftPadding,
          bottom: (hasText || isThinkingWithoutContent)
              ? screenHeight * 0.006
              : 0,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () =>
                Navigator.push(
                    context, PhotoViewer.route(File(message.photoPath!))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.file(
                File(message.photoPath!),
                width: imageWidth,
                height: imageWidth,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    } else if (hasPhoto && !isImage) {
      photoWidget = Padding(
        padding: EdgeInsets.only(
          left: leftPadding,
          bottom: (hasText || isThinkingWithoutContent)
              ? screenHeight * 0.006
              : 0,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: imageWidth,
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
                color: AppColors.tertiaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(borderRadius)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.description, color: AppColors.primaryColor.inverted,
                    size: screenWidth * 0.08),
                const SizedBox(height: 4),
                Text(
                  message.photoPath!.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: isTablet ? screenWidth * 0.02 : 12
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      photoWidget = const SizedBox.shrink();
    }

    return Column(
      key: ValueKey('ai_message_${message.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        photoWidget,
        if (hasText || isThinkingWithoutContent) aiMessageContentWidget,
      ],
    );
  }

  /// A top-level builder that determines whether to build a user or an AI message tile.
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

  /// The main factory method that builds the entire scrollable list of messages.
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
  }) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final modelService = context.read<ModelService>();

    final double statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;

    final double totalTopPadding = statusBarHeight;

    return ListView.separated(
      controller: scrollController,

      padding: EdgeInsets.only(
          top: totalTopPadding,
          bottom: screenHeight * 0.01
      ),

      cacheExtent: 500,
      itemCount: messages.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: screenHeight * 0.01),
      itemBuilder: (context, index) {
        Message message = messages[index];
        final bool isMessageUnderEdit = isEditingMode &&
            editingMessageIndex != null && index > editingMessageIndex;
        if (isMessageUnderEdit) {
          message = message.copyWith(opacity: 0.0);
        }

        return buildMessageTile(
          context: context,
          message: message,
          index: index,
          key: ValueKey(messages[index].id),
          isEditingMode: isEditingMode,
          editingMessageIndex: editingMessageIndex,
          onEdit: () => onEdit(index),
          onFadeOutComplete: isMessageUnderEdit ? null : () =>
              onFadeOutComplete?.call(index),
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          modelId: modelId,
          onReport: () => onReport(index),
          onRegenerate: ({String? newModelId}) {
            onRegenerate(index, newModelId: newModelId);
          },
          onStop: onStop,
          modelService: modelService,
        );
      },
    );
  }

  static bool _isImageFile(String path) {
    final ext = path
        .split('.')
        .last
        .toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext);
  }
}