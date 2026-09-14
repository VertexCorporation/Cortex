import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/services/flow.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Flow progresses Blue → Red → Green → Yellow', () {
    final flow = FlowOrchestrator()..begin(newGeneration: 7);

    expect(flow.currentParticipant, FlowParticipant.blue);
    expect(flow.completeAi(expectedGeneration: 7), FlowParticipant.red);
    expect(flow.completeAi(expectedGeneration: 7), FlowParticipant.green);
    expect(flow.completeAi(expectedGeneration: 7), FlowParticipant.yellow);
    expect(flow.completeAi(expectedGeneration: 7), isNull);
    expect(flow.phase, FlowPhase.interRoundPause);
  });

  test('silent inter-round pause begins a new round at Blue', () {
    final flow = FlowOrchestrator()..begin(newGeneration: 3);
    flow.currentParticipant = FlowParticipant.yellow;
    flow.phase = FlowPhase.aiSpeaking;
    expect(flow.completeAi(expectedGeneration: 3), isNull);

    expect(flow.beginNextRound(expectedGeneration: 3), FlowParticipant.blue);
    expect(flow.round, 1);
    expect(flow.phase, FlowPhase.thinking);
  });

  test(
    'user interruption resets the round and invalidates stale generation',
    () {
      final flow = FlowOrchestrator()..begin(newGeneration: 10);
      flow.currentParticipant = FlowParticipant.green;
      flow.phase = FlowPhase.aiSpeaking;
      flow.interruptForUser();

      expect(flow.currentParticipant, FlowParticipant.blue);
      expect(flow.phase, FlowPhase.userSpeaking);
      expect(flow.completeAi(expectedGeneration: 10), isNull);
    },
  );

  test('Flow participant identity survives message serialization', () {
    final message = Message(
      id: 'flow-1',
      text: 'A blue response',
      isUserMessage: false,
      model: 'cortex/auto',
      flowParticipant: FlowParticipant.blue.key,
    );

    final restored = Message.fromMap({...message.toMap(), 'isUser': 0});

    expect(restored.flowParticipant, FlowParticipant.blue.key);
    expect(
      FlowParticipantMetadata.fromKey(restored.flowParticipant)?.color,
      FlowParticipant.blue.color,
    );
    expect(
      FlowParticipantMetadata.fromKey('red')?.color,
      FlowParticipant.red.color,
    );
    expect(
      FlowParticipantMetadata.fromKey('green')?.color,
      FlowParticipant.green.color,
    );
    expect(
      FlowParticipantMetadata.fromKey('yellow')?.color,
      FlowParticipant.yellow.color,
    );
  });

  test('assistant-only Flow turns preserve the current conversation', () {
    final conversation = ConversationProvider();
    conversation.setConversationContext('chat-42', 'Discussion');
    conversation.loadMessages([Message.user(text: 'What should we do?')]);

    final index = conversation.appendAssistantThinking(
      model: 'cortex/auto',
      flowParticipant: FlowParticipant.red.key,
    );

    expect(conversation.conversationID, 'chat-42');
    expect(index, 1);
    expect(conversation.messages.length, 2);
    expect(conversation.messages.last.isUserMessage, isFalse);
    expect(conversation.messages.last.flowParticipant, 'red');
  });
}
