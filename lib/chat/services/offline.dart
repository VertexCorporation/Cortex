// lib/chat/services/offline.dart
//
// OfflineService - Optimized
//
// Manages communication with the native (Kotlin/Swift) layer for running
// on-device (offline) models via a platform channel.
//
// Optimizations:
// - Dynamic Context Size (4096 tokens).
// - GPU Offloading (Max layers).
// - Tuned Sampler Settings (Temp 0.7 default).
//

import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/processor.dart';
import 'package:cortex/chat/services/response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';
import '../../library/backend/data/format.dart';
import '../../library/backend/data/defaults.dart';
import 'context.dart';

class SamplerPreset {
  final double temperature;
  final double topP;
  final int topK;

  SamplerPreset(this.temperature, this.topP, this.topK);
}

SamplerPreset computeSampler(ModelEntity model) {
  // Enhanced Logic: Avoid extremely low temperatures which cause repetition loops.
  // Llama-3 and Gemma prefer slightly higher temps (0.6 - 0.8).
  final size = model.size ?? 0; // MB

  if (size <= 1000) {
    // Tiny models (TinyLlama) need guidance but not 0.1
    return SamplerPreset(0.5, 0.9, 20);
  } else if (size <= 4000) {
    // 3B - 4B models (Phi-3, Gemma 2B)
    return SamplerPreset(0.6, 0.9, 40);
  } else {
    // 7B+ models
    return SamplerPreset(0.7, 0.95, 40);
  }
}

class OfflineService {
  final ResponseService _responseService;
  final ChatSessionProvider _sessionProvider;
  final ModelService _modelService;
  final ContextService _contextService;

  ChatFormatProcessor? _currentProcessor;

  // Repetition guard state per stream
  String _visibleHistory = '';
  String? _lastVisibleChunk;
  int _lastVisibleChunkRepeatCount = 0;
  bool _forceAbortCurrentStream = false;

  // Repetition guard constants
  static const int _maxHistoryLength = 1024;
  static const int _chunkRepeatThreshold = 6; // More aggressive stop
  static const int _patternRepeatThreshold = 4;

  static const MethodChannel _llamaChannel =
      MethodChannel('com.vertex.cortex/llama');

  OfflineService({
    required ResponseService responseService,
    required ChatSessionProvider sessionProvider,
    required ModelService modelService,
    required ContextService contextService,
  })  : _responseService = responseService,
        _sessionProvider = sessionProvider,
        _modelService = modelService,
        _contextService = contextService {
    _llamaChannel.setMethodCallHandler(methodCallHandler);
  }

  // ===========================================================================
  // Public API
  // ===========================================================================

  /// Queries AVAILABLE (free) RAM and returns an optimal context size.
  /// Uses 80% of free RAM to leave headroom for the OS and other apps.
  Future<int> _computeOptimalContextSize() async {
    try {
      const memoryChannel = MethodChannel('com.vertex.cortex/memory');

      // Get total and used RAM
      final int totalRAM =
          await memoryChannel.invokeMethod<int>('getDeviceMemory') ?? 4096;
      final int usedRAM =
          await memoryChannel.invokeMethod<int>('getUsedMemory') ?? 2048;

      // Calculate free RAM
      final int freeRAM = totalRAM - usedRAM;

      // Use 80% of free RAM for context (leave 20% as safety buffer)
      final double usableRAM = freeRAM * 0.80;

      // Heuristic: ~0.5 MB per 1024 context tokens for typical 7B models (KV cache)
      // So: usableRAM (MB) * 2 ≈ max context tokens
      // Example: 4000 MB free * 0.8 = 3200 MB usable -> 6400 tokens
      final int rawContext = (usableRAM * 2).toInt();

      // Round down to nearest 256 (optimal for GPU memory alignment)
      final int alignedContext = (rawContext ~/ 256) * 256;

      // Clamp between safe min/max
      final int nCtx = alignedContext.clamp(512, 8192);

      debugPrint(
          "[OfflineService] RAM Status: total=$totalRAM MB, used=$usedRAM MB, free=$freeRAM MB");
      debugPrint(
          "[OfflineService] Computed Context: $nCtx tokens (80% of free: ${usableRAM.toInt()} MB)");

      return nCtx;
    } catch (e) {
      debugPrint(
          "[OfflineService] Failed to query RAM, using safe default: $e");
      return 2048; // Safe fallback
    }
  }

  /// Computes optimal thread count based on total device RAM as a proxy for CPU power.
  int _computeOptimalThreads(int totalRAM) {
    if (totalRAM <= 4096) return 2;
    if (totalRAM <= 8192) return 4;
    return 6; // High-end devices
  }

