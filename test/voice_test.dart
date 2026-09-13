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

  Function(String text)? onResultCallback;
  void Function()? onClosedCallback;
  void Function(SttLease lease)? onLeaseCallback;
  SpeechOwner? lastOwner;

  @override
  bool get isListening => _listening;
  @override
  bool get isRemoteActive => remoteActive;
  @override
  double get soundLevel => level;

  @override
  Future<bool> startListening({
    required String locale,
    required Function(String text) onResult,
    SpeechOwner owner = SpeechOwner.dictation,
    void Function()? onClosed,
    void Function(SttLease lease)? onLease,
  }) async {
    startCount++;
    lastOwner = owner;
    onClosedCallback = onClosed;
    onLeaseCallback = onLease;
    if (shouldFailStart) return false;
    _listening = true;
    onResultCallback = onResult;
    return true;
  }

  @override
  Future<void> stopListening() async {
    stopCount++;
    _listening = false;
  }

  void emit(String text) => onResultCallback?.call(text);
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
    mockSpeechService = MockSpeechService();
    mockFlutterTts = MockFlutterTts();

    voiceService = VoiceService(
      speechService: mockSpeechService,
      flutterTts: mockFlutterTts,
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

  test('barge-in: sustained user speech while speaking cuts audio and returns to listening', () async {
    await startTestSession();

    voiceService.onAiStreamCallback("The assistant is talking.");
    await Future<void>.delayed(Duration.zero);
    expect(voiceService.state, VoiceState.speaking);

    // Simulate the remote mic still open during playback: the user starts
    // talking over the assistant. A transcript frame arrives (evidence), then
    // three consecutive loud samples.
    mockSpeechService.remoteActive = true;
    mockSpeechService.emit("User");

    mockSpeechService.level = 0.8;
    mockSpeechService.notifyListeners();
    mockSpeechService.notifyListeners();
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
  });

  test(
    'provider socket loss reconnects under the same session, bounded',
    () async {
      await startTestSession();
      final startsBefore = mockSpeechService.startCount;

      // The socket closes on its own three times: the session reconnects each
      // time under the SAME generation.
      mockSpeechService.onClosedCallback?.call();
      await Future<void>.delayed(Duration.zero);
      mockSpeechService.onClosedCallback?.call();
      await Future<void>.delayed(Duration.zero);
      mockSpeechService.onClosedCallback?.call();
      await Future<void>.delayed(Duration.zero);

      expect(mockSpeechService.startCount, startsBefore + 3);
      expect(voiceService.isSessionActive, true);
      expect(voiceService.state, VoiceState.listening);

      // The fourth close exceeds the per-session budget while still listening:
      // the session fails instead of looping forever.
      mockSpeechService.onClosedCallback?.call();
      await Future<void>.delayed(Duration.zero);
      expect(voiceService.isSessionActive, false);
      expect(voiceService.state, VoiceState.failed);
      expect(voiceService.lastEndReason, VoiceEndReason.error);
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
}
