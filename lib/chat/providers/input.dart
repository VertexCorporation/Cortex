// lib/chat/providers/input.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cortex/chat/messages/messages.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p; // Useful for extension checking

// =================================================================************
// SECTION 0: DEFINITIONS & MODELS
// =================================================================************

enum ChatInputMode {
  none,
  study,
  quiz,
  offline,
}

enum AttachmentType {
  image,
  document,
}

/// A simple wrapper class to categorize attachments for the UI.
class InputAttachment {
  final File file;
  final AttachmentType type;

  const InputAttachment({
    required this.file,
    required this.type,
  });

  String get fileName => p.basename(file.path);

  String get extension => p.extension(file.path).toLowerCase();
}

/// A dedicated provider responsible for managing the transient state of the user input area.
class InputProvider with ChangeNotifier {
  // ===========================================================================
  // SECTION 1: PRIVATE STATE VARIABLES
  // ===========================================================================

  // --- Editing State ---
  bool _isEditingMode = false;
  int? _editingMessageIndex;
  String? _originalMessageText;

  // --- Attachment State (Universal System) ---
  final List<InputAttachment> _attachments = [];
  bool _isAttachmentLoading = false;

  // --- Voice & Features ---
  bool _isVoiceRecording = false;
  bool _isVoiceModeActive = false;
  ChatInputMode _featureMode = ChatInputMode.none;

  // ===========================================================================
  // SECTION 2: PUBLIC GETTERS
  // ===========================================================================

  ChatInputMode get featureMode => _featureMode;

  // Editing
  bool get isEditingMode => _isEditingMode;

  int? get editingMessageIndex => _editingMessageIndex;

  String? get originalMessageText => _originalMessageText;

  // Attachments
  List<InputAttachment> get attachments => List.unmodifiable(_attachments);

  bool get hasAttachments => _attachments.isNotEmpty;

  bool get isAttachmentLoading => _isAttachmentLoading;

  int get attachmentCount => _attachments.length;

  // Voice
  bool get isVoiceRecording => _isVoiceRecording;

  bool get isVoiceModeActive => _isVoiceModeActive;

  // ===========================================================================
  // SECTION 3: STATE MUTATION METHODS (ACTIONS)
  // ===========================================================================

  // -------------------- Feature & Voice Modes --------------------

  void setFeatureMode(ChatInputMode mode) {
    _featureMode = mode;
    notifyListeners();
  }

  void clearFeatureMode() {
    _featureMode = ChatInputMode.none;
    notifyListeners();
  }

  void setVoiceRecording(bool value) {
    _isVoiceRecording = value;
    notifyListeners();
  }

  void setVoiceModeActive(bool isActive) {
    if (_isVoiceModeActive == isActive) return;
    _isVoiceModeActive = isActive;
    notifyListeners();
  }

  // -------------------- Attachment Management --------------------

  void addAttachment(File file, {required bool isImage}) {
    if (_attachments.length >= 9) return; // Safety check

    _attachments.add(InputAttachment(
      file: file,
      type: isImage ? AttachmentType.image : AttachmentType.document,
    ));
    notifyListeners();
  }

  void removeAttachmentAt(int index) {
    if (index >= 0 && index < _attachments.length) {
      _attachments.removeAt(index);
      notifyListeners();
    }
  }

  void clearAttachments() {
    if (_attachments.isNotEmpty) {
      _attachments.clear();
      notifyListeners();
    }
  }

  void setAttachmentLoading(bool isLoading) {
    if (_isAttachmentLoading != isLoading) {
      _isAttachmentLoading = isLoading;
      notifyListeners();
    }
  }

  // -------------------- Editing Mode Actions --------------------

  /// Activates message editing mode.
  /// Populates the input field and attachment list from the existing message.
  void startEditing(int index, Message messageToEdit) {
    _isEditingMode = true;
    _editingMessageIndex = index;
    _originalMessageText = messageToEdit.text;

    // Clear current attachments to avoid mixing new uploads with the edited message's old files
    _attachments.clear();

    // --- RECONSTRUCTION LOGIC ---
    // The Message class handles migration internally.
    // Even old messages with 'photoPath' in the DB will have that path inside
    // 'attachmentPaths' when loaded into memory.
    if (messageToEdit.attachmentPaths.isNotEmpty) {
      for (final path in messageToEdit.attachmentPaths) {
        final file = File(path);
        // Only add if the file still exists on the device
        if (file.existsSync()) {
          final isImage = _isImageFile(path);
          _attachments.add(InputAttachment(
            file: file,
            type: isImage ? AttachmentType.image : AttachmentType.document,
          ));
        }
      }
    }

    notifyListeners();
  }

  /// Deactivates editing mode and discards changes.
  void cancelEditing() {
    _resetEditState();
    notifyListeners();
  }

  /// Completes the editing process.
  void finishEditing() {
    _resetEditState();
    notifyListeners();
  }

  /// Helper to reset purely editing-related state variables.
  void _resetEditState() {
    _isEditingMode = false;
    _editingMessageIndex = null;
    _originalMessageText = null;
    _attachments.clear();
  }

  // -------------------- Global Reset --------------------

  void resetInputState() {
    _isEditingMode = false;
    _editingMessageIndex = null;
    _originalMessageText = null;
    _attachments.clear();
    _isAttachmentLoading = false;
    _isVoiceRecording = false;
    _featureMode = ChatInputMode.none;
    notifyListeners();
  }

  // -------------------- Helpers --------------------

  bool _isImageFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
  }
}
