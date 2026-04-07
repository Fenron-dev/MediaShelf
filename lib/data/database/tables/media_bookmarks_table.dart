import 'package:drift/drift.dart';

import 'assets_table.dart';

/// Universal bookmark table for ePub, PDF, video, and audio assets.
///
/// [positionKey] encoding per media type:
/// - epub:  CFI string
/// - pdf:   page number as string
/// - video/audio: position in milliseconds as string
class MediaBookmarks extends Table {
  TextColumn get id => text()();

  TextColumn get assetId =>
      text().references(Assets, #id, onDelete: KeyAction.cascade)();

  /// 'epub' | 'pdf' | 'video' | 'audio'
  TextColumn get mediaType => text()();

  /// CFI / page number / milliseconds as string.
  TextColumn get positionKey => text()();

  /// Optional user label, e.g. "Spannende Szene".
  TextColumn get label => text().nullable()();

  /// Optional longer note.
  TextColumn get note => text().nullable()();

  /// Human-readable position, e.g. "Kapitel 3", "Seite 12", "0:45:22".
  TextColumn get positionLabel => text().nullable()();

  /// Color tag for highlights: 'yellow'|'green'|'blue'|'pink'|'orange'.
  TextColumn get colorTag => text().nullable()();

  /// Highlighted/quoted text (ePub highlights).
  TextColumn get quote => text().nullable()();

  /// Milliseconds since epoch.
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
