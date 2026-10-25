// lib/apps/chat_tools.dart
//
// Chat tools that let the assistant use the user's connected apps:
// `find_app_actions` discovers Composio actions, `run_app_action` executes
// one after the per-app permission check (ask → confirmation dialog,
// read only → reads only, off → never). Fulcrum enforces the same rules.

import 'dart:async';
import 'dart:convert';

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/main.dart' show navigatorKey;
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'controller.dart';
import 'logo.dart';
import 'models.dart';
import 'service.dart';

class AppChatTools {
  AppChatTools._();

  static const String findTool = 'find_app_actions';
  static const String runTool = 'run_app_action';

  static const int _maxSchemaChars = 6000;
  static const Duration _confirmTimeout = Duration(minutes: 3);
  static const Uuid _uuid = Uuid();

  static String _turnId = _uuid.v4();
  static final Map<String, AppAction> _discovered = {};

  /// One user turn counts once against the daily app quota on Fulcrum,
  /// however many actions it runs.
  static void beginTurn() {
    _turnId = _uuid.v4();
    _discovered.clear();
  }

  /// Tool definitions, offered only while at least one app is usable.
  static List<Map<String, dynamic>> toolsJson() {
    final apps = AppsController.instance.chatApps;
    if (apps.isEmpty) return const [];
    final names = apps.map((app) => '${app.name} (${app.slug})').join(', ');
    final slugs = apps.map((app) => app.slug).toList();
    return [
      {
        'type': 'function',
        'function': {
          'name': findTool,
          'description':
              'Find actions in apps the user connected to Cortex: $names. '
                  'Call this first whenever the user asks to read, search, create, send or change something in one of these apps. '
                  'Returns action slugs with their JSON input schemas.',
          'parameters': {
            'type': 'object',
            'properties': {
              'query': {
                'type': 'string',
                'description':
                    'Short English description of the capability needed, e.g. "send an email" or "list today\'s calendar events".',
              },
              'app': {
                'type': 'string',
                'enum': slugs,
                'description': 'Optional app slug to search in.',
              },
            },
            'required': ['query'],
          },
        },
      },
      {
        'type': 'function',
        'function': {
          'name': runTool,
          'description':
              'Run one action returned by $findTool in a connected app. '
                  'Fill arguments exactly according to that action\'s input schema. '
                  'The user may be asked to approve the action. Never claim an action succeeded unless the result says so.',
          'parameters': {
            'type': 'object',
            'properties': {
              'action': {
                'type': 'string',
                'description': 'Exact action slug from $findTool.',
              },
              'arguments': {
                'type': 'object',
                'description': 'Arguments matching the action input schema.',
              },
            },
            'required': ['action', 'arguments'],
          },
        },
      },
    ];
  }

  static String _json(Map<String, dynamic> value) => jsonEncode(value);

  static Map<String, dynamic> _boundedSchema(Map<String, dynamic> schema) {
    final encoded = jsonEncode(schema);
    if (encoded.length <= _maxSchemaChars) return schema;
    // Keep the property names and types; drop long nested descriptions.
    final properties = schema['properties'];
    return {
      'type': 'object',
      if (schema['required'] != null) 'required': schema['required'],
      if (properties is Map)
        'properties': {
          for (final entry in properties.entries)
            entry.key: entry.value is Map
                ? {
                    'type': (entry.value as Map)['type'],
                    if ((entry.value as Map)['description'] != null)
                      'description': (entry.value as Map)['description']
                          .toString()
                          .split('\n')
                          .first,
                  }
                : entry.value,
        },
    };
  }

  static Future<String> find(Map<String, dynamic> args) async {
    final query = (args['query'] ?? '').toString().trim();
    final app = args['app']?.toString().trim();
    if (query.isEmpty) return _json({'error': 'query is required.'});

    final controller = AppsController.instance;
    await controller.restore();
    if (app != null &&
        app.isNotEmpty &&
        controller.permissionFor(app) == AppPermission.off) {
      return _json({
        'error': 'The user turned this app off for Cortex. Do not use it.',
      });
    }

    try {
      final body = await AppsService.instance.discoverActions(
        query,
        preferredApp: app,
      );
      if (body['connectionRequired'] == true) {
        final suggested = body['suggestedToolkit'];
        final name = suggested is Map ? suggested['name'] : null;
        return _json({
          'connection_required': true,
          'app': name,
          'message':
              'This app is not connected. Ask the user to connect it from the Apps screen in the Cortex sidebar.',
        });
      }

      final tools = body['tools'];
      final actions = <Map<String, dynamic>>[];
      if (tools is List) {
        for (final raw in tools.whereType<Map>()) {
          final action = AppAction.fromJson(Map<String, dynamic>.from(raw));
          if (action.slug.isEmpty) continue;
          final permission = controller.permissionFor(action.toolkitSlug);
          if (permission == AppPermission.off) continue;
          if (permission == AppPermission.readOnly && !action.readOnly) continue;
          _discovered[action.slug] = action;
          actions.add({
            'action': action.slug,
            'name': action.name,
            'app': action.toolkitName,
            'description': action.description.length > 400
                ? '${action.description.substring(0, 400)}…'
                : action.description,
            'read_only': action.readOnly,
            'input_schema': _boundedSchema(action.inputParameters),
          });
        }
      }
      if (actions.isEmpty) {
        return _json({
          'actions': [],
          'message': 'No permitted action matched. Try a different query or explain the limitation to the user.',
        });
      }
      return _json({'actions': actions});
    } on AppsException catch (e) {
      return _json({'error': 'App action search failed: ${e.message}'});
    } catch (e) {
      return _json({'error': 'App action search failed.'});
    }
  }

