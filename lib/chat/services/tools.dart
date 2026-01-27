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

  static List<Map<String, dynamic>> getLocalizedToolsJson(String langCode,
      AppLocalizations localizations) {
    // Tools are now injected on the server side (message.js).
    // Access: functions/src/tools.js
    return [];
  }

  static Future<String> _executeOnServer(String name,
      Map<String, dynamic> args) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return "Error: User not authenticated.";

      final token = await user.getIdToken();
      final dio = Dio();

      final response = await dio.post(
        _executeToolUrl,
        data: {'name': name, 'args': args},
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