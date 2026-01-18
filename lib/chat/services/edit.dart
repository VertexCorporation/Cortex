// lib/chat/services/edit.dart

import 'dart:async';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/scroll.dart';
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

  // NEW: Method to update controller references when ChatInputPanel rebuilds
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
    final String? newPhotoPath = _inputProvider.selectedPhoto?.path;
    final originalMessage = originalMessages[editingIndex];

    final String originalPhotoPath = originalMessage.photoPath ?? '';
    final String normalizedNewPhotoPath = newPhotoPath ?? '';

    final bool textChanged = newText != originalMessage.text;
    final bool photoChanged = normalizedNewPhotoPath != originalPhotoPath;

    debugPrint(
      "[EditService] Original vs New → "
          "originalText='${originalMessage.text}', "
          "originalPhotoPath=$originalPhotoPath, "
          "newText='$newText', "
          "newPhotoPath=$normalizedNewPhotoPath, "
          "textChanged=$textChanged, photoChanged=$photoChanged",
    );

    if (!textChanged && !photoChanged) {
      debugPrint("[EditService] Nothing changed. Cancelling edit mode.");
      cancelEditingMode();
      return;
    }

    final bool clearPhoto = photoChanged && newPhotoPath == null;

    List<Message> updatedList =
    List<Message>.from(originalMessages.sublist(0, editingIndex));

    final updatedMessage = originalMessage.copyWith(
      text: newText,
      photoPath: newPhotoPath,
      opacity: 1.0,
      includeInContext: true,
      clearPhoto: clearPhoto,
    );

    updatedList.add(updatedMessage);

    debugPrint(
      "[EditService] Updated user message prepared at index $editingIndex → "
          "finalPhotoPath=${updatedMessage.photoPath}, "
          "updatedList.length=${updatedList.length}",
    );

    _conversationProvider.loadMessages(updatedList);
    debugPrint(
      "[EditService] ConversationProvider.loadMessages called "
          "with updatedList.length=${updatedList.length}",
    );

    // 4) input UI cleanup
    _inputProvider.finishEditing();
    _controller.clear();
    await _panelController.reverse();
    _ensureKeyboardFocus();

    final int newAiMessageIndex = updatedList.length;

    debugPrint(
      "[EditService] Triggering regenerate for newAiMessageIndex=$newAiMessageIndex. "
          "LastUser.photoPath=${updatedList
          .lastWhere((m) => m.isUserMessage)
          .photoPath}",
    );

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
    // Do not start a new edit session if one is already active.
    if (_inputProvider.isEditingMode) {
      debugPrint(
          "[EditService] startEditingMessage ignored: already in editing mode.");
      return;
    }

    final messages = _conversationProvider.messages;
    debugPrint(
      "[EditService] startEditingMessage called for index=$index, "
          "currentMessages.length=${messages.length}",
    );

    if (index < 0 || index >= messages.length) {
      debugPrint(
          "[EditService] startEditingMessage aborted: index out of range.");
      return;
    }

    // Hide the scroll-down button immediately while entering edit mode.
    _scrollService.hideButtonImmediately();

    // Backup the full original list so we can:
    // - restore it if the user cancels editing
    // - use it as the source of truth when regenerating the AI reply
    _messagesBeforeEdit = List<Message>.from(messages);
    debugPrint(
      "[EditService] Backup of messages created. backupLength=${_messagesBeforeEdit!
          .length}",
    );

    // Build a "visible" subset that only includes messages up to (and including)
    // the one being edited. This ensures:
    // - no extra scroll area below the edited message
    // - any photos in later messages are completely removed from the list
    final List<Message> visibleSubset = messages.sublist(0, index + 1);
    debugPrint(
      "[EditService] Visible subset created. visibleSubset.length=${visibleSubset
          .length}",
    );

    // Load the truncated list into the conversation provider so the UI behaves
    // as if later messages do not exist at all during editing.
    _conversationProvider.loadMessages(visibleSubset);

    // The message to edit is now the last item in the visible subset.
    final messageToEdit = visibleSubset[index];
    debugPrint(
      "[EditService] messageToEdit index=$index → "
          "text='${messageToEdit.text.substring(
          0, messageToEdit.text.length.clamp(0, 50))}', "
          "photoPath=${messageToEdit.photoPath}",
    );

    // Inform the InputProvider that editing has started for this index.
    _inputProvider.startEditing(index, messageToEdit);

    // Show the top edit panel.
    _panelController.forward();

    // Fill the input field with the existing text and place the cursor at the end.
    _controller.text = messageToEdit.text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );

    // Ensure the keyboard is focused shortly after the panel animation starts.
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