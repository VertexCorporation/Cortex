import 'dart:convert';
import 'dart:math' as math;

/// Pure, deterministic tuning helpers for on-device llama.cpp inference.
///
/// Keeping these decisions outside the platform bridge makes them testable and
/// ensures Android and iOS receive the same conservative device profile.
class OfflineInferenceTuning {
  static const int minimumContextSize = 2048;
  static const int maximumContextSize = 8192;
  static const int outputTokenReserve = 512;

  static int selectGenerationThreads(int logicalCoreCount) {
    final cores = math.max(1, logicalCoreCount);
    if (cores <= 2) return 1;
    if (cores <= 4) return cores - 1;
    if (cores <= 6) return math.min(4, cores - 1);
    if (cores <= 8) return math.min(6, cores - 2);
    return math.min(8, cores - 2);
  }

  static int selectBatchThreads(int logicalCoreCount) {
    final cores = math.max(1, logicalCoreCount);
    final generationThreads = selectGenerationThreads(cores);
    if (cores <= 4) return generationThreads;
    return math.min(cores - 1, generationThreads + 1);
  }

  /// Conservative tokenizer-independent estimate. UTF-8 bytes are used so
  /// code, CJK, emoji and other token-dense prompts are not underestimated as
  /// badly as a simple character/4 heuristic.
  static int estimatePromptTokens(String prompt) {
    if (prompt.isEmpty) return 0;
    return (utf8.encode(prompt).length / 2).ceil() + 16;
  }

  /// Parses catalog values such as `8k`, `8192`, `32 K tokens`, or `4.0K`.
  static int? parseModelContextLimit(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase().replaceAll(',', '');
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*([km]?)').firstMatch(normalized);
    if (match == null) return null;

    final amount = double.tryParse(match.group(1)!);
    if (amount == null || amount <= 0) return null;
    final suffix = match.group(2);
    final multiplier = suffix == 'm'
        ? 1000000
        : suffix == 'k'
            ? 1024
            : 1;
    return (amount * multiplier).floor();
  }

  static int selectContextSize({
    required String prompt,
    required int totalRamMb,
    required int freeRamMb,
    String? modelContext,
  }) {
    final safeTotalRam = math.max(0, totalRamMb);
    final safeFreeRam = math.max(0, freeRamMb);

    var ramLimit = minimumContextSize;
    if (safeTotalRam >= 6144 && safeFreeRam >= 2048) {
      ramLimit = 4096;
    }
    if (safeTotalRam >= 8192 && safeFreeRam >= 3072) {
      ramLimit = maximumContextSize;
    }

    final catalogLimit = parseModelContextLimit(modelContext);
    final maxAllowed = catalogLimit == null
        ? ramLimit
        : math.max(1, math.min(ramLimit, catalogLimit));
    final required = estimatePromptTokens(prompt) + outputTokenReserve;

    for (final tier in const [2048, 4096, 8192]) {
      if (tier >= required) return math.min(tier, maxAllowed);
    }
    return maxAllowed;
  }

  static OfflineBatchConfig selectBatchConfig({
    required int totalRamMb,
    required int freeRamMb,
    required int contextSize,
  }) {
    var nBatch = 512;
    var nUbatch = 128;

    if (totalRamMb >= 6144 && freeRamMb >= 2048) {
      nBatch = 1024;
      nUbatch = 256;
    }
    if (totalRamMb >= 8192 && freeRamMb >= 3072) {
      nBatch = 2048;
      nUbatch = 512;
    }

    nBatch = math.max(32, math.min(nBatch, contextSize));
    nUbatch = math.max(32, math.min(nUbatch, nBatch));
    return OfflineBatchConfig(nBatch: nBatch, nUbatch: nUbatch);
  }
}

class OfflineBatchConfig {
  final int nBatch;
  final int nUbatch;

  const OfflineBatchConfig({required this.nBatch, required this.nUbatch});
}

class OfflineRuntimeConfig {
  final int nCtx;
  final int nThreads;
  final int nThreadsBatch;
  final int nBatch;
  final int nUbatch;
  final int nGpuLayers;
  final int totalRamMb;
  final int freeRamMb;
  final int logicalCoreCount;

  const OfflineRuntimeConfig({
    required this.nCtx,
    required this.nThreads,
    required this.nThreadsBatch,
    required this.nBatch,
    required this.nUbatch,
    required this.nGpuLayers,
    required this.totalRamMb,
    required this.freeRamMb,
    required this.logicalCoreCount,
  });
}
