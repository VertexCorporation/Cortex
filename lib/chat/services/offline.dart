// lib/chat/services/offline.dart
//
// OfflineService
//
// Manages communication with the native (Kotlin/Swift) layer for running
// on-device (offline) models via a platform channel.
//
// Responsibilities:
// - Build properly formatted prompts based on the model's chat format.
// - Stream tokens coming from native into the UI through ResponseService.
// - Use ChatFormatProcessor to strip control tokens (ChatML, stop tokens, etc.).
// - Detect excessive repetition in the visible output and auto-stop generation
//   to prevent infinite loops ("hellohellohello...", "aaaaaa...", etc.).
//

import 'dart:convert';
import 'dart:io';

import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/processor.dart';
import 'package:cortex/chat/services/response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import 'context.dart';

/// A service to manage communication with the native (Kotlin/Swift) layer
/// for handling on-device, offline model interactions via a platform channel.
class OfflineService {
  final ResponseService _responseService;
  final ChatSessionProvider _sessionProvider;
  final ModelService _modelService;
  final ContextService _contextService;

  /// Holds the processor for the current ongoing message stream.
  ChatFormatProcessor? _currentProcessor;

  /// Repetition guard state for the current stream.
  String _visibleHistory = '';
  String? _lastVisibleChunk;
  int _lastVisibleChunkRepeatCount = 0;
  bool _forceAbortCurrentStream = false;

  // Repetition guard tuning parameters.
  static const int _maxHistoryLength = 1024;
  static const int _minPatternLength = 3;
  static const int _maxPatternLength = 32;
  static const int _patternRepeatThreshold = 4; // e.g. "hello" * 4
  static const int _chunkRepeatThreshold = 12;  // identical chunk seen 12x

  // The platform channel must be static to ensure a single communication
  // channel is used throughout the app's lifecycle.
  static const MethodChannel _llamaChannel =
  MethodChannel('com.vertex.cortex/llama');

  /// Constructs the OfflineService with its required dependencies.
  OfflineService({
    required ResponseService responseService,
    required ChatSessionProvider sessionProvider,
    required ModelService modelService,
    required ContextService contextService,
  })  : _responseService = responseService,
        _sessionProvider = sessionProvider,
        _modelService = modelService,
        _contextService = contextService {
    // Set the handler for messages coming from the native platform to this service instance.
    _llamaChannel.setMethodCallHandler(methodCallHandler);
  }

  // ===========================================================================
  // Public API
  // ===========================================================================

  /// Sends a command to the native layer to cache a model from the specified file path into memory.
  Future<void> cacheModel(String path) async {
    if (path.isEmpty) {
      debugPrint("[OfflineService] Aborting cacheModel call: Path is empty.");
      return;
    }
    debugPrint(
      "[OfflineService] Invoking 'cacheModel' on the native side with path: $path",
    );
    try {
      await _llamaChannel.invokeMethod<void>('cacheModel', {'path': path});
    } on PlatformException catch (e) {
      debugPrint(
        "[OfflineService] Failed to invoke 'cacheModel': ${e.message}",
      );
      // Optionally, notify the UI of the failure.
      _responseService.onMessageResponse(
        "[Error: Failed to load model. Please check logs.]",
      );
      _responseService.finalizeResponse();
    }
  }

  /// Sends a command to the native layer to release the current model from memory.
  Future<void> releaseModel() async {
    debugPrint("[OfflineService] Invoking 'releaseModel' on the native side.");
    await _llamaChannel.invokeMethod('releaseModel');
    _sessionProvider.setLocalModelLoaded(false); // Ensure state is reset in Dart
  }

  /// Clears native KV cache before a new local generation.
  Future<void> _resetKvCache() async {
    try {
      await _llamaChannel.invokeMethod<void>('resetKv');
      debugPrint("[OfflineService] Requested KV reset on native side.");
    } catch (e) {debugPrint("[OfflineService] KV reset failed (non-fatal): $e");
    }
  }

  /// Sends a user's prompt to the native layer to be processed by the local model.
  Future<void> sendMessage(String text, String? photoPath) async {
    final String? modelId = _sessionProvider.modelId;
    if (modelId == null) {
      debugPrint(
        "[OfflineService] Cannot send message, no model selected in session.",
      );
      _responseService.onMessageResponse("[Error: No model selected.]");
      _responseService.finalizeResponse();
      return;
    }

    final ModelEntity model =
    _modelService.getPreciseModelData(modelId, langCode: 'en');
    // langCode for offline selection does not affect tokens; models are typically language-agnostic here.

    // Initialize a new processor for this message, passing a stop callback
    // that forwards the stop request to the native layer.
    _currentProcessor = ChatFormatProcessor(
      model.chatFormat,
      onStopTokenDetected: () {
        stopGeneration();
      },
    );
    _resetRepetitionGuardState();
    debugPrint(
      "[OfflineService] Initialized ChatFormatProcessor for model '$modelId'.",
    );

    // Build the fully formatted prompt string.
    final String finalPrompt =
    await _buildFormattedPrompt(model: model, latestMessage: text);
    if (finalPrompt.isEmpty) {
      debugPrint(
        "[OfflineService] Formatted prompt is empty. Aborting send.",
      );
      _responseService.finalizeResponse(); // End the chat turn with an empty response.
      return;
    }

    await _resetKvCache();

    debugPrint("[OfflineService] Invoking 'sendMessage' on the native side.");
    await _llamaChannel.invokeMethod<void>(
      'sendMessage',
      {
        'message': finalPrompt,
        'photoBase64': photoPath != null
            ? await _encodePhotoToBase64(photoPath)
            : null,
      },
    );
  }

