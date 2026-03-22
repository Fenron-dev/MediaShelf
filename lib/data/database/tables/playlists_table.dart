import 'package:drift/drift.dart';

import 'assets_table.dart';

/// A named, ordered playlist (audio-only or video-only).
class Playlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// 'audio' | 'video'
  TextColumn get mediaType => text()();

  /// Unix timestamp (ms) when the playlist was created.
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One entry in a [Playlist] — an asset at a specific position.
class PlaylistItems extends Table {
  TextColumn get id => text()();
  TextColumn get playlistId =>
      text().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get assetId =>
      text().references(Assets, #id, onDelete: KeyAction.cascade)();

  /// 0-based order index (lower = plays first).
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
