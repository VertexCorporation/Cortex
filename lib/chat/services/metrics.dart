import 'dart:async';

class ResponseMetrics {
  final DateTime startTime;
  DateTime? firstTokenTime;
  DateTime? endTime;
  int promptTokensEstimated = 0;
  int completionTokensEstimated = 0;
  int compressedPromptTokensEstimated = 0;
  String modelId;

  ResponseMetrics({
    required this.startTime,
    required this.modelId,
  });

  Duration? get timeToFirstToken {
    if (firstTokenTime == null) return null;
    return firstTokenTime!.difference(startTime);
  }

  Duration? get totalDuration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  double get costSavingEstimated {
    final savings = promptTokensEstimated - compressedPromptTokensEstimated;
    if (savings <= 0) return 0.0;
    // Assuming $0.0015 per 1K tokens average
    return (savings / 1000.0) * 0.0015;
  }
}

class MetricsTracker {
  static final MetricsTracker _instance = MetricsTracker._internal();
  factory MetricsTracker() => _instance;
  MetricsTracker._internal();

  ResponseMetrics? _currentMetrics;
  final List<ResponseMetrics> _history = [];

  List<ResponseMetrics> get history => _history;
  ResponseMetrics? get currentMetrics => _currentMetrics;

  void startTracking(String modelId, {required int originalPromptLength, required int compressedPromptLength}) {
    // Estimating: 1 token ≈ 4 characters in average English/Turkish content
    final originalTokens = (originalPromptLength / 4.0).round();
    final compressedTokens = (compressedPromptLength / 4.0).round();

    _currentMetrics = ResponseMetrics(
      startTime: DateTime.now(),
      modelId: modelId,
    )
      ..promptTokensEstimated = originalTokens
      ..compressedPromptTokensEstimated = compressedTokens;
  }

  void onTokenReceived() {
    final current = _currentMetrics;
    if (current != null) {
      current.firstTokenTime ??= DateTime.now();
      current.completionTokensEstimated++;
    }
  }

  void stopTracking() {
    final current = _currentMetrics;
    if (current != null) {
      current.endTime = DateTime.now();
      _history.add(current);
      // Keep history limited to last 50 requests to avoid memory growth
      if (_history.length > 50) {
        _history.removeAt(0);
      }
      _currentMetrics = null;
    }
  }

  // Helper to get overall cost savings in USD
  double get totalSavingsUsd {
    double total = 0.0;
    for (var m in _history) {
      total += m.costSavingEstimated;
    }
    return total;
  }
}
