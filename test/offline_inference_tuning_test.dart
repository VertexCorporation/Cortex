import 'package:cortex/chat/services/offline_tuning.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfflineInferenceTuning threads', () {
    test('keeps UI headroom across mobile CPU tiers', () {
      expect(OfflineInferenceTuning.selectGenerationThreads(1), 1);
      expect(OfflineInferenceTuning.selectGenerationThreads(2), 1);
      expect(OfflineInferenceTuning.selectGenerationThreads(4), 3);
      expect(OfflineInferenceTuning.selectGenerationThreads(6), 4);
      expect(OfflineInferenceTuning.selectGenerationThreads(8), 6);
      expect(OfflineInferenceTuning.selectGenerationThreads(12), 8);
    });

    test('batch threads never consume every core', () {
      for (final cores in [2, 4, 6, 8, 12]) {
        expect(
          OfflineInferenceTuning.selectBatchThreads(cores),
          lessThan(cores),
        );
      }
    });
  });

  group('OfflineInferenceTuning context', () {
    test('parses common model context metadata', () {
      expect(OfflineInferenceTuning.parseModelContextLimit('8k'), 8192);
      expect(
        OfflineInferenceTuning.parseModelContextLimit('32 K tokens'),
        32768,
      );
      expect(OfflineInferenceTuning.parseModelContextLimit('4096'), 4096);
      expect(OfflineInferenceTuning.parseModelContextLimit(null), isNull);
    });

    test('small prompts start at 2048 even on an 8 GB device', () {
      expect(
        OfflineInferenceTuning.selectContextSize(
          prompt: 'Short conversation',
          totalRamMb: 8192,
          freeRamMb: 4096,
          modelContext: '8k',
        ),
        2048,
      );
    });

    test('context grows through 4096 and 8192 tiers with prompt demand', () {
      expect(
        OfflineInferenceTuning.selectContextSize(
          prompt: List.filled(4600, 'a').join(),
          totalRamMb: 8192,
          freeRamMb: 4096,
          modelContext: '8k',
        ),
        4096,
      );
      expect(
        OfflineInferenceTuning.selectContextSize(
          prompt: List.filled(11000, 'a').join(),
          totalRamMb: 8192,
          freeRamMb: 4096,
          modelContext: '8k',
        ),
        8192,
      );
    });

    test('RAM and model limits cap context growth', () {
      expect(
        OfflineInferenceTuning.selectContextSize(
          prompt: List.filled(11000, 'a').join(),
          totalRamMb: 4096,
          freeRamMb: 3000,
          modelContext: '8k',
        ),
        2048,
      );
      expect(
        OfflineInferenceTuning.selectContextSize(
          prompt: List.filled(11000, 'a').join(),
          totalRamMb: 16384,
          freeRamMb: 10000,
          modelContext: '4k',
        ),
        4096,
      );
    });
  });

  group('OfflineInferenceTuning batch', () {
    test('uses conservative batches on low-memory devices', () {
      final batch = OfflineInferenceTuning.selectBatchConfig(
        totalRamMb: 4096,
        freeRamMb: 1024,
        contextSize: 2048,
      );
      expect(batch.nBatch, 512);
      expect(batch.nUbatch, 128);
    });

    test('increases prefill batch without exceeding context', () {
      final batch = OfflineInferenceTuning.selectBatchConfig(
        totalRamMb: 8192,
        freeRamMb: 4096,
        contextSize: 1024,
      );
      expect(batch.nBatch, 1024);
      expect(batch.nUbatch, 512);
    });
  });
}
