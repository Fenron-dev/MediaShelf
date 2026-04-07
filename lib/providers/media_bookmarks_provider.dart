import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import 'library_provider.dart';

// ── Document position providers ───────────────────────────────────────────────

final documentPositionProvider =
    FutureProvider.family<DocumentPosition?, String>((ref, assetId) {
  return ref.watch(documentPositionsDaoProvider).getPosition(assetId);
});

// ── Bookmark providers ────────────────────────────────────────────────────────

final bookmarksProvider =
    StreamProvider.family<List<MediaBookmark>, String>((ref, assetId) {
  return ref.watch(mediaBookmarksDaoProvider).watchBookmarks(assetId);
});

final bookmarkCountProvider =
    StreamProvider.family<int, String>((ref, assetId) {
  return ref.watch(mediaBookmarksDaoProvider).watchBookmarkCount(assetId);
});