  static Future<String> run(Map<String, dynamic> args) async {
    final slug = (args['action'] ?? '').toString().trim().toUpperCase();
    final rawArguments = args['arguments'];
    final arguments = rawArguments is Map
        ? Map<String, dynamic>.from(rawArguments)
        : rawArguments is String
            ? _decodeMap(rawArguments)
            : <String, dynamic>{};
    if (slug.isEmpty) return _json({'error': 'action is required.'});

    final controller = AppsController.instance;
    await controller.restore();

    var action = _discovered[slug];
    if (action == null) {
      try {
        final body = await AppsService.instance.inspectAction(slug);
        final code = body['code']?.toString();
        if (code != null) return _json(_codeResult(code, body));
        final tool = body['tool'];
        if (tool is Map) {
          action = AppAction.fromJson(Map<String, dynamic>.from(tool));
        }
      } on AppsException catch (e) {
        return _json({'error': 'Could not inspect the action: ${e.message}'});
      }
    }
    if (action == null) {
      return _json({'error': 'Unknown action. Call $findTool first.'});
    }

    final permission = controller.permissionFor(action.toolkitSlug);
    if (permission == AppPermission.off) {
      return _json(_codeResult('integration_disabled', const {}));
    }
    if (permission == AppPermission.readOnly && !action.readOnly) {
      return _json(_codeResult('integration_read_only', const {}));
    }
    if (permission == AppPermission.ask) {
      final approved = await _confirm(action, arguments);
      if (!approved) {
        return _json({
          'success': false,
          'denied_by_user': true,
          'message': 'The user did not approve this action. Do not retry it unless they ask.',
        });
      }
    }

    try {
      final body = await AppsService.instance.executeAction(
        actionSlug: action.slug,
        arguments: arguments,
        turnId: _turnId,
      );
      return _json({
        'success': body['success'] != false,
        'app': action.toolkitName,
        'action': action.name,
        'data': body['data'],
        if (body['error'] != null) 'error': body['error'],
      });
    } on AppsException catch (e) {
      if (e.code != null) return _json(_codeResult(e.code!, const {}));
      return _json({'success': false, 'error': e.message});
    }
  }

  static Map<String, dynamic> _decodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return <String, dynamic>{};
  }

  static Map<String, dynamic> _codeResult(String code, Map body) {
    switch (code) {
      case 'integration_connection_required':
        return {
          'success': false,
          'connection_required': true,
          'message':
              'The app is not connected. Ask the user to connect it from the Apps screen in the Cortex sidebar.',
        };
      case 'integration_disabled':
        return {
          'success': false,
          'blocked_by_permission': true,
          'message': 'The user turned this app off for Cortex. Tell them it can be changed in Apps → permissions.',
        };
      case 'integration_read_only':
        return {
          'success': false,
          'blocked_by_permission': true,
          'message':
              'This app is set to read-only, so this action is not allowed. Tell the user they can change it in Apps → permissions.',
        };
      case 'integration_daily_limit':
        return {
          'success': false,
          'message': 'The daily app usage limit for the user\'s plan has been reached.',
        };
      default:
        return {'success': false, 'error': code};
    }
  }

  static Future<bool> _confirm(
    AppAction action,
    Map<String, dynamic> arguments,
  ) async {
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return false;
    final summary = AppsController.instance.connectedApp(action.toolkitSlug);
    final result = await showDialog<_Decision>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ConfirmDialog(
        action: action,
        appName: summary?.name ?? action.toolkitName,
        logo: summary?.logo ?? action.toolkitLogo,
        arguments: arguments,
      ),
    ).timeout(_confirmTimeout, onTimeout: () {
      final navigator = navigatorKey.currentState;
      if (navigator != null && navigator.canPop()) navigator.pop();
      return _Decision.deny;
    });

    if (result == _Decision.always) {
      unawaited(AppsController.instance
          .setPermission(action.toolkitSlug, AppPermission.allow)
          .catchError((_) {}));
    }
    return result == _Decision.once || result == _Decision.always;
  }
}

enum _Decision { deny, once, always }

class _ConfirmDialog extends StatelessWidget {
  final AppAction action;
  final String appName;
  final String? logo;
  final Map<String, dynamic> arguments;

  const _ConfirmDialog({
    required this.action,
    required this.appName,
    required this.logo,
    required this.arguments,
  });

  String _preview() {
    final lines = <String>[];
    for (final entry in arguments.entries.take(6)) {
      var value = entry.value is String ? entry.value as String : jsonEncode(entry.value);
      value = value.replaceAll('\n', ' ');
      if (value.length > 90) value = '${value.substring(0, 90)}…';
      lines.add('${entry.key}: $value');
    }
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = AppColors.primaryColor.inverted;
    final muted = AppColors.tertiaryColor;
    final preview = _preview();
    return AlertDialog(
      backgroundColor: AppColors.secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          AppLogo(name: appName, url: logo, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.appsConfirmTitle(appName),
              style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appsConfirmBody(appName, action.name),
            style: TextStyle(color: text, fontSize: 15, height: 1.4),
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                preview,
                style: TextStyle(color: muted, fontSize: 13, height: 1.4, fontFamily: 'monospace'),
              ),
            ),
          ],
        ],
      ),
      actionsOverflowButtonSpacing: 4,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_Decision.deny),
          child: Text(l10n.appsConfirmDeny, style: TextStyle(color: muted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_Decision.always),
          child: Text(l10n.appsPermissionAllow),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_Decision.once),
          style: FilledButton.styleFrom(
            backgroundColor: text,
            foregroundColor: AppColors.primaryColor,
          ),
          child: Text(l10n.appsConfirmAllowOnce),
        ),
      ],
    );
  }
}
