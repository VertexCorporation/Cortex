// tiles.dart

import 'dart:io';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/messages/viewer.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';

import '../../../models/backend/data.dart';
import '../../messages/tiles/ai.dart';
import '../../messages/tiles/user.dart';

class Tiles {
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
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      crossFadeState:
      isEditingThisMessage ? CrossFadeState.showFirst : CrossFadeState
          .showSecond,
      sizeCurve: Curves.easeInOut,
      alignment: Alignment.centerRight,
      firstChild: Padding(
        key: ValueKey('editing_$index'),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  color: AppColors.primaryColor.inverted, size: 20),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.editingMessageInfo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      secondChild: buildNormalContent(
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

  static Widget buildNormalContent({
    required BuildContext context,
    required Message message,
    required int index,
    Key? key,
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onEdit,
    VoidCallback? onFadeOutComplete,
  }) {
    return Column(
      key: ValueKey('normal_$index'),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (message.photoPath != null)
          Padding(
            padding: EdgeInsets.only(
              right: screenWidth * 0.04,
              bottom: screenHeight * 0.006,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PhotoViewer.route(File(message.photoPath!)),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, opacity, child) =>
                        Opacity(opacity: opacity, child: child),
                    child: Image.file(
                      File(message.photoPath!),
                      width: screenWidth * 0.4,
                      height: screenWidth * 0.4,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (message.text
            .trim()
            .isNotEmpty)
          UserMessageTile(
            key: key,
            text: message.text,
            opacity: message.opacity,
            onFadeOutComplete: onFadeOutComplete,
            onEdit: onEdit,
          ),
      ],
    );
  }

  static Widget buildAIMessageTile({
    required BuildContext context,
    required Message message,
    required int index,
    Key? key,
    required String modelId,
    required VoidCallback onReport,
    required VoidCallback onRegenerate,
    required VoidCallback onStop,
    required Function(String newExtension) onChangeModel,
    required double screenWidth,
    required double screenHeight,
  }) {
    final preciseModelId = message.model ?? modelId;
    final modelData = ModelData.getPreciseModelData(preciseModelId);
    final correctImagePath = modelData['imagePath'] as String? ?? 'assets/icons/self.svg';

    // --- THE PERFECT FIX: Handle both text and photo visibility logically ---

    // Determine if there is visible content.
    final bool hasPhoto = message.photoPath != null && message.photoPath!.isNotEmpty;
    final bool hasText = message.text.trim().isNotEmpty;
    final bool isThinkingWithoutContent = message.isThinking && !hasPhoto && !hasText;

    // The main widget to display text content or the "thinking" animation.
    final aiMessageContentWidget = AIMessageTile(
      // The key should be on the parent-most widget for this message if possible,
      // but putting it here is also effective.
      key: key,
      text: message.text,
      avatarPath: correctImagePath,
      opacity: message.opacity,
      modelId: preciseModelId,
      isReported: message.isReported,
      isError: message.isError,
      onReport: onReport,
      onRegenerate: onRegenerate,
      onStop: onStop,
      onChangeModel: onChangeModel,
      parsedSpans: message.parsedSpans,
      isThinking: message.isThinking,
    );

    // The widget to display the generated photo.
    final photoWidget = hasPhoto ? Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.04,
        // Add bottom padding only if there is text below it.
        bottom: (hasText || isThinkingWithoutContent) ? screenHeight * 0.006 : 0,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PhotoViewer.route(File(message.photoPath!)),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 200),
              builder: (context, opacity, child) =>
                  Opacity(opacity: opacity, child: child),
              child: Image.file(
                File(message.photoPath!),
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ) : const SizedBox.shrink(); // If no photo, render nothing.

    // Combine them in a Column.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always display the photo first if it exists.
        photoWidget,

        // Display the text/thinking bubble if there is text OR if it's in a thinking state.
        if (hasText || isThinkingWithoutContent)
          aiMessageContentWidget,
      ],
    );
  }

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
    required ValueNotifier<bool> streamingNotifier,
    required VoidCallback onReport,
    required VoidCallback onRegenerate,
    required VoidCallback onStop,
    required Function(String newExtension) onChangeModel,
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
        index: index,
        key: key,
        modelId: modelId,
        onReport: onReport,
        onRegenerate: onRegenerate,
        onStop: onStop,
        onChangeModel: onChangeModel,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      );
    }
  }

  static Widget buildMessagesList({
    required BuildContext context,
    required List<Message> messages,
    required ScrollController scrollController,
    required bool isEditingMode,
    required int? editingMessageIndex,
    required ValueNotifier<bool> streamingNotifier,
    required String modelId,
    required VoidCallback onStop,
    required Function(int index) onEdit,
    Function(int index)? onFadeOutComplete,
    required Function(int index) onRegenerate,
    required Function(int index, String newExtension) onChangeModel,
    required Function(int index) onReport,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      cacheExtent: 500,
      itemCount: messages.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: screenHeight * 0.01),
      itemBuilder: (context, index) {
        final Message message = messages[index];
        final bool underEditing =
            isEditingMode &&
                editingMessageIndex != null &&
                index > editingMessageIndex;
        return buildMessageTile(
          context: context,
          message: message,
          index: index,
          key: ValueKey(message.id),
          isEditingMode: isEditingMode,
          editingMessageIndex: editingMessageIndex,
          onEdit: () => onEdit(index),
          onFadeOutComplete: underEditing ? null : () =>
              onFadeOutComplete!(index),
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          modelId: modelId,
          streamingNotifier: streamingNotifier,
          onReport: () => onReport(index),
          onRegenerate: () => onRegenerate(index),
          onStop: onStop,
          onChangeModel: (newExtension) => onChangeModel(index, newExtension),
        );
      },
    );
  }
}