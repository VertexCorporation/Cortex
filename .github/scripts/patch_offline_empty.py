from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(
            f"{path}: expected one match, found {count}: {old[:120]!r}"
        )
    p.write_text(text.replace(old, new, 1))


# 1) Never finalize a zero-content response as a normal assistant turn.
replace_once(
    "lib/chat/services/response.dart",
    "  void finalizeResponse() {\n",
    "  void finalizeResponse({String? emptyResponseError}) {\n",
)
replace_once(
    "lib/chat/services/response.dart",
    """    if (targetIndex != -1) {
      // The `finishBotResponse` method within the provider handles all necessary state changes:
""",
    """    if (targetIndex != -1) {
      final targetMessage = messages[targetIndex];
      final emptyResponse = targetMessage.displayableText.trim().isEmpty &&
          !targetMessage.hasAttachments;
      if (emptyResponse &&
          emptyResponseError != null &&
          emptyResponseError.trim().isNotEmpty) {
        debugPrint(
            "[ResponseService] Native stream completed without visible output. Converting placeholder to an error instead of persisting a ghost reply.");
        _conversationProvider.setErrorMessage(
          targetIndex,
          emptyResponseError,
          false,
        );
        return;
      }

      // The `finishBotResponse` method within the provider handles all necessary state changes:
""",
)

# 2) Completed empty assistant rows must not render header/options UI.
replace_once(
    "lib/chat/screen/widgets/tiles.dart",
    """    final bool showContent = hasText ||
        message.isThinking ||
        message.hasAttachments ||
        hasShimmer ||
        !message.isError;
""",
    """    final bool showContent = hasText ||
        message.isThinking ||
        message.hasAttachments ||
        hasShimmer ||
        message.isError ||
        message.toolActivity.isNotEmpty ||
        message.toolSteps.isNotEmpty ||
        message.isIncomplete;
""",
)

# 3) Give the offline stream localized failure copy for a genuine zero-token completion.
replace_once(
    "lib/chat/services/send.dart",
    """            _inputProvider.ragDocumentIds,
            targetConvId,
          );
""",
    """            _inputProvider.ragDocumentIds,
            targetConvId,
            localizations.requestFailed,
          );
""",
)

# 4) Buffer native events that arrive during the MethodChannel launch window.
replace_once(
    "lib/chat/services/offline.dart",
    """  bool _isNativeStreamActive = false;
  Completer<void>? _staleStreamTeardown;
  bool _acceptingNativeEvents = false;
""",
    """  bool _isNativeStreamActive = false;
  Completer<void>? _staleStreamTeardown;
  bool _acceptingNativeEvents = false;

  // Very fast sub-1B models can emit their first token (or even complete)
  // while MethodChannel.sendMessage is still returning to Dart. Buffer only
  // that launch window. Teardown events remain rejected because the launch
  // flag is enabled only immediately around the new send invocation.
  bool _isLaunchingNativeStream = false;
  final List<String> _launchBufferedTokens = <String>[];
  bool _launchBufferedCompletion = false;
  bool _didEmitVisibleOutput = false;
  String? _emptyResponseError;
""",
)

replace_once(
    "lib/chat/services/offline.dart",
    """    ChatInputMode? activeMode,
    List<String> attachmentPaths = const [],
    bool ragEnabled = false,
    List<String> ragDocumentIds = const [],
    String? conversationId,
  ]) async {
""",
    """    ChatInputMode? activeMode,
    List<String> attachmentPaths = const [],
    bool ragEnabled = false,
    List<String> ragDocumentIds = const [],
    String? conversationId,
    String? emptyResponseError,
  ]) async {
""",
)

replace_once(
    "lib/chat/services/offline.dart",
    """    await _teardownStaleNativeStream(
      conversationId != null
          ? "a new generation for conversation '$conversationId'"
          : 'a new generation',
    );

    final String? modelId = _sessionProvider.modelId;
""",
    """    await _teardownStaleNativeStream(
      conversationId != null
          ? "a new generation for conversation '$conversationId'"
          : 'a new generation',
    );
    _didEmitVisibleOutput = false;
    _emptyResponseError = emptyResponseError;

    final String? modelId = _sessionProvider.modelId;
""",
)

