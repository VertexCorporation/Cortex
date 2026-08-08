// test/rag_extractors_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:cortex/rag/extractors.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a minimal DOCX (a zip containing word/document.xml) in memory.
Uint8List _buildDocx(List<String> paragraphs) {
  final sb = StringBuffer('<w:document><w:body>');
  for (final paragraph in paragraphs) {
    sb.write('<w:p><w:r><w:t xml:space="preserve">');
    sb.write(paragraph.replaceAll('&', '&amp;').replaceAll('<', '&lt;'));
    sb.write('</w:t></w:r></w:p>');
  }
  sb.write('</w:body></w:document>');

  final archive = Archive()
    ..addFile(ArchiveFile(
      'word/document.xml',
      sb.length,
      utf8.encode(sb.toString()),
    ));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

void main() {
  final extractor = DocTextExtractor();
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('rag_extract_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('extracts plain text files with UTF-8 content', () async {
    final file = File('${tempDir.path}/ornek.txt')
      ..writeAsStringSync('Merhaba dünya!\nİkinci satır.');
    final text = await extractor.extractText(file.path);
    expect(text, contains('Merhaba dünya!'));
    expect(text, contains('İkinci satır.'));
  });

  test('returns null for missing files', () async {
    expect(await extractor.extractText('${tempDir.path}/yok.pdf'), isNull);
  });

  test('falls back to the server parser for legacy formats', () async {
    final file = File('${tempDir.path}/eski.doc')
      ..writeAsStringSync('binary-ish');
    final text = await extractor.extractText(
      file.path,
      serverFallback: (_) async => 'Sunucudan gelen metin',
    );
    expect(text, 'Sunucudan gelen metin');
  });

  test('server fallback may still return null', () async {
    final file = File('${tempDir.path}/eski.xls')
      ..writeAsStringSync('binary-ish');
    final text = await extractor.extractText(
      file.path,
      serverFallback: (_) async => null,
    );
    expect(text, isNull);
  });

  test('unknown extensions are read as plain text', () async {
    final file = File('${tempDir.path}/veri.xyz')
      ..writeAsStringSync('sadece metin içeriği');
    final text = await extractor.extractText(file.path);
    expect(text, 'sadece metin içeriği');
  });

  test('extracts text from a minimal docx', () async {
    final file = File('${tempDir.path}/belge.docx')
      ..writeAsBytesSync(_buildDocx(['Başlık paragrafı', 'İkinci paragraf']));
    final text = await extractor.extractText(file.path);
    expect(text, contains('Başlık paragrafı'));
    expect(text, contains('İkinci paragraf'));
  });

  test('returns null when docx extraction fails', () async {
    final file = File('${tempDir.path}/bozuk.docx')
      ..writeAsStringSync('not a zip');
    final text = await extractor.extractText(file.path);
    expect(text, isNull);
  });
}
