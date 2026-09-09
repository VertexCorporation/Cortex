// lib/chat/services/offline.dart
//
// OfflineService - Optimized
//
// Manages communication with the native (Kotlin/Swift) layer for running
// on-device (offline) models via a platform channel.
//
// Optimizations:
// - Adaptive context, CPU threads, and prefill batches.
// - Native model and verified prompt-prefix/KV reuse.
// - Platform-verified GPU offload with CPU fallback.
//

import 'dart:async';
import 'dart:io'; // Required for File checks
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/processor.dart';
import 'package:cortex/chat/services/response.dart';
import 'package:cortex/chat/services/speculative.dart';
import 'package:cortex/rag/chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/remove.dart';
import '../../library/backend/data/service.dart';
import '../../library/backend/data/format.dart';
import '../../library/backend/data/defaults.dart';
import 'context.dart';
import 'offline_tuning.dart';
import 'offline_request.dart';

class SamplerPreset {
  final double temperature;
  final double topP;
  final int topK;
  final double repeatPenalty;
  final double frequencyPenalty;
  final double presencePenalty;
  final int mirostatMode;
  final double mirostatTau;
  final double mirostatEta;

  const SamplerPreset({
    required this.temperature,
    required this.topP,
    required this.topK,
    this.repeatPenalty = 1.0,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
    this.mirostatMode = 0,
    this.mirostatTau = 5.0,
    this.mirostatEta = 0.1,
  });
}

SamplerPreset computeSampler(ModelEntity model) {
  final size = model.size ?? 0;

  if (size <= 1000) {
    return SamplerPreset(
      temperature: 0.5,
      topP: 0.9,
      topK: 20,
      repeatPenalty: 1.15,
      presencePenalty: 0.1,
    );
  } else if (size <= 4000) {
    return SamplerPreset(
      temperature: 0.65,
      topP: 0.9,
      topK: 40,
      repeatPenalty: 1.1,
      presencePenalty: 0.05,
    );
  } else {
    return SamplerPreset(
      temperature: 0.7,
      topP: 0.95,
      topK: 40,
      repeatPenalty: 1.05,
      presencePenalty: 0.05,
    );
  }
}

SamplerPreset codeSampler(ModelEntity model) {
  return SamplerPreset(
    temperature: 0.2,
    topP: 0.85,
    topK: 20,
    repeatPenalty: 1.2,
    presencePenalty: 0.1,
  );
}

SamplerPreset creativeSampler(ModelEntity model) {
  return SamplerPreset(
    temperature: 0.8,
    topP: 0.95,
    topK: 50,
    repeatPenalty: 1.05,
    presencePenalty: 0.1,
    mirostatMode: 2,
    mirostatTau: 5.0,
    mirostatEta: 0.1,
  );
}

class OfflineService {
  OfflineRequest? _request;

  bool _ownsRequest(String requestId) =>
      _request?.accepts(requestId, _responseService.conversationId) ?? false;

  final ResponseService _responseService;
  final ChatSessionProvider _sessionProvider;
  final ModelService _modelService;
  final ContextService _contextService;
  final RagChatService _ragChat;

  ChatFormatProcessor? _currentProcessor;
  SpeculativeDecodingConfig _speculativeConfig =
      const SpeculativeDecodingConfig();

  // Repetition guard state per stream
  String _visibleHistory = '';
  String? _lastVisibleChunk;
  int _lastVisibleChunkRepeatCount = 0;
  bool _forceAbortCurrentStream = false;
  bool _hasDeliveredOutput = false;

  // Repetition guard constants
  static const int _maxHistoryLength = 1024;
  static const int _chunkRepeatThreshold = 6; // More aggressive stop
  static const int _patternRepeatThreshold = 4;

  static const MethodChannel _llamaChannel =
      MethodChannel('com.vertex.cortex/llama');

