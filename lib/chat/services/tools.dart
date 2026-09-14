import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cortex/network/fulcrum_http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cortex/l10n/app_localizations.dart';

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

  /// Document attachments are registered by an opaque per-attachment scope.
  ///
  /// The old implementation kept one process-global `_currentDocuments` list.
  /// Two conversations generating concurrently could therefore overwrite each
  /// other's document payload and a later document-free request could inherit
  /// an older PDF. Scopes make document lookup explicit and request-safe: the
  /// model receives the scope in the attachment marker and must echo it in the
  /// `read_document` call.
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
  /// The server will use these definitions for the AI model.
  static List<Map<String, dynamic>> getLocalizedToolsJson(
      String langCode, AppLocalizations l10n) {
    return [
      // 0. Read Document - for PDF/XLSX/etc parsing
      {
        'type': 'function',
        'function': {
          'name': 'read_document',
          'description': l10n.toolReadDocumentDescription,
          'parameters': {
            'type': 'object',
            'properties': {
              'document_scope': {
                'type': 'string',
                'description':
                    'Opaque document scope shown in the attachment marker. Copy it exactly.',
              },
              // Kept for backwards/provider compatibility. The client scopes
              // one attachment per call and rewrites this to 0 before the
              // server tool executes, so models do not have to reason about a
              // process-global document list.
              'document_index': {
                'type': 'integer',
                'description': l10n.toolReadDocumentIndexParam,
              }
            },
            'required': ['document_scope']
          }
        }
      },
      // 1. Stock & Crypto Price
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
      // 2. Weather
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
      // 3. Python Code Execution
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
      // 4. Calculator
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
      // 5. Chart Rendering
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

  /// Registers document metadata for tool execution.
  ///
  /// The metadata intentionally contains a local path instead of eager base64
  /// bytes. Encoding is deferred until `read_document` is actually called,
  /// which avoids a large allocation for attachments the model never needs to
  /// open.
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

  /// Legacy cleanup hook kept for callers that already invoke it after a tool
  /// loop. Scoped contexts cannot be cleared globally here because another
  /// conversation may still be using one. Expired entries are pruned instead.
  static void clearDocumentsContext() {
    _pruneExpiredDocumentContexts();
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

        // The server receives exactly one scoped document, therefore its
        // document index is always 0 regardless of what a provider emitted.
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

  /// Initializes the default set of free, premium tools.
  static void initialize() {
    // 0. Read Document (PDF, XLSX, etc.)
    register(CortexTool(
      name: 'read_document',
      description: 'Read document content.',
      parameters: {},
      function: (args) => _executeOnServer('read_document', args),
    ));

    // 1. Stock & Crypto Price
    register(CortexTool(
      name: 'get_stock_price',
      description: 'Get stock/crypto price.',
      parameters: {},
      function: (args) => _executeOnServer('get_stock_price', args),
    ));

    // 2. Weather
    register(CortexTool(
      name: 'get_weather',
      description: 'Get weather.',
      parameters: {},
      function: (args) => _executeOnServer('get_weather', args),
    ));

    // 3. Code Execution
    register(CortexTool(
      name: 'run_python_code',
      description: 'Run python code.',
      parameters: {},
      function: (args) => _executeOnServer('run_python_code', args),
    ));

    // 4. Calculator
    register(CortexTool(
      name: 'calculate',
      description: 'Calculate expression.',
      parameters: {},
      function: (args) => _executeOnServer('calculate', args),
    ));

    // 5. Chart Rendering
    register(CortexTool(
      name: 'render_chart',
      description: 'Render chart.',
      parameters: {},
      function: (args) => _executeOnServer('render_chart', args),
    ));
  }
}
