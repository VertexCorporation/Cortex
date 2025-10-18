// edit.dart

import 'package:flutter/material.dart';
import '../chat.dart';
import '../messages/messages.dart';

/// Service responsible for managing the message editing lifecycle.
/// It handles entering and exiting edit mode, and applying the final changes
/// by delegating the resubmission to the RegenerateService.
class EditService {
  final ChatScreenState state;
  EditService({required this.state});

  // A temporary backup of the message list before an edit starts.
  List<Message>? _messagesBeforeEdit;

  /// This function now works on the message list that was already truncated
  /// by `startEditingMessage`. Its responsibilities are:
  /// 1. Capture the edited content.
  /// 2. Update the last message in the list (the one being edited).
  /// 3. Clean up the editing UI state and the message backup.
  /// 4. Delegate the "resend" operation to RegenerateService.
  Future<void> applyEditedMessage() async {
    final int? editingIndex = state.editingMessageIndex;
    if (editingIndex == null) return;

    // 1. Capture the final edited content.
    final String newText = state.controller.text.trim();
    final String? newPhotoPath = state.sendService.selectedPhoto?.path;

    final originalMessage = state.messages[editingIndex];

    // Ensure we don't proceed if there's no change.
    if (newText.isEmpty && newPhotoPath == null) {
      cancelEditingMode();
      return;
    }
    if (newText == state.originalMessageText && newPhotoPath == null && originalMessage.photoPath == null) {
      cancelEditingMode();
      return;
    }

    final updatedUserMessage = Message(
      id: originalMessage.id, // Keep the original ID for now.
      text: newText,
      isUserMessage: true,
      photoPath: newPhotoPath ?? originalMessage.photoPath,
      model: originalMessage.model,
    );

    // 2. Clean up the editing UI state.
    state.setState(() {
      // Replace the old message with the updated one.
      state.messages[editingIndex] = updatedUserMessage;

      // Exit editing mode and clear related state variables.
      state.isEditingMode = false;
      state.editingMessageIndex = null;
      state.originalMessageText = null;
      state.controller.clear();
      state.sendService.selectedPhoto = null;

      // The edit is confirmed, so clear the backup.
      _messagesBeforeEdit = null;
    });

    // Animate the edit panel away.
    await state.editPanelController.reverse();

    // 3. Delegate the core logic to RegenerateService.
    //    It will regenerate the AI message that should follow our edited message.
    await state.regenerateService.onRegenerate(editingIndex + 1);
  }

  /// This now immediately truncates the message list for a clean and predictable UI,
  /// backing up the original list in case of cancellation.
  void startEditingMessage(int index) {
    if (!state.mounted || state.isEditingMode) return;

    // Backup the current message list before making changes.
    _messagesBeforeEdit = List.from(state.messages);

    state.setState(() {
      final messageToEdit = state.messages[index];
      state.editingMessageIndex = index;
      state.originalMessageText = messageToEdit.text;

      // Truncate the list to only include messages up to and including the one being edited.
      // This correctly and instantly removes all subsequent messages from the view.
      state.messages = state.messages.sublist(0, index + 1);

      state.controller.text = messageToEdit.text;
      state.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: state.controller.text.length),
      );

      state.isEditingMode = true;
      state.editSessionCounter++; // Force InputField to rebuild with preselected photo etc.
    });

    FocusScope.of(state.context).requestFocus(state.textFieldFocusNode);
    state.editPanelController.forward();
  }

  /// This now restores the full message list from the backup created when
  /// the edit began.
  void cancelEditingMode() {
    if (!state.mounted) return;

    state.setState(() {
      // Restore the original message list from the backup.
      if (_messagesBeforeEdit != null) {
        state.messages = _messagesBeforeEdit!;
        _messagesBeforeEdit = null;
      }

      // Reset all editing-related state variables.
      state.editingMessageIndex = null;
      state.originalMessageText = null;
      state.isEditingMode = false;
      state.controller.clear();
      state.sendService.selectedPhoto = null;
    });

    state.textFieldFocusNode.unfocus();
    state.editPanelController.reverse();
  }
}