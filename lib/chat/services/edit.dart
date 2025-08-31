// edit.dart

import 'package:flutter/material.dart';
import '../chat.dart';
import '../messages/messages.dart';

/// Service responsible for managing the message editing lifecycle.
/// It handles entering and exiting edit mode, and applying the final changes
/// by delegating the resubmission to the SendService.
class EditService {
  final ChatScreenState state;
  EditService({required this.state});

  /// [PERFECTED & REBUILT] Applies the edited message.
  ///
  /// This function is now a lean and efficient orchestrator. It NO LONGER
  /// manipulates the message list directly. Its sole responsibility is to:
  /// 1. Capture the edited content.
  /// 2. Clean up the editing UI state (panels, controllers).
  /// 3. Delegate the entire "resend" operation to RegenerateService, which
  ///    already knows how to correctly and atomically rebuild the message list.
  Future<void> applyEditedMessage() async {
    final int? editingIndex = state.editingMessageIndex;
    if (editingIndex == null) return;

    // 1. Capture the final edited content from the controller and SendService.
    final String newText = state.controller.text.trim();
    final String? newPhotoPath = state.sendService.selectedPhoto?.path;

    // --- THE CRITICAL FIX IS HERE ---
    // Instead of directly changing the message text, we will create a NEW
    // Message object. This ensures it gets a new, unique ID, which is the
    // key to making Flutter's list updates work correctly.

    final originalMessage = state.messages[editingIndex];
    final updatedUserMessage = Message(
      id: originalMessage.id, // Keep the original ID for now, RegenerateService will handle it
      text: newText,
      isUserMessage: true,
      photoPath: newPhotoPath ?? originalMessage.photoPath, // Use new photo if available
      model: originalMessage.model,
    );

    // 2. Clean up the editing UI state immediately for a responsive feel.
    state.setState(() {
      // Replace the old message with our updated one.
      // This step is crucial for context building in the regenerate service.
      state.messages[editingIndex] = updatedUserMessage;

      // Exit editing mode and clear the related state variables.
      state.isEditingMode = false;
      state.editingMessageIndex = null;
      state.originalMessageText = null;
      state.controller.clear();
      // Clear the photo now that we've captured its path.
      state.sendService.selectedPhoto = null;
    });

    // Animate the edit panel away.
    await state.editPanelController.reverse();

    // 3. Delegate the core logic to RegenerateService.
    //    We tell it to regenerate the AI message that FOLLOWS our edited message.
    //    RegenerateService will now see the updated text/photo in the message list
    //    and will correctly rebuild the UI from that point onwards.
    await state.regenerateService.onRegenerate(editingIndex + 1);
  }

  /// Initiates editing for the message at the specified [index].
  void startEditingMessage(int index) {
    if (!state.mounted) return;

    state.setState(() {
      final messageToEdit = state.messages[index];
      state.editingMessageIndex = index;
      state.originalMessageText = messageToEdit.text;

      state.controller.text = messageToEdit.text ?? '';
      // Move cursor to the end of the text for a better user experience.
      state.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: state.controller.text.length),
      );

      // Visually indicate which messages will be replaced upon applying the edit.
      for (int i = index + 1; i < state.messages.length; i++) {
        state.messages[i].opacity = 0.3;
      }

      state.isEditingMode = true;
      state.editSessionCounter++; // Force InputField to rebuild with preselected photo etc.
    });

    FocusScope.of(state.context).requestFocus(state.textFieldFocusNode);
    state.editPanelController.forward();
  }

  /// Cancels the editing mode and restores the UI to its previous state.
  void cancelEditingMode() {
    if (!state.mounted) return;

    state.setState(() {
      // Restore the full opacity of subsequent messages.
      for (int i = (state.editingMessageIndex ?? 0) + 1; i < state.messages.length; i++) {
        state.messages[i].opacity = 1.0;
      }

      // Reset all editing-related state variables.
      state.editingMessageIndex = null;
      state.originalMessageText = null;
      state.isEditingMode = false;
      state.controller.clear();
      state.sendService.selectedPhoto = null; // A new photo might have been selected but not sent.
    });

    state.textFieldFocusNode.unfocus();
    state.editPanelController.reverse();
  }
}