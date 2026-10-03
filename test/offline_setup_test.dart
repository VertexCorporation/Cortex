import 'package:cortex/chat/services/offline_setup.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/system.dart';
import 'package:flutter_test/flutter_test.dart';

ModelEntity model(String id, {int? ram = 1024, int? size = 500,
    String tier = 'free', String type = 'offline', String? url = 'https://example.com/model.gguf'}) =>
    ModelEntity.fromMap({'id': id, 'name': id, 'type': type, 'tier': tier,
      'ram': ram, 'size': size, 'url': url}, 'en');

SystemInfoData device({int memory = 8192, int used = 2048, int storage = 8192}) =>
    SystemInfoData(deviceMemory: memory, usedMemory: used,
      freeStorage: storage, totalStorage: 16384);

void main() {
  test('recommendation leaves RAM headroom and compares actual variants', () {
    final recommended = recommendOfflineModel(models: [
      model('small'), model('medium', ram: 4096, size: 2048),
      model('too-large', ram: 8192, size: 4096),
    ], device: device());
    expect(recommended?.id, 'medium');
  });

  test('live memory pressure selects a smaller model', () {
    final recommended = recommendOfflineModel(models: [
      model('small', ram: 512), model('big', ram: 2048),
    ], device: device(used: 7000));
    expect(recommended?.id, 'small');
  });

  test('app resident memory must not be mistaken for system-wide free RAM on iOS', () {
    final recommended = recommendOfflineModel(models: [
      model('small', ram: 1024), model('too-large', ram: 4096),
    ], device: device(used: 128), usedMemoryIsSystemWide: false);
    expect(recommended?.id, 'small');
  });

  test('unknown requirements, paid models and online models are not auto-selected', () {
    expect(recommendOfflineModel(models: [
      model('unknown', ram: null), model('premium', tier: 'premium'),
      model('online', type: 'online'), model('unknown-size', size: null),
    ], device: device()), isNull);
    expect(recommendOfflineModel(models: [model('safe')],
      device: device(memory: -1)), isNull);
  });

  test('storage buffer and secure download URL are mandatory for a new download', () {
    expect(recommendOfflineModel(models: [model('model', size: 500)],
      device: device(storage: 550)), isNull);
    expect(recommendOfflineModel(models: [model('http', url: 'http://example.com/a.gguf')],
      device: device()), isNull);
  });

  test('an installed suitable model is reused without needing download space', () {
    final recommended = recommendOfflineModel(models: [
      model('installed', url: null), model('new', ram: 2048),
    ], device: device(storage: 0), installedIds: {'installed'});
    expect(recommended?.id, 'installed');
  });
}
