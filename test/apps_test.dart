import 'package:cortex/apps/categories.dart';
import 'package:cortex/apps/chat_tools.dart';
import 'package:cortex/apps/controller.dart';
import 'package:cortex/apps/models.dart';
import 'package:cortex/apps/widgets.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

CortexApp _app(Map<String, dynamic> json) => CortexApp.fromJson(json);

void main() {
  group('CortexApp', () {
    test('parses the Fulcrum getIntegrations item contract', () {
      final app = _app({
        'slug': 'gmail',
        'name': 'Gmail',
        'logo': 'https://logos.composio.dev/api/gmail',
        'description': ' Read and manage Gmail ',
        'categories': [
          {'id': 'communication', 'name': 'Communication'},
          {'id': '', 'name': ''},
        ],
        'toolsCount': 42,
        'connected': true,
        'connectionStatus': 'ACTIVE',
        'connectedAccountId': 'ca_123',
        'permission': 'read_only',
      });
      expect(app.slug, 'gmail');
      expect(app.description, 'Read and manage Gmail');
      expect(app.categories, hasLength(1));
      expect(app.toolsCount, 42);
      expect(app.connected, isTrue);
      expect(app.permission, AppPermission.readOnly);
    });

    test('rejects insecure logos and defaults permission to ask', () {
      final app = _app({'slug': 'x', 'logo': 'http://example.com/x.png'});
      expect(app.logo, isNull);
      expect(app.permission, AppPermission.ask);
      expect(app.name, 'x');
    });

    test('permission wire values match Fulcrum', () {
      expect(AppPermission.values.map((p) => p.wire),
          ['ask', 'allow', 'read_only', 'off']);
      expect(AppPermission.fromWire('nonsense'), AppPermission.ask);
    });
  });

  group('AppGroup', () {
    AppGroup? group(String id) => AppGroup.of(AppCategory(id: id, name: id));

    test('maps Composio categories to localized shelves', () {
      expect(group('productivity'), AppGroup.productivity);
      expect(group('communication'), AppGroup.communication);
      expect(group('crm'), AppGroup.sales);
      expect(group('developer-tools'), AppGroup.developer);
      expect(group('cloud-storage'), AppGroup.files);
      expect(group('social-media'), AppGroup.social);
      expect(group('ai'), AppGroup.ai);
      expect(group('calendar'), AppGroup.scheduling);
    });

    test('short keywords only match whole segments', () {
      // "ai" inside "email" must not make it an AI app.
      expect(group('email'), AppGroup.communication);
      expect(group('unknown-thing'), isNull);
    });
  });

  group('AppsController permissions', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'cortex_apps_state_v1':
            '{"connected":[{"slug":"gmail","name":"Gmail","logo":null,"permission":"allow"},'
                '{"slug":"notion","name":"Notion","logo":null,"permission":"off"}],'
                '"permissions":{"notion":"off"}}',
      });
    });

    test('restores connections and hides apps that are off from chat', () async {
      final controller = AppsController.instance;
      await controller.restore();
      expect(controller.permissionFor('gmail'), AppPermission.allow);
      expect(controller.permissionFor('notion'), AppPermission.off);
      expect(controller.permissionFor('slack'), AppPermission.ask);
      expect(controller.chatApps.map((a) => a.slug), ['gmail']);

      final tools = AppChatTools.toolsJson();
      expect(tools.map((t) => t['function']['name']),
          [AppChatTools.findTool, AppChatTools.runTool]);
      final appEnum = tools.first['function']['parameters']['properties']['app']['enum'];
      expect(appEnum, ['gmail']);
    });
  });

  testWidgets('AppRow shows name, description and connection state',
      (tester) async {
    final app = _app({
      'slug': 'notion',
      'name': 'Notion',
      'description': 'Create docs, tasks, databases',
      'connected': false,
    });
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: AppRow(app: app, onTap: () => taps++)),
    ));
    expect(find.text('Notion'), findsOneWidget);
    expect(find.text('Create docs, tasks, databases'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    // Logo falls back to the monogram without a URL.
    expect(find.text('N'), findsOneWidget);
    await tester.tap(find.text('Notion'));
    expect(taps, 1);
  });

  testWidgets('Apps strings exist in Turkish', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        l10n = AppLocalizations.of(context)!;
        return const SizedBox();
      }),
    ));
    expect(l10n.appsTitle, 'Uygulamalar');
    expect(l10n.appsInstalled, 'Kurulu');
    expect(l10n.appsSearchHint, 'Uygulamalarda ara');
    expect(l10n.appsConfirmTitle('Gmail'), 'Gmail için izin verilsin mi?');
  });
}
