import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/asset_filter.dart';

class AssetFilterNotifier extends StateNotifier<AssetFilter> {
  AssetFilterNotifier() : super(const AssetFilter());

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void setDirFilter(String dir, {bool includeSubdirs = true}) =>
      state = state.copyWith(dirFilter: dir, includeSubdirs: includeSubdirs);

  void clearDirFilter() =>
      state = state.copyWith(dirFilter: '');

  void setCollectionId(String? id) => id == null
      ? state = state.copyWith(clearCollectionId: true)
      : state = state.copyWith(collectionId: id);

  void setTagFilter(String? tag) => tag == null
      ? state = state.copyWith(clearTagFilter: true)
      : state = state.copyWith(tagFilter: tag);

  void setRatingMin(int rating) =>
      state = state.copyWith(ratingMin: rating);

  void setColorLabel(String label) =>
      state = state.copyWith(colorLabel: label);

  void setMimeType(String mime) =>
      state = state.copyWith(mimeType: mime);

  void setExtension(String ext) =>
      state = state.copyWith(extension: ext);

  void setHasResume(ResumeFilter value) =>
      state = state.copyWith(hasResume: value);

  void setSortBy(SortBy sortBy) =>
      state = state.copyWith(sortBy: sortBy);

  void toggleSortDir() => state = state.copyWith(
        sortDir: state.sortDir == SortDir.asc ? SortDir.desc : SortDir.asc,
      );

  void setSortDir(SortDir dir) => state = state.copyWith(sortDir: dir);

  void setRandomMode(bool on) => state = state.copyWith(randomMode: on);

  void clearAll() => state = const AssetFilter();
}

final assetFilterProvider =
    StateNotifierProvider<AssetFilterNotifier, AssetFilter>(
  (ref) => AssetFilterNotifier(),
);
