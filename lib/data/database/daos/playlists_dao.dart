import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

part 'playlists_dao.g.dart';

@DriftAccessor(tables: [Playlists, PlaylistItems, Assets])
class PlaylistsDao extends DatabaseAccessor<AppDatabase>
    with _$PlaylistsDaoMixin {
  PlaylistsDao(super.db);

  // ── Playlists ──────────────────────────────────────────────────────────────

  Stream<List<Playlist>> watchAll() =>
      (select(playlists)
            ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
          .watch();

  Future<List<Playlist>> getAll() =>
      (select(playlists)
            ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
          .get();

  Future<Playlist?> getById(String id) =>
      (select(playlists)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<String> createPlaylist({
    required String name,
    required String mediaType, // 'audio' | 'video'
  }) async {
    final id = const Uuid().v4();
    await into(playlists).insert(PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      mediaType: Value(mediaType),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return id;
  }

  Future<void> renamePlaylist(String id, String name) =>
      (update(playlists)..where((p) => p.id.equals(id)))
          .write(PlaylistsCompanion(name: Value(name)));

  Future<void> deletePlaylist(String id) =>
      (delete(playlists)..where((p) => p.id.equals(id))).go();

  /// Returns all playlists that contain [assetId].
  Future<List<Playlist>> getPlaylistsForAsset(String assetId) async {
    final rows = await (select(playlists).join([
      innerJoin(
          playlistItems, playlistItems.playlistId.equalsExp(playlists.id)),
    ])
          ..where(playlistItems.assetId.equals(assetId)))
        .get();
    return rows.map((r) => r.readTable(playlists)).toList();
  }

  // ── Playlist items ─────────────────────────────────────────────────────────

  /// Returns the ordered items of a playlist, joined with their Asset data.
  Future<List<PlaylistItemWithAsset>> getItems(String playlistId) async {
    final rows = await (select(playlistItems).join([
      innerJoin(assets, assets.id.equalsExp(playlistItems.assetId)),
    ])
          ..where(playlistItems.playlistId.equals(playlistId))
          ..orderBy([OrderingTerm.asc(playlistItems.position)]))
        .get();
    return rows.map((row) => PlaylistItemWithAsset(
          item: row.readTable(playlistItems),
          asset: row.readTable(assets),
        )).toList();
  }

  Stream<List<PlaylistItemWithAsset>> watchItems(String playlistId) {
    return (select(playlistItems).join([
      innerJoin(assets, assets.id.equalsExp(playlistItems.assetId)),
    ])
          ..where(playlistItems.playlistId.equals(playlistId))
          ..orderBy([OrderingTerm.asc(playlistItems.position)]))
        .watch()
        .map((rows) => rows
            .map((row) => PlaylistItemWithAsset(
                  item: row.readTable(playlistItems),
                  asset: row.readTable(assets),
                ))
            .toList());
  }

  /// Appends [assetId] to the end of [playlistId]. No-op if already present.
  Future<void> addItem(String playlistId, String assetId) async {
    final existing = await (select(playlistItems)
          ..where((i) =>
              i.playlistId.equals(playlistId) & i.assetId.equals(assetId)))
        .getSingleOrNull();
    if (existing != null) return;

    final maxPos = await _maxPosition(playlistId);
    await into(playlistItems).insert(PlaylistItemsCompanion(
      id: Value(const Uuid().v4()),
      playlistId: Value(playlistId),
      assetId: Value(assetId),
      position: Value(maxPos + 1),
    ));
  }

  /// Inserts [assetId] at [position], shifting everything else down.
  Future<void> insertItemAt(
      String playlistId, String assetId, int position) async {
    await customStatement(
      'UPDATE playlist_items SET position = position + 1'
      ' WHERE playlist_id = ? AND position >= ?',
      [playlistId, position],
    );
    await into(playlistItems).insert(PlaylistItemsCompanion(
      id: Value(const Uuid().v4()),
      playlistId: Value(playlistId),
      assetId: Value(assetId),
      position: Value(position),
    ));
  }

  Future<void> removeItem(String itemId) =>
      (delete(playlistItems)..where((i) => i.id.equals(itemId))).go();

  Future<void> removeAssetFromPlaylist(
          String playlistId, String assetId) =>
      (delete(playlistItems)
            ..where((i) =>
                i.playlistId.equals(playlistId) &
                i.assetId.equals(assetId)))
          .go();

  /// Reorders: moves item at [oldIndex] to [newIndex], fixes position for all.
  Future<void> reorder(
      String playlistId, int oldIndex, int newIndex) async {
    final items = await getItems(playlistId);
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);
    for (var i = 0; i < items.length; i++) {
      await (update(playlistItems)
            ..where((pi) => pi.id.equals(items[i].item.id)))
          .write(PlaylistItemsCompanion(position: Value(i)));
    }
  }

  Future<int> _maxPosition(String playlistId) async {
    final result = await customSelect(
      'SELECT COALESCE(MAX(position), -1) AS max_pos FROM playlist_items'
      ' WHERE playlist_id = ?',
      variables: [Variable.withString(playlistId)],
    ).getSingle();
    return result.read<int>('max_pos');
  }
}

// ── Value object ──────────────────────────────────────────────────────────────

class PlaylistItemWithAsset {
  const PlaylistItemWithAsset({required this.item, required this.asset});
  final PlaylistItem item;
  final Asset asset;
}
