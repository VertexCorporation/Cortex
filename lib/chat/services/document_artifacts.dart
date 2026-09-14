import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cortex/rag/extractors.dart';

/// Deterministic on-device file engine used by the chat tools.
///
/// The model decides WHAT should be created or changed. Cortex owns the file
/// format work so online models and Dynamic Chat never need to emit binary
/// files or understand OOXML/PDF internals.
class DocumentArtifactService {
  static const int _maxToolPayloadChars = 750000;

  static const Set<String> supportedCreateFormats = {
    'pdf',
    'docx',
    'xlsx',
    'pptx',
    'txt',
    'md',
    'csv',
    'json',
  };

  static const Set<String> supportedEditFormats = {
    'pdf',
    'docx',
    'xlsx',
    'pptx',
    'txt',
    'md',
    'csv',
    'json',
  };

  static Future<Map<String, dynamic>> create(Map<String, dynamic> args) async {
    _guardToolPayload(args);

    final format = (args['format'] ?? 'pdf').toString().toLowerCase().trim();
    if (!supportedCreateFormats.contains(format)) {
      throw ArgumentError('Unsupported document format: $format');
    }

    final output = await _outputFile(
      requestedName: args['file_name']?.toString(),
      extension: format,
      fallbackBase: 'cortex_document',
    );

    switch (format) {
      case 'pdf':
        await _writePdf(output, args);
        break;
      case 'docx':
        await _writeDocx(output, args);
        break;
      case 'xlsx':
        await _writeXlsx(output, args);
        break;
      case 'pptx':
        await _writePptx(output, args);
        break;
      case 'txt':
      case 'md':
        await output.writeAsString(_plainDocumentText(args), flush: true);
        break;
      case 'csv':
        await output.writeAsString(_csvText(args), flush: true);
        break;
      case 'json':
        await output.writeAsString(
          const JsonEncoder.withIndent('  ').convert(
            args['data'] ?? _documentJson(args),
          ),
          flush: true,
        );
        break;
    }

    return _artifactMetadata(
      output,
      format: format,
      summary: 'Created ${p.basename(output.path)}.',
    );
  }

  /// Produces a revised copy. The user's original file is never overwritten.
  static Future<Map<String, dynamic>> edit(
    Map<String, dynamic> args, {
    required String sourcePath,
  }) async {
    _guardToolPayload(args);

    final source = File(sourcePath);
    if (!await source.exists()) {
      throw ArgumentError('The source document no longer exists.');
    }

    final extension = p.extension(source.path).replaceFirst('.', '').toLowerCase();
    if (!supportedEditFormats.contains(extension)) {
      throw ArgumentError('Editing .$extension files is not supported.');
    }

    final operations = _mapList(args['operations']);
    if (operations.isEmpty) {
      throw ArgumentError('edit_document requires at least one operation.');
    }

    final output = await _outputFile(
      requestedName: args['file_name']?.toString(),
      extension: extension,
      fallbackBase: '${p.basenameWithoutExtension(source.path)}_edited',
    );

    String? warning;
    switch (extension) {
      case 'xlsx':
        await _editXlsx(source, output, operations);
        break;
      case 'pdf':
        warning = await _rebuildTextDocument(
          source,
          output,
          operations,
          format: 'pdf',
        );
        break;
      case 'docx':
        warning = await _rebuildTextDocument(
          source,
          output,
          operations,
          format: 'docx',
        );
        break;
      case 'pptx':
        warning = await _rebuildTextDocument(
          source,
          output,
          operations,
          format: 'pptx',
        );
        break;
      case 'txt':
      case 'md':
      case 'csv':
      case 'json':
        await _editTextFile(source, output, operations);
        break;
    }

    return _artifactMetadata(
      output,
      format: extension,
      summary:
          'Edited ${p.basename(source.path)} and created ${p.basename(output.path)}.',
      warning: warning,
    );
  }

  static void _guardToolPayload(Map<String, dynamic> args) {
    final encoded = jsonEncode(args);
    if (encoded.length > _maxToolPayloadChars) {
      throw ArgumentError('Document tool payload is too large.');
    }
  }

