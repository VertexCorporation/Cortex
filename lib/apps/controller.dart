// lib/apps/controller.dart
//
// App-wide state for Cortex Apps: catalog, connections and per-app
// permissions. The connected-app summary is persisted so chat can decide
// synchronously whether to offer app tools, and so permissions are enforced
// on the device even before Fulcrum confirms them.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models.dart';
import 'service.dart';

class ConnectedAppSummary {
  final String slug;
  final String name;
  final String? logo;
  final AppPermission permission;

  const ConnectedAppSummary({
    required this.slug,
    required this.name,
    required this.logo,
    required this.permission,
  });

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'name': name,
        'logo': logo,
        'permission': permission.wire,
      };

  factory ConnectedAppSummary.fromJson(Map<String, dynamic> json) =>
      ConnectedAppSummary(
        slug: (json['slug'] ?? '').toString(),
        name: (json['name'] ?? json['slug'] ?? '').toString(),
        logo: json['logo']?.toString(),
        permission: AppPermission.fromWire(json['permission']),
      );
}

class AppsController extends ChangeNotifier {
  AppsController._();

  static final AppsController instance = AppsController._();

  static const String _prefsKey = 'cortex_apps_state_v1';

  final AppsService _service = AppsService.instance;

  List<CortexApp> _apps = const [];
  String? _language;
  bool _loading = false;
  Object? _error;
  bool _restored = false;
  String? _awaitingConnection;
  Future<void>? _inFlight;

  /// Source of truth for chat tools and on-device permission checks.
  Map<String, ConnectedAppSummary> _connected = {};

  /// Local permission choices, kept even if Fulcrum could not store them.
  Map<String, AppPermission> _permissions = {};

  List<CortexApp> get apps => _apps;
  bool get isLoading => _loading;
  Object? get error => _error;
  String? get awaitingConnection => _awaitingConnection;

  List<CortexApp> get installed =>
      _apps.where((app) => app.connected).toList(growable: false);

  /// Connected apps that chat may use.
  List<ConnectedAppSummary> get chatApps => _connected.values
      .where((app) => permissionFor(app.slug) != AppPermission.off)
      .toList(growable: false);

  AppPermission permissionFor(String slug) =>
      _permissions[slug] ??
      _connected[slug]?.permission ??
      AppPermission.ask;

  ConnectedAppSummary? connectedApp(String slug) => _connected[slug];

