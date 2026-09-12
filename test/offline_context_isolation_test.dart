// test/offline_context_isolation_test.dart
//
// Regression coverage for the offline cross-conversation context leak
// (2026-09-11 report: a new offline chat, asked in English, sometimes
// answered in Turkish — as if the previous Turkish chat's context had
// persisted into the new conversation).
//
// Root causes fixed (and locked in here):
//
//   1. NATIVE EVENT ROUTING: leaving a chat while its on-device generation
//      was still decoding kept the native llama stream alive. Because
//      `isWaitingForResponse` is a single, conversation-blind flag, the
//      moment the NEXT conversation started waiting, the stale stream's
//      tokens — and its terminal `onMessageComplete` — were routed into
//      the new conversation's message bubble. OfflineService now tears the
//      previous native stream down (stop + bounded ack wait) before any
//      new generation, and accepts native events only between its own
//      `sendMessage` invoke and its terminal completion.
//
//   2. PROMPT SCOPING: the offline prompt must contain ONLY the current
//      conversation's own history (same-chat multi-turn memory preserved).
//
// Also verifies the `seedBuffer` API behind the "Continue generating"
// background-buffer repair (the kept partial is part of THIS turn's final
// text, so a backgrounded completion persists partial + continuation).

import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/background.dart';
import 'package:cortex/chat/services/context.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/response.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/rag/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _llamaChannel = MethodChannel('com.vertex.cortex/llama');

/// The catalog shape of the incident: an installed offline model.
final ModelEntity _offlineQwen = ModelEntity.fromMap(const {
  'id': 'qwen3-06b',
  'title': 'Qwen3 0.6B',
  'type': 'offline',
  'source': 'user',
  'category': 'chat',
  'tier': 'free',
}, 'en');

/// Minimal stand-in for [ChatSessionProvider]: only what OfflineService
/// reads (selected model, path, load state, locale).
class _FakeSession extends ChangeNotifier implements ChatSessionProvider {
  @override
  String? get modelId => 'qwen3-06b';

  @override
  String? get modelPath => '/tmp/fake-model.gguf';

  bool _loaded = true;

  @override
  bool get isLocalModelLoaded => _loaded;

  @override
  void setLocalModelLoaded(bool value) {
    _loaded = value;
  }

  @override
  Locale getLocale() => const Locale('en');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Minimal stand-in for [ModelService]: answers everything with the
/// offline test model, no vision support.
class _FakeModelService implements ModelService {
  @override
  ModelEntity getPreciseModelData(String modelId,
          {required String langCode}) =>
      _offlineQwen;

  @override
  bool hasModality(String modelId,
          {required String langCode, String? modality}) =>
      false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Minimal stand-in for [RagChatService]: never injects context, records
/// the arguments so the test can prove RAG stays disabled by default.
class _FakeRagChat implements RagChatService {
  bool called = false;
  bool toggleEnabled = true;
  List<String> documentIds = const [];
  List<String> attachmentPaths = const [];

