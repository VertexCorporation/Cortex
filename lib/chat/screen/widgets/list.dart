// lib/chat/screen/widgets/list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Internal Imports ---
import 'package:cortex/theme.dart';
import 'package:cortex/fog.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/edit.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/stop.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/chat/screen/widgets/tiles.dart';
import 'package:cortex/chat/messages/options/report.dart';

class ChatMessageList extends StatelessWidget {
  final ScrollController scrollController;
  final EditService editService;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.editService,
  });

  @override
  Widget build(BuildContext context) {
    final conversationProvider = context.watch<ConversationProvider>();
    final sessionProvider = context.watch<ChatSessionProvider>();
    final inputProvider = context.watch<InputProvider>();

    final messages = conversationProvider.messages;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Expanded(
          child: ScrollFog(
            scrollController: scrollController,
            fogColor: AppColors.background,
            topFogHeight: screenHeight * 0.02,
            bottomFogHeight: screenHeight * 0.02,
            child: Tiles.buildMessagesList(
              context: context,
              messages: messages.toList(),
              scrollController: scrollController,

              modelId: sessionProvider.modelId ?? '',
              isEditingMode: inputProvider.isEditingMode,
              editingMessageIndex: inputProvider.editingMessageIndex,

              onStop: context.read<StopService>().stopResponse,

              onEdit: (index) => editService.startEditingMessage(index),

              onFadeOutComplete: (index) =>
                  context.read<ConversationProvider>().removeMessageAtIndex(index),

              onRegenerate: (int index, {String? newModelId}) {
                _handleRegenerate(context, index, newModelId, sessionProvider.isDynamicChat);
              },

              onReport: (index) {
                _handleReport(context, index, conversationProvider);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegenerate(
      BuildContext context,
      int index,
      String? newModelId,
      bool isDynamic
      ) {
    context.read<RegenerateService>().onRegenerate(
      index,
      context: context,
      newModelId: newModelId,
      isDynamicRegenerate: isDynamic,
    );
  }

  void _handleReport(
      BuildContext context,
      int index,
      ConversationProvider conversationProvider
      ) {
    final messages = conversationProvider.messages;
    if (index < 0 || index >= messages.length) return;

    final message = messages[index];
    final modelId = message.model;

    if (modelId == null) return;

    ReportDialog.show(
      context,
      aiMessage: message.text,
      modelId: modelId,
      onReportSuccess: () {
        final updatedMessage = message.copyWith(isReported: true);
        conversationProvider.updateMessageAtIndex(index, updatedMessage);

        if (conversationProvider.conversationID != null) {
          ChatStorageService.updateStoredMessage(
            conversationProvider.conversationID!,
            updatedMessage,
            index,
          );
        }
      },
    );
  }
}