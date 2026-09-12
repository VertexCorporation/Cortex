import 'package:cortex/chat/services/api.dart';
import 'package:cortex/l10n/app_localizations_en.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAuth extends Fake implements FirebaseAuth {
  User? user;
  @override
  User? get currentUser => user;
}

class TestUser extends Fake implements User {
  TestUser(this.uid, this.readToken);
  @override
  final String uid;
  final Future<String?> Function(bool) readToken;
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) =>
      readToken(forceRefresh);
}

void main() {
  late TestAuth auth;
  late Dio dio;
  late ApiService api;
  late List<String?> headers;
  late int responseStatus;

  setUp(() {
    auth = TestAuth();
    headers = [];
    responseStatus = 400;
    dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      headers.add(options.headers['Authorization'] as String?);
      // Stop at the transport boundary: never contact the production backend.
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: responseStatus),
      ));
    }));
    api = ApiService(auth: auth, dio: dio);
  });

  tearDown(() => dio.close(force: true));

  Future<String> request() => api.getCharacterResponse(
        userInput: 'test',
        context: [],
        characterId: 'test',
        isPremium: false,
        baseModelId: 'test',
        localizations: AppLocalizationsEn(),
      );

  Future<void> rejectedRequest() async {
    await expectLater(request(), throwsA(isA<ApiException>()));
  }

  test('a reused service obtains the active account token on each request', () async {
    auth.user = TestUser('a', (_) async => 'token-a');
    await rejectedRequest();
    auth.user = TestUser('b', (_) async => 'token-b');
    await rejectedRequest();
    expect(headers, ['Bearer token-a', 'Bearer token-b']);
  });

  test('uses renewed SDK tokens for the same account', () async {
    var token = 'first';
    auth.user = TestUser('a', (_) async => token);
    await rejectedRequest();
    token = 'renewed';
    await rejectedRequest();
    expect(headers, ['Bearer first', 'Bearer renewed']);
  });

  test('missing tokens never reach the transport', () async {
    for (final token in <String?>[null, '']) {
      auth.user = TestUser('a', (_) async => token);
      await rejectedRequest();
    }
    expect(headers, isEmpty);
  });

  test('account switch during token lookup aborts before sending', () async {
    auth.user = TestUser('a', (_) async {
      auth.user = TestUser('b', (_) async => 'token-b');
      return 'token-a';
    });
    await expectLater(request(), throwsA(isA<ApiException>().having(
      (e) => e.code, 'code', 'USER_CHANGED')));
    expect(headers, isEmpty);
  });

  test('logout during token lookup aborts before sending', () async {
    auth.user = TestUser('a', (_) async {
      auth.user = null;
      return 'token-a';
    });
    await rejectedRequest();
    expect(headers, isEmpty);
  });

  test('401 retry refreshes only the original active account', () async {
    responseStatus = 401;
    final refreshes = <bool>[];
    auth.user = TestUser('a', (refresh) async {
      refreshes.add(refresh);
      if (refresh) auth.user = TestUser('b', (_) async => 'token-b');
      return 'token-a';
    });
    await rejectedRequest();
    expect(refreshes, [false, true]);
    expect(headers, ['Bearer token-a']);
  });
}
