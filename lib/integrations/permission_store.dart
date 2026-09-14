import 'package:shared_preferences/shared_preferences.dart';

/// Persistent, user-controlled permission rules for integration actions.
///
/// Only an explicit "Always allow" decision is persisted. A one-time allow
/// and a rejection live only for the current prompt, which keeps the default
/// posture conservative while still allowing users to remove remembered
/// permissions from the Plugins screen.
class IntegrationPermissionStore {
  IntegrationPermissionStore._();

  static final IntegrationPermissionStore instance =
      IntegrationPermissionStore._();

  static const String _prefix = 'integration.always.';

  String _key(String toolkitSlug) => '$_prefix${toolkitSlug.toLowerCase()}';

  Future<Set<String>> alwaysAllowedTools(String toolkitSlug) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key(toolkitSlug)) ?? const <String>[])
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  Future<bool> isAlwaysAllowed(String toolkitSlug, String toolSlug) async {
    final rules = await alwaysAllowedTools(toolkitSlug);
    return rules.contains(toolSlug.trim().toUpperCase());
  }

  Future<void> setAlwaysAllowed(
    String toolkitSlug,
    String toolSlug, {
    required bool allowed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rules = await alwaysAllowedTools(toolkitSlug);
    final normalized = toolSlug.trim().toUpperCase();
    if (normalized.isEmpty) return;

    if (allowed) {
      rules.add(normalized);
    } else {
      rules.remove(normalized);
    }

    final sorted = rules.toList()..sort();
    if (sorted.isEmpty) {
      await prefs.remove(_key(toolkitSlug));
    } else {
      await prefs.setStringList(_key(toolkitSlug), sorted);
    }
  }

  Future<void> clearToolkit(String toolkitSlug) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(toolkitSlug));
  }
}
