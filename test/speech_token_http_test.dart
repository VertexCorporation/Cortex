import 'dart:typed_data';

import 'package:cortex/chat/services/stt_remote.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _ResponseAdapter implements HttpClientAdapter {
  _ResponseAdapter(this.status, this.body, this.type);
  final int status;
  final String body;
  final String type;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [type],
    },
  );
  @override
  void close({bool force = false}) {}
}

void main() {
  for (final type in ['text/html', 'text/plain', 'application/json']) {
    test('500 crash page survives Dio decoding with $type', () async {
      final dio = Dio()
        ..httpClientAdapter = _ResponseAdapter(
          500,
          '<html>Memory limit exceeded</html>',
          type,
        );
      addTearDown(dio.close);
      final response = await requestSpeechToken(
        dio,
        'https://example.test',
        idToken: 'test',
        data: {},
      );
      expect(response.statusCode, 500);
      expect(decodeSpeechTokenResponse(response.data), isNull);
      expect(
        RemoteSttService.blocksSpeechFallback(response.statusCode),
        isFalse,
      );
      expect(
        RemoteSttService.refusalBodyPreview(response.data),
        contains('Memory limit exceeded'),
      );
    });
  }
  for (final entry in [
    (401, '{"error":"Unauthorized"}', false),
    (403, '{"error":"voice_daily_limit"}', true),
    (403, '{"error":"app_check_failed"}', false),
    (403, '<html>Forbidden</html>', false),
  ]) {
    test(
      'refusal ${entry.$1} ${entry.$2} blocks all speech fallback',
      () async {
        final dio = Dio()
          ..httpClientAdapter = _ResponseAdapter(
            entry.$1,
            entry.$2,
            'application/json',
          );
        addTearDown(dio.close);
        final response = await requestSpeechToken(
          dio,
          'https://example.test',
          idToken: 'test',
          data: {},
        );
        expect(
          RemoteSttService.blocksSpeechFallback(response.statusCode),
          isTrue,
        );
        expect(
          RemoteSttService.isDailyVoiceLimitRefusal(
            response.statusCode,
            decodeSpeechTokenResponse(response.data),
          ),
          entry.$3,
        );
      },
    );
  }
  test('valid JSON token response remains usable', () async {
    final dio = Dio()
      ..httpClientAdapter = _ResponseAdapter(
        200,
        '{"token":"test","voice":{"reservedSeconds":120}}',
        'application/json',
      );
    addTearDown(dio.close);
    final response = await requestSpeechToken(
      dio,
      'https://example.test',
      idToken: 'test',
      data: {},
    );
    expect(decodeSpeechTokenResponse(response.data)?['token'], 'test');
  });
  test('diagnostics do not expose token fields or bearer credentials', () {
    for (final body in [
      {'token': 'private-secret'},
      '{"access_token":"private-secret"}',
      'upstream Authorization: Bearer private-secret',
      'upstream token=private-secret',
      {'error': 'upstream token=private-secret'},
    ]) {
      expect(
        RemoteSttService.refusalBodyPreview(body),
        isNot(contains('private-secret')),
      );
    }
  });
}