  static Future<File> _outputFile({
    required String? requestedName,
    required String extension,
    required String fallbackBase,
  }) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'Cortex', 'Documents'));
    await directory.create(recursive: true);

    final raw = (requestedName ?? '').trim();
    var baseName = raw.isEmpty
        ? '${fallbackBase}_${DateTime.now().millisecondsSinceEpoch}'
        : p.basename(raw);

    // Hyphen is deliberately last in the character class so the RegExp is
    // valid on every Dart target. This also prevents model-controlled paths.
    baseName = baseName.replaceAll(RegExp(r'[^A-Za-z0-9._() -]'), '_');
    if (baseName.isEmpty || baseName == '.' || baseName == '..') {
      baseName = '${fallbackBase}_${DateTime.now().millisecondsSinceEpoch}';
    }

    final wantedExtension = '.$extension';
    if (!baseName.toLowerCase().endsWith(wantedExtension)) {
      baseName = '${p.basenameWithoutExtension(baseName)}$wantedExtension';
    }

    var candidate = File(p.join(directory.path, baseName));
    if (await candidate.exists()) {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      candidate = File(
        p.join(
          directory.path,
          '${p.basenameWithoutExtension(baseName)}_$stamp$wantedExtension',
        ),
      );
    }
    return candidate;
  }

  static Map<String, dynamic> _artifactMetadata(
    File file, {
    required String format,
    required String summary,
    String? warning,
  }) {
    return {
      'path': file.path,
      'file_name': p.basename(file.path),
      'format': format,
      'media_type': _mediaTypeFor(format),
      'summary': summary,
      if (warning != null && warning.isNotEmpty) 'warning': warning,
    };
  }

  static String _mediaTypeFor(String extension) {
    return switch (extension) {
      'pdf' => 'application/pdf',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'pptx' =>
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'csv' => 'text/csv',
      'json' => 'application/json',
      'md' => 'text/markdown',
      _ => 'text/plain',
    };
  }

  // ---------------------------------------------------------------------------
  // PDF
  // ---------------------------------------------------------------------------

  static Future<void> _writePdf(File output, Map<String, dynamic> args) async {
    final document = pw.Document();

    pw.Font? regular;
    pw.Font? bold;
    try {
      regular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/inter/Inter-Regular.ttf'),
      );
      bold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/inter/Inter-Bold.ttf'),
      );
    } catch (_) {
      // Built-in fonts remain a fallback if bundled fonts cannot be loaded.
    }

    final theme = regular == null
        ? null
        : pw.ThemeData.withFont(base: regular, bold: bold ?? regular);

    final widgets = <pw.Widget>[];
    final title = (args['title'] ?? '').toString().trim();
    if (title.isNotEmpty) {
      widgets.add(pw.Header(level: 0, child: pw.Text(title)));
    }

    final content = (args['content'] ?? '').toString();
    widgets.addAll(_pdfParagraphs(content));

    for (final section in _mapList(args['sections'])) {
      final heading =
          (section['heading'] ?? section['title'] ?? '').toString().trim();
      final body = (section['body'] ?? section['content'] ?? '').toString();
      if (heading.isNotEmpty) {
        widgets.add(pw.SizedBox(height: 8));
        widgets.add(pw.Header(level: 1, child: pw.Text(heading)));
      }
      widgets.addAll(_pdfParagraphs(body));
    }

    for (final table in _mapList(args['tables'])) {
      final headers = _dynamicList(table['headers']);
      final rows = _rowList(table['rows']);
      if (headers.isEmpty && rows.isEmpty) continue;

      final data = <List<dynamic>>[
        if (headers.isNotEmpty)
          headers.map((value) => value?.toString() ?? '').toList(),
        ...rows.map(
          (row) => row.map((value) => value?.toString() ?? '').toList(),
        ),
      ];

      widgets.add(pw.SizedBox(height: 12));
      widgets.add(
        pw.TableHelper.fromTextArray(
          data: data,
          headerCount: headers.isNotEmpty ? 1 : 0,
        ),
      );
    }

    if (widgets.isEmpty) widgets.add(pw.Text(''));

    document.addPage(
      pw.MultiPage(
        theme: theme,
        build: (_) => widgets,
      ),
    );
    await output.writeAsBytes(await document.save(), flush: true);
  }

  static List<pw.Widget> _pdfParagraphs(String text) {
    if (text.trim().isEmpty) return const <pw.Widget>[];
    return _paragraphStrings(text)
        .map<pw.Widget>(
          (paragraph) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(paragraph),
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // DOCX
  // ---------------------------------------------------------------------------

  static Future<void> _writeDocx(File output, Map<String, dynamic> args) async {
    final body = StringBuffer();
    final title = (args['title'] ?? '').toString().trim();
    if (title.isNotEmpty) {
      body.write(_wordParagraph(title, bold: true, sizeHalfPoints: 32));
    }

    for (final paragraph in _paragraphStrings((args['content'] ?? '').toString())) {
      body.write(_wordParagraph(paragraph));
    }

    for (final section in _mapList(args['sections'])) {
      final heading =
          (section['heading'] ?? section['title'] ?? '').toString().trim();
      final sectionBody =
          (section['body'] ?? section['content'] ?? '').toString();
      if (heading.isNotEmpty) {
        body.write(_wordParagraph(heading, bold: true, sizeHalfPoints: 26));
      }
      for (final paragraph in _paragraphStrings(sectionBody)) {
        body.write(_wordParagraph(paragraph));
      }
    }

    for (final table in _mapList(args['tables'])) {
      final headers = _dynamicList(table['headers']);
      final rows = _rowList(table['rows']);
      if (headers.isNotEmpty || rows.isNotEmpty) {
        body.write(_wordTable(headers, rows));
      }
    }

    final documentXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    $body
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/>
    </w:sectPr>
  </w:body>
</w:document>''';

    final archive = Archive();
    _addUtf8(archive, '[Content_Types].xml', _docxContentTypes);
    _addUtf8(archive, '_rels/.rels', _docxRootRels);
    _addUtf8(archive, 'word/document.xml', documentXml);
    await _writeZip(output, archive);
  }

  static String _wordParagraph(
    String text, {
    bool bold = false,
    int? sizeHalfPoints,
  }) {
    final runProperties = StringBuffer();
    if (bold) runProperties.write('<w:b/>');
    if (sizeHalfPoints != null) {
      runProperties.write('<w:sz w:val="$sizeHalfPoints"/>');
    }
    final rPr = runProperties.isEmpty
        ? ''
        : '<w:rPr>${runProperties.toString()}</w:rPr>';
    return '<w:p><w:r>$rPr<w:t xml:space="preserve">${_xml(text)}</w:t></w:r></w:p>';
  }

  static String _wordTable(List<dynamic> headers, List<List<dynamic>> rows) {
    final allRows = <List<dynamic>>[
      if (headers.isNotEmpty) headers,
      ...rows,
    ];
    final buffer = StringBuffer(
      '<w:tbl><w:tblPr><w:tblBorders>'
      '<w:top w:val="single" w:sz="4"/><w:left w:val="single" w:sz="4"/>'
      '<w:bottom w:val="single" w:sz="4"/><w:right w:val="single" w:sz="4"/>'
      '<w:insideH w:val="single" w:sz="4"/><w:insideV w:val="single" w:sz="4"/>'
      '</w:tblBorders></w:tblPr>',
    );
    for (final row in allRows) {
      buffer.write('<w:tr>');
      for (final value in row) {
        buffer.write(
          '<w:tc><w:p><w:r><w:t xml:space="preserve">'
          '${_xml(value?.toString() ?? '')}'
          '</w:t></w:r></w:p></w:tc>',
        );
      }
      buffer.write('</w:tr>');
    }
    buffer.write('</w:tbl>');
    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // XLSX
  // ---------------------------------------------------------------------------

  static Future<void> _writeXlsx(File output, Map<String, dynamic> args) async {
    final workbook = excel.Excel.createExcel();
    final sheets = _mapList(args['sheets']);

    if (sheets.isEmpty) {
      final sheet = workbook['Sheet1'];
      final rows = _rowList(args['rows']);
      if (rows.isEmpty) {
        final content = (args['content'] ?? '').toString();
        if (content.isNotEmpty) {
          sheet.updateCell(
            excel.CellIndex.indexByString('A1'),
            excel.TextCellValue(content),
          );
        }
      } else {
        for (final row in rows) {
          sheet.appendRow(row.map(_excelValue).toList());
        }
      }
    } else {
      var first = true;
      for (final spec in sheets) {
        final name = _safeSheetName((spec['name'] ?? 'Sheet').toString());
        final sheet = workbook[name];
        for (final row in _rowList(spec['rows'])) {
          sheet.appendRow(row.map(_excelValue).toList());
        }
        if (first) {
          workbook.setDefaultSheet(name);
          first = false;
        }
      }
      if (workbook.tables.length > 1 && workbook.tables.containsKey('Sheet1')) {
        workbook.delete('Sheet1');
      }
    }

    final bytes = workbook.save();
    if (bytes == null) throw StateError('Excel encoder returned no bytes.');
    await output.writeAsBytes(bytes, flush: true);
  }

  static Future<void> _editXlsx(
    File source,
    File output,
    List<Map<String, dynamic>> operations,
  ) async {
    final workbook = excel.Excel.decodeBytes(await source.readAsBytes());

    for (final operation in operations) {
      final type = operation['type']?.toString() ?? '';
      final requestedSheet = operation['sheet']?.toString();
      final sheetName = requestedSheet != null && requestedSheet.isNotEmpty
          ? requestedSheet
          : workbook.tables.keys.firstOrNull;
      if (sheetName == null || !workbook.tables.containsKey(sheetName)) {
        throw ArgumentError('Sheet not found: ${requestedSheet ?? '(default)'}');
      }
      final sheet = workbook[sheetName];

      if (type == 'set_cell') {
        final cell = (operation['cell'] ?? '').toString().toUpperCase();
        if (!RegExp(r'^[A-Z]{1,3}[1-9][0-9]*$').hasMatch(cell)) {
          throw ArgumentError('Invalid Excel cell reference: $cell');
        }
        sheet.updateCell(
          excel.CellIndex.indexByString(cell),
          _excelValue(operation['value']),
        );
      } else if (type == 'append_row') {
        sheet.appendRow(
          _dynamicList(operation['values']).map(_excelValue).toList(),
        );
      } else if (type == 'replace_text') {
        final find = (operation['find'] ?? '').toString();
        final replace = (operation['replace'] ?? '').toString();
        if (find.isEmpty) continue;
        for (final row in sheet.rows) {
          for (final cell in row) {
            if (cell == null || cell.value == null) continue;
            final text = cell.value.toString();
            if (!text.contains(find)) continue;
            cell.value = excel.TextCellValue(
              operation['replace_all'] == false
                  ? _replaceFirst(text, find, replace)
                  : text.replaceAll(find, replace),
            );
          }
        }
      } else {
        throw ArgumentError('XLSX edit operation not supported: $type');
      }
    }

    final bytes = workbook.save();
    if (bytes == null) throw StateError('Excel encoder returned no bytes.');
    await output.writeAsBytes(bytes, flush: true);
  }

  static excel.CellValue _excelValue(dynamic value) {
    if (value is bool) return excel.BoolCellValue(value);
    if (value is int) return excel.IntCellValue(value);
    if (value is double) return excel.DoubleCellValue(value);
    if (value is num) return excel.DoubleCellValue(value.toDouble());
    return excel.TextCellValue(value?.toString() ?? '');
  }

  static String _safeSheetName(String input) {
    var result = input.replaceAll(RegExp(r'[\\/*?:\[\]]'), '_').trim();
    if (result.isEmpty) result = 'Sheet';
    if (result.length > 31) result = result.substring(0, 31);
    return result;
  }

  // ---------------------------------------------------------------------------
  // PPTX
  // ---------------------------------------------------------------------------

  static Future<void> _writePptx(File output, Map<String, dynamic> args) async {
    final slides = _mapList(args['slides']);
    final normalized = slides.isEmpty
        ? <Map<String, dynamic>>[
            {
              'title': args['title'] ?? '',
              'body': args['content'] ?? '',
            }
          ]
        : slides;

    final archive = Archive();
    _addUtf8(archive, '[Content_Types].xml', _pptxContentTypes(normalized.length));
    _addUtf8(archive, '_rels/.rels', _pptxRootRels);
    _addUtf8(archive, 'ppt/presentation.xml', _pptxPresentation(normalized.length));
    _addUtf8(
      archive,
      'ppt/_rels/presentation.xml.rels',
      _pptxPresentationRels(normalized.length),
    );
    _addUtf8(archive, 'ppt/slideMasters/slideMaster1.xml', _pptxSlideMaster);
    _addUtf8(
      archive,
      'ppt/slideMasters/_rels/slideMaster1.xml.rels',
      _pptxSlideMasterRels,
    );
    _addUtf8(archive, 'ppt/slideLayouts/slideLayout1.xml', _pptxSlideLayout);
    _addUtf8(
      archive,
      'ppt/slideLayouts/_rels/slideLayout1.xml.rels',
      _pptxSlideLayoutRels,
    );
    _addUtf8(archive, 'ppt/theme/theme1.xml', _pptxTheme);

    for (var i = 0; i < normalized.length; i++) {
      final spec = normalized[i];
      final title = (spec['title'] ?? '').toString();
      final body = (spec['body'] ?? spec['content'] ?? '').toString();
      final bullets = _dynamicList(spec['bullets'])
          .map((value) => value?.toString() ?? '')
          .where((value) => value.trim().isNotEmpty)
          .map((value) => '• $value')
          .toList();
      final combinedBody = [
        if (body.trim().isNotEmpty) body.trim(),
        ...bullets,
      ].join('\n');

      _addUtf8(
        archive,
        'ppt/slides/slide${i + 1}.xml',
        _pptxSlide(title, combinedBody),
      );
      _addUtf8(
        archive,
        'ppt/slides/_rels/slide${i + 1}.xml.rels',
        _pptxSlideRels,
      );
    }

    await _writeZip(output, archive);
  }

  static String _pptxSlide(String title, String body) =>
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld><p:spTree>
    <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>
    <p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>
    ${_pptxTextBox(2, 'Title', title, 800000, 500000, 10500000, 1200000, 2800, true)}
    ${_pptxTextBox(3, 'Body', body, 800000, 1900000, 10500000, 4000000, 1800, false)}
  </p:spTree></p:cSld>
  <p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>
</p:sld>''';

  static String _pptxTextBox(
    int id,
    String name,
    String text,
    int x,
    int y,
    int cx,
    int cy,
    int fontSize,
    bool bold,
  ) {
    final paragraphs = text.split('\n').map((line) {
      return '<a:p><a:r><a:rPr lang="en-US" sz="$fontSize" b="${bold ? 1 : 0}"/>'
          '<a:t>${_xml(line)}</a:t></a:r>'
          '<a:endParaRPr lang="en-US" sz="$fontSize"/></a:p>';
    }).join();

    return '''<p:sp>
      <p:nvSpPr><p:cNvPr id="$id" name="$name"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr>
      <p:spPr><a:xfrm><a:off x="$x" y="$y"/><a:ext cx="$cx" cy="$cy"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></p:spPr>
      <p:txBody><a:bodyPr wrap="square"/><a:lstStyle/>$paragraphs</p:txBody>
    </p:sp>''';
  }

  // ---------------------------------------------------------------------------
  // Rebuild-based editing for PDF/DOCX/PPTX
  // ---------------------------------------------------------------------------

  static Future<String?> _rebuildTextDocument(
    File source,
    File output,
    List<Map<String, dynamic>> operations, {
    required String format,
  }) async {
    final extracted = await DocTextExtractor().extractText(source.path);
    if (extracted == null) {
      throw ArgumentError('Could not extract text from the source document.');
    }

    var text = extracted;
    for (final operation in operations) {
      final type = operation['type']?.toString() ?? '';
      if (type == 'replace_text') {
        text = _replaceText(text, operation);
      } else if (type == 'append_text') {
        final value = (operation['text'] ?? '').toString();
        if (value.isNotEmpty) {
          text = '$text${text.endsWith('\n') ? '' : '\n'}$value';
        }
      } else {
        throw ArgumentError('$format edit operation not supported: $type');
      }
    }

    if (format == 'pdf') {
      await _writePdf(output, {
        'title': p.basenameWithoutExtension(source.path),
        'content': text,
      });
      return 'The PDF was rebuilt from extracted text; complex original layout, forms, or positioned graphics may not be preserved.';
    }

    if (format == 'docx') {
      await _writeDocx(output, {
        'title': p.basenameWithoutExtension(source.path),
        'content': text,
      });
      return 'The DOCX was rebuilt from extracted text; complex original styling, images, headers, or positioned elements may not be preserved.';
    }

    final slideBodies = text
        .split(RegExp(r'\n\s*\n'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    await _writePptx(output, {
      'slides': [
        for (var i = 0; i < slideBodies.length; i++)
          {
            'title': 'Slide ${i + 1}',
            'body': slideBodies[i],
          }
      ],
    });
    return 'The PPTX was rebuilt from extracted text; original theme, images, animations, and exact slide layout may not be preserved.';
  }

  // ---------------------------------------------------------------------------
  // TXT / MD / CSV / JSON
  // ---------------------------------------------------------------------------

  static Future<void> _editTextFile(
    File source,
    File output,
    List<Map<String, dynamic>> operations,
  ) async {
    var text = await source.readAsString();
    for (final operation in operations) {
      final type = operation['type']?.toString() ?? '';
      if (type == 'replace_text') {
        text = _replaceText(text, operation);
      } else if (type == 'append_text') {
        final value = (operation['text'] ?? '').toString();
        if (value.isNotEmpty) {
          text = '$text${text.endsWith('\n') ? '' : '\n'}$value';
        }
      } else {
        throw ArgumentError('Text edit operation not supported: $type');
      }
    }

    if (p.extension(source.path).toLowerCase() == '.json') {
      jsonDecode(text);
    }
    await output.writeAsString(text, flush: true);
  }

  static String _plainDocumentText(Map<String, dynamic> args) {
    final buffer = StringBuffer();
    final title = (args['title'] ?? '').toString().trim();
    if (title.isNotEmpty) buffer.writeln('$title\n');

    final content = (args['content'] ?? '').toString();
    if (content.isNotEmpty) buffer.writeln(content);

    for (final section in _mapList(args['sections'])) {
      final heading =
          (section['heading'] ?? section['title'] ?? '').toString().trim();
      final body = (section['body'] ?? section['content'] ?? '').toString();
      if (heading.isNotEmpty) buffer.writeln('\n$heading');
      if (body.isNotEmpty) buffer.writeln(body);
    }
    return buffer.toString().trimRight();
  }

  static String _csvText(Map<String, dynamic> args) {
    final rows = _rowList(args['rows']);
    if (rows.isEmpty) return (args['content'] ?? '').toString();
    return rows.map((row) => row.map(_csvCell).join(',')).join('\n');
  }

  static String _csvCell(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  static Map<String, dynamic> _documentJson(Map<String, dynamic> args) => {
        'title': args['title'] ?? '',
        'content': args['content'] ?? '',
        'sections': args['sections'] ?? const [],
        'tables': args['tables'] ?? const [],
      };

  // ---------------------------------------------------------------------------
  // Helpers / OOXML constants
  // ---------------------------------------------------------------------------

  static String _replaceText(String text, Map<String, dynamic> operation) {
    final find = (operation['find'] ?? '').toString();
    final replace = (operation['replace'] ?? '').toString();
    if (find.isEmpty) return text;
    return operation['replace_all'] == false
        ? _replaceFirst(text, find, replace)
        : text.replaceAll(find, replace);
  }

  static String _replaceFirst(String source, String from, String to) {
    final index = source.indexOf(from);
    if (index < 0) return source;
    return source.replaceRange(index, index + from.length, to);
  }

  static List<String> _paragraphStrings(String text) => text
      .split(RegExp(r'\n\s*\n'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static List<dynamic> _dynamicList(dynamic value) {
    if (value is List) return List<dynamic>.from(value);
    return const [];
  }

  static List<List<dynamic>> _rowList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<List>()
        .map((row) => List<dynamic>.from(row))
        .toList();
  }

  static String _xml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  static void _addUtf8(Archive archive, String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  static Future<void> _writeZip(File output, Archive archive) async {
    final bytes = ZipEncoder().encode(archive);
    if (bytes == null) throw StateError('ZIP encoder returned no bytes.');
    await output.writeAsBytes(bytes, flush: true);
  }

  static const String _docxContentTypes =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''';

  static const String _docxRootRels =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';

  static const String _pptxRootRels =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
</Relationships>''';

  static String _pptxContentTypes(int slideCount) =>
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>
  <Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>
  <Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>
  <Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>
  ${List.generate(slideCount, (i) => '<Override PartName="/ppt/slides/slide${i + 1}.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>').join()}
</Types>''';

  static String _pptxPresentation(int slideCount) =>
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:presentation xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId1"/></p:sldMasterIdLst>
  <p:sldIdLst>${List.generate(slideCount, (i) => '<p:sldId id="${256 + i}" r:id="rId${i + 2}"/>').join()}</p:sldIdLst>
  <p:sldSz cx="12192000" cy="6858000" type="screen16x9"/>
  <p:notesSz cx="6858000" cy="9144000"/>
</p:presentation>''';

  static String _pptxPresentationRels(int slideCount) =>
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="slideMasters/slideMaster1.xml"/>
  ${List.generate(slideCount, (i) => '<Relationship Id="rId${i + 2}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide${i + 1}.xml"/>').join()}
</Relationships>''';

  static const String _pptxSlideRels =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
</Relationships>''';

  static const String _pptxSlideLayoutRels =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="../slideMasters/slideMaster1.xml"/>
</Relationships>''';

  static const String _pptxSlideMasterRels =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="../theme/theme1.xml"/>
</Relationships>''';

  static const String _pptxSlideLayout =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sldLayout xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" type="blank" preserve="1">
  <p:cSld name="Blank"><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr></p:spTree></p:cSld>
  <p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>
</p:sldLayout>''';

  static const String _pptxSlideMaster =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<p:sldMaster xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
  <p:cSld name="Master"><p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr></p:spTree></p:cSld>
  <p:clrMap accent1="accent1" accent2="accent2" accent3="accent3" accent4="accent4" accent5="accent5" accent6="accent6" bg1="lt1" bg2="lt2" folHlink="folHlink" hlink="hlink" tx1="dk1" tx2="dk2"/>
  <p:sldLayoutIdLst><p:sldLayoutId id="1" r:id="rId1"/></p:sldLayoutIdLst>
  <p:txStyles><p:titleStyle/><p:bodyStyle/><p:otherStyle/></p:txStyles>
</p:sldMaster>''';

  static const String _pptxTheme =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Cortex">
  <a:themeElements>
    <a:clrScheme name="Cortex"><a:dk1><a:sysClr val="windowText" lastClr="000000"/></a:dk1><a:lt1><a:sysClr val="window" lastClr="FFFFFF"/></a:lt1><a:dk2><a:srgbClr val="1F1F1F"/></a:dk2><a:lt2><a:srgbClr val="F2F2F2"/></a:lt2><a:accent1><a:srgbClr val="4F46E5"/></a:accent1><a:accent2><a:srgbClr val="06B6D4"/></a:accent2><a:accent3><a:srgbClr val="10B981"/></a:accent3><a:accent4><a:srgbClr val="F59E0B"/></a:accent4><a:accent5><a:srgbClr val="EF4444"/></a:accent5><a:accent6><a:srgbClr val="8B5CF6"/></a:accent6><a:hlink><a:srgbClr val="0563C1"/></a:hlink><a:folHlink><a:srgbClr val="954F72"/></a:folHlink></a:clrScheme>
    <a:fontScheme name="Cortex"><a:majorFont><a:latin typeface="Arial"/><a:ea typeface=""/><a:cs typeface=""/></a:majorFont><a:minorFont><a:latin typeface="Arial"/><a:ea typeface=""/><a:cs typeface=""/></a:minorFont></a:fontScheme>
    <a:fmtScheme name="Cortex"><a:fillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:fillStyleLst><a:lnStyleLst><a:ln w="9525"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/></a:ln></a:lnStyleLst><a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst><a:bgFillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill></a:bgFillStyleLst></a:fmtScheme>
  </a:themeElements>
</a:theme>''';
}

extension _FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
