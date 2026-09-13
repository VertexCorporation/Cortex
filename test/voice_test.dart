// test/voice_test.dart
//
// VOICE/Flow LIFECYCLE INVARIANTS. The mocks simulate the engines; every
// test asserts an invariant that must hold under adversarial input:
//   * one session, one microphone, one callback set — ever;
//   * start/stop are idempotent under rapid repeated calls;
//   * stale callbacks from a dead session never mutate its successor;
//   * the continuous-session model never re-mints between turns;
//   * interrupted speech never resumes;
//   * reconnects are bounded;
//   * the server's allowance numbers are the ones the UI shows.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/stt_remote.dart';
import 'package:flutter_tts/flutter_tts.dart';

// --- Mocks ---

class MockSpeechService extends SpeechService {
  int startCount = 0;
  int stopCount = 0;
  bool shouldFailStart = false;
  bool _listening = false;
  double level = 0.0;
  bool remoteActive = false;
  bool micLive = false;
  bool shouldSucceedReconnect = true;
  int reconnectSocketCount = 0;

  Function(String text)? onResultCallback;
  void Function(SttCloseInfo info)? onClosedCallback;
  void Function(SttLease lease)? onLeaseCallback;
  void Function(SttResult result)? onSttResultCallback;
  SpeechOwner? lastOwner;

  @override
  bool get isListening => _listening;
  @override
  bool get isRemoteActive => remoteActive;
  @override
  double get soundLevel => level;
  @override
  bool get isRemoteSocketReconnectable => remoteActive && micLive;

  @override
  Future<bool> startListening({
    required String locale,
    required Function(String text) onResult,
    SpeechOwner owner = SpeechOwner.dictation,
    void Function(SttCloseInfo info)? onClosed,
    void Function(SttLease lease)? onLease,
    void Function(SttResult result)? onSttResult,
  }) async {
    startCount++;
    lastOwner = owner;
    onClosedCallback = onClosed;
    onLeaseCallback = onLease;
    onSttResultCallback = onSttResult;
    if (shouldFailStart) return false;
    _listening = true;
    onResultCallback = onResult;
    return true;
  }

  @override
  Future<void> stopListening() async {
    stopCount++;
    _listening = false;
    micLive = false;
  }

  @override
  Future<bool> reconnectRemoteSocket() async {
    reconnectSocketCount++;
    if (!shouldSucceedReconnect) return false;
    return remoteActive && micLive;
  }

  void emit(String text) => onResultCallback?.call(text);

  void emitStructured(SttResult result) {
    onSttResultCallback?.call(result);
    onResultCallback?.call(result.text);
  }

  void emitClose(SttCloseInfo info) => onClosedCallback?.call(info);
}

class MockFlutterTts extends FlutterTts {
  String? lastSpokenText;
  VoidCallback? _startHandler;
  VoidCallback? _completionHandler;
  bool isSpeakingMock = false;

  @override
  Future<dynamic> setSharedInstance(bool? shared) async => 1;

  @override
  Future<dynamic> setIosAudioCategory(
    IosTextToSpeechAudioCategory category,
    List<IosTextToSpeechAudioCategoryOptions> options, [
    IosTextToSpeechAudioMode mode = IosTextToSpeechAudioMode.defaultMode,
  ]) async => 1;

  @override
  Future<dynamic> awaitSpeakCompletion(bool? awaitCompletion) async => 1;

  @override
  Future<dynamic> setLanguage(String language) async => 1;

  @override
  void setStartHandler(VoidCallback callback) {
    _startHandler = callback;
  }

  @override
  void setCompletionHandler(VoidCallback callback) {
    _completionHandler = callback;
  }

  @override
  void setErrorHandler(Function(dynamic) handler) {}

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    lastSpokenText = text;
    isSpeakingMock = true;
    if (_startHandler != null) _startHandler!();

    // Auto-complete immediately for testing logic flow
    Future.microtask(() {
      isSpeakingMock = false;
      if (_completionHandler != null) _completionHandler!();
    });
    return 1;
  }

  @override
  Future<dynamic> stop() async {
    isSpeakingMock = false;
    return 1;
  }
}