  Future<void> cacheModel(String path) async {
    if (path.isEmpty) {
      debugPrint("[OfflineService] Aborting cacheModel call: Path is empty.");
      return;
    }

    // DYNAMIC CONTEXT SIZE based on device RAM
    final int nCtx = await _computeOptimalContextSize();

    // GPU Layers: 99 = offload as many layers as possible (if GPU supported)
    const int nGpu = 99;

    // DYNAMIC THREADS based on RAM (proxy for CPU power)
    const memoryChannel = MethodChannel('com.vertex.cortex/memory');
    final int ramMB =
        await memoryChannel.invokeMethod<int>('getDeviceMemory') ?? 4096;
    final int nThreads = _computeOptimalThreads(ramMB);

    debugPrint(
        "[OfflineService] 🚀 Caching Model => ctx=$nCtx, gpu=$nGpu, threads=$nThreads (RAM: $ramMB MB)");

    try {
      await _llamaChannel.invokeMethod<void>('cacheModel', {
        'path': path,
        'nCtx': nCtx,
        'nGpu': nGpu,
        'nThreads': nThreads,
      });
    } on PlatformException catch (e) {
      debugPrint(
          "[OfflineService] Failed to invoke 'cacheModel': ${e.message}");
      _responseService
          .onMessageResponse("[Error: Failed to load model. ${e.message}]");
      _responseService.finalizeResponse();
    }
  }

  Future<void> releaseModel() async {
    debugPrint("[OfflineService] Invoking 'releaseModel'.");
    await _llamaChannel.invokeMethod('releaseModel');
    _sessionProvider.setLocalModelLoaded(false);
  }

  Future<void> sendMessage(String text, String? photoPath) async {
    final String? modelId = _sessionProvider.modelId;
    if (modelId == null) {
      _responseService.onMessageResponse("[Error: No model selected.]");
      _responseService.finalizeResponse();
      return;
    }

    final ModelEntity model =
        _modelService.getPreciseModelData(modelId, langCode: 'en');

    // Setup Processor (Stops formatting tokens)
    _currentProcessor = ChatFormatProcessor(
      model.chatFormat,
      onStopTokenDetected: stopGeneration,
    );
    _resetRepetitionGuardState();

    // Prepare Prompt
    final String finalPrompt =
        await _buildFormattedPrompt(model: model, latestMessage: text);
    if (finalPrompt.isEmpty) {
      _responseService.finalizeResponse();
      return;
    }

    // OPTIMIZATION: Computed Samplers
    final sampler = computeSampler(model);
    debugPrint(
        "[OfflineService] Sending Message with Samplers: T=${sampler.temperature}, P=${sampler.topP}, K=${sampler.topK}");

    // Note: We don't reset KV cache every turn necessarily if we want conversational memory,
    // but the current architecture might clear it on the native side.
    // If the native side clears KV on 'send', we should rely on that or manage it here.
    // The updated Native logic clears KV before generating to handle the FULL prompt we send (history included).
    // So we don't need to manually clear it here if native does it, but calling it ensures sync.
    // await _resetKvCache(); // Native code handles this now in 'send' flow based on the full prompt.

    await _llamaChannel.invokeMethod<void>(
      'sendMessage',
      {
        'message': finalPrompt,
        'photoPath': photoPath,
        'temp': sampler.temperature,
        'topP': sampler.topP,
        'topK': sampler.topK,
      },
    );
  }

  Future<void> stopGeneration() async {
    debugPrint("[OfflineService] Invoking 'stopGeneration'.");
    await _llamaChannel.invokeMethod('stopGeneration');
  }

  // ===========================================================================
  // Native Handler
  // ===========================================================================

  @pragma('vm:entry-point')
  Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onMessageResponse':
        final String rawToken = call.arguments as String? ?? '';
        if (_forceAbortCurrentStream) return;

        final processor = _currentProcessor;
        if (processor == null) {
          if (rawToken.isEmpty) return;
          if (_shouldAbortForRepetition(rawToken)) {
            _handleRepetitionAbort();
          } else {
            _responseService.onMessageResponse(rawToken);
          }
          return;
        }

        final String? processedToken = processor.processToken(rawToken);
        if (processedToken != null && processedToken.isNotEmpty) {
          if (_shouldAbortForRepetition(processedToken)) {
            _handleRepetitionAbort();
          } else {
            _responseService.onMessageResponse(processedToken);
          }
        }
        break;

      case 'onMessageComplete':
        debugPrint("[OfflineService] Complete.");

        final tail = _currentProcessor?.finalize();
        if (tail != null && tail.isNotEmpty) {
          _responseService.onMessageResponse(tail);
        }
        _responseService.finalizeResponse();
        _currentProcessor = null;
        break;

      case 'onModelLoaded':
        debugPrint("[OfflineService] Model Loaded Successfully.");
        _sessionProvider.setLocalModelLoaded(true);
        break;

      case 'onModelLoadFailed':
        final String error = call.arguments as String? ?? 'Unknown error';
        debugPrint("[OfflineService] Load Failed: $error");
        _sessionProvider.setLocalModelLoaded(false);
        break;

