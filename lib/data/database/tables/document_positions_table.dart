import 'package:drift/drift.dart';

import 'assets_table.dart';

/// Stores the last reading position for ePub and PDF assets.
///
/// - ePub: [positionKey] is a CFI string (e.g. "epubcfi(/6/4[ch001]!/4/2/1:0)")
/// - PDF:  [positionKey] is the page number as a string (e.g. "42")
class DocumentPositions extends Table {
  TextColumn get assetId =>
      text().references(Assets, #id, onDelete: KeyAction.cascade)();

  /// CFI string (ePub) or page number string (PDF).
  TextColumn get positionKey => text()();

  /// Human-readable label, e.g. "Kapitel 3" or "Seite 42".
  TextColumn get positionLabel => text().nullable()();

  /// Reading progress 0.0–1.0.
  RealColumn get progress => real().withDefault(const Constant(0.0))();

  /// Milliseconds since epoch.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {assetId};
}
