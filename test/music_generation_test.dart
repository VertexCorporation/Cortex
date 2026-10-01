import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/generation.dart';
import 'package:cortex/chat/services/send/media.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter_test/flutter_test.dart';

ModelEntity audioModel(String id, String title, {String source = 'fal'}) =>
    ModelEntity.fromMap({'id': id, 'name': title, 'title': title,
      'type': 'online', 'source': source, 'outputs': {'audio': true}}, 'en');

class _UnusedModelService implements ModelService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('music is a distinct composer mode using the established audio lane', () {
    expect(generationModeForTarget('music'), ChatInputMode.musicGeneration);
    expect(generationModeForTarget('audio'), ChatInputMode.audioGeneration);
  });

  test('music routing rejects TTS and unadvertised sound-effect generators', () {
    expect(MediaRouter.isMusicGenerationModel(audioModel('fal/music', 'Music')), isTrue);
    expect(MediaRouter.isMusicGenerationModel(audioModel('fal/tts', 'Music Voice')), isFalse);
    expect(MediaRouter.isMusicGenerationModel(audioModel('fal/sound-effects', 'Sounds')), isFalse);
    expect(MediaRouter.isMusicGenerationModel(audioModel('other/music', 'Music', source: 'openrouter')), isFalse);
  });

  test('Turkish song prompts are audio intent rather than image intent', () {
    final router = MediaRouter(_UnusedModelService());
    expect(router.inferMediaIntentFromText(text: 'Bana bir şarkı yap',
      hasImage: false, hasVideo: false, hasAudio: false), MediaIntent.generateAudio);
  });
}
