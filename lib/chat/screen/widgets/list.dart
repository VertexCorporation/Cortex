// lib/chat/screen/widgets/list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/edit.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/stop.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/chat/screen/widgets/tiles.dart';
import 'package:cortex/chat/messages/options/report.dart';

class ChatMessageList extends StatefulWidget {
  final ScrollController scrollController;
  final EditService editService;
  final double bottomPadding;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.editService,
    this.bottomPadding = 0.0,
  });

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  @override
  void initState() {
    super.initState();
    // Scroll to bottom on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomIfNeeded();
    });
  }

  void _scrollToBottomIfNeeded() {
    if (!mounted) return;
    if (widget.scrollController.hasClients) {
      widget.scrollController
          .jumpTo(widget.scrollController.position.maxScrollExtent);
    }
  }

  @override
  void didUpdateWidget(covariant ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If we want to detect "new chat" specifically, we might need to watch the conversation ID.
    // For now, let's rely on the parent rebuild or key change if checking a new chat.
    // Usually, changing chats rebuilds this widget entirely if key changes.
  }

  @override
  Widget build(BuildContext context) {
    final conversationProvider = context.watch<ConversationProvider>();
    final sessionProvider = context.watch<ChatSessionProvider>();
    final inputProvider = context.watch<InputProvider>();

    final messages = conversationProvider.messages;

    // Scroll to bottom when messages just finished loading (switching chats)
    if (conversationProvider.justFinishedLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottomIfNeeded();
        // Consume the flag so we don't scroll again on every rebuild
        conversationProvider.consumeJustFinishedLoadingFlag();
      });
    }

    // Use a unique key based on conversation ID to force a fresh state (and thus initState scroll) when chat changes
    // This is the cleanest way to ensure "open new chat -> scroll to bottom".
    // We assume conversationProvider.conversationID changes.

    return Column(
      key: ValueKey(conversationProvider.conversationID),
      children: [
        Expanded(
          child: Tiles.buildMessagesList(
            context: context,
            messages: messages.toList(),
            scrollController: widget.scrollController,
            modelId: sessionProvider.modelId ?? '',
            isEditingMode: inputProvider.isEditingMode,
            editingMessageIndex: inputProvider.editingMessageIndex,
            bottomPadding: widget.bottomPadding,
            onStop: context.read<StopService>().stopResponse,
            onEdit: (index) => widget.editService.startEditingMessage(index),
            onFadeOutComplete: (index) => context
                .read<ConversationProvider>()
                .removeMessageAtIndex(index),
            onRegenerate: (int index, {String? newModelId}) {
              _handleRegenerate(
                  context, index, newModelId, sessionProvider.isDynamicChat);
            },
            onReport: (index) {
              _handleReport(context, index, conversationProvider);
            },
          ),
        ),
      ],
    );
  }

  void _handleRegenerate(
      BuildContext context, int index, String? newModelId, bool isDynamic) {
    context.read<RegenerateService>().onRegenerate(
          index,
          context: context,
          newModelId: newModelId,
          isDynamicRegenerate: isDynamic,
        );
  }

  void _handleReport(BuildContext context, int index,
      ConversationProvider conversationProvider) {
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
