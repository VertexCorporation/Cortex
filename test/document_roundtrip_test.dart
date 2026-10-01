import 'dart:convert';
import 'dart:io';

import 'package:cortex/chat/services/document_artifacts.dart';
import 'package:cortex/rag/extractors.dart';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  setUp(() async {
    root = await Directory.systemTemp.createTemp('document_roundtrip');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.path);
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await root.delete(recursive: true);
  });

  for (final format in ['docx', 'pptx', 'txt', 'md']) {
    test('$format output can be read again with Turkish text and XML characters', () async {
      const body = 'İstanbul, çağrı ve şarkı: <başlık> & "not".';
      final artifact = await DocumentArtifactService.create({
        'format': format, 'title': 'Rapor', 'content': body,
      });
      final text = await DocTextExtractor().extractText(artifact['path']);
      expect(text, contains('Rapor'));
      expect(text, contains(body));
    });
  }

  test('reading a twelve-slide presentation preserves slide order', () async {
    final artifact = await DocumentArtifactService.create({
      'format': 'pptx',
      'slides': [
        for (var i = 1; i <= 12; i++) {'title': 'Topic $i.', 'body': 'Body $i.'},
      ],
    });
    final text = (await DocTextExtractor().extractText(artifact['path']))!;
    var position = -1;
    for (var i = 1; i <= 12; i++) {
      final next = text.indexOf('Topic $i.');
      expect(next, greaterThan(position));
      position = next;
    }
  });

  test('XLSX edits preserve typed cells and the original workbook', () async {
    final source = await DocumentArtifactService.create({
      'format': 'xlsx', 'rows': [['Name', 'Count', 'Ready'], ['old', 12, true]],
    });
    final original = await File(source['path']).readAsBytes();
    final revised = await DocumentArtifactService.edit({
      'operations': [
        {'type': 'replace_text', 'find': 'old', 'replace': 'new'},
        {'type': 'set_cell', 'cell': 'B2', 'value': 24},
        {'type': 'append_row', 'values': ['next', 6, false]},
      ],
    }, sourcePath: source['path']);
    final workbook = excel.Excel.decodeBytes(await File(revised['path']).readAsBytes());
    final rows = workbook['Sheet1'].rows;
    expect(rows[1][0]!.value.toString(), 'new');
    expect(rows[1][1]!.value, isA<excel.IntCellValue>());
    expect(rows[1][1]!.value.toString(), '24');
    expect(rows[1][2]!.value, isA<excel.BoolCellValue>());
    expect(rows[2][0]!.value.toString(), 'next');
    expect(await File(source['path']).readAsBytes(), original);
    expect(await DocTextExtractor().extractText(revised['path']), contains('new'));
  });

  test('CSV escapes commas, quotes and carriage returns without data loss', () async {
    final artifact = await DocumentArtifactService.create({
      'format': 'csv', 'rows': [['one,two', 'a"b', 'first\rsecond', 'şarkı']],
    });
    expect(await File(artifact['path']).readAsString(),
        '"one,two","a""b","first\rsecond",şarkı');
  });

  test('JSON round trip preserves structured data and rejects an invalid edit', () async {
    final data = {'city': 'İstanbul', 'rows': [1, true, null]};
    final artifact = await DocumentArtifactService.create({'format': 'json', 'data': data});
    final original = await File(artifact['path']).readAsString();
    expect(jsonDecode(original), data);
    await expectLater(DocumentArtifactService.edit({
      'operations': [{'type': 'append_text', 'text': 'invalid JSON'}],
    }, sourcePath: artifact['path']), throwsFormatException);
    expect(await File(artifact['path']).readAsString(), original);
  });

  test('PDF generation writes a PDF container rather than a text placeholder', () async {
    final artifact = await DocumentArtifactService.create({
      'format': 'pdf', 'title': 'Cortex report', 'content': 'Document content.',
    });
    final bytes = await File(artifact['path']).readAsBytes();
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(latin1.decode(bytes), contains('%%EOF'));
    expect(artifact['media_type'], 'application/pdf');
  });
}
