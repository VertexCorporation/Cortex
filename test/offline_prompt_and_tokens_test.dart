// test/offline_prompt_and_tokens_test.dart
//
// Regression coverage for the offline system prompt and architecture-aware
// chat-template/token handling:
//
//  * ONE short, neutral English system prompt for EVERY offline model —
//    no locale-forcing directives, regardless of the device language.
//    (Locale forcing previously made a fresh English chat on a TR device
//    answer in Turkish and measurably degrades small local models.)
//  * A curated `role` (roleplay persona from the catalog) is the only
//    persona override.
//  * Prompt building consumes the model's own chatFormat tokens as published
//    by Synapse (chatml for Qwen, llama3 headers, [INST] for Llama 2,
//    and no system turn for Gemma).
//  * ChatFormatProcessor stops ONLY on the model's own stop tokens and
//    strips cross-family protocol markers without stopping on them.

import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/context.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/processor.dart';
import 'package:cortex/chat/services/response.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/library/backend/data/defaults.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/format.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/rag/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _llamaChannel = MethodChannel('com.vertex.cortex/llama');

// Special-token spellings identical to the published catalog values.
const String kImEnd = '\u003c|im_end|\u003e';
const String kEndOfText = '\u003c|endoftext|\u003e';
const String kSlashS = '\u003c/s\u003e';
const String kEotId = '<|eot_id|>';
const String kEndOfTurn = '<end_of_turn>';
const String kEndTag = '<|end|>';

/// The canonical Qwen (chatml) format as published by Synapse for qwen3-06b.
Map<String, dynamic> qwenChatFormat() => {
      'template': 'qwen',
      'tokens': {
        'system_start': '<|im_start|>system',
        'system_end': kImEnd,
        'user_start': '<|im_start|>user',
        'user_end': kImEnd,
        'assistant_start': '<|im_start|>assistant',
        'assistant_end': kImEnd,
        'stop_generation': [kImEnd, kEndOfText, kSlashS],
      },
    };

Map<String, dynamic> llama3ChatFormat() => {
      'template': 'llama3',
      'tokens': {
        'system_start':
            '<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n',
        'system_end': kEotId,
        'user_start': '<|start_header_id|>user<|end_header_id|>\n\n',
        'user_end': kEotId,
        'assistant_start': '<|start_header_id|>assistant<|end_header_id|>\n\n',
        'assistant_end': kEotId,
        'stop_generation': [kEotId, '<|end_of_text|>'],
      },
    };

Map<String, dynamic> llama2ChatFormat() => {
      'template': 'llama2',
      'tokens': {
        'system_start': '<<SYS>>',
        'system_end': '<</SYS>>',
        'user_start': '[INST]',
        'user_end': '[/INST]',
        'assistant_end': kSlashS,
        'stop_generation': [kSlashS, '[INST]', '[/INST]'],
      },
    };

Map<String, dynamic> gemmaChatFormat() => {
      'template': 'gemma',
      'tokens': {
        'user_start': '<start_of_turn>user\n',
        'user_end': '$kEndOfTurn\n',
        'assistant_start': '<start_of_turn>model\n',
        'assistant_end': '$kEndOfTurn\n',
        'stop_generation': [kEndOfTurn, '<eos>'],
      },
    };

ModelEntity offlineModel({
  required String id,
  Map<String, dynamic>? chatFormat,
  String? role,
}) =>
    ModelEntity.fromMap({
      'id': id,
      'title': id,
      'type': 'offline',
      'source': 'user',
      'category': 'chat',
      'tier': 'free',
      'role': role,
      'chatFormat': ?chatFormat,
    }, 'en');

class _FakeSession extends ChangeNotifier implements ChatSessionProvider {
  _FakeSession(this._locale);

