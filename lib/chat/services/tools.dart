import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cortex/network/fulcrum_http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import 'document_artifacts.dart';

/// Represents a tool that the AI can call.
class CortexTool {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final Future<String> Function(Map<String, dynamic> args) function;

  CortexTool({
    required this.name,
    required this.description,
    required this.parameters,
    required this.function,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'function',
      'function': {
        'name': name,
        'description': description,
        'parameters': parameters,
      }
    };
  }
}

class _ScopedDocumentContext {
  final Map<String, dynamic> document;
  final DateTime registeredAt;

  const _ScopedDocumentContext({
    required this.document,
    required this.registeredAt,
  });
}

/// Central registry for all available tools.
class ToolRegistry {
  static final Map<String, CortexTool> _tools = {};
  static const Uuid _uuid = Uuid();

  /// Document attachments are registered by an opaque per-attachment scope.
  ///
  /// The old implementation kept one process-global `_currentDocuments` list.
  /// Two conversations generating concurrently could therefore overwrite each
  /// other's document payload and a later document-free request could inherit
  /// an older PDF. Scopes make document lookup explicit and request-safe: the
  /// model receives the scope in the attachment marker and must echo it in the
  /// document tool call.
  static final Map<String, _ScopedDocumentContext> _documentsByScope = {};
  static const Duration _documentScopeTtl = Duration(minutes: 15);

  static void register(CortexTool tool) {
    _tools[tool.name] = tool;
  }

  static CortexTool? getTool(String name) {
    return _tools[name];
  }

  static const String _executeToolUrl =
      "https://executetool-o5h7dmtija-ew.a.run.app";

