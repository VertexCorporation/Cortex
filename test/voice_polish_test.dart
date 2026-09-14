import 'package:flutter_test/flutter_test.dart';
import 'package:cortex/chat/services/flow_text.dart';
import 'package:cortex/chat/services/voice_catalog.dart';
import 'package:cortex/chat/messages/messages.dart';

void main() {
  test('leading Flow markers disappear, later quoted markers remain', () {
    for (final marker in [
      '[red participant]',
      ' [ GREEN participant : ] :  ',
      'Blue participant: ',
      '[ yellow  participant ]',
    ]) {
      expect(FlowText.sanitize('$marker Hello.'), 'Hello.');
    }
    const content = 'Discuss [red participant] as a literal label.';
    expect(FlowText.sanitize(content), content);
    expect(
      FlowText.sanitize('[purple participant] Hello.'),
      '[purple participant] Hello.',
    );
  });
  test('streaming markers never leak into the displayed or spoken delta', () {
    const raw = ' [  ReD   participant ]: Hello there.';
    var previous = '';
    final spoken = StringBuffer();
    for (var i = 1; i <= raw.length; i++) {
      final visible = FlowText.sanitize(raw.substring(0, i), streaming: true);
      expect(visible.startsWith(previous), isTrue);
      spoken.write(visible.substring(previous.length));
      previous = visible;
    }
    expect(spoken.toString(), 'Hello there.');
  });
  test(
    'only Flow assistant presentation is sanitized; raw persistence survives',
    () {
      final flow = Message(
        text: '[Blue participant] Hello',
        isUserMessage: false,
        flowParticipant: 'blue',
      );
      expect(flow.displayableText, 'Hello');
      expect(Message.fromMap(flow.toMap()).displayableText, 'Hello');
      expect(flow.text, '[Blue participant] Hello');
      expect(
        Message(text: flow.text, isUserMessage: true).displayableText,
        flow.text,
      );
    },
  );
  test(
    'Flow cast is distinct, gender correct, and stable after catalog reorder',
    () {
      const voices = [
        CortexVoice(id: 'f2', name: 'F2', gender: VoiceGender.female),
        CortexVoice(id: 'm2', name: 'M2', gender: VoiceGender.male),
        CortexVoice(id: 'f1', name: 'F1', gender: VoiceGender.female),
        CortexVoice(id: 'm1', name: 'M1', gender: VoiceGender.male),
      ];
      expect(resolveFlowVoices(voices), ['f1', 'm1', 'f2', 'm2']);
      expect(
        resolveFlowVoices(voices.reversed.toList()),
        resolveFlowVoices(voices),
      );
      expect(resolveFlowVoices(voices, configured: {'blue': 'f2'}), [
        'f2',
        'm1',
        'f1',
        'm2',
      ]);
    },
  );
}
