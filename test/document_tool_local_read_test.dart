import 'dart:io';

import 'package:cortex/chat/services/document_artifacts.dart';
import 'package:cortex/chat/services/tools.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cortex_local_document_tool');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.path);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('read_document reads supported attachments locally', () async {
    const expectedText = 'The local document reader works.';
    final artifact = await DocumentArtifactService.create({
      'format': 'docx',
      'title': 'Local reading check',
      'content': expectedText,
    });
    const scope = 'local-read-test-scope';
    ToolRegistry.setDocumentsContext([
      {
        'scope': scope,
        'path': artifact['path'],
        'extension': 'docx',
        'fileName': artifact['file_name'],
      },
    ]);
    ToolRegistry.initialize();

    final tool = ToolRegistry.getTool('read_document');
    expect(tool, isNotNull);
    final result = await tool!.function({'document_scope': scope});

    expect(result, contains('Local reading check'));
    expect(result, contains(expectedText));
  });
}
