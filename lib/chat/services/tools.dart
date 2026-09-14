import 'dart:convert';

import 'package:cortex/integrations/dialogs.dart';
import 'package:cortex/integrations/model.dart';
import 'package:cortex/integrations/service.dart';
import 'package:cortex/network/fulcrum_http.dart';
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
      {
        'type': 'function',
        'function': {
          'name': 'discover_integration_tools',
          'description':
              'Find a small set of actions from the user\'s connected plugins that can complete the request. Use this before execute_integration_tool. Describe the capability in natural language. You may provide a preferred toolkit such as gmail, github, slack, notion, googlecalendar or googledrive. If the required app is not connected, Cortex will ask the user to connect it.',
          'parameters': {
            'type': 'object',
            'properties': {
              'capability': {
                'type': 'string',
                'description':
                    'What needs to be done, e.g. "read recent emails for a summary" or "create a GitHub issue".'
              },
              'preferred_toolkit': {
                'type': 'string',
                'description':
                    'Optional toolkit slug when the user named a specific service.'
              }
            },
            'required': ['capability']
          }
        }
      },
      {
        'type': 'function',
        'function': {
          'name': 'execute_integration_tool',
          'description':
              'Execute one exact action returned by discover_integration_tools. Use only for an action the user requested. Cortex will show a permission prompt unless the user previously chose Always allow for this exact action. Never invent a tool_slug.',
          'parameters': {
            'type': 'object',
            'properties': {
              'tool_slug': {
                'type': 'string',
                'description':
                    'Exact tool_slug returned by discover_integration_tools.'
              },
              'arguments': {
                'type': 'object',
                'description': 'Arguments matching the discovered input schema.'
              },
              'version': {
                'type': 'string',
                'description': 'Optional exact version returned by discovery.'
              }
            },
            'required': ['tool_slug', 'arguments']
          }
        }
      },
    ];
  }

  static List<Map<String, dynamic>>? _currentDocuments;

  static void setDocumentsContext(List<Map<String, dynamic>> documents) {
    _currentDocuments = documents;
  }

  static void clearDocumentsContext() {
    _currentDocuments = null;
    IntegrationService.instance.endTurn();
  }

  static Future<String> _executeOnServer(
      String name, Map<String, dynamic> args) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return "Error: User not authenticated.";

      final token = await user.getIdToken();
      final dio = createFulcrumHttp();

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

  static Future<String> _discoverIntegrationTools(
      Map<String, dynamic> args) async {
    final capability = (args['capability'] ?? '').toString().trim();
    final preferred = args['preferred_toolkit']?.toString().trim();
    if (capability.isEmpty) {
      return jsonEncode({'error': 'A capability description is required.'});
    }

    try {
      final discovery = await IntegrationService.instance.discoverTools(
        capability: capability,
        preferredToolkit: preferred,
      );

      if (discovery.connectionRequired) {
        final slug = discovery.suggestedToolkitSlug ?? preferred ?? '';
        final name = discovery.suggestedToolkitName ??
            (slug.isEmpty ? 'Plugin' : _humanize(slug));
        await IntegrationDialogs.showConnectionRequired(
          toolkitSlug: slug,
          toolkitName: name,
          logoUrl: discovery.suggestedToolkitLogo,
          search: slug.isEmpty ? preferred : slug,
        );
        return jsonEncode({
          'connection_required': true,
          'toolkit': {'slug': slug, 'name': name},
          'message':
              'The required plugin is not connected. Cortex showed the user a connection prompt. Do not claim the requested data was accessed.',
        });
      }

      return jsonEncode({
        'connection_required': false,
        'tools': discovery.tools.map((tool) => tool.compactForModel()).toList(),
        'instruction':
            'Choose only an exact tool_slug from this list. If none fits, refine discovery instead of inventing a slug.',
      });
    } catch (e) {
      return jsonEncode({'error': 'Integration discovery failed: $e'});
    }
  }

  static Future<String> _executeIntegrationTool(
      Map<String, dynamic> args) async {
    final toolSlug = (args['tool_slug'] ?? '').toString().trim().toUpperCase();
    final rawArguments = args['arguments'];
    if (toolSlug.isEmpty || rawArguments is! Map) {
      return jsonEncode({'error': 'Invalid integration action request.'});
    }
    final arguments = Map<String, dynamic>.from(rawArguments);

    try {
      // Resolve exact action metadata from Fulcrum before asking the user.
      // This prevents model-written permission text from understating what an
      // integration action will actually do.
      final IntegrationToolInfo verifiedTool =
          await IntegrationService.instance.inspectTool(toolSlug);

      IntegrationService.instance.setActiveIntegrationTool(verifiedTool);
      final actionDescription = verifiedTool.description.isNotEmpty
          ? verifiedTool.description
          : verifiedTool.name;

      final decision = await IntegrationDialogs.requestActionPermission(
        toolkitSlug: verifiedTool.toolkitSlug,
        toolkitName: verifiedTool.toolkitName,
        logoUrl: verifiedTool.toolkitLogo,
        toolSlug: verifiedTool.slug,
        actionDescription: actionDescription,
      );
      if (decision == IntegrationPermissionDecision.reject) {
        return jsonEncode({
          'error': 'User rejected the integration action.',
          'code': 'integration_permission_rejected',
        });
      }

      final result = await IntegrationService.instance.executeTool(
        toolSlug: verifiedTool.slug,
        arguments: arguments,
        version: verifiedTool.version,
      );
      return jsonEncode({
        'success': result.success,
        'data': result.data,
        if (result.error != null) 'error': result.error,
        'toolkit': {
          'slug': result.toolkitSlug,
          'name': result.toolkitName,
        },
      });
    } on IntegrationLimitException {
      await IntegrationDialogs.showDailyLimitReached();
      return jsonEncode({
        'error': 'Daily plugin usage limit reached.',
        'code': 'integration_daily_limit',
      });
    } on IntegrationConnectionRequiredException catch (e) {
      await IntegrationDialogs.showConnectionRequired(
        toolkitSlug: e.toolkitSlug,
        toolkitName: e.toolkitName,
        logoUrl: e.logoUrl,
        search: e.toolkitSlug,
      );
      return jsonEncode({
        'error': 'Required plugin is not connected.',
        'code': 'integration_connection_required',
      });
    } catch (e) {
      return jsonEncode({'error': 'Integration action failed: $e'});
    } finally {
      IntegrationService.instance.setActiveIntegrationTool(null);
    }
  }

  static String _humanize(String slug) {
    if (slug.isEmpty) return 'Plugin';
    return slug
        .split(RegExp(r'[_-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  static void initialize() {
    register(CortexTool(
      name: 'read_document',
      description: 'Read document content.',
      parameters: {},
      function: (args) => _executeOnServer('read_document', args),
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

    register(CortexTool(
      name: 'discover_integration_tools',
      description: 'Discover connected integration actions.',
      parameters: {},
      function: _discoverIntegrationTools,
    ));

    register(CortexTool(
      name: 'execute_integration_tool',
      description: 'Execute a permission-gated integration action.',
      parameters: {},
      function: _executeIntegrationTool,
    ));
  }
}
