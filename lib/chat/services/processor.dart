// lib/chat/services/processor.dart
//
// ChatFormatProcessor
//
// This class is responsible for turning raw token streams coming from
// offline models into clean, displayable text.
//
// It understands the model's chat format (e.g. ChatML) and:
// - Detects control tokens such as system/user/assistant start & end markers.
// - Detects stop-generation tokens like "<|im_end|>", "<|endoftext|>", "</s>".
// - Ensures that these control tokens are NEVER rendered to the user,
//   even if they arrive split across multiple tokens.
// - Calls an optional callback when a stop token is detected so the caller
//   can immediately stop reading from the stream.
//
// The core idea is a tiny state machine that operates at *character level*,
// so control sequences are handled correctly even when the model outputs them
// in chunks like "<", "|im_", "end|>".
//

import 'package:flutter/foundation.dart';
import '../../library/backend/data/format.dart';

/// Callback to signal that a stop token has been detected.
typedef OnStopTokenDetected = void Function();

/// Processes incoming token streams from offline models based on their chat format.
class ChatFormatProcessor {
  final ChatFormat? _format;
  final OnStopTokenDetected? onStopTokenDetected;

  // Once true, all subsequent tokens are ignored.
  bool _generationStopped = false;

  // Buffer for a potential control sequence (e.g. "<|im_end|>").
  // We keep characters here until we can decide whether they are:
  // - part of a known control token → consume & handle
  // - or just normal text → flush to output.
  String _pendingControl = '';

  // All known control patterns derived from the chat format.
  // Includes system/user/assistant markers and stop tokens.
  List<String> _controlPatterns = const [];

  // Subset of _controlPatterns: tokens that should stop generation.
  Set<String> _stopPatterns = const {};

  bool _patternsInitialized = false;

  ChatFormatProcessor(this._format, {this.onStopTokenDetected});

  bool _discardNextWhitespace = false;

  /// Processes a single incoming token and returns the clean, displayable part,
  /// or null if nothing should be shown to the user for this token.
  ///
  /// NOTE:
  /// - This method may keep some characters in an internal buffer if they look
  ///   like the beginning of a control sequence (e.g. "<", "<|", "<|im_").
  /// - To guarantee that no non-control characters are lost at the *end* of a
  ///   stream, you should call [finalize] once streaming is finished.
  String? processToken(String token) {
    if (_generationStopped) return null;

    // If no special chat format is defined, pass tokens through as-is.
    if (_format?.tokens == null) {
      return token;
    }

    final tokens = _format!.tokens!;
    _ensurePatternsInitialized(tokens);

    // --- ignore_regex short-circuit (same semantics as before) ---
    final ignoreRegex = tokens.ignoreRegex;
    if (ignoreRegex != null && ignoreRegex.isNotEmpty) {
      try {
        final regex = RegExp(ignoreRegex);
        if (regex.hasMatch(token)) {
          debugPrint(
            "[ChatFormatProcessor] Ignoring token via ignore_regex: '$token'",
          );
          return null;
        }
      } catch (e) {
        debugPrint(
          "[ChatFormatProcessor] Invalid ignore_regex pattern: $ignoreRegex",
        );
      }
    }

    // This buffer will only contain text that is actually safe to render.
    final visibleBuffer = StringBuffer();

    // Process character by character so we can correctly recognise control
    // sequences even when they are split across multiple tokens.
    for (final rune in token.runes) {
      if (_generationStopped) break;
      final ch = String.fromCharCode(rune);
      _processChar(ch, tokens, visibleBuffer);
    }

    if (_generationStopped) {
      debugPrint(
        "[ChatFormat-STOP] Generation has been stopped by a control token.",
      );
    }

    if (visibleBuffer.isEmpty) {
      return null;
    }

    // The processor's job is to strip protocol/control tokens and stop
    // on stopGeneration markers. If a model chooses to output plain text
    // around those tokens, that text is considered visible.
    return visibleBuffer.toString();
  }

  /// Call this exactly once *after* the stream has fully finished.
  ///
  /// This flushes any remaining characters that were tentatively held in the
  /// internal control buffer but never formed a complete control pattern.
  ///
  /// Example:
  /// - Model outputs only "<" and then the stream ends.
  /// - During streaming, "<" looked like the start of "<|im_end|>", so it was
  ///   kept in _pendingControl and never shown.
  /// - [finalize] will now flush "<" as normal visible text so nothing is lost.
  ///
  /// If generation has already been stopped by a stop token, this method will
  /// NOT emit any further text.
  String? finalize() {
    if (_generationStopped) {
      // We were explicitly stopped by a control token; anything left in
      // _pendingControl is considered protocol noise and discarded.
      _pendingControl = '';
      return null;
    }

    if (_pendingControl.isEmpty) {
      return null;
    }

    // At this point _pendingControl cannot be an exact known control token:
    // - Exact matches are handled inside _processChar and clear the buffer.
    // - Therefore, whatever is left here is just partial text that *looked*
    //   like a control prefix but never completed. We now treat it as normal
    //   visible output so nothing is silently lost.
    final flushed = _pendingControl;
    _pendingControl = '';
    return flushed;
  }

