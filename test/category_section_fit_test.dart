// Regression guard for the Poco F7 / narrow-screen RenderFlex overflow in
// the library category carousel: the per-card height slot must cover
// ModelTile's fixed-pixel floor (48 px control button), and OEM/enlarged
// text metrics must never push the column past the page box.

import 'package:cortex/internet.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/utils.dart';
import 'package:cortex/library/screen/models/widgets/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Minimal connectivity stub, mirroring composer_recording_animation_test.dart.
class _Internet extends ChangeNotifier implements InternetProvider {
  @override
  bool get isConnected => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A local (download-button) model with a framed SVG cover: the tallest tile
/// variant — the case that overflowed on the Poco F7.
ModelEntity _framedModel(String id) => ModelEntity(
      id: id,
      displayTitle: 'Çok uzun Türkçe model başlığı denemesi $id',
      producer: 'producer',
      type: 'offline',
      source: 'source',
      category: 'assistant',
      displaySummary: 'İki satıra sığmayabilen uzun Türkçe özet metni $id',
      displayDescription: 'description',
      imagePath: 'assets/icons/checkmark.svg',
      tier: 'free',
      size: 1024,
      ram: 2048,
      modalities: const {},
      outputs: const {},
      toolUse: false,
      isFullyLocalized: true,
    );

Widget _wrap(Widget child) => ChangeNotifierProvider<InternetProvider>(
      create: (_) => _Internet(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // MIUI-style enlarged system text.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    );

void main() {
  test('calculateCategoryHeight covers ModelTile fixed-pixel floor', () {
    const narrow = 393.8; // Poco F7 logical width
    final three = List.filled(3, <String, dynamic>{'id': 'x'});
    final height = ModelsBackendUtils.calculateCategoryHeight(three, narrow);
    // Real per-tile footprint: action column 0.045w + 48 px button + 0.016w
    // vertical padding, plus the inter-tile spacers.
    final floor = 3 * (narrow * 0.061 + 48) + 2 * narrow * 0.01;
    expect(height, greaterThan(floor));

    // The slot still grows with the screen on wide devices.
    final wide = ModelsBackendUtils.calculateCategoryHeight(three, 800);
    expect(wide, greaterThan(height));
  });

  for (final width in [393.8, 320.0]) {
    testWidgets('carousel column never overflows at $width px / 1.3 text scale',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(ModelCategorySection(
        title: 'Category',
        models: [_framedModel('a'), _framedModel('b'), _framedModel('c')],
        downloadedStates: const {},
        downloadManagers: const {},
        getCompatibilityStatus: (_) => CompatibilityStatus.compatible,
        onModelTapped: (_) {},
        onRemovePressed: (_, _) async {},
        onChatPressed: (String id, bool isServerSide,
                {bool isCustomModel = false, String? modelPath}) async {},
        onDownloadPressed: ({required String id, required String? url, required String title}) async {},
        onCancelDownload: (_) {},
        onResumeDownload: (_) {},
      )));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // RenderFlex overflow (the Poco F7 crash class) throws during layout.
      expect(tester.takeException(), isNull);
    });
  }
}
