import 'dart:collection';

import 'package:flutter/foundation.dart';

/// One completed runtime timing sample.
class PerfSample {
  const PerfSample({
    required this.name,
    required this.elapsedMicros,
    required this.startedAtMicros,
    this.metadata = const <String, Object?>{},
  });

  final String name;
  final int elapsedMicros;
  final int startedAtMicros;
  final Map<String, Object?> metadata;

  double get elapsedMs => elapsedMicros / 1000.0;
}

class PerfSummary {
  const PerfSummary({
    required this.name,
    required this.count,
    required this.totalMicros,
    required this.minMicros,
    required this.maxMicros,
    required this.averageMicros,
  });

  final String name;
  final int count;
  final int totalMicros;
  final int minMicros;
  final int maxMicros;
  final double averageMicros;

  double get averageMs => averageMicros / 1000.0;
  double get minMs => minMicros / 1000.0;
  double get maxMs => maxMicros / 1000.0;
}

class _Accumulator {
  _Accumulator(this.name);

  final String name;
  int count = 0;
  int total = 0;
  int min = 1 << 62;
  int max = 0;

  void add(int micros) {
    count++;
    total += micros;
    if (micros < min) min = micros;
    if (micros > max) max = micros;
  }

  PerfSummary snapshot() => PerfSummary(
        name: name,
        count: count,
        totalMicros: total,
        minMicros: count == 0 ? 0 : min,
        maxMicros: max,
        averageMicros: count == 0 ? 0 : total / count,
      );
}

/// Lightweight runtime tracing that is cheap enough to leave compiled in.
///
/// Detailed sample retention/logging is disabled by default in release builds.
/// Aggregate counters remain available to tests and debug diagnostics without
/// adding network telemetry or changing user privacy behavior.
class PerfTrace {
  PerfTrace._();

  static const int _maxSamples = 256;
  static final Queue<PerfSample> _samples = Queue<PerfSample>();
  static final Map<String, _Accumulator> _accumulators =
      <String, _Accumulator>{};

  static bool enabled = kDebugMode;
  static bool logSlowOperations = kDebugMode;
  static Duration slowThreshold = const Duration(milliseconds: 16);

  static PerfSpan start(
    String name, {
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return PerfSpan._(
      name: name,
      metadata: metadata,
      startedAtMicros: DateTime.now().microsecondsSinceEpoch,
      stopwatch: Stopwatch()..start(),
    );
  }

  static Future<T> measureAsync<T>(
    String name,
    Future<T> Function() action, {
    Map<String, Object?> metadata = const <String, Object?>{},
  }) async {
    final span = start(name, metadata: metadata);
    try {
      return await action();
    } finally {
      span.end();
    }
  }

  static T measureSync<T>(
    String name,
    T Function() action, {
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    final span = start(name, metadata: metadata);
    try {
      return action();
    } finally {
      span.end();
    }
  }

  static void _record(PerfSample sample) {
    final acc = _accumulators.putIfAbsent(
      sample.name,
      () => _Accumulator(sample.name),
    );
    acc.add(sample.elapsedMicros);

    if (enabled) {
      _samples.addLast(sample);
      while (_samples.length > _maxSamples) {
        _samples.removeFirst();
      }
    }

    if (logSlowOperations &&
        sample.elapsedMicros >= slowThreshold.inMicroseconds) {
      debugPrint(
        '[Perf] ${sample.name}: ${sample.elapsedMs.toStringAsFixed(2)} ms '
        '${sample.metadata.isEmpty ? '' : sample.metadata}',
      );
    }
  }

  static List<PerfSample> recentSamples() =>
      List<PerfSample>.unmodifiable(_samples);

  static List<PerfSummary> summaries() {
    final values = _accumulators.values
        .map((accumulator) => accumulator.snapshot())
        .toList(growable: false);
    values.sort((a, b) => b.totalMicros.compareTo(a.totalMicros));
    return values;
  }

  static PerfSummary? summary(String name) =>
      _accumulators[name]?.snapshot();

  static void clear() {
    _samples.clear();
    _accumulators.clear();
  }
}

class PerfSpan {
  PerfSpan._({
    required this.name,
    required this.metadata,
    required this.startedAtMicros,
    required Stopwatch stopwatch,
  }) : _stopwatch = stopwatch;

  final String name;
  final Map<String, Object?> metadata;
  final int startedAtMicros;
  final Stopwatch _stopwatch;
  bool _ended = false;

  bool get isEnded => _ended;
  Duration get elapsed => _stopwatch.elapsed;

  PerfSample end({Map<String, Object?> extra = const <String, Object?>{}}) {
    if (_ended) {
      return PerfSample(
        name: name,
        elapsedMicros: _stopwatch.elapsedMicroseconds,
        startedAtMicros: startedAtMicros,
        metadata: <String, Object?>{...metadata, ...extra},
      );
    }
    _ended = true;
    _stopwatch.stop();
    final sample = PerfSample(
      name: name,
      elapsedMicros: _stopwatch.elapsedMicroseconds,
      startedAtMicros: startedAtMicros,
      metadata: <String, Object?>{...metadata, ...extra},
    );
    PerfTrace._record(sample);
    return sample;
  }
}