  /// Sends a command to the native layer to stop any ongoing text generation.
  Future<void> stopGeneration() async {
    debugPrint("[OfflineService] Invoking 'stopGeneration' on the native side.");
    await _llamaChannel.invokeMethod('stopGeneration');
  }

  // ===========================================================================
  // Native Method Call Handler
  // ===========================================================================

  /// The central handler for all method calls received from the native platform.
  @pragma('vm:entry-point')
  Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
    // Called for each token of the streaming response.
      case 'onMessageResponse':
        final String rawToken = call.arguments as String? ?? '';

        // If we have already decided to abort this stream due to repetition,
        // ignore all subsequent chunks from native.
        if (_forceAbortCurrentStream) {
          debugPrint(
            "[OfflineService] Ignoring token because stream is force-aborted.",
          );
          return;
        }

        final processor = _currentProcessor;

        if (processor == null) {
          // Defensive fallback: no processor → forward raw token, with repetition guard.
          if (rawToken.isEmpty) return;
          if (_shouldAbortForRepetition(rawToken)) {
            _handleRepetitionAbort();
          } else {
            _responseService.onMessageResponse(rawToken);
          }
          return;
        }

        // Process the raw token through our format processor.
        final String? processedToken = processor.processToken(rawToken);

        // Only forward the token to the UI if it's not null (i.e., not a stop token or ignored token).
        if (processedToken != null && processedToken.isNotEmpty) {
          if (_shouldAbortForRepetition(processedToken)) {
            _handleRepetitionAbort();
          } else {
            _responseService.onMessageResponse(processedToken);
          }
        }
        break;

    // Called when the native model finishes generating a full response.
      case 'onMessageComplete':
        debugPrint("[OfflineService] Received 'onMessageComplete'. Finalizing response.");

        // 1) Flush any leftover visible chars from the processor (if any).
        final tail = _currentProcessor?.finalize();
        if (tail != null && tail.isNotEmpty) {
          _responseService.onMessageResponse(tail);
        }

        // 2) Close the message as before.
        _responseService.finalizeResponse();

        // 3) Cleanup.
        _currentProcessor = null;
        break;

    // Called when the native layer has successfully loaded the model into memory.
      case 'onModelLoaded':
        debugPrint(
          "[OfflineService] Received 'onModelLoaded'. Updating provider state.",
        );
        _sessionProvider.setLocalModelLoaded(true);
        break;

      case 'onModelLoadFailed':
        final String error = call.arguments as String? ?? 'Unknown error';
        debugPrint(
          "[OfflineService] CRITICAL: Received 'onModelLoadFailed' with error: $error",
        );
        _sessionProvider.setLocalModelLoaded(false);
        break;

