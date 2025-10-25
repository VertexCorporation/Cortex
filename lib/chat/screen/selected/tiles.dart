// lib/chat/screen/selected/tiles.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/messages/viewer.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/models/backend/data/data.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import '../../messages/tiles/ai.dart';
import '../../messages/tiles/user.dart';

/// A utility class that acts as a factory for building different types of message widgets.
///
/// It centralizes the logic for constructing message tiles and the main messages list,
/// ensuring a consistent appearance and behavior throughout the chat screen.
class Tiles {
  /// Builds a user's message tile, handling the switch between normal and "editing" states.
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
    // --- NEW: Required parameters passed down for the child UserMessageTile ---
    required bool conversationHasPhoto,
    required bool isUserSubscribed,
    required int premiumTrialUses,
  }) {
    final isEditingThisMessage = isEditingMode && (editingMessageIndex == index);
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      crossFadeState: isEditingThisMessage
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
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
      secondChild: buildNormalUserContent(
        context: context,
        message: message,
        index: index,
        key: key,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        onEdit: onEdit,
        onFadeOutComplete: onFadeOutComplete,
        // Pass the new parameters down to the final builder.
        conversationHasPhoto: conversationHasPhoto,
        isUserSubscribed: isUserSubscribed,
        premiumTrialUses: premiumTrialUses,
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
    // --- NEW: Required parameters to be passed to UserMessageTile ---
    required bool conversationHasPhoto,
    required bool isUserSubscribed,
    required int premiumTrialUses,
  }) {
    return Column(
      key: ValueKey('normal_user_$index'),
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
        if (message.text.trim().isNotEmpty)
          UserMessageTile(
            key: key,
            text: message.text,
            opacity: message.opacity,
            onFadeOutComplete: onFadeOutComplete,
            onEdit: onEdit,
            conversationHasPhoto: conversationHasPhoto,
            isUserSubscribed: isUserSubscribed,
            premiumTrialUses: premiumTrialUses,
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
    required VoidCallback onRegenerate,
    required VoidCallback onStop,
    required ValueChanged<String> onChangeModel,
    required double screenWidth,
    required double screenHeight,
    required bool isPersistentlyDynamic,
    // --- NEW: Required parameters passed down for the child AIMessageTile ---
    required bool conversationHasPhoto,
    required bool isUserSubscribed,
    required int premiumTrialUses,
    required ValueNotifier<bool> isWaitingForResponseNotifier,
  }) {
    final preciseModelId = message.model ?? modelId;
    final modelData = ModelData.getPreciseModelData(preciseModelId);
    final correctImagePath = modelData['imagePath'] as String? ?? 'assets/icons/self.svg';

    final bool hasPhoto = message.photoPath != null && message.photoPath!.isNotEmpty;
    final bool hasText = message.text.trim().isNotEmpty;
    final bool isThinkingWithoutContent = message.isThinking && !hasPhoto && !hasText;

    final aiMessageContentWidget = AIMessageTile(
      text: message.text,
      avatarPath: correctImagePath,
      opacity: message.opacity,
      modelId: preciseModelId,
      isReported: message.isReported,
      isError: message.isError,
      isThinking: message.isThinking,
      isPersistentlyDynamic: isPersistentlyDynamic,
      onReport: onReport,
      onRegenerate: onRegenerate,
      onStop: onStop,
      onChangeModel: onChangeModel,
      parsedSpans: message.parsedSpans,
    );

    final photoWidget = hasPhoto
        ? Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.04,
        bottom: (hasText || isThinkingWithoutContent)
            ? screenHeight * 0.006
            : 0,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            PhotoViewer.route(File(message.photoPath!)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              File(message.photoPath!),
              width: screenWidth * 0.4,
              height: screenWidth * 0.4,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    )
        : const SizedBox.shrink();

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
    required VoidCallback onRegenerate,
    required VoidCallback onStop,
    required ValueChanged<String> onChangeModel,
    required bool isPersistentlyDynamic,
    // --- NEW: Required parameters to be passed down the chain ---
    required bool conversationHasPhoto,
    required bool isUserSubscribed,
    required int premiumTrialUses,
    required ValueNotifier<bool> isWaitingForResponseNotifier,
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
        // Pass the required data down to the user tile builder.
        conversationHasPhoto: conversationHasPhoto,
        isUserSubscribed: isUserSubscribed,
        premiumTrialUses: premiumTrialUses,
      );
    } else {
      return buildAIMessageTile(
        context: context,
        message: message,
        modelId: modelId,
        onReport: onReport,
        onRegenerate: onRegenerate,
        onStop: onStop,
        onChangeModel: onChangeModel,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        isPersistentlyDynamic: isPersistentlyDynamic,
        // Pass the required data down to the AI tile builder.
        conversationHasPhoto: conversationHasPhoto,
        isUserSubscribed: isUserSubscribed,
        premiumTrialUses: premiumTrialUses,
        isWaitingForResponseNotifier: isWaitingForResponseNotifier,
      );
    }
  }

  /// The main factory method that builds the entire scrollable list of messages.
  ///
  /// This is the entry point that should be called from the main UI. It reads
  /// the required data and passes it down to the individual tile builders.
  /// It now uses `reverse: true` to properly handle keyboard appearance.
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
    required ValueChanged<int> onRegenerate,
    required void Function(int index, String newExtension) onChangeModel,
    required ValueChanged<int> onReport,
    required bool isPersistentlyDynamic,
    required bool conversationHasPhoto,
    required bool isUserSubscribed,
    required int premiumTrialUses,
    required ValueNotifier<bool> isWaitingForResponseNotifier,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: screenHeight * 0.01,
        bottom: screenHeight * 0.01,
      ),
      cacheExtent: 500,
      itemCount: messages.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: screenHeight * 0.01),
      itemBuilder: (context, index) {
        Message message = messages[index];

        final bool isMessageUnderEdit = isEditingMode &&
            editingMessageIndex != null &&
            index > editingMessageIndex;

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
          onFadeOutComplete: isMessageUnderEdit ? null : () => onFadeOutComplete?.call(index),
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          modelId: modelId,
          onReport: () => onReport(index),
          onRegenerate: () => onRegenerate(index),
          onStop: onStop,
          onChangeModel: (newExtension) => onChangeModel(index, newExtension),
          isPersistentlyDynamic: isPersistentlyDynamic,
          conversationHasPhoto: conversationHasPhoto,
          isUserSubscribed: isUserSubscribed,
          premiumTrialUses: premiumTrialUses,
          isWaitingForResponseNotifier: isWaitingForResponseNotifier,
        );
      },
    );
  }
}