void main() {
  late MockSpeechService mockSpeechService;
  late MockFlutterTts mockFlutterTts;
  late VoiceService voiceService;
  List<String> submittedTurns = [];

  // Deterministic clock for the barge-in windows: tests advance it
  // explicitly instead of sleeping real milliseconds.
  late DateTime fakeNow;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    // Mock the channel used by FlutterTts
    const MethodChannel channel = MethodChannel('flutter_tts');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return 1;
        });

    submittedTurns = [];
    fakeNow = DateTime(2026, 1, 1, 12, 0, 0);
    mockSpeechService = MockSpeechService();
    mockFlutterTts = MockFlutterTts();

    // Zero reconnect backoff: lifecycle tests exercise the policy, not the
    // wall-clock timing (the backoff policy itself is tested separately).
    voiceService = VoiceService(
      speechService: mockSpeechService,
      flutterTts: mockFlutterTts,
      clock: () => fakeNow,
      reconnectBackoff: (_, _) => Duration.zero,
    );
  });

  tearDown(() async {
    await voiceService.stopSession();
    voiceService.dispose();
  });

  Future<void> startTestSession() async {
    await voiceService.startSession(
      locale: 'en-US',
      onFinalSentence: (text) => submittedTurns.add(text),
    );
  }

  test('Initial state is idle and no session exists', () {
    expect(voiceService.state, VoiceState.idle);
    expect(voiceService.isSessionActive, false);
    expect(voiceService.lastEndReason, isNull);
  });

  test(
    'rapid repeated startSession creates exactly ONE active session',
    () async {
      await startTestSession();
      await startTestSession();
      await startTestSession();
      expect(
        mockSpeechService.startCount,
        1,
        reason: 'a second startSession while active must be a no-op',
      );
      expect(voiceService.isSessionActive, true);
      expect(voiceService.state, VoiceState.listening);
      expect(
        mockSpeechService.lastOwner,
        SpeechOwner.voice,
        reason: 'voice mode captures the mic as the voice owner',
      );
    },
  );

  test(
    'rapid repeated stopSession is safe and always releases the microphone',
    () async {
      await startTestSession();
      await voiceService.stopSession();
      await voiceService.stopSession();
      await voiceService.stopSession();
      expect(voiceService.isSessionActive, false);
      expect(voiceService.state, VoiceState.idle);
      expect(mockSpeechService.isListening, false);
      expect(mockSpeechService.stopCount, greaterThanOrEqualTo(1));
      expect(mockFlutterTts.isSpeakingMock, false);
    },
  );

  test(
    'start/stop/start: a stale STT result from the dead session is dropped',
    () async {
      await startTestSession();
      final staleResult = mockSpeechService.onResultCallback;
      await voiceService.stopSession();

      await startTestSession();
      // The old session's callback fires late (an in-flight provider frame).
      // It must not feed the new session or submit a turn.
      staleResult?.call('Stale words from the previous session.');
      await Future<void>.delayed(Duration.zero);

      expect(
        voiceService.hasRecognizedText,
        false,
        reason: 'stale results must not mutate the new session',
      );
      expect(voiceService.liveTranscript, '');
      expect(submittedTurns, isEmpty);
    },
  );

  test('silence-timer finalization submits the turn exactly once and keeps the provider session open (continuous model)', () async {
    await startTestSession();
    final engineRestartsBefore = mockSpeechService.startCount;
    final engineStopsBefore = mockSpeechService.stopCount;

    mockSpeechService.emit('Hello world');
    expect(voiceService.liveTranscript, 'Hello world');

    // The silence timer (2s) finalizes the turn.
    await Future<void>.delayed(const Duration(milliseconds: 2500));

    expect(submittedTurns, ['Hello world']);
    expect(voiceService.state, VoiceState.processing);
    expect(
      mockSpeechService.stopCount,
      engineStopsBefore,
      reason: 'the continuous model never stops the engine between turns',
    );
    expect(
      mockSpeechService.startCount,
      engineRestartsBefore,
      reason: 'the continuous model never re-mints between turns',
    );
  });

  test(
    'a session whose engines cannot start ends as failed, not stuck',
    () async {
      mockSpeechService.shouldFailStart = true;
      await voiceService.startSession(
        locale: 'en-US',
        onFinalSentence: (text) => submittedTurns.add(text),
      );
      expect(voiceService.isSessionActive, false);
      expect(voiceService.state, VoiceState.failed);
      expect(voiceService.lastEndReason, VoiceEndReason.error);
    },
  );

  test('Speaking logic queues sentences correctly', () async {
    await startTestSession();

    voiceService.onAiStreamCallback("Hello world");
    // No delimiter yet — nothing speaks.
    expect(mockFlutterTts.lastSpokenText, isNull);

    voiceService.onAiStreamCallback(". ");
    await Future<void>.delayed(Duration.zero);
    expect(mockFlutterTts.lastSpokenText, "Hello world.");

    voiceService.onAiStreamCallback("How are you?");
    await Future<void>.delayed(Duration.zero);
    expect(mockFlutterTts.lastSpokenText, "How are you?");

    voiceService.onAiResponseFinished();
    await Future<void>.delayed(Duration.zero);
    expect(mockFlutterTts.lastSpokenText, "How are you?");
  });

  test(
    'VoiceService resumes listening after AI finishes without re-minting',
    () async {
      await startTestSession();
      await voiceService.stopSession(); // Reset

      await startTestSession();
      final engineStarts = mockSpeechService.startCount;

      voiceService.onAiStreamCallback("Hello.");
      await Future<void>.delayed(Duration.zero);

      voiceService.onAiResponseFinished();

      // Wait for the 500ms resume delay.
      await Future<void>.delayed(const Duration(milliseconds: 600));

      expect(voiceService.state, VoiceState.listening);
      expect(mockSpeechService.isListening, true);
      expect(
        mockSpeechService.startCount,
        engineStarts,
        reason: 'the remote session is continuous — resume must not re-mint',
      );
    },
  );

  test(
    'TTS interruption generation: an interrupted queue never resumes',
    () async {
      await startTestSession();

      voiceService.onAiStreamCallback("First sentence.");
      await Future<void>.delayed(Duration.zero);
      expect(mockFlutterTts.lastSpokenText, "First sentence.");

      voiceService.onAiStreamCallback("Second sentence.");
      // Interrupt immediately: the queued sentence is invalidated before its
      // synthesis lands.
      voiceService.stopSpeaking();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        mockFlutterTts.lastSpokenText,
        "First sentence.",
        reason: 'the interrupted sentence must never play later',
      );
      expect(voiceService.state, VoiceState.listening);
    },
  );

  test('barge-in: confident, non-echo speech during playback cuts audio and returns to listening', () async {
    await startTestSession();

    voiceService.onAiStreamCallback("The assistant is talking.");
    await Future<void>.delayed(Duration.zero);
    expect(voiceService.state, VoiceState.speaking);

    // Simulate the remote mic still open during playback (never muted): a
    // CONFIDENT multi-word transcript arrives that is NOT what the assistant
    // is saying, plus voice amplitude sustained past the 300 ms window.
    // The clock moves past the post-TTS echo window first: genuine user
    // speech never arrives inside the 250ms tail window.
    mockSpeechService.remoteActive = true;
    fakeNow = fakeNow.add(const Duration(milliseconds: 300));
    mockSpeechService.emitStructured(
      const SttResult('stop that please', isFinal: true, confidence: 0.9),
    );

    mockSpeechService.level = 0.8;
    mockSpeechService.notifyListeners();
    fakeNow = fakeNow.add(const Duration(milliseconds: 350));
    mockSpeechService.notifyListeners();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(
      voiceService.state,
      VoiceState.listening,
      reason: 'barge-in must immediately return to listening',
    );
    expect(
      mockFlutterTts.lastSpokenText,
      "The assistant is talking.",
      reason: 'no new audio may start after the interruption',
    );
    expect(
      mockSpeechService.stopCount,
      0,
      reason: 'the microphone capture is never torn down for barge-in',
    );
  });

  test('barge-in echo gate: the assistant\'s own words transcribing back never interrupt', () async {
    await startTestSession();

    voiceService.onAiStreamCallback("The capital of France is Paris.");
    await Future<void>.delayed(Duration.zero);
    expect(voiceService.state, VoiceState.speaking);

    // Speaker bleed: the assistant's own sentence, confidently transcribed
    // by the still-open mic, with loud amplitude sustained past the window.
    // The clock moves past the post-TTS echo window so the ECHO GATE is the
    // gate that rejects this, not the timing window.
    mockSpeechService.remoteActive = true;
    fakeNow = fakeNow.add(const Duration(milliseconds: 300));
    mockSpeechService.emitStructured(
      const SttResult(
        'the capital of France is Paris',
        isFinal: true,
        confidence: 0.95,
      ),
    );

    mockSpeechService.level = 0.8;
    mockSpeechService.notifyListeners();
    fakeNow = fakeNow.add(const Duration(milliseconds: 400));
    mockSpeechService.notifyListeners();
    await Future<void>.delayed(Duration.zero);

    expect(
      voiceService.state,
      VoiceState.speaking,
      reason: 'echo of the assistant may never barge in',
    );
    expect(mockFlutterTts.isSpeakingMock, false);
  });

  test(
    'low-confidence and single-word transcripts are not barge-in evidence',
    () async {
      await startTestSession();

      voiceService.onAiStreamCallback("I am explaining something long.");
      await Future<void>.delayed(Duration.zero);
      expect(voiceService.state, VoiceState.speaking);

      mockSpeechService.remoteActive = true;
      fakeNow = fakeNow.add(const Duration(milliseconds: 300));
      // Low confidence: the provider itself is unsure of these words.
      mockSpeechService.emitStructured(
        const SttResult('stop talking now', isFinal: true, confidence: 0.4),
      );
      // Single word: too little to be a user turn.
      mockSpeechService.emitStructured(
        const SttResult('hey', isFinal: true, confidence: 0.95),
      );

      mockSpeechService.level = 0.8;
      mockSpeechService.notifyListeners();
      fakeNow = fakeNow.add(const Duration(milliseconds: 400));
      mockSpeechService.notifyListeners();
      await Future<void>.delayed(Duration.zero);

      expect(
        voiceService.state,
        VoiceState.speaking,
        reason: 'neither weak-confidence nor single-word frames may barge in',
      );
    },
  );

  test('provider socket loss reconnects the SOCKET only — microphone preserved — bounded per session', () async {
    await startTestSession();
    // The remote capture is live: socket up, microphone streaming.
    mockSpeechService.remoteActive = true;
    mockSpeechService.micLive = true;
    final startsBefore = mockSpeechService.startCount;
    final stopsBefore = mockSpeechService.stopCount;

    const close = SttCloseInfo(
      provider: 'deepgram',
      closeClass: SttCloseClass.reconnect,
    );

    // The socket closes on its own three times: the session reconnects the
    // socket ALONE each time under the SAME generation — the microphone
    // and its callback set are never touched.
    mockSpeechService.emitClose(close);
    await Future<void>.delayed(Duration.zero);
    mockSpeechService.emitClose(close);
    await Future<void>.delayed(Duration.zero);
    mockSpeechService.emitClose(close);
    await Future<void>.delayed(Duration.zero);

    expect(mockSpeechService.reconnectSocketCount, 3);
    expect(
      mockSpeechService.startCount,
      startsBefore,
      reason: 'a socket-only reconnect never re-opens the capture',
    );
    expect(
      mockSpeechService.stopCount,
      stopsBefore,
      reason: 'a socket-only reconnect never tears the microphone down',
    );
    expect(voiceService.isSessionActive, true);
    expect(voiceService.state, VoiceState.listening);

    // The fourth close exceeds the per-session budget while still
    // listening: the session fails instead of looping forever.
    mockSpeechService.emitClose(close);
    await Future<void>.delayed(Duration.zero);
    expect(voiceService.isSessionActive, false);
    expect(voiceService.state, VoiceState.failed);
    expect(voiceService.lastEndReason, VoiceEndReason.error);
  });

  test('a fatal provider close (1002) ends the session without a single reconnect attempt', () async {
    await startTestSession();
    mockSpeechService.remoteActive = true;
    mockSpeechService.micLive = true;
    final startsBefore = mockSpeechService.startCount;

    mockSpeechService.emitClose(
      const SttCloseInfo(
        provider: 'deepgram',
        closeCode: 1002,
        closeClass: SttCloseClass.fatal,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      mockSpeechService.reconnectSocketCount,
      0,
      reason: 'a protocol error must not burn the reconnect budget',
    );
    expect(
      mockSpeechService.startCount,
      startsBefore,
      reason: 'no engine restart either',
    );
    expect(voiceService.isSessionActive, false);
    expect(voiceService.state, VoiceState.failed);
    expect(voiceService.lastEndReason, VoiceEndReason.error);
  });

  test(
    'socket loss without a live microphone falls back to a full engine restart',
    () async {
      await startTestSession();
      // Remote capture dead (socket AND mic gone — e.g. mic error path).
      mockSpeechService.remoteActive = false;
      mockSpeechService.micLive = false;
      final startsBefore = mockSpeechService.startCount;

      mockSpeechService.emitClose(
        const SttCloseInfo(
          provider: 'deepgram',
          closeClass: SttCloseClass.reconnect,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(
        mockSpeechService.startCount,
        startsBefore + 1,
        reason: 'with no mic to preserve, the full engine restart is used',
      );
      expect(voiceService.isSessionActive, true);
      expect(voiceService.state, VoiceState.listening);
    },
  );

  test(
    'the server lease publishes the authoritative allowance numbers',
    () async {
      await startTestSession();
      mockSpeechService.onLeaseCallback?.call(
        const SttLease(
          provider: 'deepgram',
          sessionId: 'sess-1',
          allowanceVoiceSeconds: 120,
          remainingVoiceSeconds: 30,
          reservedVoiceSeconds: 120,
        ),
      );

      expect(voiceService.voiceAllowanceSeconds, 120);
      expect(voiceService.remainingVoiceSeconds, 30);
      expect(voiceService.voiceWindowSeconds, 120);
    },
  );

  test(
    'Flow Mode submits its hidden prompt under the same session identity',
    () async {
      await startTestSession();
      voiceService.setFlowMode(true);
      voiceService.startFlowWithPrompt('Begin the discussion.');

      expect(submittedTurns, ['Begin the discussion.']);
      expect(voiceService.isFlowActive, true);
      expect(
        voiceService.isSessionActive,
        true,
        reason: 'flow shares the voice session core',
      );
      expect(voiceService.state, VoiceState.processing);
    },
  );

  test('a double completion schedules exactly ONE flow rotation (no orphaned timer)', () async {
    await startTestSession();
    voiceService.setFlowMode(true);
    voiceService.isFlowActive = true;
    // Response text with no sentence delimiter: buffered, never spoken.
    voiceService.onAiStreamCallback('agent zero is speaking');
    await Future<void>.delayed(Duration.zero);

    // The generation completes twice in a row: only the LAST rotation
    // timer may survive — an orphaned timer would still fire and
    // double-advance the agents.
    voiceService.setAiGenerationComplete(true);
    voiceService.setAiGenerationComplete(true);

    expect(
      voiceService.currentFlowAgentIndex,
      0,
      reason: 'rotation is deferred to the 800ms boundary',
    );

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    expect(
      voiceService.currentFlowAgentIndex,
      1,
      reason: 'exactly one rotation may run for a double completion',
    );
    expect(submittedTurns, ['agent zero is speaking']);
  });

  test(
    'stopSession deterministically cancels a pending flow rotation',
    () async {
      await startTestSession();
      voiceService.setFlowMode(true);
      voiceService.isFlowActive = true;
      voiceService.onAiStreamCallback('next agent go');
      await Future<void>.delayed(Duration.zero);

      // Rotation timer is pending; the session ends BEFORE it fires.
      voiceService.setAiGenerationComplete(true);
      await voiceService.stopSession();

      await Future<void>.delayed(const Duration(milliseconds: 1200));

      expect(voiceService.isSessionActive, false);
      expect(voiceService.isFlowActive, false);
      expect(
        submittedTurns,
        isEmpty,
        reason: 'a stopped session may never submit a flow turn',
      );
    },
  );

  group('provider close classification (documented Deepgram close frames)', () {
    test('1011 with NET codes maps to the documented policies', () {
      // 1011/NET-0000: server-side fault → normal reconnect.
      expect(
        SttCloseInfo.classify(
          provider: 'deepgram',
          closeCode: 1011,
          msgCode: 'NET-0000',
        ),
        SttCloseClass.reconnect,
      );
      // 1011/NET-0001: the client went silent → retry fast.
      expect(
        SttCloseInfo.classify(
          provider: 'deepgram',
          closeCode: 1011,
          msgCode: 'NET-0001',
        ),
        SttCloseClass.reconnectImmediate,
      );
      // 1011/NET-0002: no-audio idle timeout → extended backoff.
      expect(
        SttCloseInfo.classify(
          provider: 'deepgram',
          closeCode: 1011,
          msgCode: 'NET-0002',
        ),
        SttCloseClass.reconnectExtended,
      );
    });

    test('NET-0002 is also recognized from the close reason alone', () {
      // The Error message does not always make it before the close frame;
      // the documented close reason carries `no_audio_timeout`.
      expect(
        SttCloseInfo.classify(
          provider: 'deepgram',
          closeCode: 1011,
          closeReason: 'Connection closed: no_audio_timeout',
        ),
        SttCloseClass.reconnectExtended,
      );
    });

    test('1002 and 1008 are fatal; unknown closes stay reconnectable', () {
      expect(
        SttCloseInfo.classify(provider: 'deepgram', closeCode: 1002),
        SttCloseClass.fatal,
        reason: 'protocol error: retrying the same stream cannot succeed',
      );
      expect(
        SttCloseInfo.classify(provider: 'deepgram', closeCode: 1008),
        SttCloseClass.fatal,
        reason: 'DATA-0000: audio the provider cannot decode fails again',
      );
      // Abnormal close with no close frame at all (network drop): the
      // historic reconnect behavior is preserved.
      expect(
        SttCloseInfo.classify(provider: 'deepgram'),
        SttCloseClass.reconnect,
      );
      expect(
        SttCloseInfo.classify(provider: 'assemblyai'),
        SttCloseClass.reconnect,
      );
    });

    test('1011 without further detail is NOT fatal', () {
      expect(
        SttCloseInfo.classify(provider: 'deepgram', closeCode: 1011),
        SttCloseClass.reconnect,
      );
    });
  });

  group('keep-alive supervision (only while audio is NOT flowing)', () {
    final base = DateTime(2026, 1, 1, 12);

    test('is due 4s after the last audio frame reached the socket', () {
      expect(
        RemoteSttService.keepAliveDue(
          provider: 'deepgram',
          lastAudioSentAt: base,
          now: base.add(const Duration(seconds: 3, milliseconds: 900)),
        ),
        isFalse,
      );
      expect(
        RemoteSttService.keepAliveDue(
          provider: 'deepgram',
          lastAudioSentAt: base,
          now: base.add(const Duration(seconds: 4)),
        ),
        isTrue,
      );
    });

    test('is due when no audio ever flowed, and only for Deepgram', () {
      expect(
        RemoteSttService.keepAliveDue(
          provider: 'deepgram',
          lastAudioSentAt: null,
          now: base,
        ),
        isTrue,
      );
      // AssemblyAI's protocol is different: no invented frames.
      expect(
        RemoteSttService.keepAliveDue(
          provider: 'assemblyai',
          lastAudioSentAt: base.subtract(const Duration(minutes: 5)),
          now: base,
        ),
        isFalse,
      );
    });
  });

  group('capture watchdog (mic frames must actually flow)', () {
    final base = DateTime(2026, 1, 1, 12);

    test('a flowing capture is never stalled', () {
      expect(
        RemoteSttService.captureStalled(
          lastMicFrameAt: base.subtract(const Duration(milliseconds: 500)),
          micOpenedAt: base.subtract(const Duration(minutes: 1)),
          now: base,
        ),
        isFalse,
      );
    });

    test('a capture that stopped delivering frames is stalled at 2s', () {
      expect(
        RemoteSttService.captureStalled(
          lastMicFrameAt: base.subtract(const Duration(seconds: 2)),
          micOpenedAt: base.subtract(const Duration(minutes: 1)),
          now: base,
        ),
        isTrue,
      );
    });

    test('a capture that was never opened is not a stall', () {
      expect(
        RemoteSttService.captureStalled(
          lastMicFrameAt: null,
          micOpenedAt: null,
          now: base,
        ),
        isFalse,
      );
    });

    test('before the first frame, the clock runs from the mic opening', () {
      // Opened 1s ago, no frame yet: the ordinary start probe still owns the
      // window — the watchdog must not race it.
      expect(
        RemoteSttService.captureStalled(
          lastMicFrameAt: null,
          micOpenedAt: base.subtract(const Duration(seconds: 1)),
          now: base,
        ),
        isFalse,
      );
      // Opened past the threshold with no frame ever: stalled.
      expect(
        RemoteSttService.captureStalled(
          lastMicFrameAt: null,
          micOpenedAt: base.subtract(const Duration(seconds: 2)),
          now: base,
        ),
        isTrue,
      );
    });

    test('a fresh frame overrides an old opening timestamp', () {
      // The mic opened long ago but delivered a frame just now: healthy.
      expect(
        RemoteSttService.captureStalled(
          lastMicFrameAt: base.subtract(const Duration(milliseconds: 100)),
          micOpenedAt: base.subtract(const Duration(hours: 1)),
          now: base,
        ),
        isFalse,
      );
    });
  });

  group('reconnect backoff policy', () {
    SttCloseInfo info(SttCloseClass closeClass) =>
        SttCloseInfo(provider: 'deepgram', closeClass: closeClass);

    test('immediate closes retry fast (250-500ms)', () {
      final delay = VoiceService.reconnectDelayFor(
        info(SttCloseClass.reconnectImmediate),
        1,
      );
      expect(delay, greaterThanOrEqualTo(const Duration(milliseconds: 250)));
      expect(delay, lessThanOrEqualTo(const Duration(milliseconds: 500)));
    });

    test('normal closes back off exponentially, capped at 3s', () {
      for (var attempt = 1; attempt <= 4; attempt++) {
        final delay = VoiceService.reconnectDelayFor(
          info(SttCloseClass.reconnect),
          attempt,
        );
        expect(delay, lessThanOrEqualTo(const Duration(seconds: 3)));
      }
      final first = VoiceService.reconnectDelayFor(
        info(SttCloseClass.reconnect),
        1,
      );
      final third = VoiceService.reconnectDelayFor(
        info(SttCloseClass.reconnect),
        3,
      );
      expect(third, greaterThan(first));
    });

    test('idle-timeout closes (NET-0002) get an extended backoff', () {
      final extended = VoiceService.reconnectDelayFor(
        info(SttCloseClass.reconnectExtended),
        1,
      );
      final normal = VoiceService.reconnectDelayFor(
        info(SttCloseClass.reconnect),
        1,
      );
      expect(extended, greaterThan(normal));
      expect(extended, lessThanOrEqualTo(const Duration(seconds: 6)));
    });

    test('fatal closes are never delayed (they never reconnect)', () {
      expect(
        VoiceService.reconnectDelayFor(info(SttCloseClass.fatal), 1),
        Duration.zero,
      );
    });
  });
}
