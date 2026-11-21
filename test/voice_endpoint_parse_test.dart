import 'package:cortex/chat/services/stt_remote.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Deepgram separates final segments from speech endpoints', () {
    final segment = RemoteSttService.parseDeepgramTranscript('''
      {"type":"Results","is_final":true,"speech_final":false,
       "channel":{"alternatives":[{"transcript":"A short clause","confidence":0.9}]}}
    ''');
    final endpoint = RemoteSttService.parseDeepgramTranscript('''
      {"type":"Results","is_final":true,"speech_final":true,
       "channel":{"alternatives":[{"transcript":"I am finished","confidence":0.95}]}}
    ''');

    expect(segment?.isFinal, isTrue);
    expect(segment?.isEndOfTurn, isFalse);
    expect(endpoint?.isFinal, isTrue);
    expect(endpoint?.isEndOfTurn, isTrue);
  });

  test('Deepgram preserves an empty speech_final boundary frame', () {
    final boundary = RemoteSttService.parseDeepgramTranscript('''
      {"type":"Results","is_final":true,"speech_final":true,
       "channel":{"alternatives":[{"transcript":""}]}}
    ''');

    expect(boundary, isNotNull);
    expect(boundary!.text, isEmpty);
    expect(boundary.isEndOfTurn, isTrue);
  });

  test('AssemblyAI end_of_turn is exposed as the turn endpoint', () {
    final interim = RemoteSttService.parseAssemblyTranscript(
      '{"type":"Turn","transcript":"Still speaking","end_of_turn":false}',
    );
    final endpoint = RemoteSttService.parseAssemblyTranscript(
      '{"type":"Turn","transcript":"Done now","end_of_turn":true}',
    );

    expect(interim?.isEndOfTurn, isFalse);
    expect(endpoint?.isEndOfTurn, isTrue);
    expect(endpoint?.isFinal, isTrue);
  });

  test('ElevenLabs committed transcripts end the user turn', () {
    final endpoint = RemoteSttService.parseElevenLabsTranscript(
      '{"message_type":"committed_transcript","text":"Hello there"}',
    );

    expect(endpoint?.isFinal, isTrue);
    expect(endpoint?.isEndOfTurn, isTrue);
  });
}
