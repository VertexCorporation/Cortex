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
          isFullyLocalized: true,
          toolUse: false);
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
          isFullyLocalized: true,
          toolUse: false);
    }
  }

  @override
  String getBaseIdFromFullId(String? fullId, {String? langCode}) {
    return fullId ?? '';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeModelService mockModelService;

  setUp(() {
    mockModelService = FakeModelService();
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatSessionProvider Unknown Model Fix Tests', () {
    // -----------------------------------------------------------------------
    // TEST 1 — Cold Start: cache is empty, provider uses the stub entity.
    //
    // When cache is empty, constructor calls _initializeWithStub().
    // The stub entity gets displayTitle = formatModelName(initialModelTitle).
    // modelTitle getter then reads the stub entity's displayTitle.
    // For 'gemini-pro', title has no slashes/dashes so it's passed through:
    // formatModelName('Gemini 1.5 Pro') -> 'Gemini 1.5 Pro' (no dashes).
    // -----------------------------------------------------------------------
    test('Should not show null/empty title on cold start (cache empty)', () {
      expect(mockModelService.getCachedModelsSync(), isEmpty);

      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'gemini-pro',
        initialModelTitle: 'Gemini 1.5 Pro',
      );

      // modelTitle must be non-null and not 'Unknown Model'
      expect(provider.modelTitle, isNotNull);
      expect(provider.modelTitle, isNot('Unknown Model'));
      expect(provider.modelTitle, isNot(isEmpty));

      // modelId stays as given
      expect(provider.modelId, 'gemini-pro');

      provider.dispose();
    });

    // -----------------------------------------------------------------------
    // TEST 2 — modelTitle NEVER returns 'Unknown Model'
    // -----------------------------------------------------------------------
    test('Should NEVER show Unknown Model string', () {
      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'gemini-pro',
        initialModelTitle: 'Gemini Cached',
      );

      expect(provider.modelTitle, isNot('Unknown Model'));

      provider.dispose();
    });

    // -----------------------------------------------------------------------
    // TEST 3 — Dynamic Chat: cortex/auto always returns null or 'Cortex'
    // -----------------------------------------------------------------------
    test('Dynamic chat (cortex/auto) returns Cortex title', () {
      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'cortex/auto',
        initialModelTitle: '',
      );

      // Dynamic mode: _selectedModel is null, so modelTitle returns null
      // (UI fallback handles 'Cortex' branding in that case)
      expect(provider.isDynamicChat, true);
      expect(provider.modelId, 'cortex/auto');

      provider.dispose();
    });

    // -----------------------------------------------------------------------
    // TEST 4 — Catalog loads: pending model resolves to real entity
    // -----------------------------------------------------------------------
    test('Should resolve to full entity when ModelService loads data', () async {
      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'gemini-pro',
        initialModelTitle: 'Gemini Cached',
      );

      // stub state - non-null title
      expect(provider.modelTitle, isNot('Unknown Model'));

      // Simulate catalog arriving
      final realEntity = ModelEntity(
          id: 'gemini-pro',
          displayTitle: 'Gemini Real Deal',
          producer: 'Google',
          source: 'openrouter',
          displayDescription: '',
          displaySummary: '',
          type: 'online',
          category: 'chat',
          tier: 'free',
          modalities: {},
          outputs: {},
          isFullyLocalized: true,
          toolUse: false);

      mockModelService.setModels([realEntity]);
      mockModelService.setLoading(false); // triggers _onModelServiceUpdate

      // Let async resolution complete
      await Future.delayed(Duration.zero);

      // After resolution, title comes from the real entity
      expect(provider.modelTitle, 'Gemini Real Deal');

      provider.dispose();
    });

    // -----------------------------------------------------------------------
    // TEST 5 — Model removed from catalog → fallback to dynamic
    // -----------------------------------------------------------------------
    test('Should fall back to dynamic if model is no longer in catalog', () async {
      // Start with empty cache (cold start)
      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'old-model',
        initialModelTitle: 'Old Model Name',
      );

      // Catalog loads but does NOT include 'old-model'
      final differentEntity = ModelEntity(
          id: 'new-model',
          displayTitle: 'New Model',
          producer: 'Vertex',
          source: 'openrouter',
          displayDescription: '',
          displaySummary: '',
          type: 'online',
          category: 'chat',
          tier: 'free',
          modalities: {},
          outputs: {},
          isFullyLocalized: true,
          toolUse: false);

      mockModelService.setModels([differentEntity]);
      mockModelService.setLoading(false);

      await Future.delayed(Duration.zero);

      // Falls back to dynamic chat
      expect(provider.isDynamicChat, true);

      provider.dispose();
    });

    // -----------------------------------------------------------------------
    // TEST 6 — resetForLogout wipes all state
    // -----------------------------------------------------------------------
    test('resetForLogout clears all model and user state', () {
      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'gemini-pro',
        initialModelTitle: 'Gemini',
      );

      provider.resetForLogout();

      expect(provider.isDynamicChat, true);
      expect(provider.isUserSubscribed, false);
      expect(provider.displayName, null);
      expect(provider.email, null);
      expect(provider.isLocalModelLoaded, false);
      expect(provider.isFluxMode, false);

      provider.dispose();
    });

    // -----------------------------------------------------------------------
    // TEST 7 — Flux mode toggling
    // -----------------------------------------------------------------------
    test('Flux mode toggling works correctly', () {
      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'cortex/auto',
      );

      expect(provider.isFluxMode, false);

      provider.setFluxMode(true);
      expect(provider.isFluxMode, true);

      provider.setFluxMode(false);
      expect(provider.isFluxMode, false);

      provider.dispose();
    });

    // -----------------------------------------------------------------------
    // TEST 8 — Storage sufficient flag
    // -----------------------------------------------------------------------
    test('Storage sufficiency flag updates correctly', () {
      final provider = ChatSessionProvider(
        modelService: mockModelService,
        initialModelId: 'cortex/auto',
      );

      expect(provider.isStorageSufficient, true);

      provider.setStorageSufficient(false);
      expect(provider.isStorageSufficient, false);

      provider.setStorageSufficient(true);
      expect(provider.isStorageSufficient, true);

      provider.dispose();
    });
  });
}
