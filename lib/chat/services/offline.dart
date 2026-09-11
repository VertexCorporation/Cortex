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

/// Classifies why a native model load attempt failed.
///
/// * [fileNotFound] — the GGUF is genuinely absent (stale download record).
/// * [engineLoad]   — the native engine rejected the file while loading
///   (e.g. `unknown model architecture` on a llama.cpp build that predates
///   the model's release). The file itself can be perfectly valid.
/// * [timeout]      — the attempt did not finish within the per-attempt
///   budget (slow device, memory pressure, GPU init hang). Often transient.
/// * [none]         — no failure recorded (attempt succeeded / not run yet).
enum _LoadFailureKind { none, fileNotFound, engineLoad, timeout }

class OfflineService {
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

  // ===========================================================================
  // Native stream lifecycle — cross-conversation isolation
  // ===========================================================================
  //
  // ONE llama context serves the whole app. When the user leaves a chat while
  // its offline generation is still running, the native stream keeps decoding
  // until it is stopped. `isWaitingForResponse` is a single, conversation-
  // blind flag, so if a NEW conversation starts waiting while that stale
  // stream is still alive, the stale stream's tokens — and its terminal
  // `onMessageComplete` — are routed into the NEW conversation's message
  // bubble (the "new chat B answers with chat A's language/content" leak).
  //
  // Every new offline generation therefore:
  //   1. tears the previous native stream down first (stop + wait for its
  //      terminal ack, bounded), and
  //   2. accepts native events ONLY between its own `sendMessage` invoke and
  //      its terminal `onMessageComplete`.
  bool _isNativeStreamActive = false;
  Completer<void>? _staleStreamTeardown;
  bool _acceptingNativeEvents = false;

  // Repetition guard constants
  static const int _maxHistoryLength = 1024;
  static const int _chunkRepeatThreshold = 6; // More aggressive stop
  static const int _patternRepeatThreshold = 4;

  static const MethodChannel _llamaChannel =
      MethodChannel('com.vertex.cortex/llama');

  static const int _maxModelLoadRetries = 5;

  Completer<bool>? _modelLoadCompleter;
  Completer<bool>? _singleLoadAttemptCompleter;
  Timer? _retryTimer;

  /// Why the most recent load attempt failed. Drives both the retry policy
  /// and the (much stricter) auto-uninstall policy.
  _LoadFailureKind _lastLoadFailureKind = _LoadFailureKind.none;

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
      _lastLoadFailureKind = _LoadFailureKind.fileNotFound;
      await _autoRemoveSelectedOfflineModel();
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
    int ramMB = 4096;
    try {
      ramMB = await memoryChannel.invokeMethod<int>('getDeviceMemory') ?? 4096;
    } catch (e) {
      debugPrint("[OfflineService] Failed to getDeviceMemory for threads: $e");
    }
    final int nThreads = _computeOptimalThreads(ramMB);

    debugPrint(
        "[OfflineService] 🚀 Caching Model => ctx=$nCtx, gpu=$nGpu, threads=$nThreads (RAM: $ramMB MB)");

    _lastLoadFailureKind = _LoadFailureKind.none;

