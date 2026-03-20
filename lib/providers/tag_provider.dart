import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/daos/tags_dao.dart';
import 'library_provider.dart';

/// Live stream of all tags with their usage counts.
final allTagsProvider = StreamProvider<List<TagWithCount>>((ref) {
  final dao = ref.watch(tagsDaoProvider);
  return dao.watchAllTagsWithCount();
});

/// Tags for a specific asset — keyed by asset id.
final assetTagsProvider =
    FutureProvider.family<List<TagWithCount>, String>((ref, assetId) async {
  final assetsDao = ref.watch(assetsDaoProvider);
  final tags = await assetsDao.getTagsForAsset(assetId);
  return tags.map((t) => TagWithCount(tag: t, count: 0)).toList();
});
