import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/repository.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter_test/flutter_test.dart';

class CatalogRepository implements ModelRepository {
  final rows = <Map<String, dynamic>>[
    {
      'id': 'qwen',
      'title': 'Qwen',
      'series': 'Qwen',
      'type': 'online',
      'variants': {
        'qwen/vision': {
          'id': 'qwen/vision',
          'title': {'en': 'Vision', 'tr': 'Görsel'},
          'modalities': {'image': true},
        },
      },
    },
  ];
  @override
  List<Map<String, dynamic>> get rawModelsCache => rows;
  @override
  Future<List<Map<String, dynamic>>?> getAllModels({
    required String langCode,
    required Map<String, String> localAssetMap,
  }) async => rows;
  @override
  void clearRawCache() {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ModelService service;
  setUp(() async {
    service = ModelService(repository: CatalogRepository());
    final models = await service.getModels(langCode: 'en');
    expect(service.hasError, isFalse);
    expect(models, isNotNull);
    expect(models!.map((model) => model.id), contains('qwen'));
    expect(service.hasModelInCache('qwen/vision'), isTrue);
  });
  tearDown(() => service.dispose());

  test(
    'variant resolution is reused and keeps modality and parent identity',
    () {
      final first = service.getPreciseModelData('qwen/vision', langCode: 'en');
      expect(
        identical(
          first,
          service.getPreciseModelData('qwen/vision', langCode: 'en'),
        ),
        isTrue,
      );
      expect(first.modalities['image'], isTrue);
      expect(service.hasModelInCache('qwen/vision'), isTrue);
      expect(service.getBaseIdFromFullId('qwen/vision'), 'qwen');
    },
  );

  test('exact ID wins over variant and removals invalidate cached matches', () {
    service.getPreciseModelData('qwen/vision', langCode: 'en');
    final exact = ModelEntity.fromMap({
      'id': 'qwen/vision',
      'title': 'Exact',
      'type': 'online',
    }, 'en');
    service.addModelToEntityCache(exact);
    expect(
      service.getPreciseModelData('qwen/vision', langCode: 'en'),
      same(exact),
    );
    service.removeModelFromEntityCache(exact.id);
    expect(service.getBaseIdFromFullId('qwen/vision'), 'qwen');
    service.removeModelFromEntityCache('qwen');
    expect(service.hasModelInCache('qwen/vision'), isFalse);
  });

  test('updated parent invalidates resolved variant', () {
    final before = service.getPreciseModelData('qwen/vision', langCode: 'en');
    final parent = service.getPreciseModelData('qwen', langCode: 'en');
    service.updateCachedEntity(
      parent.copyWith(imagePath: 'assets/updated.png'),
    );
    final after = service.getPreciseModelData('qwen/vision', langCode: 'en');
    expect(after, isNot(same(before)));
    expect(after.imagePath, 'assets/updated.png');
  });

  test(
    'switching locale cannot reuse a localized variant from prior locale',
    () {
      final english = service.getPreciseModelData(
        'qwen/vision',
        langCode: 'en',
      );
      final turkish = service.getPreciseModelData(
        'qwen/vision',
        langCode: 'tr',
      );
      expect(turkish, isNot(same(english)));
      expect(english.displayTitle, 'Vision');
      expect(turkish.displayTitle, 'Görsel');
      service.clearAllCache();
      expect(service.hasModelInCache('qwen/vision'), isFalse);
    },
  );
}
