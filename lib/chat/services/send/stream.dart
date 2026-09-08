// lib/chat/services/send/stream.dart

import 'dart:async';

/// Buffers and throttles streaming text chunks to ensure smooth UI updates
/// without overwhelming the Flutter layout engine on high-speed token bursts.
class StreamBuffer {
  final StringBuffer _fullContent = StringBuffer();
  final StringBuffer _pendingBatch = StringBuffer();
  final void Function(String fullText) onTextFlush;
  final Duration flushInterval;

  Timer? _flushTimer;
  bool _hasPendingUpdates = false;

  StreamBuffer({
    required this.onTextFlush,
    this.flushInterval = const Duration(milliseconds: 40),
  });

  String get currentText => _fullContent.toString();

  void append(String chunk) {
    _fullContent.write(chunk);
    _pendingBatch.write(chunk);
    _hasPendingUpdates = true;

    if (_flushTimer == null || !_flushTimer!.isActive) {
      _flushTimer = Timer(flushInterval, _flush);
    }
  }

  void _flush() {
    if (_hasPendingUpdates) {
      onTextFlush(_fullContent.toString());
      _pendingBatch.clear();
      _hasPendingUpdates = false;
    }
  }

  /// Immediately flushes all remaining text and cancels pending timers.
  String finalize() {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_hasPendingUpdates) {
      onTextFlush(_fullContent.toString());
      _pendingBatch.clear();
      _hasPendingUpdates = false;
    }
    return _fullContent.toString();
  }

  void dispose() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _pendingBatch.clear();
  }
}
