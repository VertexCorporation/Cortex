// lib/chat/services/edit.dart

import 'dart:async';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:flutter/foundation.dart'; // for listEquals
import 'package:flutter/material.dart';
import '../messages/messages.dart';

/// Service responsible for managing the message editing lifecycle.
class EditService {
  final InputProvider _inputProvider;
  final ConversationProvider _conversationProvider;
  final RegenerateService _regenerateService;
  final ScrollService _scrollService;
  final AnimationController _panelController;
  TextEditingController _controller;
  FocusNode _focusNode;

  List<Message>? _messagesBeforeEdit;

  EditService({
    required InputProvider inputProvider,
    required ConversationProvider conversationProvider,
    required RegenerateService regenerateService,
    required ScrollService scrollService,
    required TextEditingController controller,
    required FocusNode focusNode,
    required AnimationController panelController,
  })
      : _inputProvider = inputProvider,
        _conversationProvider = conversationProvider,
        _regenerateService = regenerateService,
        _scrollService = scrollService,
        _controller = controller,
        _focusNode = focusNode,
        _panelController = panelController;

  void updateControllers({
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
    _controller = controller;
    _focusNode = focusNode;
  }

  Future<void> applyEditedMessage(BuildContext context) async {
    final int? editingIndex = _inputProvider.editingMessageIndex;
    final List<Message> originalMessages =
        _messagesBeforeEdit ?? _conversationProvider.messages;

    if (editingIndex == null || editingIndex >= originalMessages.length) {
      cancelEditingMode();
      return;
    }

    final String newText = _controller.text.trim();

    // Get new list of attachment paths from InputProvider
    final List<String> newAttachmentPaths = _inputProvider.attachments
        .map((a) => a.file.path)
        .toList();

    final originalMessage = originalMessages[editingIndex];

    // Determine changes
    final bool textChanged = newText != originalMessage.text;
    final bool attachmentsChanged = !listEquals(
        newAttachmentPaths, originalMessage.attachmentPaths);

    debugPrint(
        "[EditService] textChanged=$textChanged, attachmentsChanged=$attachmentsChanged"
    );

    if (!textChanged && !attachmentsChanged) {
      debugPrint("[EditService] Nothing changed. Cancelling edit mode.");
      cancelEditingMode();
      return;
    }

    List<Message> updatedList =
    List<Message>.from(originalMessages.sublist(0, editingIndex));

    final updatedMessage = originalMessage.copyWith(
      text: newText,
      // UPDATED: Pass the new list of paths
      attachmentPaths: newAttachmentPaths,
      opacity: 1.0,
      includeInContext: true,
    );

    updatedList.add(updatedMessage);

    _conversationProvider.loadMessages(updatedList);

    // Cleanup
    _inputProvider.finishEditing();
    _controller.clear();
    await _panelController.reverse();
    _ensureKeyboardFocus();

    final int newAiMessageIndex = updatedList.length;

    if (context.mounted) {
      await _regenerateService.onRegenerate(
        newAiMessageIndex,
        context: context,
      );
    }

    _clearBackup();
    debugPrint("[EditService] applyEditedMessage completed. Backup cleared.");
  }

  void startEditingMessage(int index) async {
    if (_inputProvider.isEditingMode) return;

    final messages = _conversationProvider.messages;
    if (index < 0 || index >= messages.length) return;

    _scrollService.hideButtonImmediately();

    _messagesBeforeEdit = List<Message>.from(messages);

    final List<Message> visibleSubset = messages.sublist(0, index + 1);
    _conversationProvider.loadMessages(visibleSubset);

    final messageToEdit = visibleSubset[index];

    _inputProvider.startEditing(index, messageToEdit);

    _panelController.forward();

    _controller.text = messageToEdit.text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );

    await Future.delayed(const Duration(milliseconds: 100));
    _ensureKeyboardFocus();
  }

  void cancelEditingMode() {
    if (!_inputProvider.isEditingMode) return;

    if (_messagesBeforeEdit != null) {
      _conversationProvider.loadMessages(_messagesBeforeEdit!);
    }

    _inputProvider.cancelEditing();
    _panelController.reverse();

    _clearBackup();
    _controller.clear();

    _ensureKeyboardFocus();
  }

  void _ensureKeyboardFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _clearBackup() {
    _messagesBeforeEdit = null;
  }
}