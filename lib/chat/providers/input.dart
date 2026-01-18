// lib/chat/providers/input.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cortex/chat/messages/messages.dart';

enum ChatInputMode {
  none,
  study,
  quiz,
  offline,
}

/// A dedicated provider responsible for managing the transient state of the user input area.
///
/// This provider's single responsibility is to manage the state directly related to
/// what the user is currently doing in the input field. This includes:
/// - Message editing mode (`isEditingMode`, `editingMessageIndex`).
/// - Photo selection and loading status (`selectedPhoto`, `isPhotoLoading`).
///
/// By isolating this frequently changing state, we prevent unnecessary rebuilds of
/// other parts of the UI, such as the main message list, leading to better performance.
class InputProvider with ChangeNotifier {
  // ===========================================================================
  // SECTION 1: PRIVATE STATE VARIABLES
  // ===========================================================================

  bool _isEditingMode = false;
  int? _editingMessageIndex;
  String? _originalMessageText;

  File? _selectedPhoto;
  bool _isPhotoLoading = false;
  ChatInputMode _featureMode = ChatInputMode.none;

  // ===========================================================================
  // SECTION 2: PUBLIC GETTERS
  // ===========================================================================

  ChatInputMode get featureMode => _featureMode;

  bool get isEditingMode => _isEditingMode;

  int? get editingMessageIndex => _editingMessageIndex;

  String? get originalMessageText => _originalMessageText;

  File? get selectedPhoto => _selectedPhoto;

  bool get isPhotoLoading => _isPhotoLoading;

  // ===========================================================================
  // SECTION 3: STATE MUTATION METHODS (ACTIONS)
  // ===========================================================================

  /// Sets the current input mode (Study, Quiz, etc.) and notifies listeners
  /// so the UI can update the button color to secondaryColor.
  void setFeatureMode(ChatInputMode mode) {
    _featureMode = mode;
    notifyListeners();
  }

  /// Clears the current mode (e.g., after sending).
  void clearFeatureMode() {
    _featureMode = ChatInputMode.none;
    notifyListeners();
  }

  // -------------------- Editing Mode Actions --------------------

  /// Activates message editing mode.
  /// This method only sets the state for the input UI. It does NOT manipulate
  /// the main message list. An orchestrating service is responsible for telling
  /// the ConversationProvider to update its message list for the UI.
  void startEditing(int index, Message messageToEdit) {
    _isEditingMode = true;
    _editingMessageIndex = index;
    _originalMessageText = messageToEdit.text;

    // Load the existing photo from the message into the input field for editing.
    final photoPath = messageToEdit.photoPath;
    _selectedPhoto = photoPath != null ? File(photoPath) : null;

    notifyListeners();
  }

  /// Deactivates message editing mode without saving changes.
  /// Resets all editing-related state.
  void cancelEditing() {
    _isEditingMode = false;
    _editingMessageIndex = null;
    _originalMessageText = null;
    _selectedPhoto = null; // Also clear any photo loaded for the edit
    notifyListeners();
  }

  /// Clears the editing state after an edited message has been successfully applied.
  /// This method should be called by an orchestrating service (`EditService`)
  /// after it has updated the `ConversationProvider`.
  void finishEditing() {
    _isEditingMode = false;
    _editingMessageIndex = null;
    _originalMessageText = null;
    _selectedPhoto = null;
    notifyListeners();
  }

  // -------------------- Input Field Actions --------------------

  /// Sets the photo selected by the user from the input field.
  void selectPhoto(File? photo) {
    _selectedPhoto = photo;
    notifyListeners();
  }

  /// Clears the selected photo, typically after a message has been sent.
  void clearSelectedPhoto() {
    if (_selectedPhoto != null) {
      _selectedPhoto = null;
      notifyListeners();
    }
  }

  /// Manages the loading indicator for photo selection/processing.
  void setPhotoLoading(bool isLoading) {
    if (_isPhotoLoading != isLoading) {
      _isPhotoLoading = isLoading;
      notifyListeners();
    }
  }

  /// A comprehensive reset method to clear all input state.
  /// Should be called when a chat session is completely reset.
  void resetInputState() {
    _isEditingMode = false;
    _editingMessageIndex = null;
    _originalMessageText = null;
    _selectedPhoto = null;
    _isPhotoLoading = false;
    notifyListeners();
  }
}