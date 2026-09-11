import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/providers/catalog.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// --- Test doubles ----------------------------------------------------------
//
// mockito's `any`/`anyNamed` matchers are `Null`-typed, so they cannot be
// passed to non-nullable parameters (`getFilePathById(String)`,
// `switchActiveModel(ModelEntity, …)`). The providers under test here have
// trivial default constructors (their heavy work lives in `initialize`),
// so hand-rolled fakes are simpler and fully analyzer-safe.

/// Only used to satisfy [SelectionService]'s constructor; never stubbed.
class _MockChatSessionProvider extends Mock
    implements ChatSessionProvider {}

class _MockConversationProvider extends Mock
    implements ConversationProvider {}

class _MockModelService extends Mock implements ModelService {}

class _FakeModelCatalogProvider extends ModelCatalogProvider {
  _FakeModelCatalogProvider(this.models);

  final List<ModelEntity> models;

  @override
  List<ModelEntity> get allModels => models;
}

class _FakeModelLocalStateProvider extends ModelLocalStateProvider {
  _FakeModelLocalStateProvider(this.installedIds);

  final Set<String> installedIds;

  @override
  String getFilePathById(String id) =>
      installedIds.contains(id) ? 'disk:$id' : 'missing';

  @override
  bool isModelOnDisk(String? path) =>
      path != null && path.startsWith('disk:')
          ? installedIds.contains(path.substring(5))
          : false;
}

class _RecordingSelectionService extends SelectionService {
  _RecordingSelectionService({
    required super.sessionProvider,
    required super.conversationProvider,
    required super.modelService,
    required super.localStateProvider,
  });

  final List<ModelEntity> switchedTo = <ModelEntity>[];

  @override
  Future<void> switchActiveModel(ModelEntity newModel,
      {BuildContext? context}) async {
    switchedTo.add(newModel);
  }
}

// --- Fixtures ------------------------------------------------------------

ModelEntity _model(
  String id, {
  String type = 'offline',
  int? ram,
  int? size,
}) {
  return ModelEntity(
    id: id,
    displayTitle: id,
    producer: 'producer',
    type: type,
    source: 'source',
    category: 'assistant',
    displaySummary: 'summary',
    displayDescription: 'description',
    tier: 'free',
    ram: ram,
    size: size,
    modalities: const {},
    outputs: const {},
    toolUse: false,
    isFullyLocalized: true,
  );
}

