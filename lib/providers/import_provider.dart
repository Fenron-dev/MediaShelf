import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/import_service.dart';
import '../domain/models/import_result.dart';
import 'library_provider.dart';

// ── Import state ──────────────────────────────────────────────────────────────

enum ImportPhase { idle, analyzing, waitingForDuplicates, executing, done }

class ImportState {
  const ImportState({
    this.phase = ImportPhase.idle,
    this.plan,
    this.result,
    this.error,
  });

  final ImportPhase phase;
  final ImportPlan? plan;
  final ImportResult? result;
  final String? error;

  bool get isWorking =>
      phase == ImportPhase.analyzing || phase == ImportPhase.executing;

  ImportState copyWith({
    ImportPhase? phase,
    ImportPlan? plan,
    ImportResult? result,
    String? error,
  }) =>
      ImportState(
        phase: phase ?? this.phase,
        plan: plan ?? this.plan,
        result: result ?? this.result,
        error: error ?? this.error,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ImportNotifier extends StateNotifier<ImportState> {
  ImportNotifier(this._ref) : super(const ImportState());

  final Ref _ref;

  /// Step 1 — analyse source paths with the given strip prefix.
  Future<ImportPlan?> analyze(
    List<String> sourcePaths,
    String stripPrefix,
  ) async {
    state = const ImportState(phase: ImportPhase.analyzing);
    try {
      final service = _buildService();
      final plan = await service.analyze(sourcePaths, stripPrefix);
      state = ImportState(
        phase: plan.hasDuplicates
            ? ImportPhase.waitingForDuplicates
            : ImportPhase.executing,
        plan: plan,
      );
      return plan;
    } catch (e) {
      state = ImportState(phase: ImportPhase.idle, error: e.toString());
      return null;
    }
  }

  /// Step 2 — execute the plan (after duplicates have been resolved).
  Future<ImportResult?> execute({
    bool createCollectionMirror = false,
    String? collectionName,
  }) async {
    final plan = state.plan;
    if (plan == null) return null;

    state = state.copyWith(phase: ImportPhase.executing);
    try {
      final service = _buildService();
      final result = await service.execute(
        plan,
        createCollectionMirror: createCollectionMirror,
        collectionName: collectionName,
      );
      state = ImportState(phase: ImportPhase.done, result: result);
      return result;
    } catch (e) {
      state = ImportState(
        phase: ImportPhase.idle,
        plan: plan,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() => state = const ImportState();

  ImportService _buildService() {
    final libraryPath = _ref.read(libraryPathProvider);
    if (libraryPath == null) throw StateError('No library open');
    return ImportService(
      libraryPath: libraryPath,
      assetsDao: _ref.read(assetsDaoProvider),
      collectionsDao: _ref.read(collectionsDaoProvider),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final importProvider =
    StateNotifierProvider<ImportNotifier, ImportState>(
  (ref) => ImportNotifier(ref),
);
