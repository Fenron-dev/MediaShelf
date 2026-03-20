import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../data/database/daos/assets_dao.dart';
import '../providers/asset_filter_provider.dart';
import 'library_provider.dart';

/// Monotonically incrementing version — bumped after each scan to invalidate
/// cached asset pages and force a refresh of the grid.
final scanVersionProvider = StateProvider<int>((ref) => 0);

/// Returns a single page of [Asset]s matching the current filter.
///
/// Keyed by page index via `.family`. Watches both [assetFilterProvider] and
/// [scanVersionProvider] so it re-runs automatically when either changes.
final assetPageProvider =
    FutureProvider.family<AssetsPage, int>((ref, page) async {
  final filter = ref.watch(assetFilterProvider);
  ref.watch(scanVersionProvider); // invalidate on scan
  final dao = ref.watch(assetsDaoProvider);
  return dao.queryPage(filter: filter, page: page, pageSize: kPageSize);
});

/// Total asset count for the current filter (from page 0 only, reused).
final assetTotalProvider = FutureProvider<int>((ref) async {
  final page0 = await ref.watch(assetPageProvider(0).future);
  return page0.total;
});

// ── Selection ─────────────────────────────────────────────────────────────────

/// Single-selected asset id (detail panel).
final selectedAssetIdProvider = StateProvider<String?>((ref) => null);

/// Multi-select set (bulk operations).
class MultiSelectNotifier extends StateNotifier<Set<String>> {
  MultiSelectNotifier() : super({});

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void selectAll(List<String> ids) => state = ids.toSet();

  void clear() => state = {};
}

final multiSelectProvider =
    StateNotifierProvider<MultiSelectNotifier, Set<String>>(
  (ref) => MultiSelectNotifier(),
);

/// Whether multi-select mode is active.
final isMultiSelectProvider = Provider<bool>(
  (ref) => ref.watch(multiSelectProvider).isNotEmpty,
);
