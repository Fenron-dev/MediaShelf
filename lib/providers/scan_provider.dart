import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/scan_result.dart';
import 'asset_list_provider.dart';
import 'library_provider.dart';

class ScanState {
  const ScanState({
    this.isScanning = false,
    this.processed = 0,
    this.total = 0,
    this.lastResult,
    this.error,
  });

  final bool isScanning;
  final int processed;
  final int total;
  final ScanResult? lastResult;
  final String? error;

  double get progress => total == 0 ? 0 : processed / total;

  ScanState copyWith({
    bool? isScanning,
    int? processed,
    int? total,
    ScanResult? lastResult,
    String? error,
  }) =>
      ScanState(
        isScanning: isScanning ?? this.isScanning,
        processed: processed ?? this.processed,
        total: total ?? this.total,
        lastResult: lastResult ?? this.lastResult,
        error: error,
      );
}

class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier(this._ref) : super(const ScanState());

  final Ref _ref;

  Future<void> startScan() async {
    if (state.isScanning) return;
    state = const ScanState(isScanning: true);

    try {
      final repo = _ref.read(libraryRepositoryProvider);
      final result = await repo.scanLibrary(
        onProgress: (processed, total) {
          state = state.copyWith(processed: processed, total: total);
        },
      );
      state = ScanState(lastResult: result);
      // Bump scan version to invalidate asset page cache
      _ref.read(scanVersionProvider.notifier).state++;
    } catch (e) {
      state = ScanState(error: e.toString());
    }
  }

  void dismiss() => state = ScanState(lastResult: state.lastResult);
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>(
  (ref) => ScanNotifier(ref),
);
