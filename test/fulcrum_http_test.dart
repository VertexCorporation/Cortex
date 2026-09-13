import 'dart:async';
import 'dart:typed_data';

import 'package:cortex/network/fulcrum_http.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const endpoint = 'https://sendmessage-o5h7dmtija-ew.a.run.app';

class RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final bodies = <List<int>>[];
  final responses = <ResponseBody>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    bodies.add(stream == null ? [] : await stream.expand((b) => b).toList());
    return responses.isEmpty
        ? ResponseBody.fromString('ok', 200)
        : responses.removeAt(0);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late RecordingAdapter adapter;
  setUp(() {
    dio = Dio();
    adapter = RecordingAdapter();
    dio.httpClientAdapter = adapter;
  });
  tearDown(() => dio.close());

  void install(Future<String?> Function() read, {Duration? timeout}) {
    dio.interceptors.add(
      FulcrumAppCheckInterceptor(
        readToken: read,
        tokenWait: timeout ?? const Duration(milliseconds: 500),
      ),
    );
    configureFulcrumHttp(dio);
  }

  test('exact Fulcrum origins only, including callable HTTP URLs', () {
    expect(isFulcrumUri(Uri.parse(endpoint)), isTrue);
    expect(
      isFulcrumUri(
        Uri.parse(
          'https://europe-west1-vertex-ai-1618.cloudfunctions.net/getNewsCacheUrl',
        ),
      ),
      isTrue,
    );
    for (final url in [
      'http://sendmessage-o5h7dmtija-ew.a.run.app',
      '$endpoint.evil.example',
      '$endpoint:444',
      'https://evil.run.app',
      'https://other.cloudfunctions.net',
      'https://storage.googleapis.com/bucket/file',
      'https://api.deepgram.com',
      'https://cortexishere.com/models',
      'https://user@sendmessage-o5h7dmtija-ew.a.run.app',
    ]) {
      expect(isFulcrumUri(Uri.parse(url)), isFalse, reason: url);
    }
  });

  test(
    'JSON and SSE retain authorization, headers, and streamed response',
    () async {
      install(() async => 'fixture-token');
      await dio.post(
        endpoint,
        data: {'message': 'hello'},
        options: Options(
          headers: {
            'Authorization': 'Bearer fixture-auth',
            'Accept': 'text/event-stream',
          },
        ),
      );
      final controller = StreamController<Uint8List>();
      adapter.responses.add(ResponseBody(controller.stream, 200));
      final response = await dio.post<ResponseBody>(
        endpoint,
        options: Options(responseType: ResponseType.stream),
      );
      final firstChunk = response.data!.stream.first;
      controller.add(Uint8List.fromList([1, 2, 3]));
      expect(await firstChunk, [1, 2, 3]);
      await controller.close();
      expect(
        adapter.requests.first.headers['Authorization'],
        'Bearer fixture-auth',
      );
      expect(adapter.requests.first.headers['Accept'], 'text/event-stream');
      expect(
        adapter.requests.every(
          (r) => r.headers['X-Firebase-AppCheck'] == 'fixture-token',
        ),
        isTrue,
      );
      expect(String.fromCharCodes(adapter.bodies.first), contains('hello'));
    },
  );

  test('multipart body and existing content type survive', () async {
    install(() async => 'fixture-token');
    await dio.post(
      endpoint,
      data: FormData.fromMap({
        'file': MultipartFile.fromString('upload bytes', filename: 'test.txt'),
      }),
    );
    expect(
      String.fromCharCodes(adapter.bodies.single),
      contains('upload bytes'),
    );
    expect(
      adapter.requests.single.headers['content-type'],
      startsWith('multipart/form-data'),
    );
  });

  test('null, empty, throwing and hung token providers fail open', () async {
    for (final read in <Future<String?> Function()>[
      () async => null,
      () async => '',
      () => throw StateError('SDK unavailable'),
      () => Completer<String?>().future,
    ]) {
      dio.interceptors.clear();
      install(read, timeout: const Duration(milliseconds: 1));
      await dio.get(endpoint);
      expect(
        adapter.requests.last.headers.containsKey('X-Firebase-AppCheck'),
        isFalse,
      );
    }
  });

  test(
    'parallel requests coalesce SDK access without retaining a token cache',
    () async {
      final token = Completer<String?>();
      var calls = 0;
      install(() {
        calls++;
        return token.future;
      });
      final requests = [dio.get(endpoint), dio.get(endpoint)];
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(calls, 1);
      token.complete('fixture-token');
      await Future.wait(requests);
      await dio.get(endpoint);
      expect(calls, 2);
    },
  );

  test(
    'third-party requests never read SDK and strip stale App Check only',
    () async {
      install(() => throw StateError('must not read SDK'));
      await dio.get(
        'https://api.example.com',
        options: Options(
          headers: {
            'x-firebase-appcheck': 'stale-fixture',
            'Authorization': 'existing',
          },
        ),
      );
      expect(
        adapter.requests.single.headers.keys.any(
          (key) => key.toLowerCase() == 'x-firebase-appcheck',
        ),
        isFalse,
      );
      expect(adapter.requests.single.headers['Authorization'], 'existing');
    },
  );

  test(
    'redirects retain token only on Fulcrum and preserve relative query',
    () async {
      install(() async => 'fixture-token');
      adapter.responses.addAll([
        ResponseBody.fromString(
          '',
          302,
          headers: {
            'location': ['/next?x=2'],
          },
        ),
        ResponseBody.fromString(
          '',
          302,
          headers: {
            'location': ['https://cdn.example.com/file'],
          },
        ),
      ]);
      await dio.get('$endpoint/start?x=1');
      expect(adapter.requests[1].uri.toString(), '$endpoint/next?x=2');
      expect(
        adapter.requests[1].headers['X-Firebase-AppCheck'],
        'fixture-token',
      );
      expect(
        adapter.requests[2].headers.containsKey('X-Firebase-AppCheck'),
        isFalse,
      );
      expect(adapter.requests.every((r) => !r.followRedirects), isTrue);
    },
  );

  test(
    '303 redirects do not replay uploads; explicit no-follow is respected',
    () async {
      install(() async => 'fixture-token');
      adapter.responses.add(
        ResponseBody.fromString(
          '',
          303,
          headers: {
            'location': ['/result'],
          },
        ),
      );
      await dio.post(endpoint, data: 'body');
      expect(adapter.requests.last.method, 'GET');
      expect(adapter.bodies.last, isEmpty);
      adapter.responses.add(
        ResponseBody.fromString(
          '',
          302,
          headers: {
            'location': ['/other'],
          },
        ),
      );
      final response = await dio.get(
        endpoint,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status == 302,
        ),
      );
      expect(response.statusCode, 302);
    },
  );

  test(
    'configuration is idempotent and cancellation remains effective',
    () async {
      install(() async => 'fixture-token');
      configureFulcrumHttp(dio);
      expect(
        dio.interceptors.whereType<FulcrumAppCheckInterceptor>(),
        hasLength(1),
      );
      final cancel = CancelToken()..cancel();
      await expectLater(
        dio.get(endpoint, cancelToken: cancel),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests, isEmpty);
    },
  );
}
