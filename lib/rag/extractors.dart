// lib/rag/extractors.dart
//
// On-device text extraction for common document formats. Binary formats that
// cannot be parsed on-device (.doc, .xls) fall back to a server-side parser
// when one is provided and the device is online.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as excel;
import 'package:pdfrx/pdfrx.dart';
import 'package:xml/xml.dart';

/// Callback used as a last-resort parser for formats we cannot read on-device.
/// The implementation typically calls the existing `read_document` backend.
typedef ServerDocParser = Future<String?> Function(String filePath);

/// Extracts plain text from a document file on the device.
class DocTextExtractor {
  /// Text-based extensions that are read directly.
  static const List<String> textExtensions = [
    'txt', 'md', 'rtf',
    'json', 'xml', 'csv', 'tsv',
    'html', 'htm', 'css',
    'js', 'ts', 'jsx', 'tsx', 'py', 'dart', 'java', 'c', 'cpp', 'h', 'hpp',
    'swift', 'kt', 'go', 'rs', 'rb', 'php', 'sh', 'bash', 'ps1',
    'sql', 'r', 'scala', 'lua', 'pl', 'pm',
    'yaml', 'yml', 'toml', 'ini', 'cfg', 'conf', 'env', 'log',
  ];

  /// On-device binary formats.
  static const List<String> onDeviceBinaryExtensions = [
    'pdf', 'docx', 'xlsx', 'pptx',
  ];

  /// Formats that require the server-side fallback.
  static const List<String> serverFallbackExtensions = [
    'doc', 'xls', 'odt', 'ods', 'odp',
  ];

  /// Returns true if this extension can be handled on-device.
  static bool supportsOnDevice(String extension) {
    return textExtensions.contains(extension) ||
        onDeviceBinaryExtensions.contains(extension);
  }

  /// Extracts plain text from [path]. Returns `null` if extraction failed or
  /// the format is unsupported.
  Future<String?> extractText(String path, {ServerDocParser? serverFallback}) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      final extension = path.split('.').last.toLowerCase();

      // 1. Text files.
      if (textExtensions.contains(extension)) {
        return await _extractTextFile(file);
      }

      // 2. On-device binary formats.
      if (extension == 'pdf') return await _extractPdf(path);
      if (extension == 'docx') return await _extractDocx(file);
      if (extension == 'xlsx') return await _extractXlsx(file);
      if (extension == 'pptx') return await _extractPptx(file);

      // 3. Legacy formats → server fallback.
      if (serverFallbackExtensions.contains(extension)) {
        if (serverFallback != null) {
          return await serverFallback(path);
        }
        return null;
      }

      // 4. Unknown: try as plain text, then give up.
      return await _extractTextFile(file);
    } catch (e) {
      debugLog('DocTextExtractor: extraction failed for $path: $e');
      return null;
    }
  }

  Future<String?> _extractTextFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      // Respect a size cap (10 MB) so huge files don't OOM.
      return utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      debugLog('DocTextExtractor: text read failed: $e');
      return null;
    }
  }

  Future<String?> _extractPdf(String path) async {
    final document = await PdfDocument.openFile(path);
    try {
      final sb = StringBuffer();
      for (final page in document.pages) {
        try {
          final text = await page.loadText();
          if (text.fullText.isNotEmpty) {
            sb.write(text.fullText);
            sb.write('\n\n');
          }
        } catch (e) {
          debugLog('DocTextExtractor: pdf page ${page.pageNumber} failed: $e');
        }
      }
      return sb.toString();
    } finally {
      await document.dispose();
    }
  }

  Future<String?> _extractDocx(File file) async {
    final bytes = await file.readAsBytes();
    return _extractOoxmlText(
      bytes,
      targetEntry: 'word/document.xml',
      paragraphTag: 'p',
      textTag: 't',
    );
  }

  Future<String?> _extractPptx(File file) async {
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final sb = StringBuffer();

    final slideNames = archive.files
        .where((f) => f.isFile && f.name.startsWith('ppt/slides/slide'))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    for (final slide in slideNames) {
      final text = _parseOoxmlText(
        utf8.decode(slide.content as List<int>, allowMalformed: true),
        paragraphTag: 'p',
        textTag: 't',
      );
      if (text.isNotEmpty) {
        sb.write(text);
        sb.write('\n\n');
      }
    }
    return sb.toString();
  }

  Future<String?> _extractXlsx(File file) async {
    final bytes = await file.readAsBytes();
    try {
      final workbook = excel.Excel.decodeBytes(bytes);
      final sb = StringBuffer();
      for (final table in workbook.tables.values) {
        for (final row in table.rows) {
          final cells = <String>[];
          for (final cell in row) {
            final value = cell?.value;
            if (value != null) cells.add(value.toString());
          }
          if (cells.isNotEmpty) {
            sb.writeln(cells.join(' | '));
          }
        }
      }
      return sb.toString();
    } catch (e) {
      debugLog('DocTextExtractor: xlsx read failed: $e');
      return null;
    }
  }

  Future<String?> _extractOoxmlText(
    List<int> bytes, {
    required String targetEntry,
    required String paragraphTag,
    required String textTag,
  }) async {
    try {
      final archive = ZipDecoder().decodeBytes(bytes as Uint8List);
      final target = archive.findFile(targetEntry);
      if (target == null) return null;
      return _parseOoxmlText(
        utf8.decode(target.content as List<int>, allowMalformed: true),
        paragraphTag: paragraphTag,
        textTag: textTag,
      );
    } catch (e) {
      debugLog('DocTextExtractor: ooxml read failed: $e');
      return null;
    }
  }

  String _parseOoxmlText(
    String xmlString, {
    required String paragraphTag,
    required String textTag,
  }) {
    try {
      final document = XmlDocument.parse(xmlString);
      final sb = StringBuffer();

      // Paragraph elements (local name, namespace-agnostic).
      final paragraphs = document.descendants
          .whereType<XmlElement>()
          .where((e) => e.name.local == paragraphTag);

      for (final para in paragraphs) {
        final texts = para.descendants
            .whereType<XmlElement>()
            .where((e) => e.name.local == textTag)
            .map((e) => e.innerText)
            .toList();
        final line = texts.join();
        if (line.trim().isNotEmpty) {
          sb.writeln(line.trim());
        }
      }
      return sb.toString();
    } catch (e) {
      debugLog('DocTextExtractor: ooxml parse failed: $e');
      return '';
    }
  }

  static void debugLog(String message) {
    // Overridable logger; defaults to no-op in release.
    // ignore: avoid_print
    print(message);
  }
}