  /// Loads persisted connections once; cheap and safe to call repeatedly.
  Future<void> restore() async {
    if (_restored) return;
    _restored = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final json = jsonDecode(raw);
      if (json is! Map) return;
      final connected = json['connected'];
      if (connected is List) {
        _connected = {
          for (final item in connected.whereType<Map>())
            if ((item['slug'] ?? '').toString().isNotEmpty)
              item['slug'].toString(): ConnectedAppSummary.fromJson(
                Map<String, dynamic>.from(item),
              ),
        };
      }
      final permissions = json['permissions'];
      if (permissions is Map) {
        _permissions = {
          for (final entry in permissions.entries)
            entry.key.toString(): AppPermission.fromWire(entry.value),
        };
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[Apps] restore failed: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode({
          'connected': _connected.values.map((app) => app.toJson()).toList(),
          'permissions': {
            for (final entry in _permissions.entries) entry.key: entry.value.wire,
          },
        }),
      );
    } catch (e) {
      debugPrint('[Apps] persist failed: $e');
    }
  }

  /// Fetches the catalog in [language]; concurrent calls share one request.
  Future<void> load({required String language, bool force = false}) {
    if (!force && _language == language && _apps.isNotEmpty) {
      return Future.value();
    }
    return _inFlight ??= _load(language).whenComplete(() => _inFlight = null);
  }

  Future<void> _load(String language) async {
    await restore();
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _service.fetchCatalog(language: language);
      _language = language;
      _apps = page.items.map(_withLocalPermission).toList(growable: false);
      _syncConnected(_apps);
    } catch (e) {
      debugPrint('[Apps] load failed: $e');
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  CortexApp _withLocalPermission(CortexApp app) {
    final local = _permissions[app.slug];
    return local == null ? app : app.copyWith(permission: local);
  }

  void _syncConnected(Iterable<CortexApp> apps) {
    // The catalog request only covers the top apps, so keep connections for
    // apps outside it and update the ones it reports.
    for (final app in apps) {
      if (app.connected) {
        _connected[app.slug] = ConnectedAppSummary(
          slug: app.slug,
          name: app.name,
          logo: app.logo,
          permission: app.permission,
        );
      } else {
        _connected.remove(app.slug);
      }
    }
    if (_awaitingConnection != null &&
        _connected.containsKey(_awaitingConnection)) {
      _awaitingConnection = null;
    }
    _persist();
  }

  /// Server-side search across the whole Composio catalog.
  Future<List<CortexApp>> search(String query, {required String language}) async {
    final page = await _service.fetchCatalog(
      search: query,
      language: language,
      limit: 60,
    );
    _syncConnected(page.items);
    notifyListeners();
    return page.items.map(_withLocalPermission).toList(growable: false);
  }

  Future<List<CortexApp>> category(String id, {required String language}) async {
    final page = await _service.fetchCatalog(
      category: id,
      language: language,
      limit: 120,
    );
    _syncConnected(page.items);
    return page.items.map(_withLocalPermission).toList(growable: false);
  }

  CortexApp resolve(CortexApp app) {
    for (final current in _apps) {
      if (current.slug == app.slug) return current;
    }
    final connected = _connected[app.slug];
    return _withLocalPermission(connected == null
        ? app.copyWith(connected: false)
        : app.copyWith(connected: true, permission: connected.permission));
  }

  /// Opens the provider's sign-in page; the list refreshes on return.
  Future<void> connect(CortexApp app) async {
    final url = await _service.startConnection(app.slug);
    _awaitingConnection = app.slug;
    notifyListeners();
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened) {
      _awaitingConnection = null;
      notifyListeners();
      throw const AppsException('Could not open the browser.');
    }
  }

  /// Called when Cortex returns to the foreground after a sign-in.
  Future<void> refreshAfterConnection() async {
    final language = _language;
    if (_awaitingConnection == null || language == null) return;
    await load(language: language, force: true);
  }

  Future<void> disconnect(CortexApp app) async {
    final id = app.connectedAccountId;
    if (id == null) throw const AppsException('Missing connection.');
    await _service.disconnect(id);
    _connected.remove(app.slug);
    _apps = [
      for (final current in _apps)
        current.slug == app.slug
            ? current.copyWith(connected: false, clearAccount: true)
            : current,
    ];
    await _persist();
    notifyListeners();
  }

  /// Applies the choice locally at once, then stores it on Fulcrum, which
  /// enforces "read only" and "off" server-side as well.
  Future<void> setPermission(String slug, AppPermission permission) async {
    final previous = permissionFor(slug);
    _applyPermission(slug, permission);
    try {
      await _service.setPermission(slug, permission);
    } on AppsException catch (e) {
      // An older Fulcrum deployment without the permission endpoint still
      // gets on-device enforcement; any other failure is rolled back.
      if (e.status == 404) return;
      _applyPermission(slug, previous);
      rethrow;
    } catch (_) {
      _applyPermission(slug, previous);
      rethrow;
    }
  }

  void _applyPermission(String slug, AppPermission permission) {
    _permissions[slug] = permission;
    final summary = _connected[slug];
    if (summary != null) {
      _connected[slug] = ConnectedAppSummary(
        slug: summary.slug,
        name: summary.name,
        logo: summary.logo,
        permission: permission,
      );
    }
    _apps = [
      for (final current in _apps)
        current.slug == slug ? current.copyWith(permission: permission) : current,
    ];
    _persist();
    notifyListeners();
  }
}