  /// Returns localized tool definitions to send to the server.
  /// The same list is used by normal online models and Dynamic Chat.
  static List<Map<String, dynamic>> getLocalizedToolsJson(
      String langCode, AppLocalizations l10n) {
    return [
      {
        'type': 'function',
        'function': {
          'name': 'read_document',
          'description':
              '${l10n.toolReadDocumentDescription} Use the exact document_scope shown with the attachment. Read the file before answering detailed questions about its contents.',
          'parameters': {
            'type': 'object',
            'properties': {
              'document_scope': {
                'type': 'string',
                'description':
                    'Opaque document scope shown in the attachment marker. Copy it exactly.',
              },
              'document_index': {
                'type': 'integer',
                'description': l10n.toolReadDocumentIndexParam,
              }
            },
            'required': ['document_scope']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'create_document',
          'description':
              'Create a real downloadable document file on the user device. Use when the user asks you to create/export a PDF, Word DOCX, Excel XLSX, PowerPoint PPTX, TXT, Markdown, CSV, or JSON file. Prefer structured sections/tables/sheets/slides instead of putting formatting instructions into content text.',
          'parameters': {
            'type': 'object',
            'properties': {
              'format': {
                'type': 'string',
                'enum': ['pdf', 'docx', 'xlsx', 'pptx', 'txt', 'md', 'csv', 'json'],
                'description': 'Output file format.'
              },
              'file_name': {
                'type': 'string',
                'description': 'Optional safe file name including or excluding extension.'
              },
              'title': {
                'type': 'string',
                'description': 'Document title.'
              },
              'content': {
                'type': 'string',
                'description': 'Main body or introductory content.'
              },
              'sections': {
                'type': 'array',
                'description': 'For PDF/DOCX/TXT/MD: ordered document sections.',
                'items': {
                  'type': 'object',
                  'properties': {
                    'heading': {'type': 'string'},
                    'body': {'type': 'string'}
                  }
                }
              },
              'tables': {
                'type': 'array',
                'description': 'For PDF/DOCX: structured tables.',
                'items': {
                  'type': 'object',
                  'properties': {
                    'headers': {'type': 'array', 'items': {}},
                    'rows': {
                      'type': 'array',
                      'items': {'type': 'array', 'items': {}}
                    }
                  }
                }
              },
              'sheets': {
                'type': 'array',
                'description': 'For XLSX: workbook sheets with row arrays.',
                'items': {
                  'type': 'object',
                  'properties': {
                    'name': {'type': 'string'},
                    'rows': {
                      'type': 'array',
                      'items': {'type': 'array', 'items': {}}
                    }
                  }
                }
              },
              'rows': {
                'type': 'array',
                'description': 'Simple rows for a single-sheet XLSX or CSV.',
                'items': {'type': 'array', 'items': {}}
              },
              'slides': {
                'type': 'array',
                'description': 'For PPTX: ordered slides.',
                'items': {
                  'type': 'object',
                  'properties': {
                    'title': {'type': 'string'},
                    'body': {'type': 'string'},
                    'bullets': {'type': 'array', 'items': {'type': 'string'}}
                  }
                }
              },
              'data': {
                'description': 'Arbitrary JSON value when format=json.'
              }
            },
            'required': ['format']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'edit_document',
          'description':
              'Edit an attached/generated document and create a new revised file. Never invent a local path: use the exact document_scope from the attachment or from create_document. Supported operations: replace_text and append_text for PDF/DOCX/text files; replace_text for PPTX; set_cell, append_row, replace_text for XLSX.',
          'parameters': {
            'type': 'object',
            'properties': {
              'document_scope': {
                'type': 'string',
                'description': 'Exact opaque scope of the source document.'
              },
              'file_name': {
                'type': 'string',
                'description': 'Optional name for the revised copy.'
              },
              'operations': {
                'type': 'array',
                'minItems': 1,
                'items': {
                  'type': 'object',
                  'properties': {
                    'type': {
                      'type': 'string',
                      'enum': ['replace_text', 'append_text', 'set_cell', 'append_row']
                    },
                    'find': {'type': 'string'},
                    'replace': {'type': 'string'},
                    'replace_all': {'type': 'boolean'},
                    'text': {'type': 'string'},
                    'sheet': {'type': 'string'},
                    'cell': {'type': 'string'},
                    'value': {},
                    'values': {'type': 'array', 'items': {}}
                  },
                  'required': ['type']
                }
              }
            },
            'required': ['document_scope', 'operations']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'get_stock_price',
          'description': l10n.toolStockDescription,
          'parameters': {
            'type': 'object',
            'properties': {
              'symbol': {
                'type': 'string',
                'description': l10n.toolStockSymbolParam,
              }
            },
            'required': ['symbol']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'get_weather',
          'description': l10n.toolWeatherDescription,
          'parameters': {
            'type': 'object',
            'properties': {
              'city': {
                'type': 'string',
                'description': l10n.toolWeatherCityParam,
              }
            },
            'required': ['city']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'run_python_code',
          'description': l10n.toolPythonDescription,
          'parameters': {
            'type': 'object',
            'properties': {
              'code': {
                'type': 'string',
                'description': l10n.toolPythonCodeParam,
              }
            },
            'required': ['code']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'calculate',
          'description': l10n.toolCalculateDescription,
          'parameters': {
            'type': 'object',
            'properties': {
              'expression': {
                'type': 'string',
                'description': l10n.toolCalculateExpressionParam,
              }
            },
            'required': ['expression']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'render_chart',
          'description':
              '${l10n.toolChartDescription} STRICTLY FOR NUMERIC DATA GRAPHS. NEVER use this tool to "draw" objects, pictures, faces, apples, cars, etc. It ONLY renders data visualizations.',
          'parameters': {
            'type': 'object',
            'properties': {
              'type': {
                'type': 'string',
                'enum': ['bar', 'line', 'pie'],
                'description': l10n.toolChartTypeParam,
              },
              'labels': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': l10n.toolChartLabelsParam,
              },
              'data': {
                'type': 'array',
                'items': {'type': 'number'},
                'description': l10n.toolChartDataParam,
              },
              'label': {
                'type': 'string',
                'description': l10n.toolChartLabelParam,
              },
              'title': {
                'type': 'string',
                'description': l10n.toolChartTitleParam,
              }
            },
            'required': ['type', 'labels', 'data', 'label']
          }
        }
      },
    ];
  }

  static void _pruneExpiredDocumentContexts() {
    final cutoff = DateTime.now().subtract(_documentScopeTtl);
    _documentsByScope.removeWhere(
      (_, context) => context.registeredAt.isBefore(cutoff),
    );
  }

  static void setDocumentsContext(List<Map<String, dynamic>> documents) {
    _pruneExpiredDocumentContexts();
    final now = DateTime.now();
    for (final document in documents) {
      final scope = document['scope']?.toString();
      if (scope == null || scope.isEmpty) continue;
      _documentsByScope[scope] = _ScopedDocumentContext(
        document: Map<String, dynamic>.from(document),
        registeredAt: now,
      );
    }
  }

  static void clearDocumentsContext() {
    _pruneExpiredDocumentContexts();
  }

  static String? _documentPathForScope(String scope) {
    _pruneExpiredDocumentContexts();
    return _documentsByScope[scope]?.document['path']?.toString();
  }

  static Future<Map<String, dynamic>?> _materializeScopedDocument(
      String scope) async {
    _pruneExpiredDocumentContexts();
    final scoped = _documentsByScope[scope];
    if (scoped == null) return null;

    final document = Map<String, dynamic>.from(scoped.document);
    final path = document.remove('path')?.toString();
    document.remove('scope');
    if (path == null || path.isEmpty) return null;

    final file = File(path);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    document['data'] = base64Encode(bytes);
    return document;
  }

  static Future<String> _registerArtifact(Map<String, dynamic> artifact) async {
    final path = artifact['path']?.toString();
    final fileName = artifact['file_name']?.toString();
    final format = artifact['format']?.toString();
    if (path == null || path.isEmpty || fileName == null || format == null) {
      return jsonEncode({
        'summary': 'Document operation finished without a usable artifact.'
      });
    }

    final file = File(path);
    if (!await file.exists()) {
      return jsonEncode({
        'summary': 'Document operation finished, but the output file is missing.'
      });
    }

    final scope = _uuid.v4();
    setDocumentsContext([
      {
        'scope': scope,
        'path': path,
        'media_type': artifact['media_type'] ?? 'application/octet-stream',
        'fileName': fileName,
        'extension': format,
        'size': await file.length(),
      }
    ]);

    final warning = artifact['warning']?.toString();
    final summary = [
      artifact['summary']?.toString() ?? 'Document ready.',
      'Document scope: $scope.',
      'The document card is available in the assistant message and can be shared or saved from there.',
      if (warning != null && warning.isNotEmpty) 'Note: $warning',
    ].join(' ');

    // SendService recognizes structured widget responses. The local file path
    // is placed only inside the rendered widget marker; SendService replaces
    // the tool result returned to the online model with [summary], so device
    // paths never leave the UI channel.
    return jsonEncode({
      'widget': 'code_execution',
      'data': {
        'artifact_path': path,
        'file_name': fileName,
        'format': format,
        'document_scope': scope,
        if (warning != null && warning.isNotEmpty) 'warning': warning,
      },
      'summary': summary,
    });
  }

  static Future<String> _createDocument(Map<String, dynamic> args) async {
    try {
      final artifact = await DocumentArtifactService.create(args);
      return await _registerArtifact(artifact);
    } catch (e) {
      return 'Document creation failed: $e';
    }
  }

  static Future<String> _editDocument(Map<String, dynamic> args) async {
    try {
      final scope = args['document_scope']?.toString();
      if (scope == null || scope.isEmpty) {
        return 'Document edit failed: missing document_scope.';
      }
      final path = _documentPathForScope(scope);
      if (path == null || path.isEmpty) {
        return 'Document edit failed: source document is unavailable or its scope expired.';
      }

      final artifact = await DocumentArtifactService.edit(
        args,
        sourcePath: path,
      );
      return await _registerArtifact(artifact);
    } catch (e) {
      return 'Document edit failed: $e';
    }
  }

  static Future<String> _executeOnServer(
      String name, Map<String, dynamic> args) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return "Error: User not authenticated.";
      final requestUserId = user.uid;

      final Map<String, dynamic> forwardedArgs = Map.from(args);
      final Map<String, dynamic> requestData = {
        'name': name,
        'args': forwardedArgs,
      };

      if (name == 'read_document') {
        final scope = forwardedArgs.remove('document_scope')?.toString();
        if (scope == null || scope.isEmpty) {
          return "Error: Missing document_scope for read_document.";
        }

        final document = await _materializeScopedDocument(scope);
        if (document == null) {
          return "Error: Document is unavailable or its scope has expired.";
        }

        forwardedArgs['document_index'] = 0;
        requestData['documents'] = [document];
      }

      final token = await user.getIdToken();
      if (FirebaseAuth.instance.currentUser?.uid != requestUserId) {
        return "Error: User session changed while executing tool.";
      }

      final dio = createFulcrumHttp();
      final response = await dio.post(
        _executeToolUrl,
        data: requestData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map || data is List) {
          return jsonEncode(data);
        }
        return data.toString();
      } else {
        return "Error executing tool: ${response.statusCode}";
      }
    } catch (e) {
      return "Server execution failed: $e";
    }
  }

  static void initialize() {
    register(CortexTool(
      name: 'read_document',
      description: 'Read document content.',
      parameters: {},
      function: (args) => _executeOnServer('read_document', args),
    ));

    register(CortexTool(
      name: 'create_document',
      description: 'Create a document file.',
      parameters: {},
      function: _createDocument,
    ));

    register(CortexTool(
      name: 'edit_document',
      description: 'Edit a scoped document file.',
      parameters: {},
      function: _editDocument,
    ));

    register(CortexTool(
      name: 'get_stock_price',
      description: 'Get stock/crypto price.',
      parameters: {},
      function: (args) => _executeOnServer('get_stock_price', args),
    ));

    register(CortexTool(
      name: 'get_weather',
      description: 'Get weather.',
      parameters: {},
      function: (args) => _executeOnServer('get_weather', args),
    ));

    register(CortexTool(
      name: 'run_python_code',
      description: 'Run python code.',
      parameters: {},
      function: (args) => _executeOnServer('run_python_code', args),
    ));

    register(CortexTool(
      name: 'calculate',
      description: 'Calculate expression.',
      parameters: {},
      function: (args) => _executeOnServer('calculate', args),
    ));

    register(CortexTool(
      name: 'render_chart',
      description: 'Render chart.',
      parameters: {},
      function: (args) => _executeOnServer('render_chart', args),
    ));
  }
}
