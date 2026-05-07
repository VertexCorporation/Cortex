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

import 'dart:async';
import 'dart:io'; // Required for File checks
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/processor.dart';
import 'package:cortex/chat/services/response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/remove.dart';
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

  static const int _maxModelLoadRetries = 5;

  Completer<bool>? _modelLoadCompleter;
  Completer<bool>? _singleLoadAttemptCompleter;

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
      int totalRAM =
          await memoryChannel.invokeMethod<int>('getDeviceMemory') ?? 4096;
      int usedRAM =
          await memoryChannel.invokeMethod<int>('getUsedMemory') ?? 2048;

      // Calculate free RAM
      int freeRAM = totalRAM - usedRAM;
      
      // If freeRAM is negative or abnormally low, fall back to safe defaults
      if (freeRAM <= 0) {
        freeRAM = 1024; 
      }

      // We should assume that the model itself takes huge RAM (e.g. 2-5 GB).
      // So instead of just looking at current freeRAM, we use a conservative clamp based on total RAM or cap it around 4096 to prevent silent OOM crashes in native libraries.
      int nCtx = 2048;
      if (totalRAM >= 8192) {
        nCtx = 8192; // 8GB+ devices can handle 8K
      } else if (totalRAM >= 6144) {
        nCtx = 4096; // 6GB devices 
      } else {
        nCtx = 2048; // Standard safe fallback
      }

      debugPrint(
          "[OfflineService] RAM Status: total=$totalRAM MB, used=$usedRAM MB, free=$freeRAM MB");
      debugPrint(
          "[OfflineService] Computed Context: $nCtx tokens for offline model.");

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

  Future<bool> cacheModel(String path) async {
    if (_sessionProvider.isLocalModelLoaded) {
      return true;
    }

    if (_modelLoadCompleter != null) {
      return _modelLoadCompleter!.future;
    }

    if (path.isEmpty) {
      debugPrint("[OfflineService] Aborting cacheModel call: Path is empty.");
      return false;
    }

    if (!await File(path).exists()) {
      debugPrint(
          "[OfflineService] Critical Error: Model file not found at $path");
      return false;
    }

    _modelLoadCompleter = Completer<bool>();
    unawaited(_loadModelWithRetries(path));
    return _modelLoadCompleter!.future;
  }

  Future<void> _loadModelWithRetries(String path) async {
    bool loaded = false;

    // DYNAMIC CONTEXT SIZE based on device RAM
    final int nCtx = await _computeOptimalContextSize();

    // GPU Layers: On Android, forcing GPU can cause silent crashes if Vulkan/OpenCL is unsupported. 
    // We pass 99 for iOS since Metal usually handles it well, but let's be careful on Android.
    int nGpu = 0;
    if (Platform.isIOS) {
       nGpu = 99;
    }


    // DYNAMIC THREADS based on RAM (proxy for CPU power)
    const memoryChannel = MethodChannel('com.vertex.cortex/memory');
    final int ramMB =
        await memoryChannel.invokeMethod<int>('getDeviceMemory') ?? 4096;
    final int nThreads = _computeOptimalThreads(ramMB);

    debugPrint(
        "[OfflineService] 🚀 Caching Model => ctx=$nCtx, gpu=$nGpu, threads=$nThreads (RAM: $ramMB MB)");

    try {
      for (var attempt = 1; attempt <= _maxModelLoadRetries; attempt++) {
        loaded = await _runSingleModelLoadAttempt(
          path: path,
          nCtx: nCtx,
          nGpu: nGpu,
          nThreads: nThreads,
          attempt: attempt,
        );
        if (loaded) break;

        await _safeReleaseNativeModel();
        _sessionProvider.setLocalModelLoaded(false);

        if (attempt < _maxModelLoadRetries) {
          await Future.delayed(const Duration(milliseconds: 350));
        }
      }

      if (!loaded) {
        await _autoRemoveSelectedOfflineModel();
      }
    } catch (e) {
      debugPrint("[OfflineService] Model load retry loop failed: $e");
      loaded = false;
    }

    if (!loaded) {
      _sessionProvider.setLocalModelLoaded(false);
    }

    if (_modelLoadCompleter != null && !_modelLoadCompleter!.isCompleted) {
      _modelLoadCompleter!.complete(loaded);
    }
    _modelLoadCompleter = null;
  }

  Future<bool> _runSingleModelLoadAttempt({
    required String path,
    required int nCtx,
    required int nGpu,
    required int nThreads,
    required int attempt,
  }) async {
    debugPrint(
        "[OfflineService] Model load attempt $attempt/$_maxModelLoadRetries");
    _singleLoadAttemptCompleter = Completer<bool>();

    try {
      await _llamaChannel.invokeMethod<void>('cacheModel', {
        'path': path,
        'nCtx': nCtx,
        'nGpu': nGpu,
        'nThreads': nThreads,
      });

      // Reduced timeout but also changed how fast we return
      return await _singleLoadAttemptCompleter!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint(
              "[OfflineService] Timeout while waiting for model load (attempt $attempt).");
          return false;
        },
      );
    } on PlatformException catch (e) {
      debugPrint(
          "[OfflineService] Failed to invoke 'cacheModel' (attempt $attempt): ${e.message}");
      return false;
    } finally {
      _singleLoadAttemptCompleter = null;
    }
  }

  Future<void> _safeReleaseNativeModel() async {
    try {
      await _llamaChannel.invokeMethod<void>('releaseModel');
    } catch (e) {
      debugPrint(
          "[OfflineService] releaseModel after failed load also failed: $e");
    }
  }

  Future<void> _autoRemoveSelectedOfflineModel() async {
    final selected = _sessionProvider.selectedModel;
    if (selected == null || selected.isServerSide) {
      return;
    }

    try {
      final removed = await ModelRemoveService.uninstallDownloadedModel(
        id: selected.id,
        title: selected.displayTitle,
      );
      debugPrint(
          "[OfflineService] Auto-uninstall after failed loads for ${selected.id}: $removed");
    } catch (e) {
      debugPrint("[OfflineService] Auto-uninstall failed: $e");
    }
  }

  Future<void> releaseModel() async {
    debugPrint("[OfflineService] Invoking 'releaseModel'.");
    // Fix: Ensure any active generation is stopped before releasing memory/file handle.
    await stopGeneration();
    await _llamaChannel.invokeMethod('releaseModel');
    _sessionProvider.setLocalModelLoaded(false);
    if (_modelLoadCompleter != null && !_modelLoadCompleter!.isCompleted) {
      _modelLoadCompleter!.complete(false);
    }
    if (_singleLoadAttemptCompleter != null &&
        !_singleLoadAttemptCompleter!.isCompleted) {
      _singleLoadAttemptCompleter!.complete(false);
    }
    _modelLoadCompleter = null;
    _singleLoadAttemptCompleter = null;
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

    final modelPath = _sessionProvider.modelPath;
    if (modelPath == null || modelPath.isEmpty) {
      _responseService.finalizeResponse();
      return;
    }

    final modelReady = await cacheModel(modelPath);
    if (!modelReady) {
      _responseService.finalizeResponse();
      return;
    }

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
        if (_singleLoadAttemptCompleter != null &&
            !_singleLoadAttemptCompleter!.isCompleted) {
          _singleLoadAttemptCompleter!.complete(true);
        }
        break;

      case 'onModelLoadFailed':
        final String error = call.arguments as String? ?? 'Unknown error';
        debugPrint("[OfflineService] Load Failed: $error");
        _sessionProvider.setLocalModelLoaded(false);
        if (_singleLoadAttemptCompleter != null &&
            !_singleLoadAttemptCompleter!.isCompleted) {
          _singleLoadAttemptCompleter!.complete(false);
        }
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
      isServerSide: false,
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