  // ===========================================================================
  // Internal helpers
  // ===========================================================================

  /// Lazily builds the list of known control patterns from the chat format.
  void _ensurePatternsInitialized(dynamic tokens) {
    if (_patternsInitialized) return;

    final patterns = <String>[];

    void addPattern(String? value) {
      if (value != null && value.isNotEmpty) {
        patterns.add(value);
      }
    }

    // System / user / assistant markers (if defined by the format).
    addPattern(tokens.systemStart as String?);
    addPattern(tokens.systemEnd as String?);
    addPattern(tokens.userStart as String?);
    addPattern(tokens.userEnd as String?);
    addPattern(tokens.assistantStart as String?);
    addPattern(tokens.assistantEnd as String?);

    // Stop-generation tokens.
    if (tokens.stopGeneration != null) {
      final list = tokens.stopGeneration as List<dynamic>;
      for (final dynamic stop in list) {
        if (stop is String && stop.isNotEmpty) {
          patterns.add(stop);
        }
      }
      _stopPatterns = list.whereType<String>().toSet();
    } else {
      _stopPatterns = const {};
    }

    _controlPatterns = patterns.toList(growable: false);
    _patternsInitialized = true;

    debugPrint(
      "[ChatFormatProcessor] Initialized control patterns: $_controlPatterns",
    );
  }

  /// Core state machine that consumes a single character from the stream.
  ///
  /// It decides whether this character:
  /// - is part of a control sequence (keep it in _pendingControl),
  /// - completes a control sequence (handle it & never show),
  /// - or should be flushed as normal visible text.
  void _processChar(String ch, dynamic tokens, StringBuffer output) {

    if (_generationStopped) return;

    if (_discardNextWhitespace) {
      if (ch.trim().isEmpty) {
        return;
      }
      _discardNextWhitespace = false;
    }

    final candidate = '$_pendingControl$ch';

    // 1) Exact match: we have a complete control token.
    if (_isExactControl(candidate)) {
      _pendingControl = '';
      _handleFullControlPattern(candidate, tokens);
      return;
    }

    // 2) Prefix match: could become a full control token if more characters arrive.
    if (_isPrefixOfControl(candidate)) {
      _pendingControl = candidate;
      return;
    }

    // 3) Not a prefix and not exact:
    //    - If we were tracking a potential control sequence, that guess
    //      was wrong. We must flush characters from _pendingControl to the
    //      visible output and re-process the current char.
    if (_pendingControl.isNotEmpty) {
      final first = _pendingControl[0];

      if (first.trim().isNotEmpty) {
        output.write(first);
      }

      _pendingControl = _pendingControl.substring(1);
      _processChar(ch, tokens, output);
      return;
    }

    // 4) No pending control and the current character is not a prefix of
    //    any control pattern → normal visible character.
    output.write(ch);
  }

  bool _isExactControl(String value) {
    if (_controlPatterns.isEmpty) return false;
    return _controlPatterns.contains(value);
  }

  bool _isPrefixOfControl(String value) {
    if (_controlPatterns.isEmpty) return false;
    for (final pattern in _controlPatterns) {
      if (pattern.startsWith(value)) return true;
    }
    return false;
  }

  /// Handles a fully recognised control pattern:
  /// - stop tokens → stop generation & invoke callback
  /// - assistant/system/user markers → update internal state
  /// - all of them are *never* rendered to the user.
  void _handleFullControlPattern(String pattern, dynamic tokens) {
    _discardNextWhitespace = true;

    // 1) Stop token: end of generation.
    if (_stopPatterns.contains(pattern)) {
      debugPrint(
        "[ChatFormat-STOP] Detected stop token: '$pattern'. Stopping generation.",
      );
      _generationStopped = true;
      onStopTokenDetected?.call();
      return;
    }

    // 2) Assistant markers.
    if (pattern == tokens.assistantStart) {
      debugPrint(
        "[ChatFormatProcessor] Detected assistant_start token.",
      );
      return;
    }

    if (pattern == tokens.assistantEnd) {
      debugPrint(
        "[ChatFormatProcessor] Detected assistant_end token.",
      );
      return;
    }

    // 3) System / user markers: treated as pure protocol noise and ignored.
    if (pattern == tokens.systemStart ||
        pattern == tokens.systemEnd ||
        pattern == tokens.userStart ||
        pattern == tokens.userEnd) {
      debugPrint(
        "[ChatFormatProcessor] Ignoring system/user control pattern: '$pattern'.",
      );
      return;
    }

    // 4) Any other control-like pattern that was configured but not explicitly
    //    handled above is silently ignored as well.
    debugPrint(
      "[ChatFormatProcessor] Ignoring unknown control pattern: '$pattern'.",
    );
  }
}