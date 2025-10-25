// lib/chat/services/edit.dart

import 'dart:async';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../messages/messages.dart';

/// Service responsible for managing the message editing lifecycle.
class EditService {
  final InputProvider _inputProvider;
  final ConversationProvider _conversationProvider;
  final RegenerateService _regenerateService;
  final ScrollService _scrollService;
  final TextEditingController _controller;
  final FocusNode _focusNode;
  final AnimationController _panelController;

  List<Message>? _messagesBeforeEdit;

  EditService({
    required InputProvider inputProvider,
    required ConversationProvider conversationProvider,
    required RegenerateService regenerateService,
    required ScrollService scrollService,
    required TextEditingController controller,
    required FocusNode focusNode,
    required AnimationController panelController,
  })  : _inputProvider = inputProvider,
        _conversationProvider = conversationProvider,
        _regenerateService = regenerateService,
        _scrollService = scrollService,
        _controller = controller,
        _focusNode = focusNode,
        _panelController = panelController;

  Future<void> applyEditedMessage(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;

    final int? editingIndex = _inputProvider.editingMessageIndex;
    // We no longer need _messagesBeforeEdit for the core logic, just for the original message comparison.
    final List<Message> originalMessages = _messagesBeforeEdit ?? _conversationProvider.messages;

    if (editingIndex == null || editingIndex >= originalMessages.length) {
      cancelEditingMode();
      return;
    }

    final String newText = _controller.text.trim();
    final String? newPhotoPath = _inputProvider.selectedPhoto?.path;
    final originalMessage = originalMessages[editingIndex];

    // Check if anything actually changed.
    final bool textChanged = newText != originalMessage.text;
    final bool photoChanged = newPhotoPath != originalMessage.photoPath;
    if (!textChanged && !photoChanged) {
      cancelEditingMode();
      return;
    }

    // --- REFACTORED ATOMIC UPDATE ---
    // 1. Create the new, definitive message list by truncating to the edit point.
    List<Message> updatedList = List.from(originalMessages.sublist(0, editingIndex));

    // 2. Add the updated user message.
    final updatedMessage = originalMessage.copyWith(
      text: newText,
      photoPath: newPhotoPath,
      opacity: 1.0,
      includeInContext: true, // Ensure it's re-included in context
    );
    updatedList.add(updatedMessage);

    // 3. Load this final, correct state into the provider. The UI will update instantly.
    _conversationProvider.loadMessages(updatedList);

    // 4. Clean up the input UI.
    _inputProvider.finishEditing();
    _controller.clear();
    await _panelController.reverse();
    _ensureKeyboardFocus();

    // 5. Now, trigger regeneration. The index for the new AI response is simply
    //    the new length of our updated list.
    final int newAiMessageIndex = updatedList.length;

    // We no longer need the complex if/else, as the new `onRegenerate` handles
    // the append case gracefully.
    await _regenerateService.onRegenerate(
      newAiMessageIndex,
      localizations: localizations,
      context: context,
    );

    // The backup is no longer needed for regeneration logic. Clean it up.
    _clearBackup();
    // --- REFACTOR END ---
  }

  void startEditingMessage(int index) async {
    if (_inputProvider.isEditingMode) return;

    final messages = _conversationProvider.messages;
    if (index < 0 || index >= messages.length) return;

    _scrollService.hideButtonImmediately();

    _messagesBeforeEdit = List.from(messages);
    final messageToEdit = messages[index];

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