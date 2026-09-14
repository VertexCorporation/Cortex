import 'dart:io';

import 'package:cortex/chat/services/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('scoped binary document attachments', () {
    test('PDF metadata is scoped without eager base64 encoding', () async {
      final dir = await Directory.systemTemp.createTemp('cortex_document_test');
      addTearDown(() => dir.delete(recursive: true));

      final pdf = File('${dir.path}/report.pdf');
      await pdf.writeAsBytes('%PDF-1.4\n% Cortex regression fixture\n'.codeUnits);

      final block = await Utils.processAttachment(pdf.path);

      expect(block, isNotNull);
      expect(block!['type'], 'text');

      final document = Map<String, dynamic>.from(block['_document'] as Map);
      final scope = document['scope']?.toString();

      expect(scope, isNotNull);
      expect(scope, isNotEmpty);
      expect(document['path'], pdf.path);
      expect(document['fileName'], 'report.pdf');
      expect(document['extension'], 'pdf');
      expect(document.containsKey('data'), isFalse,
          reason: 'binary bytes must be encoded only when read_document runs');
      expect(block['text'].toString(), contains(scope!));

      final extracted = Utils.extractDocuments([block]);
      expect(extracted, hasLength(1));
      expect(extracted.single['scope'], scope);
      expect(extracted.single['path'], pdf.path);

      final cleaned = Utils.cleanContentBlocks([block]);
      expect(cleaned.single.containsKey('_document'), isFalse);
      expect(cleaned.single['text'].toString(), contains(scope));
    });

    test('processing the same PDF twice creates independent scopes', () async {
      final dir = await Directory.systemTemp.createTemp('cortex_document_test');
      addTearDown(() => dir.delete(recursive: true));

      final pdf = File('${dir.path}/same-name.pdf');
      await pdf.writeAsBytes('%PDF-1.4\n% scope isolation\n'.codeUnits);

      final first = await Utils.processAttachment(pdf.path);
      final second = await Utils.processAttachment(pdf.path);

      final firstScope = (first!['_document'] as Map)['scope'];
      final secondScope = (second!['_document'] as Map)['scope'];

      expect(firstScope, isNot(equals(secondScope)),
          reason: 'concurrent chat turns must never share document identity');
    });
  });
}