      default:
        break;
    }
  }

  // ===========================================================================
  // Prompt & Repetition Check (Same as before but cleaner)
  // ===========================================================================

  Future<String> _buildFormattedPrompt({
    required ModelEntity model,
    required String latestMessage,
  }) async {
    // 1. Fallback to default ChatML if no format is provided (safety net).
    // Use ModelDefaults.defaultChatFormat if model.chatFormat is null.
    // Since we can't easily import ModelDefaults here without checking imports,
    // we'll assume the service layer handled it or implement a local hard fallback.
    // However, robust code handles nulls gracefully.

    // Check if we need to force a default format.
    final format = model.chatFormat;

    // If absolutely no format, we have to construct a temporary one to avoid RAW text completion mode
    // which confuses users.
    final effectiveTokens = format?.tokens ??
        ChatTokens.fromMap(ModelDefaults.getFallbackFormat(model.id));

    final sb = StringBuffer();
    final systemPrompt = (model.role ?? "").trim();

    // System Preamble
    if (systemPrompt.isNotEmpty &&
        (effectiveTokens.systemStart?.isNotEmpty ?? false)) {
      _appendTurn(sb,
          start: effectiveTokens.systemStart!,
          end: effectiveTokens.systemEnd,
          content: systemPrompt);
    }

    // Chat History
    final history = await _contextService.buildContextMessages(
      includeLastUser: false,
      targetModelId: model.id,
      langCode: 'en',
    );

    for (final msg in history) {
      final role = msg['role'];
      final content = _extractVisibleText(msg['content']);
      if (content.isEmpty) continue;

      if (role == 'user') {
        _appendTurn(sb,
            start: effectiveTokens.userStart ?? '',
            end: effectiveTokens.userEnd,
            content: content);
      } else if (role == 'assistant') {
        _appendTurn(sb,
            start: effectiveTokens.assistantStart ?? '',
            end: effectiveTokens.assistantEnd,
            content: content);
      }
    }

    // Last User Message
    _appendTurn(sb,
        start: effectiveTokens.userStart ?? '',
        end: effectiveTokens.userEnd,
        content: latestMessage);

    // Assistant Primer
    if (effectiveTokens.assistantStart?.isNotEmpty ?? false) {
      sb.write(effectiveTokens.assistantStart!);
      // Smart newline check: Only add if the token doesn't already end with one.
      if (!effectiveTokens.assistantStart!.endsWith('\n')) {
        // Some formats might not want a newline here, but for most (ChatML/Llama3),
        // the start token implies a header start. Llama3: <|start_header_id|>assistant<|end_header_id|>\n\n
        // ChatML: <|im_start|>assistant\n
        // If our default has \n, we skip. If not, we might need one.
        // For safety, we trust the token definition primarily.
      }
    }

    return sb.toString();
  }

  String _extractVisibleText(dynamic content) {
    if (content is String) return content.trim();
    if (content is List) return "multimodal content"; // Simplification
    return "";
  }

  void _appendTurn(StringBuffer sb,
      {required String start, String? end, required String content}) {
    if (start.isNotEmpty) {
      sb.write(start);
      // Only add newline if start token doesn't have one and isn't a complex header
      if (!start.endsWith('\n')) {
        sb.write('\n');
      }
    }

    sb.write(content);
    // Ensure content ends with newline before closing tag
    if (!content.endsWith('\n')) {
      sb.write('\n');
    }

    if (end != null && end.isNotEmpty) {
      sb.write(end);
      if (!end.endsWith('\n')) {
        sb.write('\n');
      }
    }
  }

  void _resetRepetitionGuardState() {
    _visibleHistory = '';
    _lastVisibleChunk = null;
    _lastVisibleChunkRepeatCount = 0;
    _forceAbortCurrentStream = false;
  }

  bool _shouldAbortForRepetition(String visibleChunk) {
    if (visibleChunk.isEmpty) return false;
    if (_lastVisibleChunk == visibleChunk) {
      _lastVisibleChunkRepeatCount++;
    } else {
      _lastVisibleChunk = visibleChunk;
      _lastVisibleChunkRepeatCount = 1;
    }

    if (_lastVisibleChunkRepeatCount >= _chunkRepeatThreshold) return true;

    _visibleHistory += visibleChunk;
    if (_visibleHistory.length > _maxHistoryLength) {
      _visibleHistory =
          _visibleHistory.substring(_visibleHistory.length - _maxHistoryLength);
    }
    // Simple tail check
    if (_visibleHistory.endsWith(visibleChunk * _patternRepeatThreshold) &&
        visibleChunk.length > 3) {
      return true;
    }

    return false;
  }

  void _handleRepetitionAbort() {
    if (_forceAbortCurrentStream) return;
    _forceAbortCurrentStream = true;
    debugPrint("[OfflineService] Repetition Guard Abort.");
    stopGeneration();
  }
}
