import 'package:cortex/chat/services/offline_cpu_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses safe core tiers with headroom on multicore devices', () {
    expect([1, 2, 4, 6, 8, 12].map(OfflineCpuPolicy.threadCount), [
      1,
      1,
      3,
      4,
      4,
      6,
    ]);
    for (var cores = 2; cores <= 128; cores++) {
      expect(OfflineCpuPolicy.threadCount(cores), lessThan(cores));
      expect(OfflineCpuPolicy.threadCount(cores), inInclusiveRange(1, 6));
    }
  });
  test('invalid or unknown core count falls back to a single worker', () {
    expect(OfflineCpuPolicy.threadCount(0), 1);
    expect(OfflineCpuPolicy.threadCount(-1), 1);
  });
}
