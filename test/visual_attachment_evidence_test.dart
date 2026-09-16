import 'dart:io';

import 'package:cortex/chat/services/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('visual_evidence_');
  });
  tearDown(() async => directory.delete(recursive: true));

  test(
    'missing and empty images cannot silently become text-only requests',
    () async {
      final path = '${directory.path}/photo.jpg';
      await expectLater(Utils.requireAttachment(path), throwsStateError);
      await File(path).writeAsBytes([]);
      await expectLater(Utils.requireAttachment(path), throwsStateError);
    },
  );

  test(
    'extensionless picker images keep their image block in history',
    () async {
      final file = File('${directory.path}/picker_cache');
      await file.writeAsBytes([0xff, 0xd8, 0xff, 0xe0, 0, 16]);
      expect(await Utils.mediaKind(file.path), 'image');
      final block = await Utils.requireAttachment(file.path);
      expect(block['type'], 'image_url');
    },
  );

  test('remote query strings and inline images are recognized', () async {
    expect(
      await Utils.mediaKind('https://example.com/photo.png?version=2'),
      'image',
    );
    expect(await Utils.mediaKind('data:image/png;base64,AA=='), 'image');
    expect(await Utils.mediaKind('https://example.com/file.pdf'), isNull);
  });

  test('history video and audio retain their actual block types', () async {
    for (final kind in ['video', 'audio']) {
      final path = 'data:$kind/${kind == 'video' ? 'mp4' : 'wav'};base64,AA==';
      expect(await Utils.mediaKind(path), kind);
      expect((await Utils.requireAttachment(path))['type'], '${kind}_url');
    }
  });
}
