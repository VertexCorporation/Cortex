import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Exact deployed Fulcrum origins, never a shared cloud-provider suffix.
bool isFulcrumUri(Uri uri) =>
    uri.scheme == 'https' &&
    uri.port == 443 &&
    uri.userInfo.isEmpty &&
    const {
      'europe-west1-vertex-ai-1618.cloudfunctions.net',
      'sendmessage-o5h7dmtija-ew.a.run.app',
      'generatefasttitle-o5h7dmtija-ew.a.run.app',
      'executetool-o5h7dmtija-ew.a.run.app',
      'getspeechtoken-o5h7dmtija-ew.a.run.app',
      'getassemblytoken-o5h7dmtija-ew.a.run.app',
      'settlespeechusage-o5h7dmtija-ew.a.run.app',
      'synthesizespeech-o5h7dmtija-ew.a.run.app',
    }.contains(uri.host);

const _header = 'X-Firebase-AppCheck';
void _removeToken(Map<String, dynamic> headers) =>
    headers.removeWhere((key, _) => key.toLowerCase() == _header.toLowerCase());

/// Share only in-flight work. Firebase owns the token cache and refresh policy.
class FulcrumAppCheckInterceptor extends Interceptor {
  FulcrumAppCheckInterceptor({
    Future<String?> Function()? readToken,
    this.tokenWait = const Duration(milliseconds: 500),
  }) : _readToken = readToken ?? (() => FirebaseAppCheck.instance.getToken());

  final Future<String?> Function() _readToken;
  final Duration tokenWait;
  Future<String?>? _pending;

  Future<String?> _read() async => await _readToken();

  Future<String?> _token() {
    return _pending ??= _read()
        .timeout(tokenWait, onTimeout: () => null)
        .catchError((Object _) => null)
        .whenComplete(() => _pending = null);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Also removes stale headers when a RequestOptions is reused for another URL.
    _removeToken(options.headers);
    // Browser redirects cannot be inspected safely; Cortex's web Firebase
    // configuration is currently a placeholder, with no App Check provider.
    if (!kIsWeb && isFulcrumUri(options.uri)) {
      final token = await _token();
      if (token != null && token.isNotEmpty) options.headers[_header] = token;
    }
    handler.next(options);
  }
}

final _appCheck = FulcrumAppCheckInterceptor();

/// Keep each service's timeouts, cancellation, streaming and retry configuration.
Dio configureFulcrumHttp(Dio dio) {
  if (!dio.interceptors.any((i) => i is FulcrumAppCheckInterceptor)) {
    dio.interceptors.insert(0, _appCheck);
  }
  if (dio.httpClientAdapter is! FulcrumRedirectAdapter) {
    dio.httpClientAdapter = FulcrumRedirectAdapter(dio.httpClientAdapter);
  }
  return dio;
}

Dio createFulcrumHttp([BaseOptions? options]) =>
    configureFulcrumHttp(Dio(options));

/// Native automatic redirects forward custom headers. Follow token-bearing
/// redirects explicitly so the App Check credential cannot leave Fulcrum.
/// Request bodies are not replayed; this matches dart:io redirect semantics.
class FulcrumRedirectAdapter implements HttpClientAdapter {
  FulcrumRedirectAdapter(this.delegate);
  final HttpClientAdapter delegate;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (!options.followRedirects ||
        !options.headers.keys.any(
          (key) => key.toLowerCase() == _header.toLowerCase(),
        )) {
      return delegate.fetch(options, requestStream, cancelFuture);
    }
    var current = options.copyWith(followRedirects: false);
    var body = requestStream;
    final redirects = <RedirectRecord>[];
    while (true) {
      final response = await delegate.fetch(current, body, cancelFuture);
      final location = response.headers['location']?.firstOrNull;
      final status = response.statusCode;
      final canRedirect =
          const {301, 302, 303, 307, 308}.contains(status) &&
          (current.method == 'GET' ||
              current.method == 'HEAD' ||
              (current.method == 'POST' && status == 303));
      if (!canRedirect || location == null) {
        response.redirects = [...redirects, ...?response.redirects];
        return response;
      }
      await response.stream.listen(null).cancel();
      if (redirects.length >= options.maxRedirects) {
        throw DioException(
          requestOptions: options,
          message: 'Too many redirects',
        );
      }
      final target = current.uri.resolve(location);
      final headers = Map<String, dynamic>.from(current.headers);
      if (!isFulcrumUri(target)) _removeToken(headers);
      // Match native sensitive-header behavior across unrelated domains.
      if (target.host != current.uri.host &&
          !target.host.endsWith('.${current.uri.host}')) {
        headers.removeWhere(
          (key, _) => const {
            'authorization',
            'cookie',
            'www-authenticate',
          }.contains(key.toLowerCase()),
        );
      }
      headers.removeWhere((key, _) => key.toLowerCase() == 'content-length');
      final method = current.method == 'POST' ? 'GET' : current.method;
      redirects.add(RedirectRecord(status, method, target));
      current = current.copyWith(
        path: target.toString(),
        baseUrl: '',
        queryParameters: {},
        method: method,
        headers: headers,
      );
      body = null;
    }
  }

  @override
  void close({bool force = false}) => delegate.close(force: force);
}
