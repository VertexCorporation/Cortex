// test/media_classification_test.dart
// Regression for the "attachment dropped" symptom: the composer's image
// classification (MediaRouter), the input picker's classification
// (InputService lists share the same extension set) and the serializer
// (Utils.processAttachment, mime-based) must agree on what an image IS.
// Historically MediaRouter excluded .heic/.heif/.bmp while the serializer
// happily sent them as image_url — the MediaTrace counted image=0 for a
// visible photo and the client-side vision intent never fired.
import 'dart:io';
import 'package:cortex/chat/services/send/media.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeModelService implements ModelService {
  @override
  ModelEntity getPreciseModelData(String modelId, {required String langCode}) {
    return ModelEntity.fromMap({'id': modelId, 'isServerSide': true, 'name': 'Dummy'}, 'en');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final router = MediaRouter(FakeModelService());

  group('MediaRouter.isImageFile — one image definition everywhere', () {
    test('recognizes the full image set incl. iPhone HEIC/HEIF and BMP', () {
      for (final ext in ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic', 'heif']) {
        expect(router.isImageFile('/tmp/photo.$ext'), isTrue, reason: '.$ext must be an image');
      }
    });

    test('still excludes non-images', () {
      for (final ext in ['mp4', 'mov', 'mp3', 'pdf', 'txt', 'docx']) {
        expect(router.isImageFile('/tmp/file.$ext'), isFalse, reason: '.$ext must not be an image');
      }
    });
  });

  group('Utils.processAttachment — the serializer speaks image_url for every image type', () {
    test('a real jpg serializes into an image_url block', () async {
      final dir = await Directory.systemTemp.createTemp('cortex_media_test');
      final jpg = File('${dir.path}/photo.jpg');
      await jpg.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]); // JPEG magic bytes

      final block = await Utils.processAttachment(jpg.path);
      expect(block, isNotNull);
      expect(block!['type'], 'image_url'); // the exact block [ChatRequest] counts
      expect((block['image_url'] as Map)['url'],
          startsWith('data:image/jpeg;base64,'));

      await dir.delete(recursive: true);
    });

    test('HEIC serializes as image_url too (mime-based, matches the classifier)', () async {
      final dir = await Directory.systemTemp.createTemp('cortex_media_test');
      final heic = File('${dir.path}/IMG_0001.heic');
      await heic.writeAsBytes([0x00, 0x00, 0x00, 0x18]);

      final block = await Utils.processAttachment(heic.path);
      expect(block, isNotNull, reason: 'the serializer must recognize HEIC');
      expect(block!['type'], 'image_url');

      await dir.delete(recursive: true);
    });
  });
}
