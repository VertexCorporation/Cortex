import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Global permission behavior for one connected integration.
///
/// - [askEveryTime]: ask before every action unless the user explicitly chose
///   "Always allow" for that exact action.
/// - [allowRead]: automatically allow clearly read-only actions, but still ask
///   before anything that can create, send, update or delete data.
/// - [allowAll]: automatically allow all verified actions for this integration.
///
/// The mode lives entirely on-device. Fulcrum/Composio never receives or owns
/// the user's local permission preference.
enum IntegrationPermissionMode { askEveryTime, allowRead, allowAll }

class IntegrationPermissionStore {
  IntegrationPermissionStore({required String? Function() currentUserId})
    : _currentUserId = currentUserId;

  final String? Function() _currentUserId;

  static final IntegrationPermissionStore instance = IntegrationPermissionStore(
    currentUserId: () => FirebaseAuth.instance.currentUser?.uid,
  );

  static const String _alwaysPrefix = 'integration.always.';
  static const String _modePrefix = 'integration.mode.';

  static const Set<String> _readVerbs = {
    'GET',
    'LIST',
    'READ',
    'SEARCH',
    'FIND',
    'FETCH',
    'LOOKUP',
    'QUERY',
    'RETRIEVE',
    'VIEW',
    'CHECK',
    'DESCRIBE',
    'INSPECT',
    'DOWNLOAD',
  };

  static const Set<String> _writeVerbs = {
    'CREATE',
    'SEND',
    'UPDATE',
    'EDIT',
    'DELETE',
    'REMOVE',
    'WRITE',
    'POST',
    'PUT',
    'PATCH',
    'ADD',
    'UPLOAD',
    'MOVE',
    'COPY',
    'ARCHIVE',
    'TRASH',
    'RESTORE',
    'INVITE',
    'ACCEPT',
    'DECLINE',
    'CANCEL',
    'MERGE',
    'PUBLISH',
    'EXECUTE',
    'RUN',
    'REPLY',
    'FORWARD',
  };

  // Do not migrate legacy global grants: their account owner is unknown.
  String _alwaysKey(String toolkitSlug, String uid) =>
      '${_alwaysPrefix}v2.${Uri.encodeComponent(uid)}.${toolkitSlug.trim().toLowerCase()}';
  String _modeKey(String toolkitSlug, String uid) =>
      '${_modePrefix}v2.${Uri.encodeComponent(uid)}.${toolkitSlug.trim().toLowerCase()}';

  Future<IntegrationPermissionMode> modeForToolkit(String toolkitSlug) async {
    final uid = _currentUserId();
    if (uid == null) return IntegrationPermissionMode.askEveryTime;
    final prefs = await SharedPreferences.getInstance();
    if (uid != _currentUserId()) return IntegrationPermissionMode.askEveryTime;
    final raw = prefs.getString(_modeKey(toolkitSlug, uid));
    return switch (raw) {
      'allowRead' => IntegrationPermissionMode.allowRead,
      'allowAll' => IntegrationPermissionMode.allowAll,
      _ => IntegrationPermissionMode.askEveryTime,
    };
  }

  /// Applying a top-level preset clears old per-action exceptions so the
  /// selected policy is immediately predictable to the user. New explicit
  /// "Always allow" decisions can still be created later from an action prompt.
  Future<void> setMode(
    String toolkitSlug,
    IntegrationPermissionMode mode,
  ) async {
    final uid = _currentUserId();
    if (uid == null) throw StateError('Authentication required.');
    final prefs = await SharedPreferences.getInstance();
    if (uid != _currentUserId()) throw StateError('User session changed.');
    await prefs.setString(_modeKey(toolkitSlug, uid), mode.name);
    await prefs.remove(_alwaysKey(toolkitSlug, uid));
  }

  Future<Set<String>> alwaysAllowedTools(String toolkitSlug) async {
    final uid = _currentUserId();
    if (uid == null) return {};
    final prefs = await SharedPreferences.getInstance();
    if (uid != _currentUserId()) return {};
    return (prefs.getStringList(_alwaysKey(toolkitSlug, uid)) ??
            const <String>[])
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  Future<bool> isAlwaysAllowed(String toolkitSlug, String toolSlug) async {
    final uid = _currentUserId();
    if (uid == null) return false;
    final mode = await modeForToolkit(toolkitSlug);
    if (uid != _currentUserId()) return false;
    if (mode == IntegrationPermissionMode.allowAll) return true;
    if (mode == IntegrationPermissionMode.allowRead &&
        isClearlyReadOnly(toolkitSlug: toolkitSlug, toolSlug: toolSlug)) {
      return true;
    }

    final rules = await alwaysAllowedTools(toolkitSlug);
    return uid == _currentUserId() &&
        rules.contains(toolSlug.trim().toUpperCase());
  }

  /// Conservative local classifier used only by the "Allow reading" preset.
  /// Unknown actions are NOT treated as reads; Cortex asks instead.
  bool isClearlyReadOnly({
    required String toolkitSlug,
    required String toolSlug,
    String description = '',
  }) {
    var normalized = toolSlug.trim().toUpperCase();
    final toolkitPrefix = '${toolkitSlug.trim().toUpperCase()}_';
    if (normalized.startsWith(toolkitPrefix)) {
      normalized = normalized.substring(toolkitPrefix.length);
    }

    final tokens = normalized
        .split(RegExp(r'[_\-\s]+'))
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (tokens.isEmpty) return false;

    // Any mutation-looking verb wins over a read-looking verb. This prevents
    // names such as "GET_AND_DELETE" from being auto-approved.
    if (tokens.any(_writeVerbs.contains)) return false;
    if (_readVerbs.contains(tokens.first)) return true;

    // Descriptions are a weak fallback only when they clearly say read-only.
    final text = description.toLowerCase();
    const mutationWords = [
      'create',
      'send',
      'update',
      'edit',
      'delete',
      'remove',
      'write',
      'change',
      'modify',
      'upload',
      'post',
      'publish',
    ];
    if (mutationWords.any(text.contains)) return false;

    return text.contains('read-only') ||
        text.contains('read only') ||
        text.startsWith('get ') ||
        text.startsWith('list ') ||
        text.startsWith('search ') ||
        text.startsWith('fetch ');
  }

  Future<void> setAlwaysAllowed(
    String toolkitSlug,
    String toolSlug, {
    required bool allowed,
  }) async {
    final uid = _currentUserId();
    if (uid == null) throw StateError('Authentication required.');
    final prefs = await SharedPreferences.getInstance();
    final rules = await alwaysAllowedTools(toolkitSlug);
    if (uid != _currentUserId()) throw StateError('User session changed.');
    final normalized = toolSlug.trim().toUpperCase();
    if (normalized.isEmpty) return;

    if (allowed) {
      rules.add(normalized);
    } else {
      rules.remove(normalized);
    }

    final sorted = rules.toList()..sort();
    if (sorted.isEmpty) {
      await prefs.remove(_alwaysKey(toolkitSlug, uid));
    } else {
      await prefs.setStringList(_alwaysKey(toolkitSlug, uid), sorted);
    }
  }

  /// Restores Cortex's conservative default: ask before actions and remove all
  /// per-action permanent exceptions for the integration.
  Future<void> resetToolkit(String toolkitSlug) async {
    final uid = _currentUserId();
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_modeKey(toolkitSlug, uid));
    await prefs.remove(_alwaysKey(toolkitSlug, uid));
  }

  Future<void> clearToolkit(String toolkitSlug) => resetToolkit(toolkitSlug);
}