replace_once(
    "lib/chat/services/offline.dart",
    """    _currentProcessor = ChatFormatProcessor(
      model.chatFormat,
      onStopTokenDetected: stopGeneration,
    );
""",
    """    _currentProcessor = ChatFormatProcessor(
      model.chatFormat,
      // A model-emitted stop marker belongs to the current generation. Ask
      // native code to stop without closing the event gate: its terminal
      // completion still needs to finalize this exact response.
      onStopTokenDetected: () {
        unawaited(_requestNativeStopForControlToken());
      },
    );
""",
)

old_invoke = """    await _llamaChannel.invokeMethod<void>(
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
"""
new_invoke = """    final nativeArgs = <String, dynamic>{
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
    };

    _isLaunchingNativeStream = true;
    _launchBufferedTokens.clear();
    _launchBufferedCompletion = false;
    try {
      await _llamaChannel.invokeMethod<void>('sendMessage', nativeArgs);

      // A user stop can cancel while invokeMethod is still in flight. Never
      // reopen the event gate after such a cancellation.
      if (!_isLaunchingNativeStream) {
        return;
      }

      _isNativeStreamActive = true;
      _acceptingNativeEvents = true;
      _isLaunchingNativeStream = false;

      final earlyTokens = List<String>.from(_launchBufferedTokens);
      final earlyCompletion = _launchBufferedCompletion;
      _launchBufferedTokens.clear();
      _launchBufferedCompletion = false;

      for (final token in earlyTokens) {
        _handleAcceptedNativeToken(token);
      }
      if (earlyCompletion) {
        await _handleAcceptedNativeCompletion();
      }
    } catch (_) {
      _isLaunchingNativeStream = false;
      _launchBufferedTokens.clear();
      _launchBufferedCompletion = false;
      _acceptingNativeEvents = false;
      _isNativeStreamActive = false;
      rethrow;
    }

    debugPrint(
        "[OfflineService] Native generation started: conversation=${conversationId ?? 'unknown'}, model=${model.id}, promptChars=${finalPrompt.length}, ragInjected=${ragContext != null && ragContext.isNotEmpty}.");
"""
replace_once("lib/chat/services/offline.dart", old_invoke, new_invoke)

replace_once(
    "lib/chat/services/offline.dart",
    """  Future<void> stopGeneration() async {
    debugPrint("[OfflineService] Invoking 'stopGeneration'.");
    _retryTimer?.cancel();
""",
    """  Future<void> _requestNativeStopForControlToken() async {
    try {
      await _llamaChannel.invokeMethod('stopGeneration');
    } catch (e) {
      debugPrint(
          "[OfflineService] Native stop after model control token failed: $e");
    }
  }

  Future<void> stopGeneration() async {
    debugPrint("[OfflineService] Invoking 'stopGeneration'.");
    _retryTimer?.cancel();
    _isLaunchingNativeStream = false;
    _launchBufferedTokens.clear();
    _launchBufferedCompletion = false;
""",
)

old_handler = """      case 'onMessageResponse':
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
"""
new_handler = """      case 'onMessageResponse':
        final String rawToken = call.arguments as String? ?? '';
        if (rawToken.isEmpty) return;
        if (!_acceptingNativeEvents && _isLaunchingNativeStream) {
          _launchBufferedTokens.add(rawToken);
          debugPrint(
              '[OfflineService] Buffered token that arrived during native launch (len=${rawToken.length}).');
          return;
        }
        if (!_acceptingNativeEvents) {
          // Token from a generation that was torn down (or never accepted):
          // it belongs to a conversation that is no longer waiting — most
          // commonly one the user left while it was still decoding.
          debugPrint(
              '[OfflineService] Dropped native token from a previous conversation (len=${rawToken.length}).');
          return;
        }
        _handleAcceptedNativeToken(rawToken);
        break;

      case 'onMessageComplete':
        if (!_acceptingNativeEvents && _isLaunchingNativeStream) {
          _launchBufferedCompletion = true;
          debugPrint(
              '[OfflineService] Buffered completion that arrived during native launch.');
          return;
        }
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
        await _handleAcceptedNativeCompletion();
        break;
"""
replace_once("lib/chat/services/offline.dart", old_handler, new_handler)

