import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show CharacterRange;

/// The reference's requestAnimationFrame scheduler, separate from glyph fades.
/// Positions are UTF-16 offsets, advanced only at grapheme boundaries.
class RevealTimeline extends ChangeNotifier {
  static const fadeMilliseconds = 280.0;
  final ValueNotifier<double> clock = ValueNotifier(0);
  String sourceText = '';
  int revealedLength = 0;
  bool networkComplete = false;
  double _lastRevealAt = -fadeMilliseconds;
  double _catchUpRate = 0;
  bool verticalReveal = false;
  int generation = 0;
  late CharacterRange _cursor = CharacterRange('');

  int get pendingLength => sourceText.length - revealedLength;
  String get visibleText => sourceText.substring(0, revealedLength);
  bool get isSettled => clock.value - _lastRevealAt >= fadeMilliseconds;
  bool get visualComplete => networkComplete && pendingLength == 0 && isSettled;
  bool get needsFrames => pendingLength > 0 || !isSettled;

  void reset(String text,
      {required bool complete, bool showImmediately = false}) {
    generation++;
    verticalReveal = false;
    _catchUpRate = 0;
    sourceText = text;
    networkComplete = complete;
    revealedLength = showImmediately ? text.length : 0;
    _lastRevealAt = -fadeMilliseconds;
    clock.value = 0;
    _resetCursor();
    notifyListeners();
  }

  void accept(String text, {required bool complete}) {
    if (text == sourceText && complete == networkComplete) return;
    _catchUpRate = 0;
    // Final trimRight/memory cleanup must never flush the unseen suffix.
    if (!text.startsWith(sourceText)) {
      int shared = 0;
      while (shared < text.length &&
          shared < revealedLength &&
          text.codeUnitAt(shared) == sourceText.codeUnitAt(shared)) {
        shared++;
      }
      revealedLength = shared;
    }
    sourceText = text;
    networkComplete = complete;
    _resetCursor();
    notifyListeners();
  }

  void _resetCursor() {
    // Include the final cluster again: a network fragment can extend an emoji
    // or combining sequence that was already received.
    final range = CharacterRange(sourceText);
    var safeEnd = 0;
    while (range.moveNext()) {
      final end = range.stringBeforeLength + range.current.length;
      if (end > revealedLength) break;
      safeEnd = end;
    }
    revealedLength = safeEnd;
    _cursor = CharacterRange.at(sourceText, revealedLength);
  }

  /// Same ceil/minimum-one policy and pressure thresholds as revealStep(delta).
  /// Delta is capped at 100ms so returning from the background cannot dump text.
  void advance(Duration delta) {
    final ms = (delta.inMicroseconds / 1000).clamp(0.0, 100.0);
    if (ms <= 0) return;
    final wasComplete = visualComplete;
    final wasSettled = isSettled;
    clock.value += ms;
    var changed = false;
    if (pendingLength > 0) {
      if (pendingLength >= 180) verticalReveal = true;
      if (networkComplete && _catchUpRate == 0 && pendingLength > 100) {
        _catchUpRate = pendingLength / 0.65;
      }
      final pressure = pendingLength;
      final double targetRate = _catchUpRate > 0
          ? _catchUpRate
          : pressure > 91
              ? pressure / .32
              : pressure > 48
                  ? 120.0
                  : pressure > 15
                      ? 55.0
                      : 35.0;
      final count = math.max(1, (targetRate * ms / 1000).ceil());
      for (var i = 0; i < count && _cursor.moveNext(); i++) {
        revealedLength = _cursor.stringBeforeLength + _cursor.current.length;
      }
      _lastRevealAt = clock.value;
      changed = true;
      if (pendingLength == 0) {
        _catchUpRate = 0;
      }
    }
    if (changed || wasComplete != visualComplete || wasSettled != isSettled) {
      if (isSettled) verticalReveal = false;
      notifyListeners();
    }
  }

  void flush() {
    verticalReveal = false;
    _catchUpRate = 0;
    revealedLength = sourceText.length;
    _lastRevealAt = clock.value - fadeMilliseconds;
    _resetCursor();
    notifyListeners();
    // Also repaint active glyphs without waiting for another frame.
    clock.value += 0.001;
  }

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }
}