  @override
  Future<String?> buildContext({
    required String queryText,
    required bool toggleEnabled,
    required List<String> toggleDocumentIds,
    required List<String> attachmentPaths,
  }) async {
    called = true;
    this.toggleEnabled = toggleEnabled;
    documentIds = toggleDocumentIds;
    this.attachmentPaths = attachmentPaths;
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Wires a REAL ConversationProvider + ResponseService + ContextService +
/// OfflineService against a mocked native channel, mirroring the native
/// stop semantics: when Dart requests 'stopGeneration', the abandoned
/// stream emits one in-flight token and then its terminal ack.
class _Harness {
  _Harness() {
    conversation = ConversationProvider();
    ragChat = _FakeRagChat();
    offline = OfflineService(
      responseService: ResponseService(
        conversationProvider: conversation,
        scrollService: ScrollService(),
      ),
      sessionProvider: _FakeSession(),
      modelService: _FakeModelService(),
      contextService: ContextService(
        conversationProvider: conversation,
        modelService: _FakeModelService(),
      ),
      ragChat: ragChat,
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_llamaChannel, (call) async {
      calls.add(call.method);
      if (call.method == 'sendMessage') {
        final args = call.arguments as Map;
        prompts.add(args['message'] as String);
        final earlyToken = synchronousTokenOnSend;
        if (earlyToken != null) {
          await offline.methodCallHandler(
              MethodCall('onMessageResponse', earlyToken));
        }
        if (synchronousCompleteOnSend) {
          await offline.methodCallHandler(const MethodCall('onMessageComplete'));
        }
      } else if (call.method == 'stopGeneration') {
        // Mirror native semantics: the abandoned stream is halted, but not
        // before emitting one in-flight token and its terminal completion.
        await offline.methodCallHandler(
            const MethodCall('onMessageResponse', 'STALE_TURKISH_TOKEN'));
        await offline.methodCallHandler(const MethodCall('onMessageComplete'));
      }
      return null;
    });
  }

  late ConversationProvider conversation;
  late _FakeRagChat ragChat;
  late OfflineService offline;
  final List<String> calls = [];
  final List<String> prompts = [];
  String? synchronousTokenOnSend;
  bool synchronousCompleteOnSend = false;

  Future<void> deliverToken(String token) async {
    await offline.methodCallHandler(MethodCall('onMessageResponse', token));
  }

  Future<void> deliverComplete() async {
    await offline.methodCallHandler(const MethodCall('onMessageComplete'));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_llamaChannel, null);
  });

  group('offline cross-conversation isolation (native event routing)', () {
    test(
        'the previous conversation\'s stream is torn down first; its tokens '
        'are dropped and its completion cannot finalize the new chat',
        () async {
      final h = _Harness();

      // --- Chat A (Turkish): generation starts and streams.
      await h.conversation.startNewConversationSession(
        'convA',
        'Chat A',
        'qwen3-06b',
        Message(text: 'Merhaba, nasılsın?', isUserMessage: true),
      );
      await h.offline.sendMessage(
          'Merhaba, nasılsın?', null, null, [], false, [], 'convA');
      expect(h.calls, ['sendMessage']);

      await h.deliverToken('Selam!');
      expect(h.conversation.messages.last.text, contains('Selam!'));

      // --- The user LEAVES chat A mid-generation (no completion yet).
      h.conversation.clearConversation();

      // --- Chat B (English): a brand-new, empty conversation.
      await h.conversation.startNewConversationSession(
        'convB',
        'Chat B',
        'qwen3-06b',
        Message(text: 'What is the capital of France?', isUserMessage: true),
      );
      await h.offline.sendMessage(
          'What is the capital of France?', null, null, [], false, [], 'convB');

      // The stale native stream was stopped BEFORE chat B's generation was
      // issued — never after, never interleaved with it.
      expect(h.calls, ['sendMessage', 'stopGeneration', 'sendMessage']);

      // The stale stream's in-flight token was dropped: chat B's waiting
      // bubble is still clean and still waiting.
      expect(h.conversation.messages.last.text, '');
      expect(h.conversation.messages.last.isThinking, isTrue);
      expect(h.conversation.isWaitingForResponse, isTrue);

      // --- Chat B's own generation streams normally.
      await h.deliverToken('Paris');
      await h.deliverToken('.');
      expect(h.conversation.messages.last.text, 'Paris.');

      // --- And finalizes normally.
      await h.deliverComplete();
      expect(h.conversation.isWaitingForResponse, isFalse);
      expect(h.conversation.messages.last.isThinking, isFalse);
      expect(h.conversation.messages.last.text, 'Paris.');
    });

    test(
        'the pre-send stop (SendService step 0) closes the event gate: the '
        'abandoned conversation\'s dying tokens and completion never reach '
        'the chat that is now waiting',
        () async {
      final h = _Harness();

      // Chat A (Turkish) starts generating and is left mid-generation.
      await h.conversation.startNewConversationSession(
        'convA',
        'Chat A',
        'qwen3-06b',
        Message(text: 'Merhaba, nasılsın?', isUserMessage: true),
      );
      await h.offline.sendMessage(
          'Merhaba, nasılsın?', null, null, [], false, [], 'convA');
      await h.deliverToken('Selam!');
      expect(h.conversation.messages.last.text, contains('Selam!'));

      // The user LEAVES chat A and starts chat B (which now WAITS).
      h.conversation.clearConversation();
      await h.conversation.startNewConversationSession(
        'convB',
        'Chat B',
        'qwen3-06b',
        Message(text: 'What is the capital of France?', isUserMessage: true),
      );
      expect(h.conversation.isWaitingForResponse, isTrue);

      // SendService step 0: stop the abandoned stream BEFORE the new
      // generation is issued. The dying stream still emits one in-flight
      // token and its terminal completion (mirrored by the mock) — both
      // must be rejected while chat B is waiting.
      await h.offline.stopGeneration();

      expect(
        h.conversation.messages.last.text,
        '',
        reason:
            'The abandoned chat\'s dying token must be dropped, not appended '
            'to chat B\'s waiting bubble.',
      );
      expect(h.conversation.isWaitingForResponse, isTrue);

      // Chat B's own generation streams and finalizes normally.
      await h.offline.sendMessage(
          'What is the capital of France?', null, null, [], false, [], 'convB');
      await h.deliverToken('Paris.');
      await h.deliverComplete();
      expect(h.conversation.messages.last.text, 'Paris.');
      expect(h.conversation.isWaitingForResponse, isFalse);
    });
  });

