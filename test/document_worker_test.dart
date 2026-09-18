import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cortex/rag/extractors.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  setUp(
    () async =>
        directory = await Directory.systemTemp.createTemp('cortex_worker_'),
  );
  tearDown(() async => directory.delete(recursive: true));

  Future<String> archiveFile(String name, String entry, String text) async {
    final xml = utf8.encode(text);
    final archive = Archive()..addFile(ArchiveFile(entry, xml.length, xml));
    final file = File('${directory.path}/$name');
    await file.writeAsBytes(ZipEncoder().encode(archive)!);
    return file.path;
  }

  test('worker preserves docx Unicode paragraphs', () async {
    final path = await archiveFile(
      'sample.docx',
      'word/document.xml',
      '<w:document xmlns:w="word"><w:p><w:r><w:t>İstanbul 🌍</w:t></w:r></w:p>'
          '<w:p><w:r><w:t>Second paragraph</w:t></w:r></w:p></w:document>',
    );
    expect(
      await DocTextExtractor().extractText(path),
      'İstanbul 🌍\nSecond paragraph\n',
    );
  });

  test('worker preserves powerpoint slide text', () async {
    final path = await archiveFile(
      'sample.pptx',
      'ppt/slides/slide1.xml',
      '<a:slide xmlns:a="slide"><a:p><a:r><a:t>Slide content</a:t></a:r></a:p></a:slide>',
    );
    expect(
      await DocTextExtractor().extractText(path),
      contains('Slide content'),
    );
  });

  test('worker preserves spreadsheet text and numeric cells', () async {
    final excel = Excel.createExcel();
    excel['Sheet1'].appendRow([TextCellValue('Revenue'), IntCellValue(42)]);
    final file = File('${directory.path}/sample.xlsx');
    await file.writeAsBytes(excel.encode()!);
    expect(
      await DocTextExtractor().extractText(file.path),
      contains('Revenue | 42'),
    );
  });

  test('corrupt Office file fails without invoking network fallback', () async {
    final file = File('${directory.path}/broken.docx');
    await file.writeAsString('not a zip');
    var fallbackCalls = 0;
    expect(
      await DocTextExtractor().extractText(
        file.path,
        serverFallback: (_) async {
          fallbackCalls++;
          return 'fallback';
        },
      ),
      isNull,
    );
    expect(fallbackCalls, 0);
  });
}
