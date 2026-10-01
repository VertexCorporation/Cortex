import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/widgets/offline_setup.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/backend/download/download.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Session extends ChangeNotifier implements ChatSessionProvider {
  @override
  bool get isUserSubscribed => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Catalogue extends ChangeNotifier implements ModelService {
  @override
  Future<List<ModelEntity>?> getModels({required String langCode}) async => [
    ModelEntity.fromMap({'id': 'offline-test', 'title': 'Device model',
      'type': 'offline', 'tier': 'free', 'ram': 1024, 'size': 512,
      'url': 'https://example.com/model.gguf'}, langCode),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Local extends ChangeNotifier implements ModelLocalStateProvider {
  int downloads = 0;
  @override
  Map<String, bool> get downloadCompleted => const {};
  @override
  Map<String, DownloadManager> get downloadManagers => const {};
  @override
  Future<bool> requestPermissionAndStartDownload({required BuildContext context,
      required String id, required String? url}) async {
    downloads++;
    return false;
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('offline setup explains, offers choice, then waits for download consent', (tester) async {
    for (final channel in ['com.vertex.cortex/memory', 'com.vertex.cortex/storage']) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        MethodChannel(channel), (call) async => call.method == 'getUsedMemory' ? 2048 : 8192);
    }
    addTearDown(() {
      for (final channel in ['com.vertex.cortex/memory', 'com.vertex.cortex/storage']) {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(MethodChannel(channel), null);
      }
    });
    final local = _Local();
    addTearDown(local.dispose);
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<ChatSessionProvider>(create: (_) => _Session()),
      ChangeNotifierProvider<ModelLocalStateProvider>.value(value: local),
      ChangeNotifierProvider<ModelService>(create: (_) => _Catalogue()),
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider('dark')),
    ], child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const Scaffold(body: OfflineSetupSheet()),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Would you like to use Cortex offline?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Choose an intelligence'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Device model'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(local.downloads, 0);
    await tester.tap(find.text('Download'));
    await tester.pump();
    expect(local.downloads, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
