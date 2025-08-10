// edit.dart

import 'package:cortex/chat/services/storage.dart';
import 'package:flutter/material.dart';
import '../chat.dart';

class EditService {
  final ChatScreenState state;
  EditService({required this.state});

  Future<void> applyEditedMessage() async {
    final int? eIndex = state.editingMessageIndex;
    if (eIndex == null) return;

    final oldMsg       = state.messages[eIndex];
    final oldPhotoPath = oldMsg.photoPath;

    final newUserText  = state.controller.text.trim();
    final photoChanged =
        (oldPhotoPath != null && state.sendService.selectedPhoto == null) ||
            (oldPhotoPath == null && state.sendService.selectedPhoto != null);

    if (newUserText == state.originalMessageText && !photoChanged) return;

    state.setState(() {

      oldMsg.text      = newUserText;
      oldMsg.photoPath = state.sendService.selectedPhoto?.path;

      state.messages = state.messages.sublist(0, eIndex);

      // – Bayraklar
      state.editingMessageIndex  = null;
      state.originalMessageText  = null;
      state.isEditingMode        = false;
      state.controller.clear();
      state.textFieldFocusNode.unfocus();
      state.showScrollDownButtonByPosition = false;
    });

    await state.editPanelController.reverse();
    await ChatStorageService.saveCurrentMessages(
        state.conversationID!, state.messages);

    await state.sendService.sendMessage(textFromButton: newUserText);
  }

  /// Initiates editing for the message at [index].
  void startEditingMessage(int index) {
    state.setState(() {
      state.editingMessageIndex = index;
      state.originalMessageText = state.messages[index].text;
      state.controller.text = state.messages[index].text!;
      state.controller.selection = TextSelection.collapsed(
        offset: state.controller.text.length,
      );
      state.controller.value = state.controller.value.copyWith(
        composing: TextRange.empty,
      );
      FocusScope.of(state.context).requestFocus(state.textFieldFocusNode);

      // -------- fade-out işlemleri --------
      for (int i = index + 1; i < state.messages.length; i++) {
        state.messages[i].opacity = 0;
      }
      state.isEditingMode = true;
      state.editSessionCounter++;
    });
    state.editPanelController.forward();
  }
  /// Cancels the editing mode and restores the original message text.
  void cancelEditingMode() {
    state.setState(() {
      if (state.editingMessageIndex != null && state.originalMessageText != null) {
        state.messages[state.editingMessageIndex!].text = state.originalMessageText!;
        state.messages[state.editingMessageIndex!].notifier.value = state.originalMessageText!;
      }
      for (int i = (state.editingMessageIndex ?? 0) + 1; i < state.messages.length; i++) {
        state.messages[i].opacity = 1;
        state.messages[i].notifier.value = state.messages[i].text!;
      }
      state.editingMessageIndex = null;
      state.originalMessageText = null;
      state.isEditingMode = false;
      state.controller.clear();
    });
    state.editPanelController.reverse().then((_) {
      state.setState(() {
        for (int i = 0; i < state.messages.length; i++) {
          state.messages[i].opacity = 1;
          state.messages[i].notifier.value = state.messages[i].text!;
        }
      });
    });
  }
}
