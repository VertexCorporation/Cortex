import 'dart:collection';
import 'dart:typed_data';

import 'package:cortex/network/fulcrum_http.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'model.dart';

class IntegrationLimitException implements Exception {
  const IntegrationLimitException();
}

class IntegrationConnectionRequiredException implements Exception {
  final String toolkitSlug;
  final String toolkitName;
  final String? logoUrl;

  const IntegrationConnectionRequiredException({
    required this.toolkitSlug,
    required this.toolkitName,
    required this.logoUrl,
  });
}

/// Fulcrum-backed integration client.
///
/// Composio credentials never enter the app. This class only talks to
/// authenticated Fulcrum endpoints and keeps a tiny amount of ephemeral state
/// for the current chat turn and live tool activity presentation.
class IntegrationService extends ChangeNotifier {
  IntegrationService._();

  static final IntegrationService instance = IntegrationService._();

  static const String _base =
      'https://europe-west1-vertex-ai-1618.cloudfunctions.net';
  static const int maxLogoBytes = 2 * 1024 * 1024;
  static const int _maxLogoCacheEntries = 72;
  static const Uuid _uuid = Uuid();

  final Dio _api = createFulcrumHttp(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 45),
      sendTimeout: const Duration(seconds: 20),
    ),
  );
  final Dio _logoClient = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 10),
      followRedirects: true,
      maxRedirects: 3,
    ),
  );

  final LinkedHashMap<String, Uint8List> _logoCache = LinkedHashMap();
  IntegrationCatalogPage? _lastCatalog;
  String? _catalogUserId;
  String? _turnId;

  IntegrationToolInfo? _activeIntegrationTool;
  IntegrationToolInfo? get activeIntegrationTool => _activeIntegrationTool;

  List<IntegrationItem> get installed =>
      _catalogUserId == FirebaseAuth.instance.currentUser?.uid
          ? _lastCatalog?.installed ?? const <IntegrationItem>[]
          : const <IntegrationItem>[];

  void setActiveIntegrationTool(IntegrationToolInfo? tool) {
    if (identical(tool, _activeIntegrationTool)) return;
    _activeIntegrationTool = tool;
    notifyListeners();
  }

  String _ensureTurnId() => _turnId ??= _uuid.v4();

  /// Ends the message-scoped integration usage identity. ToolRegistry calls
  /// this when the assistant's tool loop finishes so multiple tool calls in
  /// one answer count as one plugin-powered message, not one action each.
  void endTurn() {
    _turnId = null;
    setActiveIntegrationTool(null);
  }

  Future<Map<String, String>> _authHeaders({String? expectedUserId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Authentication required.');
    if (expectedUserId != null && user.uid != expectedUserId) {
      throw StateError('User session changed.');
    }
    final token = await user.getIdToken();
    if (FirebaseAuth.instance.currentUser?.uid != user.uid) {
      throw StateError('User session changed.');
    }
    if (token == null || token.isEmpty) {
      throw StateError('Authentication token unavailable.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<IntegrationCatalogPage> fetchCatalog({
    String search = '',
    String? category,
    int limit = 220,
  }) async {
    final requestUserId = FirebaseAuth.instance.currentUser?.uid;
    if (requestUserId == null) throw StateError('Authentication required.');
    final response = await _api.get<Map<String, dynamic>>(
      '$_base/getIntegrations',
      queryParameters: {
        'limit': limit.clamp(1, 300),
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
      },
      options: Options(headers: await _authHeaders(expectedUserId: requestUserId)),
    );

    if (requestUserId != FirebaseAuth.instance.currentUser?.uid) {
      throw StateError('User session changed.');
    }
    if (_catalogUserId != requestUserId) _lastCatalog = null;
    _catalogUserId = requestUserId;
    final data = response.data;
    if (data == null) throw StateError('Empty integrations response.');
    final catalog = IntegrationCatalogPage.fromJson(data);

    // Preserve installed accounts even when this response is a narrow search.
    if (search.trim().isEmpty || _lastCatalog == null) {
      _lastCatalog = catalog;
    } else {
      _lastCatalog = IntegrationCatalogPage(
        items: catalog.items,
        installed: catalog.installed.isNotEmpty
            ? catalog.installed
            : _lastCatalog!.installed,
        nextCursor: catalog.nextCursor,
        totalItems: catalog.totalItems,
      );
    }
    notifyListeners();
    return catalog;
  }

  Future<IntegrationToolDiscovery> discoverTools({
    required String capability,
    String? preferredToolkit,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '$_base/discoverIntegrationTools',
      queryParameters: {
        'query': capability.trim(),
        if (preferredToolkit != null && preferredToolkit.trim().isNotEmpty)
          'preferredToolkit': preferredToolkit.trim().toLowerCase(),
      },
      options: Options(headers: await _authHeaders()),
    );

    final data = response.data;
    if (data == null) throw StateError('Empty integration tools response.');
    return IntegrationToolDiscovery.fromJson(data);
  }

  /// Resolves one exact Composio action on Fulcrum before Cortex asks for
  /// permission. The permission card therefore uses trusted toolkit metadata
  /// and a server-provided action description, never model-authored wording.
  Future<IntegrationToolInfo> inspectTool(String toolSlug) async {
    final response = await _api.get<Map<String, dynamic>>(
      '$_base/getIntegrationTool',
      queryParameters: {'toolSlug': toolSlug.trim().toUpperCase()},
      options: Options(headers: await _authHeaders()),
    );
    final data = response.data;
    if (data == null) throw StateError('Empty integration tool response.');
    if (data['code']?.toString() == 'integration_connection_required') {
      final toolkit = data['toolkit'];
      final map = toolkit is Map
          ? Map<String, dynamic>.from(toolkit)
          : const <String, dynamic>{};
      throw IntegrationConnectionRequiredException(
        toolkitSlug: (map['slug'] ?? '').toString(),
        toolkitName: (map['name'] ?? map['slug'] ?? 'Plugin').toString(),
        logoUrl: map['logo']?.toString(),
      );
    }
    final rawTool = data['tool'];
    if (rawTool is! Map) throw StateError('Integration tool metadata missing.');
    return IntegrationToolInfo.fromJson(Map<String, dynamic>.from(rawTool));
  }

  Future<IntegrationExecutionResult> executeTool({
    required String toolSlug,
    required Map<String, dynamic> arguments,
    String? version,
    String? expectedUserId,
  }) async {
    final headers = await _authHeaders(expectedUserId: expectedUserId);
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '$_base/executeIntegrationTool',
        data: {
          'toolSlug': toolSlug,
          'arguments': arguments,
          'turnId': _ensureTurnId(),
          if (version != null && version.trim().isNotEmpty)
            'version': version.trim(),
        },
        options: Options(headers: headers),
      );
      final data = response.data;
      if (data == null) throw StateError('Empty integration execution response.');
      return IntegrationExecutionResult.fromJson(data);
    } on DioException catch (error) {
      final raw = error.response?.data;
      final body = raw is Map
          ? Map<String, dynamic>.from(raw)
          : const <String, dynamic>{};
      final code = body['code']?.toString();
      if (code == 'integration_daily_limit') {
        throw const IntegrationLimitException();
      }
      if (code == 'integration_connection_required') {
        final toolkit = body['toolkit'];
        final map = toolkit is Map
            ? Map<String, dynamic>.from(toolkit)
            : const <String, dynamic>{};
        throw IntegrationConnectionRequiredException(
          toolkitSlug: (map['slug'] ?? '').toString(),
          toolkitName: (map['name'] ?? map['slug'] ?? 'Plugin').toString(),
          logoUrl: map['logo']?.toString(),
        );
      }
      rethrow;
    }
  }

  IntegrationItem? installedBySlug(String slug) {
    final normalized = slug.trim().toLowerCase();
    for (final item in installed) {
      if (item.slug.toLowerCase() == normalized) return item;
    }
    return null;
  }

  Future<Uri> createConnection(String toolkitSlug) async {
    final response = await _api.post<Map<String, dynamic>>(
      '$_base/startIntegrationConnection',
      data: {'toolkitSlug': toolkitSlug},
      options: Options(headers: await _authHeaders()),
    );

    final raw = response.data?['redirectUrl']?.toString() ?? '';
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw StateError('Invalid integration redirect URL.');
    }
    return uri;
  }

  Future<void> disconnect(String connectedAccountId) async {
    await _api.post<Map<String, dynamic>>(
      '$_base/disconnectIntegration',
      data: {'connectedAccountId': connectedAccountId},
      options: Options(headers: await _authHeaders()),
    );
  }

  Future<Uint8List?> loadLogo(String? rawUrl) async {
    if (rawUrl == null || rawUrl.isEmpty) return null;
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;

    final cached = _logoCache.remove(rawUrl);
    if (cached != null) {
      _logoCache[rawUrl] = cached;
      return cached;
    }

    try {
      final response = await _logoClient.get<ResponseBody>(
        rawUrl,
        options: Options(
          responseType: ResponseType.stream,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );

      final lengthHeader = response.headers.value(Headers.contentLengthHeader);
      final declaredLength = int.tryParse(lengthHeader ?? '');
      if (declaredLength != null && declaredLength > maxLogoBytes) return null;

      final body = response.data;
      if (body == null) return null;

      final builder = BytesBuilder(copy: false);
      var total = 0;
      await for (final chunk in body.stream) {
        total += chunk.length;
        if (total > maxLogoBytes) return null;
        builder.add(chunk);
      }

      final bytes = builder.takeBytes();
      if (bytes.isEmpty) return null;

      _logoCache[rawUrl] = bytes;
      while (_logoCache.length > _maxLogoCacheEntries) {
        _logoCache.remove(_logoCache.keys.first);
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  void clearLogoCache() => _logoCache.clear();
}