      default:
        debugPrint(
          "[OfflineService] Received unknown method call from native: ${call.method}",
        );
        break;
    }
  }

  // ===========================================================================
  // Prompt Building
  // ===========================================================================

  /// Builds the full prompt string for the model, including context, based on its chat format.
  Future<String> _buildFormattedPrompt({
    required ModelEntity model,
    required String latestMessage,
  }) async {
    final format = model.chatFormat;
    final tokens = format?.tokens;

    if (format == null || tokens == null) {
      debugPrint("[OfflineService] No chat format found for model '${model.id}'. Sending raw message.");
      return latestMessage;
    }

    final sb = StringBuffer();

    final systemPrompt = (model.role ?? "").trim();
    if (systemPrompt.isNotEmpty && (tokens.systemStart?.isNotEmpty ?? false)) {
      _appendTurn(sb, start: tokens.systemStart!, end: tokens.systemEnd, content: systemPrompt);
    }

    final history = await _contextService.buildContextMessages(
      includeLastUser: false,
      targetModelId: model.id,
      langCode: 'en',
    );

    for (final msg in history) {
      final role = (msg['role'] as String?) ?? '';
      final contentText = _extractVisibleText(msg['content']);

      if (contentText.isEmpty) continue;

      if (role == 'user' && (tokens.userStart?.isNotEmpty ?? false)) {
        _appendTurn(sb, start: tokens.userStart!, end: tokens.userEnd, content: contentText);
      } else if (role == 'assistant' && (tokens.assistantStart?.isNotEmpty ?? false)) {
        _appendTurn(sb, start: tokens.assistantStart!, end: tokens.assistantEnd, content: contentText);
      } else {
        sb..write(contentText)..write('\n');
      }
    }

    final latest = latestMessage.trim();
    if (latest.isNotEmpty && (tokens.userStart?.isNotEmpty ?? false)) {
      _appendTurn(sb, start: tokens.userStart!, end: tokens.userEnd, content: latest);
    } else {
      sb..write(latest)..write('\n');
    }

    if (tokens.assistantStart?.isNotEmpty ?? false) {
      sb..write(tokens.assistantStart!)..write('\n');
    }

    final finalPrompt = sb.toString();
    debugPrint("[OfflineService] Built Formatted Prompt (normalized):\n-----\n$finalPrompt\n-----");
    return finalPrompt;
  }

  // Content normalizer
  String _extractVisibleText(dynamic content) {
    if (content == null) return '';
    if (content is String) return content.trim();

    if (content is List) {
      final buffer = StringBuffer();
      for (final part in content) {
        if (part is Map) {
          final type = part['type'];
          if (type == 'text') {
            final data = part['text'] ?? part['content'] ?? '';
            if (data is String && data.trim().isNotEmpty) {
              buffer.writeln(data.trim());
            }
          }
        }
      }
      return buffer.toString().trim();
    }

    return '';
  }

  /// Helper: Appends one ChatML turn with proper newlines.
  void _appendTurn(
      StringBuffer sb, {
        required String start,
        String? end,
        required String content,
      }) {
    // start + \n + content + \n + end? + \n
    sb..write(start)..write('\n');
    sb..write(content)..write('\n');
    if ((end ?? '').isNotEmpty) sb.write(end);
    sb.write('\n');
  }

  // ===========================================================================
  // Repetition Guard
  // ===========================================================================

  /// Resets all repetition guard state for a new message stream.
  void _resetRepetitionGuardState() {
    _visibleHistory = '';
    _lastVisibleChunk = null;
    _lastVisibleChunkRepeatCount = 0;
    _forceAbortCurrentStream = false;
  }

  /// Returns true if the given visible chunk indicates that we should abort
  /// the current generation due to excessive repetition.
  bool _shouldAbortForRepetition(String visibleChunk) {
    if (visibleChunk.isEmpty) return false;

    // Quick guard: same visible chunk repeated too many times.
    if (_lastVisibleChunk == visibleChunk) {
      _lastVisibleChunkRepeatCount++;
    } else {
      _lastVisibleChunk = visibleChunk;
      _lastVisibleChunkRepeatCount = 1;
    }

    if (_lastVisibleChunkRepeatCount >= _chunkRepeatThreshold) {
      debugPrint(
        "[OfflineService][RepetitionGuard] Same visible chunk repeated "
            "$_lastVisibleChunkRepeatCount times. Will abort.",
      );
      return true;
    }

    // Append to the rolling history and trim if needed.
    _visibleHistory += visibleChunk;
    if (_visibleHistory.length > _maxHistoryLength) {
      _visibleHistory = _visibleHistory.substring(
        _visibleHistory.length - _maxHistoryLength,
      );
    }

    if (_hasExcessiveTailRepetition(_visibleHistory)) {
      debugPrint(
        "[OfflineService][RepetitionGuard] Detected excessive tail pattern repetition. Will abort.",
      );
      return true;
    }

    return false;
  }

  /// Detects whether the end of [text] contains a pattern of length between
  /// [_minPatternLength] and [_maxPatternLength] that is repeated at least
  /// [_patternRepeatThreshold] times consecutively.
  bool _hasExcessiveTailRepetition(String text) {
    if (text.length < _minPatternLength * _patternRepeatThreshold) {
      return false;
    }

    final segment = text;
    final tailLen = segment.length;
    final maxPatternLenFromLength = tailLen ~/ _patternRepeatThreshold;
    final upperPatternLen = maxPatternLenFromLength < _maxPatternLength
        ? maxPatternLenFromLength
        : _maxPatternLength;

    for (int patternLen = _minPatternLength;
    patternLen <= upperPatternLen;
    patternLen++) {
      final patternStart = tailLen - patternLen;
      if (patternStart < 0) break;

      final pattern = segment.substring(patternStart);

      int count = 1; // we already have one at the end
      int index = patternStart - patternLen;

      while (index >= 0) {
        final candidate =
        segment.substring(index, index + patternLen);
        if (candidate == pattern) {
          count++;
          index -= patternLen;
        } else {
          break;
        }
      }

      if (count >= _patternRepeatThreshold) {
        return true;
      }
    }

    return false;
  }

  /// Centralized handling when repetition guard decides to abort the stream.
  void _handleRepetitionAbort() {
    if (_forceAbortCurrentStream) return;
    _forceAbortCurrentStream = true;
    debugPrint(
      "[OfflineService][RepetitionGuard] Auto-stopping generation due to excessive repetition.",
    );
    // Request the native side to stop generation. We still rely on
    // 'onMessageComplete' from native to finalize the response.
    stopGeneration();
  }

  Future<String?> _encodePhotoToBase64(String? path) async {
    if (path == null) return null;
    try {
      final bytes = await File(path).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint("[OfflineService] Failed to encode photo: $e");
      return null;
    }
  }
}