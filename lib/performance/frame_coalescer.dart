import 'dart:async';

import 'package:flutter/scheduler.dart';

/// Coalesces a burst of callbacks into at most one callback per rendered frame.
///
/// High-frequency sources such as microphone level meters and streaming token
/// metadata can emit significantly faster than the display refresh rate. UI
/// listeners cannot display every intermediate value, so scheduling one update
/// per frame removes redundant rebuild work without changing the latest value.
class FrameCoalescer {
  FrameCoalescer({SchedulerBinding? scheduler})
      : _scheduler = scheduler ?? SchedulerBinding.instance;

  final SchedulerBinding _scheduler;
  bool _scheduled = false;
  bool _disposed = false;
  void Function()? _latest;

  bool get isScheduled => _scheduled;

  void schedule(void Function() callback) {
    if (_disposed) return;
    _latest = callback;
    if (_scheduled) return;
    _scheduled = true;
    _scheduler.scheduleFrameCallback((_) {
      _scheduled = false;
      if (_disposed) return;
      final callback = _latest;
      _latest = null;
      callback?.call();
    });
  }

  /// Runs pending work immediately. Mainly useful before terminal state changes
  /// such as stop/dispose where waiting for the next frame is unnecessary.
  void flush() {
    if (_disposed) return;
    final callback = _latest;
    _latest = null;
    _scheduled = false;
    callback?.call();
  }

  void cancel() {
    _latest = null;
    _scheduled = false;
  }

  void dispose() {
    _disposed = true;
    _latest = null;
    _scheduled = false;
  }
}

/// Time-based coalescer for non-visual work where a fixed maximum update rate is
/// preferable to a frame callback.
class RateCoalescer {
  RateCoalescer(this.minInterval);

  final Duration minInterval;
  Timer? _timer;
  int _lastRunMicros = 0;
  void Function()? _latest;
  bool _disposed = false;

  bool get isScheduled => _timer != null;

  void schedule(void Function() callback) {
    if (_disposed) return;
    _latest = callback;
    final now = DateTime.now().microsecondsSinceEpoch;
    final elapsed = now - _lastRunMicros;
    final wait = minInterval.inMicroseconds - elapsed;

    if (wait <= 0 && _timer == null) {
      _run();
      return;
    }

    if (_timer != null) return;
    _timer = Timer(Duration(microseconds: wait > 0 ? wait : 0), _run);
  }

  void _run() {
    _timer?.cancel();
    _timer = null;
    if (_disposed) return;
    final callback = _latest;
    _latest = null;
    if (callback == null) return;
    _lastRunMicros = DateTime.now().microsecondsSinceEpoch;
    callback();
  }

  void flush() {
    if (_disposed) return;
    _timer?.cancel();
    _timer = null;
    _run();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _latest = null;
  }

  void dispose() {
    _disposed = true;
    cancel();
  }
}

/// Forwards the newest value at most once per frame.
class FrameValueCoalescer<T> {
  FrameValueCoalescer(this.onValue, {FrameCoalescer? coalescer})
      : _coalescer = coalescer ?? FrameCoalescer();

  final void Function(T value) onValue;
  final FrameCoalescer _coalescer;
  T? _latest;
  bool _hasValue = false;

  void add(T value) {
    _latest = value;
    _hasValue = true;
    _coalescer.schedule(() {
      if (!_hasValue) return;
      final current = _latest as T;
      _hasValue = false;
      onValue(current);
    });
  }

  void flush() => _coalescer.flush();

  void dispose() {
    _hasValue = false;
    _latest = null;
    _coalescer.dispose();
  }
}
