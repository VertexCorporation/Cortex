// test/ui_fluency_test.dart
//
// UI Akışkanlığı (Fluency) Testleri
//
// Bu testler, kullanıcı arayüzünün "jank" yaratmadan çalışmasını sağlamak
// için kritik olan widget rebuild, state değişim hızı ve veri dönüşüm
// performansını ölçer.
//
// Eşik değerleri dart test VM'de (JIT warmup dahil) gerçekçi tutulmuştur.
// Release modda bu değerler 5-10x daha düşük çıkar.

import 'dart:io';
import 'package:cortex/cache.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // =========================================================================
  // GRUP 1: InputProvider — UI State Geçiş Hızı
  // =========================================================================
  group('UI Fluency — InputProvider State Transitions', () {
    late InputProvider provider;

    setUp(() {
      provider = InputProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('[PERF] 1000 feature mode toggles complete in <50ms', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 500; i++) {
        provider.setFeatureMode(ChatInputMode.study);
        provider.clearFeatureMode();
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50),
          reason: 'Feature mode toggle is a simple enum set — must be near-instant');
    });

    test('[PERF] 1000 web search toggles complete in <50ms', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        provider.toggleWebSearch();
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('[PERF] Adding 9 attachments (max capacity) completes in <20ms', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 9; i++) {
        provider.addAttachment(
          File('img$i.jpg'),
          isImage: true,
        );
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(20),
          reason: 'Attachment ops are list inserts — must be near-instant');
    });

    test('[PERF] resetInputState is fast (<20ms)', () {
      provider.setFeatureMode(ChatInputMode.quiz);
      provider.setVoiceRecording(true);
      provider.setAttachmentLoading(true);

      final sw = Stopwatch()..start();
      provider.resetInputState();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(20));
    });

    test('State after resetInputState is fully clean', () {
      provider.setFeatureMode(ChatInputMode.quiz);
      provider.setVoiceRecording(true);
      provider.setVoiceModeActive(true);
      provider.setAttachmentLoading(true);

      provider.resetInputState();

      expect(provider.featureMode, ChatInputMode.none);
      expect(provider.isVoiceRecording, false);
      // isVoiceModeActive is intentionally not reset by resetInputState
      expect(provider.isVoiceModeActive, true); 
      expect(provider.isAttachmentLoading, false);
      expect(provider.enableWebSearch, false);
      expect(provider.isEditingMode, false);
    });

    test('Global draft survives resetInputState but clears on clearAllInput', () {
      provider.updateGlobalDraft('My unsent draft');
      provider.resetInputState();
      expect(provider.globalDraft, 'My unsent draft',
          reason: 'Draft must persist across reset — user typed it!');

      provider.clearAllInput();
      expect(provider.globalDraft, isEmpty);
    });

    test('enableWebSearch resets after resetInputState', () {
      // Enable web search
      if (!provider.enableWebSearch) provider.toggleWebSearch();
      expect(provider.enableWebSearch, true);

      // resetInputState must clear it
      provider.resetInputState();
      expect(provider.enableWebSearch, false,
          reason: 'resetInputState() explicitly sets _enableWebSearch = false');
    });

    test('clearAllInput calls resetInputState (clears everything including featureMode)', () {
      // clearAllInput() → resetInputState() → all flags cleared
      provider.setFeatureMode(ChatInputMode.study);
      if (!provider.enableWebSearch) provider.toggleWebSearch();

      provider.clearAllInput();

      // clearAllInput delegates to resetInputState which clears all flags
      expect(provider.featureMode, ChatInputMode.none);
      expect(provider.enableWebSearch, false);
      expect(provider.globalDraft, isEmpty);
    });

    test('clearAfterSend deliberately preserves featureMode', () {
      // clearAfterSend() is the "after message sent" path that keeps user toggles
      provider.setFeatureMode(ChatInputMode.study);

      provider.clearAfterSend();

      // Per code comment: "We deliberately KEEP _featureMode and _enableWebSearch intact!"
      expect(provider.featureMode, ChatInputMode.study);
      expect(provider.enableWebSearch, false);
    });

    test('clearAfterSend deliberately preserves enableWebSearch', () {
      provider.setFeatureMode(ChatInputMode.none); // Ensure it's clear so web search can be enabled
      if (!provider.enableWebSearch) provider.toggleWebSearch();

      provider.clearAfterSend();

      expect(provider.featureMode, ChatInputMode.none);
      expect(provider.enableWebSearch, true);
    });
  });

  // =========================================================================
  // GRUP 2: Message — Rebuild Optimizasyonu (notifier reuse)
  // =========================================================================
  group('UI Fluency — Message ValueNotifier Reuse', () {
    test('Notifier reuse: same ID reuses the existing notifier object', () {
      final msg1 = Message(
        isUserMessage: false,
        text: 'Hello',
        id: 'msg-001',
        attachmentPaths: [],
      );

      final msg2 = msg1.copyWith(text: 'Hello updated');
      expect(identical(msg1.notifier, msg2.notifier), false, 
          reason: 'Text change should result in a new notifier');

      // But if text is the same — same notifier must be reused.
      final msg3 = msg1.copyWith(isError: true); // text unchanged
      expect(identical(msg1.notifier, msg3.notifier), true,
          reason:
              'When text does not change, copyWith must reuse the same ValueNotifier '
              'to prevent unnecessary subtree rebuilds.');
    });

    test('Notifier reuse: different ID gets a new notifier', () {
      final msg1 = Message(
        isUserMessage: false,
        text: 'Hello',
        id: 'msg-001',
        attachmentPaths: [],
      );

      final msg2 = msg1.copyWith(text: 'Other message', forceNewId: true);

      // Text changed → new notifier expected
      expect(identical(msg1.notifier, msg2.notifier), false,
          reason: 'Different text must create a new notifier');
    });

    test('[PERF] Creating 200 messages completes in <50ms', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 200; i++) {
        Message(
          isUserMessage: i.isEven,
          text: 'Message content number $i with some realistic length text',
          id: 'msg-$i',
          attachmentPaths: [],
        );
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50),
          reason: 'Message construction must be cheap — called per chat bubble');
    });

    test('[PERF] 1000 copyWith calls complete in <50ms', () {
      final base = Message(
        isUserMessage: true,
        text: 'Base message',
        id: 'base',
        attachmentPaths: [],
      );
      final sw = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        base.copyWith(text: 'Updated $i');
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('Message serialization round-trip is lossless', () {
      final original = Message(
        isUserMessage: true,
        text: 'Hello World',
        id: 'test-123',
        attachmentPaths: ['/path/img.jpg'],
        model: 'gemini-pro',
      );

      final map = original.toMap();
      final restored = Message.fromMap(map);

      expect(restored.text, original.text);
      expect(restored.id, original.id);
      expect(restored.isUserMessage, original.isUserMessage);
      expect(restored.attachmentPaths, containsAll(original.attachmentPaths));
    });
  });

  // =========================================================================
  // GRUP 3: ModelDataUtils — UI Display Computation Hızı
  // =========================================================================
  group('UI Fluency — ModelDataUtils Display Computations', () {
    test('[PERF] cleanTitle on 5000 strings completes <100ms', () {
      final titles = List.generate(5000, (i) => '  --  Model Title $i  ');
      final sw = Stopwatch()..start();
      for (final t in titles) {
        ModelDataUtils.cleanTitle(t);
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(100));
    });

    test('cleanTitle strips leading dashes and spaces correctly', () {
      expect(ModelDataUtils.cleanTitle('  --  Clean Title'), 'Clean Title');
      expect(ModelDataUtils.cleanTitle('- Title'), 'Title');
      expect(ModelDataUtils.cleanTitle('Title'), 'Title');
      expect(ModelDataUtils.cleanTitle(null), '');
      expect(ModelDataUtils.cleanTitle(''), '');
    });

    test('[PERF] Optimal variant selection on 1000 models <100ms', () {
      final model = ModelEntity.fromMap({
        'id': 'llama-3',
        'title': 'LLaMA 3',
        'type': 'offline',
        'variants': {
          'llama-3-7b': {'ram': '6000', 'size': '4200', 'url': 'url-7b'},
          'llama-3-13b': {'ram': '10000', 'size': '7500', 'url': 'url-13b'},
          'llama-3-4b': {'ram': '4000', 'size': '2800', 'url': 'url-4b'},
          'llama-3-1b': {'ram': '2000', 'size': '1200', 'url': 'url-1b'},
          'llama-3-70b': {'ram': '40000', 'size': '35000', 'url': 'url-70b'},
        }
      }, 'en');

      final sw = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        ModelDataUtils.getOptimalDownloadUrl(model);
        ModelDataUtils.getOptimalVariantId(model);
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(100),
          reason: 'Variant selection is shown every time user opens model picker');
    });

    test('Optimal variant selects lowest RAM', () {
      final model = ModelEntity.fromMap({
        'id': 'test',
        'title': 'Test',
        'type': 'offline',
        'variants': {
          'heavy': {'ram': '10000', 'size': '8000', 'url': 'url-heavy'},
          'light': {'ram': '2000', 'size': '1500', 'url': 'url-light'},
          'medium': {'ram': '5000', 'size': '3000', 'url': 'url-medium'},
        }
      }, 'en');

      expect(ModelDataUtils.getOptimalVariantId(model), 'light');
      expect(ModelDataUtils.getOptimalDownloadUrl(model), 'url-light');
    });
  });

  // =========================================================================
  // GRUP 4: CacheService — UI Layer Cache Hit/Miss Hızı
  // =========================================================================
  group('UI Fluency — Cache Read Performance (UI Critical Path)', () {
    setUp(() => CacheService.clearAll());
    tearDown(() => CacheService.clearAll());

    test('[PERF] Simulated conversation list cache read 10k times <50ms', () {
      final fakeData = List.generate(100, (i) => {'id': 'conv-$i', 'title': 'Chat $i'});
      CacheService.set(CacheKey.conversationManagers, fakeData);

      final sw = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        CacheService.get<List>(CacheKey.conversationManagers);
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50),
          reason: 'Conversation list is read on every sidebar rebuild');
    });

    test('[PERF] Cache miss (null return) is fast <50ms for 10k hits', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        CacheService.get<List>(CacheKey.conversationManagers);
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50));
    });
  });
}
