import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/scan_result.dart';
import 'asset_list_provider.dart';
import 'library_provider.dart';

class ScanState {
  const ScanState({
    this.isScanning = false,
    this.phase = ScanPhase.idle,
    this.processed = 0,
    this.total = 0,
    this.thumbsDone = 0,
    this.thumbsTotal = 0,
    this.lastResult,
    this.error,
  });

  final bool isScanning;
  final ScanPhase phase;
  final int processed;
  final int total;
  final int thumbsDone;
  final int thumbsTotal;
  final ScanResult? lastResult;
  final String? error;

  double get progress => total == 0 ? 0 : processed / total;
  double get thumbProgress => thumbsTotal == 0 ? 0 : thumbsDone / thumbsTotal;

  bool get isGeneratingThumbs =>
      phase == ScanPhase.thumbnails && thumbsTotal > 0;

  ScanState copyWith({
    bool? isScanning,
    ScanPhase? phase,
    int? processed,
    int? total,
    int? thumbsDone,
    int? thumbsTotal,
    ScanResult? lastResult,
    String? error,
  }) =>
      ScanState(
        isScanning: isScanning ?? this.isScanning,
        phase: phase ?? this.phase,
        processed: processed ?? this.processed,
        total: total ?? this.total,
        thumbsDone: thumbsDone ?? this.thumbsDone,
        thumbsTotal: thumbsTotal ?? this.thumbsTotal,
        lastResult: lastResult ?? this.lastResult,
        error: error,
      );
}

enum ScanPhase { idle, scanning, thumbnails }

class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier(this._ref) : super(const ScanState());

  final Ref _ref;

  Future<void> startScan() async {
    if (state.isScanning) return;
    state = const ScanState(isScanning: true, phase: ScanPhase.scanning);

    try {
      final repo = _ref.read(libraryRepositoryProvider);

      // Phase 1: file scan
      final result = await repo.scanLibrary(
        onProgress: (processed, total) {
          state = state.copyWith(
            phase: ScanPhase.scanning,
            processed: processed,
            total: total,
          );
        },
        onThumbnailsStarted: (total) {
          state = state.copyWith(
            phase: ScanPhase.thumbnails,
            thumbsTotal: total,
            thumbsDone: 0,
          );
        },
        onThumbnailGenerated: (path) {
          state = state.copyWith(
            phase: ScanPhase.thumbnails,
            thumbsDone: state.thumbsDone + 1,
          );
        },
      );

      state = ScanState(lastResult: result);
      // Invalidate asset grid
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
