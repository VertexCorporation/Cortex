import 'dart:io';

import 'package:cortex/library/backend/security.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ModelSecurity download URL validation', () {
    test('accepts public HTTPS URLs', () {
      final uri = ModelSecurity.requireTrustedDownloadUri(
          'https://huggingface.co/org/model/resolve/main/model.gguf');
      expect(uri.scheme, 'https');
      expect(uri.host, 'huggingface.co');

      final fcDomain = ModelSecurity.requireTrustedDownloadUri(
          'https://fcdn.example.com/model.gguf');
      expect(fcDomain.host, 'fcdn.example.com');
    });

    test('rejects clear-text and private hosts', () {
      expect(
        () => ModelSecurity.requireTrustedDownloadUri(
            'http://example.com/model.gguf'),
        throwsFormatException,
      );
      expect(
        () => ModelSecurity.requireTrustedDownloadUri(
            'https://127.0.0.1/model.gguf'),
        throwsFormatException,
      );
      expect(
        () => ModelSecurity.requireTrustedDownloadUri(
            'https://192.168.1.5/model.gguf'),
        throwsFormatException,
      );
    });
  });

  group('ModelSecurity model paths', () {
    test('preserves ordinary legacy IDs', () {
      final path = ModelSecurity.resolveModelFilePath(
        filesDir: '/tmp/cortex-models',
        modelId: 'gemma-3-4b-q4',
      );
      expect(path, p.normalize('/tmp/cortex-models/gemma-3-4b-q4.gguf'));
    });

    test('prevents traversal outside the model directory', () {
      final base = p.normalize(p.absolute('/tmp/cortex-models'));
      final path = ModelSecurity.resolveModelFilePath(
        filesDir: base,
        modelId: '../../outside',
      );
      expect(p.isWithin(base, path), isTrue);
      expect(path, isNot(contains('..')));
    });
  });

  group('ModelSecurity catalog guards', () {
    test('rejects empty and catastrophic catalog replacements', () {
      expect(
        ModelSecurity.isPlausibleCatalogReplacement(
            existingCount: 300, incomingCount: 0),
        isFalse,
      );
      expect(
        ModelSecurity.isPlausibleCatalogReplacement(
            existingCount: 300, incomingCount: 80),
        isFalse,
      );
      expect(
        ModelSecurity.isPlausibleCatalogReplacement(
            existingCount: 300, incomingCount: 200),
        isTrue,
      );
    });

    test('disambiguates duplicate top-level IDs deterministically', () {
      final result = ModelSecurity.disambiguateDuplicateModelIds([
        {'id': 'vision', 'producer': 'Google'},
        {'id': 'vision', 'producer': 'Meta'},
        {'id': 'unique', 'producer': 'OpenAI'},
      ]);

      expect(result.map((m) => m['id']).toList(),
          ['google--vision', 'meta--vision', 'unique']);
    });
  });

  test('validates GGUF magic bytes', () async {
    final dir = await Directory.systemTemp.createTemp('cortex_gguf_test_');
    addTearDown(() async {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    final valid = File(p.join(dir.path, 'valid.gguf'));
    await valid.writeAsBytes([0x47, 0x47, 0x55, 0x46, 0, 0, 0, 0]);
    expect(await ModelSecurity.isValidGgufFile(valid), isTrue);

    final invalid = File(p.join(dir.path, 'invalid.gguf'));
    await invalid.writeAsBytes([0x50, 0x4b, 0x03, 0x04]);
    expect(await ModelSecurity.isValidGgufFile(invalid), isFalse);
  });
}