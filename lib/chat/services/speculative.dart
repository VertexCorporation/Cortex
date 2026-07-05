// lib/chat/services/speculative.dart
//
// Speculative Decoding Service
//
// Implements the mathematical framework for lossless speculative decoding
// to accelerate local model inference while preserving the exact target
// distribution p(x).
//
// Acceptance rule:      α(x) = min(1, p(x)/q(x))
// Rejection resample:   p_kalan(x) = max(0, p(x)-q(x)) / Σ max(0, p(x)-q(x))
// Expected block len:   E[τ] = (1 - α^(γ+1)) / (1 - α)
// Latency improvement:  L = (T_draft + T_verify) / τ
//
// DSpark extensions:
//   - Semi-autoregressive correction via low-rank (rank-256) Markov head
//   - Confidence score calibration: c'_i = σ(logit(c_i)/T)
//   - Load-aware verification length: k ≈ argmax_k [E[τ|k] × SPS(B, k)]

import 'dart:math' as math;

class SpeculativeDecodingConfig {
  final bool enabled;
  final String? draftModelPath;
  final int draftBlockSize;
  final double draftTemperature;
  final int lowRankDimension;
  final double calibrationTemperature;
  final bool loadAwareVerification;

  const SpeculativeDecodingConfig({
    this.enabled = false,
    this.draftModelPath,
    this.draftBlockSize = 5,
    this.draftTemperature = 0.6,
    this.lowRankDimension = 256,
    this.calibrationTemperature = 1.0,
    this.loadAwareVerification = false,
  });

  Map<String, dynamic> toNativeArgs() => {
        'specDecodeEnabled': enabled,
        if (draftModelPath != null) 'draftModelPath': draftModelPath,
        'draftBlockSize': draftBlockSize,
        'draftTemp': draftTemperature,
        'lowRankDim': lowRankDimension,
      };

  SpeculativeDecodingConfig copyWith({
    bool? enabled,
    String? draftModelPath,
    int? draftBlockSize,
    double? draftTemperature,
    int? lowRankDimension,
    double? calibrationTemperature,
    bool? loadAwareVerification,
  }) =>
      SpeculativeDecodingConfig(
        enabled: enabled ?? this.enabled,
        draftModelPath: draftModelPath ?? this.draftModelPath,
        draftBlockSize: draftBlockSize ?? this.draftBlockSize,
        draftTemperature: draftTemperature ?? this.draftTemperature,
        lowRankDimension: lowRankDimension ?? this.lowRankDimension,
        calibrationTemperature:
            calibrationTemperature ?? this.calibrationTemperature,
        loadAwareVerification: loadAwareVerification ?? this.loadAwareVerification,
      );
}

class SpeculativeDecodingMath {
  /// Acceptance probability: α(x) = min(1, p(x)/q(x))
  static double acceptanceProbability(double pX, double qX) {
    if (qX <= 0) return pX > 0 ? 1.0 : 0.0;
    return math.min(1.0, pX / qX);
  }

  /// Expected block length: E[τ] = (1 - α^(γ+1)) / (1 - α)
  static double expectedBlockLength(double avgAlpha, int draftBlockSize) {
    if (avgAlpha >= 1.0) return double.infinity;
    if (avgAlpha <= 0) return 1.0;
    final power = math.pow(avgAlpha, draftBlockSize + 1);
    return (1 - power) / (1 - avgAlpha);
  }

  /// Latency improvement factor: L = (T_draft + T_verify) / τ
  static double latencyImprovementFactor(
    double draftTimeMs,
    double verifyTimeMs,
    double expectedBlockLen,
  ) {
    if (expectedBlockLen <= 0) return 1.0;
    return (draftTimeMs + verifyTimeMs) / expectedBlockLen;
  }

  /// Speedup ratio relative to standard autoregressive decoding.
  static double speedupRatio(
    double standardTokenTimeMs,
    double draftTimeMs,
    double verifyTimeMs,
    double expectedBlockLen,
  ) {
    final latency = latencyImprovementFactor(draftTimeMs, verifyTimeMs, expectedBlockLen);
    if (latency <= 0) return 1.0;
    return standardTokenTimeMs / latency;
  }

  /// Confidence score calibration: c'_i = σ(logit(c_i)/T)
  static double calibratedConfidence(double logit, double temperature) {
    return 1.0 / (1.0 + math.exp(-logit / temperature));
  }

  /// Optimal verification length: argmax_k [E[τ|k] × SPS(B,k)]
  static int optimalVerificationLength(
    double avgAlpha,
    double gpuLoad,
    double baselineSps,
  ) {
    int bestK = 5;
    double bestScore = 0;

    for (int k = 2; k <= 12; k++) {
      final blockLen = expectedBlockLength(avgAlpha, k);
      if (blockLen.isInfinite) return k;

      final loadFactor = 1.0 / (1.0 + gpuLoad * 0.15);
      final throughput = baselineSps * loadFactor * (blockLen / k);
      final score = blockLen * throughput;

      if (score > bestScore) {
        bestScore = score;
        bestK = k;
      }
    }
    return bestK;
  }

  /// Rejection resampling distribution: p_kalan(x) = max(0, p(x)-q(x)) / Z
  static double residualProbability(double pX, double qX, double normalization) {
    if (normalization <= 0) return 0;
    return math.max(0.0, pX - qX) / normalization;
  }
}