  group('offline launch window and empty response recovery', () {
    test('token and completion emitted before invokeMethod returns are replayed',
        () async {
      final h = _Harness()
        ..synchronousTokenOnSend = 'Hello from Qwen.'
        ..synchronousCompleteOnSend = true;

      await h.conversation.startNewConversationSession(
        'convFast',
        'Fast local model',
        'qwen3-06b',
        Message(text: 'Hello', isUserMessage: true),
      );
      await h.offline.sendMessage(
        'Hello',
        null,
        null,
        [],
        false,
        [],
        'convFast',
        'Please try again.',
      );

      final answer = h.conversation.messages.last;
      expect(answer.text, 'Hello from Qwen.');
      expect(answer.isThinking, isFalse);
      expect(answer.isError, isFalse);
      expect(h.conversation.isWaitingForResponse, isFalse);
    });

    test('zero-token completion becomes an error, never a ghost assistant row',
        () async {
      final h = _Harness()..synchronousCompleteOnSend = true;

      await h.conversation.startNewConversationSession(
        'convEmpty',
        'Empty local response',
        'qwen3-06b',
        Message(text: 'alo', isUserMessage: true),
      );
      await h.offline.sendMessage(
        'alo',
        null,
        null,
        [],
        false,
        [],
        'convEmpty',
        'The model did not generate a response. Please try again.',
      );

      final answer = h.conversation.messages.last;
      expect(
        answer.text,
        'The model did not generate a response. Please try again.',
      );
      expect(answer.isThinking, isFalse);
      expect(answer.isError, isTrue);
      expect(answer.includeInContext, isFalse);
      expect(h.conversation.isWaitingForResponse, isFalse);
    });
  });

