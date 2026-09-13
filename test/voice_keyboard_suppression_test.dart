// test/voice_keyboard_suppression_test.dart
//
// Phase 1.1: while Voice Mode owns the chat screen, nothing may reopen the
// composer keyboard — not a direct request, not a pending retry chain that
// was scheduled before the voice overlay appeared. Every guard in the chain
// (EditService, ChatViewState, ChatInputPanel, MainScreen) reads the SAME
// single source of truth: InputProvider.isVoiceModeActive, which is set
// BEFORE the voice session starts. These tests pin that contract at the
// service level, where the actual focus node lives.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/edit.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/scroll.dart';

/// Records focus requests without needing a mounted focus scope.
class RecordingFocusNode extends FocusNode {
  int requestFocusCount = 0;

  @override
  void requestFocus([FocusNode? node]) {
    requestFocusCount++;
  }
}

/// The two public methods of RegenerateService are all the interface
/// EditService actually holds.
class StubRegenerateService implements RegenerateService {
  @override
  Future<void> onContinue(
    int aiMessageIndex, {
    required BuildContext context,
  }) async {}

  @override
  Future<void> onRegenerate(
    int messageIndex, {
    required BuildContext context,
    String? newModelId,
    bool isDynamicRegenerate = false,
  }) async {}
}

class StubTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

void main() {
  late InputProvider inputProvider;
  late EditService editService;
  late RecordingFocusNode focusNode;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    inputProvider = InputProvider();
    focusNode = RecordingFocusNode();
    editService = EditService(
      inputProvider: inputProvider,
      conversationProvider: ConversationProvider(),
      regenerateService: StubRegenerateService(),
      scrollService: ScrollService(),
      controller: TextEditingController(),
      focusNode: focusNode,
      panelController: AnimationController(
        vsync: StubTickerProvider(),
        duration: const Duration(milliseconds: 200),
      ),
    );
  });

  test('requestFocus works normally when voice mode is inactive', () {
    expect(inputProvider.isVoiceModeActive, false);
    editService.requestFocus();
    expect(focusNode.requestFocusCount, 1);
  });

  test('requestFocus is suppressed while voice mode owns the screen', () {
    inputProvider.setVoiceModeActive(true);
    expect(inputProvider.isVoiceModeActive, true);

    editService.requestFocus();
    editService.requestFocus();
    expect(
      focusNode.requestFocusCount,
      0,
      reason: 'the keyboard may never open over the voice overlay',
    );
  });

  test('focus is granted again once the voice session is closed', () {
    inputProvider.setVoiceModeActive(true);
    editService.requestFocus();
    expect(focusNode.requestFocusCount, 0);

    inputProvider.setVoiceModeActive(false);
    editService.requestFocus();
    expect(focusNode.requestFocusCount, 1);
  });

  test(
    'the suppression flag is notification-driven state, not a timing hack',
    () {
      var notifications = 0;
      inputProvider.addListener(() => notifications++);

      inputProvider.setVoiceModeActive(true);
      inputProvider.setVoiceModeActive(false);

      // Every flip notifies, so UI guards re-evaluate the moment the state
      // changes — no delays, no races with pending focus retry chains.
      expect(notifications, 2);
    },
  );
}
