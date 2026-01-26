import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:math_expressions/math_expressions.dart';
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

  static List<Map<String, dynamic>> getLocalizedToolsJson(String langCode,
      AppLocalizations localizations) {
    return _tools.values.map((t) {
      // Create a copy of the tool definition
      var json = t.toJson();

      if (t.name == 'get_stock_price') {
        json['function']['description'] =
            localizations.toolGetStockPriceDescription;
        json['function']['parameters']['properties']['symbol']['description'] =
            localizations.toolGetStockPriceParamSymbol;
      } else if (t.name == 'get_weather') {
        json['function']['description'] =
            localizations.toolGetWeatherDescription;
        json['function']['parameters']['properties']['city']['description'] =
            localizations.toolGetWeatherParamCity;
      } else if (t.name == 'run_python_code') {
        json['function']['description'] =
            localizations.toolRunPythonCodeDescription;
        json['function']['parameters']['properties']['code']['description'] =
            localizations.toolRunPythonCodeParamCode;
      } else if (t.name == 'calculate') {
        json['function']['description'] =
            localizations.toolCalculateDescription;
        json['function']['parameters']['properties']['expression']
        ['description'] = localizations.toolCalculateParamExpression;
      } else if (t.name == 'render_chart') {
        json['function']['description'] =
            localizations.toolRenderChartDescription;
        json['function']['parameters']['properties']['type']['description'] =
            localizations.toolRenderChartParamType;
        json['function']['parameters']['properties']['labels']['description'] =
            localizations.toolRenderChartParamLabels;
        json['function']['parameters']['properties']['data']['description'] =
            localizations.toolRenderChartParamData;
        json['function']['parameters']['properties']['label']['description'] =
            localizations.toolRenderChartParamLabel;
        json['function']['parameters']['properties']['title']['description'] =
            localizations.toolRenderChartParamTitle;
      }

      return json;
    }).toList();
  }

  /// Helper to format the tool output as a structured JSON string.
  /// This structure allows the UI to intercept specific widgets while keeping
  /// a text summary for the LLM context.
  static String _formatOutput({
    required String? widgetType,
    required Map<String, dynamic>? data,
    required String summary,
  }) {
    // If no widget is needed, just return the text as usual.
    if (widgetType == null) return summary;

    final output = {
      'widget': widgetType, // e.g., 'weather_card', 'crypto_card', 'chart'
      'data': data,
      'summary': summary, // Text representation for the LLM
    };
    return jsonEncode(output);
  }

  /// Initializes the default set of free, premium tools.
  static void initialize() {
    final dio = Dio();

    // 1. Stock & Crypto Price (Yahoo Finance)
    register(CortexTool(
      name: 'get_stock_price',
      description:
      'Get the current price and daily trend of a stock (e.g., AAPL, THYAO.IS) or cryptocurrency (e.g., BTC-USD, ETH-USD) from Yahoo Finance.',
      parameters: {
        'type': 'object',
        'properties': {
          'symbol': {
            'type': 'string',
            'description':
            'The ticker symbol (e.g., AAPL, TSLA, THYAO.IS, BTC-USD).',
          },
        },
        'required': ['symbol'],
      },
      function: (args) async {
        try {
          var symbol = args['symbol'].toString().toUpperCase();

          // Auto-fix common crypto formats if user forgets -USD
          if (['BTC', 'ETH', 'SOL', 'DOGE', 'XRP', 'AVAX'].contains(symbol)) {
            symbol = '$symbol-USD';
          }

          final url =
              'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1h&range=1d';

          final response = await dio.get(
            url,
            options: Options(
              headers: {
                // Yahoo Finance requires a User-Agent to avoid 429 errors
                'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
              },
            ),
          );

          if (response.statusCode == 200) {
            final json = response.data;
            if (json['chart']['result'] == null) {
              return 'Error: Symbol $symbol not found.';
            }

            final result = json['chart']['result'][0];
            final meta = result['meta'];
            final currentPrice =
                double.tryParse(meta['regularMarketPrice'].toString()) ?? 0.0;
            final currency = meta['currency'] ?? 'USD';
            final longName = meta['longName'] ?? symbol;

            // Extract sparkline data
            List<double> sparklineData = [];
            try {
              final indicators = result['indicators']['quote'][0];
              final closes = indicators['close'] as List<dynamic>;
              sparklineData = closes
                  .where((e) => e != null)
                  .map((e) => double.tryParse(e.toString()) ?? 0.0)
                  .toList();
            } catch (_) {}

            final summary =
                '$longName ($symbol) price: $currentPrice $currency';

            return _formatOutput(
              widgetType: 'crypto_card', // Reusing the same card widget for now
              data: {
                'symbol': longName, // Display full name
                'price': currentPrice,
                'sparkline': sparklineData,
                'currency': currency
              },
              summary: summary,
            );
          } else {
            return 'Error fetching data: ${response.statusCode}';
          }
        } catch (e) {
          return 'Finance Service Error: $e';
        }
      },
    ));

    // 2. Weather (Open-Meteo)
    register(CortexTool(
      name: 'get_weather',
      description:
      'Get current weather for a specific city. Ask user for city if not known.',
      parameters: {
        'type': 'object',
        'properties': {
          'city': {
            'type': 'string',
            'description': 'The name of the city (e.g., London, Istanbul).',
          },
        },
        'required': ['city'],
      },
      function: (args) async {
        try {
          final city = args['city'].toString();

          // 1. Geocoding
          final geoResponse = await dio.get(
              'https://geocoding-api.open-meteo.com/v1/search',
              queryParameters: {
                'name': city,
                'count': 1,
                'language': 'en',
                'format': 'json'
              });

          if (geoResponse.statusCode != 200) return 'Error finding city: $city';

          final geoData = geoResponse.data;
          if (geoData['results'] == null ||
              (geoData['results'] as List).isEmpty) {
            return 'City not found: $city';
          }

          final lat = geoData['results'][0]['latitude'];
          final lon = geoData['results'][0]['longitude'];
          final name = geoData['results'][0]['name'];
          final country = geoData['results'][0]['country'];

          // 2. Weather
          final weatherResponse = await dio
              .get('https://api.open-meteo.com/v1/forecast', queryParameters: {
            'latitude': lat,
            'longitude': lon,
            'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
            'timezone': 'auto'
          });

          if (weatherResponse.statusCode == 200) {
            final wData = weatherResponse.data;
            if (wData['current'] == null || wData['current_units'] == null) {
              return 'Error: Weather data not available for $name ($country).';
            }
            final current = wData['current'];
            final units = wData['current_units'];

            final summary =
                'Weather in $name: ${current['temperature_2m']}${units['temperature_2m']}, Code: ${current['weather_code']}';

            return _formatOutput(
              widgetType: 'weather_card',
              data: {
                'city': name,
                'country': country,
                'current': current,
                'units': units,
              },
              summary: summary,
            );
          } else {
            return 'Error fetching weather data.';
          }
        } catch (e) {
          return 'Error getting weather: $e';
        }
      },
    ));

    // 3. Code Execution (Piston)
    register(CortexTool(
      name: 'run_python_code',
      description:
      'Execute Python code in a secure sandbox. Use this for complex calculations, data processing, or algorithmic tasks.',
      parameters: {
        'type': 'object',
        'properties': {
          'code': {
            'type': 'string',
            'description': 'The Python code to execute.',
          },
        },
        'required': ['code'],
      },
      function: (args) async {
        try {
          final code = args['code'].toString();
          final response = await dio.post(
            'https://emkc.org/api/v2/piston/execute',
            data: {
              'language': 'python',
              'version': '3.10.0',
              'files': [
                {'content': code}
              ],
            },
          );

          if (response.statusCode == 200) {
            final data = response.data;
            final run = data['run'];
            final output = run['output'] ?? '';
            final error = run['stderr'] ?? '';

            if (error.isNotEmpty) {
              return _formatOutput(
                widgetType: 'code_execution',
                data: {
                  'code': code,
                  'output': output,
                  'error': error,
                },
                summary: 'Execution Error:\n$error',
              );
            }

            final summary = output.isEmpty
                ? 'Code executed successfully.'
                : 'Output:\n$output';

            return _formatOutput(
              widgetType: 'code_execution',
              data: {
                'code': code,
                'output': output,
              },
              summary: summary,
            );
          } else {
            return 'Failed to execute code. Server returned ${response
                .statusCode}';
          }
        } catch (e) {
          return 'Execution error: $e';
        }
      },
    ));

    // 4. Calculator (Math Expressions)
    register(CortexTool(
      name: 'calculate',
      description: 'Evaluate a mathematical expression.',
      parameters: {
        'type': 'object',
        'properties': {
          'expression': {
            'type': 'string',
            'description':
            'The math expression (e.g., "3 + 4 * 2", "sin(45)").',
          },
        },
        'required': ['expression'],
      },
      function: (args) async {
        try {
          final expr = args['expression'].toString();
          GrammarParser p = GrammarParser();
          Expression exp = p.parse(expr);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          return eval.toString();
        } catch (e) {
          return 'Calculation error: $e';
        }
      },
    ));

    // 5. Chart Rendering
    register(CortexTool(
      name: 'render_chart',
      description:
      'Generate a chart/graph. Use this to visualize data provided by the user or calculated.',
      parameters: {
        'type': 'object',
        'properties': {
          'type': {
            'type': 'string',
            'description': 'Chart type: bar, line, pie.',
            'enum': [
              'bar',
              'line',
              'pie',
            ]
          },
          'labels': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': 'Labels for the x-axis or categories.'
          },
          'data': {
            'type': 'array',
            'items': {'type': 'number'},
            'description': 'Numerical data points.'
          },
          'label': {'type': 'string', 'description': 'Label for the dataset.'},
          'title': {'type': 'string', 'description': 'Title of the chart.'}
        },
        'required': ['type', 'labels', 'data', 'label'],
      },
      function: (args) async {
        try {
          final type = args['type'];
          final labels = args['labels'];
          final data = args['data'];
          final datasetLabel = args['label'] ?? 'Data';
          final title = args['title'];

          final summary = 'Chart generated: $title ($type)';

          return _formatOutput(
            widgetType: 'chart_card',
            data: {
              'type': type,
              'labels': labels,
              'data': data,
              'datasetLabel': datasetLabel,
              'title': title,
            },
            summary: summary,
          );
        } catch (e) {
          return 'Error generating chart: $e';
        }
      },
    ));
  }
}
