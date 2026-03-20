import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Lifecycle & State Reset Tests', () {
    test('ConversationProvider properly resets state on logout', () {
      final provider = ConversationProvider();
      
      // Simulate an active conversation
      provider.setConversationContext('conv_123', 'My Session');
      provider.setLoadingMessages(true);
      
      final msg = Message(text: 'Hello', isUserMessage: true);
      provider.loadMessages([msg]);
      
      // Verify state is dirty
      expect(provider.conversationID, 'conv_123');
      expect(provider.conversationTitle, 'My Session');
      expect(provider.messages.length, 1);
      
      // TRIGGER LOGOUT RESET
      provider.resetForLogout();
      
      // Verify full reset
      expect(provider.conversationID, isNull);
      expect(provider.conversationTitle, isNull);
      expect(provider.messages, isEmpty);
      expect(provider.isLoadingMessages, isFalse);
    });

    test('InputProvider properly resets state and global draft on logout', () {
      final provider = InputProvider();
      
      // Simulate active input and draft
      provider.updateGlobalDraft('Unfinished message...');
      provider.setFeatureMode(ChatInputMode.offline);
      provider.setVoiceRecording(true);
      
      // Verify state is dirty
      expect(provider.globalDraft, 'Unfinished message...');
      expect(provider.featureMode, ChatInputMode.offline);
      expect(provider.isVoiceRecording, isTrue);
      
      // TRIGGER LOGOUT RESET
      provider.resetForLogout();
      
      // Verify full reset including global draft
      expect(provider.globalDraft, isEmpty);
      expect(provider.featureMode, ChatInputMode.none);
      expect(provider.isVoiceRecording, isFalse);
    });
  });

  group('Hidden Message Privacy Filtering Tests', () {
    test('UI should filter invisible messages correctly (Logic test)', () {
      final messages = [
        Message(text: 'Visible 1', isUserMessage: true, isVisible: true),
        Message(text: 'Hidden Voice Context', isUserMessage: false, isVisible: false),
        Message(text: 'Visible 2', isUserMessage: false, isVisible: true),
      ];

      final visibleIndices = <int>[];
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].isVisible) {
          visibleIndices.add(i);
        }
      }

      expect(visibleIndices.length, 2);
      expect(visibleIndices, [0, 2]);
    });

    test('History context should exclude invisible messages', () {
      final provider = ConversationProvider();
      
      final msg1 = Message(text: 'Hello', isUserMessage: true, isVisible: true, includeInContext: true);
      // Pre-input message, e.g. "Take a deep breath"
      final msg2Hidden = Message(text: 'Hidden intent', isUserMessage: false, isVisible: false, includeInContext: true);
      final msg3 = Message(text: 'World', isUserMessage: false, isVisible: true, includeInContext: true);
      
      provider.loadMessages([msg1, msg2Hidden, msg3]);
      
      final history = provider.messages
        .where((m) => m.includeInContext && !m.isThinking && !m.isError && m.isVisible)
        .toList();
        
      expect(history.length, 2);
      expect(history.contains(msg2Hidden), isFalse);
      expect(history.first.text, 'Hello');
      expect(history.last.text, 'World');
    });
  });
}
