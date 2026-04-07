import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

part 'media_bookmarks_dao.g.dart';

@DriftAccessor(tables: [MediaBookmarks])
class MediaBookmarksDao extends DatabaseAccessor<AppDatabase>
    with _$MediaBookmarksDaoMixin {
  MediaBookmarksDao(super.db);

  /// Watch all bookmarks for [assetId], ordered newest first.
  Stream<List<MediaBookmark>> watchBookmarks(String assetId) =>
      (select(mediaBookmarks)
            ..where((t) => t.assetId.equals(assetId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// Watch the bookmark count for [assetId].
  Stream<int> watchBookmarkCount(String assetId) => watchBookmarks(assetId)
      .map((list) => list.length);

  /// Insert a new bookmark and return it.
  Future<MediaBookmark> addBookmark({
    required String assetId,
    required String mediaType,
    required String positionKey,
    String? label,
    String? note,
    String? positionLabel,
    String? colorTag,
    String? quote,
  }) async {
    final id = const Uuid().v4();
    final companion = MediaBookmarksCompanion.insert(
      id: id,
      assetId: assetId,
      mediaType: mediaType,
      positionKey: positionKey,
      label: Value(label),
      note: Value(note),
      positionLabel: Value(positionLabel),
      colorTag: Value(colorTag),
      quote: Value(quote),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await into(mediaBookmarks).insert(companion);
    return (select(mediaBookmarks)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// Delete a bookmark by [id].
  Future<void> deleteBookmark(String id) =>
      (delete(mediaBookmarks)..where((t) => t.id.equals(id))).go();

  /// Update label/note of a bookmark.
  Future<void> updateBookmark(String id, {String? label, String? note}) =>
      (update(mediaBookmarks)..where((t) => t.id.equals(id))).write(
        MediaBookmarksCompanion(
          label: Value(label),
          note: Value(note),
        ),
      );
}