  final Locale _locale;

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
  Locale getLocale() => _locale;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeModelService implements ModelService {
  _FakeModelService(this.model);

  final ModelEntity model;

  @override
  ModelEntity getPreciseModelData(String modelId, {required String langCode}) =>
      model;

  @override
  bool hasModality(String modelId,
          {required String langCode, String? modality}) =>
      false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRagChat implements RagChatService {
  @override
  Future<String?> buildContext({
    required String queryText,
    required bool toggleEnabled,
    required List<String> toggleDocumentIds,
    required List<String> attachmentPaths,
  }) async =>
      null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Harness {
  _Harness({Locale locale = const Locale('en'), ModelEntity? model}) {
    model ??= offlineModel(id: 'qwen3-06b', chatFormat: qwenChatFormat());
    conversation = ConversationProvider();
    offline = OfflineService(
      responseService: ResponseService(
        conversationProvider: conversation,
        scrollService: ScrollService(),
      ),
      sessionProvider: _FakeSession(locale),
      modelService: _FakeModelService(model),
      contextService: ContextService(
        conversationProvider: conversation,
        modelService: _FakeModelService(model),
      ),
      ragChat: _FakeRagChat(),
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_llamaChannel, (call) async {
      calls.add(call.method);
      if (call.method == 'sendMessage') {
        prompts.add(call.arguments['message'] as String);
      }
      return null;
    });
  }

  late ConversationProvider conversation;
  late OfflineService offline;
  final List<String> calls = [];
  final List<String> prompts = [];

  Future<void> send(String text, String convId) async {
    await conversation.startNewConversationSession(
      convId,
      'Chat $convId',
      'qwen3-06b',
      Message(text: text, isUserMessage: true),
    );
    await offline.sendMessage(text, null, null, [], false, [], convId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_llamaChannel, null);
  });

  group('offline system prompt (single, neutral, English)', () {
    test('every locale gets the same short neutral prompt; no forcing',
        () async {
      for (final locale in [const Locale('en'), const Locale('tr')]) {
        final h = _Harness(locale: locale);
        await h.send('Hello!', 'convA');

        final prompt = h.prompts.single;
        expect(
            prompt,
            contains(
                "You are a helpful AI assistant running inside Cortex, Türkiye's largest B2C AI platform."));
        // Locale-forcing directives are gone for every locale.
        expect(prompt, isNot(contains('Türkçe konuşan')));
        expect(prompt, isNot(contains('Deutsch spricht')));
        expect(prompt, isNot(contains('parle français')));
        expect(prompt, isNot(contains('-speaking assistant')));
        expect(prompt, isNot(contains('plain text only')));
      }
    });

    test(
        'the exact final prompt for a fresh chat: one system turn + one user '
        'turn + the assistant primer — nothing else',
        () async {
      // The reproduction case: a fresh English chat asking
      // "hello how are you feeling today". The composition log showed
      // system=1, historyMessages=0, latestUser=1, ragInjected=false,
      // chatFormatProvided=true — this pins the resulting prompt EXACTLY.
      // There is no language instruction of any kind: no device-locale
      // forcing, no hidden Turkish directive, no stale system prompt and no
      // RAG preamble. (A 600M model that then "decides" the reply must be in
      // Turkish "as per the user's request" is hallucinating — nothing in
      // this prompt asks for a language; the only Türkiye mention is the
      // brand line below, which is NOT a language directive.)
      const expectedPrompt = '<|im_start|>system\n'
          "You are a helpful AI assistant running inside Cortex, Türkiye's "
          'largest B2C AI platform.\n'
          '<|im_end|>\n'
          '<|im_start|>user\n'
          'hello how are you feeling today\n'
          '<|im_end|>\n'
          '<|im_start|>assistant\n';

      for (final locale in [const Locale('en'), const Locale('tr')]) {
        final h = _Harness(locale: locale);
        await h.send('hello how are you feeling today', 'convA');
        expect(h.prompts.single, expectedPrompt,
            reason: 'locale ${locale.languageCode} must compose the exact '
                'same prompt');
      }
    });

    test('a curated roleplay role is the only persona override', () async {
      final h = _Harness(
        model: offlineModel(
            id: 'self-hero',
            chatFormat: qwenChatFormat(),
            role: 'You are Max, a brave explorer.'),
      );
      await h.send('Hi!', 'convA');

      final prompt = h.prompts.single;
      expect(prompt, contains('You are Max, a brave explorer.'));
      expect(prompt, isNot(contains('You are a helpful AI assistant')));
    });

    test("prompt is built with the model's own chatFormat tokens", () async {
      final h = _Harness(
        model: offlineModel(id: 'llama-3-1-8b', chatFormat: llama3ChatFormat()),
      );
      await h.send('Hello!', 'convA');

      final prompt = h.prompts.single;
      // System turn uses the Llama 3 header format and its own end token.
      expect(prompt, contains('<|begin_of_text|>'));
      expect(prompt, contains('<|start_header_id|>system<|end_header_id|>'));
      expect(prompt, contains(kEotId));
      // The user turn is wrapped in Llama 3 headers too.
      expect(prompt, contains('<|start_header_id|>user<|end_header_id|>'));
    });

    test('llama-2 models are formatted with the [INST] convention', () async {
      final h = _Harness(
        model:
            offlineModel(id: 'llama-2-7b-chat', chatFormat: llama2ChatFormat()),
      );
      await h.send('Hello!', 'convA');

      final prompt = h.prompts.single;
      expect(prompt, contains('<<SYS>>'));
      expect(prompt, contains('[INST]'));
      expect(prompt, contains('Hello!'));
      expect(prompt, contains('[/INST]'));
    });

    test('gemma has no system role: the system prompt is omitted entirely',
        () async {
      final h = _Harness(
        model:
            offlineModel(id: 'gemma-3-12b-it', chatFormat: gemmaChatFormat()),
      );
      await h.send('Hello!', 'convA');

      final prompt = h.prompts.single;
      expect(prompt, contains('<start_of_turn>user'));
      expect(prompt, isNot(contains('You are a helpful AI assistant')),
          reason: 'gemma does not support a system turn');
    });
  });

  group('ChatFormatProcessor (architecture-aware stop & strip)', () {
    test('chatml: stops on its own im_end marker, split across tokens', () {
      var stopped = false;
      final p = ChatFormatProcessor(
        ChatFormat.fromMap(qwenChatFormat()),
        onStopTokenDetected: () => stopped = true,
      );

      expect(p.processToken('Hello'), 'Hello');
      // The stop token arrives character-by-character.
      for (final ch in kImEnd.split('')) {
        expect(p.processToken(ch), isNull);
      }
      expect(stopped, isTrue);
      // Everything after the stop token is ignored.
      expect(p.processToken('extra'), isNull);
    });

    test('chatml: foreign stop markers are stripped but never stop generation',
        () {
      var stopped = false;
      final p = ChatFormatProcessor(
        ChatFormat.fromMap(qwenChatFormat()),
        onStopTokenDetected: () => stopped = true,
      );

      // A Llama-3 marker is NOT a stop token for a Qwen model.
      for (final ch in kEotId.split('')) {
        expect(p.processToken(ch), isNull);
      }
      expect(stopped, isFalse, reason: 'foreign markers must not stop chatml');
      expect(p.processToken('still here'), 'still here');
    });

    test('llama3: stops on its eot marker, not on chatml markers', () {
      var stopped = false;
      final p = ChatFormatProcessor(
        ChatFormat.fromMap(llama3ChatFormat()),
        onStopTokenDetected: () => stopped = true,
      );

      for (final ch in kImEnd.split('')) {
        expect(p.processToken(ch), isNull);
      }
      expect(stopped, isFalse);
      expect(p.processToken('ok'), 'ok');
      for (final ch in kEotId.split('')) {
        expect(p.processToken(ch), isNull);
      }
      expect(stopped, isTrue);
    });

    test('llama2: stops on its [INST] and </s> tokens', () {
      var stopped = false;
      final p = ChatFormatProcessor(
        ChatFormat.fromMap(llama2ChatFormat()),
        onStopTokenDetected: () => stopped = true,
      );

      expect(p.processToken('Hi there'), 'Hi there');
      for (final ch in kSlashS.split('')) {
        expect(p.processToken(ch), isNull);
      }
      expect(stopped, isTrue);
    });

    test('gemma: stops on its end_of_turn marker', () {
      var stopped = false;
      final p = ChatFormatProcessor(
        ChatFormat.fromMap(gemmaChatFormat()),
        onStopTokenDetected: () => stopped = true,
      );

      for (final ch in kEndOfTurn.split('')) {
        expect(p.processToken(ch), isNull);
      }
      expect(stopped, isTrue);
    });

    test('cross-family protocol markers never leak as visible text', () {
      var stopped = false;
      final p = ChatFormatProcessor(
        ChatFormat.fromMap(qwenChatFormat()),
        onStopTokenDetected: () => stopped = true,
      );

      // All well-known protocol markers are consumed silently. This list
      // deliberately EXCLUDES the qwen fixture's own stop tokens
      // (im_end / endoftext / "</s>") — those legitimately stop generation.
      for (final marker in [
        '<|im_start|>',
        '<|eot_id|>',
        '<|end_of_text|>',
        '<|start_header_id|>',
        '<|end_header_id|>',
        '<start_of_turn>',
        '<end_of_turn>',
        kEndTag,
        '<|start|>',
        '<|message|>',
        '<|channel|>',
        '<|return|>',
      ]) {
        for (final ch in marker.split('')) {
          expect(p.processToken(ch), isNull, reason: 'marker leaked: $marker');
        }
      }
      expect(stopped, isFalse, reason: 'strip-only markers must not stop');
      expect(p.processToken('visible'), 'visible');
    });
  });

  group('ModelDefaults.getFallbackFormat (last-resort, mirrors the catalog)',
      () {
    test('routes legacy cached ids to the canonical family templates', () {
      expect(ModelDefaults.getFallbackFormat('qwen3-06b')['template'],
          'chatml');
      expect(ModelDefaults.getFallbackFormat('next-1b')['template'],
          'chatml');
      expect(
          ModelDefaults.getFallbackFormat('Qwen/Qwen3-0.6B-GGUF:x.gguf')
              ['template'],
          'chatml');
      expect(
          ModelDefaults.getFallbackFormat('Meta-Llama-3.1-8B-Instruct')
              ['template'],
          'llama3');
      expect(ModelDefaults.getFallbackFormat('llama-2-7b-chat')['template'],
          'llama2');
      expect(
          ModelDefaults.getFallbackFormat('mistral-7b-instruct-v02')
              ['template'],
          'llama2');
      expect(ModelDefaults.getFallbackFormat('gemma-3-12b-it')['template'],
          'gemma');
      expect(ModelDefaults.getFallbackFormat('phi-4')['template'], 'phi3');
      expect(ModelDefaults.getFallbackFormat('GLM-4.7-Flash')['template'],
          'phi3');
      expect(
          ModelDefaults.getFallbackFormat('Nous Hermes 2 Pro Mistral 7B')
              ['template'],
          'chatml');
    });
  });
}