  group('offline prompt scoping (per-conversation context)', () {
    test('a new conversation\'s prompt contains only its own messages',
        () async {
      final h = _Harness();

      // Chat A's prompt: built while chat A is the active conversation.
      await h.conversation.startNewConversationSession(
        'convA',
        'Chat A',
        'qwen3-06b',
        Message(text: 'Merhaba, nasılsın?', isUserMessage: true),
      );
      await h.offline.sendMessage(
          'Merhaba, nasılsın?', null, null, [], false, [], 'convA');
      expect(h.prompts.single, contains('Merhaba'));

      // Leave chat A; start a brand-new chat B.
      h.conversation.clearConversation();
      await h.conversation.startNewConversationSession(
        'convB',
        'Chat B',
        'qwen3-06b',
        Message(text: 'What is the capital of France?', isUserMessage: true),
      );
      await h.offline.sendMessage(
          'What is the capital of France?', null, null, [], false, [], 'convB');

      // Chat B's prompt contains chat B's question — and ZERO chat A text.
      final promptB = h.prompts.last;
      expect(promptB, contains('What is the capital of France?'));
      expect(
        promptB,
        isNot(contains('Merhaba')),
        reason: 'Chat A\'s messages must never appear in chat B\'s prompt.',
      );
      expect(h.prompts.length, 2);
    });

    test(
        'same-chat multi-turn memory is preserved (history + latest turn)',
        () async {
      final h = _Harness();

      // Turn 1.
      await h.conversation.startNewConversationSession(
        'convA',
        'Chat A',
        'qwen3-06b',
        Message(text: 'My name is Ada.', isUserMessage: true),
      );
      await h.offline.sendMessage(
          'My name is Ada.', null, null, [], false, [], 'convA');
      await h.deliverToken('Nice to meet you!');
      await h.deliverComplete();
      expect(h.conversation.isWaitingForResponse, isFalse);

      // Turn 2 (same conversation): the rebuilt prompt must include the
      // first exchange (user + assistant) plus the latest question.
      h.conversation.appendMessageToConversation(
          Message(text: 'What is my name?', isUserMessage: true));
      await h.offline.sendMessage(
          'What is my name?', null, null, [], false, [], 'convA');

      final prompt = h.prompts.last;
      expect(prompt, contains('My name is Ada.'));
      expect(prompt, contains('Nice to meet you!'));
      expect(prompt, contains('What is my name?'));
    });

    test('RAG stays disabled for a normal offline send', () async {
      final h = _Harness();

      await h.conversation.startNewConversationSession(
        'convB',
        'Chat B',
        'qwen3-06b',
        Message(text: 'Summarize nothing.', isUserMessage: true),
      );
      await h.offline.sendMessage(
          'Summarize nothing.', null, null, [], false, [], 'convB');

      expect(h.ragChat.called, isTrue);
      expect(h.ragChat.toggleEnabled, isFalse,
          reason: 'A plain offline chat must not query the RAG library.');
      expect(h.ragChat.documentIds, isEmpty);

      final prompt = h.prompts.single;
      expect(prompt, contains('Summarize nothing.'));
    });
  });

  group('BackgroundTaskService.seedBuffer (Continue-generating repair)', () {
    test('seeds the buffer with the kept partial; appended chunks continue it',
        () {
      final bgs = BackgroundTaskService();

      // Stale text from a crashed previous turn must be REPLACED by the
      // kept partial of the current turn.
      bgs.appendChunk('conv', 'stale-previous-turn');
      bgs.seedBuffer('conv', 'PARTIAL.');
      expect(bgs.peekBuffer('conv'), 'PARTIAL.');

      // Continuation chunks append to the seed: the final text is the
      // partial + continuation, exactly what a backgrounded completion
      // must persist.
      bgs.appendChunk('conv', ' CONTINUED');
      expect(bgs.consumeBuffer('conv'), 'PARTIAL. CONTINUED');
    });

    test('seeding an empty partial is a no-op (nothing lost)', () {
      final bgs = BackgroundTaskService();
      bgs.appendChunk('conv', 'already-buffered');
      bgs.seedBuffer('conv', '');
      expect(bgs.peekBuffer('conv'), 'already-buffered');
    });

    test('resetBuffer clears text for retries but keeps durable tool steps',
        () {
      final bgs = BackgroundTaskService();
      bgs.seedBuffer('conv', 'PARTIAL.');
      bgs.addToolStep('conv', 'searched-the-web');
      bgs.setTruncated('conv', true);

      bgs.resetBuffer('conv');

      expect(bgs.peekBuffer('conv'), '');
      expect(bgs.isTruncated('conv'), isFalse);
      expect(bgs.getToolSteps('conv'), ['searched-the-web'],
          reason: 'Tool steps are durable facts of the turn.');
    });
  });
}
