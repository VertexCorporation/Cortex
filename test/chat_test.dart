// test/chat_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/messages/messages.dart';

// Tests for the InputProvider logic.
// We avoid external dependencies like mockito for simplicity and speed as requested.
// We use real logic checks.

void main() {
  group('InputProvider Tests', () {
    late InputProvider inputProvider;

    setUp(() {
      inputProvider = InputProvider();
    });

    test('Initial state should be clean', () {
      expect(inputProvider.featureMode, ChatInputMode.none);
      expect(inputProvider.isEditingMode, false);
      expect(inputProvider.attachments, isEmpty);
      expect(inputProvider.isAttachmentLoading, false);
      expect(inputProvider.isVoiceRecording, false);
      expect(inputProvider.isVoiceModeActive, false);
    });

    test('Feature mode toggling', () {
      inputProvider.setFeatureMode(ChatInputMode.study);
      expect(inputProvider.featureMode, ChatInputMode.study);

      inputProvider.clearFeatureMode();
      expect(inputProvider.featureMode, ChatInputMode.none);
    });

    test('Voice recording state toggling', () {
      inputProvider.setVoiceRecording(true);
      expect(inputProvider.isVoiceRecording, true);

      inputProvider.setVoiceRecording(false);
      expect(inputProvider.isVoiceRecording, false);
    });

    test('Voice mode active toggling', () {
      inputProvider.setVoiceModeActive(true);
      expect(inputProvider.isVoiceModeActive, true);

      // Toggling same state should be safe
      inputProvider.setVoiceModeActive(true);
      expect(inputProvider.isVoiceModeActive, true);

      inputProvider.setVoiceModeActive(false);
      expect(inputProvider.isVoiceModeActive, false);
    });

    test('Attachment loading state', () {
      inputProvider.setAttachmentLoading(true);
      expect(inputProvider.isAttachmentLoading, true);

      inputProvider.setAttachmentLoading(false);
      expect(inputProvider.isAttachmentLoading, false);
    });

    test('Adding and removing attachments logic', () {
      // Logic test only, assuming paths are valid for this unit context
      final file1 = File('test1.jpg');
      final file2 = File('test2.pdf');

      inputProvider.addAttachment(file1, isImage: true);
      expect(inputProvider.attachments.length, 1);
      expect(inputProvider.attachments.first.type, AttachmentType.image);
      expect(inputProvider.hasAttachments, true);

      inputProvider.addAttachment(file2, isImage: false);
      expect(inputProvider.attachments.length, 2);
      expect(inputProvider.attachments.last.type, AttachmentType.document);
      expect(inputProvider.attachmentCount, 2);

      inputProvider.removeAttachmentAt(0);
      expect(inputProvider.attachments.length, 1);
      // After removing index 0 (jpg), index 0 should be pdf now
      expect(inputProvider.attachments.first.file.path, 'test2.pdf');

      inputProvider.clearAttachments();
      expect(inputProvider.attachments, isEmpty);
      expect(inputProvider.hasAttachments, false);
    });

    test('Max attachment limit logic', () {
      for (int i = 0; i < 15; i++) {
        inputProvider.addAttachment(File('file$i.jpg'), isImage: true);
      }
      expect(inputProvider.attachments.length, 9,
          reason: 'Should cap at 9 attachments');
    });

    test('Editing mode flow logic', () {
      final msg = Message(
        isUserMessage: true,
        text: 'Hello World',
        id: '123',
        attachmentPaths: [],
      );

      inputProvider.startEditing(5, msg);

      expect(inputProvider.isEditingMode, true);
      expect(inputProvider.editingMessageIndex, 5);
      expect(inputProvider.originalMessageText, 'Hello World');

      inputProvider.cancelEditing();
      expect(inputProvider.isEditingMode, false);
      expect(inputProvider.editingMessageIndex, null);
      expect(inputProvider.originalMessageText, null);
      expect(inputProvider.attachments, isEmpty);
    });

    test('Reset input state', () {
      inputProvider.setFeatureMode(ChatInputMode.quiz);
      inputProvider.setVoiceRecording(true);
      inputProvider.setAttachmentLoading(true);

      inputProvider.resetInputState();

      expect(inputProvider.featureMode, ChatInputMode.none);
      expect(inputProvider.isVoiceRecording, false);
      expect(inputProvider.isAttachmentLoading, false);
      expect(inputProvider.isEditingMode, false);
    });
    test('Global Draft logic', () {
      // 1. Initial State
      expect(inputProvider.globalDraft, isEmpty);

      // 2. Update Draft
      inputProvider.updateGlobalDraft('Draft Text');
      expect(inputProvider.globalDraft, 'Draft Text');

      // 3. Reset Input State (Should NOT clear draft)
      inputProvider.setVoiceRecording(true);
      inputProvider.resetInputState();
      expect(inputProvider.isVoiceRecording, false);
      expect(inputProvider.globalDraft, 'Draft Text');

      // 4. Update Draft again
      inputProvider.updateGlobalDraft('New Draft');
      expect(inputProvider.globalDraft, 'New Draft');

      // 5. Clear All Input (Should clear draft)
      inputProvider.clearAllInput();
      expect(inputProvider.globalDraft, isEmpty);
    });
  });
}
