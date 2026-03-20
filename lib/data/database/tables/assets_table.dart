import 'package:drift/drift.dart';

/// Maps to the `assets` table — central record for every indexed file.
///
/// Schema is intentionally compatible with Nexus Explorer's SQLite schema.
class Assets extends Table {
  /// UUID v4, stable identifier.
  TextColumn get id => text()();

  /// Relative path from library root, forward slashes on all platforms.
  TextColumn get path => text().unique()();

  TextColumn get filename => text()();
  TextColumn get extension => text().nullable()();

  /// File size in bytes.
  IntColumn get size => integer().nullable()();

  TextColumn get mimeType => text().nullable()();

  /// Image/video width in pixels.
  IntColumn get width => integer().nullable()();

  /// Image/video height in pixels.
  IntColumn get height => integer().nullable()();

  /// Duration in milliseconds (audio/video).
  IntColumn get durationMs => integer().nullable()();

  /// Saved playback position in milliseconds (resume support).
  IntColumn get playbackPositionMs => integer().nullable()();

  /// MD5 hex string — used for move/rename detection.
  TextColumn get contentHash => text().nullable()();

  /// Perceptual hash (for future duplicate/similarity detection).
  TextColumn get phash => text().nullable()();

  /// 'ok' | 'missing'
  TextColumn get status => text().withDefault(const Constant('ok'))();

  /// Star rating 0–5.
  IntColumn get rating => integer().withDefault(const Constant(0))();

  /// One of: red, yellow, green, blue, purple — or null.
  TextColumn get colorLabel => text().nullable()();

  /// Short user note / description (also indexed in FTS5).
  TextColumn get note => text().nullable()();

  TextColumn get sourceUrl => text().nullable()();

  /// Unix timestamp (ms) of OS file creation time.
  IntColumn get fileCreatedAt => integer().nullable()();

  /// Unix timestamp (ms) of OS file modification time.
  IntColumn get fileModifiedAt => integer().nullable()();

  /// Unix timestamp (ms) when this record was last scanned/indexed.
  IntColumn get indexedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
