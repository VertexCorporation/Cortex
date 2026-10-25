// lib/apps/service.dart
//
// HTTP client for Fulcrum's app integration endpoints (functions/src/
// integrations.js). Composio credentials stay on Fulcrum; Cortex only sends
// the Firebase ID token and receives catalog data, OAuth links and results.

import 'package:cortex/network/fulcrum_http.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models.dart';

class AppsException implements Exception {
  final String message;
  final int? status;
  final String? code;

  const AppsException(this.message, {this.status, this.code});

  @override
  String toString() => message;
}

class AppsService {
  AppsService._();

  static final AppsService instance = AppsService._();

  static const String _base =
      'https://europe-west1-vertex-ai-1618.cloudfunctions.net';

  final Dio _dio = createFulcrumHttp(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60),
    validateStatus: (_) => true,
  ));

  Future<Options> _options() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const AppsException('Not signed in.', status: 401);
    }
    final token = await user.getIdToken();
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }

  Map<String, dynamic> _body(Response response) {
    final data = response.data;
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw AppsException(
        (map['error'] ?? 'Request failed ($status).').toString(),
        status: status,
        code: map['code']?.toString(),
      );
    }
    return map;
  }

  Future<AppsCatalogPage> fetchCatalog({
    String search = '',
    String category = '',
    String? cursor,
    int limit = 220,
    String language = 'en',
  }) async {
    final response = await _dio.get(
      '$_base/getIntegrations',
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (category.isNotEmpty) 'category': category,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
        'lang': language,
      },
      options: await _options(),
    );
    final body = _body(response);
    final items = body['items'];
    var rank = 0;
    return AppsCatalogPage(
      items: items is List
          ? items
              .whereType<Map>()
              .map((item) => CortexApp.fromJson(
                    Map<String, dynamic>.from(item),
                    rank: rank++,
                  ))
              .where((app) => app.slug.isNotEmpty)
              .toList()
          : const [],
      nextCursor: body['nextCursor']?.toString(),
    );
  }

  /// Returns the Composio-hosted OAuth/API-key page for [toolkitSlug].
  Future<Uri> startConnection(String toolkitSlug) async {
    final response = await _dio.post(
      '$_base/startIntegrationConnection',
      data: {'toolkitSlug': toolkitSlug},
      options: await _options(),
    );
    final url = Uri.tryParse((_body(response)['redirectUrl'] ?? '').toString());
    if (url == null || url.scheme != 'https') {
      throw const AppsException('Invalid connection link.');
    }
    return url;
  }

  Future<void> disconnect(String connectedAccountId) async {
    final response = await _dio.post(
      '$_base/disconnectIntegration',
      data: {'connectedAccountId': connectedAccountId},
      options: await _options(),
    );
    _body(response);
  }

  Future<void> setPermission(String toolkitSlug, AppPermission permission) async {
    final response = await _dio.post(
      '$_base/setIntegrationPermission',
      data: {'toolkitSlug': toolkitSlug, 'permission': permission.wire},
      options: await _options(),
    );
    _body(response);
  }

  /// Finds actions in the user's connected apps for a natural-language need.
  Future<Map<String, dynamic>> discoverActions(
    String query, {
    String? preferredApp,
  }) async {
    final response = await _dio.get(
      '$_base/discoverIntegrationTools',
      queryParameters: {
        'query': query,
        if (preferredApp != null && preferredApp.isNotEmpty)
          'preferredToolkit': preferredApp,
      },
      options: await _options(),
    );
    return _body(response);
  }

  Future<Map<String, dynamic>> inspectAction(String actionSlug) async {
    final response = await _dio.get(
      '$_base/getIntegrationTool',
      queryParameters: {'toolSlug': actionSlug},
      options: await _options(),
    );
    return _body(response);
  }

  Future<Map<String, dynamic>> executeAction({
    required String actionSlug,
    required Map<String, dynamic> arguments,
    required String turnId,
  }) async {
    final response = await _dio.post(
      '$_base/executeIntegrationTool',
      data: {
        'toolSlug': actionSlug,
        'arguments': arguments,
        'turnId': turnId,
      },
      options: (await _options()).copyWith(
        receiveTimeout: const Duration(seconds: 100),
      ),
    );
    return _body(response);
  }
}
