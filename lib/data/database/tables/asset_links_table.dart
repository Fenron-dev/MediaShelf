import 'package:drift/drift.dart';

import 'assets_table.dart';

/// Links between assets (internal file references).
///
/// When files are linked, they share the same metadata (tags, properties, etc.).
/// The [originalId] is the "source of truth". If the original is deleted,
/// one linked asset is promoted to become the new original.
class AssetLinks extends Table {
  TextColumn get id => text()();

  /// The original / primary asset.
  TextColumn get originalId =>
      text().references(Assets, #id, onDelete: KeyAction.restrict)();

  /// The linked (secondary) asset.
  TextColumn get linkedId =>
      text().references(Assets, #id, onDelete: KeyAction.cascade)();

  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {originalId, linkedId},
      ];
}