  Completer<bool>? _modelLoadCompleter;
  Completer<bool>? _singleLoadAttemptCompleter;
  Timer? _retryTimer;
  Stopwatch? _deliveryClock;
  int _nativeChunks = 0;
  int _visibleChunks = 0;
  String? _loadedModelPath;
  int _loadedContextSize = 0;
  String? _pendingLoadPath;
  OfflineRuntimeConfig? _pendingRuntimeConfig;
  Stopwatch? _modelLoadStopwatch;

  OfflineService({
    required ResponseService responseService,
    required ChatSessionProvider sessionProvider,
    required ModelService modelService,
    required ContextService contextService,
    required RagChatService ragChat,
  })  : _responseService = responseService,
        _sessionProvider = sessionProvider,
        _modelService = modelService,
        _contextService = contextService,
        _ragChat = ragChat {
    _llamaChannel.setMethodCallHandler(methodCallHandler);
  }

  void setSpeculativeDecodingConfig(SpeculativeDecodingConfig config) {
    _speculativeConfig = config;
  }

  // ===========================================================================
  // Public API
  // ===========================================================================

  Future<OfflineRuntimeConfig> _computeRuntimeConfig({
    String prompt = '',
    String? modelContext,
  }) async {
    const memoryChannel = MethodChannel('com.vertex.cortex/memory');
    var totalRamMb = 4096;
    var usedRamMb = 2048;

    try {
      final values = await Future.wait<int>([
        memoryChannel
            .invokeMethod<int>('getDeviceMemory')
            .then((value) => value ?? 4096),
        memoryChannel
            .invokeMethod<int>('getUsedMemory')
            .then((value) => value ?? 2048),
      ]);
      totalRamMb = values[0];
      usedRamMb = values[1];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OfflineService] RAM query failed; using safe defaults: $e');
      }
    }

    final freeRamMb =
        (totalRamMb - usedRamMb).clamp(0, totalRamMb).toInt();
    final logicalCores = Platform.numberOfProcessors;
    final nCtx = OfflineInferenceTuning.selectContextSize(
      prompt: prompt,
      totalRamMb: totalRamMb,
      freeRamMb: freeRamMb,
      modelContext: modelContext,
    );
    final batch = OfflineInferenceTuning.selectBatchConfig(
      totalRamMb: totalRamMb,
      freeRamMb: freeRamMb,
      contextSize: nCtx,
    );

    // The Android build does not enable GGML_VULKAN, so Android must remain
    // CPU-only. The shipped iOS framework contains Metal and retains its
    // existing CPU fallback on load failure.
    final nGpuLayers = Platform.isIOS ? 99 : 0;

    return OfflineRuntimeConfig(
      nCtx: nCtx,
      nThreads:
          OfflineInferenceTuning.selectGenerationThreads(logicalCores),
      nThreadsBatch: OfflineInferenceTuning.selectBatchThreads(logicalCores),
      nBatch: batch.nBatch,
      nUbatch: batch.nUbatch,
      nGpuLayers: nGpuLayers,
      totalRamMb: totalRamMb,
      freeRamMb: freeRamMb,
      logicalCoreCount: logicalCores,
    );
  }

  Future<bool> cacheModel(
    String path, {
    String prompt = '',
    String? modelContext,
  }) async {
    final runtimeConfig = await _computeRuntimeConfig(
      prompt: prompt,
      modelContext: modelContext,
    );

    if (_sessionProvider.isLocalModelLoaded &&
        _loadedModelPath == path &&
        _loadedContextSize >= runtimeConfig.nCtx) {
      if (kDebugMode) {
        debugPrint(
            '[OfflineService][perf] model reuse path=$path ctx=$_loadedContextSize');
      }
      return true;
    }

    if (_modelLoadCompleter != null) {
      final pendingCanSatisfy = _pendingLoadPath == path &&
          (_pendingRuntimeConfig?.nCtx ?? 0) >= runtimeConfig.nCtx;
      final result = await _modelLoadCompleter!.future;
      if (pendingCanSatisfy) return result;
      return cacheModel(path, prompt: prompt, modelContext: modelContext);
    }

    if (path.isEmpty) {
      debugPrint("[OfflineService] Aborting cacheModel call: Path is empty.");
      return false;
    }

    if (!await File(path).exists()) {
      debugPrint(
          "[OfflineService] Critical Error: Model file not found at $path");
      await _autoRemoveSelectedOfflineModel();
      return false;
    }

    _modelLoadCompleter = Completer<bool>();
    _pendingLoadPath = path;
    _pendingRuntimeConfig = runtimeConfig;
    _modelLoadStopwatch = Stopwatch()..start();
    unawaited(_loadModelWithRetries(path, runtimeConfig));
    return _modelLoadCompleter!.future;
  }

  Future<void> _loadModelWithRetries(
    String path,
    OfflineRuntimeConfig runtimeConfig,
  ) async {
    bool loaded = false;
    final maxAttempts = runtimeConfig.nGpuLayers > 0 ? 2 : 1;

    if (kDebugMode) {
      debugPrint(
          '[OfflineService][perf] load path=$path ctx=${runtimeConfig.nCtx} '
          'threads=${runtimeConfig.nThreads}/${runtimeConfig.nThreadsBatch} '
          'gpu=${runtimeConfig.nGpuLayers} batch=${runtimeConfig.nBatch}/'
          '${runtimeConfig.nUbatch} cores=${runtimeConfig.logicalCoreCount} '
          'ram=${runtimeConfig.totalRamMb}MB free=${runtimeConfig.freeRamMb}MB');
    }

    try {
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        final currentGpu = attempt == 1 ? runtimeConfig.nGpuLayers : 0;

        loaded = await _runSingleModelLoadAttempt(
          path: path,
          nCtx: runtimeConfig.nCtx,
          nGpu: currentGpu,
          nThreads: runtimeConfig.nThreads,
          nThreadsBatch: runtimeConfig.nThreadsBatch,
          nBatch: runtimeConfig.nBatch,
          nUbatch: runtimeConfig.nUbatch,
          attempt: attempt,
          maxAttempts: maxAttempts,
        );
        if (loaded) break;

        if (attempt < maxAttempts) {
          _retryTimer?.cancel();
          await _retryDelay(const Duration(milliseconds: 350));
        }
      }

    } catch (e) {
      debugPrint("[OfflineService] Model load retry loop failed: $e");
      loaded = false;
    }

    if (!loaded && !_sessionProvider.isLocalModelLoaded) {
      _sessionProvider.setLocalModelLoaded(false);
    }

    if (_modelLoadCompleter != null && !_modelLoadCompleter!.isCompleted) {
      _modelLoadCompleter!.complete(loaded);
    }
    _modelLoadCompleter = null;
    _pendingLoadPath = null;
    _pendingRuntimeConfig = null;
    _modelLoadStopwatch = null;
  }

  Future<bool> _runSingleModelLoadAttempt({
    required String path,
    required int nCtx,
    required int nGpu,
    required int nThreads,
    required int nThreadsBatch,
    required int nBatch,
    required int nUbatch,
    required int attempt,
    required int maxAttempts,
  }) async {
    if (kDebugMode) {
      debugPrint('[OfflineService] Model load attempt $attempt/$maxAttempts');
    }
    _singleLoadAttemptCompleter = Completer<bool>();

    try {
      await _llamaChannel.invokeMethod<void>('cacheModel', {
        'path': path,
        'nCtx': nCtx,
        'nGpu': nGpu,
        'nThreads': nThreads,
        'nThreadsBatch': nThreadsBatch,
        'nBatch': nBatch,
        'nUbatch': nUbatch,
        'debugPerf': kDebugMode,
      });

      return await _singleLoadAttemptCompleter!.future.timeout(
        const Duration(seconds: 90),
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
      if (removed) {
        _sessionProvider.removeDownloadedModel(selected.id);
      }
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
    _loadedModelPath = null;
    _loadedContextSize = 0;
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

  Future<void> sendMessage(
    String text,
    String? photoPath, [
    ChatInputMode? activeMode,
    List<String> attachmentPaths = const [],
    bool ragEnabled = false,
    List<String> ragDocumentIds = const [],
  ]) async {
    _request?.cancel();
    final request = OfflineRequest(_responseService.conversationId);
    _request = request;
    final requestId = request.id;
    _currentProcessor = null;
    try {
      await _llamaChannel.invokeMethod<void>('stopGeneration');
      if (!_ownsRequest(requestId)) return;
      await _sendMessage(requestId, text, photoPath, activeMode,
          attachmentPaths, ragEnabled, ragDocumentIds);
    } catch (e) {
      if (_ownsRequest(requestId)) {
        _responseService.onMessageResponse('[Error: Local generation failed. Please retry.]');
        _responseService.finalizeResponse();
        _request?.cancel();
      }
      if (kDebugMode) debugPrint('[OfflineService] Generation failed: $e');
    }
  }

  Future<void> _sendMessage(
    String requestId,
    String text,
    String? photoPath,
    ChatInputMode? activeMode,
    List<String> attachmentPaths,
    bool ragEnabled,
    List<String> ragDocumentIds,
  ) async {
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

    final bool enableThinkingMode =
        activeMode == ChatInputMode.featureReasoning;
    final langCode = _sessionProvider.getLocale().languageCode;

    // RAG (Document Chat): retrieve relevant passages before building the
    // prompt so the offline model can answer from attached documents.
    final String? ragContext = await _ragChat.buildContext(
      queryText: text,
      toggleEnabled: ragEnabled,
      toggleDocumentIds: ragDocumentIds,
      attachmentPaths: attachmentPaths,
    );
    if (!_ownsRequest(requestId)) return;

    // Prepare Prompt
    final String finalPrompt = await _buildFormattedPrompt(
      model: model,
      latestMessage: text,
      enableThinkingMode: enableThinkingMode,
      langCode: langCode,
      ragContext: ragContext,
    );
    if (!_ownsRequest(requestId)) return;
    if (finalPrompt.isEmpty) {
      _responseService.finalizeResponse();
      return;
    }

    final modelReady = await cacheModel(
      modelPath,
      prompt: finalPrompt,
      modelContext: model.context,
    );
    if (!_ownsRequest(requestId)) return;
    if (!modelReady) {
      _responseService.onMessageResponse('[Error: Local model could not prepare this conversation. Please retry.]');
      _responseService.finalizeResponse();
      return;
    }

    // Setup Processor (Stops formatting tokens)
    _currentProcessor = ChatFormatProcessor(
      model.chatFormat,
      onStopTokenDetected: () => _llamaChannel.invokeMethod<void>('stopGeneration'),
    );
    _resetRepetitionGuardState();

    // OPTIMIZATION: Computed Samplers with per-task presets
    final SamplerPreset sampler;
    switch (activeMode) {
      case ChatInputMode.featureReasoning:
        sampler = codeSampler(model);
      case ChatInputMode.study:
      case ChatInputMode.quiz:
        sampler = creativeSampler(model);
      default:
        sampler = computeSampler(model);
    }
    if (kDebugMode) {
      debugPrint(
          '[OfflineService] sampler temp=${sampler.temperature} '
          'topP=${sampler.topP} topK=${sampler.topK}');
    }

    final specArgs = _speculativeConfig.enabled
        ? _speculativeConfig.toNativeArgs()
        : <String, dynamic>{};

    if (kDebugMode) {
      _deliveryClock = Stopwatch()..start();
      _nativeChunks = 0;
      _visibleChunks = 0;
    }
    await _llamaChannel.invokeMethod<void>(
      'sendMessage',
      {
        'message': finalPrompt,
        'requestId': requestId,
        'photoPath': photoPath,
        'temp': sampler.temperature,
        'topP': sampler.topP,
        'topK': sampler.topK,
        'repeatPenalty': sampler.repeatPenalty,
        'frequencyPenalty': sampler.frequencyPenalty,
        'presencePenalty': sampler.presencePenalty,
        'mirostatMode': sampler.mirostatMode,
        'mirostatTau': sampler.mirostatTau,
        'mirostatEta': sampler.mirostatEta,
        'debugPerf': kDebugMode,
        ...specArgs,
      },
    );
  }

  Future<void> stopGeneration() async {
    _request?.cancel();
    _currentProcessor = null;
    debugPrint("[OfflineService] Invoking 'stopGeneration'.");
    await _llamaChannel.invokeMethod('stopGeneration');
  }

  Future<void> _retryDelay(Duration duration) {
    final completer = Completer<void>();
    _retryTimer = Timer(duration, () => completer.complete());
    return completer.future;
  }

  // ===========================================================================
  // Native Handler
  // ===========================================================================

  @pragma('vm:entry-point')
  Future<void> methodCallHandler(MethodCall call) async {
    if (call.method == 'onMessageResponse' ||
        call.method == 'onMessageComplete') {
      final event = call.arguments;
      if (event is! Map || event['requestId'] is! String ||
          !_ownsRequest(event['requestId'] as String)) return;
    }
    switch (call.method) {
      case 'onMessageResponse':
        final String rawToken = (call.arguments as Map)['token'] as String? ?? '';
        if (_forceAbortCurrentStream) return;
        if (kDebugMode && rawToken.isNotEmpty && ++_nativeChunks == 1) {
          debugPrint('[OfflineService][delivery] firstNativeChunkMs='
              '${_deliveryClock?.elapsedMilliseconds}');
        }

        final processor = _currentProcessor;
        if (processor == null) {
          if (rawToken.isEmpty) return;
          if (_shouldAbortForRepetition(rawToken)) {
            _handleRepetitionAbort();
          } else {
            _deliverVisibleChunk(rawToken);
          }
          return;
        }

        final String? processedToken = processor.processToken(rawToken);
        if (processedToken != null && processedToken.isNotEmpty) {
          if (_shouldAbortForRepetition(processedToken)) {
            _handleRepetitionAbort();
          } else {
            _deliverVisibleChunk(processedToken);
          }
        }
        break;

      case 'onMessageComplete':
        debugPrint("[OfflineService] Complete.");

        final tail = _currentProcessor?.finalize();
        if (tail != null && tail.isNotEmpty) {
          _deliverVisibleChunk(tail);
        }
        if ((call.arguments as Map)['error'] != null) {
          _deliverVisibleChunk('\n[Error: Local generation failed. Please retry.]');
        } else if (!_hasDeliveredOutput) {
          _deliverVisibleChunk('[Error: Local model returned no response. Please retry.]');
        }
        if (kDebugMode) {
          _deliveryClock?.stop();
          debugPrint('[OfflineService][delivery] nativeChunks=$_nativeChunks '
              'visibleChunks=$_visibleChunks '
              'elapsedMs=${_deliveryClock?.elapsedMilliseconds}');
          _deliveryClock = null;
        }
        _responseService.finalizeResponse();
        _currentProcessor = null;
        _request?.cancel();
        break;

      case 'onModelLoaded':
        final details = call.arguments;
        if (details is Map) {
          _loadedModelPath = details['path']?.toString() ?? _pendingLoadPath;
          _loadedContextSize = (details['nCtx'] as num?)?.toInt() ??
              _pendingRuntimeConfig?.nCtx ??
              0;
        } else {
          _loadedModelPath = _pendingLoadPath;
          _loadedContextSize = _pendingRuntimeConfig?.nCtx ?? 0;
        }
        _sessionProvider.setLocalModelLoaded(true);
        final ready = details is! Map || details['capacitySatisfied'] != false;
        if (kDebugMode) {
          _modelLoadStopwatch?.stop();
          debugPrint(
              '[OfflineService][perf] model ready path=$_loadedModelPath '
              'ctx=$_loadedContextSize elapsedMs='
              '${_modelLoadStopwatch?.elapsedMilliseconds ?? -1} '
              'reused=${details is Map ? details['reusedModel'] : null}');
        }
        if (_singleLoadAttemptCompleter != null &&
            !_singleLoadAttemptCompleter!.isCompleted) {
          _singleLoadAttemptCompleter!.complete(ready);
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

  void _deliverVisibleChunk(String chunk) {
    if (chunk.trim().isNotEmpty) _hasDeliveredOutput = true;
    if (kDebugMode && ++_visibleChunks == 1) {
      debugPrint('[OfflineService][delivery] firstVisibleChunkMs='
          '${_deliveryClock?.elapsedMilliseconds}');
    }
    _responseService.onMessageResponse(chunk);
  }

  Future<String> _buildFormattedPrompt({
    required ModelEntity model,
    required String latestMessage,
    bool enableThinkingMode = false,
    String langCode = 'en',
    String? ragContext,
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
    var systemPrompt = (model.role ?? "").trim();

    // Short, direct instructions for better local model output
    final langName = _languageName(langCode);
    if (langCode == 'tr') {
      systemPrompt +=
          "\n\nSen Türkçe konuşan bir asistansın. Kısa ve doğal yanıt ver. Asla düşünce etiketi (<think>), işaretleme dili (markdown) veya biçimlendirme kullanma. Sadece düz metinle yanıtla. Konuşma geçmişini hatırla ve bağlamı koru.";
    } else if (langCode == 'de') {
      systemPrompt +=
          "\n\nDu bist ein Assistent, der Deutsch spricht. Antworte kurz und natürlich. Verwende niemals Denk-Tags (<think>), Markdown oder Formatierungen. Antworte nur in Klartext. Behalte den Gesprächsverlauf im Gedächtnis.";
    } else if (langCode == 'fr') {
      systemPrompt +=
          "\n\nTu es un assistant qui parle français. Réponds brièvement et naturellement. N'utilise jamais de balises de pensée (<think>), de markdown ou de formatage. Réponds uniquement en texte brut. Souviens-toi de l'historique de la conversation.";
    } else {
      systemPrompt +=
          "\n\nYou are a $langName-speaking assistant. Keep responses short and natural. Never use think tags (<think>), markdown, or formatting. Respond in plain text only. Remember the conversation history.";
    }

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
      langCode: langCode,
      isServerSide: false,
      enableThinkingMode: enableThinkingMode,
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
    final String effectiveLatest = (ragContext != null && ragContext.isNotEmpty)
        ? '$ragContext\n\n$latestMessage'
        : latestMessage;
    _appendTurn(sb,
        start: effectiveTokens.userStart ?? '',
        end: effectiveTokens.userEnd,
        content: effectiveLatest);

    // Assistant Primer (consistent with _appendTurn — adds newline after start token)
    if (effectiveTokens.assistantStart?.isNotEmpty ?? false) {
      sb.write(effectiveTokens.assistantStart!);
      if (!effectiveTokens.assistantStart!.endsWith('\n')) {
        sb.write('\n');
      }
    }

    return sb.toString();
  }

  String _languageName(String langCode) {
    switch (langCode) {
      case 'tr': return 'Turkish';
      case 'de': return 'German';
      case 'fr': return 'French';
      case 'es': return 'Spanish';
      case 'it': return 'Italian';
      case 'pt': return 'Portuguese';
      case 'nl': return 'Dutch';
      case 'pl': return 'Polish';
      case 'ru': return 'Russian';
      case 'ja': return 'Japanese';
      case 'ko': return 'Korean';
      case 'zh': return 'Chinese';
      case 'ar': return 'Arabic';
      case 'hi': return 'Hindi';
      default: return 'English';
    }
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
    _hasDeliveredOutput = false;
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
    unawaited(_llamaChannel.invokeMethod<void>('stopGeneration'));
  }
}