void main() {
  group('bestInstalledOfflineModel', () {
    test('returns null when no offline model is installed', () {
      final local = _FakeModelLocalStateProvider(<String>{});
      final models = [
        _model('a', ram: 2000, size: 1400),
        _model('b', ram: 1000, size: 700),
      ];

      expect(bestInstalledOfflineModel(models, local), isNull);
    });

    test('returns null when only online models exist', () {
      final local = _FakeModelLocalStateProvider({'online-a'});
      final models = [
        _model('online-a', type: 'online', ram: 9000, size: 90000),
      ];

      expect(bestInstalledOfflineModel(models, local), isNull);
    });

    test('ignores online models even with the largest metadata', () {
      final local = _FakeModelLocalStateProvider({'offline-small'});
      final models = [
        _model('offline-small', ram: 1000, size: 700),
        _model('online-huge', type: 'online', ram: 9000, size: 90000),
      ];

      expect(bestInstalledOfflineModel(models, local)?.id, 'offline-small');
    });

    test('ranks by RAM requirement first', () {
      final local = _FakeModelLocalStateProvider({'small', 'big'});
      final models = [
        _model('small', ram: 2000, size: 5000), // bigger file, weaker RAM
        _model('big', ram: 4000, size: 1000),
      ];

      expect(bestInstalledOfflineModel(models, local)?.id, 'big');
    });

    test('breaks RAM ties by file size', () {
      final local = _FakeModelLocalStateProvider({'short', 'long'});
      final models = [
        _model('short', ram: 4000, size: 1200),
        _model('long', ram: 4000, size: 4200),
      ];

      expect(bestInstalledOfflineModel(models, local)?.id, 'long');
    });

    test('breaks full ties deterministically by id, regardless of order',
        () {
      final local = _FakeModelLocalStateProvider({'alpha', 'beta', 'gamma'});
      final models = [
        _model('alpha', ram: 4000, size: 4200),
        _model('beta', ram: 4000, size: 4200),
        _model('gamma', ram: 4000, size: 4200),
      ];

      expect(bestInstalledOfflineModel(models, local)?.id, 'gamma');
      expect(bestInstalledOfflineModel(models.reversed.toList(), local)?.id,
          'gamma');
    });

    test('treats missing metadata as zero but keeps the model eligible', () {
      final local = _FakeModelLocalStateProvider({'unknown', 'known'});
      final models = [
        _model('unknown'), // no ram/size metadata
        _model('known', ram: 500, size: 300),
      ];

      expect(bestInstalledOfflineModel(models, local)?.id, 'known');
    });

    test('hasInstalledOfflineModel mirrors the same definition', () {
      final local = _FakeModelLocalStateProvider({'installed'});
      final models = [
        _model('installed'),
        _model('not-downloaded'),
        _model('cloud', type: 'online'),
      ];

      expect(hasInstalledOfflineModel(models, local), isTrue);
      expect(
          hasInstalledOfflineModel(
              models.where((m) => m.id == 'not-downloaded'), local),
          isFalse);
    });
  });

  group('handleUseOfflineAction', () {
    late _FakeModelCatalogProvider catalog;
    late _FakeModelLocalStateProvider local;
    late _RecordingSelectionService selection;
    late InputProvider input;

    setUp(() {
      input = InputProvider();
      catalog = _FakeModelCatalogProvider([]);
      local = _FakeModelLocalStateProvider(<String>{});
      selection = _RecordingSelectionService(
        sessionProvider: _MockChatSessionProvider(),
        conversationProvider: _MockConversationProvider(),
        modelService: _MockModelService(),
        localStateProvider: local,
      );
    });

    Future<ModelEntity?> pumpAction(
      WidgetTester tester, {
      required List<ModelEntity> models,
      required Set<String> installedIds,
    }) async {
      catalog = _FakeModelCatalogProvider(models);
      local = _FakeModelLocalStateProvider(installedIds);
      selection = _RecordingSelectionService(
        sessionProvider: _MockChatSessionProvider(),
        conversationProvider: _MockConversationProvider(),
        modelService: _MockModelService(),
        localStateProvider: local,
      );

      ModelEntity? result;
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<InputProvider>.value(value: input),
          ChangeNotifierProvider<ModelCatalogProvider>.value(value: catalog),
          ChangeNotifierProvider<ModelLocalStateProvider>.value(value: local),
          Provider<SelectionService>.value(value: selection),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => result = handleUseOfflineAction(context),
                  child: const Text('act'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('act'));
      await tester.pump();
      return result;
    }

    testWidgets('with zero installed models routes to Library, arms nothing '
        'and clears an armed Web Search', (tester) async {
      input.toggleWebSearch();
      expect(input.enableWebSearch, isTrue);

      final result = await pumpAction(
        tester,
        models: [_model('not-downloaded')],
        installedIds: <String>{},
      );

      // Took the Library route (no model selected, no offline mode armed)…
      expect(result, isNull);
      expect(input.featureMode, ChatInputMode.none);
      // …and Web Search is never left armed by an offline action.
      expect(input.enableWebSearch, isFalse);
      expect(selection.switchedTo, isEmpty);
    });

    testWidgets('with one installed model selects it and arms offline mode',
        (tester) async {
      final model = _model('only', ram: 1000, size: 700);
      final result = await pumpAction(
        tester,
        models: [model, _model('missing')],
        installedIds: {'only'},
      );

      expect(result?.id, 'only');
      expect(input.featureMode, ChatInputMode.offline);
      expect(selection.switchedTo, [model]);
    });

    testWidgets('with multiple installed models selects the best ranked one',
        (tester) async {
      final weak = _model('weak', ram: 2000, size: 5000);
      final strong = _model('strong', ram: 4000, size: 1000);
      final notDownloaded = _model('ghost', ram: 9000, size: 90000);
      final result = await pumpAction(
        tester,
        models: [weak, notDownloaded, strong],
        installedIds: {'weak', 'strong'},
      );

      expect(result?.id, 'strong');
      expect(input.featureMode, ChatInputMode.offline);
      expect(selection.switchedTo, [strong]);
      expect(selection.switchedTo.contains(notDownloaded), isFalse);
    });

    testWidgets('never activates Web Search, and clears it when armed',
        (tester) async {
      // Arm Web Search first — the old greeting-card wiring toggled it ON
      // from the "Use Offline" button; it must now be cleared instead.
      input.toggleWebSearch();
      expect(input.enableWebSearch, isTrue);

      final model = _model('best', ram: 1000, size: 700);
      final result = await pumpAction(
        tester,
        models: [model],
        installedIds: {'best'},
      );

      expect(result?.id, 'best');
      expect(input.enableWebSearch, isFalse,
          reason: 'Use Offline must clear Web Search, never arm it');
      expect(input.featureMode, ChatInputMode.offline);
    });
  });
}
