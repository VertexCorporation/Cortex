// lib/chat/providers/input.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  featureReasoning,
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
  StreamSubscription? _authSub;
  ChatInputMode _featureMode = ChatInputMode.none;

  // --- Web Search ---
  bool _enableWebSearch = false;

  // --- RAG (Document Chat) ---
  bool _ragEnabled = false;
  final List<String> _ragDocumentIds = [];

  // --- Global Draft (Persist across chats) ---
  String _globalDraft = '';

  // ===========================================================================
  // SECTION 1.5: INITIALIZATION
  // ===========================================================================

  InputProvider() {
    try {
      _authSub = FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          resetForLogout();
        }
      });
    } catch (_) {
      // Ignore during testing
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  // ===========================================================================
  // SECTION 2: PUBLIC GETTERS
  // ===========================================================================

  String get globalDraft => _globalDraft;

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

  // Web Search
  bool get enableWebSearch => _enableWebSearch;

  // RAG (Document Chat)
  bool get ragEnabled => _ragEnabled;

  /// Document ids selected for toggle-mode retrieval.
  List<String> get ragDocumentIds => List.unmodifiable(_ragDocumentIds);

  // ===========================================================================
  // SECTION 3: STATE MUTATION METHODS (ACTIONS)
  // ===========================================================================

  // -------------------- Feature & Voice Modes --------------------

  void setFeatureMode(ChatInputMode mode) {
    _featureMode = mode;
    if (mode != ChatInputMode.none) {
      _enableWebSearch = false;
    }
    notifyListeners();
  }

  /// Clears feature mode only if it's offline mode.
  /// Non-offline features (like reasoning) persist across chat switches.
  void clearFeatureModeIfOffline() {
    if (_featureMode == ChatInputMode.offline) {
      _featureMode = ChatInputMode.none;
      notifyListeners();
    }
  }

  /// Force clears any feature mode (use for full reset).
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

  void toggleWebSearch() {
    _enableWebSearch = !_enableWebSearch;
    if (_enableWebSearch && _featureMode != ChatInputMode.none) {
      _featureMode = ChatInputMode.none;
    }
    notifyListeners();
  }

  void clearWebSearch() {
    if (_enableWebSearch) {
      _enableWebSearch = false;
      notifyListeners();
    }
  }

  // -------------------- RAG (Document Chat) State --------------------

  void toggleRag() {
    _ragEnabled = !_ragEnabled;
    if (_ragEnabled && _featureMode != ChatInputMode.none) {
      _featureMode = ChatInputMode.none;
    }
    notifyListeners();
  }

  void setRagEnabled(bool enabled) {
    if (_ragEnabled == enabled) return;
    _ragEnabled = enabled;
    notifyListeners();
  }

  void setRagDocuments(List<String> documentIds) {
    _ragDocumentIds
      ..clear()
      ..addAll(documentIds);
    if (_ragDocumentIds.isEmpty) {
      _ragEnabled = false;
    }
    notifyListeners();
  }

  void clearRag() {
    _ragEnabled = false;
    _ragDocumentIds.clear();
    notifyListeners();
  }

  // -------------------- Attachment Management --------------------

  void addAttachment(File file, {required bool isImage}) {
    debugPrint(
        "InputProvider: addAttachment called. Current count: ${_attachments.length}. New file: ${file.path}");
    if (_attachments.length >= 9) {
      debugPrint("InputProvider: Attachment limit reached. Ignoring.");
      return;
    }

    _attachments.add(InputAttachment(
      file: file,
      type: isImage ? AttachmentType.image : AttachmentType.document,
    ));
    debugPrint(
        "InputProvider: Attachment added. New count: ${_attachments.length}. Notifying listeners.");
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

  // -------------------- Global Draft Management --------------------

  void updateGlobalDraft(String text) {
    if (_globalDraft != text) {
      _globalDraft = text;
    }
  }

  // -------------------- Global Reset --------------------

  void resetInputState() {
    _isEditingMode = false;
    _editingMessageIndex = null;
    _originalMessageText = null;
    _attachments.clear();
    _isVoiceRecording = false;
    _isAttachmentLoading = false;
    _featureMode = ChatInputMode.none;
    _enableWebSearch = false;
    _ragEnabled = false;
    _ragDocumentIds.clear();
    // NOTE: We do NOT clear _globalDraft here.
    // This allows maintaining text when switching chats.
    notifyListeners();
  }

  /// Strictly resets everything including the global draft for a complete sign-out,
  /// ensuring no drafts leak into another user's account.
  void resetForLogout() {
    _globalDraft = '';
    resetInputState();
  }

  /// Clears everything including the draft. Called after successful send.
  void clearAllInput() {
    _globalDraft = '';
    resetInputState();
  }

  /// Clears text, draft, and attachments after a send, but PERSISTS feature toggles
  /// (e.g. Web Search, Reasoning) so the user doesn't have to re-enable them per message.
  void clearAfterSend() {
    _globalDraft = '';
    _isEditingMode = false;
    _editingMessageIndex = null;
    _originalMessageText = null;
    _attachments.clear();
    _isVoiceRecording = false;
    _isAttachmentLoading = false;
    // Note: We deliberately KEEP _featureMode and _enableWebSearch intact!
    notifyListeners();
  }

  // -------------------- Helpers --------------------

  bool _isImageFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
  }
}
