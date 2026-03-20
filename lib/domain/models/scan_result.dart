class ScanResult {
  const ScanResult({
    required this.added,
    required this.updated,
    required this.missing,
    required this.total,
    required this.elapsed,
  });

  final int added;
  final int updated;
  final int missing;
  final int total;
  final Duration elapsed;

  @override
  String toString() =>
      'ScanResult(added: $added, updated: $updated, missing: $missing, '
      'total: $total, elapsed: ${elapsed.inMilliseconds}ms)';
}

/// Progress update emitted during a scan.
class ScanProgress {
  const ScanProgress({required this.processed, required this.total});
  final int processed;
  final int total;
}
