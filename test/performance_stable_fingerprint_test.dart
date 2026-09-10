import 'package:cortex/performance/stable_fingerprint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('map key order does not affect fingerprint', () {
    final a = <String, dynamic>{
      'name': 'Ada',
      'credits': 42,
      'nested': {'b': 2, 'a': 1},
    };
    final b = <String, dynamic>{
      'nested': {'a': 1, 'b': 2},
      'credits': 42,
      'name': 'Ada',
    };
    expect(StableFingerprint.of(a), StableFingerprint.of(b));
  });

  test('list order remains significant', () {
    expect(
      StableFingerprint.of([1, 2, 3]),
      isNot(StableFingerprint.of([3, 2, 1])),
    );
  });

  test('nested material change changes fingerprint', () {
    final before = {
      'subscription': {'tier': 'plus', 'active': true},
    };
    final after = {
      'subscription': {'tier': 'pro', 'active': true},
    };
    expect(StableFingerprint.of(before), isNot(StableFingerprint.of(after)));
  });

  test('FingerprintGuard reports only changes', () {
    final guard = FingerprintGuard();
    expect(guard.changed({'a': 1}), isTrue);
    expect(guard.changed({'a': 1}), isFalse);
    expect(guard.changed({'a': 2}), isTrue);
    guard.reset();
    expect(guard.changed({'a': 2}), isTrue);
  });
}
