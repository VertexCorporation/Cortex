import 'package:cortex/fog.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/providers/details.dart';
import 'package:cortex/library/screen/model/controller.dart';
import 'package:cortex/library/screen/model/widgets/appbar.dart';
import 'package:cortex/library/screen/model/widgets/body.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Theme extends ChangeNotifier implements ThemeProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Details extends ChangeNotifier implements ModelDetailProvider {
  @override
  final mainModel = ModelEntity.fromMap({
    'id': 'grok',
    'title': 'Grok',
    'type': 'online',
    'imagePath': 'assets/models/grok.webp'
  }, 'en');
  @override
  String? selectedVariantName = 'a';
  @override
  String get displayTitle => 'Grok';
  @override
  String get displayProducer => 'xAI';
  @override
  String get displayImagePath => 'assets/models/grok.webp';
  @override
  String get displaySummary => 'Variant $selectedVariantName';
  @override
  String get displayDescription =>
      List.filled(35, 'Model description.').join('\n');
  @override
  String get displayContext => '8192';
  @override
  String get displayModality => 'Text';
  @override
  List<String> get parsedFeatures => [];
  @override
  ModelEntity? get selectedVariant => null;
  @override
  ModelEntity? get currentCapabilitiesSource => mainModel;
  @override
  String? get selectedBaseModelId => null;
  @override
  bool get isCharacterModel => false;
  @override
  bool get isDescriptionExpanded => true;
  @override
  bool get isPluralModel => true;
  @override
  bool get isLoading => false;
  @override
  bool get isUserCreatedModel => false;
  @override
  bool get isDeleting => false;
  @override
  bool get isDownloading => false;
  @override
  bool get isPaused => false;
  @override
  bool get isButtonLocked => false;
  @override
  bool get shouldShowPremiumWarning => false;
  @override
  bool get didBaseModelChange => false;
  @override
  void selectVariant(BuildContext context, String id) {
    selectedVariantName = id;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
      'detail fades before selection, latest request wins, fog and scroll remain',
      (tester) async {
    final details = _Details();
    addTearDown(details.dispose);
    await tester.pumpWidget(ChangeNotifierProvider<ModelDetailProvider>.value(
        value: details,
        child: ChangeNotifierProvider<ThemeProvider>(
            create: (_) => _Theme(),
            child: const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: ModelDetailContent()))));
    await tester.pump(const Duration(milliseconds: 350));
    final fog = tester.widget<ScrollFog>(find.byType(ScrollFog));
    expect(fog.showTop, isTrue);
    expect(fog.showBottom, isTrue);
    fog.scrollController.jumpTo(60);
    await tester.pump();
    final select = tester
        .widget<DetailAppBar>(find.byType(DetailAppBar))
        .onVariantSelected;
    Animation<double> fade() => tester
        .widget<FadeTransition>(find
            .ancestor(
                of: find.byType(BodyContent),
                matching: find.byType(FadeTransition))
            .first)
        .opacity;
    select('b');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 75));
    expect(details.selectedVariantName, 'a');
    expect(fade().value, closeTo(0.5, 0.01));
    select('c');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(details.selectedVariantName, 'c');
    await tester.pump(const Duration(milliseconds: 160));
    expect(fade().value, 1);
    expect(fog.scrollController.offset, 60);
    expect(find.byType(ModelDetailContent), findsOneWidget);
    for (var i = 0; i < 8; i++) {
      select('variant$i');
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump(const Duration(milliseconds: 160));
    expect(details.selectedVariantName, 'variant7');
    expect(fade().value, 1);
    select('disposed');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}
