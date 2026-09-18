/// Conservative mobile CPU policy. Logical cores are an upper bound, not a
/// claim about big/LITTLE performance cores. Leave scheduling headroom for UI.
class OfflineCpuPolicy {
  const OfflineCpuPolicy._();

  static int threadCount(int logicalCores) {
    if (logicalCores <= 2) return 1;
    if (logicalCores <= 4) return logicalCores - 1;
    if (logicalCores <= 8) return 4;
    return 6;
  }
}
