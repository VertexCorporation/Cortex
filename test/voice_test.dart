// test/voice_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:flutter_tts/flutter_tts.dart';

// --- Mocks ---

class MockSpeechService extends SpeechService {
  bool isListeningMock = false;
  Function(String text)? onResultCallback;

  @override
  Future<void> startListening({
    required String locale,
    required Function(String text) onResult,
  }) async {
    isListeningMock = true;
    onResultCallback = onResult;
  }

  @override
  Future<void> stopListening() async {
    isListeningMock = false;
  }
}

class MockFlutterTts extends FlutterTts {
  String? lastSpokenText;
  VoidCallback? _startHandler;
  VoidCallback? _completionHandler;
  bool isSpeakingMock = false;

  @override
  Future<dynamic> setSharedInstance(bool? shared) async => 1;

  @override
  Future<dynamic> setIosAudioCategory(IosTextToSpeechAudioCategory category,
      List<IosTextToSpeechAudioCategoryOptions> options,
      [IosTextToSpeechAudioMode mode =
          IosTextToSpeechAudioMode.defaultMode]) async =>
      1;

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

    mockSpeechService = MockSpeechService();
    mockFlutterTts = MockFlutterTts();

    voiceService = VoiceService(
      speechService: mockSpeechService,
      flutterTts: mockFlutterTts,
    );
  });

  test('Initial state is idle', () {
    expect(voiceService.state, VoiceState.idle);
  });

  test('Start session transitions to listening', () async {
    await voiceService.startSession(
      locale: 'en-US',
      onFinalSentence: (text) {},
    );
    expect(voiceService.state, VoiceState.listening);
    expect(mockSpeechService.isListeningMock, true);
  });

  test('Speaking logic queues sentences correctly', () async {
    // 1. Start Session
    await voiceService.startSession(locale: 'en-US', onFinalSentence: (_) {});

    // 2. Simulate AI Streaming text
    // "Hello world. How are you?"
    voiceService.onAiStreamCallback("Hello world");
    // Should not speak yet (no delimiter)
    expect(mockFlutterTts.lastSpokenText, isNull);

    voiceService.onAiStreamCallback(". ");
    // Should detect "Hello world" and speak it.

    await Future.delayed(Duration.zero);

    expect(mockFlutterTts.lastSpokenText, "Hello world.");

    voiceService.onAiStreamCallback("How are you?");
    // Delimiter found at end of string, so it speaks immediately.
    await Future.delayed(Duration.zero);
    expect(mockFlutterTts.lastSpokenText, "How are you?");

    voiceService.onAiResponseFinished();
    await Future.delayed(Duration.zero);
    expect(mockFlutterTts.lastSpokenText, "How are you?");
  });

  test('VoiceService restarts listening after AI finishes', () async {
    await voiceService.startSession(locale: 'en-US', onFinalSentence: (_) {});
    await voiceService.stopSession(); // Reset

    await voiceService.startSession(locale: 'en-US', onFinalSentence: (_) {});

    voiceService.onAiStreamCallback("Hello.");
    await Future.delayed(Duration.zero);

    voiceService.onAiResponseFinished();

    // Wait for 500ms delay + buffer
    await Future.delayed(const Duration(milliseconds: 600));

    expect(voiceService.state, VoiceState.listening);
    expect(mockSpeechService.isListeningMock, true);
  });
}
