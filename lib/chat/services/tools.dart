import 'dart:convert';
import 'package:dio/dio.dart';
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

/// Central registry for all available tools.
class ToolRegistry {
  static final Map<String, CortexTool> _tools = {};

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
              'document_index': {
                'type': 'integer',
                'description': l10n.toolReadDocumentIndexParam,
              }
            },
            'required': ['document_index']
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

  /// Stores documents for the current request context (PDF, XLSX, etc.)
  static List<Map<String, dynamic>>? _currentDocuments;

  /// Sets the documents context for tool execution.
  /// Call this before executing tools that need document access.
  static void setDocumentsContext(List<Map<String, dynamic>> documents) {
    _currentDocuments = documents;
  }

  /// Clears the documents context after tool execution.
  static void clearDocumentsContext() {
    _currentDocuments = null;
  }

  static Future<String> _executeOnServer(
      String name, Map<String, dynamic> args) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return "Error: User not authenticated.";

      final token = await user.getIdToken();
      final dio = Dio();

      // Include documents if this is a read_document call
      final Map<String, dynamic> requestData = {
        'name': name,
        'args': args,
      };

      if (name == 'read_document' && _currentDocuments != null) {
        requestData['documents'] = _currentDocuments;
      }

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
        // The server returns the JSON string directly usually, or an object.
        // If it returns an object, we might need to stringify it if the
        // calling code expects a string result from the tool.
        // CortexTool.function returns Future<String>.
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
      // Definitions handle on server, but we keep empties or minimal for local registry if needed?
      // Actually registry only uses name to find handler. Parameters here are unused if getLocalizedToolsJson returns [].
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
