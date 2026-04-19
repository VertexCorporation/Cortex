// test/session_test.dart
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fake ModelService Implementation to mock behavior
class FakeModelService extends ChangeNotifier implements ModelService {
  bool _isLoading = false;
  List<ModelEntity> _models = [];

  @override
  bool get isLoading => _isLoading;

  @override
  bool get hasError => false;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setModels(List<ModelEntity> models) {
    _models = models;
    notifyListeners();
  }

  @override
  List<ModelEntity> getCachedModelsSync() {
    return _models;
  }

  @override
  bool hasModelInCache(String modelId) {
    if (modelId == 'cortex/auto' || modelId == 'dynamic') return true;
    return _models.any((m) => m.id == modelId);
  }

  @override
  ModelEntity getPreciseModelData(String modelId, {required String langCode}) {
    if (_models.isEmpty) {
      // Mimic real service behavior: It might return an "Unknown" entity if called prematurely
      // or throw. Our fix handles empty check explicitly, so this mimics exact match fail.
      return ModelEntity(
          id: modelId,
          displayTitle: 'Unknown Model',
          producer: '',
          source: 'openrouter',
          displayDescription: '',
          displaySummary: '',
          type: 'online',
          category: 'general',
          tier: 'free',
          modalities: {},
          outputs: {},
          isFullyLocalized: true, toolUse: false);
    }
    try {
      return _models.firstWhere((m) => m.id == modelId);
    } catch (e) {
      return ModelEntity(
          id: modelId,
          displayTitle: 'Unknown Model',
          producer: '',
          source: 'openrouter',
          displayDescription: '',
          displaySummary: '',
          type: 'online',
          category: 'general',
          tier: 'free',
          modalities: {},
          outputs: {},
          isFullyLocalized: true, toolUse: false);
    }
  }

  @override
  String getBaseIdFromFullId(String? fullId, {String? langCode}) {
    // Mock implementation: simplistically return fullId as baseId
    return fullId ?? '';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeModelService mockModelService;

  setUp(() {
    mockModelService = FakeModelService();
    // Reset SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatSessionProvider Unknown Model Fix Tests', () {
    test(
        'Should use cached title when ModelService cache is empty (Cold Start)',
        () {
      // 1. Setup: Service cache is empty
      expect(mockModelService.getCachedModelsSync(), isEmpty);

      // 2. Initialize Provider with cached title passed from main.dart
      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'gemini-pro',
        initialModelTitle: 'Gemini 1.5 Pro', // Simulated persisted title
      );

      // 3. Verify: Should use the cached title immediately
      expect(provider.modelTitle, 'Gemini 1.5 Pro');
      expect(provider.modelId, 'gemini-pro');

      // Cleanup
      provider.dispose();
    });

    test('Should NOT show Unknown Model even if Service would return it', () {
      // Our fix explicitly checks for empty cache.
      // If we didn't check, getPreciseModelData would return "Unknown Model".

      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'gemini-pro',
        initialModelTitle: 'Gemini Cached',
      );

      // Verify strict check worked
      expect(provider.modelTitle, 'Gemini Cached');
      expect(provider.modelTitle, isNot('Unknown Model'));

      provider.dispose();
    });

    test('Should resolve to full entity when ModelService loads data', () {
      // 1. Initialize with Stub
      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'gemini-pro',
        initialModelTitle: 'Gemini Cached',
      );

      expect(provider.modelTitle, 'Gemini Cached');

      // 2. Populate models in Service
      final realEntity = ModelEntity(
          id: 'gemini-pro',
          displayTitle: 'Gemini Real Deal', // Updated title from server
          producer: 'Google',
          source: 'openrouter',
          displayDescription: '',
          displaySummary: '',
          type: 'online',
          category: 'chat',
          tier: 'free',
          modalities: {},
          outputs: {},
          isFullyLocalized: true, toolUse: false);

      mockModelService.setModels([realEntity]);

      // 3. Trigger update via loading state change (simulating catalog load completion)
      mockModelService.setLoading(true);
      mockModelService.setLoading(false);

      // 4. Verify resolution: Should now have the real title
      expect(provider.modelTitle, 'Gemini Real Deal');

      provider.dispose();
    });
  });
}
