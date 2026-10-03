import 'dart:io';

import 'package:cortex/chat/services/document_artifacts.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  setUp(() async {
    root = await Directory.systemTemp.createTemp('artifact_safety');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.path);
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await root.delete(recursive: true);
  });

  test('concurrent identical names retain both outputs', () async {
    final results = await Future.wait([
      for (final content in ['first', 'second'])
        DocumentArtifactService.create({
          'format': 'txt',
          'file_name': 'same.txt',
          'content': content,
        }),
    ]);
    expect(results[0]['path'], isNot(results[1]['path']));
    expect(await File(results[0]['path']).readAsString(), 'first');
    expect(await File(results[1]['path']).readAsString(), 'second');
  });

  test(
    'share rejects private files and symlinks outside artifact directory',
    () async {
      final artifact = await DocumentArtifactService.create({
        'format': 'txt',
        'content': 'safe',
      });
      final private = await File('${root.path}/private.txt')
          .writeAsString('private');
      await expectLater(
        DocumentArtifactService.resolveShareableArtifact(private.path),
        throwsArgumentError,
      );
      final link = Link('${File(artifact['path']).parent.path}/link.txt');
      await link.create(private.path);
      await expectLater(
        DocumentArtifactService.resolveShareableArtifact(link.path),
        throwsArgumentError,
      );
      expect(
        await (await DocumentArtifactService.resolveShareableArtifact(
          artifact['path'],
        )).readAsString(),
        'safe',
      );
    },
  );

  test('explicit Sheet1 is retained alongside other sheets', () async {
    final artifact = await DocumentArtifactService.create({
      'format': 'xlsx',
      'sheets': [
        {
          'name': 'Sheet1',
          'rows': [
            ['keep me'],
          ],
        },
        {
          'name': 'Other',
          'rows': [
            [2],
          ],
        },
      ],
    });
    final book = Excel.decodeBytes(await File(artifact['path']).readAsBytes());
    expect(book.tables.keys, containsAll(['Sheet1', 'Other']));
    expect(book['Sheet1'].rows.first.first!.value.toString(), 'keep me');
  });

  test('missing replacements fail without changing the source', () async {
    final source = await File('${root.path}/source.txt')
        .writeAsString('original');
    await expectLater(
      DocumentArtifactService.edit({
        'operations': [
          {'type': 'replace_text', 'find': 'absent', 'replace': 'new'},
        ],
      }, sourcePath: source.path),
      throwsArgumentError,
    );
    expect(await source.readAsString(), 'original');
  });
}