    try {
      for (var attempt = 1; attempt <= _maxModelLoadRetries; attempt++) {
        // Fallback to CPU-only on retry if GPU fails (vital for Simulators/older devices)
        int currentGpu = attempt == 1 ? nGpu : 0;

        loaded = await _runSingleModelLoadAttempt(
          path: path,
          nCtx: nCtx,
          nGpu: currentGpu,
          nThreads: nThreads,
          attempt: attempt,
        );
        if (loaded) break;

        await _safeReleaseNativeModel();
        _sessionProvider.setLocalModelLoaded(false);

        // Smart abort: deterministic failures never recover by retrying.
        final kind = _lastLoadFailureKind;
        if (kind == _LoadFailureKind.fileNotFound) {
          // The file is gone — every retry would hit the same wall.
          debugPrint(
              "[OfflineService] File not found — aborting retries immediately.");
          break;
        }
        if (kind == _LoadFailureKind.engineLoad && attempt >= 2) {
          // The native engine rejected the file (e.g. an architecture this
          // llama build doesn't know). We already tried the CPU-only
          // fallback; do not burn attempts 3-5 (and 15s timeouts each).
          debugPrint(
              "[OfflineService] Deterministic engine load failure — stopping retries after GPU and CPU-only attempts.");
          break;
        }

        if (attempt < _maxModelLoadRetries) {
          _retryTimer?.cancel();
          await _retryDelay(const Duration(milliseconds: 350));
        }
      }

      if (loaded) {
        _lastLoadFailureKind = _LoadFailureKind.none;
      } else {
        await _handleLoadFailureCleanup(path);
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
          _lastLoadFailureKind = _LoadFailureKind.timeout;
          debugPrint(
              "[OfflineService] Timeout while waiting for model load (attempt $attempt).");
          return false;
        },
      );
    } on PlatformException catch (e) {
      final String code = e.code;
      _lastLoadFailureKind = code == 'FILE_NOT_FOUND'
          ? _LoadFailureKind.fileNotFound
          : _LoadFailureKind.engineLoad;
      debugPrint(
          "[OfflineService] Failed to invoke 'cacheModel' (attempt $attempt, code: $code): ${e.message}");
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

  /// Decides what happens after the model failed to load.
  ///
  /// Auto-uninstall is ONLY justified when the file itself is unusable
  /// (missing or structurally corrupt). A structurally valid GGUF is NEVER
  /// deleted: the failure then belongs to the engine (stale llama build,
  /// memory pressure, ...), and destroying a valid multi-hundred-MB download
  /// — forcing the user to re-download it — is strictly worse than keeping
  /// it and telling the user what happened.
  Future<void> _handleLoadFailureCleanup(String path) async {
    final bool plausible = await _isDownloadedGgufPlausible(path);
    if (!plausible) {
      debugPrint(
          "[OfflineService] File missing/corrupt after load failure — auto-uninstalling model record.");
      await _autoRemoveSelectedOfflineModel();
      return;
    }
    debugPrint(
        "[OfflineService] Load failed (kind: ${_lastLoadFailureKind.name}) but the GGUF file at '$path' is structurally valid. KEEPING the file — refusing destructive auto-uninstall.");
  }

  /// Cheap structural validation of a downloaded GGUF:
  ///   1. Must exist and be non-trivially sized.
  ///   2. Must start with the GGUF magic bytes and a plausible version.
  ///   3. Actual file size must roughly match the catalog's expected size.
  ///
  /// Returns false only when the file is provably unusable. On any
  /// unexpected I/O error it returns true — never delete on uncertainty.
  Future<bool> _isDownloadedGgufPlausible(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return false;
      }
      final int length = await file.length();
      if (length < 1024) {
        return false;
      }

      final raf = await file.open(mode: FileMode.read);
      try {
        final magic = await raf.read(4);
        if (magic.length < 4) {
          return false;
        }
        // 'G', 'G', 'U', 'F'
        const ggufMagic = [0x47, 0x47, 0x55, 0x46];
        for (var i = 0; i < 4; i++) {
          if (magic[i] != ggufMagic[i]) {
            return false;
          }
        }

        final versionBytes = await raf.read(4);
        if (versionBytes.length == 4) {
          final int version = versionBytes[0] |
              (versionBytes[1] << 8) |
              (versionBytes[2] << 16) |
              (versionBytes[3] << 24);
          // GGUF v1 (legacy), v2 and v3 are the known-good versions.
          if (version < 1 || version > 3) {
            return false;
          }
        }
      } finally {
        await raf.close();
      }

      // Expected size from the catalog (in MB). A tolerant 15% window
      // covers decimal-MB vs MiB listing ambiguities.
      final int? expectedMB = _sessionProvider.selectedModel?.size;
      if (expectedMB != null && expectedMB > 0) {
        final int expectedBytes = expectedMB * 1024 * 1024;
        final double tolerance = expectedBytes * 0.15;
        if ((length - expectedBytes).abs() > tolerance) {
          debugPrint(
              "[OfflineService] Size mismatch: expected ~$expectedBytes bytes (catalog $expectedMB MB), got $length bytes.");
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint("[OfflineService] GGUF validation error (keeping file): $e");
      return true;
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
    // The native context is going away — no stream can be active afterwards.
    _isNativeStreamActive = false;
    _acceptingNativeEvents = false;
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

  Future<void> sendMessage(
    String text,
    String? photoPath, [
    ChatInputMode? activeMode,
    List<String> attachmentPaths = const [],
    bool ragEnabled = false,
    List<String> ragDocumentIds = const [],
    String? conversationId,
  ]) async {
    // CROSS-CONVERSATION ISOLATION: the previous native generation (possibly
    // still decoding for a conversation the user already left) must be dead
    // before this conversation may wait on the same channel. The teardown
    // also closes the token gate: from here on, only THIS generation's
    // native events are accepted (see [_acceptingNativeEvents]).
    await _teardownStaleNativeStream(
      conversationId != null
          ? "a new generation for conversation '$conversationId'"
          : 'a new generation',
    );

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
      _responseService.onMessageResponse(
          "[Error: The model file could not be found on this device. Please download the model again.]");
      _responseService.finalizeResponse();
      return;
    }

    final modelReady = await cacheModel(modelPath);
    if (!modelReady) {
      // Never fail silently: without a visible error the user would just see
      // an empty reply while the session quietly drifted back to Dynamic Chat.
      switch (_lastLoadFailureKind) {
        case _LoadFailureKind.fileNotFound:
          _responseService.onMessageResponse(
              "[Error: The model file was missing and has been removed from your library. Please download it again.]");
        case _LoadFailureKind.engineLoad:
          _responseService.onMessageResponse(
              "[Error: The on-device model could not be started. The model file was kept — updating the app, freeing up memory, or choosing another model may help.]");
        case _LoadFailureKind.timeout:
        case _LoadFailureKind.none:
          _responseService.onMessageResponse(
              "[Error: The on-device model did not respond in time. The model file was kept — please try again, or free up memory.]");
      }
      _responseService.finalizeResponse();
      return;
    }

    // Setup Processor (Stops formatting tokens)
    _currentProcessor = ChatFormatProcessor(
      model.chatFormat,
      onStopTokenDetected: stopGeneration,
    );
    _resetRepetitionGuardState();

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

    // Prepare Prompt
    final String finalPrompt = await _buildFormattedPrompt(
      model: model,
      latestMessage: text,
      enableThinkingMode: enableThinkingMode,
      langCode: langCode,
      ragContext: ragContext,
    );
    if (finalPrompt.isEmpty) {
      _responseService.finalizeResponse();
      return;
    }

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
    debugPrint(
        "[OfflineService] Sending Message with Samplers: T=${sampler.temperature}, P=${sampler.topP}, K=${sampler.topK}");

    // Note: We don't reset KV cache every turn necessarily if we want conversational memory,
    // but the current architecture might clear it on the native side.
    // If the native side clears KV on 'send', we should rely on that or manage it here.
    // The updated Native logic clears KV before generating to handle the FULL prompt we send (history included).
    // So we don't need to manually clear it here if native does it, but calling it ensures sync.
    // await _resetKvCache(); // Native code handles this now in 'send' flow based on the full prompt.

    final specArgs = _speculativeConfig.enabled
        ? _speculativeConfig.toNativeArgs()
        : <String, dynamic>{};

    await _llamaChannel.invokeMethod<void>(
      'sendMessage',
      {
        'message': finalPrompt,
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
        ...specArgs,
      },
    );

    // The native stream for THIS conversation is now live: open the event
    // gate. (Set after the invoke resolves so a failed invoke cannot leave
    // the gate open for a stream that never started.)
    _isNativeStreamActive = true;
    _acceptingNativeEvents = true;
    debugPrint(
        "[OfflineService] Native generation started: conversation=${conversationId ?? 'unknown'}, model=${model.id}, promptChars=${finalPrompt.length}, ragInjected=${ragContext != null && ragContext.isNotEmpty}.");
  }

  /// Tears down any native generation that is still decoding so the NEXT
  /// conversation's generation can own the channel exclusively.
  ///
  /// Stops the stale stream and waits (bounded) for its terminal
  /// `onMessageComplete` ack. While tearing down, the event gate is closed:
  /// the stale stream's remaining tokens are dropped and its completion is
  /// never forwarded to [ResponseService] — otherwise the abandoned
  /// conversation's completion would finalize the message of the NEW
  /// conversation that is about to start waiting.
  Future<void> _teardownStaleNativeStream(String reason) async {
    // Close the gate FIRST: from this instant, no native event of the
    // previous generation may reach the conversation provider.
    _acceptingNativeEvents = false;

    if (!_isNativeStreamActive) {
      // No live native stream (idle, or the previous generation already
      // completed normally) — nothing to stop or wait for.
      return;
    }

    final Completer<void> ack = Completer<void>();
    _staleStreamTeardown = ack;
    debugPrint('[OfflineService] Tearing down stale native stream before $reason.');

    try {
      await _llamaChannel.invokeMethod('stopGeneration');
    } catch (e) {
      debugPrint('[OfflineService] stopGeneration during teardown failed: $e');
    }

    try {
      await ack.future.timeout(const Duration(seconds: 2));
      debugPrint('[OfflineService] Stale stream acknowledged stop.');
    } on TimeoutException {
      debugPrint(
          '[OfflineService] WARNING: stale stream did not acknowledge stop within 2s; proceeding with the new generation anyway.');
    }

    _staleStreamTeardown = null;
    _isNativeStreamActive = false;
  }

  Future<void> stopGeneration() async {
    debugPrint("[OfflineService] Invoking 'stopGeneration'.");
    _retryTimer?.cancel();
    // The app is abandoning the current generation (stop button, chat
    // switch, or the SendService pre-kill that precedes a new exchange).
    // Close the event gate IMMEDIATELY: the dying stream's remaining tokens
    // — and its terminal completion — must never be routed into a
    // conversation that starts waiting afterwards (the cross-conversation
    // leak). The gate reopens only when the next generation is accepted.
    _acceptingNativeEvents = false;
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
    switch (call.method) {
      case 'onMessageResponse':
        final String rawToken = call.arguments as String? ?? '';
        if (rawToken.isEmpty) return;
        if (!_acceptingNativeEvents) {
          // Token from a generation that was torn down (or never accepted):
          // it belongs to a conversation that is no longer waiting — most
          // commonly one the user left while it was still decoding.
          debugPrint(
              '[OfflineService] Dropped native token from a previous conversation (len=${rawToken.length}).');
          return;
        }
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
        _isNativeStreamActive = false;
        if (!_acceptingNativeEvents) {
          // Terminal ack of a torn-down / unaccepted generation. Swallowing
          // it prevents the ABANDONED conversation's completion from
          // finalizing the thinking message of the conversation that is
          // currently waiting (which would otherwise lock in its mixed or
          // empty text and drop the real response).
          final Completer<void>? pendingAck = _staleStreamTeardown;
          if (pendingAck != null && !pendingAck.isCompleted) {
            pendingAck.complete();
          }
          debugPrint(
              '[OfflineService] Suppressed stale stream completion (previous conversation); nothing finalized.');
          return;
        }
        // This generation is finished — close the gate against any trailing
        // events before finalizing.
        _acceptingNativeEvents = false;
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
        // The native side sends {"code": ..., "message": ...}; older builds
        // sent a bare message string. Classify so the retry loop and the
        // uninstall policy can act on the true cause.
        String errorCode = 'LOAD_FAILED';
        String errorMessage = 'Unknown error';
        final args = call.arguments;
        if (args is Map) {
          errorCode = args['code'] as String? ?? 'LOAD_FAILED';
          errorMessage = args['message'] as String? ?? 'Unknown error';
        } else if (args is String) {
          errorMessage = args;
        }
        _lastLoadFailureKind = errorCode == 'FILE_NOT_FOUND'
            ? _LoadFailureKind.fileNotFound
            : _LoadFailureKind.engineLoad;
        debugPrint(
            "[OfflineService] Load Failed (code: $errorCode): $errorMessage");
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

  /// The single, neutral system prompt used for offline inference.
  ///
  /// Deliberately short: small on-device models (especially sub-1B) degrade
  /// with long persona/behavior directives, and locale-forcing instructions
  /// ("speak the device language") bias the reply language even when the user
  /// writes in another language. The model follows the user's language
  /// naturally from the conversation itself.
  static const String _offlineSystemPrompt =
      "You are a helpful AI assistant running inside Cortex, Türkiye's largest B2C AI platform.";

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
    // ONE short, neutral system prompt for every offline model (see
    // [_offlineSystemPrompt]). A curated `role` (a roleplay persona from the
    // catalog) is the only exception: it is the model's identity, so it takes
    // precedence when the catalog defines one. No locale-forcing directives —
    // the model should follow the user's language from the conversation.
    final String role = (model.role ?? '').trim();
    final String systemPrompt = role.isNotEmpty ? role : _offlineSystemPrompt;

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
    );

    // Composition log (counts only — never message contents) so cross-
    // conversation leakage can be verified from logs: a brand-new chat MUST
    // show historyMessages=0, a same-chat follow-up MUST show its own turns.
    int historyUserCount = 0;
    int historyAssistantCount = 0;

    for (final msg in history) {
      final role = msg['role'];
      final content = _extractVisibleText(msg['content']);
      if (content.isEmpty) continue;

      if (role == 'user') {
        historyUserCount++;
        _appendTurn(sb,
            start: effectiveTokens.userStart ?? '',
            end: effectiveTokens.userEnd,
            content: content);
      } else if (role == 'assistant') {
        historyAssistantCount++;
        _appendTurn(sb,
            start: effectiveTokens.assistantStart ?? '',
            end: effectiveTokens.assistantEnd,
            content: content);
      }
    }

    debugPrint(
        '[OfflineService] Prompt composition for model ${model.id}: system=${systemPrompt.isEmpty ? 0 : 1}, '
        'historyMessages=${history.length} (user=$historyUserCount, assistant=$historyAssistantCount), '
        'latestUser=1, ragInjected=${ragContext?.isNotEmpty ?? false}, '
        'chatFormatProvided=${format != null}.');

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

    debugPrint(
        '[OfflineService] Final offline prompt: promptChars=${sb.length}.');
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
