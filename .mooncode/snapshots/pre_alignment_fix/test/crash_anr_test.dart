// test/crash_anr_test.dart
//
// Crash & ANR (Application Not Responding) Koruma Testleri
//
// Bu testler şunları doğrular:
//   1. CRASH: Sınır ve null değerlerinde hiçbir kod throw etmez
//   2. ANR: Hiçbir iş senkron olarak gereğinden uzun ana thread'i bloke etmez
//   3. Güvenli hata yutma: try/catch blokları beklendiği gibi çalışır
//
// Eşik değerleri: dart test VM JIT warmup dahil gerçekçi tutulmuştur.

import 'dart:io';
import 'package:cortex/cache.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // =========================================================================
  // GRUP 1: NULL & EMPTY INPUT — Crash Koruma
  // =========================================================================
  group('Crash Protection — Null and Empty Inputs', () {
    test('ModelEntity.fromMap with empty map does not crash', () {
      expect(() => ModelEntity.fromMap({}, 'en'), returnsNormally);
    });

    test('ModelEntity.fromMap with null values does not crash', () {
      expect(
        () => ModelEntity.fromMap({
          'id': null,
          'title': null,
          'tier': null,
          'type': null,
          'category': null,
          'modalities': null,
        }, 'en'),
        returnsNormally,
      );
    });

    test('ModelEntity.fromMap with partial data does not crash', () {
      expect(() => ModelEntity.fromMap({'id': 'test-model'}, 'en'), returnsNormally);
      expect(() => ModelEntity.fromMap({'title': 'Only Title'}, 'en'), returnsNormally);
    });

    test('ModelDataUtils.cleanTitle with null does not crash', () {
      expect(() => ModelDataUtils.cleanTitle(null), returnsNormally);
      expect(() => ModelDataUtils.cleanTitle(''), returnsNormally);
      expect(() => ModelDataUtils.cleanTitle('   '), returnsNormally);
    });

    test('ModelDataUtils.formatModelName with edge cases does not crash', () {
      expect(() => ModelDataUtils.formatModelName(''), returnsNormally);
      expect(() => ModelDataUtils.formatModelName('/'), returnsNormally);
      expect(() => ModelDataUtils.formatModelName('---'), returnsNormally);
      expect(() => ModelDataUtils.formatModelName('1234'), returnsNormally);
      expect(() => ModelDataUtils.formatModelName('a' * 1000), returnsNormally);
    });

    test('ModelEntity.toMap does not crash for any valid entity', () {
      final model = ModelEntity.fromMap({'id': 'test', 'title': 'Test'}, 'en');
      expect(() => model.toMap(), returnsNormally);
    });

    test('ModelEntity.copyWith does not crash', () {
      final model = ModelEntity.fromMap({'id': 'test', 'title': 'Test'}, 'en');
      expect(() => model.copyWith(displayTitle: 'New Title'), returnsNormally);
      expect(() => model.copyWith(displayTitle: ''), returnsNormally);
      expect(() => model.copyWith(displayTitle: null), returnsNormally);
    });
  });

  // =========================================================================
  // GRUP 2: ANR Koruması — UI Thread Bloke Testi
  // =========================================================================
  group('ANR Protection — Main Thread Block Prevention', () {
    // Dart test VM'de JIT warmup ile 100ms eşiği gerçekçidir.
    // Release modda aynı işlemler <5ms sürer.
    const anrThresholdMs = 100;

    test('[ANR] Message.fromMap never blocks >${anrThresholdMs}ms', () {
      final map = {
        'text': 'A' * 10000,
        'uuid': 'msg-001',
        'isUser': 1,
        'attachmentPaths': List.generate(9, (i) => '/path/img$i.jpg'),
        'model': 'gemini-pro',
      };

      final sw = Stopwatch()..start();
      Message.fromMap(map);
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(anrThresholdMs),
          reason: 'Message deserialization is in the critical UI rendering path');
    });

    test('[ANR] InputProvider.resetInputState never blocks >${anrThresholdMs}ms', () {
      final provider = InputProvider();
      provider.setFeatureMode(ChatInputMode.study);
      provider.setVoiceRecording(true);
      provider.setAttachmentLoading(true);

      final sw = Stopwatch()..start();
      provider.resetInputState();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(anrThresholdMs));
      provider.dispose();
    });

    test('[ANR] CacheService.set never blocks >${anrThresholdMs}ms for any key', () {
      for (final key in CacheKey.values) {
        final sw = Stopwatch()..start();
        CacheService.set(key, List.generate(500, (i) => 'item-$i'));
        sw.stop();
        expect(sw.elapsedMilliseconds, lessThan(anrThresholdMs),
            reason: 'CacheService.set(${key.name}) blocked too long');
      }
      CacheService.clearAll();
    });

    test('[ANR] CacheService.invalidateConversationCache never blocks >${anrThresholdMs}ms', () {
      CacheService.set(CacheKey.conversationManagers, ['c1', 'c2']);
      CacheService.set(CacheKey.conversationOrder, [1, 2]);

      final sw = Stopwatch()..start();
      CacheService.invalidateConversationCache();
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(anrThresholdMs));
    });

    test('[ANR] Parsing 50 ModelEntities never blocks >${anrThresholdMs}ms', () {
      final rawList = List.generate(50, (i) => {
        'id': 'model-$i',
        'title': {'en': 'Model Number $i', 'tr': 'Model $i'},
        'tier': i.isEven ? 'free' : 'premium',
        'type': 'online',
        'category': 'chat',
        'modalities': {'text': true, 'image': i % 3 == 0},
        'outputs': {'text': true},
      });

      final sw = Stopwatch()..start();
      for (final raw in rawList) {
        ModelEntity.fromMap(raw, 'en');
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(anrThresholdMs),
          reason: 'Catalog page rendering must not be slow');
    });
  });

  // =========================================================================
  // GRUP 3: Sınır Değerleri — Boundary Crash Testleri
  // =========================================================================
  group('Crash Protection — Boundary Values', () {
    test('InputProvider: adding beyond max (9) attachment limit does not crash', () {
      final provider = InputProvider();
      expect(() {
        for (int i = 0; i < 50; i++) {
          provider.addAttachment(File('img$i.jpg'), isImage: true);
        }
      }, returnsNormally);

      // Must cap at 9
      expect(provider.attachments.length, 9);
      provider.dispose();
    });

    test('Message with empty attachmentPaths list does not crash', () {
      expect(
        () => Message(
          isUserMessage: true,
          text: '',
          id: '',
          attachmentPaths: [],
        ),
        returnsNormally,
      );
    });

    test('Message with very long text does not crash', () {
      expect(
        () => Message(
          isUserMessage: true,
          text: 'X' * 100000,
          id: 'long-msg',
          attachmentPaths: [],
        ),
        returnsNormally,
      );
    });

    test('ModelEntity with extremely long title does not crash', () {
      expect(
        () => ModelEntity.fromMap({'id': 'x', 'title': 'A' * 10000}, 'en'),
        returnsNormally,
      );
    });

    test('CacheService: setting very large data does not crash', () {
      final bigList = List.generate(10000, (i) => {'id': 'item-$i', 'data': 'X' * 100});
      expect(() => CacheService.set(CacheKey.allModels, bigList), returnsNormally);
      CacheService.clearAll();
    });

    test('CacheService: double invalidate of same key does not crash', () {
      CacheService.set(CacheKey.allModels, ['x']);
      expect(() {
        CacheService.invalidate(CacheKey.allModels);
        CacheService.invalidate(CacheKey.allModels);
      }, returnsNormally);
    });

    test('CacheService: double clearAll does not crash', () {
      expect(() {
        CacheService.clearAll();
        CacheService.clearAll();
      }, returnsNormally);
    });

    test('InputProvider: cancelEditing when not editing does not crash', () {
      final provider = InputProvider();
      expect(() => provider.cancelEditing(), returnsNormally);
      provider.dispose();
    });

    test('InputProvider: removeAttachmentAt with invalid index does not crash', () {
      final provider = InputProvider();
      // 0 attachments, try to remove index 0
      expect(() => provider.removeAttachmentAt(0), returnsNormally);
      provider.dispose();
    });
  });

  // =========================================================================
  // GRUP 4: Error Recovery — Graceful Degradation
  // =========================================================================
  group('Error Recovery — Graceful Degradation', () {
    test('ModelEntity.fromMap with malformed variants does not crash', () {
      expect(
        () => ModelEntity.fromMap({
          'id': 'model-x',
          'variants': 'not-a-map',
        }, 'en'),
        returnsNormally,
      );

      expect(
        () => ModelEntity.fromMap({
          'id': 'model-x',
          'variants': [1, 2, 3],
        }, 'en'),
        returnsNormally,
      );
    });

    test('ModelEntity.fromMap with malformed modalities does not crash', () {
      expect(
        () => ModelEntity.fromMap({
          'id': 'model-x',
          'modalities': 'text,image',
        }, 'en'),
        returnsNormally,
      );
    });

    test('Message.fromMap with missing fields falls back gracefully', () {
      final msg = Message.fromMap({'text': 'Hello'});
      expect(msg, isNotNull);
      expect(msg.text, 'Hello');
    });

    test('Message.fromMap with legacy photoPath field works', () {
      final msg = Message.fromMap({
        'text': 'With photo',
        'uuid': 'old-msg',
        'photoPath': '/old/path/photo.jpg',
        'isUser': 1,
      });
      expect(msg.attachmentPaths, contains('/old/path/photo.jpg'));
    });
  });
}