replace_once(
    "lib/chat/services/offline.dart",
    """  // ===========================================================================
  // Native Handler
  // ===========================================================================
""",
    """  void _handleAcceptedNativeToken(String rawToken) {
    if (_forceAbortCurrentStream || rawToken.isEmpty) return;

    final processor = _currentProcessor;
    if (processor == null) {
      if (_shouldAbortForRepetition(rawToken)) {
        _handleRepetitionAbort();
      } else {
        _didEmitVisibleOutput = true;
        _responseService.onMessageResponse(rawToken);
      }
      return;
    }

    final String? processedToken = processor.processToken(rawToken);
    if (processedToken == null || processedToken.isEmpty) return;
    if (_shouldAbortForRepetition(processedToken)) {
      _handleRepetitionAbort();
      return;
    }

    _didEmitVisibleOutput = true;
    _responseService.onMessageResponse(processedToken);
  }

  Future<void> _handleAcceptedNativeCompletion() async {
    _isNativeStreamActive = false;
    _acceptingNativeEvents = false;
    debugPrint("[OfflineService] Complete.");

    final tail = _currentProcessor?.finalize();
    if (tail != null && tail.isNotEmpty) {
      _didEmitVisibleOutput = true;
      _responseService.onMessageResponse(tail);
    }

    _responseService.finalizeResponse(
      emptyResponseError: _didEmitVisibleOutput ? null : _emptyResponseError,
    );
    _currentProcessor = null;
    _emptyResponseError = null;
    _didEmitVisibleOutput = false;
  }

  // ===========================================================================
  // Native Handler
  // ===========================================================================
""",
)

# 5) Regression harness: make native output arrive synchronously during invokeMethod.
replace_once(
    "test/offline_context_isolation_test.dart",
    """      if (call.method == 'sendMessage') {
        final args = call.arguments as Map;
        prompts.add(args['message'] as String);
      } else if (call.method == 'stopGeneration') {
""",
    """      if (call.method == 'sendMessage') {
        final args = call.arguments as Map;
        prompts.add(args['message'] as String);
        final earlyToken = synchronousTokenOnSend;
        if (earlyToken != null) {
          await offline.methodCallHandler(
              MethodCall('onMessageResponse', earlyToken));
        }
        if (synchronousCompleteOnSend) {
          await offline.methodCallHandler(const MethodCall('onMessageComplete'));
        }
      } else if (call.method == 'stopGeneration') {
""",
)
replace_once(
    "test/offline_context_isolation_test.dart",
    """  final List<String> calls = [];
  final List<String> prompts = [];

  Future<void> deliverToken(String token) async {
""",
    """  final List<String> calls = [];
  final List<String> prompts = [];
  String? synchronousTokenOnSend;
  bool synchronousCompleteOnSend = false;

  Future<void> deliverToken(String token) async {
""",
)

marker = "  group('offline prompt scoping (per-conversation context)', () {\n"
new_tests = r'''  group('offline launch window and empty response recovery', () {
    test('token and completion emitted before invokeMethod returns are replayed',
        () async {
      final h = _Harness()
        ..synchronousTokenOnSend = 'Hello from Qwen.'
        ..synchronousCompleteOnSend = true;

      await h.conversation.startNewConversationSession(
        'convFast',
        'Fast local model',
        'qwen3-06b',
        Message(text: 'Hello', isUserMessage: true),
      );
      await h.offline.sendMessage(
        'Hello',
        null,
        null,
        [],
        false,
        [],
        'convFast',
        'Please try again.',
      );

      final answer = h.conversation.messages.last;
      expect(answer.text, 'Hello from Qwen.');
      expect(answer.isThinking, isFalse);
      expect(answer.isError, isFalse);
      expect(h.conversation.isWaitingForResponse, isFalse);
    });

    test('zero-token completion becomes an error, never a ghost assistant row',
        () async {
      final h = _Harness()..synchronousCompleteOnSend = true;

      await h.conversation.startNewConversationSession(
        'convEmpty',
        'Empty local response',
        'qwen3-06b',
        Message(text: 'alo', isUserMessage: true),
      );
      await h.offline.sendMessage(
        'alo',
        null,
        null,
        [],
        false,
        [],
        'convEmpty',
        'The model did not generate a response. Please try again.',
      );

      final answer = h.conversation.messages.last;
      expect(
        answer.text,
        'The model did not generate a response. Please try again.',
      );
      expect(answer.isThinking, isFalse);
      expect(answer.isError, isTrue);
      expect(answer.includeInContext, isFalse);
      expect(h.conversation.isWaitingForResponse, isFalse);
    });
  });

'''
replace_once(
    "test/offline_context_isolation_test.dart",
    marker,
    new_tests + marker,
)
