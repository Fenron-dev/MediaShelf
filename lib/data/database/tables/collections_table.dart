import 'package:drift/drift.dart';

import 'assets_table.dart';

class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Parent collection id — enables hierarchical collections.
  TextColumn get parentId => text().nullable()();

  /// When true, [smartFilterQuery] is a JSON rule set.
  BoolColumn get isSmartFilter =>
      boolean().withDefault(const Constant(false))();

  /// JSON string: `{"logic":"AND","rules":[...]}` — same format as Nexus Explorer.
  TextColumn get smartFilterQuery => text().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Auto-created mirror collection from an imported folder structure.
  BoolColumn get isMirror => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class CollectionAssets extends Table {
  TextColumn get collectionId =>
      text().references(Collections, #id, onDelete: KeyAction.cascade)();
  TextColumn get assetId =>
      text().references(Assets, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {collectionId, assetId};
}
