// test/utils_test.dart
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter_test/flutter_test.dart';

// Minimal fake
class FakeModelService implements ModelService {
  final Map<String, ModelEntity> models = {};

  @override
  ModelEntity getPreciseModelData(String modelId, {required String langCode}) {
    if (models.containsKey(modelId)) {
      return models[modelId]!;
    }
    // Return a dummy entity using factory
    return ModelEntity.fromMap({
      'id': modelId,
      'isServerSide': modelId.startsWith('cortex/'),
      'name': 'Dummy'
    }, 'en');
  }

  // Ignore others
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Utils Tests', () {
    late FakeModelService fakeService;

    setUp(() {
      fakeService = FakeModelService();
    });

    test('isServerSideModel returns true if IDs invalid', () {
      expect(
          Utils.isServerSideModel(null,
              langCode: 'en', modelService: fakeService),
          true);
      expect(
          Utils.isServerSideModel('',
              langCode: 'en', modelService: fakeService),
          true);
    });

    test('isServerSideModel resolves via service', () {
      // Setup fake data
      fakeService.models['local-gpt'] = ModelEntity.fromMap(
          {'id': 'local-gpt', 'type': 'offline', 'name': 'Local'}, 'en');

      fakeService.models['cloud-gpt'] = ModelEntity.fromMap(
          {'id': 'cloud-gpt', 'type': 'online', 'name': 'Cloud'}, 'en');

      expect(
          Utils.isServerSideModel('local-gpt',
              langCode: 'en', modelService: fakeService),
          false);
      expect(
          Utils.isServerSideModel('cloud-gpt',
              langCode: 'en', modelService: fakeService),
          true);
    });

    test('isLocalModel is inverse of server side', () {
      fakeService.models['local-gpt'] = ModelEntity.fromMap(
          {'id': 'local-gpt', 'type': 'offline', 'name': 'Local'}, 'en');

      expect(
          Utils.isLocalModel('local-gpt',
              langCode: 'en', modelService: fakeService),
          true);
    });

    test('getModelEntityFromId call-through', () {
      fakeService.models['my-model'] = ModelEntity.fromMap({
        'id': 'my-model',
        'title': 'Custom' // Entity maps 'title' to displayTitle
      }, 'en');

      final entity = Utils.getModelEntityFromId('my-model',
          langCode: 'en', modelService: fakeService);
      expect(entity.id, 'my-model');
      expect(entity.displayTitle, 'Custom');
    });
  });
}
