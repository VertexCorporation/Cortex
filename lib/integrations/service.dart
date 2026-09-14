import 'dart:collection';
import 'dart:typed_data';

import 'package:cortex/network/fulcrum_http.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'model.dart';

class IntegrationService {
  IntegrationService._();

  static final IntegrationService instance = IntegrationService._();

  static const String _base =
      'https://europe-west1-vertex-ai-1618.cloudfunctions.net';
  static const int maxLogoBytes = 2 * 1024 * 1024;
  static const int _maxLogoCacheEntries = 72;

  final Dio _api = createFulcrumHttp(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      sendTimeout: const Duration(seconds: 15),
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

  Future<Map<String, String>> _authHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Authentication required.');
    final token = await user.getIdToken();
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
    final response = await _api.get<Map<String, dynamic>>(
      '$_base/getIntegrations',
      queryParameters: {
        'limit': limit.clamp(1, 300),
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
      },
      options: Options(headers: await _authHeaders()),
    );

    final data = response.data;
    if (data == null) throw StateError('Empty integrations response.');
    return IntegrationCatalogPage.fromJson(data);
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
          validateStatus: (status) => status != null && status >= 200 && status < 300,
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
