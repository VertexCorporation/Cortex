import 'dart:convert';
import 'package:cortex/chat/services/local_finance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves explicit single-symbol price requests', () {
    expect(LocalFinance.symbolFor('AAPL fiyatı kaç?'), 'AAPL');
    expect(LocalFinance.symbolFor('THYAO.IS kaç TL?'), 'THYAO.IS');
    expect(LocalFinance.symbolFor('Bitcoin fiyatı kaç?'), 'BTC-USD');
    expect(LocalFinance.symbolFor('BTC-USD price'), 'BTC-USD');
  });
  test('does not guess ambiguous, non-price or opted-out requests', () {
    for (final text in ['Apple fiyatı', 'AAPL ve MSFT fiyatı',
      'AAPL tarihini anlat', 'AAPL fiyatı internetsiz', 'Translate AAPL price']) {
      expect(LocalFinance.symbolFor(text), isNull, reason: text);
    }
  });
  test('validates prices and explicitly leaves market time unknown', () {
    final time = DateTime.utc(2026, 9, 9);
    final summary = LocalFinance.summary('AAPL',
        jsonEncode({'data': {'price': 123.45, 'currency': 'USD'}}), time)!;
    final data = jsonDecode(summary);
    expect(data['price'], 123.45);
    expect(data['marketTimestamp'], isNull);
    expect(data['retrievedAtUtc'], time.toIso8601String());
    for (final response in ['{}', 'not json', '{"error":"unavailable"}',
      '{"data":{"price":-1,"currency":"USD"}}']) {
      expect(LocalFinance.summary('AAPL', response, time), isNull);
    }
  });
}
