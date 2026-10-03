import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/generation.dart';
import 'package:cortex/chat/services/send/media.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter_test/flutter_test.dart';

ModelEntity audioModel(String id, String title, {String source = 'fal',
    Map<String, dynamic> modalities = const {}}) =>
    ModelEntity.fromMap({'id': id, 'name': title, 'title': title,
      'type': 'online', 'source': source, 'outputs': {'audio': true},
      'modalities': modalities}, 'en');

class _UnusedModelService implements ModelService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MusicCatalogue extends _UnusedModelService {
  final ModelEntity family = ModelEntity.fromMap({
    'id': 'family', 'variants': {
      'fal/tts': {}, 'fal/lyria': {},
    },
  }, 'en');

  @override
  List<ModelEntity> getCachedModelsSync() => [family];

  @override
  ModelEntity getPreciseModelData(String id, {required String langCode}) =>
      id == 'family' ? family : audioModel(id, id);
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

  test('music accepts text generation but rejects audio-only editing', () {
    expect(MediaRouter.isMusicGenerationModel(audioModel('fal/music-editor', 'Music',
      modalities: {'audio': true})), isFalse);
    expect(MediaRouter.isMusicGenerationModel(audioModel('fal/music', 'Music',
      modalities: {'text': true, 'audio': true})), isTrue);
  });

  test('music routing resolves exact catalogue variants instead of a family or TTS', () {
    final router = MediaRouter(_MusicCatalogue());
    expect(router.findMusicGenerationModel(langCode: 'en',
      isUserSubscribed: false)?.id, 'fal/lyria');
    expect(MediaRouter(_UnusedModelService()).resolveAttachmentIntentModelId(
      currentModelId: 'fal/lyria', text: 'Make a song', attachments: ['cover.jpg'],
      langCode: 'en', isUserSubscribed: false), isNull);
  });

  test('Turkish song prompts are audio intent rather than image intent', () {
    final router = MediaRouter(_UnusedModelService());
    expect(router.inferMediaIntentFromText(text: 'Bana bir şarkı yap',
      hasImage: false, hasVideo: false, hasAudio: false), MediaIntent.generateAudio);
  });
}
